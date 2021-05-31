/*
 * The MIT License
 * Copyright (c) 2020- Nordic Institute for Interoperability Solutions (NIIS)
 * Copyright (c) 2019 Estonian Information System Authority (RIA)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

package ee.aktors.misp2.interceptor;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.ActionInvocation;

import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.service.EulaService;
import ee.aktors.misp2.service.PortalService;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.service.XroadInstanceService;
import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
public class PortalInterceptor extends BaseInterceptor {

    private static final long serialVersionUID = 1L;
    private PortalService portalService;
    private UserService userService;
    private XroadInstanceService xroadInstanceService;
    private EulaService eulaService;
    private static final String LOGIN_ATTEMPT = "loginAttempt";
    private static final Logger LOGGER = LogManager.getLogger(PortalInterceptor.class.getName());

    /**
     * Dependency injection
     * @param portalService portal service
     * @param userService user service
     * @param xroadInstanceService service of X-Road instances
     */
    public PortalInterceptor(PortalService portalService, UserService userService,
            XroadInstanceService xroadInstanceService, EulaService eulaService) {
        this.portalService = portalService;
        this.userService = userService;
        this.xroadInstanceService = xroadInstanceService;
        this.eulaService = eulaService;
    }

    /**
     * Sets portal if one doesn't already exist
     * @see com.opensymphony.xwork2.interceptor.Interceptor#intercept(com.opensymphony.xwork2.ActionInvocation)
     * @param invocation  a action invocation
     * @return invocation return code
     * @throws Exception can throw
     */
    public String intercept(ActionInvocation invocation) throws Exception {
        LOGGER.debug("PORTAL INTERCEPTOR");
        Map<String, Object> session = invocation.getInvocationContext().getSession();

        Portal portal = (Portal) session.get(Const.SESSION_PORTAL);

        if (portal == null) { // first attempt to enter MISP or admin UI without added portal
            LOGGER.debug("No portal in session");
            String loginAttempt = ((HttpServletRequest) invocation.getInvocationContext().get(HTTP_REQUEST))
                    .getParameter(LOGIN_ATTEMPT);

            if (loginAttempt != null && !loginAttempt.trim().isEmpty()) {
                LOGGER.debug("Trying to login through admin console");
                return invocation.invoke();

            } else if (session.get(Const.SESSION_USER_HANDLE) != null) {
                LOGGER.debug("User logged is in but no portal exists");
                List<Portal> allPortals = portalService.findUserPortalsAllowed((Person) (session
                        .get(Const.SESSION_USER_HANDLE)));
                if (allPortals != null && !allPortals.isEmpty()) {
                    synchronized (session) {
                        Person user = (Person) (session.get(Const.SESSION_USER_HANDLE));
                        Person userDB = userService.findObject(Person.class, user.getId());
                        portal = userDB.getLastPortal();
                        if (portal == null) {
                            portal = allPortals.get(0);
                            userDB.setLastPortal(portal);
                            user.setLastPortal(portal);
                        }
                        session.put(Const.SESSION_PORTAL, portal);
                        xroadInstanceService.saveActiveXroadInstancesToSession(session);
                        eulaService.savePendingEulasToSession(session);
                    }
                }

                return invocation.invoke();
            } else {
                LOGGER.warn("Returning 'no_portal'");
                return NO_PORTAL;
            }
        } else {
            LOGGER.debug("Portal exists and is fine");
        }
        return invocation.invoke();
    }

}
