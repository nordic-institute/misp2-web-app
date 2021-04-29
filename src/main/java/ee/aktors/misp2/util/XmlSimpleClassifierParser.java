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

import ee.aktors.misp2.beans.ListClassifierItem;
import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author arnis.rips
 */
public class XmlSimpleClassifierParser {
    private static final Logger LOGGER = LogManager.getLogger(XmlSimpleClassifierParser.class.getName());
    private String item;
    private String firstParam;
    private String secondParam;

    /**
     * Initializes class
     * @param item item to set
     * @param firstParam firstParam to set
     * @param secondParam secondParam to set
     */
    public XmlSimpleClassifierParser(String item, String firstParam, String secondParam) {
        this.item = item;
        this.firstParam = firstParam;
        this.secondParam = secondParam;
    }

    /**
     * Parses simple xml with structure:
     * <pre>
     * {@code
     *  <root>
     *      <item>
     *          <firstParam>text <\/firstParam>
     *          <secondParam>text<\/secondParam>
     *      <\/item>
     *  <\/root>
     * }
     * </pre>
     * 
     * @param xml xml to parse
     * @param maxChars max chars of first and second param tags
     * @return list of type ListClassifierItem objects representing given xml structure
     */
    public List<ListClassifierItem> parseXml(String xml, Integer maxChars) {
        if (xml == null) {
            throw new IllegalArgumentException("Xml is null");
        }
        List<ListClassifierItem> classifierItems = new ArrayList<>();
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            dbf.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD, "");
            dbf.setAttribute(XMLConstants.ACCESS_EXTERNAL_SCHEMA, "");
            DocumentBuilder db = dbf.newDocumentBuilder();
            Document doc = db.parse(new InputSource(new StringReader(xml)));

            Element rootEl = doc.getDocumentElement();
            NodeList items = rootEl.getElementsByTagName(item);
            for (int i = 0; i < items.getLength(); i++) {
                Node node = items.item(i);

                if (node.getNodeType() == Node.ELEMENT_NODE) {
                    Element it = (Element) node;
                    Node fp = it.getElementsByTagName(firstParam).item(0); // only one for this level
                    Node sp = it.getElementsByTagName(secondParam).item(0); // only one for this level
                    String fpstr = fp.getTextContent();
                    String spstr = sp.getTextContent();
                    if (maxChars != null) {
                        if (maxChars <= fpstr.trim().length()) {
                            fpstr = fpstr.substring(0, maxChars).concat("...");
                        }
                        if (maxChars <= spstr.trim().length()) {
                            spstr = spstr.substring(0, maxChars).concat("...");
                        }
                    }
                    classifierItems.add(new ListClassifierItem(fpstr, spstr));
                }
            }
        } catch (SAXException | IOException | ParserConfigurationException ex) {
            LOGGER.error(ex.getMessage(), ex);
        }
        return classifierItems;
    }

    /**
     * @param xml xml to parse
     * @return list of classifier items
     */
    public List<ListClassifierItem> parseXml(String xml) {
        return parseXml(xml, null);
    }

}
