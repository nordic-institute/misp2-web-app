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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.net.URLConnection;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.ServletActionContext;

import ee.aktors.misp2.provider.ConfigurationProvider;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 *
 * @author arnis.rips
 */
public final class URLReader {
    
    private static final Logger LOGGER = LogManager.getLogger(URLReader.class.getName());
    
    private URLReader() { }

    /**
     * Reads given url and returns its contents as string. Should be treadsafe but not tested for it.
     * @param url url to be opend and read by this method
     * @param preserveCookies keep cookies or not
     * @return url contents as string object
     * @throws DataExchangeException throws is url is unreachable or invalid etc
     */
    public static String readUrlStr(URL url, boolean preserveCookies)
            throws DataExchangeException {
        try {
            // 
            if (url.getProtocol() == null
                || ( !url.getProtocol().equals("http")
                     && !url.getProtocol().equals("https"))
            ) {
                throw new DataExchangeException(DataExchangeException.Type.READING_FROM_URL_PROTOCOL_NOT_ALLOWED,
                        "Reading from URL " + url + " failed. Protocol '" + url.getProtocol()
                        + "' not allowed.", null, url.getProtocol(), url.toString());
            }
            
            String privateUrl = url.toString();
            LOGGER.debug("Reading URL " + privateUrl);
                
            URLConnection urlConnection = url.openConnection();
            
            if (preserveCookies) {
                String jsessionId = ServletActionContext.getRequest() != null
                        && ServletActionContext.getRequest().getSession() != null ? ServletActionContext.getRequest()
                        .getSession().getId() : null;
    
                if (jsessionId != null
                        && privateUrl.startsWith(ConfigurationProvider.getConfig().getString("misp2.internal.url"))) {
                    urlConnection.addRequestProperty("Cookie", "JSESSIONID=" + jsessionId);
                    LOGGER.debug("Adding session cookie to " + privateUrl + " connection " + jsessionId);
                }
            }
            BufferedReader in = new BufferedReader(new InputStreamReader(urlConnection.getInputStream(), "UTF-8"));
            StringBuilder sb = new StringBuilder();
            String inputLine;
    
            while ((inputLine = in.readLine()) != null) {
                sb.append(inputLine);
                sb.append(System.getProperty("line.separator"));
            }
            if (LOGGER.isTraceEnabled()) {
                LOGGER.trace("URL " + url + " contents: " + sb.toString());
            }
            in.close();
            return sb.toString();
        } catch (SocketTimeoutException e) {
            throw new DataExchangeException(DataExchangeException.Type.TIMEOUT,
                    "Reading from URL " + url + " timed out", e);
        } catch (IOException e) {
            throw new DataExchangeException(DataExchangeException.Type.READING_FROM_URL_FAILED,
                    "Reading from URL " + url + " failed", e, url.toString());
            
        }
    }

    /**
     * @param urlIn url to read
     * @return url contents as string object
     * @throws DataExchangeException throws is url is unreachable or invalid etc
     */
    public static String readUrlStr(String urlIn) throws DataExchangeException {
        return readUrlStr(parseUrl(urlIn), true);
    }

    /**
     * @param urlIn url to read
     * @return url contents as string object
     * @throws DataExchangeException throws is url is unreachable or invalid etc
     */
    public static String readUrlStrWithoutCookies(String urlIn) throws DataExchangeException {
        return readUrlStr(parseUrl(urlIn), false);
    }

    private static URL parseUrl(String urlIn) throws DataExchangeException {
        try {
            return new URL(urlIn);
        } catch (MalformedURLException e) {
            throw new DataExchangeException(DataExchangeException.Type.READING_FROM_URL_FAILED,
                    "Malformed URL '" + urlIn + "'", e, urlIn);
        }
    }
}
