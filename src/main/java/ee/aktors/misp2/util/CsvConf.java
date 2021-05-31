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

import java.nio.charset.Charset;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Locale;

import org.apache.commons.configuration.Configuration;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Extract CSV configuration data from webapp config.
 * <p>
 * Parameters are extracted in the constructor. First, webapp looks for
 * 'csv.separator.{locale}' and 'csv.separator.{locale}' properties from configuration,
 * where {locale} is current locale of the webapp (e.g. csv.separator.et = ;).
 * <p>
 * If locale, specific keys are not found, extractor looks for global
 * 'csv.separator' and 'csv.encoding' keys.
 * <p>
 * Date format can also be configured similarly, e.g. csv.dateFormat = UTF-8
 * @author sander
 *
 */
public class CsvConf {
    private String separator;
    private String encoding;
    private String dateFormat;
    private String newline;
    private static final Logger LOGGER = LogManager.getLogger(CsvConf.class);
    
    /**
     * Constructor extracts configuration parameters from webapp conf.
     * @param config webapp config.
     * @param locale user session locale
     */
    public CsvConf(final Configuration config, Locale locale) {
        separator = null;
        encoding = null;
        dateFormat = null;
        
        // Use locale for determining CSV configuration
        String countryCode = locale.getLanguage();
        LOGGER.debug("CSV country code " + countryCode);
        if (countryCode != null && !countryCode.isEmpty()) {
            separator = config.getString("csv.separator." + countryCode.toLowerCase(), null);
            encoding = config.getString("csv.encoding." + countryCode.toLowerCase(), null);
            dateFormat = config.getString("csv.dateFormat." + countryCode.toLowerCase(), null);
            newline = config.getString("csv.newline." + countryCode.toLowerCase(), null);
            if (separator != null) {
                LOGGER.debug("Locale '" + countryCode + "' specific CSV separator '"  + separator    + "'");
            }
            if (encoding != null) {
                LOGGER.debug("Locale '" + countryCode + "' specific CSV encoding '"   + encoding     + "'");
            }
            if (dateFormat != null) {
                LOGGER.debug("Locale '" + countryCode + "' specific CSV dateFormat '" + dateFormat   + "'");
            }
            if (newline != null) {
                LOGGER.trace("Locale '" + countryCode + "' specific CSV newline '"    + newline      + "'");
            }
        }
        
        if (separator == null) {
            separator  = config.getString("csv.separator", ",");
            LOGGER.debug("CSV conf: Using global separator '" + separator + "'.");
        }
        if (encoding == null) {
            encoding  = config.getString("csv.encoding", "ISO-8859-4");
            LOGGER.debug("CSV conf: Using global encoding '" + encoding + "'.");
        }
        if (dateFormat == null) {
            dateFormat  = config.getString("csv.dateFormat", "yyyy-MM-dd HH:mm:ss.SSS");
            LOGGER.debug("CSV conf: Using global dateFormat '" + dateFormat + "'.");
        }
        if (newline == null) {
            newline  = config.getString("csv.newline", "\r\n");
            LOGGER.trace("CSV conf: Using global newline '" + newline + "'.");
        }
    }
    
    /**
     * @return CSV separator
     */
    public String getSeparator() {
        return separator;
    }
    /**
     * @return CSV encoding character set
     */
    public Charset getEncoding() {
        return Charset.forName(encoding);
    }
    /**
     * @return CSV date format
     */
    public DateFormat getDateFormat() {
        return new SimpleDateFormat(dateFormat);
    }
    /**
     * @return CSV newline
     */
    public String getNewline() {
        return newline;
    }
}
