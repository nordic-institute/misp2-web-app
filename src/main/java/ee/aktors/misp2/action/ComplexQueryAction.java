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

package ee.aktors.misp2.action;

import ee.aktors.misp2.model.Producer.ProtocolType;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.Action;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgQuery;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.ProducerName;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.model.QueryName;
import ee.aktors.misp2.model.Xforms;
import ee.aktors.misp2.service.ProducerService;
import ee.aktors.misp2.service.QueryService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Const.QUERY_TYPE;
import ee.aktors.misp2.util.LanguageUtil;

/**
 */
public class ComplexQueryAction extends SessionPreparedBaseAction {
    private static final long serialVersionUID = 8942443447206121512L;
    private ArrayList<String> languages = LanguageUtil.getLanguages();
    private QueryService qService;
    private ProducerService pService;
    private List<Query> queries;
    private List<ProducerName> complexProducers;
    private Producer complexProducer;
    private List<Xforms> xformsList;
    private Query query;
    private List<QueryName> queryNames;
    private List<QueryName> cQueryDescriptions;
    private OrgQuery orgQuery;
    private Xforms xforms;
    private Integer queryId;
    private String xformsGroup;
    private TreeMap<String, Boolean> statesOfUpdatesMap;
    private List<ProducerName> cProducerDescriptions;
    private static final Logger LOG = LogManager.getLogger(ComplexQueryAction.class);
    private Integer id;
    /**
     * Default: {@link ProtocolType#SOAP}
     * Determines active tab in {@link ee.aktors.misp2.interceptor.MenuInterceptor#intercept}
     */
    private ProtocolType protocol;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    /**
     * @param qService qService to inject
     * @param pService pService to inject
     */
    public ComplexQueryAction(QueryService qService, ProducerService pService) {
        this.qService = qService;
        this.pService = pService;
    }
    
    @Override
    public void prepare() throws Exception {
        super.prepare();
        protocol = protocol == null ? ProtocolType.SOAP : protocol;
        if (getQueryId() != null) {
            setQuery(qService.findObject(Query.class, getQueryId()));
            // setQueryName(getQuery().getActiveName(getLocale().getLanguage()));

            initQueryNames();

            setOrgQuery(qService.findOrgQueryByOrgIdAndQueryId(org.getId(), getQuery().getId()));
            setXforms(qService.findXformEntityByQuery(getQuery().getId()));
            setId(getQuery().getProducer().getId());
        }
        if (getId() != null) {
            setComplexProducer(qService.reAttach(
                    qService.findObject(Producer.class, getId()), Producer.class));
        }

        initCProducerDescriptions();
    }

    @Override
    public void validate() {
        for (List<String> s : getFieldErrors().values()) {
            setActionErrors(s);
        }
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String complexProducerEdit() {
        return Action.SUCCESS;
    }

    /**
     * @return ERROR if could not validate SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String complexProducerSave() {
        getComplexProducer().setProtocol(protocol);
        getComplexProducer().setIsComplex(Boolean.TRUE);
        getComplexProducer().setPortal(portal);
        if (producerExists(getComplexProducer().getShortName())) {
            qService.save(getComplexProducer());
            // saveProducerName(getLocale().getLanguage());
            saveCProducerDescriptions();
            return Action.SUCCESS;
        } else {
            String msg = getText("validation.in_use", new String[] {getText("complex.edit.name") });
            addActionError(msg);
            return Action.ERROR;
        }
    }

    /**
     * @return ERROR if could not delete complex producer,SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String complexProducerDelete() {
        try {
            qService.remove(getComplexProducer());
            return Action.SUCCESS;
        } catch (Exception e) {
            LOG.debug("cannot delete complex producer");
            return Action.ERROR;
        }
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String listComplexQueries() {
        setQueries(qService.findComplexQueries(getComplexProducer()));
        LOG.debug("Queries: " + queries.size());
        setXformsList(qService.findAllProducerComplexXforms(getComplexProducer()));
        LOG.debug("XformsList: " + xformsList.size());
        LOG.debug("xformsGroup: " + getXformsGroup());
        if (getXformsGroup() != null) {
            try {
                TreeMap<String, Boolean> restults = qService.updateDescriptions(getXformsGroup(),
                        CONFIG.getString("misp2.internal.url"));
                setStatesOfUpdatesMap(restults);
                LOG.debug("xformsGroup: " + statesOfUpdatesMap.keySet().size());
                for (Map.Entry<String, Boolean> entry : statesOfUpdatesMap.entrySet()) {
                    String key = entry.getKey();
                    Boolean value = entry.getValue();
                    if (value)
                        addActionMessage(getText("xforms.note_refreshed." + protocol) + "(" + key + ")");
                    else
                        addActionError(getText("xforms.error_not_refreshed." + protocol) + "(" + key + ")");
                }
            } catch (Exception e) {
                LOG.error("Refreshing services failed ", e);
            }
        }
        return Action.SUCCESS;
    }

    /**
     * @return producerDescription
     */
    public String getProducerDescription() {
        return getComplexProducer().getActiveName(getLocale().getLanguage()).getDescription();
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String addComplexQuery() {
        Query q = new Query();
        q.setType(QUERY_TYPE.X_ROAD_COMPLEX.ordinal());
        setQuery(q);
        Xforms x = new Xforms();
        x.setUrl("http://");
        setXforms(x);
        /*
         * QueryName qn = new QueryName(); qn.setLang(getLocale().getLanguage()); setQueryName(qn);
         */

        initQueryNames();

        return Action.SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String changeComplexQuery() {
        return Action.SUCCESS;
    }

    /**
     * @return SUCCESS
     * @throws Exception can throw
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String saveComplexData() throws Exception {
        if (getQuery().getType() == null) {
            getQuery().setType(QUERY_TYPE.X_ROAD_COMPLEX.ordinal());
        }
        if (!qService.isQueryUnique(getQuery().getName(), getQuery().getOpenapiServiceCode(), getComplexProducer(), getQuery().getId())) {
            LOG.error("Complex service name/producer already exist, cannot save. Query ID: " + getQuery().getId());
            addFieldError("query.name", getText("services.query_not_unique"));
            validate();
            return Action.INPUT;
        }

        getQuery().setProducer(getComplexProducer());
        qService.save(getQuery());
        getXforms().setQuery(getQuery());
        saveQueryNames();

        if (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL) {
            OrgQuery oq = getOrgQuery();
            if (oq == null) {
                oq = new OrgQuery();
            }
            oq.setQueryId(getQuery());
            oq.setOrgId(org);
            qService.save(oq);
            Org supOrg = qService.reAttach((Org) session.get(Const.SESSION_ACTIVE_ORG), Org.class);
            if (supOrg.getSupOrgId() == null) { // if active org is suporg
                List<Org> suborgs = supOrg.getOrgList();
                for (Org suborg : suborgs) {
                    if (!qService.orgQueryExists(getQuery(), portal, suborg)) {
                        LOG.debug("adding org query for suborg " + suborg.getActiveName(getLocale().getLanguage()));
                        OrgQuery tempOrgQuery = new OrgQuery();
                        tempOrgQuery.setQueryId(getQuery());
                        tempOrgQuery.setOrgId(suborg);
                        qService.save(tempOrgQuery);
                    }
                }
            }
        } else {
            OrgQuery oq = getOrgQuery();
            if (oq == null) {
                oq = new OrgQuery();
            }
            oq.setQueryId(getQuery());
            oq.setOrgId(org);
            qService.save(oq);
        }
        qService.save(getXforms());
        return Action.SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String deleteComplex() {
        qService.remove(getQuery());
        return Action.SUCCESS;
    }

    private Boolean producerExists(String memberCode) {
        if (memberCode.isEmpty()) {
            return false;
        }
        Producer p = qService.findComplexProducerByName(memberCode, portal);
        if (getComplexProducer().getId() == null && p != null) {
            return false;
        } else if (getComplexProducer().getId() != null && p != null && !p.equals(getComplexProducer()))
            return false;
        else
            return true;
    }

    private void initQueryNames() {
        queryNames = new ArrayList<QueryName>();
        for (String language : languages) {
            QueryName queryName = null;
            if (queryId != null) {
                queryName = qService.findQueryName(query, language); // Take existing one
            }
            if (queryName == null) { // If existing one is not accessible or does not exist, then create new one
                queryName = new QueryName();
                queryName.setDescription("");
                queryName.setLang(language);
            }
            queryNames.add(queryName);
        }
    }

    private void saveQueryNames() {
        for (int i = 0; i < languages.size(); i++) {
            String language = languages.get(i);
            QueryName queryName = queryNames.get(i);

            queryName.setLang(language);
            String description = queryName.getDescription();

            QueryName existingQueryName = qService.findQueryName(query, language);
            queryName = (existingQueryName == null ? queryName : existingQueryName);
            // Use existing queryName entity if it exists
            queryName.setDescription(description);
            queryName.setLang(language);
            queryName.setQuery(query);
            qService.save(queryName);
        }
    }

    private void initCProducerDescriptions() {
        cProducerDescriptions = new ArrayList<ProducerName>();
        for (String language : languages) {
            ProducerName cProducerDescription = null;
            if (complexProducer != null) {
                cProducerDescription = pService.findProducerName(complexProducer, language); // Take existing one
            }
            if (cProducerDescription == null) {
                // If existing one is not accessible or does not exist, then create new one
                cProducerDescription = new ProducerName();
                cProducerDescription.setDescription("");
                cProducerDescription.setLang(language);
            }
            cProducerDescriptions.add(cProducerDescription);
        }
    }

    private void saveCProducerDescriptions() {
        for (int i = 0; i < languages.size(); i++) {
            String language = languages.get(i);
            ProducerName cProducerDescription = cProducerDescriptions.get(i);

            cProducerDescription.setLang(language);
            String description = cProducerDescription.getDescription();

            ProducerName existingCProducerDescription = pService.findProducerName(complexProducer, language);
            cProducerDescription =
                    existingCProducerDescription == null ? cProducerDescription : existingCProducerDescription;
            // Use existing producerName entity if it exists

            cProducerDescription.setDescription(description);
            cProducerDescription.setLang(language);
            cProducerDescription.setProducer(complexProducer);
            pService.save(cProducerDescription);
        }
    }

    
    public List<ProducerName> getcProducerDescriptions() {
        return cProducerDescriptions;
    }

    public void setcProducerDescriptions(List<ProducerName> cProducerDescriptions) {
        this.cProducerDescriptions = cProducerDescriptions;
    }

    /**
     * @return the languages
     */
    public ArrayList<String> getLanguages() {
        return languages;
    }

    /**
     * @param languagesNew the languages to set
     */
    public void setLanguages(ArrayList<String> languagesNew) {
        this.languages = languagesNew;
    }

    /**
     * @return the queries
     */
    public List<Query> getQueries() {
        return queries;
    }

    /**
     * @param queriesNew the queries to set
     */
    public void setQueries(List<Query> queriesNew) {
        this.queries = queriesNew;
    }

    /**
     * @return the complexProducers
     */
    public List<ProducerName> getComplexProducers() {
        return complexProducers;
    }

    /**
     * @param complexProducersNew the complexProducers to set
     */
    public void setComplexProducers(List<ProducerName> complexProducersNew) {
        this.complexProducers = complexProducersNew;
    }

    /**
     * @return the complexProducer
     */
    public Producer getComplexProducer() {
        return complexProducer;
    }

    /**
     * @param complexProducerNew the complexProducer to set
     */
    public void setComplexProducer(Producer complexProducerNew) {
        this.complexProducer = complexProducerNew;
    }

    /**
     * @return the xformsList
     */
    public List<Xforms> getXformsList() {
        return xformsList;
    }

    /**
     * @param xformsListNew the xformsList to set
     */
    public void setXformsList(List<Xforms> xformsListNew) {
        this.xformsList = xformsListNew;
    }

    /**
     * @return the query
     */
    public Query getQuery() {
        return query;
    }

    /**
     * @param queryNew the query to set
     */
    public void setQuery(Query queryNew) {
        this.query = queryNew;
    }

    /**
     * @return the orgQuery
     */
    public OrgQuery getOrgQuery() {
        return orgQuery;
    }

    /**
     * @param orgQueryNew the orgQuery to set
     */
    public void setOrgQuery(OrgQuery orgQueryNew) {
        this.orgQuery = orgQueryNew;
    }

    /**
     * @return the xforms
     */
    public Xforms getXforms() {
        return xforms;
    }

    /**
     * @param xformsNew the xforms to set
     */
    public void setXforms(Xforms xformsNew) {
        this.xforms = xformsNew;
    }

    /**
     * @return the queryId
     */
    public Integer getQueryId() {
        return queryId;
    }

    /**
     * @param queryIdNew the queryId to set
     */
    public void setQueryId(Integer queryIdNew) {
        this.queryId = queryIdNew;
    }

    /**
     * @return the queryNames
     */
    public List<QueryName> getQueryNames() {
        return queryNames;
    }

    /**
     * @param queryNamesNew the queryNames to set
     */
    public void setQueryNames(List<QueryName> queryNamesNew) {
        this.queryNames = queryNamesNew;
    }

    /**
     * @return the cQueryDescriptions
     */
    public List<QueryName> getcQueryDescriptions() {
        return cQueryDescriptions;
    }

    /**
     * @param cQueryDescriptionsNew the cQueryDescriptions to set
     */
    public void setcQueryDescriptions(List<QueryName> cQueryDescriptionsNew) {
        this.cQueryDescriptions = cQueryDescriptionsNew;
    }

    /**
     * @return the xformsGroup
     */
    public String getXformsGroup() {
        return xformsGroup;
    }

    /**
     * @param xformsGroupNew the xformsGroup to set
     */
    public void setXformsGroup(String xformsGroupNew) {
        this.xformsGroup = xformsGroupNew;
    }

    /**
     * @return the statesOfUpdatesMap
     */
    public TreeMap<String, Boolean> getStatesOfUpdatesMap() {
        return statesOfUpdatesMap;
    }

    /**
     * @param statesOfUpdatesMapNew the statesOfUpdatesMap to set
     */
    public void setStatesOfUpdatesMap(TreeMap<String, Boolean> statesOfUpdatesMapNew) {
        this.statesOfUpdatesMap = statesOfUpdatesMapNew;
    }


    public ProtocolType getProtocol() {
        return protocol;
    }

    public void setProtocol(ProtocolType protocol) {
        this.protocol = protocol;
    }
}
