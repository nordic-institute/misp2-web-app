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

import static org.junit.Assert.assertEquals;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.xml.soap.SOAPException;
import javax.xml.xpath.XPathExpressionException;

import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.junit.Before;
import org.junit.Test;
import org.xml.sax.SAXException;

import ee.aktors.misp2.util.Const.XROAD_VERSION;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * Test ComplexQueryAnalyzer which extracts sub-service identifiers from complex query XForms
 * @author sander.kallo
 *
 */
public class ComplexQueryAnalyzerTest {
    protected static Logger logger = LogManager.getLogger(ComplexQueryAnalyzerTest.class);

    private static class TestConfItem {
        protected String path;
        protected XROAD_VERSION ver;
        protected int noOfSubServices;

        TestConfItem(String path, XROAD_VERSION ver, int noOfSubServices) {
            this.path = path;
            this.ver = ver;
            this.noOfSubServices = noOfSubServices;
        }

        public XROAD_VERSION getVer() {
            return ver;
        }

        public int getNoOfSubServices() {
            return noOfSubServices;
        }
        
        public String getXFormsContent() throws IOException {
            try (InputStream stream = Test.class.getResourceAsStream("/" + path)) {
                return IOUtils.toString(stream, StandardCharsets.UTF_8);
                
            }
        }
    }

    List<TestConfItem> testConf = null;

    /**
     * Set up test for each test case
     * @throws ConfigurationException if set up fails
     */
    @Before
    public void setUp() throws ConfigurationException {
        // test case consists of URL, X-Road version (XROAD_VERSION.V5 is used
        // both, for v5 and v4 services)
        // and finally an integer, showing how many sub-services are supposed to
        // be found from there
        testConf = new ArrayList<TestConfItem>();
        
        testConf.add(new TestConfItem(
                "xforms/digilugu-test-xroad-v5.xhtml",
                XROAD_VERSION.V5, 1));
        testConf.add(new TestConfItem(
                "xforms/aktorstest-complex-xroad-v5.xhtml",
                XROAD_VERSION.V5, 2));
        testConf.add(new TestConfItem(
                "xforms/aktorstest-complex-xroad-v6.xhtml",
                XROAD_VERSION.V6, 2));
    }

    /**
     * Given test reads X-Road complex service files (XForms) and verifies
     * correct singular-service identifiers are parsed out from those. Test case
     * tests X-Road v4, v5 and X-Road v6 services.
     * 
     * @throws IOException on error
     * @throws SAXException on error
     * @throws DataExchangeException on DOM parsing error
     * @throws XPathExpressionException on error
     * @throws XMLUtilException on error
     * @throws SOAPException on error
     * @throws ConfigurationException on error
     */
    @Test
    public void testSubQueryExtraction() throws IOException, SAXException,
        XPathExpressionException, XMLUtilException,
        DataExchangeException, SOAPException, ConfigurationException {
        logger.debug("Testing queries: each method (DOM, STR, SAX, should give the same result per one row.");
        for (TestConfItem testConfItem : testConf) {
            XROAD_VERSION xroadVersion = testConfItem.getVer();
            int noOfSubQueries = testConfItem.getNoOfSubServices();

            logger.debug("Expecting " + noOfSubQueries + " subqueries");
            ComplexQueryAnalyzer complexQueryAnalyzer = new ComplexQueryAnalyzer(
                    testConfItem.getXFormsContent(), xroadVersion);
            complexQueryAnalyzer.parseWithDom();
            assertEquals("DOM processing returns right amount of subqueries: ", noOfSubQueries,
                    getSubQueryNames(complexQueryAnalyzer).size());
            String domProcessingServices = complexQueryAnalyzer.toString();
            complexQueryAnalyzer.parseWithStringProcessing();
            assertEquals("String processing returns right amount of subqueries: ", noOfSubQueries,
                    getSubQueryNames(complexQueryAnalyzer).size());
            String stringProcessingServices = complexQueryAnalyzer.toString();
            complexQueryAnalyzer.parseWithSax();
            assertEquals("SAX processing returns right amount of subqueries: ", noOfSubQueries,
                    getSubQueryNames(complexQueryAnalyzer).size());
            String saxProcessingServices = complexQueryAnalyzer.toString();

            assertEquals("SAX processing and string processing return the same answer",
                    saxProcessingServices, stringProcessingServices);
            assertEquals("DOM processing and string processing return the same answer",
                    domProcessingServices, stringProcessingServices);
            logger.trace("Found subservices: " + saxProcessingServices);
        }
    }

    /**
     * This test makes sure using #parse() method that selects parser from conf
     * also works
     * 
     * @throws ConfigurationException on conf failure
     * @throws IOException on X-Forms resource file reading failure
     */
    @Test
    public void testParse() throws ConfigurationException, IOException {
        TestConfItem testConfItem = testConf.get(2);
        int noOfSubQueries = testConfItem.getNoOfSubServices();
        ComplexQueryAnalyzer complexQueryAnalyzer = new ComplexQueryAnalyzer(
                testConfItem.getXFormsContent(), XROAD_VERSION.V6);
        logger.trace("Test parsing from config.cfg.");
        org.apache.commons.configuration.PropertiesConfiguration conf =
                new org.apache.commons.configuration.PropertiesConfiguration(
                FileUtil.getConfigPathForTest("config.cfg"));
        complexQueryAnalyzer.parse(conf);

        assertEquals("Parsing based on conf also works", noOfSubQueries,
                getSubQueryNames(complexQueryAnalyzer).size());
    }

    private List<String> getSubQueryNames(ComplexQueryAnalyzer complexQueryAnalyzer) {
        return Arrays.asList(complexQueryAnalyzer.toString()
                .split(Const.SUB_QUERY_NAME_SEPARATOR));
    }

}
