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
import java.net.URLDecoder;
import java.util.HashMap;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.configuration.Configuration;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.beans.QueryBean;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.util.Const.XROAD_VERSION;

/**
 *
 * @author arnis.rips
 */
public abstract class MISPUtils {

    private static final int SPLIT_LENGTH = 3;
    private static final Logger LOGGER = LogManager.getLogger(MISPUtils.class);

    /**
     * Format for input string is : {@code producerName.queryName.version}
     * or {@code producerName.queryName} or {@code producerName}
     * @param queryLongName required, used to generate query bean
     * @return query bean generated from given string
     */
    public static QueryBean parseQueryString(String queryLongName) {

        QueryBean qb = new QueryBean();

        if (queryLongName == null || queryLongName.isEmpty()) {
            LOGGER.warn("Query not set, returning null");
        } else {
            // http://www.velocityreviews.com/forums/t135234-string-split-at-a-decimal-point.html
            String[] split = queryLongName.split("\\.");
            LOGGER.debug("Split authquery=" + queryLongName + " into " + split.length + " strings");
            if (split.length >= 1) {
                qb.setProducerName(split[0]);
                if (split.length >= 2) {
                    qb.setQueryName(split[1]);
                    if (split.length == SPLIT_LENGTH) {
                        qb.setVersion(split[2]);

                    }
                }
            }
        }

        return qb;
    }

    /**
     * Turns string into boolean according to comparable string. NULL safe.
     * @author siim.kinks
     * @param value String to turn boolean
     * @param comparable Comparable string to determine the return value
     * @param nullable String that turns input value to NULL
     * @return True if value equals to comparable(ignoring case); false if not. NULL if value is NULL or equals to
     *         nullable(ignoring case).
     */
    public static Boolean stringToBoolean(String value, String comparable, String nullable) {
        if (value != null) {
            if (value.equalsIgnoreCase(nullable)) {
                return null;
            }
            if (value.equalsIgnoreCase(comparable)) {
                return true;
            } else {
                return false;
            }
        }
        return null;
    }

    /**
     * Finds universal portal X-Road version which is specified in univConfiguration.
     * 
     * @param portal - portal
     * @param producerName - name of the producer
     * @param univConfiguration - configuration for universal portals
     * @return - portals X-Road version which is currently specified in univConfiguration.
     */
    public static int findUnivPortalXROADVersion(Portal portal, String producerName, Configuration univConfiguration) {
        String portalName = portal.getShortName();
        int version = XROAD_VERSION.V5.getIndex();
        //check if for this particular portal we should use old or new tags.
        String headerTagsKey = portalName + ".old_header_tags";

        if (univConfiguration.containsKey(headerTagsKey) && univConfiguration.getBoolean(headerTagsKey)) {
            version = XROAD_VERSION.V4.getIndex();
        }
        if (producerName.equals("") == false) {
            headerTagsKey = portalName + "." + producerName + ".old_header_tags";
            if (univConfiguration.containsKey(headerTagsKey)) {
                if (univConfiguration.getBoolean(headerTagsKey)) {
                    version = XROAD_VERSION.V4.getIndex();
                } else {
                    version = XROAD_VERSION.V5.getIndex();
                }
            }
        }
        LOGGER.debug("headerTagsKey: " + headerTagsKey);
        return version;
    }

    /**
     * @param request address which to compare with local address
     * @return true if local and request addresses are the same
     */
    public static boolean isLocalRequest(HttpServletRequest request) {
        return request.getRemoteAddr().equals(request.getLocalAddr());
    }

    /**
     * @param request request wich parameters to get
     * @return parameters request parameters
     * @throws UnsupportedEncodingException if request queryString cant be decoded
     */
    public static HashMap<String, String> getParameterMap(HttpServletRequest request)
            throws UnsupportedEncodingException {
        HashMap<String, String> parameters = new HashMap<String, String>();
        String queryString = URLDecoder.decode(request.getQueryString(), "UTF-8");
        String[] parsedString = queryString.split("&");
        for (String s : parsedString) {
            parameters.put(s.substring(0, s.indexOf("=")), s.substring(s.indexOf("=") + 1));
        }
        return parameters;
    }

    /**
     * Find HTTP request source IP address either from X-Forwarded-For header or
     * in case that does not exist, directly from client connection.
     * @param request HTTP request object
     * @return IP address as string
     */
    public static String getSourceIp(HttpServletRequest request) {
        if (request != null) {
            String ipAddress = request.getHeader("X-Forwarded-For");
            if (ipAddress == null) {
                ipAddress = request.getRemoteAddr();
                if (LOGGER.isTraceEnabled()) {
                    LOGGER.trace("Client IP address directly from TCP connection: " + ipAddress);
                }
            } else {
                if (LOGGER.isTraceEnabled()) {
                    LOGGER.trace("Client IP address from X-Forwarded-For: " + ipAddress);
                }
            }
            return ipAddress;
        } else {
            if (LOGGER.isTraceEnabled()) {
                LOGGER.trace("Client IP address cannot be obtained. Request is null.");
            }
            return null;
        }
    }
}
