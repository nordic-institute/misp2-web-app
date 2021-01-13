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

import java.lang.reflect.Field;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;
import org.apache.struts2.dispatcher.SessionMap;

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ActionInvocation;

import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.MenuUtil;

/**
 *
 * @author arnis.rips
 */
public class SessionInterceptor extends BaseInterceptor implements StrutsStatics {

    private static final long serialVersionUID = 1L;
    private static final int MS_IN_SECOND = 1000;
    private static final Logger LOGGER = LogManager.getLogger(SessionInterceptor.class.getName());

    
    /**
     * Checks session timeout or sets last access time for session
     * @see com.opensymphony.xwork2.interceptor.Interceptor#intercept(com.opensymphony.xwork2.ActionInvocation)
     * @param ai  a action invocation
     * @return invocation return code
     * @throws Exception can throw
     */
    public String intercept(ActionInvocation ai) throws Exception {
        if (LOGGER.isDebugEnabled()) {
            LOGGER.debug("SESSION INTERCEPTOR");
        }
        Map<String, Object> session = ai.getInvocationContext().getSession();
        String action = ActionContext.getContext().getName();

        // We do this, because in case of session expiration we do not invoke any more interceptors.
        // Because of this can't expect I8nWrappweInterceptor to be called,
        // but have to set ActionInvocation locale for the display of session expiration jsp
        I18nWrapperInterceptor.setActionInvocationLocaleToSystemDefault(ai);

        HttpServletRequest request = (HttpServletRequest) ai.getInvocationContext().get(HTTP_REQUEST);
        // Returns the current HttpSession associated with this request or,
        // if there is no current session and create is true, returns a new session.
        // If create is false and the request has no valid HttpSession, this method returns null.
        // updates session last accessed time and timeouts if necessary.
        // Needed because checking for timeout resets sessions built-in timeout countdown.
        HttpSession httpSession = request.getSession(false);
        if (httpSession != null) {
            Field field = httpSession.getClass().getDeclaredField("session");
            field.setAccessible(true);
            Object s = field.get(httpSession);
            if (s != null) {
                if (httpSession.getAttribute(Const.SESSION_LAST_ACCESS_TIME) == null)
                    httpSession.setAttribute(Const.SESSION_LAST_ACCESS_TIME, System.currentTimeMillis());
                // we do not update session last accessed time if were checking for timeout
                if (action.equals(MenuUtil.CHECK_TIMEOUT) == false) {
                    httpSession.setAttribute(Const.SESSION_LAST_ACCESS_TIME, System.currentTimeMillis());
                }
                // if were over the time out interval. Compare seconds
                if ((System.currentTimeMillis()
                        - (Long) httpSession.getAttribute(Const.SESSION_LAST_ACCESS_TIME)) / MS_IN_SECOND
                        >= httpSession.getMaxInactiveInterval()) {
                    ((SessionMap<String, Object>) session).invalidate();
                    return "session_expired";
                }
            }
        }
        /*
         * if ((httpSession==null || !request.isRequestedSessionIdValid()) && !(action.contains("admin"))) {
         * ((SessionMap)session).invalidate(); return "session_expired"; }
         */

        return ai.invoke();
    }

}
