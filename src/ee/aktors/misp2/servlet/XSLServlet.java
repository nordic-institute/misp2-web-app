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

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.ExternallyConfigured;
import ee.aktors.misp2.saxon.SaxonNodeSet;
import ee.aktors.misp2.util.FileUtil;
import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.XslUriResolver;
import net.sf.saxon.TransformerFactoryImpl;

/**
 * xsl servlet
 */
public class XSLServlet extends HttpServlet implements ExternallyConfigured {

    private static final long serialVersionUID = 1L;
    private static Logger logger = LogManager.getLogger(XSLServlet.class);

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException,
            IOException {
        response.reset();
        try {
            String xslRootPath = CONFIG.getString("etsa.xsl.path");

            String xslFilePath = request.getParameter("xsl");
            if (xslFilePath == null)
                xslFilePath = "main.xsl"; // default to main.xsl

            File xslFile = new File(xslRootPath, xslFilePath);
            if (!xslFile.exists()) {
                throw new IOException("XSL file deos not exist. XSL root: " + xslRootPath + "| XSL file: "
                        + xslFilePath);
            }
            if (!FileUtil.isParent(new File(xslRootPath), xslFile)) {
                throw new IOException("XSL file must be located within XSL root folder: " + xslRootPath
                        + "| XSL file: " + xslFilePath);
            }
            logger.info("Performing XSL transformation with " + xslFile.getAbsolutePath());
            InputStreamReader in = new InputStreamReader(new FileInputStream(xslFile), "UTF-8");
            TransformerFactory tFactory = XMLUtil.getTransformerFactory();
            // add node-set extension that etsa xsls use
            ((TransformerFactoryImpl) tFactory).getConfiguration().registerExtensionFunction(new SaxonNodeSet());

            tFactory.setURIResolver(new XslUriResolver(xslRootPath));
            Transformer transformer = tFactory.newTransformer(new javax.xml.transform.stream.StreamSource(in));
            StringWriter writer = new StringWriter();
            transformer.transform(new javax.xml.transform.stream.StreamSource(request.getInputStream()),
                    new StreamResult(writer));
            String htmlResult = writer.toString();
            File html = File.createTempFile("tmp", ".doc");

            FileUtils.write(html, htmlResult);
            htmlResult = StringEscapeUtils.escapeXml(htmlResult);
            String xmlResult = "<root><element>" + htmlResult + "</element></root>";
            // send response as xml
            response.setContentType("text/xml");
            response.getOutputStream().write(xmlResult.getBytes("UTF-8"));
        } catch (Exception e) {
            LogManager.getLogger(getClass()).error(e.getMessage(), e);
            String htmlErrorResult = "<html><head></head><body><h5>Viga faili töötlemisel</h5></body></html>";
            htmlErrorResult = StringEscapeUtils.escapeXml(htmlErrorResult);
            String xmlErrorResult = "<root><element>" + htmlErrorResult + "</element></root>";
            // send response error message as xml
            response.setContentType("text/xml");
            // response.setCharacterEncoding("UTF-8");
            response.getOutputStream().write(xmlErrorResult.getBytes("UTF-8"));
        }
    }
}
