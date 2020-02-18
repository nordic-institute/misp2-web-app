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

package ee.aktors.misp2.util.xroad.soap.wsdl;

import java.util.ArrayList;
import java.util.List;

import org.jsoup.helper.StringUtil;

import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.service.QueryService;

/**
 * Container for query list, initialized from comma-separated list of {@link Query} entity IDs.
 * Enables retrieving list of query ID-s and also list of query operation names.
 * @author sander.kallo
 *
 */
public class QueryCollector {
    private List<Query> queries;
    private QueryService queryService;
    
    /**
     * Construct class from comma separated list of query ID-s
     * @param queryServiceNew service for DB access
     * @param queryIds list of query ID-s
     */
    public QueryCollector(QueryService queryServiceNew, List<Integer> queryIds) {
        queries = null;
        this.queryService = queryServiceNew;
        queries = new ArrayList<Query>();
        
        for (Integer queryId : queryIds) {
            Query query = queryService.findObject(Query.class, queryId);
            queries.add(query);
        }
    }
    
    /**
     * @param separator text used to separate different operations in response string
     * @return list of collected WSDL operation names
     */
    public String getQueryOperationNames(String separator) {
        List<String> operationNames = new ArrayList<String>();
        for (Query query: queries) {
            operationNames.add(query.getServiceCode());
        }
        return StringUtil.join(operationNames, separator);
    }
}
