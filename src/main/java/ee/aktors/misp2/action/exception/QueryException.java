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

package ee.aktors.misp2.action.exception;

import java.util.ArrayList;
import java.util.List;

/**
 */
public class QueryException extends Exception implements Translatable {
    private static final long serialVersionUID = 6500358641992930660L;

    /**
     * Enumerator for QueryException type. Each {@link QueryException} has a type to classify it and to ease tracing the
     * exception origin.
     */
    public enum Type {
        UNSPECIFIED,
        WSDL_TO_XFORMS_XSL_TRANSFORMATION_FAILED,
        WSDL_MAX_SCHEMA_DEPTH_EXCEEDED("queries.error.wsdl_max_schema_depth_exceeded"),
        WSDL_TO_XFORMS_READING_INPUT_FAILED,
        WSDL_URL_IS_MISSING("queries.note.wsdl_url_missing"),
        WSDL_IS_MISSING_FROM_RESPONSE,
        WSDL_HAS_SOAP_FAULT,
        WSDL_READING_FAILED,
        WSDL_XROAD_NAMESPACE_NOT_FOUND,
        WSDL_AND_CONFIG_XROAD_NAMESPACE_MISMATCH("queries.note.wsdl_namespace_mismatch"),
        WSDL_MISSING_OPERATION,
        OPENAPI_PARSING_FAILED,
        OPENAPI_MODEL_NOT_VALID, 
        OPENAPI_QUERY_NOT_FOUND;

        private String i18nCode;

        Type() {
            // default is a generic-failed message
            this.i18nCode = "queries.note.not_updated";
        }

        /**
         * @param i18nCode custom i18n error translation code
         */
        Type(String i18nCode) {
            this.i18nCode = i18nCode;
        }

        /**
         * @return i18n error translation code
         */
        public String getCode() {
            return i18nCode;
        }
    }

    private Type type;

    /**
     * @param type type of query exception
     * @param message message for exception
     * @param e exception
     */
    public QueryException(Type type, String message, Throwable e) {
        super(type + " " + message, e);
        this.type = type;
    }

    @Override
    public String getTranslationCode() {
        return type.getCode();
    }

    @Override
    public List<String> getParameters() {
        return new ArrayList<String>(0);
    }
}
