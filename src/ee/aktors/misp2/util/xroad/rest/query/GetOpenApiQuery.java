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

package ee.aktors.misp2.util.xroad.rest.query;

import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.util.openapi.OpenApiParser;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.rest.XRoadRestQuery;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URI;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class GetOpenApiQuery extends XRoadRestQuery {

    public static final String UTF_8 = "UTF-8";
    private static Logger logger = LogManager.getLogger(XRoadRestQuery.class);

    private static final String QUERY_GET_OPENAPI = "getOpenAPI";
    private static final String PARAMETER_SERVICE_CODE = "serviceCode";

    public GetOpenApiQuery(Producer producer) throws DataExchangeException {
        super(producer);
    }

    /**
     * Get OpenApi of service
     * @param serviceCode service which openApi to get
     * @return openApi of given service
     * @throws DataExchangeException when request fails or unable to parse OpenApi
     */
    public OpenApiParser fetchOpenApi(String serviceCode) throws DataExchangeException {
        String requestUri = joinUriPath(getProducerBaseUrl(), QUERY_GET_OPENAPI);
        File temp = null;
        try {
            URI uri = buildUri(requestUri, PARAMETER_SERVICE_CODE, serviceCode);

            String file_name = String.format("%s_%d", getProducer().getShortName(), System.currentTimeMillis());
            String suffix = ".openapi";
            temp = File.createTempFile(file_name, suffix);

            try(FileOutputStream fileOutputStream = new FileOutputStream(temp)) {
                String response = fetch(uri);
                IOUtils.write(response, fileOutputStream, UTF_8);
            }
            try {
                return new OpenApiParser(temp);
            } catch (Exception e){
                String errorMessage = String.format("Failed to parse openApi response for uri %s", uri.toString());
                logger.debug(errorMessage);
                throw new DataExchangeException(DataExchangeException.Type.XROAD_REST_RESPONSE_INVALID_OPENAPI_FORMAT, errorMessage);
            }

        } catch (IOException e) {
            String errorMessage = "Failed to create temporary file for openApi";
            logger.error(errorMessage);
            throw new DataExchangeException(DataExchangeException.Type.UNSPECIFIED, errorMessage);
        } finally {
            if(temp != null) {
                temp.delete();
            }
        }
    }
}
