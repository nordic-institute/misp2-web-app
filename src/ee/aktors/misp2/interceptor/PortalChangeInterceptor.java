/*
 * The MIT License
 * Copyright (c) 2020 NIIS <info@niis.org>
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

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;

import com.opensymphony.xwork2.ActionInvocation;

import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.PersonEula;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.PortalEula;
import ee.aktors.misp2.service.EulaService;
import ee.aktors.misp2.service.PortalService;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.service.XroadInstanceService;
import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
public class PortalChangeInterceptor extends BaseInterceptor {

    private static final long serialVersionUID = 1L;
    private PortalService portalService;
    private UserService userService;
    private XroadInstanceService xroadInstanceService;
    private EulaService eulaService;
    private static final Logger LOGGER = LogManager.getLogger(PortalChangeInterceptor.class);

    /**
     * Dependency injection
     * @param portalService service portal
     * @param userService service user
     * @param xroadInstanceService service of X-Road instances
     * @param eulaService service to access portal EULA and its accepting status by user
     */
    public PortalChangeInterceptor(PortalService portalService, UserService userService,
            XroadInstanceService xroadInstanceService, EulaService eulaService) {
        this.portalService = portalService;
        this.userService = userService;
        this.xroadInstanceService = xroadInstanceService;
        this.eulaService = eulaService;
    }
    
    /**
     * Checks if portal change is allowed
     * @see com.opensymphony.xwork2.interceptor.Interceptor#intercept(com.opensymphony.xwork2.ActionInvocation)
     * @param ai a action invocation
     * @return invocation return code
     * @throws Exception can throw
     */
    public String intercept(ActionInvocation ai) throws Exception {
        Map<String, Object> session = ai.getInvocationContext().getSession();
        LOGGER.debug("PORTALCHANGE INTERCEPTOR");

        Person user = (Person) session.get(Const.SESSION_USER_HANDLE);
        if (user != null) {
            Map<String, String> allUserPortals = portalService.findUserPortalsAllowedActiveNames(user, getLocale()
                    .getLanguage());

            if (allUserPortals != null) {
                // To avoid possible XSS issue in firefox
                for (String key : allUserPortals.keySet()) {
                    allUserPortals.put(key,StringEscapeUtils.escapeHtml(allUserPortals.get(key)));
                }
                LOGGER.debug("Inserting allUserPortals to invocation context");
                synchronized (ai.getInvocationContext()) {
                    ai.getInvocationContext().put("allUserPortals", allUserPortals);
                }
            }
            HttpServletRequest req = (HttpServletRequest) ai.getInvocationContext().get(StrutsStatics.HTTP_REQUEST);
            String pn = StringEscapeUtils.escapeHtml(req.getParameter("portalName"));
            if (pn != null) {
                Portal portal = portalService.findPortal(pn);
                if (portal != null) {
                    LOGGER.debug("Switching user " + user.getFullNameSsnParenthesis() + " portal to: "
                            + portal.getPortalFullString(getLocale().getLanguage()));

                    if (portal.isOpenPortal() || userHasRights(portal, user)) {
                        synchronized (session) {
                            session.put(Const.SESSION_PORTAL, portal);
                            xroadInstanceService.saveActiveXroadInstancesToSession(session);
                            user.setLastPortal(portal);
                            userService.save(user);
                            session.remove(Const.SESSION_ALL_ROLES);
                            eulaService.savePendingEulasToSession(session);
                            
                        }
                    } else {
                        LOGGER.warn("User " + user.getFullNameSsnParenthesis() + " tried to change portal to '" + pn
                                + "' but doesn't have rights in it");

                        addActionError(ai, getText("text.fail.enter_portal") + ": " + pn);
                        return UNAUTHORIZED;
                    }
                } else {
                    LOGGER.error("Tried to change portal but it was not found: " + pn);
                    addActionError(ai, getText("text.fail.enter_portal") + ": " + pn);
                    return UNAUTHORIZED;
                }
            }
        }
        return ai.invoke();
    }

    private boolean userHasRights(Portal portal, Person user) {
        List<OrgPerson> userOPs = userService.findPortalOrgPersons(portal, user);
        return userOPs != null && !userOPs.isEmpty();
    }

}
