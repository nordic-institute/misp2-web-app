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

package ee.aktors.misp2.util;

import java.io.UnsupportedEncodingException;
import java.util.Enumeration;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.xml.soap.MimeHeaders;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.ExternallyConfigured;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.servlet.mediator.MediatorServlet;

/**
 *  Download and upload utils
 */
public final class DownloadUploadUtils implements ExternallyConfigured {
    
    private DownloadUploadUtils() {
    }
    
    private static final Logger LOGGER = LogManager.getLogger(DownloadUploadUtils.class);

    /**
     * @param req request which headers to get
     * @return request headers
     */
    public static MimeHeaders getHeaders(HttpServletRequest req) {
        Enumeration<?> headerNames = req.getHeaderNames();
        MimeHeaders headers = new MimeHeaders();
        while (headerNames.hasMoreElements()) {
            String headerName = (String) headerNames.nextElement();
            String headerValue = req.getHeader(headerName);
            StringTokenizer values = new StringTokenizer(headerValue, ",");
            while (values.hasMoreTokens()) {
                headers.addHeader(headerName, values.nextToken().trim());
            }
        }
        return headers;
    }

    /**
     * Get mediator address; currently not used
     * 
     * @param req for context path
     * @param portal unused
     * @return meditator address
     * @throws UnsupportedEncodingException can throw
     */
    public static String getMediatorAddress(HttpServletRequest req, Portal portal) throws UnsupportedEncodingException {
        // send attachment through mediator servlet
        String mediatorAddress = CONFIG.getString("misp2.internal.url") + req.getContextPath()
                + MediatorServlet.SERVLET_PATH + "?attachment=true";
        LOGGER.debug("Mediator address " + mediatorAddress);
        return mediatorAddress;
    }

}
