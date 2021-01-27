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

package ee.aktors.misp2.util.xroad.soap.query.unit;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.util.LinkedHashMap;

import ee.aktors.misp2.util.TestFileUtil;
import org.apache.commons.configuration.ConfigurationException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.junit.Before;
import org.junit.Test;

import ee.aktors.misp2.util.FileUtil;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf.AuthQueryConf;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf.CheckQueryConf;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf.OrgPortalAuthQueryConf;

/**
 * Current test checks if universal portal and organization portal X-Road
 * authentication and unit validation query configuration behaves as expected
 * 
 * @author sander.kallo
 *
 */
public class UnitQueryConfTest {
    static org.apache.commons.configuration.PropertiesConfiguration orgConf;
    static org.apache.commons.configuration.PropertiesConfiguration univConf;
    static UnitQueryConf unitQueryConf;

    protected static Logger log = LogManager.getLogger(UnitQueryConfTest.class);

    /**
     * Set up configurations and derived objects before each test
     * @throws ConfigurationException on failure
     */
    @Before
    public void setUp() throws ConfigurationException {
        // initialize config
        orgConf = new org.apache.commons.configuration
                .PropertiesConfiguration(TestFileUtil.getConfigPathForTest("orgportal-conf.cfg"));
        univConf = new org.apache.commons.configuration
                .PropertiesConfiguration(TestFileUtil.getConfigPathForTest("uniportal-conf.cfg"));
        unitQueryConf = new UnitQueryConf(orgConf, univConf);
    }


    /**
     * Test uniportal 'unit valid' query.
     * @throws ConfigurationException on failure
     */
    @Test
    public void testUnivPortalConfUnitValidQuery() throws ConfigurationException {
        // uniportal conf
        LinkedHashMap<String, String> checks = unitQueryConf.getCheckQueryOptions();
        // the map is used for displaying the options in administrator interface
        // (uniportal only, unit check query)
        assertTrue("At least one config item exists in developer conf ", checks.size() > 0);
        CheckQueryConf checkQueryConf = null;
        for (String key : checks.keySet()) {
            CheckQueryConf tmpCheckQueryConf = unitQueryConf.getCheckQueryConf(key);
            if (tmpCheckQueryConf.getServiceCode().equals("unitValid")
                    && tmpCheckQueryConf.getMemberCode().equals("11333578")) {
                // found our sample query, search is over, break
                checkQueryConf = tmpCheckQueryConf;
                break;
            }
            log.trace("orgPortalCheck:" + key + " " + tmpCheckQueryConf.getName());
        }

        assertTrue("Our sample service exists in uniportal-conf ", checkQueryConf != null);
        assertEquals("Query name is successfully read from conf ", checkQueryConf.getName(),
                "ee-dev:COM:11333578:aktorstest-db01:unitValid:v1");
        assertEquals("Namespace is successfully read from conf ", checkQueryConf.getNamespace(),
                "http://aktorstest.x-road.ee/producer");

        // sample a couple of random configuration parameters to verify if they
        // are read in
        assertEquals("Response unit code code is successfully read from conf ",
                checkQueryConf.getRequestUnitCodeXpath(), "request/unitCode");
    }

    /**
     * Test uniportal 'unit represent' query.
     * @throws ConfigurationException on failure
     */
    @Test
    public void testUnivPortalConfUnitRepresentQuery() throws ConfigurationException {
        // uniportal conf
        LinkedHashMap<String, String> auths = unitQueryConf.getAuthQueryOptions();
        // the map is used for displaying the options in administrator interface
        // (uniportal only, unit valid query)
        assertTrue("At least one config item exists in developer conf ", auths.size() > 0);
        AuthQueryConf authQueryConf = null;
        for (String key : auths.keySet()) {
            AuthQueryConf tmpAuthQueryConf = unitQueryConf.getAuthQueryConf(key);
            if (tmpAuthQueryConf.getServiceCode().equals("unitRepresent")
                    && tmpAuthQueryConf.getMemberCode().equals("11333578")) {
                // found our sample query, search is over, break
                authQueryConf = tmpAuthQueryConf;
                break;
            }
            log.trace("uniportal auth:" + key + " " + tmpAuthQueryConf.getName());
        }

        assertTrue("Our sample service exists in uniportal-conf ", authQueryConf != null);
        assertEquals("Query name is successfully read from conf ", authQueryConf.getName(),
                "ee-dev:COM:11333578:aktorstest-db01:unitRepresent:v1");

        // sample a couple of random configuration parameters to verify if they
        // are read in
        assertEquals("Namespace is successfully read from conf ", authQueryConf.getNamespace(),
                "http://aktorstest.x-road.ee/producer");
        assertEquals("Response unit code code is successfully read from conf ", authQueryConf.getResponseUnitCodeXath(),
                "//item/unitCode");
    }

    /**
     * Test orgportal 'person represent' query.
     * @throws ConfigurationException on failure
     */
    @Test
    public void testOrgPortalConf() {
        // orgportal conf
        LinkedHashMap<String, String> orgPortalAuths = unitQueryConf.getOrgPortalAuthQueryOptions();
        // the map is used for displaying the options in administrator interface
        // (orgportal only)
        assertTrue("At least one config item exists in developer conf ", orgPortalAuths.size() > 0);
        OrgPortalAuthQueryConf orgPortalQueryConf = null;
        for (String key : orgPortalAuths.keySet()) {
            OrgPortalAuthQueryConf tmpOrgPortalQueryConf = unitQueryConf.getOrgPortalAuthQueryConf(key);
            if (tmpOrgPortalQueryConf.getServiceCode().equals("personRepresent")
                    && tmpOrgPortalQueryConf.getMemberCode().equals("11333578")) {
                // found our sample query, search is over, break
                orgPortalQueryConf = tmpOrgPortalQueryConf;
                break;
            }
            log.trace("orgPortalAuth:" + key + " " + tmpOrgPortalQueryConf.getName());
        }
        assertTrue("Our sample service exists in orgportal-conf ", orgPortalQueryConf != null);
        assertEquals("Query name is successfully read from conf ", orgPortalQueryConf.getName(),
                "ee-dev:COM:11333578:aktorstest-db01:personRepresent:v1");

        // sample a couple of random configuration parameters to verify if they
        // are read in
        assertEquals("Namespace is successfully read from conf ", orgPortalQueryConf.getNamespace(),
                "http://aktorstest.x-road.ee/producer");
        assertEquals("Register code is successfully read from conf ", orgPortalQueryConf.getResponseRegisterCodeXpath(),
                "organizationCode");

    }

    /**
     * Given test determines, if translating current application user
     * unit.memberClass values to X-Road service request works.
     */
    @Test
    public void testResponseMemberClassTranslationOption() {
        UnitQueryConf.SingleQueryConf signleQueryConf = new UnitQueryConf.SingleQueryConf();
        signleQueryConf.set("member_class_translations", "com : COM-TRANSL | gov : GOV-TRANSL | ngo : NGO-TRANSL");
        assertEquals(signleQueryConf.translateMemberClass("com"), "COM-TRANSL");
        assertEquals(signleQueryConf.translateMemberClass("gov"), "GOV-TRANSL");
        assertEquals(signleQueryConf.translateMemberClass("ngo"), "NGO-TRANSL");
        assertEquals("Non-existent entry in translation map is translated to NULL",
                signleQueryConf.translateMemberClass("does-not-exist"), null);

        signleQueryConf.set("member_class_translations", null);
        assertEquals("If mapping is null, do not translate and return input value unchanged",
                signleQueryConf.translateMemberClass("same-value"), "same-value");

    }
}
