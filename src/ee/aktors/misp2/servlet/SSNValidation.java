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

package ee.aktors.misp2.servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.transaction.NotSupportedException;

import ee.aktors.misp2.util.SSNValidator;

/**
 * Servlet that validates Estonian SSN and sends response as XML; Useful with Orbeon server validation;
 * @parameters: ssn, countryCode
 */
public class SSNValidation extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * super() call, no additional actions
     */
    public SSNValidation() {
        super();
    }

    /** (non-Javadoc)
     * @see javax.servlet.http.HttpServlet#doGet(javax.servlet.http.HttpServletRequest,
     *  javax.servlet.http.HttpServletResponse)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String ssn = request.getParameter("ssn");
            String countryCode = request.getParameter("countryCode");
            if (!SSNValidator.validateSSN(ssn, countryCode)) {
                response.setContentType("text/xml; charset=UTF-8");
                response.getWriter().write("<validation-result><error>true</error></validation-result>");
            } else {
                response.setContentType("text/xml; charset=UTF-8");
                response.getWriter().write("<validation-result/>");
            }
        } catch (NotSupportedException e) {
            response.setContentType("text/xml; charset=UTF-8");
            response.getWriter().write("<validation-result/>");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        // not implemented
    }
}
