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

package ee.aktors.misp2.csrfProtection;

import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ActionInvocation;

import ee.aktors.misp2.action.LoginAction;
import ee.aktors.misp2.flash.FlashUtil;
import ee.aktors.misp2.interceptor.BaseInterceptor;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.StrutsUtil;

/**
 * Apply CSRF protection for all POST requests and requests to action methods marked with
 * {@link ApplyCSRFProtectionAlways}, unless they are to {@link LoginAction} (exception, because session may timeout
 * there without invalidating form). <br/>
 * If request marked for CSRF protection does not have CSRF token matching with one in session, then redirects to
 * default page with appropriate informative message
 * 
 * @author karol.kartau
 */
public class CSRFProtectionInterceptor extends BaseInterceptor {

    private static final long serialVersionUID = -1280147368001720651L;

    @Override
    public String intercept(ActionInvocation ai) throws Exception {
        HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
        HttpSession session = request.getSession();
        String csrfToken = (String) (session.getAttribute(Const.SESSION_CSRF_TOKEN) != null ? session
                .getAttribute(Const.SESSION_CSRF_TOKEN) : UUID.randomUUID().toString());
        session.setAttribute(Const.SESSION_CSRF_TOKEN, csrfToken);

        // GET requests are not CSRF protected, because it is assumed
        // that GET requests do not modify server data
        // Exception to this is if ApplyCSRFProtectionAlways annotation is set
        boolean testForCSRF = request.getMethod().equalsIgnoreCase("GET") == false
                || StrutsUtil.getInvokedActionMethod(ai).getAnnotation(ApplyCSRFProtectionAlways.class) != null;

        if (testForCSRF && ai.getAction().getClass().equals(LoginAction.class) == false) {
            String requestCSRFToken;
            // First, look for token from header
            requestCSRFToken = request.getHeader("X-CSRF-Token");
            // In case token was not found from header, look for a request parameter
            if (requestCSRFToken == null) {
                // Login page is safe for CSRF
                // Normally only one csrfToken parameter is sent, but because there is a possibility of accidentally
                // sending multiple (identical), then simply take always the first one
                String[] requestCSRFTokenList = request.getParameterValues("csrfToken");
                requestCSRFToken = (requestCSRFTokenList != null ? requestCSRFTokenList[0] : "");
            }
            if (requestCSRFToken.equals(csrfToken) == false) {
                // Request CSRFToken did not match with session one
                String requestedWithHeader = request.getHeader("X-Requested-With");
                FlashUtil.getFlash().put("errorMessage", getText("text.CSRF.error"));
                if (requestedWithHeader == null || requestedWithHeader.equals("XMLHttpRequest") == false) {
                    // If is not ajax request, then redirect
                    return "csrfError";
                } else {
                    // If is ajax request, then return login timeout status code (expect, that javascript itself
                    // redirects based on this code)
                    return "csrfAjaxError";
                }
            }
        }

        return ai.invoke();
    }

}
