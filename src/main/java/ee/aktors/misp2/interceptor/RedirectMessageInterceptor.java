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

/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import java.util.Collection;
import java.util.List;
import java.util.Map;

import org.apache.struts2.result.ServletActionRedirectResult;
import org.apache.struts2.result.ServletRedirectResult;

import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.Result;
import com.opensymphony.xwork2.interceptor.ValidationAware;
import com.opensymphony.xwork2.interceptor.MethodFilterInterceptor;

/**
 * An Interceptor to preserve an actions ValidationAware messages across a redirect result.
 *
 * It makes the assumption that you always want to preserve messages across a redirect and restore them to the next
 * action if they exist.
 *
 * The way this works is it looks at the result type after a action has executed and if the result was a redirect
 * (ServletRedirectResult) or a redirectAction (ServletActionRedirectResult) and there were any errors, messages, or
 * fieldErrors they are stored in the session. Before the next action executes it will check if there are any messages
 * stored in the session and add them to the next action.
 *
 */
public class RedirectMessageInterceptor extends MethodFilterInterceptor {

    private static final long serialVersionUID = -1847557437429753540L;
    public static final String FIELD_ERRORS_KEY = "RedirectMessageInterceptor_FieldErrors";
    public static final String ACTION_ERRORS_KEY = "RedirectMessageInterceptor_ActionErrors";
    public static final String ACTION_MESSAGES_KEY = "RedirectMessageInterceptor_ActionMessages";

    /**
     * Empty constructor for class initialization. No additional actions performed.
     */
    public RedirectMessageInterceptor() {
    }

    /**
     * Retrieve the errors and messages from the session and add them to the action.
     * If the invocation result is a redirect then store error and messages in the session.
     * @see
     * com.opensymphony.xwork2.interceptor.MethodFilterInterceptor#doIntercept(com.opensymphony.xwork2.ActionInvocation)
     * @param invocation AtionInvocation to invoke
     * @return invocation invocation result
     * @throws Exception invocation can throw
     */
    public String doIntercept(ActionInvocation invocation) throws Exception {
        Object action = invocation.getAction();
        if (action instanceof ValidationAware) {
            before(invocation, (ValidationAware) action);
        }

        String result = invocation.invoke();

        if (action instanceof ValidationAware) {
            after(invocation, (ValidationAware) action);
        }
        return result;
    }

    /**
     * Retrieve the errors and messages from the session and add them to the action.
     */
    protected void before(ActionInvocation invocation, ValidationAware validationAware) throws Exception {
        Map<String, ?> session = invocation.getInvocationContext().getSession();
        @SuppressWarnings("unchecked")
        Collection<String> actionErrors = (Collection<String>) session.remove(ACTION_ERRORS_KEY);
        if (actionErrors != null && actionErrors.size() > 0) {
            for (String error : actionErrors) {
                validationAware.addActionError(error);
            }
        }
        @SuppressWarnings("unchecked")
        Collection<String> actionMessages = (Collection<String>) session.remove(ACTION_MESSAGES_KEY);
        if (actionMessages != null && actionMessages.size() > 0) {
            for (String message : actionMessages) {
                validationAware.addActionMessage(message);
            }
        }
        @SuppressWarnings("unchecked")
        Map<String, List<String>> fieldErrors = (Map<String, List<String>>) session.remove(FIELD_ERRORS_KEY);
        if (fieldErrors != null && fieldErrors.size() > 0) {
            for (Map.Entry<String, List<String>> fieldError : fieldErrors.entrySet()) {
                for (String message : fieldError.getValue()) {
                    validationAware.addFieldError(fieldError.getKey(), message);
                }
            }
        }
    }

    /**
     * If the result is a redirect then store error and messages in the session.
     */
    protected void after(ActionInvocation invocation, ValidationAware validationAware) throws Exception {
        Result result = invocation.getResult();

        if (result != null
                && (result instanceof ServletRedirectResult || result instanceof ServletActionRedirectResult)) {
            Map<String, Object> session = invocation.getInvocationContext().getSession();

            Collection<String> actionErrors = validationAware.getActionErrors();
            if (actionErrors != null && actionErrors.size() > 0) {
                session.put(ACTION_ERRORS_KEY, actionErrors);
            }

            Collection<String> actionMessages = validationAware.getActionMessages();
            if (actionMessages != null && actionMessages.size() > 0) {
                session.put(ACTION_MESSAGES_KEY, actionMessages);
            }

            Map<String, List<String>> fieldErrors = validationAware.getFieldErrors();
            if (fieldErrors != null && fieldErrors.size() > 0) {
                session.put(FIELD_ERRORS_KEY, fieldErrors);
            }
        }
    }

}
