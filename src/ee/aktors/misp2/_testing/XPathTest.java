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

package ee.aktors.misp2._testing;

import java.io.File;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.io.FileUtils;
import org.apache.logging.log4j.LogManager;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

/**
 *
 * @author arnis.rips
 */
public final class XPathTest {
    
    private XPathTest() {     }

    private static XPath xpath = XPathFactory.newInstance().newXPath();
    private static String xml = "<Body>" + "    <paringesindusResponse>" + "        <keha>"
            + "            <ettevotjad>" + "                <item>"
            + "                    <ariregistri_kood>11893857</ariregistri_kood>"
            + "                    <arinimi>RIA Teine Testimine OÜ</arinimi>"
            + "                    <staatus>R</staatus>" + "                    <isikud>"
            + "                        <item>"
            + "                            <fyysilise_isiku_kood>37007160274</fyysilise_isiku_kood>"
            + "                            <ainuesindusoigus_olemas>EI TEA</ainuesindusoigus_olemas>"
            + "                        </item>" + "                        <item>"
            + "                            <fyysilise_isiku_kood>370dsf7160274</fyysilise_isiku_kood>"
            + "                            <ainuesindusoigus_olemas>EIs TEA</ainuesindusoigus_olemas>"
            + "                        </item>" + "                    </isikud>" + "                </item>"
            + "            <item>" + "                    <ariregistri_kood>1189385s7</ariregistri_kood>"
            + "                    <arinimi>RIA Teine Testimine OÜ</arinimi>"
            + "                    <staatus>R</staatus>" + "                    <isikud>"
            + "                        <item>"
            + "                            <fyysilise_isiku_kood>37007160274</fyysilise_isiku_kood>"
            + "                            <ainuesindusoigus_olemas>EIas TEA</ainuesindusoigus_olemas>"
            + "                        </item>" + "                        <item>"
            + "                            <fyysilise_isiku_kood>370dsf7160274</fyysilise_isiku_kood>"
            + "                            <ainuesindusoigus_olemas>EI TEA</ainuesindusoigus_olemas>"
            + "                        </item>" + "                    </isikud>" + "                </item>"
            + "            </ettevotjad>" + "        </keha>" + "    </paringesindusResponse>" + "</Body>";

    /**
     * @param args command line args
     * @throws Exception can trhrow
     */
    public static void main(String[] args) throws Exception {
        DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
        domFactory.setNamespaceAware(true);
        DocumentBuilder builder = domFactory.newDocumentBuilder();
        InputSource s = new InputSource(FileUtils.openInputStream(new File("C:\\xpath\\xml.xml")));

        Document doc = builder.parse(s);

        // NodeList evaluate = (NodeList)
        // xpath.evaluate("Body/paringesindusResponse/keha/ettevotjad/
        //                   item[ariregistri_kood='1189385s7']/isikud/item[fyysilise_isiku_kood='370dsf7160274']",
        // doc, XPathConstants.NODESET);
        NodeList evaluate = (NodeList) xpath.evaluate("//response/item[unitCode!='456456']", doc,
                XPathConstants.NODESET);
        LogManager.getLogger(XPathTest.class).debug("items found = " + evaluate.getLength()); //REMOVE - evaluate

        for (int i = 0; i < evaluate.getLength(); i++) {
            Node node = evaluate.item(i);
//            String str =
                    xpath.evaluate("power", node);
            LogManager.getLogger(XPathTest.class).debug("str = " + node.getTextContent()); //REMOVE - str
        }
        // String str = xpath.evaluate("ainuesindusoigus_olemas", evaluate);
        // LogManager.getLogger(this.getClass()).debug("str = " + str); //REMOVE - str
    }

}
