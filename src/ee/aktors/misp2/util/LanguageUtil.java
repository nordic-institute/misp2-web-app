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

package ee.aktors.misp2.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Locale;

import ee.aktors.misp2.provider.ConfigurationProvider;

/**
 * Language util
 */
public final class LanguageUtil {

    private LanguageUtil() {
    }

    public static final String ALL_LANGUAGES = "all";
    private static ArrayList<String> languages = null;

    /**
     * Get languages to which user is allowed to switch and in which can descriptions
     * be set for different elements.<br/>
     * Gets languages from config "languages" property (clears duplicates).<br/>
     * If that property does not contain any suitable languages, then uses system default locale language.
     * @return languages to which user is allowed to switch
     */
    public static synchronized ArrayList<String> getLanguages() {
        if (languages == null) {
            initLanguages();
        }
        return languages;
    }

    /**
     * @return default language from {@link #getLanguages()}
     */
    public static String getDefaultLanguage() {
        return getLanguages().get(0);
    }

    private static void initLanguages() {
        // Use LinkedHashSet to preserve order and clear duplicates
        LinkedHashSet<String> configLanguages = new LinkedHashSet<String>();
        configLanguages.addAll(Arrays.asList(ConfigurationProvider.getConfig().getStringArray("languages")));
        // Remove those which are not defined as languages
        configLanguages.retainAll(Arrays.asList(Locale.getISOLanguages()));

        languages = new ArrayList<String>();
        if (configLanguages.isEmpty() == false) {
            languages.addAll(configLanguages);
        } else {
            languages.add(Locale.getDefault().getLanguage());
        }
    }
}
