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

package ee.aktors.misp2.action;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.struts2.StrutsStatics;

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ActionSupport;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.SessionCounter;

/**
 */
public class LogoutAction extends ActionSupport implements StrutsStatics {

    private static final long serialVersionUID = 1L;

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String execute() throws Exception {
        ActionContext ac = ActionContext.getContext();
        Map<String, Object> session = ac.getSession();
        Person user = (Person) session.get(Const.SESSION_USER_HANDLE);
        session.clear();
        HttpServletRequest request = ((HttpServletRequest) ac.get(HTTP_REQUEST));
        if (request.isRequestedSessionIdValid() && user != null) {
            SessionCounter.getInstance().decreaseCounter(user.getSsn());
        }
        request.getSession().invalidate();
        return SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String logoutAdmin() {
        ActionContext ac = ActionContext.getContext();
        Map<String, Object> session = ac.getSession();
        session.clear();
        return SUCCESS;
    }
}
