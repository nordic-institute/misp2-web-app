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

package ee.aktors.misp2.util.xroad.soap.query.test;

import java.io.IOException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.soap.SOAPException;

import org.xml.sax.SAXException;

import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.query.AbstractXRoadQuery;
import ee.aktors.misp2.util.xroad.soap.CommonXRoadSOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.CommonXRoadVer4And5SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad6SOAPMessageBuilder;

/**
 * Demo X-Road query functionality. This is a helper utility for developers,
 * demonstrating how to use AbstractXRoadQuery. It assumes integration with
 * security server, thus does not belong with unit tests.
 * 
 * @author sander.kallo
 *
 */
public class TestXRoadQuery extends AbstractXRoadQuery {

    /**
     * Initialize query
     * 
     * @param soapRequestBuilder SOAP request message builder
     */
    public TestXRoadQuery(CommonXRoadSOAPMessageBuilder soapRequestBuilder) {
        super(soapRequestBuilder);

    }

    @Override
    protected void initSOAPRequestBody() throws DataExchangeException {
        try {
            soapRequestBuilder
                    .setBody("<allowedMethods xmlns=\"" + soapRequestBuilder.getXRoadNamespace().getUri() + "\"/>");
        } catch (SOAPException | SAXException | IOException | ParserConfigurationException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void initSOAPRequestHeader() throws DataExchangeException {
        soapRequestBuilder.setUserId("EE38410155213");
        soapRequestBuilder.setQueryId(XRoadUtil.getXRoadRequestId());

        if (soapRequestBuilder instanceof XRoad6SOAPMessageBuilder) {
            XRoad6SOAPMessageBuilder ver6MessageBuilder = (XRoad6SOAPMessageBuilder) soapRequestBuilder;
            String xroadInstance = "ee-dev";
            ver6MessageBuilder.setServiceXRoadInstance(xroadInstance);
            ver6MessageBuilder.setServiceMemberClass("COM");
            ver6MessageBuilder.setServiceMemberCode("11333578");
            ver6MessageBuilder.setServiceSubsystemCode("aktorstest-db01");
            ver6MessageBuilder.setServiceCode("allowedMethods");
            ver6MessageBuilder.setServiceVersion(null);

            ver6MessageBuilder.setClientXRoadInstance(xroadInstance);
            ver6MessageBuilder.setClientMemberClass("COM");
            ver6MessageBuilder.setClientMemberCode("11333578");
            ver6MessageBuilder.setClientSubsystemCode("misp2-01");

            setSecurityServerUrl("http://192.168.219.227/cgi-bin/consumer_proxy");
        } else if (soapRequestBuilder instanceof CommonXRoadVer4And5SOAPMessageBuilder) {
            CommonXRoadVer4And5SOAPMessageBuilder ver4And5MessageBuilder =
                    (CommonXRoadVer4And5SOAPMessageBuilder) soapRequestBuilder;

            ver4And5MessageBuilder.setService("aktorstest.allowedMethods");
            ver4And5MessageBuilder.setProducer("aktorstest");
            ver4And5MessageBuilder.setConsumer("11333578");

            setSecurityServerUrl("http://192.168.219.122/cgi-bin/consumer_proxy");
        }
    }

    /**
     * Run demo as Java application
     * @param args empty String
     * @throws SOAPException on failure
     * @throws DataExchangeException on failure
     */
    public static void main(String[] args) throws DataExchangeException {
        TestXRoadQuery testXroadQuery = new TestXRoadQuery(
                new XRoad6SOAPMessageBuilder("http://x-road.eu/xsd/xroad.xsd"));
        testXroadQuery.createSOAPRequest();
        testXroadQuery.sendRequest();
    }

}
