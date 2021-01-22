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

package ee.aktors.misp2.action;

import java.util.List;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.service.PortalService;

/**
 *
 * @author arnis.rips
 */
public class SearchQueriesAction extends QuickTipAction {

    private static final long serialVersionUID = 1L;
    private String searchCriteria;
    private PortalService portalService;
    private List<Query> querySearchResults;

    /**
     * @param portalService portalService to inject
     */
    public SearchQueriesAction(PortalService portalService) {
        this.portalService = portalService;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String search() {
        querySearchResults = portalService.filterSearchQueries(org, user, searchCriteria, portal);
        return SUCCESS;
    }

/**
     * @return the searchCriteria
     */
    public String getSearchCriteria() {
        return searchCriteria;
    }

    /**
     * @param searchCriteriaNew the searchCriteria to set
     */
    public void setSearchCriteria(String searchCriteriaNew) {
        this.searchCriteria = searchCriteriaNew;
    }

    /**
     * @return the querySearchResults
     */
    public List<Query> getQuerySearchResults() {
        return querySearchResults;
    }
}
