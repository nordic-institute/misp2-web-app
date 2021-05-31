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

package ee.aktors.misp2.servlet;

import ee.aktors.misp2.util.Const;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.dom4j.DocumentException;
import org.dom4j.io.SAXReader;
import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;

/**
 * Servlet implementation class EchoServlet
 */
public class EchoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public EchoServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        response.reset();
        try {
            String responseData = readRequestData(request);
            String extension = request.getParameter("extension");
            if (extension == null || extension.isEmpty())
                extension = Const.XML;
            String contentDisposition = "attachment;filename=" + request.getParameter("service") + "." + extension;
            if (request.getContentType().contains(Const.XML)) {
                response.setHeader(Const.CONTENT_DISPOSITION, contentDisposition);
                response.setContentType(request.getContentType());
                BufferedOutputStream os = new BufferedOutputStream(response.getOutputStream());
                os.write(responseData.getBytes(StandardCharsets.UTF_8));
                os.close();
            } else {
                byte[] decoded = null;
                DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
                dbf.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD, "");
                dbf.setAttribute(XMLConstants.ACCESS_EXTERNAL_SCHEMA, "");
                DocumentBuilder db = dbf.newDocumentBuilder();
                InputSource is = new InputSource();
                is.setCharacterStream(new StringReader(responseData));
                Document doc = db.parse(is);
                NodeList sections = doc.getElementsByTagName("*");
                int numSections = sections.getLength();
                for (int i = 0; i < numSections; i++) {
                    Element section = (Element) sections.item(i);
                    Node title = section.getFirstChild();
                    if (title != null && title.getNodeType() != Node.ELEMENT_NODE) {
                        decoded = Base64.decodeBase64(title.getNodeValue());
                    }
                }
                response.setContentType(Const.MIME_OCTETSTREAM);
                response.setHeader(Const.CONTENT_DISPOSITION, contentDisposition);
                BufferedOutputStream output = new BufferedOutputStream(response.getOutputStream());
                assert decoded != null;
                output.write(decoded);
                output.close();
            }
        } catch (DocumentException | IOException | SAXException | ParserConfigurationException |
                IllegalArgumentException | DOMException e) {
            LogManager.getLogger(EchoServlet.class)
                    .error(
                            "Cannot echo the message ({})",
                            e.getClass().getSimpleName()
                    );
        }


    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        // not implemented
    }

    protected static String readRequestData(HttpServletRequest req) throws IOException, DocumentException, SAXException {
        SAXReader xmlReader = new SAXReader();
        xmlReader.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        org.dom4j.Document xmlDocument = xmlReader.read(req.getInputStream());
        return xmlDocument.asXML();
    }

}
