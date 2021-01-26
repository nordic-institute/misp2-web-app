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

import java.io.IOException;
import java.io.StringReader;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPConstants;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPHeader;
import javax.xml.soap.SOAPMessage;
import javax.xml.soap.SOAPPart;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * Common functionality for all implemented X-Road SOAP request messages.
 * (e.g. getting and setting message header field values).
 * @author sander.kallo
 *
 */
public abstract class CommonXRoadSOAPMessageBuilder {
    protected Logger log = LogManager.getLogger(CommonXRoadSOAPMessageBuilder.class);

    /**
     * X-Road SOAP message that is constructed
     */
    protected SOAPMessage soapMessage;
    protected SOAPPart soapPart; // directly referring to soapMessage, added to ease use
    protected SOAPEnvelope envelope; // directly referring to soapMessage, added to ease use
    private XMLNamespaceContainer xroadNamespace;
    
    /**
     * Initialize builder using  X-Road namespace URI of SOAP header elements
     * @param xroadNamespace X-Road namespace URI
     * @throws DataExchangeException on initialization failure
     */
    public CommonXRoadSOAPMessageBuilder(XMLNamespaceContainer xroadNamespace) throws DataExchangeException {
        try {
            soapMessage = MessageFactory.newInstance(SOAPConstants.SOAP_1_1_PROTOCOL).createMessage();
            soapPart = soapMessage.getSOAPPart();
            envelope = soapPart.getEnvelope();
            this.xroadNamespace = xroadNamespace;
            assert getHeader() != null;
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_MESSAGE_BUILDER_INIT_FAILED,
                    "Error initializing CommonXRoadSOAPMessageBuilder(xroadNamespace)", e);
        }
    }
    
    /**
     * Initialize builder using X-Road SOAP message
     * @param soapMessage X-Road SOAP message
     * @throws DataExchangeException on initialization failure
     */
    public CommonXRoadSOAPMessageBuilder(SOAPMessage soapMessage) throws DataExchangeException {
        try {
            this.soapMessage = soapMessage;
            soapPart = soapMessage.getSOAPPart();
            envelope = soapPart.getEnvelope();
            this.xroadNamespace = XRoadUtil.getXRoadNamespace(soapMessage);
            assert getHeader() != null;
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_MESSAGE_BUILDER_INIT_FAILED,
                    "Error initializing CommonXRoadSOAPMessageBuilder(soapMessage)", e);
        }
    }

    /** Getters for header tags */
    protected abstract Node getUserId() throws DataExchangeException;
    protected abstract Node getQueryId() throws DataExchangeException;
    
    /**
     * Get query ID tag name
     * @return query ID tag name
     */
    public String getQueryIdTagName() {
        return "id"; // common for all X-Road versions so far
    }
    
    // Setters for X-Road query header elements, uses element tag names
    /**
     * Set user ID to given value in SOAP header
     * @param userId X-Road header user ID value
     * @throws DataExchangeException on setting failure
     */
    public abstract void setUserId(String userId) throws DataExchangeException;
    /**
     * Set query ID to given value in SOAP header
     * @param queryId X-Road header query ID value
     * @throws DataExchangeException on setting failure
     */
    public abstract void setQueryId(String queryId) throws DataExchangeException;

    /**
     * @param content XML String to be inserted into SOAP message body
     * @throws DataExchangeException on failure
     * @throws SOAPException  on failure
     * @throws IOException  on failure
     * @throws SAXException  on failure
     * @throws ParserConfigurationException  on failure
     */
    public void setBody(String content) throws DataExchangeException, SOAPException,
        SAXException, IOException, ParserConfigurationException {
        String processedContent = content.startsWith("<?xml") ? content
            : "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + content;
        
        SOAPBody soapBody = getBody();
        DocumentBuilder documentBuilder =  DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document document = documentBuilder.parse(new InputSource(new StringReader(processedContent)));
        
        soapBody.addDocument(document);
    }
    
    /**
     * @return SOAP-ENV:Body of the request currently being built message
     * @throws DataExchangeException on body retrieval failure
     * @throws SOAPException on body retrieval failure
     */
    public SOAPBody getBody() throws DataExchangeException, SOAPException {
        return soapMessage.getSOAPBody();
    }
    
    /**
     * @return SOAP-ENV:Head of the request currently being built message
     * @throws DataExchangeException
     * @throws SOAPException
     */
    protected SOAPHeader getHeader() throws DataExchangeException {
        try {
            return soapMessage.getSOAPHeader();
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_HEADER_INIT_FAILED,
                    "Error retrieving SOAP header from SOAP message", e);
        }
    }
    
    /**
     * Get the X-Road request SOAP message (with set X-Road headers)
     * @return SOAP request message
     */
    public SOAPMessage getSOAPMessage() {
        return soapMessage;
    }

    /**
     * Get the X-Road request SOAP message (with set X-Road headers)
     * @return SOAP request message
     */
    public String toString() {
        return XRoadUtil.soapMessageToString(getSOAPMessage());
    }
    
    /**
     * Get X-Road namespace (namespace of SOAP message header children)
     * @return X-Road namespace
     */
    public XMLNamespaceContainer getXRoadNamespace() {
        return xroadNamespace;
    }
    
    /**
     * Set X-Road request SOAP element. If missing, add element, if exists, overwrite value
     * @param tagName SOAP header field tag name
     * @param value value SOAP header field tag to be set
     * @return {@link SOAPElement} that was changed
     * @throws DataExchangeException on setting failure
     */
    protected SOAPElement setUniqueField(SOAPElement parentElement, String tagName, String value,
        XMLNamespaceContainer ns) throws DataExchangeException {
        // contains removing functionality so that if value is null, then remove respective element
        try {
            Element element = XMLUtil.getElementByLocalTagName(parentElement, tagName);
            if (value == null && element == null) return null;
            else if (value == null && element != null) {
                element.getParentNode().removeChild(element);
            } else if (element == null) {
                element = parentElement.addChildElement(tagName, ns.getPrefix(), ns.getUri());
                
            }
            element.setTextContent(value);
            return (SOAPElement)element;
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_HEADER_INIT_FAILED,
                    "Error setting child to X-Road v6 element "
                    + parentElement.getTagName() + ": " + tagName + "->" + value, e);
        }
    }
    
    /**
     * Set X-Road request SOAP header field by tag name
     * @param tagName SOAP header field tag name
     * @param value value SOAP header field tag to be set
     * @param namespaceContainer element namespace with prefix
     * @return {@link SOAPElement} that was changed
     * @throws DataExchangeException on failure setting header field
     */
    public SOAPElement setHeaderField(String tagName, String value, XMLNamespaceContainer namespaceContainer)
        throws DataExchangeException {
        return setUniqueField(getHeader(), tagName, value, namespaceContainer);
    }
    
    /**
     * Set header field value by element tag name
     * @param tagName header element XML tag name
     * @param value element text content
     * @return element that was set
     * @throws DataExchangeException on setting failure
     */
    public SOAPElement setHeaderField(String tagName, String value) throws DataExchangeException {
        return setUniqueField(getHeader(), tagName, value, getXRoadNamespace());
    }
    
    /**
     * Retrieves a header element with given name (finds first match with given tag name)
     * @param name SOAP header XML element tag name
     * @param namespaceContainer element namespace with prefix
     * @return {@link SOAPElement} for a header field
     * @throws DataExchangeException on retrieval failure
     */
    protected Node getHeaderField(String name, XMLNamespaceContainer namespaceContainer) throws DataExchangeException {
        SOAPHeader soapHeader = getHeader();
        NodeList nodes = soapHeader.getElementsByTagName(namespaceContainer.getPrefix() + ":" + name);
        if (nodes.getLength() > 0) return nodes.item(0);
        return null;
    }
    protected Node getHeaderField(String name) throws DataExchangeException {
        return getHeaderField(name, getXRoadNamespace());
    }
    
    /**
     * Get field value (null safe) from SOAP message header
     * @param tag XML node that can be null
     * @return element text content or null if element is null
     */
    public String getFieldValue(Node tag) {
        try {
            return tag.getTextContent();
        } catch (NullPointerException e) {
            return null;
        }
    }

    /**
     * Get query ID value from SOAP message header
     * @return query id value
     * @throws DataExchangeException on failure
     */
    public String getQueryIdValue() throws DataExchangeException {
        return getFieldValue(getQueryId());
    }

    /**
     * @return user ID value from SOAP message header
     * @throws DataExchangeException on failure
     */
    public String getUserIdValue() throws DataExchangeException {
        return getFieldValue(getUserId());
    }
    
    /**
     * @return service element summary
     * @throws DataExchangeException on service summary failure
     */
    public abstract String getServiceSummary() throws DataExchangeException;

    /**
     * @return true if service is defined in X-Road SOAP message header
     * @throws DataExchangeException on service info retrieval failure
     */
    public abstract boolean hasService() throws DataExchangeException;
    
}
