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

package ee.aktors.misp2.util.xroad.soap.query.unit;

import javax.xml.soap.SOAPException;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;

import org.apache.commons.configuration.Configuration;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.util.MISPUtils;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf.CheckQueryConf;

/**
 * Unit check query for univ-portal. Query request contains organization code
 * and response tells if the organization is valid or not.
 * 
 * @author sander.kallo
 *
 */
public class UnitCheckQuery extends CommonUnitQuery {

    private static Logger logger = LogManager.getLogger(UnitCheckQuery.class);
    private CheckQueryConf checkQueryConf;
    private Org unit;
    /**
     * 
     * @param checkQueryConf universal portal check query conf ('check unit' service details) for X-Road v6 service
     * @param univConfiguration universal portal configuration for legacy services support for X-Road v5
     * @param defaultCountryCode country code (for reading from conf)
     * @param unit organizational unit to be checked
     * @throws DataExchangeException on initialization error
     */
    public UnitCheckQuery(CheckQueryConf checkQueryConf, Configuration univConfiguration, String defaultCountryCode,
            Org unit) throws DataExchangeException {
        super(checkQueryConf, null, univConfiguration);
        if (portal.getUnitIsConsumer() != null && portal.getUnitIsConsumer().booleanValue()) {
            this.org = unit;
        } else {
            this.org = portal.getOrgId();
        }
        this.checkQueryConf = checkQueryConf; // for X-Road v6
        this.unit = unit;
        if (!portal.isV6()) {
            setXRoadV5Namespace(defaultCountryCode, ".producer.namespace_format");
        } // else in v6 it is already set
    }

    @Override
    protected void initSOAPRequestParameters() throws SOAPException, DataExchangeException {
        if (portal.isV6()) {
            String memberClassPath = checkQueryConf.getRequestUnitMemberClassXpath();
            if (memberClassPath != null && !memberClassPath.trim().isEmpty()) {
                String memberClassValue = checkQueryConf.translateMemberClass(unit.getMemberClass());
                addRequestElement(memberClassPath, memberClassValue);
                logger.debug("Adding member class element to '" + checkQueryConf.getName() + "' query"
                        + " memberClassPath: " + memberClassPath + " memberClassValue: " + memberClassValue);
            }
        }
        String requestPath;
        if (portal.isV6()) {
            requestPath = checkQueryConf.getRequestUnitCodeXpath();
        } else {
            requestPath = super.getXRoadV5RequestPath(".check.xpath.request_code");
            logger.debug("Unit check query namespace" + bodyRootElementNamespace.getUri());
        }

        String nodeValue = unit.getCode();
        if (requestPath == null || requestPath.isEmpty()) {
            logger.warn("Did not find request path for" + " universal portal check query " + portal.getUnivCheckQuery()
                    + " X-Road builder class: " + getSOAPRequestBuilder().getClass());
        }
        logger.debug("Adding request element to '" + soapRequestBuilder.getServiceSummary() + "' query"
                + " requestPath: " + requestPath + " nodeValue: " + nodeValue);
        addRequestElement(requestPath, nodeValue);
    }

    @Override
    protected int getXRoadVersion() {
        return MISPUtils.findUnivPortalXROADVersion(portal, queryBean.getProducerName(), configuration);
    }

    @Override
    protected String getXRoadV4Or5QueryName() {
        return portal.getUnivCheckQuery();
    }

    /**
     * @return true if unit is valid according to the received SOAP response, false if not
     * @throws DataExchangeException on response parsing error
     */
    public boolean isResponseValid() throws DataExchangeException {
        if (super.hasResponse()) {
            final String pathValid;
            final String validResponseValue;
            if (isV6()) {
                pathValid = checkQueryConf.getResponseValidXath();
                validResponseValue = checkQueryConf.getResponseValidValue();
            } else {
                // for X-Road v5 and v6 support legacy conf; the code was
                // located formerly
                // RoleChangeInterceptor#parseResultCheckQuery() method
                String producerName = MISPUtils.parseQueryString(portal.getUnivCheckQuery()).getProducerName();
                int version = MISPUtils.findUnivPortalXROADVersion(portal, producerName, configuration);
                pathValid = configuration.getString("v" + version + ".check.xpath.valid");
                validResponseValue = "true";
            }
            try {
                String valid = (String) evaluateXpath(pathValid, soapResponse.getSOAPBody(), XPathConstants.STRING);
                return valid.equals(validResponseValue);
            } catch (XPathExpressionException | SOAPException e) {
                throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_RESPONSE_PROCESSING_FAILED,
                        "Response xpath access failed", e);
            }
        } else {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_RESPONSE_PROCESSING_FAILED,
                    "No query response received, cannot process response", null);
        }
    }
}
