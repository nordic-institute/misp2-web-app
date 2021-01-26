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

package ee.aktors.misp2.action;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.ActionSupport;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;

/**
 *
 * @author arnis.rips
 */
public class PageFaultsAction extends ActionSupport {
    private static final long serialVersionUID = 1L;
    private static final Logger LOG = LogManager.getLogger(PageFaultsAction.class);

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String execute() throws Exception {
        return SUCCESS;
    }

    /**
     * @return "unauthorized"
     * @throws Exception can throw
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String unauthorized() throws Exception {
        addActionError(getText("message.restricted_area"));
        LOG.debug("User not authorized because of a page fault");
        return "unauthorized";
    }

    /**
     * Redirect user to a generic error page for unexpected errors.
     * @return "runtimeException"
     * @throws Exception on failure
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String runtimeException() throws Exception {
        LOG.debug("Redirecting user to generic error page for unexpected errors.");
        return "runtimeException";
    }
}
