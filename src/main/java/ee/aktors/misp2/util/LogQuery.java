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

import java.net.URL;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.beans.T3SecWrapper;
import ee.aktors.misp2.model.T3Sec;
import ee.aktors.misp2.service.BaseService;
import ee.aktors.misp2.util.xroad.soap.query.meta.LogOnlyQuery;

/**
 *
 * @author arnis.rips
 */
public class LogQuery {
    private static final Logger LOGGER = LogManager.getLogger(LogQuery.class.getName());
    public static final int MANAGER_SETTING = 0;
    public static final int MANAGER_DELETE = 1;
    public static final int USER_ADD_TO_GROUP = 2;
    public static final int USER_DELETE_FROM_GROUP = 3;
    public static final int QUERY_RIGHTS_ADD = 4;
    public static final int QUERY_RIGHTS_DELETE = 5;
    public static final int USERGROUP_ADD = 6;
    public static final int USERGROUP_DELETE = 7;
    public static final int USER_ADD = 8;
    public static final int USER_DELETE = 9;
    public static final int UNIT_ADD = 10;
    public static final int UNIT_DELETE = 11;
    public static final int PORTAL_ADD = 12;
    public static final int PORTAL_DELETE = 13;
    public static final int REPRESENTION_CHECK = 14;
    public static final int NEGATIVE_RESPONSE_VALIDITY_CHECK = 15;
    // ----
    public static final String NAME_AEG = "aeg";
    public static final String NAME_GROUP = "group";
    public static final String NAME_QUERY_NAME = "query_name";
    public static final String NAME_REQUEST = "request";
    public static final String NAME_GROUP_NAME = "group_name";
    public static final String NAME_PORTAL_NAME = "portal_name";
    public static final String NAME_USER_TO = "user_to";
    public static final String NAME_VALID_UNTIL = "valid_until";
    public static final String NAME_ACTION_NAME = "action_name";
    // ----
    private BaseService service;
    private static final boolean ESCAPE_LOGGING = false;

    /**
     * @param service service to inject
     */
    public LogQuery(BaseService service) {
        this.service = service;
    }

    /**
     * Logs actions on X-Road server and our DB
     * @param input properly filled T3Sec object
     * @param endpoint  URL for endpoint (X-Road server)
     * @param runLogOnlyService if to send xRoadQuery
     * @return true if logging was successful, false if something went wrong
     * @throws Exception throws
     */
    @SuppressWarnings("fallthrough") // it's intentional
    public boolean log(T3SecWrapper input, URL endpoint, boolean runLogOnlyService) throws Exception {
        if (ESCAPE_LOGGING) {
            return true;
        }

        // logOnly query is always initialized because it builds toBeSaved variable
        LogOnlyQuery xRoadQuery = new LogOnlyQuery(input);
        xRoadQuery.createSOAPRequest();

        if (runLogOnlyService) {
            xRoadQuery.sendRequest();
        }
        try {
            // save to our database
            for (T3Sec t3Sec : xRoadQuery.getToBeSaved()) {
                LOGGER.debug("T3 SEC query: " + t3Sec.getQuery());
                LOGGER.debug("T3 SEC valid until: " + t3Sec.getValidUntil());
                service.save(t3Sec);
            }
        } catch (Exception ex) {
            LOGGER.error("DB log failed: " + ex.getMessage(), ex);
        }

        return true;
    }
}
