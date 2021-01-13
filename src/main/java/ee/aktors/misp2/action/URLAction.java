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

package ee.aktors.misp2.action;

import java.io.FileNotFoundException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.util.URLReader;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 *
 * @author arnis.rips
 */
public class URLAction extends ActionSupport {

    private static final long serialVersionUID = 1L;
    private String lines;
    private String url;
    private static final Logger LOG = LogManager.getLogger(URLAction.class);

    /**
     * @return ERROR if url not found or reading fails, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String readUrl() {
        LogManager.getLogger(getClass()).debug("Reading from url: " + url);
        if (url != null) {
            try {
                lines = URLReader.readUrlStr(url);
            } catch (DataExchangeException e) {
                Throwable cause = e.getCause();
                if (cause instanceof FileNotFoundException) {
                    lines = getText("xslt_styles.error.invalid_url");
                    LOG.warn("XSLT URL is invalid", e);
                    return Action.ERROR;
                } else {
                    lines = getText(e.getTranslationCode(), e.getParameters());
                    LOG.warn("Reading XSLT from URL failed", e);
                    return Action.ERROR;
                }
            }
        }
        LOG.debug("Done reading url. Returning success");
        return Action.SUCCESS;
    }

    /**
     * @return the lines
     */
    public String getLines() {
        return lines;
    }

    /**
     * @param linesNew the lines to set
     */
    public void setLines(String linesNew) {
        this.lines = linesNew;
    }

    /**
     * @return the url
     */
    public String getUrl() {
        return url;
    }

    /**
     * @param urlNew the url to set
     */
    public void setUrl(String urlNew) {
        this.url = urlNew;
    }

}
