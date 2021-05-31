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

package ee.aktors.misp2.httpMethodChecker;

import java.lang.reflect.Method;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.ActionInvocation;

import ee.aktors.misp2.interceptor.BaseInterceptor;
import ee.aktors.misp2.util.StrutsUtil;

/**
 * Deny (Redirect to "page not found" page) access to Struts 2 Action method if it has {@link HTTPMethods} annotation
 * specified and it's {@link HttpServletRequest}'s HTTP method is not in that annotation's allowed HTTP methods
 * 
 * @author karol.kartau
 */
public class HTTPMethodsInterceptor extends BaseInterceptor {

    private static final long serialVersionUID = -5185040724271143250L;
    private static final Logger LOGGER = LogManager.getLogger(HTTPMethodsInterceptor.class.getName());

    @Override
    public String intercept(ActionInvocation ai) throws Exception {
        HttpServletRequest req = (HttpServletRequest) ai.getInvocationContext().get(HTTP_REQUEST);
        String requestHTTPMethod = req.getMethod();

        Class<?> actionClass = ai.getAction().getClass();
        Method actionMethod = StrutsUtil.getInvokedActionMethod(ai);

        HTTPMethods httpMethods = actionMethod.getAnnotation(HTTPMethods.class);
        if (httpMethods != null) { // Only check for allowance if annotation is specified
            HTTPMethod[] httpMethodArray = httpMethods.methods();
            for (HTTPMethod httpMethod : httpMethodArray) {
                if (httpMethod.name().equalsIgnoreCase(requestHTTPMethod)) {
                    return ai.invoke();
                }
            }
            LOGGER.warn("Request was made to " + actionClass.getName() + "." + actionMethod.getName()
                    + "() with HTTP method " + requestHTTPMethod + ", but it is not allowed for that method");
            return PAGE_NOT_FOUND; // Request HTTP method was not in specified HTTP methods
        }

        return ai.invoke(); // Allowed HTTP methods were not specified
    }

}
