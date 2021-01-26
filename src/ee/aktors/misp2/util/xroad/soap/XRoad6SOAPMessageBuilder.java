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

package ee.aktors.misp2.util.xroad.soap;

import javax.xml.namespace.QName;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPMessage;
import javax.xml.soap.SOAPPart;

import org.w3c.dom.Node;

import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * X-Road version 6 soap message builder
 * 
 * @author sander.kallo
 *
 */
public class XRoad6SOAPMessageBuilder extends CommonXRoadSOAPMessageBuilder {
    public static final String IDEN_NAMESPACE_URI = "http://x-road.eu/xsd/identifiers";
    public static final String REPR_NAMESPACE_URI = "http://x-road.eu/xsd/representation.xsd";
    protected XMLNamespaceContainer identifiersNamespace;
    protected XMLNamespaceContainer representationNamespace;
    
    /**
     * Create X-Road 6 SOAP message builder from namespace URI argument
     * @param xroadNamespaceSuffix  SOAP header X-Road namespace URI
     * @throws DataExchangeException when builder initialization fails
     */
    public XRoad6SOAPMessageBuilder(String xroadNamespaceSuffix) throws DataExchangeException {
        super(new XMLNamespaceContainer("xrd", xroadNamespaceSuffix));
        init("Error initializing XRoad6SOAPMessageBuilder from namespace");

    }
    /**
     * Create X-Road 6 SOAP message builder from existing SOAP message
     * @param soapMessage existing X-Road v6 SOAP request message
     * @throws DataExchangeException when initialization fails
     */
    public XRoad6SOAPMessageBuilder(SOAPMessage soapMessage) throws DataExchangeException {
        super(soapMessage);
        init("Error initializing XRoad6SOAPMessageBuilder from existing message");
    }

    protected void init(String comment) throws DataExchangeException {
        SOAPPart soapPart = this.soapMessage.getSOAPPart();
        identifiersNamespace = new XMLNamespaceContainer("iden", IDEN_NAMESPACE_URI);
        representationNamespace = new XMLNamespaceContainer("repr", REPR_NAMESPACE_URI);

        try {
            SOAPEnvelope envelope = soapPart.getEnvelope();
            envelope.addNamespaceDeclaration(getXRoadNamespace().getPrefix(), getXRoadNamespace().getUri());
            envelope.addNamespaceDeclaration(identifiersNamespace.getPrefix(), identifiersNamespace.getUri());
            envelope.addNamespaceDeclaration(representationNamespace.getPrefix(), representationNamespace.getUri());
            setHeaderField(getProtocolVersionTagName(), "4.0");
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_MESSAGE_BUILDER_INIT_FAILED, comment,
                    e);
        }
    }

    @Override
    protected Node getUserId() throws DataExchangeException {
        return getHeaderField(getUserIdTagName());
    }

    @Override
    protected Node getQueryId() throws DataExchangeException {
        return getHeaderField(getQueryIdTagName());
    }

    @Override
    public void setUserId(String userId) throws DataExchangeException {
        setHeaderField(getUserIdTagName(), userId);

    }

    @Override
    public void setQueryId(String queryId) throws DataExchangeException {
        setHeaderField(getQueryIdTagName(), queryId);

    }

    protected SOAPElement getOrCreateHeaderTreeElement(String tagName, String objectType,
            XMLNamespaceContainer namespaceContainer) throws DataExchangeException {
        Node headerNode = getHeaderField(tagName, namespaceContainer);
        if (headerNode != null) {
            return (SOAPElement) headerNode;
        }

        SOAPElement headerSoapElement = setHeaderField(tagName, "", namespaceContainer);
        try {
            if (objectType != null) {
                headerSoapElement.addAttribute(getObjectTypeQName(), objectType);
            }
            return headerSoapElement;
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_HEADER_INIT_FAILED,
                    "Error setting X-Road v6 " + tagName + " iden:objectType=\"" + objectType
                            + "\" in SOAP request header",
                    e);
        }
    }

    protected SOAPElement getOrCreateClient() throws DataExchangeException {
        return getOrCreateHeaderTreeElement(getClientTagName(), "SUBSYSTEM", getXRoadNamespace());
    }

    protected SOAPElement getOrCreateService() throws DataExchangeException {
        return getOrCreateHeaderTreeElement(getServiceTagName(), "SERVICE", getXRoadNamespace());
    }

    protected SOAPElement getOrCreateRepresentedParty() throws DataExchangeException {
        return getOrCreateHeaderTreeElement(getRepresentedPartyTagName(), null, representationNamespace);
    }

    /**
     * Remove representation party element if it exists
     * @throws DataExchangeException on failure
     */
    public void removeRepresentedParty() throws DataExchangeException {
        setHeaderField(getRepresentedPartyTagName(), null, representationNamespace);
    }

    protected SOAPElement getClient() throws DataExchangeException {
        return (SOAPElement) getHeaderField(getClientTagName());
    }

    protected SOAPElement getService() throws DataExchangeException {
        return (SOAPElement) getHeaderField(getServiceTagName());
    }

    protected SOAPElement getRepresentedParty() throws DataExchangeException {
        return (SOAPElement) getHeaderField(getRepresentedPartyTagName(), representationNamespace);
    }

    protected SOAPElement setHeaderTreeElementChild(SOAPElement parentElement, String tagName, String value,
            XMLNamespaceContainer namespaceContainer) throws DataExchangeException {
        return setUniqueField(parentElement, tagName, value, namespaceContainer);
    }

    protected SOAPElement setClientChild(String tagName, String value) throws DataExchangeException {
        return setHeaderTreeElementChild(getOrCreateClient(), tagName, value, identifiersNamespace);
    }

    protected SOAPElement setServiceChild(String tagName, String value) throws DataExchangeException {
        return setHeaderTreeElementChild(getOrCreateService(), tagName, value, identifiersNamespace);
    }

    protected SOAPElement setRepresentationChild(String tagName, String value) throws DataExchangeException {
        return setHeaderTreeElementChild(getOrCreateRepresentedParty(), tagName, value, representationNamespace);
    }

    protected QName getObjectTypeQName() {
        return new QName(identifiersNamespace.getUri(), "objectType", identifiersNamespace.getPrefix());
    }

    /**
     * Set xrd:service/iden:xRoadInstance element in X-Road SOAP message header
     * @param xroadInstance value to be set
     * @throws DataExchangeException on failure
     */
    public void setServiceXRoadInstance(String xroadInstance) throws DataExchangeException {
        setServiceChild(getXRoadInstanceTagName(), xroadInstance);
    }

    /**
     * Set xrd:service/iden:memberClass element in X-Road SOAP message header
     * @param serviceMemberClass value to be set
     * @throws DataExchangeException on failure
     */
    public void setServiceMemberClass(String serviceMemberClass) throws DataExchangeException {
        setServiceChild(getMemberClassTagName(), serviceMemberClass);
    }


    /**
     * Set xrd:service/iden:memberCode element in X-Road SOAP message header
     * @param serviceMemberCode value to be set
     * @throws DataExchangeException on failure
     */
    public void setServiceMemberCode(String serviceMemberCode) throws DataExchangeException {
        setServiceChild(getMemberCodeTagName(), serviceMemberCode);
    }

    /**
     * Set xrd:service/iden:subsystemCode element in X-Road SOAP message header
     * @param serviceSubsystemCode value to be set
     * @throws DataExchangeException on failure
     */
    public void setServiceSubsystemCode(String serviceSubsystemCode) throws DataExchangeException {
        setServiceChild(getSubsystemCodeTagName(), serviceSubsystemCode);
    }

    /**
     * Set xrd:service/iden:serviceCode element in X-Road SOAP message header
     * @param serviceCode value to be set
     * @throws DataExchangeException on failure
     */
    public void setServiceCode(String serviceCode) throws DataExchangeException {
        setServiceChild(getServiceCodeTagName(), serviceCode);
    }

    /**
     * Set xrd:service/iden:serviceVersion element in X-Road SOAP message header
     * @param serviceVersion value to be set
     * @throws DataExchangeException on failure
     */
    public void setServiceVersion(String serviceVersion) throws DataExchangeException {
        setServiceChild(getServiceVersionTagName(), serviceVersion);
    }

    /**
     * Set xrd:client/iden:xRoadInstance element in X-Road SOAP message header
     * @param xroadInstance value to be set
     * @throws DataExchangeException on failure
     */
    public void setClientXRoadInstance(String xroadInstance) throws DataExchangeException {
        setClientChild(getXRoadInstanceTagName(), xroadInstance);
    }

    /**
     * Set xrd:client/iden:memberClass element in X-Road SOAP message header
     * @param memberClass value to be set
     * @throws DataExchangeException on failure
     */
    public void setClientMemberClass(String memberClass) throws DataExchangeException {
        setClientChild(getMemberClassTagName(), memberClass);
    }

    /**
     * Set xrd:client/iden:memberCode element in X-Road SOAP message header
     * @param memberCode value to be set
     * @throws DataExchangeException on failure
     */
    public void setClientMemberCode(String memberCode) throws DataExchangeException {
        setClientChild(getMemberCodeTagName(), memberCode);
    }

    /**
     * Set xrd:client/iden:subsystemCode element in X-Road SOAP message header
     * @param subsystemCode value to be set
     * @throws DataExchangeException on failure
     */
    public void setClientSubsystemCode(String subsystemCode) throws DataExchangeException {
        setClientChild(getSubsystemCodeTagName(), subsystemCode);
    }

    /**
     * Set repr:representedParty/repr:partyClass element in X-Road SOAP message header
     * @param partyClass value to be set
     * @throws DataExchangeException on failure
     */
    public void setRepresentedPartyClass(String partyClass) throws DataExchangeException {
        setRepresentationChild(getPartyClassTagName(), partyClass);
    }

    /**
     * Set repr:representedParty/repr:partyCode element in X-Road SOAP message header
     * @param partyCode value to be set
     * @throws DataExchangeException on failure
     */
    public void setRepresentedPartyCode(String partyCode) throws DataExchangeException {
        setRepresentationChild(getPartyCodeTagName(), partyCode);
    }

    // ---------- Getters ----------
    protected String getServiceChildValue(String tagName) throws DataExchangeException {
        return XMLUtil.getElementValueSafely(XMLUtil.getElementByLocalTagName(getService(), tagName));
    }

    protected String getClientChildValue(String tagName) throws DataExchangeException {
        return XMLUtil.getElementValueSafely(XMLUtil.getElementByLocalTagName(getClient(), tagName));
    }

    protected String getRepresentationChildValue(String tagName) throws DataExchangeException {
        return XMLUtil.getElementValueSafely(XMLUtil.getElementByLocalTagName(getRepresentedParty(), tagName));
    }
    /**
     * @return xrd:service/iden:xRoadInstance element content from X-Road SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getServiceXRoadInstanceValue() throws DataExchangeException {
        return getServiceChildValue(getXRoadInstanceTagName());
    }
    /**
     * @return xrd:service/iden:memberClass element content from X-Road SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getServiceMemberClassValue() throws DataExchangeException {
        return getServiceChildValue(getMemberClassTagName());
    }
    /**
     * @return xrd:service/iden:memberCode element content from X-Road SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getServiceMemberCodeValue() throws DataExchangeException {
        return getServiceChildValue(getMemberCodeTagName());
    }

    /**
     * @return xrd:service/iden:subsystemCode element content from X-Road SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getServiceSubsystemCodeValue() throws DataExchangeException {
        return getServiceChildValue(getSubsystemCodeTagName());
    }

    /**
     * @return xrd:service/iden:serviceCode element from X-Road SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getServiceCodeValue() throws DataExchangeException {
        return getServiceChildValue(getServiceCodeTagName());
    }

    /**
     * @return xrd:service/iden:serviceVersion element from X-Road SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getServiceVersionValue() throws DataExchangeException {
        return getServiceChildValue(getServiceVersionTagName());
    }

    /**
     * @return xrd:client/iden:xRoadInstance element from X-Road SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getClientXRoadInstanceValue() throws DataExchangeException {
        return getClientChildValue(getXRoadInstanceTagName());
    }
    
    /**
     * @return xrd:client/iden:memberClass element from X-Road SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getClientMemberClassValue() throws DataExchangeException {
        return getClientChildValue(getMemberClassTagName());
    }

    /**
     * @return xrd:client/iden:memberCode element from X-Road SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getClientMemberCodeValue() throws DataExchangeException {
        return getClientChildValue(getMemberCodeTagName());
    }

    /**
     * @return xrd:client/iden:subsystemCode element from X-Road SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getClientSubsystemCodeValue() throws DataExchangeException {
        return getClientChildValue(getSubsystemCodeTagName());
    }

    /**
     * @return repr:representedParty/repr:partyClass element from X-Road SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getRepresentedPartyClassValue() throws DataExchangeException {
        return getRepresentationChildValue(getPartyClassTagName());
    }

    /**
     * @return repr:representedParty/repr:partyCode element from X-Road SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getRepresentedPartyCodeValue() throws DataExchangeException {
        return getRepresentationChildValue(getPartyCodeTagName());
    }

    // ---------- Tag name definitions ----------
    protected String getProtocolVersionTagName() {
        return "protocolVersion";
    }

    protected String getUserIdTagName() {
        return "userId";
    }

    public static final String SERVICE_TAG_NAME = "service";

    protected String getServiceTagName() {
        return SERVICE_TAG_NAME;
    }

    protected String getClientTagName() {
        return "client";
    }

    protected String getRepresentedPartyTagName() {
        return "representedParty";
    }

    protected String getPartyClassTagName() {
        return "partyClass";
    }

    protected String getPartyCodeTagName() {
        return "partyCode";
    }

    // constants need to be public to facilitate reuse, since meta-services
    // return the same tag names also in body
    public static final String XROAD_INSTANCE_TAG_NAME = "xRoadInstance";

    protected String getXRoadInstanceTagName() {
        return XROAD_INSTANCE_TAG_NAME;
    }

    public static final String MEMBER_CLASS_TAG_NAME = "memberClass";

    protected String getMemberClassTagName() {
        return MEMBER_CLASS_TAG_NAME;
    }

    public static final String MEMBER_CODE_TAG_NAME = "memberCode";

    protected String getMemberCodeTagName() {
        return MEMBER_CODE_TAG_NAME;
    }

    public static final String SUBSYSTEM_CODE_TAG_NAME = "subsystemCode";

    protected String getSubsystemCodeTagName() {
        return SUBSYSTEM_CODE_TAG_NAME;
    }

    public static final String SERVICE_CODE_TAG_NAME = "serviceCode";

    protected String getServiceCodeTagName() {
        return SERVICE_CODE_TAG_NAME;
    }

    public static final String SERVICE_VERSION_TAG_NAME = "serviceVersion";

    protected String getServiceVersionTagName() {
        return SERVICE_VERSION_TAG_NAME;
    }
    /**
     * @return client field summary from X-Road v6 header
     * @throws DataExchangeException on retrieval failure
     */
    public String getClientSummary() throws DataExchangeException {
        return XRoadUtil.getXRoadV6ClientSummary(getClientXRoadInstanceValue(), getClientMemberClassValue(),
                getClientMemberCodeValue(), getClientSubsystemCodeValue());
    }

    @Override
    public String getServiceSummary() throws DataExchangeException {
        return XRoadUtil.getXRoadV6ServiceSummary(getServiceXRoadInstanceValue(), getServiceMemberClassValue(),
                getServiceMemberCodeValue(), getServiceSubsystemCodeValue(), getServiceCodeValue(),
                getServiceVersionValue());
    }

    @Override
    public boolean hasService() throws DataExchangeException {
        return XRoadUtil.hasXRoadV6Service(getServiceXRoadInstanceValue(), getServiceMemberClassValue(),
                getServiceMemberCodeValue(), getServiceSubsystemCodeValue(), getServiceCodeValue(),
                getServiceVersionValue());
    }

    /**
     * @return represented party (unit) class and code from X-Road v6 header separated by colon
     * @throws DataExchangeException on retrieval failure
     */
    public String getRepresentedPartySummary() throws DataExchangeException {
        return XRoadUtil.getXRoadV6RepresentedPartySummary(getRepresentedPartyClassValue(),
                getRepresentedPartyCodeValue());
    }
}
