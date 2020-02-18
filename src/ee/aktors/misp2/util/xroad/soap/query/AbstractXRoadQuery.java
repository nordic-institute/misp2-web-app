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

package ee.aktors.misp2.util.xroad.soap.query;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Date;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLSession;
import javax.xml.namespace.QName;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.SOAPConnection;
import javax.xml.soap.SOAPConnectionFactory;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPMessage;

import org.apache.commons.lang.exception.ExceptionUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.SOAPUtils;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.CommonXRoadSOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad4SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad5SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad6SOAPMessageBuilder;

/**
 * Functionality for X-Road query. Should be extended by a specific X-Road service
 * class that implements specific input-output messages
 * 
 * @author sander.kallo
 *
 */
public abstract class AbstractXRoadQuery {
    private static Logger log = LogManager.getLogger(AbstractXRoadQuery.class);

    protected Date soapRequestSent;
    protected Date soapResponseReceived;

    protected CommonXRoadSOAPMessageBuilder soapRequestBuilder;
    protected SOAPMessage soapResponse;

    protected String securityServerUrl;
    protected SOAPMessage dummyResponse;

    // protected String soapRequestString;
    // protected String soapResponseString;

    protected AbstractXRoadQuery(CommonXRoadSOAPMessageBuilder soapRequestBuilder) {
        this.soapRequestBuilder = soapRequestBuilder;
        soapRequestSent = null;

        soapResponse = null;
        soapResponseReceived = null;

        securityServerUrl = null;
        dummyResponse = null;

        // soapRequestString = null;
        // soapResponseString = null;

    }

    /**
     * Sends X-Road SOAP request. Response can be accessed with
     * #getSoapResponse() Assumes soapRequestBuilder has been initialized and
     * filled with SOAP header and body data. In case dummy response is set,
     * does not perform actual SOAP query. Instead sets dummyResponse as
     * soapResponse.
     * 
     * @throws DataExchangeException on send failure
     */
    public void sendRequest() throws DataExchangeException {
        SOAPConnection soapConnection = null;

        try {
            if (dummyResponse == null) {
                // Create SOAP Connection
                SOAPConnectionFactory soapConnectionFactory = SOAPConnectionFactory.newInstance();
                soapConnection = soapConnectionFactory.createConnection();

                SOAPMessage requestMessage = soapRequestBuilder.getSOAPMessage();
                // soapRequestString =
                // XRoadUtil.soapMessageToString(requestMessage);
                // log.debug("Message sent through security server " +
                // securityServerUrl + " to XRoad: \n" + soapRequestString);

                // Send SOAP Message to SOAP Server
                String serviceIdentifier = soapRequestBuilder.getServiceSummary();
                SOAPUtils.logSOAPMessage(requestMessage, "X-Road SOAP request for '" + serviceIdentifier + "'");

                URL endpoint = getEndpointUrl();
                if (isV4() && endpoint.getProtocol().toUpperCase().equals("HTTPS")) {
                    HttpsURLConnection.setDefaultHostnameVerifier(new NullHostnameVerifier());
                }
                soapRequestSent = new Date();

                soapResponse = soapConnection.call(soapRequestBuilder.getSOAPMessage(), endpoint);
                soapResponseReceived = new Date();
                log.info("X-Road query took: " + (soapResponseReceived.getTime() - soapRequestSent.getTime()) + " ms");

                SOAPUtils.logSOAPMessage(soapResponse, "X-Road SOAP response for '" + serviceIdentifier + "'");
                // soapResponseString =
                // XRoadUtil.soapMessageToString(soapResponse);
                // log.debug("Message received from XRoad: \n" +
                // soapResponseString);

                checkFault();
            } else {
                soapRequestSent = new Date();

                soapResponse = dummyResponse;

                soapResponseReceived = new Date();
                // if(soapResponse != null){
                // soapResponseString =
                // XRoadUtil.soapMessageToString(soapResponse);
                // }
            }
        } catch (SOAPException | MalformedURLException e) {
            // if exception has a cause (or is itself) of type SocketTimeoutException
            if (ExceptionUtils.indexOfThrowable(e, java.net.SocketTimeoutException.class) != -1) {
                // then throw timeout exception
                throw new DataExchangeException(DataExchangeException.Type.TIMEOUT,
                        "Sending X-Road SOAP message timed out", e);
            } else {
                throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_MESSAGE_SENDING_FAILED,
                        "Sending X-Road SOAP message failed", e);
            }
        } finally {
            try {
                if (soapConnection != null)
                    soapConnection.close();
            } catch (SOAPException e) {
                throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_CONNECTION_CLOSING_FAILED,
                        "Closing X-Road SOAP connection failed", e);
            }
        }
    }

    protected URL getEndpointUrl() throws MalformedURLException, DataExchangeException {
        return new URL(getSecurityServerUrl());
    }

    protected boolean isV4() {
        return soapRequestBuilder instanceof XRoad4SOAPMessageBuilder;
    }

    protected boolean isV5() {
        return soapRequestBuilder instanceof XRoad5SOAPMessageBuilder;
    }

    protected boolean isV6() {
        return soapRequestBuilder instanceof XRoad6SOAPMessageBuilder;
    }

    private static class NullHostnameVerifier implements HostnameVerifier {
        public boolean verify(String hostname, SSLSession session) {
            return true;
        }
    }

    /**
     * Override to add fault checks
     * 
     * @throws DataExchangeException
     */
    protected void checkFault() throws DataExchangeException {
        XRoadUtil.checkFault(soapResponse);
    }

    /**
     * @return X-Road SOAP response message
     */
    public SOAPMessage getSoapResponse() {
        return soapResponse;
    }

    /**
     * @return dummy response (to be only used in testing)
     */
    public SOAPMessage getDummyResponse() {
        return dummyResponse;
    }

    /**
     * Set dummy SOAP answer so that actual SOAP request is not sent, but dummy
     * response is returned instead. This can be used for testing.
     * 
     * @param dummyResponseStr
     *            SOAP dummy answer String to be returned
     * @throws DataExchangeException on failure
     */
    public void setDummyResponse(String dummyResponseStr) throws DataExchangeException {
        InputStream is = new ByteArrayInputStream(dummyResponseStr.getBytes(StandardCharsets.UTF_8));
        setDummyResponse(is);

    }

    /**
     * If {@link #dummyResponseStream} is not null, do not perform SOAP query in
     * {@link #sendRequest()}, return #dummyResponse instead. Can be used for
     * unit tests, for instance testing SOAP binding without actually connecting
     * to security server and needing aptusCache object to be initialized.
     * 
     * @param dummyResponseStream SOAP dummy answer String to be returned
     * @throws DataExchangeException on response setting failure
     */
    public void setDummyResponse(InputStream dummyResponseStream) throws DataExchangeException {
        // MessageFactory.newInstance(SOAPConstants.SOAP_1_2_PROTOCOL).createMessage(new
        // MimeHeaders(), is);
        try {
            dummyResponse = MessageFactory.newInstance().createMessage(null, dummyResponseStream);
        } catch (IOException | SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_DUMMY_RESPONSE_COULD_NOT_BE_SET,
                    "Setting X-Road dummy response message failed", e);
        }
    }

    /**
     * Initialize X-Road SOAP message header and body. Both require implementations in child-classes.
     * @throws DataExchangeException on SOAP request creation failure
     */
    public void createSOAPRequest() throws DataExchangeException {
        if (soapRequestBuilder == null) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_MESSAGE_BUILDER_INIT_FAILED,
                    "X-Road SOAP builder not initialized. "
                    + "soapRequestBuilder must be initialized before createSOAPRequest()",
                    null);
        }
        if (dummyResponse == null)
            initSOAPRequestHeader();
        initSOAPRequestBody();
    }

    /**
     * Set SOAP request builder.
     * @param builder SOAP request builder (can be any implementation)
     */
    public void setSOAPRequestBuilder(CommonXRoadSOAPMessageBuilder builder) {
        soapRequestBuilder = builder;
    }

    protected abstract void initSOAPRequestHeader() throws DataExchangeException;

    protected QName getRequestQName() {
        QName requestName;
        if (isV4()) {
            requestName = new QName(Const.SOAP_REQUEST_ELEMENT_OLD);
        } else {
            requestName = new QName(Const.SOAP_REQUEST_ELEMENT);
        }
        return requestName;
    }

    /**
     * Fills X-Road soap message body
     * 
     * @throws DataExchangeException
     */
    protected abstract void initSOAPRequestBody() throws DataExchangeException;

    /**
     * @return request target URL (security server proxy URL)
     */
    public String getSecurityServerUrl() {
        return securityServerUrl;
    }

    /**
     * Set request target URL (security server proxy URL)
     * @param url target URL
     */
    public void setSecurityServerUrl(String url) {
        this.securityServerUrl = url;
    }

    /**
     * @return SOAP request message builder
     */
    public CommonXRoadSOAPMessageBuilder getSOAPRequestBuilder() {
        return soapRequestBuilder;
    }

    /**
     * @return X-Road query ID from current request message
     * @throws DataExchangeException on retrieval failure
     */
    public String getXRoadMessageId() throws DataExchangeException {
        if (this.getSOAPRequestBuilder() == null)
            return null;
        return this.getSOAPRequestBuilder().getQueryIdValue();
    }
    /**
     * @return true if X-Road response has been received
     */
    public boolean hasResponse() {
        return soapResponse != null;
    }
}
