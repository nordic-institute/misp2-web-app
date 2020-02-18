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

package ee.aktors.misp2.util.xroad.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException.Type;
import ee.aktors.misp2.util.xroad.rest.model.ErrorResponse;
import ee.aktors.misp2.util.xroad.soap.identifier.XRoad6ClientIdentifierData;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;

/**
 * Base class for X-Road REST queries
 */
abstract public class XRoadRestQuery {

    private static Logger logger = LogManager.getLogger(XRoadRestQuery.class);

    private static final String HEADER_X_ROAD_CLIENT = "X-Road-Client";
    private static final String REST_SERVICE_CONSTANT = "r1";

    private final ObjectMapper objectMapper;
    private final boolean clientHeaderRequired;

    private Producer producer;
    private String producerBaseUrl;
    private String xRoadClientHeaderValue;

    protected XRoadRestQuery(Producer producer) throws DataExchangeException {
        this(producer, true);
    }

    protected XRoadRestQuery(Producer producer, boolean clientHeaderRequired) throws DataExchangeException {
        this.objectMapper = new ObjectMapper();
        this.clientHeaderRequired = clientHeaderRequired;

        if(producer != null) {
            this.producer = producer;
            this.producerBaseUrl = joinUriPath(
                    producer.getPortal().getSecurityHost(),
                    REST_SERVICE_CONSTANT,
                    producer.getXroadIdentifier(Const.URL_PATH_SEPARATOR));

            Map<String, Object> session = ActionContext.getContext().getSession();
            Portal portal = (Portal) session.get(Const.SESSION_PORTAL);
            Org org = (Org) session.get(Const.SESSION_ACTIVE_ORG);
            XRoad6ClientIdentifierData clientData = new XRoad6ClientIdentifierData(portal, org);

            this.xRoadClientHeaderValue = clientData.getRestClientIdentifier();
        }

        if(clientHeaderRequired && StringUtils.isBlank(xRoadClientHeaderValue)) {
            String errorMessage = String.format("Header %s is required but is missing", HEADER_X_ROAD_CLIENT);
            logger.error(errorMessage);
            throw new DataExchangeException(DataExchangeException.Type.XROAD_REST_HEADER_INIT_FAILED, errorMessage);
        }
    }

    /**
     * Fetches uri and parses response json into pojo
     * @param uri uri for request
     * @param responseClass class to which request response json is parsed into
     * @param <M> response class
     * @return pojo
     * @throws DataExchangeException if connection fails or unable to parse response
     */
    protected <M> M fetch(URI uri, Class<M> responseClass) throws DataExchangeException {
        try {
            return objectMapper.readValue(fetch(uri), responseClass);
        } catch (IOException e) {
            String errorMessage = String.format("REST X-Road response in unknown format for uri: %s", uri.toString());
            logger.error(errorMessage);
            throw new DataExchangeException(DataExchangeException.Type.XROAD_REST_RESPONSE_INVALID_JSON_FORMAT, errorMessage);
        }
    }


    /**
     * Fetches uri
     * @param uri uri for request
     * @return pojo
     * @throws DataExchangeException if connection fails or unable to parse response
     */
    protected String fetch(URI uri) throws DataExchangeException {
        logger.info(String.format("REST X-Road request to %s", uri));
        HttpGet request = new HttpGet(uri);
        request.addHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE);
        if (clientHeaderRequired) {
            request.addHeader(HEADER_X_ROAD_CLIENT, xRoadClientHeaderValue);
        }
        try (CloseableHttpClient httpClient = HttpClients.createDefault();
            CloseableHttpResponse response = httpClient.execute(request)) {
            HttpEntity entity = response.getEntity();
            if (entity != null) {
                logger.debug(String.format("REST X-Road response for %s", uri));
                String responseJson = EntityUtils.toString(entity);
                try {
                    ErrorResponse errorResponse = objectMapper.readValue(responseJson, ErrorResponse.class);

                    String errorMessage = String.format("REST X-Road error response from %s. %s", uri.toString(), errorResponse);
                    logger.error(errorMessage);
                    throw new DataExchangeException(Type.XROAD_REST_RESPONSE_ERROR, errorMessage);
                } catch (IOException e) {
                    return responseJson;
                }

            } else {
                String errorMessage = String.format("REST X-Road no response for uri: %s", uri.toString());
                logger.error(errorMessage);
                throw new DataExchangeException(DataExchangeException.Type.NO_RESPONSE, errorMessage);
            }
        } catch (IOException e) {
            String errorMessage = String.format("REST X-Road request failed for uri %s", uri);
            logger.error(errorMessage, e);
            throw new DataExchangeException(DataExchangeException.Type.XROAD_INSTANCE_QUERY_CONNECTION_FAILED, errorMessage, e);
        }
    }


    /**
     * Joins uri parts into one, does not check validity
     * @param parts uri parts to join
     * @return joined uri
     */
    protected String joinUriPath(String... parts) {
        return String.join(Const.URL_PATH_SEPARATOR, parts);
    }

    /**
     * Adds params to uri
     * @param uri uri to add the params to
     * @param parameters name/value pairs
     * @return URI with given uri and parameters
     * @throws DataExchangeException if header name/values aren't in pairs
     */
    protected URI buildUri(String uri, String... parameters) throws DataExchangeException {
        try {
            URIBuilder uriBuilder = new URIBuilder(uri);
            if(parameters.length % 2 != 0) {
                String message = String.format("Received %d header name/values. Header name/values must come in pairs", parameters.length);
                throw new DataExchangeException(Type.XROAD_SOAP_HEADER_INIT_FAILED, message);
            }
            for (int i = 0; i < parameters.length; i++) {
                String paramName = parameters[i];
                String paramValue = parameters[++i];
                uriBuilder.addParameter(paramName, paramValue);
            }
            return uriBuilder.build();
        } catch (URISyntaxException e) {
            String errorMessage = String.format("REST X-Road uri incorrect syntax: %s", uri);
            logger.error(errorMessage);
            throw new DataExchangeException(DataExchangeException.Type.XROAD_INSTANCE_QUERY_MALFORMED_URL, errorMessage);
        }
    }

    protected String getProducerBaseUrl() {
        return producerBaseUrl;
    }

    public Producer getProducer() {
        return producer;
    }
}
