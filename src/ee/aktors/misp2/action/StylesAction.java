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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.Action;

import ee.aktors.misp2.beans.Auth;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.model.Xslt;
import ee.aktors.misp2.service.StylesService;
import ee.aktors.misp2.util.CheckXML;
import ee.aktors.misp2.util.Const;

/**
 */
public class StylesAction extends SessionPreparedBaseAction implements IManagementAction {

    private static final long serialVersionUID = 1L;
    // ------------------- Used internally --------------
    private StylesService sService;
    // ------------------- Form items -------------------
    private Xslt xslt;
    private String queryName;
    private List<Producer> producers;
    private boolean inUse;
    private Integer producerId;
    private boolean urlChanged;
    private Integer queryId;
    private List<Query> producersQueries = new ArrayList<Query>();
    // --------------------------------------------------
    // ----------------- Filter items -------------------
    private String filterName;
    private String filterProducer;
    private String filterQuery;
    private List<Xslt> searchResults;
    private Integer styleId;
    private Map<Integer, String> producerNames;
    private int pageNumber;
    private long itemCount;
    private final int pageSize = 25;
    // --------------------------------------------------
    private static final Logger LOG = LogManager.getLogger(StylesAction.class);

    /**
     * @param service serviceto inject
     */
    public StylesAction(StylesService service) {
        this.sService = service;
    }

    @Override
    public void prepare() throws Exception {
        super.prepare();
        if (((Auth) session.get(Const.SESSION_AUTH)).isAdmin()) {
            portal = null;
        }

        producers = sService.findAllProducers(portal);
        if (styleId != null) {

            xslt = sService.findObject(Xslt.class, styleId);

        } else {
            if (xslt != null) {
                styleId = xslt.getId();
            }
        }
    }
    
    @Override
    public void validate() {
        if (xslt != null && xslt.getXsl() != null) {
            if (xslt.getXsl().trim().isEmpty() && xslt.getUrl().trim().isEmpty()) {
                addFieldError("xslt.url", getText("validation.input_required"));
            }
            if (!CheckXML.checkSyntax(xslt.getXsl())) {
                addFieldError("xslt.xsl", getText("validation.syntax"));
            }
        }
        for (List<String> s : getFieldErrors().values()) {
            setActionErrors(s);
        }
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String addItem() {
        return SUCCESS;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String showItem() {
        if (xslt != null) {
            if (!isAllowed(xslt)) {
                LOG.debug("User doesn't have rights for xslt");
                addActionError(getText("text.error.item_not_allowed"));
                return ERROR;
            }
            producersQueries = sService.findQueries(xslt.getProducerId(), "");
            queryId = (xslt.getQueryId() != null ? xslt.getQueryId().getId() : null);
        }
        return SUCCESS;
    }

    /**
     * @return SUCCESS if queries to list are found, ERROR otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String listQueries() {
        if (producerId != null) {
            producersQueries = sService.findQueries(producerId, "");
            return Action.SUCCESS;
        }
        return Action.ERROR;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String deleteItem() {
        try {
            if (styleId != null) {
                Xslt xs = null;
                xs = sService.findObject(Xslt.class, styleId);
                if (xs != null) {
                    if (!isAllowed(xs)) {
                        addActionError(getText("text.error.item_not_allowed"));
                        return ERROR;
                    }
                    sService.remove(xs);
                    addActionMessage(getText("text.success.delete"));
                    return SUCCESS;
                } else {
                    LOG.error("No xslt found for id=" + styleId + ". Nothing was deleted");
                }
            } else {
                LOG.error("Style id not set styleId=" + styleId + ". Nothing was deleted");
            }
        } catch (Exception e) {
            LOG.error(e.getMessage(), e);
        }
        addActionError(getText("text.fail.delete"));
        return ERROR;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String submitItem() {
        if (xslt != null) {
            if (xslt.getId() != null && !isAllowed(xslt)) {
                addActionError(getText("text.error.item_not_allowed"));
                return ERROR;
            }

            xslt.setInUse(inUse);
            xslt.setPortal(portal);

            if (queryId != null) {
                xslt.setQueryId(sService.findObject(Query.class, queryId));
            } else {
                xslt.setQueryId(null);
            }
            try {
                sService.save(xslt);
                addActionMessage(getText("text.success.save"));
            } catch (Exception e) {
                LOG.error(e.getMessage(), e);
                addActionError(getText("text.fail.save"));
                return ERROR;
            }
            styleId = xslt.getId();
        }
        return SUCCESS;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String filter() {
        producerNames = new HashMap<Integer, String>();
        List<Producer> aps = sService.findAllProducers(portal);
        for (Producer p : aps) {
            producerNames.put(p.getId(), p.getShortName());
        }
        searchResults = sService.findXslts(portal, filterName, filterProducer, filterQuery, pageNumber, pageSize);
        itemCount = sService.countXslts(portal, filterName, filterProducer, filterQuery);
        return SUCCESS;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String showFilter() {
        return filter();
    }

    private boolean isAllowed(Xslt xsltIn) {
        Auth auth = (Auth) session.get(Const.SESSION_AUTH);
        if (auth != null && auth.isAdmin()) {
            return xsltIn.getPortal() == null;
        }
        return portal.equals(xsltIn.getPortal());
    }

    // ------------------- Form item getters/setters -------------------

    /**
     * @return the queryName
     */
    public String getQueryName() {
        return queryName;
    }

    /**
     * @return the producers
     */
    public List<Producer> getProducers() {
        return producers;
    }

    /**
     * @param queryNameNew the queryName to set
     */
    public void setQueryName(String queryNameNew) {
        this.queryName = queryNameNew;
    }

    /**
     * @return the inUse
     */
    public boolean isInUse() {
        return inUse;
    }

    /**
     * @param inUseNew the inUse to set
     */
    public void setInUse(boolean inUseNew) {
        this.inUse = inUseNew;
    }

    /**
     * @return the xslt
     */
    public Xslt getXslt() {
        return xslt;
    }

    /**
     * @param xsltNew the xslt to set
     */
    public void setXslt(Xslt xsltNew) {
        this.xslt = xsltNew;
    }

    /**
     * @return the filterName
     */
    public String getFilterName() {
        return filterName;
    }

    /**
     * @param filterNameNew the filterName to set
     */
    public void setFilterName(String filterNameNew) {
        this.filterName = filterNameNew;
    }

    /**
     * @return the filterQuery
     */
    public String getFilterQuery() {
        return filterQuery;
    }

    /**
     * @param filterQueryNew the filterQuery to set
     */
    public void setFilterQuery(String filterQueryNew) {
        this.filterQuery = filterQueryNew;
    }

    /**
     * @return the searchResults
     */
    public List<Xslt> getSearchResults() {
        return searchResults;
    }

    /**
     * @param searchResultsNew the searchResults to set
     */
    public void setSearchResults(List<Xslt> searchResultsNew) {
        this.searchResults = searchResultsNew;
    }

    /**
     * @return the styleId
     */
    public Integer getStyleId() {
        return styleId;
    }

    /**
     * @param styleIdNew the styleId to set
     */
    public void setStyleId(Integer styleIdNew) {
        this.styleId = styleIdNew;
    }

    /**
     * @return the filterProducer
     */
    public String getFilterProducer() {
        return filterProducer;
    }

    /**
     * @return the producerId
     */
    public Integer getProducerId() {
        return producerId;
    }

    /**
     * @param producerIdNew the producerId to set
     */
    public void setProducerId(Integer producerIdNew) {
        this.producerId = producerIdNew;
    }

    /**
     * @return the urlChanged
     */
    public boolean isUrlChanged() {
        return urlChanged;
    }

    /**
     * @param urlChangedNew the urlChanged to set
     */
    public void setUrlChanged(boolean urlChangedNew) {
        this.urlChanged = urlChangedNew;
    }

    /**
     * @return the producersQueries
     */
    public List<Query> getProducersQueries() {
        return producersQueries;
    }

    /**
     * @param producersQueriesNew the producersQueries to set
     */
    public void setProducersQueries(List<Query> producersQueriesNew) {
        this.producersQueries = producersQueriesNew;
    }

    /**
     * @return the queryId
     */
    public Integer getQueryId() {
        return queryId;
    }

    /**
     * @return the producerNames
     */
    public Map<Integer, String> getProducerNames() {
        return producerNames;
    }

    /**
     * @param filterProducerNew the filterProducer to set
     */
    public void setFilterProducer(String filterProducerNew) {
        this.filterProducer = filterProducerNew;
    }

    /**
     * @param queryIdNew the queryId to set
     */
    public void setQueryId(Integer queryIdNew) {
        this.queryId = queryIdNew;
    }

    /**
     * @return the pageNumber
     */
    public int getPageNumber() {
        return pageNumber + 1;
    }

    /**
     * @param pageNumberNew pageNumber to set
     */
    public void setPageNumber(int pageNumberNew) {
        if ((pageNumberNew - 1) > -1) {
            this.pageNumber = pageNumberNew - 1;
        } else {
            this.pageNumber = 0;
        }
    }
    /**
     * @return the itemCount
     */
    public long getItemCount() {
        return itemCount;
    }

    /**
     * @return the pageSize
     */
    public int getPageSize() {
        return pageSize;
    }
}
