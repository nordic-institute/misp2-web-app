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

package ee.aktors.misp2.util.xroad.rest.query;

import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.rest.XRoadRestQuery;
import ee.aktors.misp2.util.xroad.rest.model.ListMethodsResponse;
import java.util.List;

public class ListMethodsQuery extends XRoadRestQuery {


    private static final String QUERY_LIST_METHODS = "listMethods";
    private static final String QUERY_ALLOWED_METHODS = "allowedMethods";

    public ListMethodsQuery(Producer producer) throws DataExchangeException {
        super(producer);
    }

    /**
     * Gets info about allowed/all services/queries
     * @param allowedOnly fetch only methods that are allowed for the producer
     * @return info about queries allowed to the producer
     * @throws DataExchangeException when unable to connect or parse the result
     */
    public List<ListMethodsResponse.QueryInfo> fetchQueries(boolean allowedOnly) throws DataExchangeException {
        String requestUri = joinUriPath(getProducerBaseUrl(), allowedOnly ? QUERY_ALLOWED_METHODS : QUERY_LIST_METHODS);
        ListMethodsResponse response = fetch(buildUri(requestUri), ListMethodsResponse.class);
        return response.getService();
    }
}
