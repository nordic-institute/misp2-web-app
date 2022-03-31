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

package ee.aktors.misp2.servlet.mediator;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.MimeHeader;
import javax.xml.soap.MimeHeaders;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPMessage;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.QueryLog;
import ee.aktors.misp2.service.QueryLogService;
import ee.aktors.misp2.service.QueryLogService.LogQueryInput;
import ee.aktors.misp2.service.XroadInstanceService;
import ee.aktors.misp2.util.SOAPUtils;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.identifier.XRoad5ClientIdentifierData;
import ee.aktors.misp2.util.xroad.soap.identifier.XRoad6ClientIdentifierData;
import ee.aktors.misp2.util.xroad.soap.CommonXRoadSOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.CommonXRoadVer4And5SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad4SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad5SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad6SOAPMessageBuilder;

/**
 * Wrapper around {@link InputStream} in (client request input stream). Used by
 * {@link ee.aktors.misp2.servlet.MediatorServlet} to process user X-Road SOAP
 * request before sending it to security server.
 * <p>
 * Reads in InputStream, converts it to SOAP message, fills (or overrides)
 * client and user SOAP headers, logs SOAP message to database and processes
 * SOAP request attachments to prepare the message.
 * <p>
 * Processed SOAP message is then converted back to input stream in order to
 * prepare it for HTTP post.
 * 
 * @author sander.kallo
 */
public class MediatorRequestInputStream extends InputStream {

    private final Logger logger = LogManager.getLogger(MediatorRequestInputStream.class);

    private InputStream in;
    private SOAPMessage soapMessage;

    private Portal sessionPortal;
    private Org sessionOrg;
    private Person sessionUser;
    private HttpServletRequest request;

    private QueryLog queryLog;
    CommonXRoadSOAPMessageBuilder soapMessageBuilder;
    private SOAPUtils soapAttachmentProcessor;

    private XroadInstanceService xroadInstanceService;
    
    private String mainServiceHumanReadableName;
    private String mainServiceFullIdentifier;
    private QueryLogService queryLogService;


    /**
     * Initialize input stream wrapper
     * @param request incoming servlet request
     * @param sessionPortal portal associated with currently logged in user
     * @param sessionOrg org associated with current user
     * @param sessionUser current user
     * @param processAttachments if true, attachments are extracted and added to SOAPMessages,
     *        otherwise the processing is skipped
     * @param xroadInstanceService X-Road instance service to check if request X-Road instance is allowed
     * @param queryLogProperties item container for logging query
     * @throws DataExchangeException on request stream initialization failure
     */
    public MediatorRequestInputStream(HttpServletRequest request, Portal sessionPortal, Org sessionOrg,
            Person sessionUser, boolean processAttachments,
            XroadInstanceService xroadInstanceService,
            QueryLogProperties queryLogProperties)
                    throws DataExchangeException {
        logger.info("Initializing MediatorInputStream");
        this.sessionPortal = sessionPortal;
        this.sessionOrg = sessionOrg;
        this.sessionUser = sessionUser;
        this.request = request;

        this.xroadInstanceService = xroadInstanceService;
        
        this.mainServiceHumanReadableName = queryLogProperties.getMainServiceHumanReadableName();
        this.mainServiceFullIdentifier = queryLogProperties.getMainServiceFullIdentifier();
        this.queryLogService = queryLogProperties.getQueryLogService();

        this.in = null;
        this.soapMessageBuilder = null;
        this.queryLog = null;
        this.soapAttachmentProcessor = null;
        try {
            // create SOAP message,
            // assume incoming message always has Content-Type text/xml,
            // because Orbeon is not capable of sending MIME multipart SOAP
            // messages
            MimeHeaders hdrs = new MimeHeaders();
            // defaultContentType always assumed to be incoming content type
            //  (because Orbeon only sends XML to security server)
            hdrs.addHeader("Content-Type", MediatorServlet.CONTENT_TYPE_TEXT_XML);
            soapMessage = MessageFactory.newInstance().createMessage(hdrs, request.getInputStream());
        } catch (IOException | SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_MEDIATOR_SOAP_REQUEST_COULD_NOT_BE_READ,
                    "Failed to parse input stream to SOAPMessage", e);
        }
        // alter SOAP message headers
        alterSoapMessage();

        // if required, extract attachments from SOAP body BASE64 elements and
        // add them as MIME multipart attachments
        if (processAttachments) {
            // create attachments from BASE64 elements
            logger.debug("Attachment filter active for current request");
            this.soapAttachmentProcessor = new SOAPUtils(soapMessage, soapMessageBuilder.getQueryIdValue(),
                    soapMessageBuilder.getUserIdValue());
            try {
                this.soapAttachmentProcessor.processSOAPRequestAttachments();
            } catch (SOAPException | IOException e) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_MEDIATOR_SOAP_REQUEST_ATTACHMENT_PROCESSING_FAILED,
                        "Failed to process client request SOAPMessage attachments for forwarding", e);
            }
        }

        // create SOAP message query log
        logRequest();

        // convert SOAP message back to input stream
        flushSoapMessage();

        // log SOAP message
        SOAPUtils.logSOAPMessage(soapMessage, "Mediator servlet request");
    }

    /**
     * @return SOAPUtils instance
     */
    public SOAPUtils getSoapAttachmentProcessor() {
        return soapAttachmentProcessor;
    }

    /**
     * Fill SOAP request message client header fields with portal-specific data
     * 
     * @throws DataExchangeException
     */
    private CommonXRoadSOAPMessageBuilder alterSoapMessage() throws DataExchangeException {
        // builder is a wrapper around soapMessage
        soapMessageBuilder = null;
        soapMessageBuilder = XRoadUtil.getXRoadSOAPMessageBuilder(soapMessage, sessionPortal.isV6());

        if (soapMessageBuilder instanceof XRoad6SOAPMessageBuilder) {
            logger.debug("Mediating X-Road v6 message");
            XRoad6SOAPMessageBuilder soapMessageBuilderV6 = (XRoad6SOAPMessageBuilder) soapMessageBuilder;
            XRoad6ClientIdentifierData clientData = new XRoad6ClientIdentifierData(sessionPortal, sessionOrg);
            soapMessageBuilderV6.setClientMemberClass(clientData.getClientMemberClass());
            soapMessageBuilderV6.setClientMemberCode(clientData.getClientMemberCode());
            soapMessageBuilderV6.setClientSubsystemCode(clientData.getClientSubsystemCode());
            soapMessageBuilderV6.setClientXRoadInstance(clientData.getXRoadInstance());
            //soapMessageBuilderV6.setServiceXRoadInstance(sessionPortal.getXroadInstance());
            if (clientData.hasRepresentedParty()) {
                logger.debug("Setting X-Road v6 message representedParty(unit) to: " + clientData.getRepresentedPartyClass() + ":"
                        + clientData.getRepresentedPartyCode());
                soapMessageBuilderV6.setRepresentedPartyClass(clientData.getRepresentedPartyClass());
                soapMessageBuilderV6.setRepresentedPartyCode(clientData.getRepresentedPartyCode());
            } else {
                // remove X-Road v6 message representedParty(unit) if this
                // exists
                soapMessageBuilderV6.removeRepresentedParty();
            }
            
            // check if target service X-Road instance is allowed
            String requestXroadInstance = soapMessageBuilderV6.getServiceXRoadInstanceValue();
            String activeXroadInstanceCode = xroadInstanceService.getActiveXroadInstanceCode(requestXroadInstance);
            if (activeXroadInstanceCode != null) {
                soapMessageBuilderV6.setServiceXRoadInstance(activeXroadInstanceCode);
            } else { // active instance was not found
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_INSTANCE_NOT_ACTIVE_FOR_PORTAL,
                        "X-Road instance '" + requestXroadInstance
                        + "' is not active in portal '" + sessionPortal.getShortName() + "'.",
                        null, requestXroadInstance, sessionPortal.getShortName());
            }
        } else if (soapMessageBuilder instanceof CommonXRoadVer4And5SOAPMessageBuilder) {
            if (soapMessageBuilder instanceof XRoad5SOAPMessageBuilder) {
                logger.debug("Mediating X-Road v5 message");
            } else if (soapMessageBuilder instanceof XRoad4SOAPMessageBuilder) {
                logger.debug("Mediating X-Road v4 message");
            }
            CommonXRoadVer4And5SOAPMessageBuilder soapMessageBuilderV45 =
                    (CommonXRoadVer4And5SOAPMessageBuilder) soapMessageBuilder;
            XRoad5ClientIdentifierData clientData = new XRoad5ClientIdentifierData(sessionPortal, sessionOrg);

            soapMessageBuilderV45.setConsumer(clientData.getOrgCode());
            if (clientData.hasUnit()) {
                logger.debug("Setting message unit to: " + clientData.getUnitCode());
                soapMessageBuilderV45.setUnit(clientData.getUnitCode());
            } else {
                soapMessageBuilderV45.setUnit(null);
            }
        }
        soapMessageBuilder.setUserId(sessionUser.getSsn());

        return soapMessageBuilder;
    }
    /**
     * @return return query log entity
     */
    public QueryLog getQueryLog() {
        return queryLog;
    }

    private void logRequest() throws DataExchangeException {
        String consumer;
        String unit;
        String service;
        if (soapMessageBuilder instanceof XRoad6SOAPMessageBuilder) {
            XRoad6SOAPMessageBuilder xroad6MessageBuilder = (XRoad6SOAPMessageBuilder) soapMessageBuilder;
            consumer = xroad6MessageBuilder.getClientSummary();
            unit = xroad6MessageBuilder.getRepresentedPartySummary();
            service = xroad6MessageBuilder.getServiceSummary();
        } else if (soapMessageBuilder instanceof CommonXRoadVer4And5SOAPMessageBuilder) {
            CommonXRoadVer4And5SOAPMessageBuilder xroad4And5MessageBuilder =
                (CommonXRoadVer4And5SOAPMessageBuilder) soapMessageBuilder;
            consumer = xroad4And5MessageBuilder.getConsumerValue();
            unit = xroad4And5MessageBuilder.getUnitValue();
            service = xroad4And5MessageBuilder.getServiceValue();
        } else {
            throw new RuntimeException("Unknown SOAP builder " + soapMessageBuilder);
        }
        logger.debug("Logging query: " + mainServiceHumanReadableName + " " + "consumer: " + consumer + " " + "unit: "
                + unit + " " + "service: " + service + " ");
        
        LogQueryInput input = new QueryLogService.LogQueryInput();
        input.setSsn(soapMessageBuilder.getUserIdValue());
        input.setPortal(sessionPortal);
        input.setConsumer(consumer);
        input.setUnit(unit);
        input.setQueryId(soapMessageBuilder.getQueryIdValue());
        input.setMainServiceName(mainServiceFullIdentifier);
        input.setService(service);
        input.setLanguage(request.getLocale().getLanguage());
        input.setDescription(mainServiceHumanReadableName);
        input.setQueryTimeSec("" + 0);
        this.queryLog = queryLogService.logQuery(input);
    }

    /**
     * Finalize SOAP message by converting it to String and this in turn to
     * input stream
     * 
     * @throws DataExchangeException
     */
    private void flushSoapMessage() throws DataExchangeException {
        ByteArrayOutputStream out = XRoadUtil.soapMessageToByteArrayOutputStream(soapMessage);
        // logger.debug(new String(out.toByteArray(), StandardCharsets.UTF_8));
        this.in = new ByteArrayInputStream(out.toByteArray());
    }

    @Override
    public int read(byte[] b) throws IOException {
        int i = in.read(b);
        return i;
    }

    @Override
    public int read(byte[] b, int off, int len) throws IOException {
        int i = in.read(b, off, len);
        return i;
    }

    @Override
    public int read() throws IOException {
        int i = in.read();
        return i;
    }

    /**
     * Copy SOAP message headers to URL connection request properties
     * @param urlConnection URL connection
     */
    public void copyHeaders(HttpURLConnection urlConnection) {
        MimeHeaders mimeHeaders = soapMessage.getMimeHeaders();
        Iterator<?> iterator = mimeHeaders.getAllHeaders();
        while (iterator.hasNext()) {
            MimeHeader mimeHeader = (MimeHeader) iterator.next();
            urlConnection.addRequestProperty(mimeHeader.getName(), mimeHeader.getValue());
        }
    }
}
