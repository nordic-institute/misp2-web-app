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
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletResponse;
import javax.xml.soap.AttachmentPart;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.MimeHeaders;
import javax.xml.soap.SOAPConstants;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPFault;
import javax.xml.soap.SOAPMessage;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.model.QueryLog;
import ee.aktors.misp2.service.QueryLogService;
import ee.aktors.misp2.util.SOAPUtils;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * Wrapper around {@link InputStream} #in (client response stream).
 * <p>
 * Used by {@link ee.aktors.misp2.servlet.MediatorServlet} to process user
 * X-Road SOAP response before sending it back to client.
 * <p>
 * Reads in InputStream, converts it to SOAP message, if SOAP Fault is returned,
 * then logs error to database, extracts attachments and fills response headers.
 * <p>
 * Processed message is then converted back to InputStream in order to prepare
 * it for sending back to client.
 * 
 * @author sander.kallo
 */
public class MediatorResponseInputStream extends InputStream {
    private final Logger logger = LogManager.getLogger(MediatorResponseInputStream.class);

    private InputStream in;
    private InputStream out;
    private SOAPMessage soapMessage;
    private QueryLog queryLog;
    private long startTime;
    private HttpServletResponse response;
    private QueryLogService queryLogService;

    /**
     * Initialize stream
     * @param backendConnection connection to security server
     * @param queryLog query log entity to be filled
     * @param response HTTP response object to be returned to client
     * @param startTime time query started in milliseconds
     * @param soapAttachmentProcessor SOAPUtils instance for attachment processing,
     *        null if no attachments are processed
     * @param queryLogService service used to save queryLog entity (and create QueryErrorLog if needed)
     * @throws DataExchangeException in case of init failure
     * @throws IOException for far end (security server) response stream read failure
     */
    public MediatorResponseInputStream(HttpURLConnection backendConnection, QueryLog queryLog,
            HttpServletResponse response, long startTime, SOAPUtils soapAttachmentProcessor,
            QueryLogService queryLogService) throws DataExchangeException, IOException {
        logger.info("Initializing MediatorInputStream");
        this.copyEndpointResponseHeadersToClientResponse(backendConnection, response);
        // a byte-counter wrapper around incoming SOAP response input stream
        this.in = new ByteCounterInputStream(backendConnection.getInputStream());
        // processed SOAP response input stream, ready to be copied into client
        // response
        this.out = null;
        this.queryLog = queryLog;
        this.response = response;
        this.startTime = startTime;
        this.queryLogService = queryLogService;
        try {
            // convert response input stream to SOAP message
            // response content type is used in SOAP message creation
            // to ensure correct handling of MIME multipart messages with
            // attachments
            MimeHeaders hdrs = new MimeHeaders();
            hdrs.addHeader("Content-Type", response.getContentType());
            soapMessage = MessageFactory.newInstance().createMessage(hdrs, in);
        } catch (IOException | SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_MEDIATOR_SOAP_RESPONSE_COULD_NOT_BE_READ,
                    "Failed to parse response input stream to SOAPMessage", e);
        }
        // extract attachments from incoming response and add them to message
        // body as base64 text
        processAttachments(soapAttachmentProcessor);

        // Convert multipart messages to normal
        stripMultipartHeaders();
        
        // convert processed SOAP message back to input stream
        flushSoapMessage();
        // query time and response size are logged after flushSoapMessage(),
        // so that soapMessage is definitely read in at this point
        // query errors are logged if SOAP-Fault was found from response
        logQuery();

        // write SOAP response to log file(s)
        SOAPUtils.logSOAPMessage(soapMessage, "Mediator servlet response");
    }

    private void copyEndpointResponseHeadersToClientResponse(HttpURLConnection urlConnection,
            HttpServletResponse httpResponse) {
        // return output from security server
        // copy headers to final response
        for (String key : urlConnection.getHeaderFields().keySet()) {
            if (key == null || key.toLowerCase().equals("transfer-encoding"))
                continue;

            // copy security server response headers to HTTP response
            for (String val : urlConnection.getHeaderFields().get(key)) {
                if (val == null)
                    continue;
                if (key.toString().toLowerCase().equals("content-type")) {
                    val = val.replace("type=text/xml", "type=\"text/xml\"");
                    logger.debug("Replacing content type with " + val);
                    httpResponse.setContentType(val);
                } else if (key.toString().toLowerCase().equals("content-length")) {
                    continue;
                } else { // copy header unchanged
                    httpResponse.setHeader(key, val);
                    logger.debug("Setting " + key + " to " + val);
                }
            }
        }
    }

    private void processAttachments(SOAPUtils soapAttachmentProcessor) throws DataExchangeException {
        // if attachment processor is null, that means attachments are not
        // processed for current message
        if (soapAttachmentProcessor != null) {
            try {
                soapAttachmentProcessor.setSOAPResponse(soapMessage);
                soapAttachmentProcessor.processSOAPAttachments();
                // replace content-type since all the attachments were removed
                // in processSOAPAttachments()
                
            } catch (SOAPException | IOException e) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_MEDIATOR_SOAP_RESPONSE_ATTACHMENT_EXTRACTION_FAILED,
                        "Attachment extraction failed from SOAP response", e);
            }
            convertSoapMessageToTextXml();
        }

    }
    private void convertSoapMessageToTextXml() throws DataExchangeException {
        // warn if SOAP message contains attachments
        if (soapMessage.countAttachments() > 0) {
            Iterator<?> attachments = soapMessage.getAttachments();
            List<String> attachmentInfo = new ArrayList<String>(soapMessage.countAttachments());
            while (attachments.hasNext()) {
                AttachmentPart attachment = (AttachmentPart) attachments.next();
                attachmentInfo.add(attachment.getContentType());
            }
            logger.warn("SOAP-message has attachments " + attachmentInfo + ". Those will be removed.");
        }
        // would be better to read content type from response
        response.setContentType(MediatorServlet.CONTENT_TYPE_TEXT_XML);
        SOAPMessage mimeSoapMessage = soapMessage;
        try {
            // create new SOAPMessage to get rid of MIME-attachment-related elements
            soapMessage = MessageFactory.newInstance(SOAPConstants.SOAP_1_1_PROTOCOL).createMessage();
            soapMessage.getSOAPPart().setContent(mimeSoapMessage.getSOAPPart().getContent());
        } catch (SOAPException e) {
            throw new DataExchangeException(
                    DataExchangeException.Type.XROAD_MEDIATOR_SOAP_RESPONSE_CONVERSION_TO_TEXT_XML_FAILED,
                    "Failed to convert SOAP message to text/xml.", e);
            
        }
    }

    /**
     * If 'multipart/related; type=text/xml' message arrives,
     * convert it to normal 'text/xml' message.
     * Otherwise Orbeon would throw error 'Response is not XML'.
     * @throws DataExchangeException on SOAP processing failure
     */
    private void stripMultipartHeaders() throws DataExchangeException {
        if (soapMessage.getMimeHeaders() != null) {
            MimeHeaders mimeHeaders = soapMessage.getMimeHeaders();
            String[] contentTypes = mimeHeaders.getHeader("Content-Type");
            if (contentTypes != null && contentTypes.length > 0) {
                String contentType = contentTypes[0];
                if (contentType != null && contentType.startsWith("multipart/related")
                        && contentType.contains("text/xml")) {
                    logger.debug("Converting multipart message with content-type '"
                            + contentType + "' to 'text/xml'.");
                    convertSoapMessageToTextXml();
                }
            }
        }
    }

    private void logQuery() throws DataExchangeException {
        // logger.debug("Query size: " + counterInputStream.getCount() + "B");
        queryLog.setQuerySize("" + (double) ((ByteCounterInputStream) in).getByteCount()); // measured
                                                                                    // in
                                                                                    // B
        long endTime = new Date().getTime();
        final double kilo = 1000.0;
        queryLog.setQueryTimeSec("" + (double) (endTime - startTime) / kilo);
        logger.debug("Query took " + (endTime - startTime) + " ms");
        try {
            if (soapMessage.getSOAPBody().hasFault()) {
                SOAPFault soapFault = soapMessage.getSOAPBody().getFault();
                logger.debug(
                        "Response contained fault: " + soapFault.getFaultCode() + " " + soapFault.getFaultString());
                queryLogService.logQueryError(queryLog, soapFault.getFaultCode(), soapFault.getFaultString(),
                        soapFault.getDetail());
            } else {
                queryLog.setSuccess(true);
                queryLogService.save(queryLog);
            }
        } catch (Exception e) {
            logger.error("Failed to log query into database", e);
        }
    }

    /**
     * Finalize SOAP message by converting it to String and this in turn to
     * input stream
     * 
     * @throws DataExchangeException
     */
    private void flushSoapMessage() throws DataExchangeException {
        ByteArrayOutputStream byteArrayOutputStream = XRoadUtil.soapMessageToByteArrayOutputStream(soapMessage);
        this.out = new ByteArrayInputStream(byteArrayOutputStream.toByteArray());
    }

    @Override
    public int read(byte[] b) throws IOException {
        int i = out.read(b);
        return i;
    }

    @Override
    public int read(byte[] b, int off, int len) throws IOException {
        int i = out.read(b, off, len);
        return i;
    }

    @Override
    public int read() throws IOException {
        int i = out.read();
        return i;
    }
}
