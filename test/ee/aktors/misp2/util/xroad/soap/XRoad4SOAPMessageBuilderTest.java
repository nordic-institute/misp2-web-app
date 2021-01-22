/*
 * The MIT License
 * Copyright (c) 2020 NIIS <info@niis.org>
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

package ee.aktors.misp2.util.xroad.soap;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import javax.xml.soap.SOAPMessage;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.junit.Test;
import org.w3c.dom.Document;

import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * Check if XRoad4SOAPMessageBuilder helper methods enable altering header
 * fields check if XRoad4SOAPMessageBuilder can be initialized from SOAPMessage.
 * 
 * @author sander.kallo
 */
public class XRoad4SOAPMessageBuilderTest {
    protected static Logger log = LogManager.getLogger(XRoad4SOAPMessageBuilderTest.class);


    /**
     * Test setting and removing X-Road v5 header elements
     * @throws DataExchangeException on error
     */
    @Test
    public void testElementAccess() throws DataExchangeException {
        XRoad4SOAPMessageBuilder builder = new XRoad4SOAPMessageBuilder(
                Const.XROAD_VERSION.V4.getDefaultNamespace());
        String soapMessageStr;

        // add header parameters
        builder.setService("testService");
        builder.setConsumer("testConsumer");
        builder.setQueryId("testQueryId");
        builder.setUserId("testUserId");
        builder.setProducer("testProducer");
        builder.setUnit("testUnit");
        soapMessageStr = XRoadUtil.soapMessageToString(builder.getSOAPMessage());
        log.debug(soapMessageStr);
        assertTrue(soapMessageStr.contains(Const.XROAD_VERSION.V4.getDefaultNamespace()));
        assertTrue(soapMessageStr.contains(">testService</xtee:nimi>"));
        assertTrue(soapMessageStr.contains(">testConsumer</xtee:asutus>"));
        assertTrue(soapMessageStr.contains(">testProducer</xtee:andmekogu>"));
        assertTrue(soapMessageStr.contains(">testUserId</xtee:isikukood>"));
        assertTrue(soapMessageStr.contains(">testQueryId</xtee:id>"));
        assertTrue(soapMessageStr.contains(">testUnit</xtee:allasutus>"));

        // delete fields
        builder.setService(null);
        builder.setConsumer(null);
        builder.setQueryId(null);
        builder.setUserId(null);
        builder.setProducer(null);
        builder.setUnit(null);

        soapMessageStr = XRoadUtil.soapMessageToString(builder.getSOAPMessage());

        assertFalse(soapMessageStr.contains("xtee:nimi>"));
        assertFalse(soapMessageStr.contains("xtee:asutus"));
        assertFalse(soapMessageStr.contains("xtee:andmekogu"));
        assertFalse(soapMessageStr.contains("xtee:isikukood"));
        assertFalse(soapMessageStr.contains("xtee:id"));
        assertFalse(soapMessageStr.contains("xtee:allasutus"));
    }

    /**
     * Initializing builder from existing SOAP-message: this scenario is used in
     * mediator servlet
     * 
     * @throws Exception on failure
     */
    @Test
    public void testBuildingFromExistingSOAPMessage() throws Exception {
        String soapMessageStr =
                  "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\""
                + " xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                + "xmlns:xtee=\"http://x-tee.riik.ee/xsd/xtee.xsd\">"
                + "    <SOAP-ENV:Header>"
                + "        <xtee:nimi xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                + "xsi:type=\"xsd:string\">testService</xtee:nimi>"
                + "        <xtee:asutus xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                + "xsi:type=\"xsd:string\">testConsumer</xtee:asutus>"
                + "        <xtee:id xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                + "xsi:type=\"xsd:string\">testQueryId</xtee:id>"
                + "        <xtee:isikukood "
                + "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                + "xsi:type=\"xsd:string\">testUserIdHere</xtee:isikukood>"
                + "        <xtee:andmekogu "
                + "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                + "xsi:type=\"xsd:string\">testProducer</xtee:andmekogu>"
                + "        <xtee:allasutus "
                + "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                + "xsi:type=\"xsd:string\">testUnit</xtee:allasutus>"
                + "    </SOAP-ENV:Header>" + "    <SOAP-ENV:Body/>" + "</SOAP-ENV:Envelope>";

        Document doc = XMLUtil.convertXMLToDocument(soapMessageStr);
        SOAPMessage soapMessage = XRoadUtil.convertNodeToSOAPMessage(doc, doc.getDocumentElement());

        XRoad4SOAPMessageBuilder builder = new XRoad4SOAPMessageBuilder(soapMessage);

        assertEquals("Header X-Road namespace was read correctly", builder.getXRoadNamespace().getUri(),
                Const.XROAD_VERSION.V4.getDefaultNamespace());
        assertEquals("X-Road user ID from header was read correctly",
                builder.getUserIdValue(), "testUserIdHere");
        log.trace(soapMessageStr);

    }

}
