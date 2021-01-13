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

package ee.aktors.misp2.util.xroad;

import static org.junit.Assert.*;

import java.util.LinkedHashSet;
import java.util.List;

import org.apache.commons.configuration.ConfigurationException;
import org.junit.BeforeClass;
import org.junit.Test;

import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.provider.ConfigurationProvider;
import ee.aktors.misp2.util.FileUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.XRoad5SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad6SOAPMessageBuilder;

/**
 * Test X-Road utils
 * @author sander.kallo
 *
 */
public class XRoadUtilTest {

    /**
    * Read in configuration (only once per test sequence)
    * @throws ConfigurationException on failure
    */
    @BeforeClass
    public static void oneTimeSetUp() throws ConfigurationException {
        // initialize config
        ConfigurationProvider.setConfig(
                new org.apache.commons.configuration.PropertiesConfiguration(
                        FileUtil.getConfigPathForTest("config.cfg")));
    }

    /**
     * Some known X-Road v6 clients are excluded from producer list. Which ones
     * are excluded, are determined by regex in conf. Test that regex here.
     * 
     * @throws ConfigurationException on configuration failure
     */
    @Test
    public void testProducerExcludingRegex() throws ConfigurationException {
        // test excludeProducersRegex
        Producer producer = new Producer();
        producer.setMemberClass("COM");
        producer.setShortName("10005211");
        producer.setSubsystemCode(null);

        assertTrue("Producer " + producer.getXroadIdentifier() + " is exclued", XRoadUtil.isProducerExcluded(producer));
        producer.setSubsystemCode("generic-consumer");
        assertTrue("Producer " + producer.getXroadIdentifier() + " is exclued", XRoadUtil.isProducerExcluded(producer));
        producer.setSubsystemCode("allowed-consumer");
        assertFalse("Producer " + producer.getXroadIdentifier() + " is not excluedd",
                XRoadUtil.isProducerExcluded(producer));
    }

    /**
     * Make sure the util returns correct X-Road builder for given portal
     * xroadProtocolVer.
     * 
     * @throws DataExchangeException on failure
     */
    @Test
    public void getXRoadSOAPMessageBuilderTest() throws DataExchangeException {
        Portal portal = new Portal();
        portal.setXroadProtocolVer("4.0");
        assertTrue("X-Road v6 builder is returned for protocol " + portal.getXroadProtocolVer(),
                XRoadUtil.getXRoadSOAPMessageBuilder(portal) instanceof XRoad6SOAPMessageBuilder);
        portal.setXroadProtocolVer("3.1");
        assertTrue("X-Road v5 builder is returned for protocol " + portal.getXroadProtocolVer(),
                XRoadUtil.getXRoadSOAPMessageBuilder(portal) instanceof XRoad5SOAPMessageBuilder);
    }
    /**
     * Test reading X-Road instances from conf
     */
    @Test
    public void getXroadInstancesTest() {
        List<String> instances = XRoadInstanceUtil.getDefaultInstances();
        assertTrue("X-Road instance list in dev machine conf exists and there are some elements there",
                instances.size() > 0);
        assertTrue("ee-dev X-Road instace is listed", instances.contains("ee-dev"));
    }

    /**
     * Test verification conf path patterns (ZIP file returned by security server) which
     * is used for federated instance listing.
     */
    @Test
    public void getMemberClassesTest() {
        List<String> memberClasses = XRoadUtil.getMemberClasses();
        assertTrue("X-Road instance list in dev machine conf exists and there are some elements there",
                memberClasses.size() > 0);
        assertTrue("COM member class is listed", memberClasses.contains("COM"));
    }
    
    /**
     * Test verification conf patterns
     */
    @Test
    public void verificationConfPathPatternTest() {
        assertTrue(
                XRoadInstanceUtil.SHARED_PARAMS_PATTERN
                    .matcher("verificationconf/FI-DEV/shared-params.xml").find()
        );
        assertTrue(
                XRoadInstanceUtil.INSTANCE_IDENTIFIER_PATTERN
                    .matcher("verificationconf/instance-identifier").find()
        );
    }
    
    private LinkedHashSet<String> orderedSet(String... keys) {
        LinkedHashSet<String> set = new LinkedHashSet<String>();
        for (String key : keys) {
            set.add(key);
        }
        return set;
    }
    
    /**
     * Test XRoadInstanceUtil.containsOrderedSubset
     */
    @Test
    public void testContainsOrderedSubset() {
        assertTrue(
                XRoadInstanceUtil.containsOrderedSubset(orderedSet("A", "B", "C"), orderedSet("A", "B", "C"))
        );
        assertTrue(
                XRoadInstanceUtil.containsOrderedSubset(orderedSet("A", "B", "C"), orderedSet("A", "B"))
        );
        assertTrue(
                XRoadInstanceUtil.containsOrderedSubset(orderedSet("A", "B", "C"), orderedSet("A", "C"))
        );
        assertTrue(
                XRoadInstanceUtil.containsOrderedSubset(orderedSet("A", "B", "C"), orderedSet("A"))
        );
        assertTrue(
                XRoadInstanceUtil.containsOrderedSubset(orderedSet("A", "B", "C"), orderedSet("B"))
        );
        assertTrue(
                XRoadInstanceUtil.containsOrderedSubset(orderedSet("A", "B", "C"), orderedSet("C"))
        );
        assertTrue(
                XRoadInstanceUtil.containsOrderedSubset(orderedSet("A", "B", "C"), orderedSet())
        );
        assertFalse(
                XRoadInstanceUtil.containsOrderedSubset(orderedSet("A", "B", "C"), orderedSet("D", "E"))
        );
        assertFalse(
                XRoadInstanceUtil.containsOrderedSubset(orderedSet("A", "B", "C"), orderedSet("D"))
        );
        assertFalse(
                XRoadInstanceUtil.containsOrderedSubset(orderedSet("A", "B", "C"), orderedSet("C", "A"))
        );
    }
}
