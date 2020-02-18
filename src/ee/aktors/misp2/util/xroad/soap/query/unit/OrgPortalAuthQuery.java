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

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.xml.soap.SOAPException;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgName;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.util.Const.XROAD_VERSION;
import ee.aktors.misp2.util.LanguageUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf.OrgPortalAuthQueryConf;
import ee.aktors.misp2.util.xroad.soap.XMLNamespaceContainer;

/**
 * Perform user data query for registering user in org-portal (Juriidilise isiku
 * portaal). Query is normally directed business register, but the query and its
 * format is configurable in orgportal-conf.cfg file. Query takes in user
 * personal code and returns user details and organization details for
 * organizations that are represented by current user. If user does not
 * represent any units, then empty response is returned.
 * 
 * @author sander.kallo
 *
 */
public class OrgPortalAuthQuery extends CommonUnitQuery {
    private static Logger logger = LogManager.getLogger(OrgPortalAuthQuery.class);

    private int countryCodeLength;
    private Map<Org, List<Person>> boardOfDirectors;
    private String defaultCountryCode;
    private Locale locale;
    /**
     * Initialize OrgPortalAuthQuery
     * @param queryBuilder various query configuration parameters
     * @throws DataExchangeException on initialization failure
     */
    public OrgPortalAuthQuery(OrgPortalAuthQueryBuilder queryBuilder) throws DataExchangeException {
        
        super(queryBuilder.getOrgPortalAuthQueryConf(),
              queryBuilder.getOrg(),
              queryBuilder.getOrgPortalConfiguration());
        this.countryCodeLength = queryBuilder.getCountryCodeLength();
        this.defaultCountryCode = queryBuilder.getDefaultCountryCode();
        this.locale = queryBuilder.getLocale();
        this.user = queryBuilder.getUser();
        this.boardOfDirectors = null;
        if (!isV6()) { // v6 namespace and request-path
            final String producerNSformat = queryBuilder.getConfig().getString("producer.namespace_format");
            String bodyRootElementNamespaceUri;
            if (isV4()) {
                bodyRootElementNamespaceUri = configuration.getString("producer_namespace");
            } else {
                bodyRootElementNamespaceUri = producerNSformat.replaceAll("#producer", queryBean.getProducerName())
                        .replaceAll("#country", defaultCountryCode.toLowerCase());
            }
            this.bodyRootElementNamespace = new XMLNamespaceContainer(getBodyRootElementNamespacePrefix(),
                    bodyRootElementNamespaceUri);

            if (this.singleQueryConf == null) {
                this.singleQueryConf = new OrgPortalAuthQueryConf(queryBuilder.getOrgPortalConfiguration());
            }
            logger.debug("OrgPortal auth query namespace" + bodyRootElementNamespace.getUri());
        }
    }

    @Override
    protected void initSOAPRequestParameters() throws SOAPException {
        String requestPath = getOrgPortalAuthQueryConf().getRequestPersonCodeXpath();
        String nodeValue = user.getSsn().substring(countryCodeLength);
        if (requestPath == null || requestPath.isEmpty()) {
            logger.warn("Did not find request path for" + " OrgPortal auth query " + portal.getUnivAuthQuery()
                    + " X-Road builder class: " + getSOAPRequestBuilder().getClass());
        }
        logger.debug("Adding request element to '" + getOrgPortalAuthQueryConf().getName() + "' query"
                + " requestPath: " + requestPath + " nodeValue: " + nodeValue);
        addRequestElement(requestPath, nodeValue);
    }

    @Override
    protected int getXRoadVersion() {
        boolean isV4 = configuration.containsKey("old_header_tags") && configuration.getBoolean("old_header_tags");
        return isV4 ? XROAD_VERSION.V4.getIndex() : XROAD_VERSION.V5.getIndex();
    }

    @Override
    protected String getXRoadV4Or5QueryName() {
        return portal.getUnivAuthQuery();
    }

    private OrgPortalAuthQueryConf getOrgPortalAuthQueryConf() {
        return (OrgPortalAuthQueryConf) singleQueryConf;
    }

    /**
     * Fill allowed organizations and unknown organizations along with their details from
     * query response
     * @param allowedOrgList allowed organizations to be filled
     * @param unknownOrgList unknown organizations to be filled
     * @throws SOAPException on XML access failure
     * @throws IOException on IO failure
     * @throws XPathExpressionException on applying XPath failure
     */
    public void processResponse(List<Org> allowedOrgList, List<Org> unknownOrgList)
            throws SOAPException, IOException, XPathExpressionException {
        if (super.hasResponse()) {
            allowedOrgList.clear();
            unknownOrgList.clear();
            OrgPortalAuthQueryConf queryConf = getOrgPortalAuthQueryConf();
            NodeList organizations = (NodeList) evaluateXpath(queryConf.getResponseOrgsXpath(),
                    soapResponse.getSOAPBody(), XPathConstants.NODESET);
            logger.debug("Found " + organizations.getLength() + " organizations");
            boardOfDirectors = new HashMap<Org, List<Person>>();

            for (int i = 0; i < organizations.getLength(); i++) { // iterate
                                                                    // through
                                                                    // enterprises
                Node orgItem = organizations.item(i);

                String status = (String) evaluateXpath(queryConf.getResponseStatusXpath(), orgItem,
                        XPathConstants.STRING);
                boolean isOrgInRegistry = (status != null
                        ? status.equalsIgnoreCase(queryConf.getResponseRegistryStatusOkValue()) : false);

                if (isOrgInRegistry || !configuration.containsKey("registry.status.ok")) {
                    Org o = new Org();
                    String oCode = (String) evaluateXpath(queryConf.getResponseRegisterCodeXpath(), orgItem,
                            XPathConstants.STRING);
                    if (oCode == null) {
                        logger.error("Organization code is missing from response");
                    }

                    if (!oCode.equals(portal.getOrgId().getCode())) {
                        o.setCode(oCode);
                        // set member code from response
                        if (isV6()) {
                            String memberClass = queryConf.getDefaultResponseOrganizationMemberClass(); // default
                                                                                                        // if
                                                                                                        // nothing
                                                                                                        // is
                                                                                                        // found
                            if (queryConf.getResponseOrgMemberClassXpath() != null) {
                                String memberClassFromResponse = (String) evaluateXpath(
                                        queryConf.getResponseOrgMemberClassXpath(), orgItem, XPathConstants.STRING);
                                if (memberClassFromResponse != null && !memberClassFromResponse.trim().isEmpty()) {
                                    memberClass = queryConf.translateMemberClass(memberClassFromResponse);
                                    logger.debug("Setting memberClass to '" + memberClass + "' X-Road v6 service '"
                                            + queryConf.getName() + "' response.");
                                } else {
                                    logger.debug("Organization member class is missing from X-Road v6 service '"
                                            + queryConf.getName() + "' response. Using default '" + memberClass + "'.");
                                }
                            } else {
                                logger.debug("Organization member class is not configured X-Road v6 service '"
                                        + queryConf.getName() + "' response. Using default '" + memberClass + "'.");
                            }
                            o.setMemberClass(memberClass);
                        }
                    } else {
                        logger.warn("Found super org from the result query, no adding this.");
                        break;
                    }

                    String orgName = ((String) evaluateXpath(queryConf.getResponseOrgNameXpath(), orgItem,
                            XPathConstants.STRING));
                    o.setOrgNameList(new ArrayList<OrgName>());
                    for (String language : LanguageUtil.getLanguages()) {
                        o.getOrgNameList().add(new OrgName(orgName, o, language));
                    }

                    String pathOrgReprRights = queryConf.getResponseReprRightsXpath().replaceAll("#org_code", oCode)
                            .replaceAll("#user_id_code", user.getSsn().substring(countryCodeLength));

                    logger.debug("pathOrgReprRights = " + pathOrgReprRights);
                    String reprRightsContent = (String) evaluateXpath(pathOrgReprRights, soapResponse.getSOAPBody(),
                            XPathConstants.STRING);

                    logger.debug("Active user has '" + reprRightsContent + "' right in org="
                            + o.getFullName(locale.getLanguage()));

                    if (reprRightsContent.equalsIgnoreCase(queryConf.getResponseRepresentationRightSingleValue())) {
                        // user has single representation rights in the
                        // organization
                        allowedOrgList.add(o);

                    } else
                        if (reprRightsContent.equalsIgnoreCase(queryConf.getResponseRepresentationRightUnknownValue())
                                || reprRightsContent
                                        .equalsIgnoreCase(queryConf.getResponseRepresentationRightNotSingleValue())) {
                        // user has unknown representation rights or not single
                        // representation rights

                        unknownOrgList.add(o);
                        NodeList representatives = (NodeList) evaluateXpath(queryConf.getResponseReprXpath(), orgItem,
                                XPathConstants.NODESET);
                        List<Person> directors = new ArrayList<Person>();
                        if (representatives != null) {
                            for (int j = 0; j < representatives.getLength(); j++) { // itereate
                                                                                    // through
                                                                                    // people
                                                                                    // in
                                                                                    // enterprise
                                Node isik = representatives.item(j);

                                Person p = new Person();
                                p.setGivenname((String) evaluateXpath(queryConf.getResponseReprGivennameXpath(), isik,
                                        XPathConstants.STRING));
                                p.setSurname((String) evaluateXpath(queryConf.getResponseReprSurnameXpath(), isik,
                                        XPathConstants.STRING));
                                p.setSsn(defaultCountryCode + evaluateXpath(queryConf.getResponseReprSsnXpath(), isik,
                                        XPathConstants.STRING));

                                directors.add(p);

                            }
                            if (directors != null) {
                                boardOfDirectors.put(o, directors);
                            }
                        }
                    }
                }
            }
        } else {
            throw new RuntimeException("No query response received, cannot process response");
        }
    }

    /**
     * @return board of directors parsed from query response
     */
    public Map<Org, List<Person>> getBoardOfDirectors() {
        return boardOfDirectors;
    }
}
