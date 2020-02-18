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

package ee.aktors.misp2.util;

import com.opensymphony.xwork2.ActionSupport;

/**
 * 
 * @author arnis.rips
 */
public interface Const {

    /**
     * X-Road version
     */
    enum XROAD_VERSION {
        V4(4, "2.0", "http://x-tee.riik.ee/xsd/xtee.xsd"), // old X-Road tags
        V5(5, "3.1", "http://x-road.ee/xsd/x-road.xsd"),
        V6(6, "4.0", "http://x-road.eu/xsd/xroad.xsd");
        private int index;
        private String protocolVersion;
        private String defaultNamespace;

        XROAD_VERSION(int index, String protocolVersion, String defaultNamespace) {
            this.index = index;
            this.protocolVersion = protocolVersion;
            this.defaultNamespace = defaultNamespace;
        }

        /**
         * @return the index
         */
        public int getIndex() {
            return this.index;
        }

        /**
         * @return the protocol version
         */
        public String getProtocolVersion() {
            return this.protocolVersion;
        }

        /**
         * @return default namespace
         */
        public String getDefaultNamespace() {
            return defaultNamespace;
        }

        /**
         * Default X-Road version. Its namespace is used in xsl files and elsewhere, where current namespace
         * {@link #XROAD_NS} can't be used for some technical reason
         * 
         * @return X-Road v5
         */
        public static XROAD_VERSION getDefault() {
            return XROAD_VERSION.V5;
        }

        /**
         * @param index index (version number) of enum
         * @return XROAD_VERSION if version with such index exists, null otherwise
         */
        public static XROAD_VERSION getByIndex(int index) {
            for (XROAD_VERSION item : XROAD_VERSION.values()) {
                if (item.getIndex() == index)
                    return item;
            }
            return null;
        }
    }

    /**
     * query type
     * Database depends on the order of enums (enum ordinals)
     * Do not change the order of the enums
     * If adding new enums only add at last position
     */
    enum QUERY_TYPE {
        //DO NOT CHANGE ORDER
        X_ROAD, BPEL, X_ROAD_COMPLEX;
    }

    String XROAD_NS_PREFIX = "xrd";
    String XROAD_NS_USERID = "userId";
    String XROAD_NS_CONSUMER = "consumer";
    String XROAD_NS_PRODUCER = "producer";
    String XROAD_NS_ID = "id";
    String XROAD_NS_SERVICE = "service";

    String XROAD_NS_PREFIX_OLD = "xtee";
    String XROAD_NS_USERID_OLD = "isikukood";
    String XROAD_NS_USER_OLD = "ametnik";
    String XROAD_NS_CONSUMER_OLD = "asutus";
    String XROAD_NS_PRODUCER_OLD = "andmekogu";
    String XROAD_NS_ID_OLD = "id";
    String XROAD_NS_SERVICE_OLD = "nimi";
    String XROAD_V6_FIELD_SEPARATOR = ":";
    String SUB_QUERY_NAME_SEPARATOR = ", ";
    // ---
    String SOAP_REQUEST_ELEMENT = "request";
    String SOAP_REQUEST_ELEMENT_OLD = "keha";
    String CLASSIFIER_SERVICE = "loadClassification";
    String LOG_ONLY_SERVICE = "xrd.logOnly";
    String LOG_ONLY_SERVICE_OLD = "xtee.logOnly";

    /**
     * Open services portal
     */
    int MISP_TYPE_CITIZEN = 0;
    /**
     * Organization's portal
     */
    int MISP_TYPE_SIMPLE = 1;
    /**
     * Business portal
     */
    int MISP_TYPE_ORGANISATION = 2;
    /**
     * Universal portal
     */
    int MISP_TYPE_UNIVERSAL = 3;
    // session constants
    String SESSION_USER_HANDLE = "SESSION_USER_HANDLE";
    String SESSION_USER_ROLE = "SESSION_USER_ROLE"; // active role, 1, 2, 4, 8, 16 (user, permman, dev, adm, pman)
    String SESSION_PORTAL = "SESSION_PORTAL";
    String SESSION_ACTIVE_ORG = "SESSION_ACTIVE_ORG";
    String SESSION_ALL_ROLES = "SESSION_ALL_ROLES";
    String SESSION_BROWSER = "SESSION_BROWSER";
    String SESSION_ALLOWED_ORG_LIST = "SESSION_AUTH_ALLOWED_ORG_LIST";
    String SESSION_UNKNOWN_ORG_LIST = "SESSION_AUTH_UNKNOWN_ORG_LIST";
    String SESSION_MANAGER_CANDIDATES = "MANAGER_CANDIDATES_LIST";
    String SESSION_BOARD_OF_DIRECTORS = "BOARD_OF_DIRECTORS";
    String SESSION_AUTH = "AUTH_METHOD";
    String SESSION_PREVIOUS_ACTION = "PREVIOUS_ACTION";
    String SESSION_USE_MANAGER = "USE_MANAGER";
    String SESSION_SSLID = "SSLID";
    String SESSION_FLASH = "SESSION_FLASH";
    String SESSION_CSRF_TOKEN = "SESSION_CSRF_TOKEN";
    String SESSION_ACTIVE_XROAD_INSTANCES = "SESSION_ACTIVE_XROAD_INSTANCES";
    String SESSION_EULA_MAP = "SESSION_EULA_MAP";
    String SESSION_QUERY_SOURCE_FILE = "SESSION_QUERY_SOURCE_FILE";
    String SESSION_QUERY_SOURCE_FILE_NAME = "SESSION_QUERY_SOURCE_FILE_NAME";
    String SESSION_IS_CONTAINER_SIGNED = "SESSION_IS_CONTAINER_SIGNED";
    String SESSION_DIGI_CONTAINER = "SESSION_DIGI_CONTAINER";
    String SESSION_DATA_TO_SIGN = "SESSION_DATA_TO_SIGN";
    String SESSION_MID_SESSION_ID = "SESSION_MID_SESSION_ID";
    String SESSION_MID_USER_DATA = "SESSION_MID_USER_DATA";
    /**
     * used for holding in session sessions last access time in milliseconds since epoch.
     */
    String SESSION_LAST_ACCESS_TIME = "SESSION_LAST_ACCESS_TIME";
    // MIME TYPES
    String MIME_X509CERT = "application/x-x509-user-cert";
    String MIME_PEM_CERT = "application/x-pem-file";
    String MIME_PDF = "application/pdf";
    String MIME_OCTETSTREAM = "application/octet-stream";
    String MIME_HTML = "text/html";
    String MIME_CSV = "text/csv";
    String CONTENT_DISPOSITION = "Content-Disposition";
    String XML = "xml";
    ActionSupport AS = new ActionSupport();
    String FILTER_YES = "1";
    String FILTER_NULL = "0";
    String VER = "version";
    String REV_NR = "revision.number";
    String SECURITY_URI = "/cgi-bin/consumer_proxy";
    String PROXY_URI = "/cgi-bin/uriproxy";
    String ALLOWED_METHODS = "allowedMethods";
    String LIST_PRODUCERS = "listProducers";

    String IE = "Microsoft Internet Explorer";
    String MOZILLA = "Mozilla";

    // X-Road (version-specific) constants
    String XROAD_V6_LIST_CLIENTS = "/listClients";
    String XROAD_V6_WSDL = "/wsdl";
    String XROAD_V5_LIST_ALLOWED_METHODS_FROM_SECURITY_SERVER = "SS";
    String XROAD_LIST_ALL_METHODS_FROM_WSDL = "WSDL";
    String XROAD_V6_LIST_ALL_METHODS_FROM_SECURITY_SERVER = "ALL";
    String XROAD_V6_LIST_ALLOWED_METHODS_FROM_SECURITY_SERVER = "ALLOWED";
    String GENERATE_XFORMS = "generate";
    String XROAD_V6_GENERATE_XFORMS_FROM_SECURITY_SERVER = "generateFromSecurityServer";
    String XROAD_INSTANCES_SELECTED = "xroadInstancesSelected";
    int XROAD_INSTANCE_MAX_LENGTH = 64;
    String XROAD_REST_HEADER_FIELD_SEPARATOR = "/";
    String OPENAPI_SERVICE_CODE_FLASH_KEY = "openapiServiceCode";
    String URL_PATH_SEPARATOR = "/";
    String LIST_ELEMENT_DELIMITER = ",";

    /**
     * \@Coulumn lengths
     */

    int LENGTH_5 = 5;
    int LENGTH_10 = 10;
    int LENGTH_16 = 16;
    int LENGTH_20 = 20;
    int LENGTH_32 = 32;
    int LENGTH_50 = 50;
    int LENGTH_64 = 64;
    int LENGTH_75 = 75;
    int LENGTH_100 = 100;
    int LENGTH_150 = 150;
    int LENGTH_256 = 256;
    int LENGTH_512 = 512;
    int LENGTH_1042 = 1042;
    int LENGTH_2048 = 2048;
    int LENGTH_2147483647 = 2147483647;

    /**
     * Prime numbers for hash calculations
     */
    int PRIME_3 = 3;
    int PRIME_7 = 7;
    int PRIME_17 = 17;
    int PRIME_29 = 29;
    int PRIME_41 = 41;
    int PRIME_97 = 97;

}
