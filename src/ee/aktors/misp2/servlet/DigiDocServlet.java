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

package ee.aktors.misp2.servlet;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.bouncycastle.util.encoders.Base64;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import ee.aktors.misp2.ExternallyConfigured;
import ee.aktors.misp2.util.MimeMessageParser;

/**
 * Servlet, mis parsib request-is tuleva XML-i ja DigiDoc-i puhul parsib seda ja saadab failis oleva sisu. Kui sisendina
 * tuleb tavaline XML, siis seda lihtsalt saadetakse tagasi. Hetkel kasutatakse ainult e-tervise TSK teenuste puhul
 */
public class DigiDocServlet extends HttpServlet implements ExternallyConfigured {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LogManager.getLogger(DigiDocServlet.class);
    private static final String MIME_TYPE_TEXT_DDOC = "text/ddoc";
    private static final String MIME_TYPE_TEXT_BDOC = "application/vnd.etsi.asic-e+zip";
    private static final String BDOC = "BDOC";
    private static final String DDOC = "DDOC";
    private static final String DDOC_DATAFILE_ELEMENT_NAME = "DataFile";
    private static final String CONTENT_TYPE_TEXT_XML = "text/xml; charset=UTF-8";

    /**
     * @see HttpServlet#HttpServlet()
     */
    public DigiDocServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.reset();
        try {
            String mimeMessage = IOUtils.toString(request.getInputStream(), "UTF-8").trim();
            MimeMessageParser mimeParser = new MimeMessageParser(mimeMessage);
            String contentType = mimeParser.getContentType();
            boolean isDdoc = contentType.contains(MIME_TYPE_TEXT_DDOC);
            boolean isBdoc = contentType.contains(MIME_TYPE_TEXT_BDOC);
            LOGGER.debug("contentType: " + contentType);
            if (contentType != null && (isDdoc || isBdoc)) {
                if (isBdoc) {
                    LOGGER.debug("Extracting data file from bdoc/zip");
                    ZipInputStream zipStream = new ZipInputStream(mimeParser.getContentStream());
                    ZipEntry entry;
                    BufferedOutputStream output = new BufferedOutputStream(response.getOutputStream());
                    response.setContentType(CONTENT_TYPE_TEXT_XML);
                    while ((entry = zipStream.getNextEntry()) != null) {
                        // find first xml file (not in META-INF folder)
                        if (entry.getName().contains(".xml") && !entry.getName().contains("META-INF/")) {
                            LOGGER.debug("Found xml data file " + entry.getName());
                            int len;
                            byte[] buffer = new byte[10000];
                            while ((len = zipStream.read(buffer, 0, buffer.length)) > 0) {
                                output.write(buffer, 0, len);
                            }
                            break;
                        }
                    }
                    output.close();
                } else {
                    LOGGER.debug("Extract data file from ddoc");
                    DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
                    DocumentBuilder builder = domFactory.newDocumentBuilder();
                    InputSource s = new InputSource(mimeParser.getContentStream());
                    Document doc = builder.parse(s);
                    NodeList nodes = doc.getElementsByTagName(DDOC_DATAFILE_ELEMENT_NAME);
                    if (nodes.getLength() > 0) {
                        LOGGER.debug("DataFile found from ddoc");
                        BufferedOutputStream output = new BufferedOutputStream(response.getOutputStream());
                        response.setContentType(CONTENT_TYPE_TEXT_XML);
                        output.write(Base64.decode(nodes.item(0).getTextContent()));
                        output.close();
                    } else {
                        LOGGER.error("No DataFile found from ddoc!");
                    }
                }
            } else {
                // just echo xml back
                LOGGER.debug("simple xml");
                response.setContentType(contentType);
                IOUtils.copy(mimeParser.getContentStream(), response.getOutputStream());
            }
            String responseContentType = request.getParameter("contentType");
            if (responseContentType != null) {
                response.setContentType(responseContentType);
                LOGGER.debug("Setting extracted document content type to " + responseContentType);
            }
            String responseContentDisposition = request.getParameter("contentDisposition");
            if (responseContentDisposition != null) {
                response.setHeader("Content-Disposition", responseContentDisposition);
                LOGGER.debug("Setting extracted document disposition to " + responseContentDisposition);
            }
        } catch (IOException e) {
            LogManager.getLogger(DigiDocServlet.class).error("Cannot echo the message (IOException)");
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
