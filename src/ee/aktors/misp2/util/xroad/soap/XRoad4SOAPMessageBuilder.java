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

package ee.aktors.misp2.util.xroad.soap;

import javax.xml.namespace.QName;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPMessage;

import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * X-Road version 4 soap message builder
 * @author sander.kallo
 *
 */
public class XRoad4SOAPMessageBuilder extends CommonXRoadVer4And5SOAPMessageBuilder {
    protected XMLNamespaceContainer xsiNamespace;
    protected XMLNamespaceContainer xsdNamespace;
    
    /**
     * Construct empty XRoad4SOAPMessageBuilder with xroadNamespaceSuffix
     * @param xroadNamespaceSuffix namespace URI of X-Road header fields
     * @throws DataExchangeException when adding namespace fails
     */
    public XRoad4SOAPMessageBuilder(String xroadNamespaceSuffix) throws DataExchangeException {
        super(new XMLNamespaceContainer("xtee", xroadNamespaceSuffix));
        xsiNamespace = new XMLNamespaceContainer("xsi", javax.xml.XMLConstants.W3C_XML_SCHEMA_INSTANCE_NS_URI);
        xsdNamespace = new XMLNamespaceContainer("xsd", javax.xml.XMLConstants.W3C_XML_SCHEMA_NS_URI);

        try {
            getXRoadNamespace().addToSOAPElement(envelope);
            xsdNamespace.addToSOAPElement(envelope);
        } catch (SOAPException e) {
            throw new DataExchangeException(
                    DataExchangeException.Type.XROAD_SOAP_MESSAGE_BUILDER_INIT_FAILED,
                    "Error initializing XRoad4SOAPMessageBuilder ", e);
        }
    }
    
    /**
     * Construct XRoad4SOAPMessageBuilder from existing SOAPMessage
     * @param soapMessage X-Road request SOAP message
     * @throws DataExchangeException on failure initializing builder
     */
    public XRoad4SOAPMessageBuilder(SOAPMessage soapMessage) throws DataExchangeException {
        super(soapMessage);
        xsiNamespace = new XMLNamespaceContainer("xsi", javax.xml.XMLConstants.W3C_XML_SCHEMA_INSTANCE_NS_URI);
        xsdNamespace = new XMLNamespaceContainer("xsd", javax.xml.XMLConstants.W3C_XML_SCHEMA_NS_URI);
    }

    @Override
    protected String getConsumerTagName() {
        return "asutus";
    }

    @Override
    protected String getProducerTagName() {
        return "andmekogu";
    }

    @Override
    protected String getUserIdTagName() {
        return "isikukood";
    }

    @Override
    protected String getUserTagName() {
        return "ametnik";
    }

    public static final String SERVICE_TAG_NAME = "nimi";
    @Override
    protected String getServiceTagName() {
        return SERVICE_TAG_NAME;
    }

    @Override
    protected String getIssueTagName() {
        return "toimik";
    }

    @Override
    protected String getUnitTagName() {
        return "allasutus";
    }

    @Override
    protected String getPositionTagName() {
        return "amet";
    }

    @Override
    protected String getAuthenticatorTagName() {
        return "autentija";
    }

    @Override
    protected String getUserNameTagName() {
        return "ametniknimi";
    }

    @Override
    protected String getAsyncTagName() {
        return "asynkroonne";
    }

    /**
     * Parameter does not exist in xtee schema
     */
    @Override
    protected String getEncodeTagName() {
        return null;
    }

    @Override
    public SOAPElement setHeaderField(String tagName, String value) throws DataExchangeException {
        
        SOAPElement headerElement = super.setHeaderField(tagName, value);
        if (headerElement != null) {
            // add String attribute to all header fields
            QName type = new QName(xsiNamespace.getUri(), "type", xsiNamespace.getPrefix());
            try {
                headerElement.addAttribute(type, "xsd:string");
            } catch (SOAPException e) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_SOAP_HEADER_INIT_FAILED,
                        "Error setting header attribute xsi:type to xsd:string", e);
            }
        }
        return headerElement;
    }

}
