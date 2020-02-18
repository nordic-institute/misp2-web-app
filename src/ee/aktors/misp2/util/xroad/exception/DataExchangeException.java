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

package ee.aktors.misp2.util.xroad.exception;

import java.util.ArrayList;
import java.util.List;

import ee.aktors.misp2.action.exception.Translatable;

/**
 * Exception wrapper for X-Road query exceptions and other higher level data exchange exceptions,
 * e.g. X-Road TIS HL7 exceptions, etc.
 * 
 * @author sander.kallo
 *
 */
public class DataExchangeException extends Exception  implements Translatable {
    private static final long serialVersionUID = 3541838647362621840L;

    /**
     * Enumerator for DataExchangeException type. Each {@link DataExchangeException} has a type to
     * classify it and to ease tracing the exception origin.
     */
    public enum Type {
        UNSPECIFIED,
        NO_RESPONSE,
        XROAD_USER_PERSONAL_CODE_MISSING,
        XROAD_USER_ORGANIZATION_CODE_MISSING,
        XROAD_SOAP_HEADER_INIT_FAILED,
        XROAD_SOAP_BODY_INIT_FAILED,
        XROAD_SOAP_CONNECTION_CLOSING_FAILED,
        XROAD_SOAP_MESSAGE_SENDING_FAILED,
        XROAD_DUMMY_RESPONSE_COULD_NOT_BE_SET,
        XROAD_SOAP_MESSAGE_BUILDER_INIT_FAILED,
        XROAD_SOAP_RESPONSE_FAULT,
        XROAD_SOAP_RESPONSE_FAULT_CHECK_FAILED,
        XROAD_SOAP_RESPONSE_PROCESSING_FAILED,
        XROAD_SECURITY_SERVER_URL_MISSING,
        XROAD_SECURITY_SERVER_URL_MALFORMED,
        XROAD_PRODUCER_MISSING,
        XROAD_MEDIATOR_SOAP_REQUEST_COULD_NOT_BE_READ,
        XROAD_MEDIATOR_SOAP_REQUEST_COULD_NOT_BE_ALTERED,
        XROAD_MEDIATOR_SOAP_RESPONSE_COULD_NOT_BE_READ,
        XROAD_MEDIATOR_SOAP_REQUEST_ATTACHMENT_PROCESSING_FAILED,
        XROAD_MEDIATOR_SOAP_RESPONSE_ATTACHMENT_EXTRACTION_FAILED,
        XROAD_MEDIATOR_SOAP_RESPONSE_CONVERSION_TO_TEXT_XML_FAILED,
        XROAD_QUERY_NOT_ALLOWED_IN_PORTAL,
        TIMEOUT,
        XROAD_INSTANCE_QUERY_NOT_ADMIN,
        XROAD_INSTANCE_QUERY_URL_MISSING,
        XROAD_INSTANCE_QUERY_MALFORMED_URL,
        XROAD_INSTANCE_QUERY_CONNECTION_FAILED,
        XROAD_INSTANCE_QUERY_HTTP_ERROR,
        XROAD_INSTANCE_QUERY_ZIP_MISSING,
        XROAD_INSTANCE_QUERY_ZIP_READING_FAILED,
        XROAD_INSTANCE_QUERY_ZIP_IDENTIFIER_MISSING,
        XROAD_INSTANCE_NOT_ACTIVE_FOR_PORTAL,
        READING_FROM_URL_PROTOCOL_NOT_ALLOWED,
        READING_FROM_URL_FAILED, 
        EULA_USER_NOT_FOUND, 
        EULA_NOT_USED_IN_PORTAL, 
        EULA_ALREADY_ACCEPTED,
        XROAD_REST_METHOD_MISSING, 
        XROAD_REST_PORTAL_MISSING,
        XROAD_REST_ORG_MISSING,
        XROAD_REST_USER_MISSING,
        XROAD_REST_SERVICE_IDENTIFIER_INVALID, 
        XROAD_REST_QUERY_ID_MISSING, 
        XROAD_REST_QUERY_ID_NOT_INTEGER,
        XROAD_REST_QUERY_NOT_FOUND, 
        XROAD_REST_QUERY_NOT_ALLOWED_FOR_USER,
        XROAD_REST_REQUEST_DOES_NOT_MATCH_FORM,
        XROAD_REST_HEADER_INIT_FAILED,
        XROAD_REST_RESPONSE_INVALID_JSON_FORMAT,
        XROAD_REST_RESPONSE_INVALID_OPENAPI_FORMAT,
        XROAD_REST_RESPONSE_ERROR;

        private String description;
        
        Type() {
            this.description = "";
        }
        Type(String message) {
            this.description = message;
        }
        /**
         * @return exception type description if given in constructor
         */
        public String getDescription() {
            return description;
        }
    }
    protected Type type;
    protected String faultString;
    protected String faultCode;
    protected String internalMessage;
    
    protected List<String> parameters;

    /**
     * Construct {@link DataExchangeException} which is main error mechanism in
     * {@link ee.aktors.misp2.util.xroad} and its sub-packages
     * <br><b>NB! Type may not be null!</b>
     * @param type each thrown error has a type which describes the error in general terms
     * @param message a specific additional message
     * @param parameters variable length array of error message parameters
     */
    public DataExchangeException(Type type, String message) {
        super(type.toString() + ": " + message);
        this.internalMessage = message;
        this.type = type;
        this.faultCode = null;
        this.faultString = null;
        this.parameters = new ArrayList<String>();
        for (String parameter : parameters) {
            this.parameters.add(parameter);
        }
    }

    /**
     * Construct {@link DataExchangeException} which is main error mechanism in
     * {@link ee.aktors.misp2.util.xroad} and its sub-packages
     * <br><b>NB! Type may not be null!</b>
     * @param type each thrown error has a type which describes the error in general terms
     * @param message a specific additional message
     * @param e thrown error
     * @param parameters variable length array of error message parameters
     */
    public DataExchangeException(Type type, String message, Throwable e, String... parameters) {
        super(type.toString() + ": " + message, e);
        this.internalMessage = message;
        this.type = type;
        this.faultCode = null;
        this.faultString = null;
        this.parameters = new ArrayList<String>();
        for (String parameter : parameters) {
            this.parameters.add(parameter);
        }
    }
    
    
    /**
     * Construct  {@link DataExchangeException} with additional faultCode and faultString which can
     * be used for SOAP faults and HL7 errors.
     * @param type each thrown error has a type which describes the error in general terms
     * @param message a specific additional message (not intended for user generally)
     * @param faultCode additional error code returned by far end (could be shown to user)
     * @param faultString additional error message returned by far end (could be shown to user)
     * @param e thrown exception, can be null
     */
    public DataExchangeException(Type type, String message, String faultCode, String faultString, Throwable e) {
        super(type.toString() + ": " + message
                + (faultCode != null || faultString != null
                ? " | " + faultCode + " " + faultString : ""), e);
        this.internalMessage = message;
        this.type = type;
        this.faultCode = faultCode;
        this.faultString = faultString;
        this.parameters = new ArrayList<String>();
    }
    
    /**
     * @return exception parameters if given
     */
    public List<String> getParameters() {
        return this.parameters;
    }

    /**
     * Get current wrapper exception type. Type is used for mapping to i18n translations of error messages.
     * @return type
     */
    public Type getType() {
        return type;
    }

    /**
     * @return fault text of remote system (null if not set)
     */
    public String getFaultString() {
        return faultString;
    }

    /**
     * @return fault code of remote system (null if not set)
     */
    public String getFaultCode() {
        return faultCode;
    }

    /**
     * @return error message additional human readable explanation that is logged,
     * but not shown to the user normally
     */
    public String getInternalMessage() {
        return internalMessage;
    }
    
    /**
     * @return i18n translation code corresponding to this message
     */
    public String getTranslationCode() {
        // DataExchangeException error messages are not currently added to i18n properties
        // nor used, instead MISP2 existing error messaging is used
        return "error.dataexchange." + this.type.toString();
    }

    /**
     * @return true if exception also contains additional fault (probably SOAP fault)
     */
    public boolean hasFault() {
        return faultCode != null || faultString != null;
    }
    /**
     * @return faultCode with faultString if these are registered
     */
    public String getFaultSummary() {
        if (!hasFault()) return "";
        return " (" + (faultCode != null ? faultCode : "")
                + (faultCode != null && faultString != null ? ": " : "")
                + (faultString != null ? faultString : "") + ")";
    }
    
}

