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

package ee.aktors.misp2.util.xroad.rest.query;

import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.rest.XRoadRestQuery;
import ee.aktors.misp2.util.xroad.rest.model.ListClientsResponse;
import java.net.URI;
import java.util.List;
import org.apache.commons.lang3.StringUtils;

public class ListClientsQuery extends XRoadRestQuery {

    private static final String QUERY_LIST_CLIENTS = "listClients";
    public static final String PARAM_X_ROAD_INSTANCE = "xRoadInstance";

    private final Portal portal;

    public ListClientsQuery(Portal portal) throws DataExchangeException {
        super(null, false);
        this.portal = portal;
    }

    /**
     * Gets info about all producers or all producer with given instance code
     * @param instCode optional, results limited to given instance code
     * @return info about available producers
     * @throws DataExchangeException when unable to connect or parse the result
     */
    public List<ListClientsResponse.ProducerInfo> fetchProducerInfo(String instCode) throws DataExchangeException {
        String requestUri = joinUriPath(portal.getSecurityHost(), QUERY_LIST_CLIENTS);
        URI uri;
        if(StringUtils.isNotBlank(instCode)) {
            uri = buildUri(requestUri, PARAM_X_ROAD_INSTANCE, instCode);
        } else {
            uri = buildUri(requestUri);
        }
        ListClientsResponse response = fetch(uri, ListClientsResponse.class);
        return response.getMember();
    }
}
