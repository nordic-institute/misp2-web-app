/*
 * The MIT License
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

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.configuration.Configuration;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ActionInvocation;

import ee.aktors.misp2.beans.Auth;
import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.provider.ConfigurationProvider;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.util.Const;

/**
 *
 */
public class LoginInterceptor extends BaseInterceptor {

    private static final String LOGIN = "login";
    private static final long serialVersionUID = 1L;
    private UserService serviceUser;
    final Configuration config = ConfigurationProvider.getConfig();
    private static final Logger LOGGER = LogManager.getLogger(LoginInterceptor.class.getName());

    /**
     * @param serviceUser
     *            serviceUser
     */
    public LoginInterceptor(UserService serviceUser) {

        this.serviceUser = serviceUser;
    }

    /**
     * Checks if user login is authorized
     * @see com.opensymphony.xwork2.interceptor.Interceptor#intercept(com.opensymphony.xwork2.ActionInvocation)
     * @param invocation actionInvocation
     * @return invokation result
     * @throws Exception if invoking invocation throws an error
     */
    public String intercept(ActionInvocation invocation) throws Exception {
        LOGGER.debug("LOGIN INTERCEPTOR");
        Map<String, Object> session = invocation.getInvocationContext().getSession();

        Portal portal = (Portal) session.get(Const.SESSION_PORTAL);
        HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);

        String actionName = invocation.getInvocationContext().getName();
        boolean userLoggedIn = session.get(Const.SESSION_USER_HANDLE) instanceof Person;
        boolean userExists = false;
        if (userLoggedIn) {
            Person user = (Person) session.get(Const.SESSION_USER_HANDLE);
            Auth auth = (Auth) session.get(Const.SESSION_AUTH);
            
            userExists = serviceUser.findPersonBySSN(user.getSsn()) != null || auth.isAdmin();
            LOGGER.debug("User logged in: " + user + " auth: " + auth);
            if (portal != null && !auth.isAdmin()) {
                // check if user has an account in this portal
                if (portal.getMispType() == Const.MISP_TYPE_SIMPLE && !userHasRights(user, portal)) {

                    addActionError(invocation, getText("text.fail.enter_portal"));

                    return UNAUTHORIZED;
                } else if (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL
                        && !portal.getRegisterUnits().booleanValue() && !userHasRights(user, portal)) {

                    addActionError(invocation, getText("text.fail.enter_portal"));
                    return UNAUTHORIZED;
                }
            }
            // check if user's ssl id is same as in session
            if (config.getBoolean("auth.sslid")) {
                String userSslID = (String) request.getAttribute("javax.servlet.request.ssl_session");
                LOGGER.debug("User SSL ID: " + userSslID);
                String sessionSslid = (String) session.get(Const.SESSION_SSLID);
                LOGGER.debug("session SSL ID: " + sessionSslid);
                if (sessionSslid != null && !sessionSslid.equals(userSslID)) {
                    addActionError(invocation, getText("text.fail.enter_portal"));
                    LOGGER.error("Invalid SSL ID!");
                    return UNAUTHORIZED;
                }
            }
        }

        if (!userLoggedIn && !actionName.contains(LOGIN)) {
            LOGGER.debug("User not logged in");
            addActionError(invocation, getText("not_logged_in"));

            return NOT_LOGGED_IN;
        } else if (userLoggedIn && !userExists) {
            LOGGER.debug("User was logged in but no longer exists");
            addActionError(invocation, getText("user_dont_exist"));

            return USER_DOESNT_EXIST;
        }

        LOGGER.debug("User not logged in: Logging in...");
        return invocation.invoke();
    }

    private boolean userHasRights(Person user, Portal portal) {
        List<OrgPerson> userOPs = serviceUser.findPortalOrgPersons(portal, user);
        return userOPs != null && !userOPs.isEmpty();
    }

    @SuppressWarnings("unused")
    private static String setParameter(String url, String name, String value) {
        // encode values to be added
        try {
            name = URLEncoder.encode(name, "UTF-8");
            value = URLEncoder.encode(value, "UTF-8");
        } catch (UnsupportedEncodingException e1) {
            e1.printStackTrace();
        }

        // replace existing parameter value, if present
        int paramPos = url.indexOf(name + "=");
        if (paramPos != -1) {
            String tmp = url.substring(paramPos);
            int pos = tmp.indexOf('&') != -1 ? tmp.indexOf('&') : tmp.indexOf('#');
            if (pos != -1) {
                tmp = tmp.substring(pos);
            } else {
                tmp = "";
            }
            url = url.substring(0, paramPos) + name + '=' + value + tmp;
        } else { // add parameter
            int qpos = url.indexOf('?');
            int hpos = url.indexOf('#');
            char sep = qpos == -1 ? '?' : '&';

            String seg = sep + name + '=' + value;

            url = hpos == -1 ? url + seg : url.substring(0, hpos) + seg + url.substring(hpos);
        }

        return url;
    }

}
