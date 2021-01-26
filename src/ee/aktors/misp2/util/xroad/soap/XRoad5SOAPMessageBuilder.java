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

import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPMessage;
import javax.xml.soap.SOAPPart;

import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * X-Road version 5 soap message builder
 * @author sander.kallo
 */
public class XRoad5SOAPMessageBuilder extends CommonXRoadVer4And5SOAPMessageBuilder {

    /**
     * Create X-Road 5 SOAP message builder from namespace URI argument
     * @param xroadNamespaceSuffix  SOAP header X-Road namespace URI
     * @throws DataExchangeException when builder initialization fails
     */
    public XRoad5SOAPMessageBuilder(String xroadNamespaceSuffix) throws DataExchangeException {
        super(new XMLNamespaceContainer("xrd", xroadNamespaceSuffix));
        SOAPPart soapPart = soapMessage.getSOAPPart();
        try {
            SOAPEnvelope envelope = soapPart.getEnvelope();
            envelope.addNamespaceDeclaration(getXRoadNamespace().getPrefix(), getXRoadNamespace().getUri());
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_MESSAGE_BUILDER_INIT_FAILED,
                    "Error initializing XRoad5SOAPMessageBuilder ", e);
        }
    }

    /**
     * Create X-Road 5 SOAP message builder from existing SOAP message
     * @param soapMessage existing X-Road v5 SOAP request message
     * @throws DataExchangeException when initialization fails
     */
    public XRoad5SOAPMessageBuilder(SOAPMessage soapMessage) throws DataExchangeException {
        super(soapMessage);
    }

    @Override
    protected String getConsumerTagName() {
        return "consumer";
    }

    @Override
    protected String getProducerTagName() {
        return "producer";
    }

    @Override
    protected String getUserIdTagName() {
        return "userId";
    }

    /**
     * Parameter does not exist in X-Road schema
     */
    @Override
    protected String getUserTagName() {
        return null;
    }

    public static final String SERVICE_TAG_NAME = "service";
    @Override
    protected String getServiceTagName() {
        return SERVICE_TAG_NAME;
    }

    @Override
    protected String getIssueTagName() {
        return "issue";
    }

    @Override
    protected String getUnitTagName() {
        return "unit";
    }

    @Override
    protected String getPositionTagName() {
        return "position";
    }

    @Override
    protected String getAuthenticatorTagName() {
        return "authenticator";
    }

    @Override
    protected String getUserNameTagName() {
        return "userName";
    }

    @Override
    protected String getAsyncTagName() {
        return "async";
    }

    @Override
    protected String getEncodeTagName() {
        return "encode";
    }
    
}
