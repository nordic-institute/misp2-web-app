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

package ee.aktors.misp2.configuration;

import ee.sk.mid.MidClient;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.digidoc4j.Configuration;
import org.digidoc4j.Configuration.Mode;

import ee.aktors.misp2.ExternallyConfigured;

public class DigiDoc4jConfiguration implements ExternallyConfigured {

    private static final Logger LOG = LogManager.getLogger(DigiDoc4jConfiguration.class);

    private Configuration digiDoc4jConfiguration;

    private MidClient midClient;

    private static final String PARAM_TEST_MODE = "digidoc4j.test";
    private static final String PARAM_OCSP_SOURCE = "digidoc4j.ocsp";
    private static final String PARAM_TRUSTED_TERRITORIES = "digidoc4j.trustedTerritories";
    private static final String PARAM_MID_HOST = "mobileID.rest.hostUrl";
    private static final String PARAM_MID_PARTY_UUID = "mobileID.rest.relyingPartyUUID";
    private static final String PARAM_MID_PARTY_NAME = "mobileID.rest.relyingPartyName";
    private static final String PARAM_MID_POLLING_TIMEOUT_SECONDS = "mobileID.rest.pollingTimeoutSeconds";

    private static final boolean DEFAULT_TEST_MODE = false;
    private static final String DEFAULT_OCSP_SOURCE = "http://ocsp.sk.ee/";
    private static final String DEFAULT_TRUSTED_TERRITORIES = "EE";
    private static final String DEFAULT_TEST_TRUSTED_TERRITORIES = "EE_T";

    public DigiDoc4jConfiguration() {
        Mode digiDoc4jMode = usingTestMode() ? Configuration.Mode.TEST : Configuration.Mode.PROD;
        digiDoc4jConfiguration = new Configuration(digiDoc4jMode);
        digiDoc4jConfiguration.setOcspSource(getOcspSource());
        digiDoc4jConfiguration.setTrustedTerritories(getTrustedTerritories());
        LOG.debug("Launched DigiDoc4j in {} mode", digiDoc4jMode);

        midClient = MidClient.newBuilder()
            .withHostUrl(getMidHost())
            .withRelyingPartyUUID(getMidPartyUuid())
            .withRelyingPartyName(getMidPartyName())
            .withLongPollingTimeoutSeconds(getMidPollingTimeoutSeconds())
            .build();
        LOG.debug("Launched MidClient with params host:{}, name: {}", getMidHost(), getMidPartyName());
    }

    /**
     * @return True when using test mode, false when using production mode. If parameter {@value #PARAM_TEST_MODE} is
     *         not found, then it is set to {@value #DEFAULT_TEST_MODE}.
     */
    private boolean usingTestMode() {
        return CONFIG.getBoolean(PARAM_TEST_MODE, DEFAULT_TEST_MODE);
    }

    /**
     * @return OCSP source. If parameter {@value #PARAM_OCSP_SOURCE} is not found, then it is set to
     *         {@value #DEFAULT_OCSP_SOURCE}.
     */
    private String getOcspSource() {
        return CONFIG.getString(PARAM_OCSP_SOURCE, DEFAULT_OCSP_SOURCE);
    }

    /**
     * @return String which contains comma-seperated values of trusted territories. If parameter
     *         {@value #PARAM_TRUSTED_TERRITORIES} is not found, then return {@value #DEFAULT_TEST_TRUSTED_TERRITORIES}
     *         when using test mode, {@value #DEFAULT_TRUSTED_TERRITORIES} when using production mode.
     */
    private String getTrustedTerritories() {
        String[] trustedTerritories = CONFIG.getStringArray(PARAM_TRUSTED_TERRITORIES);
        if (trustedTerritories.length < 1) {
            trustedTerritories = new String[1];
            trustedTerritories[0] = usingTestMode() ? DEFAULT_TEST_TRUSTED_TERRITORIES : DEFAULT_TRUSTED_TERRITORIES;
        }
        return StringUtils.join(trustedTerritories, ",");
    }

    /**
     * @return Mobile id host url
     */
    private String getMidHost() {
        return CONFIG.getString(PARAM_MID_HOST);
    }

    /**
     * @return Mobile id relying party UUID
     */
    private String getMidPartyUuid() {
        return CONFIG.getString(PARAM_MID_PARTY_UUID);
    }

    /**
     * @return Mobile id relying party name
     */
    private String getMidPartyName() {
        return CONFIG.getString(PARAM_MID_PARTY_NAME);
    }

    /**
     * @return How long will user be polled to check if they have entered the
     * verification code. In seconds
     */
    private Integer getMidPollingTimeoutSeconds() {
        return CONFIG.getInteger(PARAM_MID_POLLING_TIMEOUT_SECONDS, 60);
    }

    /**
     * @return DigiDoc4j configuration instance {@link org.digidoc4j.Configuration}
     */
    public Configuration getConfiguration() {
        return digiDoc4jConfiguration;
    }

    /**
     * @return Configured Mobile-ID client
     */
    public MidClient getMidClient() {return midClient;}

}
