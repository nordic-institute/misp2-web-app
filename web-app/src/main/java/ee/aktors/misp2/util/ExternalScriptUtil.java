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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.provider.ConfigurationProvider;

/**
 * Read list of external JavaScript URLs to be used in main layout so each page has them.
 * @author sander.kallo
 *
 */
public final class ExternalScriptUtil {
    private static final Logger LOGGER = LogManager.getLogger(ExternalScriptUtil.class);

    private static List<String> externalScriptUrls = null;
    
    /**
     * Hide constructor to work around RIA checkstyle limitations
     */
    private ExternalScriptUtil() {
        //not called
    }
    /**
     * @return external script URL list from conf
     */
    public static synchronized List<String> getExternalScriptUrls() {
        if (externalScriptUrls == null) {
            initExternalScriptUrls();
        }
        ConfigurationProvider.getConfig();
        LOGGER.trace("Getting external scripts. Found " + externalScriptUrls.size() + " scripts");
        return externalScriptUrls;
    }

    private static void initExternalScriptUrls() {
        // Use LinkedHashSet to preserve order and clear duplicates
        LinkedHashSet<String> configExternalScriptUrls = new LinkedHashSet<String>();
        configExternalScriptUrls
                .addAll(Arrays.asList(ConfigurationProvider.getConfig().getStringArray("external.script.urls")));

        LOGGER.trace("Initing external scripts. Found " + configExternalScriptUrls.size() + " scripts");

        externalScriptUrls = new ArrayList<String>();
        externalScriptUrls.addAll(configExternalScriptUrls);
        // externalScriptUrls.add("https://xp.ria.ee/frontend/js/embed.js?#bannergroup=195");
        externalScriptUrls = Collections.unmodifiableList(externalScriptUrls);
    }
}
