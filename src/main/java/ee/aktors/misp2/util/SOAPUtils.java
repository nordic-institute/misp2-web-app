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

package ee.aktors.misp2.util;

import javax.xml.bind.DatatypeConverter;
import javax.xml.namespace.QName;
import javax.xml.soap.AttachmentPart;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.MimeHeaders;
import javax.xml.soap.Name;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPConnection;
import javax.xml.soap.SOAPConnectionFactory;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPMessage;
import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import java.io.ByteArrayOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;
import java.math.BigInteger;
import java.net.URL;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * SOAP utils
 */
public class SOAPUtils {
    private static final int MSG_TRUNCATE_LENGTH = 10000;
    private static final Logger LOGGER = LogManager.getLogger(SOAPUtils.class);
    private static MessageFactory factory;
    private static SOAPConnection connection;
    private SOAPMessage soapRequest;
    private SOAPMessage soapResponse;
    private String serviceName = "";
    private String userId = "";

    /**
     * Initiates message factory and connection
     */
    public SOAPUtils() {
        try {
            factory = MessageFactory.newInstance();
            SOAPConnectionFactory soapConnectionFactory = SOAPConnectionFactory.newInstance();
            connection = soapConnectionFactory.createConnection();
        } catch (Exception e) {
            LOGGER.debug(e.getStackTrace(), e);
        }
    }

    /**
     * Initializes values, sets factory and connection to null
     * @param soapRequest soapRequest to set
     * @param userId userId to set
     * @param serviceName serviceName to set
     */
    public SOAPUtils(SOAPMessage soapRequest, String userId, String serviceName) {
        // message is ready, no factory needed
        factory = null;
        connection = null;
        this.soapRequest = soapRequest;
        this.userId = userId;
        this.serviceName = serviceName;
    }

    /**
     * @param headers message headers
     * @param in input stream for message
     * @return generated soap message
     * @throws IOException if there is a problem in reading data from the input stream
     * @throws SOAPException may be thrown if the message is invalid
     */
    public SOAPMessage createSOAPMessageFromStream(MimeHeaders headers, InputStream in) throws IOException,
            SOAPException {
        soapRequest = factory.createMessage(headers, in);
        return processSOAPRequestAttachments();
    }

    /**
     * @return processed SOAP message
     * @throws IOException If an I/O error occurs
     * @throws SOAPException If the SOAP Body does not exist or cannot be retrieved
     */
    public SOAPMessage processSOAPRequestAttachments() throws IOException, SOAPException {
        SOAPBody body = soapRequest.getSOAPBody();
        for (SOAPElement element : elements(body.getElementsByTagName("*"))) {
            checkElementForAttachments(element);
        }
        return soapRequest;
    }

    /**
     * @param soapRequestIn soap request to make
     * @param endpoint where to make request from
     * @return response to request
     * @throws SOAPException  if there is a SOAP error
     */
    public SOAPMessage sendSOAPMessage(SOAPMessage soapRequestIn, URL endpoint) throws SOAPException {
        logSOAPMessage(soapRequestIn, "SOAPUtils request");
        soapResponse = connection.call(soapRequestIn, endpoint);
        logSOAPMessage(soapResponse, "SOAPUtils response");
        return soapResponse;
    }

    /**
     * @return soap response
     * @throws SOAPException if the SOAP Header does not exist or cannot be retrieved
     */
    public SOAPMessage processSOAPResponse() throws SOAPException {
        Iterator<?> it = soapResponse.getSOAPHeader().examineAllHeaderElements();
        while (it.hasNext()) {
            SOAPElement el = (SOAPElement) it.next();
            String headerName = el.getNodeName();
            if (headerName.equals("xrd:service") || headerName.equals("xtee:nimi")) {
                serviceName = el.getTextContent();
                if (serviceName != null)
                    serviceName = serviceName.trim();
            } else if (headerName.equals("xrd:userId") || headerName.equals("xtee:isikukood")) {
                userId = el.getTextContent();
                if (userId != null)
                    userId = userId.trim();
            }
        }
        processSOAPAttachments();
        return soapResponse;
    }

    private void checkElementForAttachments(SOAPElement element) throws IOException,
            SOAPException {
        boolean hasHrefAttribute = false;
        boolean hasHexBinaryAttribute = false;
        Iterator<?> attrs = element.getAllAttributes();
        while (attrs.hasNext()) {
            Name attrName = (Name) attrs.next();
            LOGGER.debug(attrName.getQualifiedName());
            if (attrName.getQualifiedName().equals("href")) {
                hasHrefAttribute = true;
                break;
            } else if (attrName.getQualifiedName().equals("hexBinaryFileType")) {
                hasHexBinaryAttribute = true;
                break;
            }
        }
        if (hasHrefAttribute) {
            LOGGER.debug("has href attribute");
            LOGGER.trace(element.getTextContent());
            String content = element.getTextContent();
            String mediatype = element.getAttribute("mediatype");
            AttachmentPart att;

            // has to be base64 content
            assert content.matches("^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$");
            if (mediatype == null || mediatype.isEmpty())
                mediatype = "application/octet-stream";
            att = soapRequest.createAttachmentPart(DatatypeConverter.parseBase64Binary(content), mediatype);

            soapRequest.addAttachmentPart(att);
            att.setContentId(UUID.randomUUID().toString());
            element.getAttributeNode("href").setValue(att.getContentId());
            element.setTextContent("");
        } else if (hasHexBinaryAttribute) {
            LOGGER.debug("has hexBinary attribute");
            String fileLocation = element.getTextContent().replace("file:", "");
            String mediaType = StringUtils.substring(fileLocation,
                    fileLocation.indexOf("mediatype") + "mediatype".length() + 1, fileLocation.indexOf("size") - 1);
            mediaType = URLDecoder.decode(mediaType, "UTF-8");
            String filePath = StringUtils.substring(fileLocation, 0, fileLocation.indexOf("?"));
            LOGGER.debug("read as hexBinary from file: " + filePath);
            Reader r = new FileReader(filePath);
            String hexContent = toHex(IOUtils.toByteArray(r, StandardCharsets.UTF_8));
            LOGGER.trace(hexContent);
            r.close();
            if (element.getAttribute("attachmentInSoapBody") != null
                    && element.getAttribute("attachmentInSoapBody").equals("true")) {
                LOGGER.debug("setting hexBinary in SOAPBody");
                element.setTextContent(hexContent);
            } else {
                LOGGER.debug("setting hexBinary as attachment");
                AttachmentPart att = soapRequest.createAttachmentPart(hexContent, mediaType);
                soapRequest.addAttachmentPart(att);
                att.setContentId(UUID.randomUUID().toString());
                element.addAttribute(new QName("href"), att.getContentId());
                element.setTextContent("");
            }
            element.removeAttribute("hexBinaryFileType");
        }
    }

    /**
     * @throws SOAPException if there is no content set into this AttachmentPart object or
     * if there was a data transformation error.
     */
    public void processSOAPAttachments() throws SOAPException {
        // if message has attachments -> represent them as binary and remove
        Iterator<?> attachments = soapResponse.getAttachments();
        List<SOAPElement> elementsWithAttachments = new ArrayList<>();
        while (attachments.hasNext()) {
            AttachmentPart attachment = (AttachmentPart) attachments.next();
            String[] contentDisposition = attachment.getMimeHeader(Const.CONTENT_DISPOSITION);
            String contentDispositionFileName = null;
            if (contentDisposition != null && contentDisposition.length > 0) {
                contentDispositionFileName = contentDisposition[0];
                if (contentDispositionFileName != null) {
                    Pattern filenamePattern = Pattern.compile("filename\\s*=\\s*\"?([^\";]+)");
                    Matcher m = filenamePattern.matcher(contentDispositionFileName);
                    while (m.find()) {
                        contentDispositionFileName = m.group(1);
                        LOGGER.debug("Content-Disposition filename: " + contentDispositionFileName);
                    }
                }
            }
            String contentId = attachment.getContentId(); // Content-ID pattern: urn:uuid:$UUID>;
            byte[] rawBytes = attachment.getRawContentBytes();
            int attachmentSizeInBytes = rawBytes.length;
            String base64Content = Base64.encodeBase64String(rawBytes);
            for (SOAPElement xmlElement : elements(soapResponse.getSOAPBody().getElementsByTagName("*"))) {
                // if element has already an attachment given, continue
                if (elementsWithAttachments.contains(xmlElement))
                    continue;
                boolean hasMTOM = xmlElement.getPrefix() != null
                        && xmlElement.getPrefix().equalsIgnoreCase("XOP");
                if (hasMTOM) {
                    SOAPElement fileElement = xmlElement.getParentElement();
                    addFileAttributesToElement(fileElement, contentDispositionFileName, attachmentSizeInBytes);
                    xmlElement.detachNode();
                    fileElement.addTextNode(base64Content);
                    LOGGER.debug("Extracted MTOM attachment: " + fileElement.getAttribute("filename"));
                    elementsWithAttachments.add(xmlElement);
                    break;
                } else {
                    String href = xmlElement.getAttribute("href");
                    if (StringUtils.isNotEmpty(href)
                            && StringUtils.substringBefore(href, ":").equalsIgnoreCase("CID")) {
                        href = StringUtils.substringAfter(href, ":");
                    }
                    boolean idAndHrefMissing = StringUtils.isEmpty(contentId) && StringUtils.isEmpty(href);
                    boolean hrefInId = StringUtils.isNotEmpty(contentId) && StringUtils.isNotEmpty(href)
                            && contentId.contains(href);
                    if ( idAndHrefMissing || hrefInId ) { // href attribute value pattern: urn:uuid:$UUID;
                        addFileAttributesToElement(xmlElement, contentDispositionFileName, attachmentSizeInBytes);
                        xmlElement.addTextNode(base64Content);
                        LOGGER.debug("Extracted SwA attachment: " + xmlElement.getAttribute("filename"));
                        elementsWithAttachments.add(xmlElement);
                        if (xmlElement.hasAttribute("href"))
                            xmlElement.removeAttribute("href");
                        break;
                    }
                }
            }

        }
        soapResponse.removeAllAttachments();
    }

    /**
     * Add filename and size base64 element attributes
     * 
     * @param fileElement file
     * @param contentDispositionFileName file name from Content-Disposition field
     * @param fileSize number of bytes
     */
    private void addFileAttributesToElement(SOAPElement fileElement,
            String contentDispositionFileName, Integer fileSize) {
        if (fileSize != null) {
            fileElement.setAttribute("size", "" + fileSize);
        }

        Node nextSiblingNode = fileElement.getNextSibling();
        SOAPElement nextSibling = null;
        if (nextSiblingNode instanceof Element) {
            nextSibling = (SOAPElement) nextSiblingNode;
        }

        boolean addAttribute = true;
        String fileName;
        // content disposition takes priority
        if (contentDispositionFileName != null) {
            fileName = contentDispositionFileName;
        // if filename attribute is there, that is used to be the file name
        } else if (fileElement.hasAttribute("filename")) {
            fileName = fileElement.getAttribute("filename");
            addAttribute = false;
        // if next element is called filename then this is used
        } else if (nextSibling != null && nextSibling.getLocalName().equals("filename")) {
            fileName = nextSibling.getTextContent();
            nextSibling.detachNode();
        // default file name is used based on service name and userid
        } else if (serviceName != null && userId != null) {
            fileName = serviceName + "-" + userId;
        // in case userId and serviceName were not found
        } else {
            fileName = "";
        }

        if (addAttribute) {
            fileElement.setAttribute("filename", fileName);
        }

    }

    private List<SOAPElement> elements(NodeList nodes) {
        List<SOAPElement> result = new ArrayList<>(nodes.getLength());
        for (int i = 0; i < nodes.getLength(); i++) {
            Node node = nodes.item(i);
            if (node instanceof SOAPElement) {
                result.add((SOAPElement) node);
            }
        }
        return result;
    }

    /**
     * @param message message to log
     */
    public static void logSOAPMessage(SOAPMessage message) {
        logSOAPMessage(message, "Logging SOAP Message");
    }

    /**
     * @param message message to log
     * @param description description in log
     */
    public static void logSOAPMessage(SOAPMessage message, String description) {
        Logger soapLogger = LogManager.getLogger("SOAP");
        boolean writeToSoaplog = soapLogger.isInfoEnabled();
        boolean writeToCatalina = LOGGER.isDebugEnabled();
        if (writeToCatalina || writeToSoaplog) {
            try {
                ByteArrayOutputStream bout = new ByteArrayOutputStream();
                message.writeTo(bout);
                String msg = bout.toString(StandardCharsets.UTF_8.name());
                
                if (writeToSoaplog) {
                    LOGGER.trace("Writing SOAP message to SOAP log.");
                    soapLogger.info(":: " + description + " ::\n" + msg);
                }
                
                if (writeToCatalina) {
                    String msgTruncated;
                    if (msg.length() > MSG_TRUNCATE_LENGTH) {
                        msgTruncated = msg.substring(0, MSG_TRUNCATE_LENGTH) + "\n[output truncated]...";
                    } else {
                        msgTruncated = msg;
                    }
                    LOGGER.debug(":: " + description + " :: " + msgTruncated);
                }
            } catch (Exception e) {
                LOGGER.error("Logging SOAP message failed", e);
                e.printStackTrace();
            }
        }
    }

    private String toHex(byte[] text) {
        return String.format("%x", new BigInteger(1, text));
    }

    /**
     * @param soapResponseIn soapResponse to set
     */
    public void setSOAPResponse(SOAPMessage soapResponseIn) {
        this.soapResponse = soapResponseIn;
    }
}
