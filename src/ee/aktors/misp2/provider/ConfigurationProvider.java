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

package ee.aktors.misp2.provider;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.configuration.PropertiesConfiguration;

/**
 *
 * @author arnis.rips
 */
public final class ConfigurationProvider {

    private static Configuration config;
    private static PropertiesConfiguration version;

    private ConfigurationProvider() {
    }
    
    /**
     * @return the config
     */
    public static Configuration getConfig() {
        return config;
    }

    /**
     * @param cfg the config to set
     */
    public static void setConfig(Configuration cfg) {
        ConfigurationProvider.config = cfg;
    }

    /**
     * @return the version
     */
    public static PropertiesConfiguration getVersion() {
        return version;
    }

    /**
     * @param versionCfg  the version to set
     */
    public static void setVersion(PropertiesConfiguration versionCfg) {
        ConfigurationProvider.version = versionCfg;
    }
}
