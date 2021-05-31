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
 * Check if XRoad6SOAPMessageBuilder helper methods enable altering header
 * fields check if XRoad6SOAPMessageBuilder can be initialized from SOAPMessage.
 * 
 * @author sander.kallo
 *
 */
public class XRoad6SOAPMessageBuilderTest {
    protected static Logger log = LogManager.getLogger(XRoad6SOAPMessageBuilderTest.class);

    /**
     * Test populating and emptying xrd:service element
     * @throws DataExchangeException on failure
     */
    @Test
    public void testServiceElementAccess() throws DataExchangeException {
        XRoad6SOAPMessageBuilder builder =
                new XRoad6SOAPMessageBuilder(Const.XROAD_VERSION.V6.getDefaultNamespace());
        String soapMessageStr;

        // add header parameters
        builder.setServiceXRoadInstance("testXRoadInstance");
        builder.setServiceMemberClass("testMemberClass");
        builder.setServiceMemberCode("testMemberCode");
        builder.setServiceSubsystemCode("testSubsystemCode");
        builder.setServiceCode("testServiceCode");
        builder.setServiceVersion("testServiceVersion");
        soapMessageStr = XRoadUtil.soapMessageToString(builder.getSOAPMessage());
        log.trace(soapMessageStr);
        assertTrue(soapMessageStr.contains(
                "<xrd:service iden:objectType=\"SERVICE\">"
                + "<iden:xRoadInstance>testXRoadInstance</iden:xRoadInstance>"));
        assertTrue(soapMessageStr.contains("<iden:memberClass>testMemberClass</iden:memberClass>"));
        assertTrue(soapMessageStr.contains("<iden:memberCode>testMemberCode</iden:memberCode>"));
        assertTrue(soapMessageStr.contains("<iden:subsystemCode>testSubsystemCode</iden:subsystemCode>"));

        assertTrue(soapMessageStr.contains("<iden:serviceCode>testServiceCode</iden:serviceCode>"));
        assertTrue(soapMessageStr.contains("<iden:serviceVersion>testServiceVersion</iden:serviceVersion>"));

        // delete fields
        builder.setServiceXRoadInstance(null);
        builder.setServiceMemberClass(null);
        builder.setServiceMemberCode(null);
        builder.setServiceSubsystemCode(null);
        builder.setServiceCode(null);
        builder.setServiceVersion(null);

        soapMessageStr = XRoadUtil.soapMessageToString(builder.getSOAPMessage());

        assertFalse(soapMessageStr.contains("<iden:xRoadInstance>"));
        assertFalse(soapMessageStr.contains("<iden:memberClass>"));
        assertFalse(soapMessageStr.contains("<iden:memberCode>"));
        assertFalse(soapMessageStr.contains("<iden:subsystemCode>"));

        assertFalse(soapMessageStr.contains("<iden:serviceCode>"));
        assertFalse(soapMessageStr.contains("<iden:serviceVersion>"));

    }

    /**
     * Test populating and emptying xrd:client element
     * @throws DataExchangeException on failure
     */
    @Test
    public void testClientElementAccess() throws DataExchangeException {
        XRoad6SOAPMessageBuilder builder = new XRoad6SOAPMessageBuilder(Const.XROAD_VERSION.V6.getDefaultNamespace());
        String soapMessageStr;

        // add header parameters
        builder.setClientXRoadInstance("testXRoadInstance");
        builder.setClientMemberClass("testMemberClass");
        builder.setClientMemberCode("testMemberCode");
        builder.setClientSubsystemCode("testSubsystemCode");

        soapMessageStr = XRoadUtil.soapMessageToString(builder.getSOAPMessage());
        log.trace(soapMessageStr);
        assertTrue(soapMessageStr.contains(
                "<xrd:client iden:objectType=\"SUBSYSTEM\"><iden:xRoadInstance>testXRoadInstance</iden:xRoadInstance>"));
        assertTrue(soapMessageStr.contains("<iden:memberClass>testMemberClass</iden:memberClass>"));
        assertTrue(soapMessageStr.contains("<iden:memberCode>testMemberCode</iden:memberCode>"));
        assertTrue(soapMessageStr.contains("<iden:subsystemCode>testSubsystemCode</iden:subsystemCode>"));

        // delete fields
        builder.setClientXRoadInstance(null);
        builder.setClientMemberClass(null);
        builder.setClientMemberCode(null);
        builder.setClientSubsystemCode(null);

        soapMessageStr = XRoadUtil.soapMessageToString(builder.getSOAPMessage());

        assertFalse(soapMessageStr.contains("<iden:xRoadInstance>"));
        assertFalse(soapMessageStr.contains("<iden:memberClass>"));
        assertFalse(soapMessageStr.contains("<iden:memberCode>"));
        assertFalse(soapMessageStr.contains("<iden:subsystemCode>"));

    }

    /**
     * Test populating and emptying repr:representedParty element
     * @throws DataExchangeException on failure
     */
    @Test
    public void testRepresentedPartyElementAccess() throws DataExchangeException {
        XRoad6SOAPMessageBuilder builder = new XRoad6SOAPMessageBuilder(Const.XROAD_VERSION.V6.getDefaultNamespace());
        String soapMessageStr;

        // add header parameters
        builder.setRepresentedPartyClass("testPartyClass");
        builder.setRepresentedPartyCode("testPartyCode");

        soapMessageStr = XRoadUtil.soapMessageToString(builder.getSOAPMessage());
        log.trace(soapMessageStr);
        assertTrue(soapMessageStr.contains("<repr:partyClass>testPartyClass</repr:partyClass>"));
        assertTrue(soapMessageStr.contains("<repr:partyCode>testPartyCode</repr:partyCode>"));

        // delete fields
        builder.setRepresentedPartyClass(null);
        builder.setRepresentedPartyCode(null);

        soapMessageStr = XRoadUtil.soapMessageToString(builder.getSOAPMessage());

        assertFalse(soapMessageStr.contains("<repr:partyClass>"));
        assertFalse(soapMessageStr.contains("<repr:partyCode>"));

    }

    /**
     * Test accessing other X-Road v6 header elements
     * @throws DataExchangeException on failure
     */
    @Test
    public void testAccessToRootElements() throws DataExchangeException {
        XRoad6SOAPMessageBuilder builder = new XRoad6SOAPMessageBuilder(Const.XROAD_VERSION.V6.getDefaultNamespace());
        String soapMessageStr;

        // add header parameters
        builder.setUserId("testUserId");
        builder.setQueryId("testQueryId");

        soapMessageStr = XRoadUtil.soapMessageToString(builder.getSOAPMessage());
        log.trace(soapMessageStr);

        // this is inserted automatically
        assertTrue(soapMessageStr.contains("<SOAP-ENV:Header><xrd:protocolVersion>4.0</xrd:protocolVersion"));

        assertTrue(soapMessageStr.contains("<xrd:id>testQueryId</xrd:id>"));
        assertTrue(soapMessageStr.contains("<xrd:userId>testUserId</xrd:userId>"));

        // delete fields
        builder.setUserId(null);
        builder.setQueryId(null);

        soapMessageStr = XRoadUtil.soapMessageToString(builder.getSOAPMessage());

        assertFalse(soapMessageStr.contains("<xrd:id>"));
        assertFalse(soapMessageStr.contains("<xrd:userId>"));

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
                "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" "
                + "  xmlns:iden=\"http://x-road.eu/xsd/identifiers\" "
                + "  xmlns:xrd=\"http://x-road.eu/xsd/xroad.xsd\">"
                + "<SOAP-ENV:Header><xrd:protocolVersion>4.0</xrd:protocolVersion>"
                + "<xrd:userId>testUserIdHere</xrd:userId>"
                + "</SOAP-ENV:Header><SOAP-ENV:Body/></SOAP-ENV:Envelope>";

        Document doc = XMLUtil.convertXMLToDocument(soapMessageStr);
        SOAPMessage soapMessage = XRoadUtil.convertNodeToSOAPMessage(doc, doc.getDocumentElement());

        XRoad6SOAPMessageBuilder builder = new XRoad6SOAPMessageBuilder(soapMessage);

        assertEquals("Header X-Road namespace was read correctly", builder.getXRoadNamespace().getUri(),
                Const.XROAD_VERSION.V6.getDefaultNamespace());
        assertEquals("X-Road user ID from header was read correctly",
                builder.getUserIdValue(), "testUserIdHere");
        log.debug(soapMessageStr);

    }

}
