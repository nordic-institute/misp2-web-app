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

package ee.aktors.misp2.filters;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Filter removes unsafe HTTP request header parameters from request and then continues filter chain
 * 
 * @author sander.kallo
 *
 */
public class SafeOrbeonRequestFilter implements Filter {

    private static final Logger LOGGER = LogManager.getLogger(SafeOrbeonRequestFilter.class.getName());

    /**
     */
    public SafeOrbeonRequestFilter() {
    }

    @Override
    public void destroy() {
    }

    /**
     * @see Filter#doFilter(ServletRequest, ServletResponse, FilterChain)
     */
    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain filterChain) throws IOException,
            ServletException {
        LOGGER.trace("Running safe-orbeon-request-filter");
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) resp;

        // Remove certain headers so that Orbeon would not return empty answer
        // At the time of writing 10.04.2014,
        // Orbeon seems to return empty text in PDFFilter whenever it gets If-Modified-Since header with value
        // 1397152261000, for instance
        // -1 value never results in such error so set If-Modified-Since to -1
        SafeOrbeonRequest orbeonRequest = new SafeOrbeonRequest(request);
        orbeonRequest.logIllegal();
        LOGGER.trace("Done. Sending request back to filter chain.");
        filterChain.doFilter(orbeonRequest, response);

    }

    @Override
    public void init(FilterConfig arg0) throws ServletException {
    }

    /**
     * Removes request headers which result in Orbeon returning empty string
     * 
     * @author Sander Källo
     *
     */
    private class SafeOrbeonRequest extends HttpServletRequestWrapper {

        /**
         * Constructor.
         * 
         * @param request
         *            HttpServletRequest.
         */
        public SafeOrbeonRequest(HttpServletRequest request) {
            super(request);
        }

        public String getHeader(String name) {
            HttpServletRequest request = (HttpServletRequest) getRequest();

            String value = isAllowed(name) ? request.getHeader(name) : null;

            return value;
        }

        public long getDateHeader(String name) {
            HttpServletRequest request = (HttpServletRequest) getRequest();
            boolean allowed = isAllowed(name);
            long value = allowed ? request.getDateHeader(name) : -1L;

            return value;
        }

        protected boolean isAllowed(String name) {
            return name != null && !"if-modified-since".equals(name.toLowerCase())
                    && !"if-unmodified-since".equals(name.toLowerCase());
        }

        @SuppressWarnings("rawtypes")
        public Enumeration getHeaderNames() {
            List<String> list = new ArrayList<String>();

            HttpServletRequest request = (HttpServletRequest) getRequest();
            Enumeration e = request.getHeaderNames();
            while (e.hasMoreElements()) {
                String name = (String) e.nextElement();
                if (isAllowed(name)) {
                    list.add(name);
                }
            }

            Enumeration en = Collections.enumeration(list);
            return en;
        }

        @SuppressWarnings("rawtypes")
        public void logIllegal() {

            HttpServletRequest request = (HttpServletRequest) getRequest();
            Enumeration e = request.getHeaderNames();
            while (e.hasMoreElements()) {
                String name = (String) e.nextElement();
                if (!isAllowed(name)) {
                    LOGGER.debug("Header field not '"
                            + name
                            + "' allowed in Orbeon request,"
                            + " since it causes Orbeon to return empty result. Removing header field.");
                }
            }

        }
    }

}
