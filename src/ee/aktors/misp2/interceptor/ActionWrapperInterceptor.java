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

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.AbstractInterceptor;
import ee.aktors.misp2.util.Const;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.StrutsStatics;

/**
 *
 * @author arnis.rips
 */
public class ActionWrapperInterceptor extends AbstractInterceptor implements StrutsStatics {

    private static final long serialVersionUID = 1L;

    /**
     * Sets response headers
     * @param ai actionInvocation to intercept
     * @return {@code ai} invocation result
     * @throws Exception thrown by {@code ai.invoke()}
     */
    public String intercept(ActionInvocation ai) throws Exception {
        HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
        HttpServletResponse response = (HttpServletResponse) ActionContext.getContext().get(HTTP_RESPONSE);

        String requestedWithHeader = request.getHeader("X-Requested-With");
        // If is not ajax
        if (requestedWithHeader == null || requestedWithHeader.equals("XMLHttpRequest") == false) {
            // Ensure that servers response is not cached by the browser according to http://stackoverflow.com/a/3414217
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
            response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
            response.setDateHeader("Expires", -1); // Proxies.
        }

        //Protection against clickjacking
        response.setHeader("X-Frame-Options", "SAMEORIGIN");

        ActionContext context = ai.getInvocationContext();
        Map<String, Object> session = context.getSession();
        String action = context.getName();

        String res = ai.invoke();

        // check that session exists (Struts2 creates session when something is put into session, but session can't be
        // created after invocation)
        if (ServletActionContext.getRequest().getSession(false) != null
                && !ServletActionContext.getRequest().getSession().isNew()) {
                session.put(Const.SESSION_PREVIOUS_ACTION, action);
        }
        return res;
    }

}

