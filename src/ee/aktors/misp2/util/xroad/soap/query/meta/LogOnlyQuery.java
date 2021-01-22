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

package ee.aktors.misp2.util.xroad.soap.query.meta;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.xml.namespace.QName;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Element;

import ee.aktors.misp2.beans.GroupValidPair;
import ee.aktors.misp2.beans.T3SecWrapper;
import ee.aktors.misp2.model.T3Sec;
import ee.aktors.misp2.util.LogQuery;
import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.CommonXRoadVer4And5SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad4SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad6SOAPMessageBuilder;

/**
 * Sends any XML or text content to security server in order to hold auditlog in
 * security server query logs for security and integrity reasons. An empty
 * response is always returned. The request differs based on X-Road version: 1)
 * X-Road v4 and v5: it is a security server meta-service request 2) X-Road v6:
 * it is a normal misp2 X-Road service request (configurable logOnly service
 * producer is used in v6)
 * 
 * @author sander.kallo
 *
 */
public class LogOnlyQuery extends AbstractMisp2MetaQuery {
    private static Logger logger = LogManager.getLogger(LogOnlyQuery.class);

    private String serviceXroadInstance;
    private String serviceMemberClass;
    private String serviceMemberCode;
    private String serviceSubsystemCode;
    private String serviceCode;
    private String serviceVersion;
    private T3SecWrapper input;
    private List<T3Sec> toBeSaved;

    /**
     * Initialize log-only query
     * @param input audit log entity wrapper
     * @throws DataExchangeException on initialization failure
     */
    public LogOnlyQuery(T3SecWrapper input) throws DataExchangeException {
        super();
        this.input = input;
        this.toBeSaved = new ArrayList<T3Sec>();
        validateInput();

        if (isV6()) {
            // final Configuration config = ConfigurationProvider.getConfig();
            // String logOnlyConf = config.getString("xroad.v6.logOnly");
            // service instance is same as client instance
            serviceXroadInstance = portal.getClientXroadInstance();
            serviceMemberClass = portal.getMisp2XroadServiceMemberClass();
            serviceMemberCode = portal.getMisp2XroadServiceMemberCode();
            serviceSubsystemCode = portal.getMisp2XroadServiceSubsystemCode();
            serviceCode = "logOnly";
            serviceVersion = "v1";
        } else if (isV5()) {
            serviceXroadInstance = null;
            serviceMemberClass = null;
            serviceMemberCode = getMetaServiceMemberCode();
            serviceSubsystemCode = null;
            serviceCode = "logOnly";
            serviceVersion = null;
        } else if (isV4()) {
            serviceMemberClass = null;
            serviceMemberCode = getMetaServiceMemberCode();
            serviceSubsystemCode = null;
            serviceCode = "logOnly";
            serviceVersion = null;
        }
    }

    private void validateInput() {
        if (input == null) {
            throw new IllegalArgumentException("T3SecWrapper is null.");
        }
        if (getSecurityServerUrl() == null) {
            throw new IllegalArgumentException("Endpoint is null.");
        }
        if (input.getT3sec() == null) {
            throw new IllegalArgumentException("T3Sec is not set.");
        }
        if (input.getT3sec().getUserFrom() == null) {
            throw new IllegalArgumentException("UserFrom is required.");
        }
        if (input.getT3sec().getOrgCode() == null) {
            throw new IllegalArgumentException("OrgCode is required.");
        }
        if (input.getSuperOrgCode() == null) {
            throw new IllegalArgumentException("SuperOrgCode is required.");
        }
        if (input.getT3sec().getActionId() == -1) {
            throw new IllegalArgumentException("ActionId is not valid.");
        }
    }
    
    @Override
    public String getServiceXRoadInstance() {
        return serviceXroadInstance;
    }

    @Override
    public String getServiceMemberClass() {
        return serviceMemberClass;
    }

    @Override
    public String getServiceMemberCode() {
        return serviceMemberCode;
    }

    @Override
    public String getServiceSubsystemCode() {
        return serviceSubsystemCode;
    }

    @Override
    public String getServiceCode() {
        return serviceCode;
    }

    @Override
    public String getServiceVersion() {
        return serviceVersion;
    }

    @Override
    protected String getUserId() {
        return input.getT3sec().getUserFrom();
    }

    @Override
    protected String getOrganizationCode() {
        return input.getSuperOrgCode();
    }

    @Override
    public void initSOAPRequestHeader() throws DataExchangeException {
        super.initSOAPRequestHeader();
        if (soapRequestBuilder instanceof XRoad4SOAPMessageBuilder) {
            ((XRoad4SOAPMessageBuilder) soapRequestBuilder).setUser(soapRequestBuilder.getUserIdValue().substring(2));
        }
    }

    @Override
    protected void initSOAPRequestBody() throws DataExchangeException {
        try {
            SOAPBody soapBody = soapRequestBuilder.getBody();
            SOAPElement rootElement;
            if (soapRequestBuilder instanceof XRoad6SOAPMessageBuilder) {
                rootElement = soapBody.addChildElement(getServiceCode(), "prod",
                        "http://misp2service.x-road.ee/producer");
            } else {
                ((CommonXRoadVer4And5SOAPMessageBuilder) soapRequestBuilder).setUnit(input.getT3sec().getOrgCode());
                rootElement = soapBody.addChildElement(getServiceCode(),
                        soapRequestBuilder.getXRoadNamespace().getPrefix(),
                        soapRequestBuilder.getXRoadNamespace().getUri());
            }

            SOAPElement request = rootElement.addChildElement(getRequestQName());

            QName name = new QName(LogQuery.NAME_ACTION_NAME);
            request.addChildElement(name).addTextNode(input.getActionName());
            T3Sec t3 = null;
            switch (input.getT3sec().getActionId()) {
            case LogQuery.USER_ADD_TO_GROUP:
            case LogQuery.USER_DELETE_FROM_GROUP:
                // add group_name
                if (input.getGroups() == null && input.getUsersTo() == null) {
                    throw new IllegalArgumentException("Either groupNames or usersTo are required when using action "
                            + input.getT3sec().getActionId());
                }
                if (input.getGroups() != null) {
                    for (GroupValidPair g : input.getGroups()) {
                        t3 = input.getT3sec().clone();
                        t3.setGroupName(g.getGroupName());

                        SOAPElement grps = request.addChildElement(new QName(LogQuery.NAME_GROUP));

                        grps.addChildElement(new QName(LogQuery.NAME_GROUP_NAME)).addTextNode(g.getGroupName());
                        if (g.getValidUntil() != null) {
                            t3.setValidUntil(g.getValidUntil());
                            grps.addChildElement(new QName(LogQuery.NAME_VALID_UNTIL)).addTextNode(g.getValidUntil());
                        }
                        toBeSaved.add(t3);
                    }
                }
                if (input.getUsersTo() != null) {
                    for (String uto : input.getUsersTo()) {
                        t3 = input.getT3sec().clone();
                        t3.setUserTo(uto);
                        SOAPElement grps = request.addChildElement(new QName(LogQuery.NAME_GROUP));
                        grps.addChildElement(new QName(LogQuery.NAME_GROUP_NAME)).addTextNode(t3.getGroupName());
                        if (t3.getValidUntil() != null) {
                            grps.addChildElement(new QName(LogQuery.NAME_VALID_UNTIL)).addTextNode(t3.getValidUntil());
                        }
                        toBeSaved.add(t3);
                    }
                }
                break;
            case LogQuery.MANAGER_SETTING:
            case LogQuery.MANAGER_DELETE:
            case LogQuery.USER_ADD:
            case LogQuery.USER_DELETE:
                // add user_to
                name = new QName(LogQuery.NAME_USER_TO);
                if (input.getT3sec().getUserTo() == null) {
                    throw new IllegalArgumentException(
                            "UserTo is required when using action " + input.getT3sec().getActionId());
                }
                request.addChildElement(name).addTextNode(input.getT3sec().getUserTo());
                if (toBeSaved.isEmpty()) {
                    toBeSaved.add(input.getT3sec());
                }
                break;
            case LogQuery.QUERY_RIGHTS_ADD:
            case LogQuery.QUERY_RIGHTS_DELETE:
                // add query
                name = new QName(LogQuery.NAME_QUERY_NAME);
                if (input.getQueries() == null) {
                    throw new IllegalArgumentException(
                            "Queries are required when using action " + input.getT3sec().getActionId());
                }
                for (String qn : input.getQueries()) {
                    t3 = input.getT3sec().clone();
                    t3.setQuery(qn);
                    request.addChildElement(name).addTextNode(qn);
                    toBeSaved.add(t3);
                }
                break;
            case LogQuery.USERGROUP_ADD:
            case LogQuery.USERGROUP_DELETE:
                // add group_name
                name = new QName(LogQuery.NAME_GROUP_NAME);
                if (input.getT3sec().getGroupName() == null) {
                    throw new IllegalArgumentException(
                            "GroupName is required when using action " + input.getT3sec().getActionId());
                }
                request.addChildElement(name).addTextNode(input.getT3sec().getGroupName());
                toBeSaved.add(input.getT3sec());
                break;
            case LogQuery.NEGATIVE_RESPONSE_VALIDITY_CHECK:
                // add aeg
                name = new QName(LogQuery.NAME_AEG);
                request.addChildElement(name).addTextNode(new Date().toString());
            case LogQuery.REPRESENTION_CHECK:
                // add query_name
                name = new QName(LogQuery.NAME_QUERY_NAME);
                if (input.getT3sec().getQuery() == null) {
                    throw new IllegalArgumentException(
                            "Query is required when using action " + input.getT3sec().getActionId());
                }
                request.addChildElement(name).addTextNode(input.getT3sec().getQuery());
                toBeSaved.add(input.getT3sec());
                break;
            case LogQuery.UNIT_ADD:
            case LogQuery.UNIT_DELETE:
            case LogQuery.PORTAL_ADD:
            case LogQuery.PORTAL_DELETE:
                // add portal_name
                name = new QName(LogQuery.NAME_PORTAL_NAME);
                if (input.getT3sec().getPortalName() == null) {
                    throw new IllegalArgumentException(
                            "PortalName is required when using action " + input.getT3sec().getActionId());
                }
                request.addChildElement(name).addTextNode(input.getT3sec().getPortalName());
                toBeSaved.add(input.getT3sec());
                break;
            default:
                throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_BODY_INIT_FAILED,
                        "Action type " + input.getT3sec().getActionId() + " not supported!", null);
            }

        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_BODY_INIT_FAILED,
                    "X-Road request SOAP body could not be initialized.", e);
        }
    }

    private String getResponseTagName() {
        return serviceCode + "Response";
    }

    @Override
    public void sendRequest() throws DataExchangeException {
        super.sendRequest();
        SOAPElement responseElement;
        try {
            responseElement = (SOAPElement) soapResponse.getSOAPBody().getFirstChild();
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_RESPONSE_FAULT,
                    "Error reading response element for logOnly query", e);
        }
        if (responseElement == null || !responseElement.getLocalName().equals(getResponseTagName())) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_RESPONSE_FAULT,
                    "Expected response element " + getResponseTagName() + " was not returned", null);
        }
        // add query_id
        Element id;
        try {
            id = XMLUtil.getElementByLocalTagName(soapResponse.getSOAPHeader(), soapRequestBuilder.getQueryIdTagName());
            if (id != null) {
                String queryId = id.getTextContent();
                if (queryId != null && !queryId.isEmpty()) {
                    input.getT3sec().setQueryId(queryId);
                } else {
                    logger.error("First id element is empty");
                }
            } else {
                logger.error("Id element cannot be found from message");
            }
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_RESPONSE_FAULT,
                    "Could not read ID element from response header", e);
        }

        logger.info("logOnly query was successful");
    }

    /**
     * @return list of T3Sec entities to be saved later to database
     */
    public List<T3Sec> getToBeSaved() {
        return toBeSaved;
    }
}
