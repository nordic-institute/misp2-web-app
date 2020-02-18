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

package ee.aktors.misp2.util.xroad.soap.query.meta;

import java.io.IOException;
import java.io.InputStream;
import java.util.Iterator;

import javax.xml.soap.AttachmentPart;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Document;

import ee.aktors.misp2.action.exception.QueryException;
import ee.aktors.misp2.model.Classifier;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.wsdl.WsdlContainer;
import ee.aktors.misp2.util.xroad.soap.wsdl.XRoadV6WsdlUrlBuilder;

/**
 * Request service WSDL from security server.
 * 
 * @author sander.kallo
 */
public class WsdlQuery extends AbstractMisp2MetaQuery {

    private static Logger logger = LogManager.getLogger(WsdlQuery.class);
    /* Input parameter container for SOAP request; also serves as URL generator for V5 */
    private XRoadV6WsdlUrlBuilder wsdlUrlBuilder;
    /* Output WSDL document container, filled after sendRequest completes. */
    WsdlContainer wsdlContainer;

    /**
     * Constructor
     * 
     * @param wsdlUrlBuilder container for X-road service information for the WSDL query
     * @throws DataExchangeException on failure
     */
    public WsdlQuery(XRoadV6WsdlUrlBuilder wsdlUrlBuilder) throws DataExchangeException {
        super();
        this.wsdlUrlBuilder = wsdlUrlBuilder;
        wsdlContainer = null;
    }
    
    @Override
    public String getServiceXRoadInstance() {
        return wsdlUrlBuilder.getXroadInstance();
    }

    @Override
    public String getServiceMemberClass() {
        return wsdlUrlBuilder.getMemberClass();
    }

    @Override
    public String getServiceMemberCode() {
        return wsdlUrlBuilder.getMemberCode();
    }

    @Override
    public String getServiceSubsystemCode() {
        return wsdlUrlBuilder.getSubsystemCode();
    }

    @Override
    public String getServiceCode() {
        return "getWsdl";
    }

    @Override
    public String getServiceVersion() {
        return null;
    }

    @Override
    protected void initSOAPRequestBody() throws DataExchangeException {
        logger.debug("Initializing getWsdl request.");
        try {
            if (isV6()) {
                logger.debug("Initializing getWsdl SOAP request.");
                SOAPBody soapBody = soapRequestBuilder.getBody();
    
                String prefix = soapRequestBuilder.getXRoadNamespace().getPrefix();
                String uri = soapRequestBuilder.getXRoadNamespace().getUri();
                SOAPElement rootElement = soapBody.addChildElement(getServiceCode(), prefix, uri);
                rootElement.addChildElement("serviceCode", prefix, uri)
                    .addTextNode(wsdlUrlBuilder.getServiceCode());
                String serviceVersion = wsdlUrlBuilder.getServiceVersion();
                if (serviceVersion != null && !serviceVersion.isEmpty()) {
                    rootElement.addChildElement("serviceVersion", prefix, uri)
                        .addTextNode(wsdlUrlBuilder.getServiceVersion());
                }
            }
            // else do not initialize SOAP query, GET URL is used instead
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_BODY_INIT_FAILED,
                    "X-Road request SOAP body could not be initialized.", e);
        }
    }

    @Override
    public void sendRequest() throws DataExchangeException {
        Document wsdlDoc = null;
        String wsdlUrl = null;
        if (isV6()) { // X-Road v6: get WSDL by SOAP query
            logger.debug("X-Road v6 WSDL: retrieve using SOAP query."
                    + " NOT using direct GET URL " + wsdlUrlBuilder.toString());
            super.sendRequest();
            int attachmentCount = soapResponse.countAttachments();
            if (attachmentCount == 0) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_SOAP_RESPONSE_FAULT,
                        "Did not receive any attachments with SOAP response. Could not read WSDL.",
                        null);
            } else if (attachmentCount > 1) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_SOAP_RESPONSE_FAULT,
                        String.format("One attachment expected, %d received. Could not read WSDL.", attachmentCount),
                        null);
            }
            Iterator<?> itAttachments = soapResponse.getAttachments();
            while (itAttachments.hasNext()) {
                AttachmentPart attachment = (AttachmentPart) itAttachments.next();
                try {
                    InputStream wsdlStream = attachment.getDataHandler().getInputStream();
                    wsdlDoc = XRoadUtil.wsdlToDocument(wsdlStream, attachment.getDataHandler().getName());
                    break; // only parse the first attachment
                } catch (IOException | SOAPException | QueryException e) {
                    throw new DataExchangeException(
                            DataExchangeException.Type.XROAD_SOAP_RESPONSE_FAULT,
                            "Reading WSDL from SOAP message attachment failed.", e);
                }
            }
        } else { // X-Road v5 (or below): get WSDL from URL
            wsdlUrl = wsdlUrlBuilder.toString();
            logger.debug("X-Road v5 WSDL: retrieve from HTTP GET URL " + wsdlUrl);
            try {
                wsdlDoc = XRoadUtil.readValidWsdlAsDocument(wsdlUrlBuilder.toString());
            } catch (QueryException e) {
                throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_MESSAGE_SENDING_FAILED,
                        "Sending X-Road SOAP message failed", e);
            }
        }
        if (wsdlDoc != null) {
            wsdlContainer = new WsdlContainer(wsdlDoc, wsdlUrl);
        }
    }

    @Override
    public boolean hasResponse() {
        return wsdlContainer != null;
    }

    /**
     * @return response WSDL
     */
    public WsdlContainer getWsdlContainer() {
        return wsdlContainer;
    }

    /**
     * Download WSDL for given X-road service from security server
     * @param portal service portal entity
     * @param producer service producer entity
     * @param query service query entity
     * @return container with WSDL as W3C Document object and GET URL if that exists
     * @throws DataExchangeException on error
     */
    public static WsdlContainer downloadWsdl(Portal portal, Producer producer, Query query)
            throws DataExchangeException {
        XRoadV6WsdlUrlBuilder urlBuilder = new XRoadV6WsdlUrlBuilder()
                .setSecurityHost(portal.getSecurityHost())
                .setXroadProtocolVer(portal.getXroadProtocolVer())
                .setXroadInstance(producer.getXroadInstance())
                .setMemberClass(producer.getMemberClass())
                .setMemberCode(producer.getShortName())
                .setSubsystemCode(producer.getSubsystemCode())
                .setServiceCode(query.getServiceCode())
                .setServiceVersion(query.getServiceVersion());
        return downloadWsdl(urlBuilder);
    }

    /**
     * Download WSDL for given X-road service from security server using its
     * classifier entity information
     * @param portal service portal entity
     * @param classifier service classifier entity
     * @return container with WSDL as W3C Document object and GET URL if that exists
     * @throws DataExchangeException on error
     */
    public static WsdlContainer downloadWsdl(Portal portal, Classifier classifier)
            throws DataExchangeException {
        // use portal security server, X-Road version and X-Road instance, take the rest of the data from classifier
        XRoadV6WsdlUrlBuilder urlBuilder = new XRoadV6WsdlUrlBuilder()
                .setSecurityHost(portal.getSecurityHost())
                .setXroadProtocolVer(portal.getXroadProtocolVer())
                .setXroadInstance(classifier.getXroadQueryXroadInstance())
                .setMemberClass(classifier.getXroadQueryMemberClass())
                .setMemberCode(classifier.getXroadQueryMemberCode())
                .setSubsystemCode(classifier.getXroadQuerySubsystemCode())
                .setServiceCode(classifier.getXroadQueryServiceCode())
                .setServiceVersion(classifier.getXroadQueryServiceVersion());
        return downloadWsdl(urlBuilder);
    }

    private static WsdlContainer downloadWsdl(XRoadV6WsdlUrlBuilder urlBuilder)
            throws DataExchangeException {
        // use portal security server, X-Road version and X-Road instance, take the rest of the data from classifier
        WsdlQuery wsdlQuery = new WsdlQuery(urlBuilder);
        wsdlQuery.createSOAPRequest();
        wsdlQuery.sendRequest();
        WsdlContainer wsdlContainer = wsdlQuery.getWsdlContainer();
        return wsdlContainer;
    }
}
