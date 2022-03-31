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

package ee.aktors.misp2.util.xroad;

import ee.aktors.misp2.action.exception.QueryException;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.provider.ConfigurationProvider;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Const.XROAD_VERSION;
import ee.aktors.misp2.util.URLReader;
import ee.aktors.misp2.util.WSDLParser;
import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.XMLUtilException;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.CommonXRoadSOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XMLNamespaceContainer;
import ee.aktors.misp2.util.xroad.soap.XRoad4SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad5SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad6SOAPMessageBuilder;
import javax.xml.namespace.NamespaceContext;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.SOAPConstants;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPFault;
import javax.xml.soap.SOAPHeader;
import javax.xml.soap.SOAPMessage;
import javax.xml.soap.SOAPPart;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import org.apache.commons.configuration.Configuration;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLStreamHandler;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Utilities related to X-Road (SOAP messages, WSDLs etc)
 * 
 * @author sander.kallo
 *
 */
@SuppressWarnings("RedundantThrows")
public final class XRoadUtil {

    protected static final Logger log = LogManager.getLogger(XRoadUtil.class);

    /**
     * Hide constructor to work around RIA checkstyle limitations
     */
    private XRoadUtil() {
        //not called
    }
    
    /**
     * Get X-Road request ID to be used in SOAP request header
     * 
     * @return random HEX-string (40 characters long)
     */
    public static String getXRoadRequestId() {
        // those variables are used only once each, but
        // prior declaration is needed to work around RIA checkstyle limitations
        final int length = 32;
        final int ff = 0xFF;
        final int sixteen = 0x10;
        
        SecureRandom random = new SecureRandom();
        byte[] bytes = new byte[length];
        random.nextBytes(bytes);
        StringBuilder nonce = new StringBuilder();
        for (byte aByte : bytes) {
            int b = aByte & ff;
            if (b < sixteen)
                nonce.append('0');
            nonce.append(Integer.toHexString(b));
        }
        return nonce.toString();
    }

    /**
     * Convert {@link SOAPMessage} to String, mainly for debugging purposes
     * 
     * @param soapMessage
     *            message to be converted
     * @return SOAP-request as XML-string
     */
    public static String soapMessageToString(SOAPMessage soapMessage) {
        ByteArrayOutputStream out = soapMessageToByteArrayOutputStream(soapMessage);
        return new String(Objects.requireNonNull(out).toByteArray(), StandardCharsets.UTF_8);
    }

    /**
     * Convert SOAP message to byte array output stream
     * 
     * @param soapMessage
     *            input SOAP message
     * @return message as stream
     */
    public static ByteArrayOutputStream soapMessageToByteArrayOutputStream(SOAPMessage soapMessage) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try {
            soapMessage.writeTo(out);
            return out;
        } catch (SOAPException | IOException e) {
            log.error("Failed to generate a String from SOAPMessage", e);
        }
        return null;
    }

    /**
     * Get first child element that has matching local tag name
     * 
     * @param element
     *            whose children are searched from
     * @param tagName
     *            tag name without XML prefix that has to match the tag name of
     *            a child element
     * @return first child element with the same tag name as #tagName
     */
    public static SOAPElement getChildByLocalName(SOAPElement element, String tagName) {
        Iterator<?> itIdentifiers = element.getChildElements();
        while (itIdentifiers.hasNext()) { // iterate over xrd:service sequence
            Object identifierObj = itIdentifiers.next();
            if (identifierObj instanceof SOAPElement) {
                SOAPElement identifierElement = (SOAPElement) identifierObj;
                if (identifierElement.getLocalName().equals(tagName)) {
                    return identifierElement;
                }
            }
        }
        return null;
    }

    /**
     * Get text of first child element that has matching local tag name
     * 
     * @param element
     *            whose children are searched from
     * @param tagName
     *            tag name without XML prefix that has to match the tag name of
     *            a child element
     * @return text of first child element with the same tag name as #tagName
     */
    public static String getChildTextByLocalName(SOAPElement element, String tagName) {
        SOAPElement childElement = getChildByLocalName(element, tagName);
        return childElement != null ? childElement.getTextContent() : null;
    }

    /**
     * Check if soap-response contained fault
     * 
     * @param soapResponse
     *            input soap response
     * @throws DataExchangeException on failure
     */
    public static void checkFault(SOAPMessage soapResponse) throws DataExchangeException {
        try {
            SOAPFault fault = soapResponse.getSOAPBody().getFault();
            if (fault != null) {
                throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_RESPONSE_FAULT,
                        "X-Road SOAP response contained Fault", fault.getFaultCode(), fault.getFaultString(), null);
            }
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_RESPONSE_FAULT_CHECK_FAILED,
                    "X-Road SOAP response fault check failed", e);
        }
    }

    static class SOAPXpathNamespaceContext implements NamespaceContext {

        public String getNamespaceURI(String prefix) {
            // only SOAP-ENV namespace is defined
            return "http://schemas.xmlsoap.org/soap/envelope/";
        }

        // This method isn't necessary for XPath processing.
        @Override
        public String getPrefix(String uri) {
            throw new UnsupportedOperationException();
        }

        // This method isn't necessary for XPath processing either.
        @Override
        @SuppressWarnings("rawtypes")
        public Iterator getPrefixes(String uri) {
            throw new UnsupportedOperationException();
        }
    }
    /**
     * Throw exception if SOAP fault is found from document from SOAP message fault xpath.
     * @param doc XML document that is handled as SOAP message
     * @param remark short comment for logging
     * @param xpath XPath object with pre-determined namespace prefixes
     * @throws DataExchangeException when SOAP-Fault is found
     * (+ faultCode and faultString are embedded into the exception)
     */
    public static void checkFault(Document doc, String remark, XPath xpath) throws DataExchangeException {
        NodeList faultNodes;
        try {
            XPathExpression soapFault = xpath.compile("/SOAP-ENV:Envelope/SOAP-ENV:Body/SOAP-ENV:Fault");
            faultNodes = (NodeList) soapFault.evaluate(doc, XPathConstants.NODESET);
        } catch (XPathExpressionException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_RESPONSE_FAULT_CHECK_FAILED,
                    " " + remark + " response fault check failed", e);
        }
        String faultCode = null;
        String faultString = null;
        if (faultNodes != null && faultNodes.getLength() > 0) {
            StringWriter faultBuf = new StringWriter();
            for (int i = 0; i < faultNodes.getLength(); i++) {
                Node faultNode = faultNodes.item(i);
                faultBuf.append(faultNode.getTextContent()).append(" ");
                if (faultNode instanceof Element) {
                    Element faultCodeElement =
                        XMLUtil.getElementByLocalTagName((Element) faultNode, "faultcode");
                    faultCode = faultCodeElement != null ? faultCodeElement.getTextContent() : null;
                    Element faultStringElement =
                        XMLUtil.getElementByLocalTagName((Element) faultNode, "faultstring");
                    faultString =
                        faultStringElement != null ? faultStringElement.getTextContent() : null;
                }
            }
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_RESPONSE_FAULT,
                    " " + remark + " response contained SOAP-ENV:Fault | "
                        + faultBuf, faultCode, faultString, null);
        }
    }
    /**
     * Throw exception if SOAP fault is found from document .
     * @param doc XML document that is handled as SOAP message
     * @param remark short comment for logging
     * @throws DataExchangeException when SOAP-Fault is found
     * (+ faultCode and faultString are embedded into the exception)
     */
    public static void checkFault(Document doc, String remark) throws DataExchangeException {
        XPathFactory xpathFactory = XPathFactory.newInstance();
        XPath xpath = xpathFactory.newXPath();
        xpath.setNamespaceContext(new SOAPXpathNamespaceContext());
        checkFault(doc, remark, xpath);
    }

    /**
     * Read X-Road namespace (prefix and URI) from X-Road request
     * {@link SOAPMessage} header. Assumes there is at least one header field
     * and the first header field is in X-Road namespace.
     * 
     * @param soapMessage
     *            X-Road request {@link SOAPMessage}
     * @return namespace URI with prefix
     * @throws DataExchangeException on namespace extraction fail
     */
    public static XMLNamespaceContainer getXRoadNamespace(SOAPMessage soapMessage) throws DataExchangeException {
        try {
            SOAPHeader soapHeader = soapMessage.getSOAPHeader();
            Iterator<?> headerElements = soapHeader.getChildElements();
            SOAPElement headerElement = null;
            while (headerElements.hasNext()) {
                Object obj = headerElements.next();
                if (obj instanceof SOAPElement) {
                    headerElement = (SOAPElement) obj;
                    break;
                }
            }
            if (headerElement == null) {
                throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_HEADER_INIT_FAILED,
                        "X-Road SOAP request did not have header fields:\n" + soapMessageToString(soapMessage), null);
            }
            // log.debug("Extracted namespace " + headerElement.getPrefix() + "
            // | " + headerElement.getNamespaceURI() + " from SOAPMessage \n" +
            // soapMessageToString(soapMessage));
            return new XMLNamespaceContainer(headerElement.getPrefix(), headerElement.getNamespaceURI());
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_HEADER_INIT_FAILED,
                    "X-Road SOAP response fault check failed", e);
        }
    }

    /**
     * Convert string to list of integers
     * 
     * @param s
     *            list of comma separated integers as String, e.g "2,3,4"
     * @return {@link List} of {@link Integer}
     */
    public static List<Integer> getIntegerListFromString(String s) {
        List<Integer> l = new ArrayList<>();
        for (String intString : getStringListFromString(s)) {
            if (intString.trim().isEmpty())
                continue;
            l.add(Integer.parseInt(intString));
        }
        return l;
    }
    /**
     * Split string to substring list
     * @param s comma-separated string
     * @return list of strings
     */
    public static List<String> getStringListFromString(String s) {
        String[] ar = s.split(Pattern.quote(Const.LIST_ELEMENT_DELIMITER));
        return new ArrayList<>(Arrays.asList(ar));
    }

    /**
     * Convert WSDL string to document
     * @param wsdl WSDL string
     * @param remark comment for logging
     * @return WSDL as org.w3c.jdom.Document
     * @throws QueryException on WSDL parsing failure
     * @throws DataExchangeException on WSDL validation failure
     */
    private static Document wsdlToDocument(String wsdl, String remark) throws QueryException, DataExchangeException {
        Document doc;
        try {
            doc = XMLUtil.convertXMLToDocument(wsdl);
        } catch (XMLUtilException e) {
            throw new QueryException(QueryException.Type.WSDL_READING_FAILED,
                    "Failed to convert WSDL to XML document " + remark, e);
        }
        // validation that there is no SOAP-ENV:Fault in WSDL response
        new WSDLParser(doc, XROAD_VERSION.V6);
        return doc;
    }

    /**
     * Convert WSDL input stream to document
     * @param wsdl WSDL input stream
     * @param remark comment for logging
     * @return WSDL as org.w3c.jdom.Document
     * @throws QueryException on WSDL parsing failure
     * @throws DataExchangeException on WSDL validation failure
     */
    public static Document wsdlToDocument(InputStream wsdl, String remark) throws
        QueryException, DataExchangeException {
        Document doc;
        try {
            doc = XMLUtil.convertInputStreamToDocument(wsdl);
        } catch (XMLUtilException e) {
            throw new QueryException(QueryException.Type.WSDL_READING_FAILED,
                    "Failed to convert WSDL to XML document " + remark, e);
        }
        // validation that there is no SOAP-ENV:Fault in WSDL response
        new WSDLParser(doc, XROAD_VERSION.V6);
        return doc;
    }

    private static String readXml(String url) throws QueryException, DataExchangeException {
        String xml = URLReader.readUrlStr(getMetaServiceEndpointUrlWithTimeouts(url), false);
        Objects.requireNonNull(xml);
        return xml;
    }
    /**
     * Read WSDL from URL and validate it
     * @param wsdlUrl web URL to WSDL
     * @return WSDL as string
     * @throws QueryException on failure
     * @throws DataExchangeException when WSDL contains SOAP fault
     */
    public static String readValidWsdlAsString(String wsdlUrl) throws QueryException, DataExchangeException {
        String wsdl = readXml(wsdlUrl);
        wsdlToDocument(wsdl, wsdlUrl);
        return wsdl;

    }

    /**
     * Read WSDL from URL and validate it
     * @param wsdlUrl web URL to WSDL
     * @return WSDL as document
     * @throws QueryException on failure
     * @throws DataExchangeException when WSDL contains SOAP fault
     */
    public static Document readValidWsdlAsDocument(String wsdlUrl) throws QueryException, DataExchangeException {
        String wsdl = readXml(wsdlUrl);
        return wsdlToDocument(wsdl, wsdlUrl);
    }

    /**
     * @return list of possible allowed X-Road v6 member class options
     */
    public static List<String> getMemberClasses() {
        String[] memberClasses = ConfigurationProvider.getConfig().getStringArray("xrd.v6.member_classes");
        return Arrays.asList(memberClasses);
    }

    /**
     * Get proper implementation of X-Road query builder based on
     * portal.xroadVersion. The builder is a wrapper of request SOAPMessage with
     * additional helper methods to manipulate X-Road SOAP message header
     * fields.
     * 
     * @param portal
     *            user session portal entity
     * @return instance of CommonXRoadSOAPMessageBuilder
     * @throws DataExchangeException on builder retrieval failure
     */
    public static CommonXRoadSOAPMessageBuilder getXRoadSOAPMessageBuilder(Portal portal) throws DataExchangeException {
        if (portal.isV6()) {
            return new XRoad6SOAPMessageBuilder(portal.getXroadNamespace());
        } else if (portal.isV5()) {
            return new XRoad5SOAPMessageBuilder(portal.getXroadNamespace());
        } else if (portal.isV4()) {
            return new XRoad4SOAPMessageBuilder(portal.getXroadNamespace());
        } else {
            throw new RuntimeException("Unknown portal.xroadVersion " + portal.getXroadProtocolVer());
        }
    }

    /**
     * Get message builder by X-Road version
     * @param xroadVersion X-Road version as integer
     * @return X-Road request message builder
     * @throws DataExchangeException on failure
     */
    public static CommonXRoadSOAPMessageBuilder getXRoadSOAPMessageBuilder(int xroadVersion)
            throws DataExchangeException {
        Portal portal = new Portal();
        portal.setXroadProtocolVer(Objects.requireNonNull(XROAD_VERSION.getByIndex(xroadVersion)).getProtocolVersion());
        return getXRoadSOAPMessageBuilder(portal);
    }

    /**
     * Helper method for comparing objects. The purpose is to avoid
     * null-comparisons between the objects by covering possible null-comparison
     * scenarios.
     * 
     * @param obj
     *            first object, could be null
     * @param anotherObj
     *            another object, could be null
     * @return #true or #false if one of the objects is null, and returns null,
     *         if objects both exist (null meaning equality is not determined)
     */
    private static Boolean areObjectsEqual(Object obj, Object anotherObj) {
        // objects are definitely unequal: one is null and another isn't
        if (obj == null && anotherObj != null || obj != null && anotherObj == null) {
            return false;
        } else if (obj == null) {
            // objects are definitely equal: both are nulls
            return true;
        }
        // don't know if the objects are equal, but they both exist
        return null;
    }

    private static boolean areStringsEqual(String str, String anotherStr) {
        Boolean stringsEqual = areObjectsEqual(str, anotherStr);
        if (stringsEqual != null)
            return stringsEqual;
        return str.equals(anotherStr);
    }

    // currently compare producers by ID, but in case IDs are missing, this
    // method could be used
    @SuppressWarnings(value = { "unused" })
    private static boolean areProducersEqual(Producer producer, Producer anotherProducer) {
        Portal portal = producer.getPortal();
        Boolean producersEqual = areObjectsEqual(producer, anotherProducer);
        // return if one of the producers is null, no other comparison needed
        if (producersEqual != null)
            return producersEqual;

        // producer != null && anotherProducer != null
        if (portal.isV6()) {
            boolean memberClassEqual = areStringsEqual(producer.getMemberClass(), anotherProducer.getMemberClass());
            boolean memberCodesEqual = areStringsEqual(producer.getShortName(), anotherProducer.getShortName());
            boolean subsystemCodesEqual = areStringsEqual(producer.getSubsystemCode(),
                    anotherProducer.getSubsystemCode());
            return memberClassEqual && memberCodesEqual && subsystemCodesEqual;
        } else {
            return areStringsEqual(producer.getShortName(), anotherProducer.getShortName());
        }
    }
    /**
     * Check if producer is contained in a set.
     * @param producer entity to be checked
     * @param producers list to be checked
     * @return true if producer is contained in a set
     */
    public static boolean isProducerUniqueInSet(Producer producer, Set<Producer> producers) {
        for (Producer producerItem : producers) {
            if (producerItem.getId().equals(producer.getId()))
                return false;
            // alternative not using ID: if(areProducersEqual(producer,
            // producerItem)) return true;
        }
        return true;
    }

    /**
     * Display ':'-separated list of X-Road v6 represented party values.
     * @param memberClass represented party class
     * @param memberCode represented party code
     * @return represented party identifier
     */
    public static String getXRoadV6RepresentedPartySummary(String memberClass, String memberCode) {
        if (memberClass == null && memberCode == null)
            return null;
        return memberClass + Const.XROAD_V6_FIELD_SEPARATOR + memberCode;
    }

    /**
     * @param serviceXRoadInstanceValue xrd:service/iden:xRoadInstance element value
     * @param serviceMemberClassValue xrd:service/iden:memberClass element value
     * @param serviceMemberCodeValue xrd:service/iden:memberCode element value
     * @param serviceSubsystemCodeValue xrd:service/iden:subsystemCode element value
     * @param serviceCodeValue xrd:service/iden:serviceCode element value
     * @param serviceVersionValue xrd:service/iden:serviceVersion element value
     * @return ':'-separated list of X-Road v6 service field values.
     */
    public static String getXRoadV6ServiceSummary(String serviceXRoadInstanceValue, String serviceMemberClassValue,
            String serviceMemberCodeValue, String serviceSubsystemCodeValue, String serviceCodeValue,
            String serviceVersionValue) {
        return serviceXRoadInstanceValue + Const.XROAD_V6_FIELD_SEPARATOR + serviceMemberClassValue + Const.XROAD_V6_FIELD_SEPARATOR
                + serviceMemberCodeValue + Const.XROAD_V6_FIELD_SEPARATOR + serviceSubsystemCodeValue
                + Const.XROAD_V6_FIELD_SEPARATOR + serviceCodeValue
                + (serviceVersionValue != null ? Const.XROAD_V6_FIELD_SEPARATOR + serviceVersionValue :  "");
    }
    
    /**
     * @param serviceXRoadInstanceValue xrd:service/iden:xRoadInstance element value
     * @param serviceMemberClassValue xrd:service/iden:memberClass element value
     * @param serviceMemberCodeValue xrd:service/iden:memberCode element value
     * @param serviceSubsystemCodeValue xrd:service/iden:subsystemCode element value
     * @param serviceCodeValue xrd:service/iden:serviceCode element value
     * @param serviceVersionValue xrd:service/iden:serviceVersion element value
     * @return true if X-Road v6 service parameters describe X-Road v6 service, false if not
     */
    public static boolean hasXRoadV6Service(String serviceXRoadInstanceValue, String serviceMemberClassValue,
            String serviceMemberCodeValue, String serviceSubsystemCodeValue, String serviceCodeValue,
            String serviceVersionValue) {
        return serviceXRoadInstanceValue != null || serviceMemberClassValue != null || serviceMemberCodeValue != null
                || serviceSubsystemCodeValue != null || serviceCodeValue != null || serviceVersionValue != null;
    }

    /**
     * @param clientXRoadInstanceValue xrd:client/iden:xRoadInstance element value
     * @param clientMemberClassValue xrd:client/iden:memberClass element value
     * @param clientMemberCodeValue xrd:client/iden:memberCode element value
     * @param clientSubsystemCodeValue xrd:client/iden:subsystemCode element value
     * 
     * @return ':'-separated list of X-Road v6 client field values.
     */
    public static String getXRoadV6ClientSummary(String clientXRoadInstanceValue, String clientMemberClassValue,
            String clientMemberCodeValue, String clientSubsystemCodeValue) {
        return clientXRoadInstanceValue + Const.XROAD_V6_FIELD_SEPARATOR + clientMemberClassValue + Const.XROAD_V6_FIELD_SEPARATOR
                + clientMemberCodeValue + Const.XROAD_V6_FIELD_SEPARATOR + clientSubsystemCodeValue;
    }
    
    /**
     * Get X-Road message builder by message and boolean value describing if
     * current portal is of X-Road version 6 or not.
     * @param soapMessage assembled X-Road SOAP message
     * @param xroadV6 true, if portal is configured to use X-Road v6
     * @return SOAP message builder for determined X-Road protocol
     * @throws DataExchangeException on builder creation failure
     */
    public static CommonXRoadSOAPMessageBuilder getXRoadSOAPMessageBuilder(
            SOAPMessage soapMessage, boolean xroadV6) throws DataExchangeException {
        CommonXRoadSOAPMessageBuilder soapMessageBuilder;
        if (xroadV6) {
            soapMessageBuilder = new XRoad6SOAPMessageBuilder(soapMessage);
        } else {
            // processing the header for v5 is done below in unison with v4
            // message
            XRoad5SOAPMessageBuilder soapMessageBuilderV5 = new XRoad5SOAPMessageBuilder(soapMessage);
            XRoad4SOAPMessageBuilder soapMessageBuilderV4 = new XRoad4SOAPMessageBuilder(soapMessage);
            if (soapMessageBuilderV5.getServiceValue() != null) {
                soapMessageBuilder = soapMessageBuilderV5;
            } else if (soapMessageBuilderV4.getServiceValue() != null) {
                soapMessageBuilder = soapMessageBuilderV4;
            } else {
                throw new RuntimeException("Message did not contain a valid X-Road v4 or v5 header service tag");
            }
        }
        return soapMessageBuilder;
    }

    /**
     * Convert existing XML node to XML Document (shallow copy)
     * 
     * @param doc XML document corresponding to the element
     * @param element
     *            XML document node, is placed as a root element of new SOAPMessage
     * @return XML document
     * @throws SOAPException on failure
     */
    public static SOAPMessage convertNodeToSOAPMessage(Document doc, Element element) throws SOAPException {
        SOAPMessage message = MessageFactory.newInstance(SOAPConstants.SOAP_1_1_PROTOCOL).createMessage();
        SOAPPart sp = message.getSOAPPart();

        NodeList headerAndBody = element.getChildNodes();
        for (int j = 0; j < headerAndBody.getLength(); j++) {
            if (headerAndBody.item(j) instanceof Element && headerAndBody.item(j).getLocalName().equals("Header")) {
                NodeList headerElements = headerAndBody.item(j).getChildNodes();
                for (int i = 0; i < headerElements.getLength(); i++) {
                    Node imported = sp.importNode(headerElements.item(i), true);
                    message.getSOAPHeader().appendChild(imported);
                }
            }
        }
        return message;
    }

    /**
     * Get URL with connect and read timeouts set in its internal handler
     * 
     * @param endpointUrl
     *            endpoint URL as string
     * @param connectTimeout
     *            maximum endpoint connecting time in milliseconds
     * @param readTimeout
     *            maximum endpoint data reading timeout in milliseconds
     * @return URL with set timeouts
     */
    private static URL getEndpointUrlWithTimeouts(String endpointUrl, final Integer connectTimeout,
            final Integer readTimeout) throws DataExchangeException {
        try {
            if (connectTimeout == null && readTimeout == null) {
                return new URL(endpointUrl);
            } else {
                log.debug("Connect timeout " + connectTimeout + " ms, read timeout " + readTimeout + " ms for URL "
                        + endpointUrl);
                return new URL(new URL(endpointUrl), "", new URLStreamHandler() {
                    @Override
                    protected URLConnection openConnection(URL url) throws IOException {
                        URL target = new URL(url.toString());
                        URLConnection connection = target.openConnection();
                        // Connection settings
                        if (connectTimeout != null) {
                            connection.setConnectTimeout(connectTimeout);
                        }
                        if (readTimeout != null) {
                            connection.setReadTimeout(readTimeout);
                        }
                        // Overwrite default Accept header
                        setGenericAcceptHeader(connection);
                        return connection;
                    }
                });
            }
        } catch (MalformedURLException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SECURITY_SERVER_URL_MALFORMED,
                    "Endpoint URL could not be parsed", e);
        }
    }

    private static URL getEndpointUrlWithTimeoutsFromConf(String endpointUrl, final String connectTimeoutKey,
            final String readTimeoutKey) throws DataExchangeException {
        Configuration config = ConfigurationProvider.getConfig();
        final int kilo = 1000;
        Integer connectTimeout = null; // ms
        if (config.containsKey(connectTimeoutKey)) {
            double connectTimeoutInSeconds = config.getDouble(connectTimeoutKey);
            if (connectTimeoutInSeconds > 0) {
                connectTimeout = (int) Math.round(connectTimeoutInSeconds * kilo);
            }
        }

        Integer readTimeout = null; // ms
        if (config.containsKey(readTimeoutKey)) {
            double readTimeoutInSeconds = config.getDouble(readTimeoutKey);
            if (readTimeoutInSeconds > 0) {
                readTimeout = (int) Math.round(readTimeoutInSeconds * kilo);
            }
        }
        return getEndpointUrlWithTimeouts(endpointUrl, connectTimeout, readTimeout);
    }

    /**
     * Create {@link URL} object from given URL string and set meta-service
     * timeouts form conf (security server SOAP and HTTP GET WSDL and
     * /listClient queries)
     * 
     * @param endpointUrl
     *            target URL
     * @return URL with set timeouts
     * @throws DataExchangeException on failure
     */
    public static URL getMetaServiceEndpointUrlWithTimeouts(String endpointUrl) throws DataExchangeException {
        final String connectTimeoutKey = "xrd.security_server.meta.connect_timeout";
        final String readTimeoutKey = "xrd.security_server.meta.read_timeout";
        return getEndpointUrlWithTimeoutsFromConf(endpointUrl, connectTimeoutKey, readTimeoutKey);
    }

    /**
     * Create {@link URL} object from given URL string and set mediator
     * (servlet) timeouts form conf
     * 
     * @param endpointUrl
     *            target URL
     * @return URL with set timeouts
     * @throws DataExchangeException on failure
     */
    public static URL getMediatorServiceEndpointUrlWithTimeouts(String endpointUrl) throws DataExchangeException {
        final String connectTimeoutKey = "xrd.security_server.mediator.connect_timeout";
        final String readTimeoutKey = "xrd.security_server.mediator.read_timeout";
        return getEndpointUrlWithTimeoutsFromConf(endpointUrl, connectTimeoutKey, readTimeoutKey);
    }

    private static Pattern getExcludedProducersRegexPattern() {
        String excludeProducersRegexStr = ConfigurationProvider.getConfig().getString("xrd.v6.exclude_producers_regex");
        if (excludeProducersRegexStr != null && !excludeProducersRegexStr.isEmpty()) {
            if (log.isTraceEnabled()) {
                log.trace("Exclude producer regex string: '" + excludeProducersRegexStr + "'");
            }
            return Pattern.compile(excludeProducersRegexStr);
        }
        return null;
    }

    private static boolean isProducerExcluded(String xroadIdentifier) {
        String text = xroadIdentifier.replace(" ", "");
        Pattern excludedProducersRegexPattern = getExcludedProducersRegexPattern();
        if (excludedProducersRegexPattern == null) {
            log.trace("excluedProducersRegexPattern == null -> do not exclude producer since pattern is not defined");
            return false;
        }
        Matcher m = excludedProducersRegexPattern.matcher(text);
        boolean result = m.matches();
        log.trace("result: " + result + "identifier:" + xroadIdentifier + " pattern: " + excludedProducersRegexPattern);
        return result;
    }
    
    /**
     * @param producer producer entity
     * @return true if producer should be displayed to the end user or false, if not
     */
    public static boolean isProducerExcluded(Producer producer) {
        if (producer == null || producer.getXroadIdentifier() == null) {
            log.warn("producer " + producer + " is not defined, unexpected behavior");
            return true;
        }
        return isProducerExcluded(producer.getXroadIdentifier());
    }

    /**
     * Overwrite default Accept header, which otherwise causes problems with security server.
     * @param urlConnection URL connection object. NB! State is assumed to be not yet connected.
     */
    public static void setGenericAcceptHeader(URLConnection urlConnection) {
        urlConnection.setRequestProperty("Accept", "*/*");
    }
}
