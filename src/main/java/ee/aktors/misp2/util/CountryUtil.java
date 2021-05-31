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
import java.util.LinkedHashSet;
import java.util.Locale;

import ee.aktors.misp2.provider.ConfigurationProvider;

/**
 *
 */
public final class CountryUtil {

   private CountryUtil() {
    }
    
    private static ArrayList<Locale> countries = null;

    /**
     * Get countries which can be set for user's country.
     * They are represented as locales which have no language set.<br/>
     * Gets countries from config "countries" property (clears duplicates).<br/>
     * If that property does not contain any suitable countries, then uses system default locale country.
     * @return results
     */
    public static synchronized ArrayList<Locale> getCountries() {
        if (countries == null) {
            initCountries();
        }
        return countries;
    }

    /**
     * Returns default country from {@link #getCountries()}
     * @return result
     */
    public static Locale getDefaultCountry() {
        return getCountries().get(0);
    }

    private static void initCountries() {
        // Use LinkedHashSet to preserve order and clear duplicates
        LinkedHashSet<String> configCountries = new LinkedHashSet<String>();
        configCountries.addAll(Arrays.asList(ConfigurationProvider.getConfig().getStringArray("countries")));
        // Remove those which are not defined as ISO
        configCountries.retainAll(Arrays.asList(Locale.getISOCountries()));

        countries = new ArrayList<Locale>();
        if (configCountries.isEmpty() == false) {
            for (String configCountry : configCountries) {
                countries.add(new Locale("", configCountry));
            }
        } else {
            countries.add(new Locale("", Locale.getDefault().getCountry()));
        }
    }
}
