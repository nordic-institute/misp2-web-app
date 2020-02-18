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

package ee.aktors.misp2.util.xroad.soap.query.unit;

import java.util.Locale;

import org.apache.commons.configuration.Configuration;

import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf.OrgPortalAuthQueryConf;

/**
 * Current object instance serves as a parameter container for
 * {@link OrgPortalAuthQuery} constructor. It is created to work around RIA
 * chesckstyle limitations where 8 constructor input parameters are not allowed
 * (7 is maximum).
 * 
 * All setter arguments preceed with 'input' wich is also a workaround to avoid
 * checkstyle alerts (input argument cannot be the same as a field name).
 * 
 * @author sander.kallo
 *
 */
public class OrgPortalAuthQueryBuilder {
    private OrgPortalAuthQueryConf orgPortalAuthQueryConf;
    private Configuration orgPortalConfiguration;
    private Configuration config;
    private String defaultCountryCode;
    private int countryCodeLength;
    private Person user;
    private Org org;
    private Locale locale;
    
    /**
     * @return X-Road v6 query conf
     */
    public OrgPortalAuthQueryConf getOrgPortalAuthQueryConf() {
        return orgPortalAuthQueryConf;
    }

    /**
     * Set X-Road v6 query conf
     * @param inputOrgPortalAuthQueryConf X-Road v6 query conf
     * @return this instance (itself)
     */
    public OrgPortalAuthQueryBuilder setOrgPortalAuthQueryConf(OrgPortalAuthQueryConf inputOrgPortalAuthQueryConf) {
        this.orgPortalAuthQueryConf = inputOrgPortalAuthQueryConf;
        return this;
    }

    /**
     * @return X-Road v5 query conf
     */
    public Configuration getOrgPortalConfiguration() {
        return orgPortalConfiguration;
    }

    /**
     * Set X-Road v5 query conf
     * @param inputOrgPortalConfiguration X-Road v5 query conf
     * @return this instance (itself)
     */
    public OrgPortalAuthQueryBuilder setOrgPortalConfiguration(Configuration inputOrgPortalConfiguration) {
        this.orgPortalConfiguration = inputOrgPortalConfiguration;
        return this;
    }

    /**
     * @return global application conf
     */
    public Configuration getConfig() {
        return config;
    }

    /**
     * Set global application conf to current container
     * @param inputConfig global application conf
     * @return this instance (itself)
     */
    public OrgPortalAuthQueryBuilder setConfig(Configuration inputConfig) {
        this.config = inputConfig;
        return this;
    }

    /**
     * @return default country code
     */
    public String getDefaultCountryCode() {
        return defaultCountryCode;
    }

    /**
     * Set default country code
     * @param inputDefaultCountryCode default country code to select data from configuration
     * @return this instance (itself)
     */
    public OrgPortalAuthQueryBuilder setDefaultCountryCode(String inputDefaultCountryCode) {
        this.defaultCountryCode = inputDefaultCountryCode;
        return this;
    }

    /**
     * @return default country code length
     */
    public int getCountryCodeLength() {
        return countryCodeLength;
    }

    /**
     * @param inputCountryCodeLength user ID country code prefix length
     * @return this instance (itself)
     */
    public OrgPortalAuthQueryBuilder setCountryCodeLength(int inputCountryCodeLength) {
        this.countryCodeLength = inputCountryCodeLength;
        return this;
    }

    /**
     * @return query user
     */
    public Person getUser() {
        return user;
    }

    /**
     * Set query user
     * @param inputUser user configuration for query input
     * @return this instance (itself)
     */
    public OrgPortalAuthQueryBuilder setUser(Person inputUser) {
        this.user = inputUser;
        return this;
    }

    /**
     * @return query org
     */
    public Org getOrg() {
        return org;
    }

    /**
     * Set query org
     * @param inputOrg org configuration for query input
     * @return this instance (itself)
     */
    public OrgPortalAuthQueryBuilder setOrg(Org inputOrg) {
        this.org = inputOrg;
        return this;
    }

    /**
     * @return current locale
     */
    public Locale getLocale() {
        return locale;
    }

    /**
     * Set current locale
     * @param inputLocale locale to select configuration parameters
     * @return this instance (itself)
     */
    public OrgPortalAuthQueryBuilder setLocale(Locale inputLocale) {
        this.locale = inputLocale;
        return this;
    }
}
