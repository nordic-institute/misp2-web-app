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

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.xml.soap.SOAPException;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;

import org.apache.commons.configuration.Configuration;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgName;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.util.LanguageUtil;
import ee.aktors.misp2.util.MISPUtils;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf.AuthQueryConf;

/**
 * Unit auth query for univ-portal. Query request contains user personal code
 * and response is a list of organizations with code and name.
 * 
 * @author sander.kallo
 *
 */
public class UnitAuthQuery extends CommonUnitQuery {
    private static Logger logger = LogManager.getLogger(UnitAuthQuery.class);

    private AuthQueryConf authQueryConf;
    private int countryCodeLength;

    /**
     * Initialize unit auth query
     * @param authQueryConf configuration parameters of currently selected query
     * @param univConfiguration universal portal configuration for legacy X-Road v5 services support
     * @param defaultCountryCode country code used in X-Road v5 configuration retrieval
     * @param countryCodeLength country code length; used for extracting user SSN from user ID
     * @param user current user auth query is performed for
     * @param org user org entity, used in query request
     * @throws DataExchangeException on initialization error
     */
    public UnitAuthQuery(AuthQueryConf authQueryConf, Configuration univConfiguration, String defaultCountryCode,
            int countryCodeLength, Person user, Org org) throws DataExchangeException {
        super(authQueryConf, org, univConfiguration);
        this.authQueryConf = authQueryConf;
        this.countryCodeLength = countryCodeLength;
        this.user = user;
        if (!portal.isV6()) {
            setXRoadV5Namespace(defaultCountryCode, ".producer.namespace_format");
        } // else in v6 it is already set

    }

    @Override
    protected void initSOAPRequestParameters() throws SOAPException, DataExchangeException {
        String requestPath;
        if (portal.isV6()) {
            requestPath = authQueryConf.getRequestPersonCodeXpath();
        } else {
            requestPath = super.getXRoadV5RequestPath(".auth.xpath.request_id_code");
            logger.debug("Universal portal auth query namespace" + bodyRootElementNamespace.getUri());
        }

        String nodeValue = user.getSsn().substring(countryCodeLength);
        if (requestPath == null || requestPath.isEmpty()) {
            logger.warn("Did not find request path for" + " Universal portal auth query " + portal.getUnivAuthQuery()
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
        return portal.getUnivAuthQuery();
    }
    
    /**
     * 
     * @param allowedOrgList list of allowed organisations filled from query response
     * @throws SOAPException on SOAPMessage access failure
     * @throws IOException on response reading failure
     * @throws XPathExpressionException on XPath access failure
     */
    public void processResponse(List<Org> allowedOrgList) throws SOAPException, IOException, XPathExpressionException {
        if (super.hasResponse()) {
            allowedOrgList.clear();
            final String pathRegistercode;
            final String pathOrgName;
            final String pathMemberClass;
            final NodeList organizationMemberClasses;
            if (isV6()) {
                pathRegistercode = authQueryConf.getResponseUnitCodeXath();
                pathOrgName = authQueryConf.getResponseUnitNameXpath();
                pathMemberClass = authQueryConf.getResponseUnitMemberClassXpath();
                if (pathMemberClass != null) {
                    organizationMemberClasses = (NodeList) evaluateXpath(pathMemberClass, soapResponse.getSOAPBody(),
                            XPathConstants.NODESET);
                } else {
                    organizationMemberClasses = null;
                }
            } else {
                String producerName = MISPUtils.parseQueryString(portal.getUnivAuthQuery()).getProducerName();
                int version = MISPUtils.findUnivPortalXROADVersion(portal, producerName, configuration);
                String versionString = "v" + version;
                pathRegistercode = configuration.getString(versionString + ".auth.xpath.registration_code");
                pathOrgName = configuration.getString(versionString + ".auth.xpath.organization.name");
                pathMemberClass = null;
                organizationMemberClasses = null;
            }
            NodeList organizationCodes = (NodeList) evaluateXpath(pathRegistercode, soapResponse.getSOAPBody(),
                    XPathConstants.NODESET);
            NodeList organizationNames = (NodeList) evaluateXpath(pathOrgName, soapResponse.getSOAPBody(),
                    XPathConstants.NODESET);

            logger.debug("Found " + organizationCodes.getLength() + " organizations");

            for (int i = 0; i < organizationCodes.getLength(); i++) { // iterate
                                                                        // through
                                                                        // enterprises
                Node orgCodeItem = organizationCodes.item(i);
                Org o = new Org();
                String oCode = orgCodeItem.getTextContent();
                if (!oCode.equals(portal.getOrgId().getCode())) {
                    o.setCode(oCode);

                    if (isV6()) {
                        String memberClass = authQueryConf.getDefaultResponseOrganizationMemberClass(); // default
                                                                                                        // if
                                                                                                        // nothing
                                                                                                        // is
                                                                                                        // found
                        if (organizationMemberClasses != null) {
                            String memberClassFromResponse = organizationMemberClasses.item(i).getTextContent();
                            if (memberClassFromResponse != null) {
                                memberClass = authQueryConf.translateMemberClass(memberClassFromResponse);
                            } else {
                                logger.debug("Organization member class is missing from X-Road v6 service '"
                                        + authQueryConf.getName() + "' response. Using default '" + memberClass + "'.");
                            }
                        }
                        o.setMemberClass(memberClass);
                    }
                } else {
                    logger.warn("Found super org from the result query, no adding this.");
                    continue;
                }
                String orgName = "unknown";
                if (organizationCodes.getLength() == organizationNames.getLength())
                    orgName = organizationNames.item(i).getTextContent();
                o.setOrgNameList(new ArrayList<OrgName>());
                for (String language : LanguageUtil.getLanguages()) {
                    o.getOrgNameList().add(new OrgName(orgName, o, language));
                }
                allowedOrgList.add(o);
            }
        } else {
            throw new RuntimeException("No query response received, cannot process response");
        }
    }
}
