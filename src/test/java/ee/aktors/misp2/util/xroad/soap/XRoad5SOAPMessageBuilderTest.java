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
 * Check if XRoad5SOAPMessageBuilder helper methods enable altering header
 * fields check if XRoad5SOAPMessageBuilder can be initialized from SOAPMessage.
 * 
 * @author sander.kallo
 *
 */
public class XRoad5SOAPMessageBuilderTest {
    protected static Logger log = LogManager.getLogger(XRoad5SOAPMessageBuilderTest.class);

    /**
     * Test setting and removing X-Road v5 header elements
     * @throws DataExchangeException on error
     */
    @Test
    public void testElementAccess() throws DataExchangeException {
        XRoad5SOAPMessageBuilder builder = new XRoad5SOAPMessageBuilder(Const.XROAD_VERSION.V5.getDefaultNamespace());
        String soapMessageStr;

        // add header parameters
        builder.setService("testService");
        builder.setConsumer("testConsumer");
        builder.setQueryId("testQueryId");
        builder.setUserId("testUserId");
        builder.setProducer("testProducer");
        builder.setUnit("testUnit");
        soapMessageStr = XRoadUtil.soapMessageToString(builder.getSOAPMessage());
        log.trace(soapMessageStr);
        assertTrue(soapMessageStr.contains(Const.XROAD_VERSION.V5.getDefaultNamespace()));
        assertTrue(soapMessageStr.contains("<xrd:service>testService</xrd:service>"));
        assertTrue(soapMessageStr.contains("<xrd:consumer>testConsumer</xrd:consumer>"));
        assertTrue(soapMessageStr.contains("<xrd:producer>testProducer</xrd:producer>"));
        assertTrue(soapMessageStr.contains("<xrd:userId>testUserId</xrd:userId>"));
        assertTrue(soapMessageStr.contains("<xrd:id>testQueryId</xrd:id>"));
        assertTrue(soapMessageStr.contains("<xrd:unit>testUnit</xrd:unit>"));

        // delete fields
        builder.setService(null);
        builder.setConsumer(null);
        builder.setQueryId(null);
        builder.setUserId(null);
        builder.setProducer(null);
        builder.setUnit(null);

        soapMessageStr = XRoadUtil.soapMessageToString(builder.getSOAPMessage());

        assertFalse(soapMessageStr.contains("<xrd:service>"));
        assertFalse(soapMessageStr.contains("<xrd:consumer>"));
        assertFalse(soapMessageStr.contains("<xrd:producer>"));
        assertFalse(soapMessageStr.contains("<xrd:userId>"));
        assertFalse(soapMessageStr.contains("<xrd:id>"));
        assertFalse(soapMessageStr.contains("<xrd:unit>"));

    }

    /**
     * Initializing builder from existing SOAP-message: this scenario is used in
     * mediator servlet
     * 
     * @throws Exception on error
     */
    @Test
    public void testBuildingFromExistingSOAPMessage() throws Exception {
        String soapMessageStr =
                  "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" "
                + "xmlns:xrd=\"http://x-road.ee/xsd/x-road.xsd\">"
                + "<SOAP-ENV:Header><xrd:service>testService</xrd:service><xrd:consumer>testConsumer</xrd:consumer>"
                + "<xrd:id>testQueryId</xrd:id><xrd:userId>testUserIdHere</xrd:userId>"
                + "<xrd:producer>testProducer</xrd:producer></SOAP-ENV:Header><SOAP-ENV:Body/></SOAP-ENV:Envelope>";

        Document doc = XMLUtil.convertXMLToDocument(soapMessageStr);
        SOAPMessage soapMessage = XRoadUtil.convertNodeToSOAPMessage(doc, doc.getDocumentElement());

        XRoad5SOAPMessageBuilder builder = new XRoad5SOAPMessageBuilder(soapMessage);

        assertEquals("Header X-Road namespace was read correctly", builder.getXRoadNamespace().getUri(),
                Const.XROAD_VERSION.V5.getDefaultNamespace());
        assertEquals("X-Road user ID from header was read correctly", builder.getUserIdValue(), "testUserIdHere");
        log.trace(soapMessageStr);

    }

}
