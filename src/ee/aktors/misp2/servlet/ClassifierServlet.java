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

import org.apache.logging.log4j.LogManager;
import org.springframework.context.ApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import ee.aktors.misp2.model.Classifier;
import ee.aktors.misp2.service.ClassifierService;
import ee.aktors.misp2.util.Const;

/**
 * Classifier servlet
 */
public class ClassifierServlet extends HttpServlet {

    private static final int PORT_80 = 80;
    private static final int PORT_443 = 443;
    private static final long serialVersionUID = 1L;
    private ClassifierService classifierService;

    /**
     * Super() call, no additional actions
     */
    public ClassifierServlet() {
        super();
    }

    /** (non-Javadoc)
     * @see javax.servlet.http.HttpServlet#doGet(javax.servlet.http.HttpServletRequest,
     * javax.servlet.http.HttpServletResponse)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String uri = request.getScheme() + "://" + request.getServerName()
                + ("http".equals(request.getScheme()) && request.getServerPort() == PORT_80
                    || "https".equals(request.getScheme()) && request.getServerPort() == PORT_443 ? "" : ":"
                + request.getServerPort()) + request.getRequestURI()
                + (request.getQueryString() != null ? "?" + request.getQueryString() : "");

        if (request.getSession() != null && request.getSession().getAttribute(Const.SESSION_PORTAL) != null) {
            ApplicationContext context = WebApplicationContextUtils.getWebApplicationContext(getServletContext());
            classifierService = (ClassifierService) context.getBean("classifierService");
            String clName = request.getParameter("name");
            if (clName != null) {
                Classifier classifier = classifierService.findAnyClassifierByName(clName);
                LogManager.getLogger(this.getClass()).debug(clName);
                if (classifier != null) {
                    response.setContentType("text/xml; charset=UTF-8");
                    // response.getOutputStream().print(classifier.getContent());
                    response.getWriter().write(classifier.getContent());
                }
            }
        } else {
            StringBuffer errorMessage = new StringBuffer("Access to classifier " + uri + " denied, ");
            if (request.getSession() == null)
                errorMessage.append("session was not found");
            else
                errorMessage.append("Session " + request.getSession().getId()
                        + " was found, but not initialized: SESSION_PORTAL: "
                        + request.getSession().getAttribute(Const.SESSION_PORTAL));
            LogManager.getLogger(this.getClass()).info(errorMessage.toString());
            response.sendRedirect(request.getContextPath() + "/error403.action");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException,
            IOException {
        // TODO Auto-generated method stub
    }

}
