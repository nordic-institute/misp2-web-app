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

package ee.aktors.misp2.util.xroad.soap.query.unit;

import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

import org.apache.commons.configuration.Configuration;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Wrapper around uni-portal and org-portal configurations for initializing
 * X-Road v6 unit query parameters. Current class is instantiated as a Spring
 * bean during application startup. It provides helper methods for retrieving
 * details for X-Road v6 person auth query (org. portal) and unit check and auth
 * queries (univ. portal). It also contains query configuration structures as
 * subclasses.
 * 
 * @author sander.kallo
 *
 */
public class UnitQueryConf {

    private static Logger logger = LogManager.getLogger(UnitQueryConf.class);
    LinkedHashMap<String, CheckQueryConf> checkQueries;
    LinkedHashMap<String, AuthQueryConf> authQueries;
    LinkedHashMap<String, OrgPortalAuthQueryConf> orgPortalAuthQueries;

    /**
     * Initialize UnitQueryConf
     * (contains org-portal authentication query conf and X-Road v6 uni-portal check and auth query conf)
     * @param orgConfiguration org-portal configuration
     * @param univConfiguration universal portal configuration
     */
    public UnitQueryConf(Configuration orgConfiguration, Configuration univConfiguration) {
        // univ-portal conf
        checkQueries = new LinkedHashMap<String, CheckQueryConf>();
        authQueries = new LinkedHashMap<String, AuthQueryConf>();
        Iterator<String> it = univConfiguration.getKeys();
        final int expectedKeyPartsLength = 3;
        while (it.hasNext()) {
            String key = it.next();
            String[] keyParts = key.split(Pattern.quote("."));
            if (keyParts.length == expectedKeyPartsLength) {
                String confType = keyParts[0];
                String confItemId = keyParts[1];
                String confParameter = keyParts[2];
                SingleQueryConf queryConf = null;

                if (confType.equals("auth")) {
                    if (authQueries.containsKey(confItemId)) {
                        queryConf = authQueries.get(confItemId);
                    } else {
                        queryConf = new AuthQueryConf();
                        authQueries.put(confItemId, (AuthQueryConf) queryConf);
                    }
                } else if (confType.equals("check")) {
                    if (checkQueries.containsKey(confItemId)) {
                        queryConf = checkQueries.get(confItemId);
                    } else {
                        queryConf = new CheckQueryConf();
                        checkQueries.put(confItemId, (CheckQueryConf) queryConf);
                    }
                }
                if (queryConf != null) {
                    boolean foundConfParam = queryConf.set(confParameter, univConfiguration.getString(key));
                    if (!foundConfParam) {
                        logger.warn("Unknown unit query univPortal-conf parameter: " + key);
                    }
                }
            }
        }

        // org-portal conf
        orgPortalAuthQueries = new LinkedHashMap<String, OrgPortalAuthQueryConf>();
        it = orgConfiguration.getKeys();
        while (it.hasNext()) {
            String key = it.next();
            String[] keyParts = key.split(Pattern.quote("."));
            if (keyParts.length == expectedKeyPartsLength) {
                String confType = keyParts[0];
                String confItemId = keyParts[1];
                String confParameter = keyParts[2];
                SingleQueryConf queryConf = null;

                if (confType.equals("auth")) {
                    if (orgPortalAuthQueries.containsKey(confItemId)) {
                        queryConf = orgPortalAuthQueries.get(confItemId);
                    } else {
                        queryConf = new OrgPortalAuthQueryConf(orgConfiguration);
                        orgPortalAuthQueries.put(confItemId, (OrgPortalAuthQueryConf) queryConf);
                    }
                }
                if (queryConf != null) {
                    boolean foundConfParam = queryConf.set(confParameter, orgConfiguration.getString(key));
                    if (!foundConfParam) {
                        logger.warn("Unknown unit query orgPortal-conf parameter: " + key);
                    }
                }
            }
        }
    }

    /**
     * @return unit check query options for universal portal administrator interface
     */
    public LinkedHashMap<String, String> getCheckQueryOptions() {
        LinkedHashMap<String, String> queryOptions = new LinkedHashMap<String, String>();
        for (String key : checkQueries.keySet()) {
            queryOptions.put(key, checkQueries.get(key).getName());
        }
        return queryOptions;
    }

    /**
     * @return unit authentication query options for universal portal administrator interface
     */
    public LinkedHashMap<String, String> getAuthQueryOptions() {
        LinkedHashMap<String, String> queryOptions = new LinkedHashMap<String, String>();
        for (String key : authQueries.keySet()) {
            queryOptions.put(key, authQueries.get(key).getName());
        }
        return queryOptions;
    }
    
    /**
     * @return org portal authentication query options for universal portal administrator interface
     */
    public LinkedHashMap<String, String> getOrgPortalAuthQueryOptions() {
        LinkedHashMap<String, String> queryOptions = new LinkedHashMap<String, String>();
        for (String key : orgPortalAuthQueries.keySet()) {
            queryOptions.put(key, orgPortalAuthQueries.get(key).getName());
        }
        return queryOptions;
    }

    /**
     * Get uni-portal check query configuration object by option map key
     * @param key check query options map key
     * @return X-Road v6 unit check query configuration object corresponding to given key
     */
    public CheckQueryConf getCheckQueryConf(String key) {
        if (key.startsWith("."))
            key = key.substring(1, key.length());
        return checkQueries.get(key);
    }

    /**
     * Get uni-portal authentication (unit representation) query configuration object by option map key
     * @param key authentication query options map key
     * @return X-Road v6 query configuration object corresponding to given key
     */
    public AuthQueryConf getAuthQueryConf(String key) {
        if (key.startsWith("."))
            key = key.substring(1, key.length());
        return authQueries.get(key);
    }

    /**
     * Get org-portal authentication query configuration object by option map key
     * @param key authentication query options map key
     * @return X-Road v6 query configuration object corresponding to given key
     */
    public OrgPortalAuthQueryConf getOrgPortalAuthQueryConf(String key) {
        if (key.startsWith("."))
            key = key.substring(1, key.length());
        return orgPortalAuthQueries.get(key);
    }

    /**
     * X-Road v6 (can also be used for v5) query configuration container
     * without any request or response parameters,
     * just basic service headers and request body namespace.
     */
    public static class SingleQueryConf {
        private String xroadInstance;
        private String memberClass;
        private String memberCode;
        private String subsystemCode;
        private String serviceCode;
        private String serviceVersion;
        private String namespace;

        // because all child classes use member class in query body (request or
        // response), this superclass
        // provides functionality to configure translation
        // only applies to request body memberClass, not X-Road message service
        // header memberClass
        private Map<String, String> memberClassTranslations;

        /**
         * @return X-Road v6 request X-Road instance header value
         */
        public String getXroadInstance() {
            return xroadInstance;
        }
        /**
         * @return X-Road v6 request service member class header value
         */
        public String getMemberClass() {
            return memberClass;
        }
        /**
         * @return X-Road v6 request service member class or X-Road v5 producer header value
         */
        public String getMemberCode() {
            return memberCode;
        }
        /**
         * @return X-Road v6 request service subsystem code
         */
        public String getSubsystemCode() {
            return subsystemCode;
        }
        /**
         * @return X-Road v6 request service code header value or X-Road v5 service name without producer and version
         */
        public String getServiceCode() {
            return serviceCode;
        }

        /**
         * @return X-Road request service version
         */
        public String getServiceVersion() {
            return serviceVersion;
        }

        /**
         * @return X-Road v6 request body namespace (cannot be derived from producer name any more as in v5)
         */
        public String getNamespace() {
            return namespace;
        }

        /**
         * Set X-Road request body namespace
         * @param inputNamespace request body namespace
         */
        public void setNamespace(String inputNamespace) {
            this.namespace = inputNamespace;
        }
        
        /**
         * @return X-Road v6 service identifier
         */
        public String getName() {
            return xroadInstance + ":" + memberClass + ":" + memberCode + ":" + subsystemCode + ":" + serviceCode
                    + (serviceVersion != null ? ":" + serviceVersion : "");
        }

        /**
         * Member classes can be translated to mapped values to fit auth and
         * check service data. For example, the following configuration key
         * (orgportal-cfg.conf or uniportal-cfg.conf)
         * auth.aktorsAuth.member_class_translations = com : COM | govern : GOV
         * | es\,cape : e\\:x\\\\amp\\|le | npo : NPO results in translation map
         * {com=>COM, govern=>GOV, es,cape=>e:xamp|le, npo=>NPO} Mapping entry
         * separator is '|', key and value separator is ':'.
         * 
         * @param val
         *            value to be translated
         * @return translated value or {@link #val} itself if translation is not
         *         switched on (key auth.[service].member_class_translations is
         *         not found from conf).
         */
        public String translateMemberClass(String val) {
            if (memberClassTranslations == null) {
                return val;
            } else {
                return memberClassTranslations.get(val);
            }
        }

        /**
         * Set configuration value by pre-determined key
         * @param key configuration property key
         * @param value configuration property value
         * @return true if given key was found and respective property set, false if not
         */
        public boolean set(String key, String value) {
            if (key.equals("xroad_instance")) {
                this.xroadInstance = value;
                return true;
            } else if (key.equals("member_class")) {
                this.memberClass = value;
                return true;
            } else if (key.equals("member_code")) {
                this.memberCode = value;
                return true;
            } else if (key.equals("subsystem_code")) {
                this.subsystemCode = value;
                return true;
            } else if (key.equals("service_code")) {
                this.serviceCode = value;
                return true;
            } else if (key.equals("service_version")) {
                if (value == null || value.trim().isEmpty())
                    value = null;
                this.serviceVersion = value;
                return true;
            } else if (key.equals("namespace")) {
                this.namespace = value;
                return true;
            } else if (key.equals("member_class_translations")) {
                memberClassTranslations = null;
                if (value != null) {
                    memberClassTranslations = new LinkedHashMap<String, String>();
                    // split by | (with optional whitespace)
                    // lookbehind<?<!\\\\) does enables to comment out
                    // separators with \\ in conf not to include them
                    String[] mappingStrAr = value.trim().split("(?<!\\\\)\\|");
                    logger.debug("Member class mapping size: " + mappingStrAr.length);
                    for (String mappingStr : mappingStrAr) {
                        // split each mapping by colon
                        String[] mapKeyAndVal = mappingStr.split("(?<!\\\\):");
                        if (mapKeyAndVal.length == 2) {
                            // replace double backslashes with one backslash and
                            // single backslash with empty string
                            // basically, get rid of escape character
                            memberClassTranslations.put(mapKeyAndVal[0].trim().replaceAll("\\\\(?!\\\\)", ""),
                                    mapKeyAndVal[1].trim().replaceAll("\\\\(?!\\\\)", ""));
                        } else {
                            logger.debug("Illegal member class mapping '" + mappingStr + "'");
                        }
                    }
                }
                logger.debug(
                        "Setting member class translations (memberClassTranslations) to " + memberClassTranslations);
                return true;
            } else {
                return false;
            }
        }
    }
    
    /**
     * Universal portal unit check query configuration container.
     * Extends on general X-Road query config {@link SingleQueryConf} with
     * added query request and response parameters such as where to put the unit data
     * in request and where to read the response from.
     */
    public static class CheckQueryConf extends SingleQueryConf {
        private String requestUnitMemberClassXpath;
        private String requestUnitCodeXpath;
        private String responseValidXath;
        private String responseNameXpath;
        private String responseValidValue;

        /**
         * Set default values to query parameters
         */
        public CheckQueryConf() {
            super();
            requestUnitMemberClassXpath = null; // by default, member class is not added
            requestUnitCodeXpath = "request/unitCode";
            responseValidXath = "//response/isValid";
            responseNameXpath = "//response/name";
            responseValidValue = "true";
        }

        /**
         * Sequence of XML node names separated by '/'.
         * Such node structure is created in request.
         * Last node in current node names list gets assigned filled with member class value.
         * 
         * @return request unit member class structure specifier
         */
        public String getRequestUnitMemberClassXpath() {
            return requestUnitMemberClassXpath;
        }

        /**
         * Sequence of XML node names separated by '/'.
         * Such node structure is created in request.
         * Last node in current node names list gets filled with member code value.
         * 
         * @return request unit member code structure specifier
         */
        public String getRequestUnitCodeXpath() {
            return requestUnitCodeXpath;
        }
        
        /**
         * @return XPath in check query response which is used to determine if requested unit is valid or not.
         */
        public String getResponseValidXath() {
            return responseValidXath;
        }

        /**
         * @return XPath in check query response where unit name is read
         */
        public String getResponseNameXpath() {
            return responseNameXpath;
        }

        /**
         * @return query response expected value that indicates that the unit is considered valid
         */
        public String getResponseValidValue() {
            return responseValidValue;
        }

        @Override
        public boolean set(String key, String value) {
            boolean setInSuper = super.set(key, value);
            if (setInSuper) {
                return true;
            } else if (key.equals("request_unit_member_class_xpath")) {
                this.requestUnitMemberClassXpath = value;
                return true;
            } else if (key.equals("request_unit_code_xpath")) {
                this.requestUnitCodeXpath = value;
                return true;
            } else if (key.equals("response_valid_xpath")) {
                this.responseValidXath = value;
                return true;
            } else if (key.equals("response_name_xpath")) {
                this.responseNameXpath = value;
                return true;
            } else if (key.equals("response_valid_value")) {
                this.responseValidValue = value;
                return true;
            } else {
                return false;
            }
        }
    }

    /**
     * Universal portal unit representation query configuration container.
     * Extends on general X-Road query config {@link SingleQueryConf} with
     * added query request and response parameters such as where to put the user id
     * in request and where to read the response from.
     */
    public static class AuthQueryConf extends SingleQueryConf {
        private String requestPersonCodeXpath;
        private String responseUnitMemberClassXpath;
        private String defaultResponseUnitMemberClass;
        private String responseUnitCodeXath;
        private String responseUnitNameXpath;

        /**
         * Set defaults
         */
        public AuthQueryConf() {
            super();
            requestPersonCodeXpath = "request/personCode";
            responseUnitMemberClassXpath = null;
            defaultResponseUnitMemberClass = "COM";
            responseUnitCodeXath = "//item/unitCode";
            responseUnitNameXpath = "//item/name";

        }

        /**
         * Sequence of XML node names separated by '/'.
         * Such node structure is created in request.
         * Last node in current node names list gets filled with person code (social security number) value.
         * 
         * @return request user person code structure specifier
         */
        public String getRequestPersonCodeXpath() {
            return requestPersonCodeXpath;
        }

        /**
         * @return XPath to response element where unit member class is read
         */
        public String getResponseUnitMemberClassXpath() {
            return responseUnitMemberClassXpath;
        }

        /**
         * @return default member class for X-Road v6 portals (if no member-class retrieval from message is specified)
         */
        public String getDefaultResponseOrganizationMemberClass() {
            return defaultResponseUnitMemberClass;
        }

        /**
         * @return XPath to representing unit code in X-Road query response
         */
        public String getResponseUnitCodeXath() {
            return responseUnitCodeXath;
        }

        /**
         * @return XPath to representing unit name in X-Road query response
         */
        public String getResponseUnitNameXpath() {
            return responseUnitNameXpath;
        }

        @Override
        public boolean set(String key, String value) {
            boolean setInSuper = super.set(key, value);
            if (setInSuper) {
                return true;
            } else if (key.equals("request_person_code_xpath")) {
                this.requestPersonCodeXpath = value;
                return true;
            } else if (key.equals("response_unit_member_class_xpath")) {
                this.responseUnitMemberClassXpath = value;
                return true;
            } else if (key.equals("default_response_unit_member_class")) {
                this.defaultResponseUnitMemberClass = value;
                return true;
            } else if (key.equals("response_unit_code_xpath")) {
                this.responseUnitCodeXath = value;
                return true;
            } else if (key.equals("response_unit_name_xpath")) {
                this.responseUnitNameXpath = value;
                return true;
            } else {
                return false;
            }
        }
    }

    /**
     * Org-portal person representation query configuration container.
     * Extends on general X-Road query config {@link SingleQueryConf} with
     * added query request and response parameters such as where to put the user id
     * in request and which fields to read the response from.
     * 
     * In principle, the query is similar to {@link UnitAuthQuery}, its input is also
     * user ssn, however the ouput is much more verbose.
     */
    public static class OrgPortalAuthQueryConf extends SingleQueryConf {
        private String requestPersonCodeXpath;

        private String responseRegisterCodeXpath;
        private String responseStatusXpath;
        private String responseOrgsXpath;
        private String responseOrgNameXpath;
        private String responseOrgMemberClassXpath;
        private String defaultResponseOrganizationMemberClass;
        private String responseReprXpath;
        private String responseReprGivennameXpath;
        private String responseReprSurnameXpath;
        private String responseReprSsnXpath;
        private String responseReprRightsXpath;

        private String responseRegistryStatusOkValue;
        private String responseRepresentationRightNotSingleValue;
        private String responseRepresentationRightSingleValue;
        private String responseRepresentationRightUnknownValue;

        /**
         * Set defaults. Org-portal v5 configuration is used for defaults.
         * @param configuration org-portal configuration
         */
        public OrgPortalAuthQueryConf(Configuration configuration) {
            super();
            setNamespace(configuration.getString("producer_namespace"));
            requestPersonCodeXpath = configuration.getString("xpath.request_id_code");
            responseRegisterCodeXpath = configuration.getString("xpath.registration_code");
            responseStatusXpath = configuration.getString("xpath.organization.status");
            responseOrgsXpath = configuration.getString("xpath.single_organization");
            responseOrgNameXpath = configuration.getString("xpath.organization.name");
            // member class is allowed to be empty in configuration, because it
            // does not exist in original X-Road v5 conf
            responseOrgMemberClassXpath = configuration.containsKey("xpath.organization.member_class")
                    ? configuration.getString("xpath.organization.member_class") : null;
            defaultResponseOrganizationMemberClass = "COM";
            responseReprXpath = configuration.getString("xpath.organization.representatives");
            responseReprGivennameXpath = configuration.getString("xpath.representative.givenname");
            responseReprSurnameXpath = configuration.getString("xpath.representative.name");
            responseReprSsnXpath = configuration.getString("xpath.representative.id_code");
            responseReprRightsXpath = configuration.getString("xpath.my.representation_right");

            responseRegistryStatusOkValue = configuration.getString("registry.status.ok");
            responseRepresentationRightNotSingleValue = configuration.getString("representation_right.not_single");
            responseRepresentationRightSingleValue = configuration.getString("representation_right.single");
            responseRepresentationRightUnknownValue = configuration.getString("representation_right.unknown");
        }

        /**
         * @return a string of configuration parameter names and values, mostly for debugging/tracing purposes
         */
        public String toString() {
            return "OrgPortalConf:\n\tnamespace: " + getNamespace() + "\n" + "\trequestPersonCodeXpath: "
                    + requestPersonCodeXpath + "\n" + "\tresponseRegisterCodeXpath: " + responseRegisterCodeXpath + "\n"
                    + "\tresponseStatusXpath: " + responseStatusXpath + "\n" + "\tresponseOrgsXpath: "
                    + responseOrgsXpath + "\n" + "\tresponseOrgNameXpath: " + responseOrgNameXpath + "\n"
                    + "\tresponseOrgMemberClassXpath: " + responseOrgMemberClassXpath + "\n" + "\tresponseReprXpath: "
                    + responseReprXpath + "\n" + "\tresponseReprGivennameXpath: " + responseReprGivennameXpath + "\n"
                    + "\tresponseReprSurnameXpath: " + responseReprSurnameXpath + "\n" + "\tresponseReprSsnXpath: "
                    + responseReprSsnXpath + "\n" + "\tresponseReprRightsXpath: " + responseReprRightsXpath + "\n"

                    + "\tresponseRegistryStatusOkValue: " + responseRegistryStatusOkValue + "\n"
                    + "\tresponseRepresentationRightNotSingleValue: " + responseRepresentationRightNotSingleValue + "\n"
                    + "\tresponseRepresentationRightSingleValue: " + responseRepresentationRightSingleValue + "\n"
                    + "\tresponseRepresentationRightUnknownValue: " + responseRepresentationRightUnknownValue + "\n";
        }

        /*
         * #Those keys can be used in conf (values here are samples that have to
         * be replaced with real service parameters)
         * auth.aktorstest3.xroad_instance = 0
         * auth.aktorstest3.member_code = 1
         * auth.aktorstest3.subsystem_code = 2
         * auth.aktorstest3.service_code = 3
         * auth.aktorstest3.service_version = 4
         * auth.aktorstest3.request_person_code_xpath = 5
         * auth.aktorstest3.response_registration_code_xpath = 6
         * auth.aktorstest3.response_organization_status_xpath = 7
         * auth.aktorstest3.response_single_organization_xpath = 8
         * auth.aktorstest3.response_organization_name_xpath = 9
         * auth.aktorstest3.response_organization_representatives_xpath = 10
         * auth.aktorstest3.response_representative_givenname_xpath = 11
         * auth.aktorstest3.response_representative_name_xpath = 12
         * auth.aktorstest3.response_representative_person_code_xpath = 13
         * auth.aktorstest3.response_my_representation_right_xpath = 14
         * auth.aktorstest3.response_registry_status_ok_value = 15
         * auth.aktorstest3.response_representation_right_not_single_value = 16
         * auth.aktorstest3.response_representation_right_single_value = 17
         * auth.aktorstest3.response_representation_right_unknown_value = 18
         */
        @Override
        public boolean set(String key, String value) {
            boolean setInSuper = super.set(key, value);
            if (setInSuper) {
                return true;
            } else if (key.equals("request_person_code_xpath")) {
                this.requestPersonCodeXpath = value;
                return true;
            } else if (key.equals("response_registration_code_xpath")) {
                this.responseRegisterCodeXpath = value;
                return true;
            } else if (key.equals("response_organization_status_xpath")) {
                this.responseStatusXpath = value;
                return true;
            } else if (key.equals("response_single_organization_xpath")) {
                this.responseOrgsXpath = value;
                return true;
            } else if (key.equals("default_response_organization_member_class")) {
                this.defaultResponseOrganizationMemberClass = value;
                return true;
            } else if (key.equals("response_organization_name_xpath")) {
                this.responseOrgNameXpath = value;
                return true;
            } else if (key.equals("response_organization_member_class_xpath")) {
                this.responseOrgMemberClassXpath = value;
                return true;
            } else if (key.equals("response_organization_representatives_xpath")) {
                this.responseReprXpath = value;
                return true;
            } else if (key.equals("response_representative_givenname_xpath")) {
                this.responseReprGivennameXpath = value;
                return true;
            } else if (key.equals("response_representative_name_xpath")) {
                this.responseReprSurnameXpath = value;
                return true;
            } else if (key.equals("response_representative_person_code_xpath")) {
                this.responseReprSsnXpath = value;
                return true;
            } else if (key.equals("response_my_representation_right_xpath")) {
                this.responseReprRightsXpath = value;
                return true;
            } else if (key.equals("response_registry_status_ok_value")) {
                this.responseRegistryStatusOkValue = value;
                return true;
            } else if (key.equals("response_representation_right_not_single_value")) {
                this.responseRepresentationRightNotSingleValue = value;
                return true;
            } else if (key.equals("response_representation_right_single_value")) {
                this.responseRepresentationRightSingleValue = value;
                return true;
            } else if (key.equals("response_representation_right_unknown_value")) {
                this.responseRepresentationRightUnknownValue = value;
                return true;
            } else {
                return false;
            }
        }

        /**
         * @return request person code element descriptor in XML structure
         */
        public String getRequestPersonCodeXpath() {
            return requestPersonCodeXpath;
        }

        /**
         * @return request person code XPath
         */
        public String getResponseRegisterCodeXpath() {
            return responseRegisterCodeXpath;
        }

        /**
         * @return request person code element descriptor in XML structure
         */
        public String getResponseStatusXpath() {
            return responseStatusXpath;
        }

        /**
         * @return XPath to organizations in service response
         */
        public String getResponseOrgsXpath() {
            return responseOrgsXpath;
        }

        /**
         * @return XPath to organization name in service response
         */
        public String getResponseOrgNameXpath() {
            return responseOrgNameXpath;
        }

        /**
         * @return  XPath to organization member class in service response
         */
        public String getResponseOrgMemberClassXpath() {
            return responseOrgMemberClassXpath;
        }

        /**
         * @return default organization member class
         */
        public String getDefaultResponseOrganizationMemberClass() {
            return defaultResponseOrganizationMemberClass;
        }

        /**
         * @return XPath to representation block in service response
         */
        public String getResponseReprXpath() {
            return responseReprXpath;
        }

        /**
         * @return XPath to representing person given name in service response
         */
        public String getResponseReprGivennameXpath() {
            return responseReprGivennameXpath;
        }

        /**
         * @return XPath to representing person surname in service response
         */
        public String getResponseReprSurnameXpath() {
            return responseReprSurnameXpath;
        }

        /**
         * @return XPath to representing person given SSN in service response
         */
        public String getResponseReprSsnXpath() {
            return responseReprSsnXpath;
        }

        /**
         * @return XPath to representation rights in service response
         */
        public String getResponseReprRightsXpath() {
            return responseReprRightsXpath;
        }

        /**
         * @return person registry status value marking a valid entity
         */
        public String getResponseRegistryStatusOkValue() {
            return responseRegistryStatusOkValue;
        }

        /**
         * @return expected value in response determining representation right is 'not single'
         */
        public String getResponseRepresentationRightNotSingleValue() {
            return responseRepresentationRightNotSingleValue;
        }

        /**
         * @return expected value in response determining 'single' representation right
         */
        public String getResponseRepresentationRightSingleValue() {
            return responseRepresentationRightSingleValue;
        }

        /**
         * @return expected value in response determining 'unknown' representation right
         */
        public String getResponseRepresentationRightUnknownValue() {
            return responseRepresentationRightUnknownValue;
        }
    }
}
