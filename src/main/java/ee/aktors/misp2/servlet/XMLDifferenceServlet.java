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

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.util.XMLDiffMerge;
import ee.aktors.misp2.util.XMLUtil;

/**
 *
 */
public class XMLDifferenceServlet extends HttpServlet {

    private static final int BASE_START = 6;
    private static final int MODIFIED_10 = 10;
    private static final long serialVersionUID = 1L;
    private static Logger logger = LogManager.getLogger(XMLDifferenceServlet.class);

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException,
            IOException {
        response.reset();
        try {
            BufferedReader bfr = new BufferedReader(new InputStreamReader(request.getInputStream(), "UTF-8"));
            String line;
            StringBuilder sb = new StringBuilder();
            while ((line = bfr.readLine()) != null) {
                sb.append(line);
            }
            bfr.close();

            int baseStartPos = sb.indexOf("<base>");
            int baseEndPos = sb.indexOf("</base>");

            logger.trace(sb.toString());
            String baseXML = sb.substring(baseStartPos + BASE_START, baseEndPos).toString();
            String baseXMLUnescaped = StringEscapeUtils.unescapeXml(baseXML);
            String changedXML = sb.substring(sb.indexOf("<modified>", baseEndPos) + MODIFIED_10,
                    sb.indexOf("</modified>", baseEndPos)).toString();
            String changedXMLUnescaped = StringEscapeUtils.unescapeXml(changedXML);
            XMLDiffMerge xmlMerge = new XMLDiffMerge(new ByteArrayInputStream(baseXMLUnescaped.getBytes("UTF-8")),
                    new ByteArrayInputStream(changedXMLUnescaped.getBytes("UTF-8")));
            sb = null;
            response.setContentType("text/xml");
            OutputStreamWriter fw = new OutputStreamWriter(response.getOutputStream(), "UTF-8");
            Transformer transformer = XMLUtil.getTransformerFactory().newTransformer();
            transformer.transform(new DOMSource(xmlMerge.getDifferenceDocument().getDocumentElement()),
                    new StreamResult(fw));
            fw.flush();
            fw.close();
        } catch (Exception e) {
            LogManager.getLogger(getClass()).error(e.getMessage(), e);
            response.setContentType("text/xml");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
