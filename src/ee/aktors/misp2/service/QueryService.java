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

package ee.aktors.misp2.service;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionContext;
import ee.aktors.misp2.action.URLAction;
import ee.aktors.misp2.action.exception.QueryException;
import ee.aktors.misp2.model.Classifier;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgQuery;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.PersonGroup;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Producer.ProtocolType;
import ee.aktors.misp2.model.ProducerName;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.model.QueryName;
import ee.aktors.misp2.model.Xforms;
import ee.aktors.misp2.model.Xslt;
import ee.aktors.misp2.provider.ConfigurationProvider;
import ee.aktors.misp2.util.CheckXML;
import ee.aktors.misp2.util.ComplexQueryAnalyzer;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Const.QUERY_TYPE;
import ee.aktors.misp2.util.Const.XROAD_VERSION;
import ee.aktors.misp2.util.Roles;
import ee.aktors.misp2.util.WSDLParser;
import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.openapi.OpenApiParser;
import ee.aktors.misp2.util.openapi.RestFormParser;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.rest.model.ListMethodsResponse;
import ee.aktors.misp2.util.xroad.rest.query.GetOpenApiQuery;
import ee.aktors.misp2.util.xroad.soap.query.meta.ListMethodsQuery;
import ee.aktors.misp2.util.xroad.soap.query.meta.WsdlQuery;
import ee.aktors.misp2.util.xroad.soap.wsdl.QueryCollector;
import ee.aktors.misp2.util.xroad.soap.wsdl.WsdlContainer;
import ee.aktors.misp2.util.xroad.soap.wsdl.XRoadV6WsdlCollector;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;
import javax.persistence.FlushModeType;
import javax.persistence.NoResultException;
import javax.servlet.http.HttpServletRequest;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import net.sf.saxon.Controller;
import net.sf.saxon.expr.instruct.TerminationException;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.StrutsStatics;
import org.springframework.transaction.annotation.Transactional;
import org.w3c.dom.Document;

/**
 * Query enity service: find queries, generate and process query XForms etc
 */
@Transactional
public class QueryService extends BaseService {

    private static Logger logger = LogManager.getLogger(QueryService.class);

    private static final String SELECT_DISTINCT = "SELECT DISTINCT q, p ";
    private static final String SELECT = "SELECT oq.queryId ";
    private static final String FROM_BY_PORTAL = "FROM OrgQuery oq INNER JOIN oq.queryId as q"
        + " INNER JOIN oq.queryId.producer as p WHERE oq.queryId.producer.portal.id = :portalId ";
    private static final String ORG_EXTRA = " AND (oq.orgId.id = :orgId OR oq.orgId.id = :supOrgId)";
    private static final String ORDER = " ORDER BY p.shortName, q.name";

    /**
     * @param portal portal of query
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Query> findAllPortalQueries(Portal portal) {
        String qlString = "select q FROM Query q where q.producer.portal.id=:portal"
            + " and q.name!='listMethods' and q.name!='testSystem'";
        javax.persistence.Query s = getEntityManager()
                                    .createQuery(qlString)
                                    .setParameter("portal", portal.getId());
        return s.getResultList();
    }

    /**
     * @param org org or supOrg of query
     * @param portal portal of queries
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Query> findAllowedQueriesByOrgAndPortal(Org org, Portal portal) {
        String queryStr = SELECT + FROM_BY_PORTAL + ORG_EXTRA + ORDER;
        logger.debug("HQL query: " + queryStr);
        logger.debug("HQL args: " + " portalId: " + portal.getId() + " orgId: " + org.getId() + " supOrgId: "
                + (org.getSupOrgId() != null ? org.getSupOrgId().getId() : null));
        return getEntityManager()
                .createQuery(queryStr)
                .setParameter("portalId", portal.getId())
                .setParameter("orgId", org.getId())
                .setParameter("supOrgId", org.getSupOrgId() != null ? org.getSupOrgId().getId() : null)
                .getResultList();
    }

    /**
     * @param input input data for the method
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Query> findAllowedQueriesFilter(QuieriesFilterInput input) {
        StringBuilder queryBuf;
        Map<String, Object> parameters = new HashMap<String, Object>();
        if (input.isOrg) {
            queryBuf = new StringBuilder(SELECT + FROM_BY_PORTAL);
            queryBuf.append(ORG_EXTRA);
        } else {
            queryBuf = new StringBuilder(SELECT_DISTINCT + FROM_BY_PORTAL);
        }
        if (input.filterDescription != null && !input.filterDescription.isEmpty()) {
            queryBuf.append(" AND oq.queryId.id IN (SELECT qn.query.id FROM QueryName qn "
                    + "WHERE LOWER(qn.description) LIKE :qdesc )");
            parameters.put("qdesc", "%" + input.filterDescription.toLowerCase() + "%");
        }
        if (input.filterName != null && !input.filterName.isEmpty()) {
            queryBuf.append(" AND LOWER(oq.queryId.name) LIKE :queryIdName ");
            parameters.put("queryIdName", "%" + input.filterName.toLowerCase() + "%");
        }
        if (input.filterProducer != null && !input.filterProducer.isEmpty()) {
            queryBuf.append(" AND LOWER(oq.queryId.producer.shortName) LIKE :shortName ");
            parameters.put("shortName", "%" + input.filterProducer.toLowerCase() + "%");
        }
        String selectGi = " (SELECT gi.orgQuery.id FROM GroupItem gi WHERE gi.personGroup.id = :groupId ";
        if (input.filterAllowed != null) {
            queryBuf.append(" AND oq.id");
            if (input.filterAllowed) {
                queryBuf.append(" IN ");
            } else {
                queryBuf.append(" NOT IN ");
            }
            queryBuf.append(selectGi + ") ");
            parameters.put("groupId", input.group.getId());
        }
        if (input.filterHidden != null) {
            queryBuf.append(" AND oq.id");
            if (input.filterHidden) {
                queryBuf.append(" IN ");
            } else {
                queryBuf.append(" NOT IN ");
                input.filterHidden = true;
            }
            queryBuf.append(selectGi + " AND invisible = " + input.filterHidden + ") ");
            parameters.put("groupId", input.group.getId());
        }
        queryBuf.append(ORDER);
        System.out.println(queryBuf);
        if (input.isOrg) {
            javax.persistence.Query q = getEntityManager().createQuery(queryBuf.toString())
                    .setParameter("portalId", input.portal.getId()).setParameter("orgId", input.org.getId())
                    .setParameter("supOrgId", input.org.getSupOrgId() != null ? input.org.getSupOrgId().getId() : null);
            for (String param : parameters.keySet()) {
                q.setParameter(param, parameters.get(param));
            }
            return q.getResultList();
        } else {
            javax.persistence.Query q = getEntityManager().createQuery(queryBuf.toString()).setParameter("portalId",
                    input.portal.getId());
            for (String param : parameters.keySet()) {
                q.setParameter(param, parameters.get(param));
            }
            List<Object[]> res = q.getResultList();
            List<Query> queryList = new ArrayList<Query>();
            for (Object[] o : res) {
                queryList.add((Query) o[0]);
            }

            return queryList;
        }
    }

    /**
     * @param portal portal of query
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Query> findDistinctAllowedQueriesByPortal(Portal portal) {
        List<Object[]> res = getEntityManager()
                              .createQuery(SELECT_DISTINCT + FROM_BY_PORTAL + ORDER)
                              .setParameter("portalId", portal.getId())
                              .getResultList();
        List<Query> queryList = new ArrayList<>();
        for (Object[] o : res) {
            queryList.add((Query) o[0]);
        }

        return queryList;
    }

    /**
     * @param orgId orgId of OrgQuery to find
     * @param queryId queryId of orgQuery to find
     * @return null if not exactly one result, result otherwise
     */
    public OrgQuery findOrgQueryByOrgIdAndQueryId(Integer orgId, Integer queryId) {
        try {
            String qlString = "FROM OrgQuery oq WHERE oq.orgId.id = :orgId AND oq.queryId.id = :queryId";
            return (OrgQuery) getEntityManager()
                    .createQuery(qlString)
                    .setParameter("orgId", orgId).setParameter("queryId", queryId)
                    .getSingleResult();
        } catch (NoResultException nre) {
            return null;
        }
    }

    /**
     * @param orgQuery to save
     * @param org org of orgQuery
     * @param query set queryId of orgQuery
     */
    public void saveOrgQuery(OrgQuery orgQuery, Org org, Query query) {
        orgQuery.setOrgId(org);
        orgQuery.setQueryId(query);
        save(orgQuery);
    }

    /**
     * @param p producer of queries
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Query> findComplexQueries(Producer p) {
        String qlString = "select q FROM Query q where q.type="
            + QUERY_TYPE.X_ROAD_COMPLEX.ordinal() + " and q.producer.id="
            + p.getId() + " order by q.id";
        return (List<Query>) getEntityManager()
                              .createQuery(qlString)
                              .getResultList();
    }

    /**
     * @param portal portal of producer
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Producer> findProducersByPortal(Portal portal) {
        String sql = "select p FROM Producer p where portal.id=" + portal.getId();
        return getEntityManager()
                .createQuery(sql)
                .getResultList();
    }

    /**
     * @param producerMemberCode {@link Producer#ProducerMemberCode} to find
     * @param portal {@link Producer#portal} to find
     * @return null if not exactly one result, result otherwise
     */
    public Producer findComplexProducerByName(String producerMemberCode, Portal portal) {
        String sql = "select p FROM Producer p where p.memberClass is null and p.subsystemCode is null "
                + "and p.shortName=:producerMemberCode and p.portal.id=:portalId order by p.inUse desc, p.shortName";
        logger.debug(sql);
        try {
            return (Producer) getEntityManager()
                                .createQuery(sql)
                                .setParameter("portalId", portal.getId())
                                .setParameter("producerMemberCode", producerMemberCode)
                                .getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }

    /**
     * @param producer {@link Query#producer}
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Query> findQueriesByProducer(Producer producer, ProtocolType protocolType) {
        String sql = "select q FROM Query q, Producer producer where producer.id=q.producer.id "
                + "and producer.id=:producerId and producer.portal.id=:portalId "
                + " and producer.protocol=:protocolType order by q.name ";
        return (List<Query>) getEntityManager()
                              .createQuery(sql)
                              .setParameter("portalId", producer.getPortal().getId())
                              .setParameter("producerId", producer.getId())
                              .setParameter("protocolType", protocolType)
                              .getResultList();
    }

    /**
     * @param producer {@link Xforms#producer}
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Xforms> findXFormsByProducer(Producer producer) {
        String qlString = "select x FROM Xforms x, Query q where q.id=x.query.id and q.producer.id=:producerId "
            + "and q.producer.portal.id=:portalId and x.query.name "
            + "NOT IN ('listMethods','testSystem') ORDER BY x.query.name";
        return (List<Xforms>) getEntityManager()
                               .createQuery(qlString)
                               .setParameter("producerId", producer.getId())
                               .setParameter("portalId", producer.getPortal().getId())
                               .getResultList();
    }

    /**
     * @param p {@link Xforms#producer}
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Xforms> findAllProducerComplexXforms(Producer p) {
        String qlString = "select x FROM Xforms x, Query q"
            + " where q.id=x.query.id and q.producer.id=:producerId and q.type="
            + QUERY_TYPE.X_ROAD_COMPLEX.ordinal();

        return (List<Xforms>) getEntityManager()
                               .createQuery(qlString)
                               .setParameter("producerId", p.getId())
                               .getResultList();
    }

    /**
     * Searches for query name only (does not take version into account)
     * 
     * @param name query entity name (without version)
     * @param p portal entity
     * @return list of found queries
     */
    @SuppressWarnings("unchecked")
    public List<Query> findQueriesByQueryNameOnly(String name, Portal p) {
        String qlString = "select q FROM Query q where (q.name = :name or q.name like :wildcardName)"
            + " and q.producer.portal.id=:portalId";

        return (List<Query>) getEntityManager()
                              .createQuery(qlString)
                              .setParameter("name", name)
                              .setParameter("wildcardName", name + ".%")
                              .setParameter("portalId", p.getId())
                              .getResultList();
    }

    /**
     * Find query entity by query entity ID and query name (redundant search parameters for security purpose)
     * 
     * @param queryId query entity ID
     * @param name query entity name
     * @return found query entity
     */
    public Query findQueryByIdAndName(Integer queryId, String name) {
        String qlString = "select q FROM Query q where q.id = :queryId and (q.name = :name or q.name like :wildcardName)";
        return (Query) getEntityManager()
                        .createQuery(qlString)
                        .setParameter("queryId", queryId)
                        .setParameter("name", name)
                        .setParameter("wildcardName", name + ".%")
                        .getSingleResult();
    }

    /**
     * Get classifier query body namespace URI from WSDL
     * 
     * @param portal current user portal classifier query is performed from
     * @param classifier entity holding query information, including namespace
     * @return request body namespace URI from WSDL
     * @throws QueryException on WSDL query failure
     * @throws DataExchangeException on WSDL parsing failure
     */
    public String getQueryNamespaceUriFromWsdl(Portal portal, Classifier classifier) throws QueryException,
            DataExchangeException {
       
        WsdlContainer wsdlContainer = WsdlQuery.downloadWsdl(portal, classifier);
        WSDLParser wsdlParser = new WSDLParser(wsdlContainer.getWsdlDocument(),
                portal.getXroadVersion());
        return wsdlParser.getOperationRequestNamespace(classifier.getXroadQueryServiceCode());
    }


    /**
     * @param q {@link QueryName#query} of QueryName to find
     * @param lang {@link QueryName#lang} of QueryName to find
     * @return result if exactly one result, null otherwises
     */
    public QueryName findQueryNameByQueryId(Query q, String lang) {
        String sql = "select qn FROM Query q, QueryName qn"
                        + " where q.id=qn.query.id and qn.query.id=" + q.getId()
                        + " and qn.lang=:language";
        javax.persistence.Query s = getEntityManager()
                                    .createQuery(sql)
                                    .setParameter("language", lang);
        if (s.getResultList() != null && s.getResultList().size() > 0) {
            return (QueryName) s.getSingleResult();
        } else {
            return null;
        }
    }

    /**
     * @param query {@link QueryName#query} of QueryName to find
     * @param language {@link QueryName#lang} of QueryName to find
     * @return result if exactly one result, null otherwises
     */
    public QueryName findQueryName(Query query, String language) {
        try {
            String qlString = "select qn FROM QueryName qn where qn.query.id=:queryId and qn.lang=:language";
            return (QueryName) getEntityManager()
                                .createQuery(qlString)
                                .setParameter("queryId", query.getId())
                                .setParameter("language", language)
                                .getSingleResult();
        } catch (NoResultException nre) {
            return null;
        }
    }


    /**
     * @param name {@link Query#name} of Query to find
     * @param p {@link Query#producer} of Query to find
     * @return result if exactly one result, null otherwises
     */
    public Query findQueryByName(String name, Producer p, String openapiServiceCode) {
        try {
            String sql = "select q FROM Query q"
                         + " where q.name=:query_name and q.producer.id=" + p.getId();

            if(StringUtils.isNotBlank(openapiServiceCode)) {
                sql += " and q.openapiServiceCode=:openapiServiceCode";
            } else {
                sql += " and q.openapiServiceCode is null";
            }

            // FIXME: in v6 service name and version separator is a colon, not dot, s need to replace that
            // right now service names with . or versions with . do not work!
            javax.persistence.Query q = getEntityManager()
                .createQuery(sql)
                .setParameter("query_name", name);
            if(StringUtils.isNotBlank(openapiServiceCode)) {
                q.setParameter("openapiServiceCode", openapiServiceCode);
            }
            return (Query) q.getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }

    /**
     * @param name {@link Query#name} of the Query
     * @param openapiServiceCode
     * @param p {@link Query#producer} of Query
     * @param excludedQueryId query id not to include in results
     * @return true if exactly one result is found, false otherwise
     */
    @Transactional(readOnly = true)
    public boolean isQueryUnique(String name, String openapiServiceCode, Producer p, Integer excludedQueryId) {
        try {
            String sql = "select count(*) FROM Query q where q.name=:query_name"
                          + " and q.producer.id=:producer_id";
            Map<String, Object> params = new HashMap<>();
            
            params.put("query_name", name);
            params.put("producer_id", p.getId());
            
            if(StringUtils.isNotBlank(openapiServiceCode)) {
                sql += " and q.openapiServiceCode=:openapiServiceCode";
                params.put("openapiServiceCode", openapiServiceCode);
            } else {
                sql += " and q.openapiServiceCode is null";
            }

            if (excludedQueryId != null) {
                sql += " and q.id != :excludedQueryId";
                params.put("excludedQueryId", excludedQueryId);
            }

            javax.persistence.Query q = createQuery(sql, params);

            Long count = (Long) q.setFlushMode(FlushModeType.COMMIT)
                                .getSingleResult();
            return count == 0L;
        } catch (NoResultException e) {
            return true;
        }
    }

    /**
     * @param id {@link XForms#query} id
     * @return result if exactly one is found, empty XForms object otherwise
     */
    public Xforms findXformEntityByQuery(int id) {
        String qlString = "select x FROM Xforms x where x.query.id=" + id;
        javax.persistence.Query s = getEntityManager().createQuery(qlString);

        if (!(s.getResultList().isEmpty())) {
            return (Xforms) s.getSingleResult();
        } else {
            return new Xforms();
        }
    }

    /**
     * @param org {@link OrgQuery#orgId}
     * @param producer {@link Producer#id}
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Query> findOrgQueriesByOrgAndProducer(Org org, Producer producer) {
        String sql = "select q FROM Query q, OrgQuery oq, Producer p, Org o, Portal prt where oq.queryId=q.id "
                + " and oq.orgId=" + org.getId() + " and p.id=q.producer.id and p.id=" + producer.getId()
                + " and prt.orgId=o.id and o.id=oq.orgId and prt.id=" + producer.getPortal().getId();

        return (List<Query>) getEntityManager().createQuery(sql).getResultList();
    }

    /**
     * @param org {@link Org#supOrgId} of Org with same id as OrgQuery
     * @param portal unused
     * @param producer {@link Query#producer} of query that id is same as {@link OrgQuery#queryId}
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<OrgQuery> findAllowedQueriesInSubOrgs(Org org, Portal portal, Producer producer) {
        String sql = "select oq FROM Query q, OrgQuery oq, Org o where "
                + " oq.queryId=q.id and q.producer.id=:producerId and oq.orgId=o.id"
                + " and o.supOrgId.id=:orgId order by q.name";

        return (List<OrgQuery>) getEntityManager()
                                .createQuery(sql)
                                .setParameter("producerId", producer.getId())
                                .setParameter("orgId", org.getId())
                                .getResultList();
    }

    /**
     * @param updates for query ids
     * @param basepath for x-forms generation
     * @return result
     * @throws QueryException on wsdl collection failure
     * @throws DataExchangeException on wsdl collection fault
     */
    public TreeMap<String, Boolean> updateDescriptions(String updates, String basepath) throws QueryException,
            DataExchangeException {
        return updateDescriptions(null, updates, null, null, basepath);
    }

    /**
     * @param updates for query ids
     * @param producer producer
     * @param xformsGeneratedLabel used when x-forms are generated from WSDL
     * @param basepath for x-forms generation
     * @return result
     * @throws QueryException on wsdl collection failure
     * @throws DataExchangeException on wsdl collection fault
     */
    public TreeMap<String, Boolean> updateDescriptionsFromSecurityServerV6(String updates, Producer producer,
            String xformsGeneratedLabel, String basepath) throws QueryException, DataExchangeException {
        XRoadV6WsdlCollector wsdlCollector = new XRoadV6WsdlCollector();
        List<Integer> queryIds = XRoadUtil.getIntegerListFromString(updates);

        for (Integer queryId : queryIds) {
            Query query = findObject(Query.class, queryId);
            wsdlCollector.collect(query);
        }
        
        TreeMap<String, Boolean> stateMap = new TreeMap<String, Boolean>();

        String priorWsdlURL = producer.getWsdlURL();
        try {
            Iterator<WsdlContainer> it = wsdlCollector.iterator();
            while (it.hasNext()) {
                WsdlContainer wsdlContainer = it.next();
                logger.debug("Updating v6 services, queryId-s: " + wsdlContainer.getUpdatedQueryIds());
                TreeMap<String, Boolean> updatedStates =
                        updateDescriptions(
                                wsdlContainer.getWsdlDocument(),
                                wsdlContainer.getUpdatedQueryIds(),
                                producer, xformsGeneratedLabel, basepath);
                stateMap.putAll(updatedStates);
            }
        } finally {
            producer.setWsdlURL(priorWsdlURL);
        }

        wsdlCollector.checkError();
        return stateMap;
    }


    /**
     * Updates api descriptions from security server
     * @param producer producer whom xForms are updated
     * @param updates string list of query ids seperated by ","
     * @param xformsGeneratedLabel used when x-forms are generated from WSDL
     * @return result
     * @throws QueryException on openApi collection failure
     */
    public TreeMap<String, Boolean> updateOpenApiDescriptionsFromSecurityServer(
            Producer producer, String updates, String xformsGeneratedLabel) throws QueryException, DataExchangeException {
        TreeMap<String, Boolean> actionMessageMap = new TreeMap<>();

        ee.aktors.misp2.util.xroad.rest.query.ListMethodsQuery listMethodsQuery =
                new ee.aktors.misp2.util.xroad.rest.query.ListMethodsQuery(producer);
        List<ListMethodsResponse.QueryInfo> queryInfos = listMethodsQuery.fetchQueries(false);

        for(ListMethodsResponse.QueryInfo queryInfo: queryInfos) {
            String openapiServiceCode = queryInfo.getServiceCode();
            try {
                GetOpenApiQuery getOpenApiQuery = new GetOpenApiQuery(producer);
                OpenApiParser openApiParser = getOpenApiQuery.fetchOpenApi(queryInfo.getServiceCode());
                if(openApiParser != null) {
                    actionMessageMap.putAll(updateOpenApiDescriptions(
                        openApiParser, updates, xformsGeneratedLabel, openapiServiceCode));
                }
            } catch (DataExchangeException e) {
                String message = String.format("Query '%s' does not have openApi", queryInfo.getServiceCode());
                logger.debug(message, e);
            }
        }
        return actionMessageMap;
    }


    /**
     * @param parser OpenApi parser
     * @param updates string list of query ids seperated by ","
     * @param xformsGeneratedLabel used when x-forms are generated from WSDL
     * @return result
     * @throws QueryException on openApi collection failure
     */
    public TreeMap<String, Boolean> updateOpenApiDescriptions(
            OpenApiParser parser, String updates, String xformsGeneratedLabel, String openapiServiceCode) throws QueryException {

        TreeMap<String, Boolean> actionMessageMap = new TreeMap<>();

        if (xformsGeneratedLabel != null) { // when forms are generated from YAML
            List<Integer> queryIds = XRoadUtil.getIntegerListFromString(updates);
            if (queryIds == null || queryIds.size() == 0) {
                return actionMessageMap; // if nothing to update, return
            }

            for (Integer id : queryIds) {
                Xforms temp = findXformEntityByQuery(id);
                Query q = findObject(Query.class, id);
                if(StringUtils.isBlank(openapiServiceCode) || !openapiServiceCode.equals(q.getOpenapiServiceCode())) {
                    actionMessageMap.put(q.getOpenapiServiceCode() + ":" + q.getName(), Boolean.FALSE);
                } else {
                    String xForm = parser.generateForm(q);
                    saveQueryForm(xformsGeneratedLabel, actionMessageMap, q, temp, xForm);
                }

            }
        } else { // when forms are read from URL
            Xforms temp = new Xforms();
            Query q = null;
            List<String> queryIds = XRoadUtil.getStringListFromString(updates);
            try {
                for (int n = 0; n < queryIds.size(); n++) {
                    if (n % 2 == 0) { // id
                        int id = Integer.parseInt(queryIds.get(n));
                        temp = findXformEntityByQuery(id);
                        q = findObject(Query.class, id);
                    } else { // url
                        String url = queryIds.get(n);
                        OpenApiParser openApiParser = new OpenApiParser(new URI(url));
                        String xForm = openApiParser.generateForm(q);

                        saveQueryForm(url, actionMessageMap, q, temp, xForm);
                    }
                }
            } catch (Exception e) {
                logger.error("Failed to update query descriptions from WSDL", e);
            }
        }
        return actionMessageMap;
    }

    /**
     * @param parser OpenApi parser
     * @param queries list of queries to generate forms for
     * @param xformsGeneratedLabel used when x-forms are generated from WSDL
     * @return result
     * @throws QueryException on openApi collection failure
     */
    public TreeMap<String, Boolean> updateAllForms(OpenApiParser parser,
        List<Query> queries, String xformsGeneratedLabel) throws QueryException {

        TreeMap<String, Boolean> actionMessageMap = new TreeMap<>();

        if (queries != null && !queries.isEmpty()) {
            for (Query query : queries) {
                Xforms temp = findXformEntityByQuery(query.getId());
                String xForm = parser.generateForm(query);
                saveQueryForm(xformsGeneratedLabel, actionMessageMap, query, temp, xForm);
            }
        }
        return actionMessageMap;
    }

    public TreeMap<String, Boolean> updateAllForms(Document wsdlDocument, List<Query> queries, Producer producer,
        String xformsGeneratedLabel, String basepath, boolean useWsdlUrl) throws QueryException, DataExchangeException {

        TreeMap<String, Boolean> actionMessageMap = new TreeMap<String, Boolean>();
        String producerName = null;
        File xformsDir = null;

        if (xformsGeneratedLabel != null) { // when x-forms are generated from WSDL
            File tmpDir = (File) ServletActionContext.getServletContext().getAttribute("javax.servlet.context.tempdir");
            Portal portal = (Portal) ActionContext.getContext().getSession().get(Const.SESSION_PORTAL);
            if (queries == null || queries.isEmpty()) {
                return actionMessageMap; // if nothing to update, return
            }

            producerName = producer.getShortName();

            String tmpXFormsSubDirName = portal.isV6() ? portal.getShortName() + "_"
                + producer.getSubsystemCode() + "_xroad_v6" : portal.getShortName() + "_" + producerName
                + "_xroad_v5";

            xformsDir = new File(tmpDir, tmpXFormsSubDirName);
            xformsDir.mkdirs();

            // if WSDL document is not given from arguments, download it from security server
            // it is only given in X-Road v6 portal to facilitate WSDL reuse:
            // in X-Road v6 same producer can have multiple WSDLs associated with it
            if (wsdlDocument == null) {
                String wsdlURL;
                if (useWsdlUrl) {
                    wsdlURL = producer.getWsdlURL();
                } else {
                    wsdlURL = portal.getSecurityHost() + (portal.getSecurityHost().endsWith("/") ? "" : "/")
                        + "cgi-bin/uriproxy?producer=" + producerName;
                }
                if (wsdlURL == null || wsdlURL.trim().isEmpty()) {
                    throw new QueryException(QueryException.Type.WSDL_URL_IS_MISSING,
                        "WSDL URL is empty so cannot load xforms from WSDL", null);
                }
                wsdlDocument = XRoadUtil.readValidWsdlAsDocument(wsdlURL);
                logger.debug("Retrieved WSDL document (because it was not given) from " + wsdlURL);
            }

            boolean generationSuccessful = generateXformsFromWsdl(wsdlDocument, xformsDir, basepath, producer, portal,
                new QueryCollector(this, queries.stream().map(Query::getId).collect(Collectors.toList())));
            if (generationSuccessful) {
                try {
                    // FIXME: strange - files are deleted only on VM exit, that could be months in stable MISP2
                    // production installations.
                    logger.debug("Forcing delete on exit for " + tmpXFormsSubDirName);
                    FileUtils.forceDeleteOnExit(xformsDir);
                } catch (IOException e) {
                    logger.error(e.getMessage(), e);
                }

                logger.debug("Successfully generated XForms from WSDL");
            }
            Xforms temp = new Xforms();
            for(Query query : queries) {
                temp = findXformEntityByQuery(query.getId());
                String xForm = null;
                try {
                    String filename = query.getName();
                    String version = query.getServiceVersion();
                    boolean serviceWithoutVersion = version == null || version.isEmpty();
                    if (serviceWithoutVersion) {
                        filename += ".";
                    }
                    if (xformsDir == null) {
                        throw new IOException(
                            "XForms directory name tmpXFormsSubDirName was not set, cannot read query.");
                    }
                    xForm = FileUtils.readFileToString(new File(xformsDir, filename + ".xhtml"), "UTF-8");
                    logger.debug("Successfully read in " + xformsDir.getPath() + "/" + filename + ".xhtml");
                } catch (IOException e) {
                    logger.error(e.getMessage(), e);
                }
                saveQueryForm(xformsGeneratedLabel, actionMessageMap, query, temp, xForm);
            }
        }
        return actionMessageMap;
    }

    /**
     * Saves xform / rest form
     * @param xformsGeneratedLabel label for form
     * @param actionMessageMap map of results
     * @param query query related to the form
     * @param xForm form to save
     * @param xFormContent xml of xform content
     */
    private void saveQueryForm(String xformsGeneratedLabel, TreeMap<String, Boolean> actionMessageMap, Query query, Xforms xForm, String xFormContent) {
        boolean openApi = query.getProducer().getProtocol() == ProtocolType.REST;
        String name = (openApi ? query.getOpenapiServiceCode() + ":" : "") + query.getName();
        if (xFormContent != null) {
            if (openApi || CheckXML.checkSyntax(xFormContent)) {
                xForm.setForm(xFormContent);
                xForm.setUrl(xformsGeneratedLabel);
                xForm.setQuery(query);
                if (openApi) {
                    addSubQueryNames(query, xForm);
                }
                getEntityManager().merge(xForm);
                actionMessageMap.put(name, Boolean.TRUE);
            } else {
                actionMessageMap.put(name, Boolean.FALSE);
            }
        } else {
            actionMessageMap.put(name, Boolean.FALSE);
        }
    }

    /**
     * @param wsdlDocument WSDL document, if not given, download it from security server
     * @param updates for query ids
     * @param producer producer
     * @param xformsGeneratedLabel used when x-forms are generated from WSDL
     * @param basepath for x-forms generation
     * @return result
     * @throws QueryException on wsdl collection failure
     * @throws DataExchangeException on wsdl collection fault
     */
    public TreeMap<String, Boolean> updateDescriptions(Document wsdlDocument, String updates, Producer producer,
            String xformsGeneratedLabel, String basepath) throws QueryException, DataExchangeException {

        TreeMap<String, Boolean> actionMessageMap = new TreeMap<String, Boolean>();
        String producerName = null;
        File xformsDir = null;

        if (xformsGeneratedLabel != null) { // when x-forms are generated from WSDL
            List<Integer> queryIds = XRoadUtil.getIntegerListFromString(updates);
            File tmpDir = (File) ServletActionContext.getServletContext().getAttribute("javax.servlet.context.tempdir");
            Portal portal = (Portal) ActionContext.getContext().getSession().get(Const.SESSION_PORTAL);
            if (queryIds == null || queryIds.size() == 0) {
                return actionMessageMap; // if nothing to update, return
            }
            Query query = findObject(Query.class, queryIds.get(0));
            Producer generatedProducer = query.getProducer();
            producerName = generatedProducer.getShortName();

            String tmpXFormsSubDirName = portal.isV6() ? portal.getShortName() + "_"
                    + generatedProducer.getSubsystemCode() + "_xroad_v6" : portal.getShortName() + "_" + producerName
                    + "_xroad_v5";

            xformsDir = new File(tmpDir, tmpXFormsSubDirName);
            xformsDir.mkdirs();

            // if WSDL document is not given from arguments, download it from security server
            // it is only given in X-Road v6 portal to facilitate WSDL reuse:
            // in X-Road v6 same producer can have multiple WSDLs associated with it
            if (wsdlDocument == null) {
                String wsdlURL;
                if (producer != null) {
                    wsdlURL = producer.getWsdlURL();
                } else {
                    wsdlURL = portal.getSecurityHost() + (portal.getSecurityHost().endsWith("/") ? "" : "/")
                            + "cgi-bin/uriproxy?producer=" + producerName;
                }
                if (wsdlURL == null || wsdlURL.trim().isEmpty()) {
                    throw new QueryException(QueryException.Type.WSDL_URL_IS_MISSING,
                            "WSDL URL is empty so cannot load xforms from WSDL", null);
                }
                wsdlDocument = XRoadUtil.readValidWsdlAsDocument(wsdlURL);
                logger.debug("Retrieved WSDL document (because it was not given) from " + wsdlURL);
            }

            boolean generationSuccessful = generateXformsFromWsdl(wsdlDocument, xformsDir, basepath, producer, portal,
                    new QueryCollector(this, queryIds));
            if (generationSuccessful) {
                try {
                    // FIXME: strange - files are deleted only on VM exit, that could be months in stable MISP2
                    // production installations.
                    logger.debug("Forcing delete on exit for " + tmpXFormsSubDirName);
                    FileUtils.forceDeleteOnExit(xformsDir);
                } catch (IOException e) {
                    logger.error(e.getMessage(), e);
                }

                logger.debug("Successfully generated XForms from WSDL");
            }
            Xforms temp = new Xforms();
            for (Integer id : queryIds) {
                temp = findXformEntityByQuery(id);
                String xForm = null;
                Query q = findObject(Query.class, id);
                try {
                    String filename = q.getName();
                    String version = q.getServiceVersion();
                    boolean serviceWithoutVersion = version == null || version.isEmpty();
                    if (serviceWithoutVersion) {
                        filename += ".";
                    }
                    if (xformsDir == null) {
                        throw new IOException(
                                "XForms directory name tmpXFormsSubDirName was not set, cannot read query.");
                    }
                    xForm = FileUtils.readFileToString(new File(xformsDir, filename + ".xhtml"), "UTF-8");
                    logger.debug("Successfully read in " + xformsDir.getPath() + "/" + filename + ".xhtml");
                } catch (IOException e) {
                    logger.error(e.getMessage(), e);
                }
                saveQueryForm(xformsGeneratedLabel, actionMessageMap, q, temp, xForm);
            }
        } else { // when xforms are read from URL
            Xforms temp = new Xforms();
            List<String> queryIds = XRoadUtil.getStringListFromString(updates);
            try {
                for (int n = 0; n < queryIds.size(); n++) {
                    if (n % 2 == 0) { // id
                        temp = findXformEntityByQuery(Integer.parseInt(queryIds.get(n)));
                    } else { // url
                        URLAction readurl = new URLAction();
                        readurl.setUrl(queryIds.get(n).toString());
                        if (readurl.readUrl() == Action.SUCCESS) {
                            String pureXml = readurl.getLines();
                            if (CheckXML.checkSyntax(pureXml)) {
                                temp.setForm(readurl.getLines());
                                temp.setUrl(queryIds.get(n).toString());
                                temp.setQuery(findObject(Query.class, Integer.parseInt(queryIds.get(n - 1))));
                                // parse subqueries from complex query
                                if (temp.getQuery().getType() == QUERY_TYPE.X_ROAD_COMPLEX.ordinal()) {
                                    addSubQueryNames(temp.getQuery(), temp);
                                }
                                getEntityManager().merge(temp);
                                actionMessageMap.put(temp.getQuery().getName(), Boolean.TRUE);
                            } else {
                                actionMessageMap.put(temp.getQuery().getName(), Boolean.FALSE);
                            }
                        } else {
                            actionMessageMap.put(temp.getQuery().getName(), Boolean.FALSE);
                        }

                    }
                }
            } catch (Exception e) {
                logger.error("Failed to update query descriptions from WSDL", e);
            }
        }
        return actionMessageMap;
    }

    private boolean generateXformsFromWsdl(Document wsdlDocument, File dest, String basepath, Producer producer,
            Portal portal, QueryCollector queryCollector) throws QueryException, DataExchangeException {

        final String xroadNamespace = portal.getXroadNamespace();

        Transformer transformer;
        StringWriter sw = new StringWriter();

        TransformerFactory transformerFactory = XMLUtil.getTransformerFactory();
        final URIResolver uriResolver = transformerFactory.getURIResolver();
        // it is used for loading imported xsl-s
        transformerFactory.setURIResolver(new URIResolver() {
                    @Override
                    public Source resolve(String href, String base) throws TransformerException {
                        logger.debug("Resolving URI " + href + " base " + base);
                        // load local XSLs (where URI does not contain //, like http://) from project directory
                        // and apply relevant preprocessing to the XSL
                        if (href != null && href.endsWith(".xsl") && !href.contains("//")) {
                            try {
                                logger.debug("Classified URI " + href + " as local XSL. Custom resolve.");
                                return new StreamSource(convertXSLToSanitizedInputStream(href, xroadNamespace));
                            } catch (IOException e) {
                                logger.error("URI resolve failed " + href, e);
                                // return null;//XSL file failed to load. href was probably pointing to
                                // namespace or some other non-relevant URL
                                throw new TransformerException(
                                        "XSL resolving failed href=" + href + " base=" + base, e);
                            }
                        } else { // load XSD and other files using default transformer
                            logger.debug("Classified URI " + href + " as shema - resolving with default resolver");
                            return uriResolver.resolve(href, base);
                        }
                    }
                });
        try {
            Date t0 = new Date();
            transformer = transformerFactory.newTransformer(new StreamSource(convertXSLToSanitizedInputStream(
                    "xtee2xforms.xsl", xroadNamespace)));

            transformer.setParameter("debugurl", "");
            transformer.setParameter("urlxml", "");
            String operationNames = queryCollector.getQueryOperationNames(","); // separator given as argument
            if (StringUtils.isNotEmpty(operationNames)) {
                transformer.setParameter("operation-names", operationNames);
                logger.debug("Operation names passed to the transformer: " + operationNames);
            }
            if (portal.isV6()) {
                transformer.setParameter("xroad6-service-instance", producer.getXroadInstance());
                transformer.setParameter("xroad6-service-member-class", producer.getMemberClass());
                transformer.setParameter("xroad6-service-member-code", producer.getShortName());
                transformer.setParameter("xroad6-service-subsystem-code", producer.getSubsystemCode());

                transformer.setParameter("xroad6-client-xroad-instance", portal.getClientXroadInstance());
            }

            transformer.setParameter(
                    "classifier-prefix",
                    basepath
                            + ((HttpServletRequest) ActionContext.getContext().get(StrutsStatics.HTTP_REQUEST))
                                    .getContextPath() + "/classifier?name=");
            transformer.setParameter("classifier-suffix", "");
            ((Controller) transformer).setBaseOutputURI(dest.toURI().toString());
            // the following line is used for the future versions of saxxon instead of the previous line
            // ((net.sf.saxon.jaxp.TransformerImpl)transformer).getUnderlyingController()
            //.setBaseOutputURI(dest.toURI().toString());

            Integer xroadVersion = portal.getXroadVersionAsInt();
            // in v5 portal, support also X-Road v4 headers if WSDL has X-Road v4 namespace
            if (xroadVersion.intValue() == XROAD_VERSION.V5.getIndex()) {
                WSDLParser wsdlParser = new WSDLParser(wsdlDocument, portal.getXroadVersion());
                String wsdlNamespace = wsdlParser.getXRoadNamespace();
                if (wsdlNamespace.equals(XROAD_VERSION.V4.getDefaultNamespace())) {
                    xroadVersion = XROAD_VERSION.V4.getIndex();
                } else {
                    String portalNamespace = portal.getXroadNamespace();
                    if (!wsdlNamespace.equals(portalNamespace)) {
                        throw new QueryException(QueryException.Type.WSDL_AND_CONFIG_XROAD_NAMESPACE_MISMATCH,
                                "WSDL X-Road namespace '" + wsdlNamespace
                                + "' does not match portal namespace '" + portalNamespace + "'.", null);
                    }
                }
            }
            transformer.setParameter("xroad-version", xroadVersion);
            transformer.transform(new DOMSource(wsdlDocument), new StreamResult(sw));
            logger.debug("Form generation took " + (new Date().getTime() - t0.getTime()) + " ms");
            return true;
        } catch (TransformerConfigurationException e) {
            throw new QueryException(QueryException.Type.WSDL_TO_XFORMS_XSL_TRANSFORMATION_FAILED,
                    "WSDL to XFORMS XSL transformer configuration failure", e);
        } catch (IOException e) {
            throw new QueryException(QueryException.Type.WSDL_TO_XFORMS_READING_INPUT_FAILED,
                    "Failed to read WSDL or XSL file", e);
        } catch (TransformerException e) {
            String errorMessage = "Failed to transform WSDL to XFORMS using XSL";
            if (e instanceof TerminationException) {
                TerminationException eTerm = (TerminationException)e;
                if (eTerm.getLocator() != null) {
                    String locatorText = eTerm.getLocator().toString()
                            .replaceAll("^Message\\(Block\\(ValueOf\\(\"([^\"]+)\".*$", "$1");
                    if (StringUtils.isNotBlank(locatorText)) {
                        if (locatorText.startsWith("Maximum allowed schema depth exceeded")) {
                            throw new QueryException(QueryException.Type.WSDL_MAX_SCHEMA_DEPTH_EXCEEDED,
                                    locatorText, e);
                        } else {
                            errorMessage = locatorText;
                        }
                    }
                }
            }
            throw new QueryException(QueryException.Type.WSDL_TO_XFORMS_XSL_TRANSFORMATION_FAILED,
                    errorMessage, e);
        }
    }

    /**
     * @param producer producer
     * @return result
     * @throws QueryException on wsdl collection failure
     * @throws DataExchangeException on wsdl fault
     */
    public List<Query> getMethodsFromWSDL(Producer producer) throws QueryException, DataExchangeException {
        WSDLParser wp = new WSDLParser(producer.getWsdlURL(), producer.getPortal().getXroadVersion());
        return getQueries(producer, wp);
    }

    /**
     * @param producer producer
     * @param file wsdl file to read the methods from
     * @return result
     * @throws QueryException on wsdl collection failure
     * @throws DataExchangeException on wsdl fault
     */
    public List<Query> getMethodsFromFile(Producer producer, File file) throws QueryException, DataExchangeException{
        WSDLParser wp = new WSDLParser(file, producer.getPortal().getXroadVersion());
        return getQueries(producer, wp);
    }

    /**
     * Gets queries from wsdl parser
     * @param producer producer whom to associate with queries
     * @param parser contains the queries
     * @return list of queries of empty list
     */
    private List<Query> getQueries(Producer producer, WSDLParser parser) {
        List<Query> queries = new ArrayList<>();
        for (String operation : parser.getOperations()) {
            Query temp = new Query();
            temp.setName(operation);
            temp.setProducer(producer);
            temp.setType(QUERY_TYPE.X_ROAD.ordinal());
            queries.add(temp); // add query to list
        }
        return queries;
    }

    /**
     * Get list of methods from _X-Road v6_ security server for given producer .
     * @param producer producer
     * @param org session user {@link Org}
     * @param type only request allowed methods or request all methods; {@link ListMethodsQuery.Type}
     * @return list of methods
     * @throws DataExchangeException throws
     */
    public List<Query> getMethodsFromSecurityServer(ListMethodsQuery.Type type, Producer producer, Org org)
            throws DataExchangeException {
        // assume protocol is V6 here
        ListMethodsQuery xRoadQuery = new ListMethodsQuery(type, producer, org);
        xRoadQuery.createSOAPRequest();
        xRoadQuery.sendRequest();
        return xRoadQuery.parseMethods();
    }

    /**
     * Get list of methods from _X-Road v6_ security server for given producer .
     * @param producer producer
     * @param type only request allowed methods or request all methods; {@link ListMethodsQuery.Type}
     * @return list of methods
     * @throws DataExchangeException throws
     */
    public List<Query> getMethodsFromSecurityServer(ListMethodsQuery.Type type, Producer producer)
            throws DataExchangeException {
        return getMethodsFromSecurityServer(type, producer, null);
    }

    /**
     * Get list of methods from _X-Road v6_ security server for given producer .
     * @param producer producer
     * @param org session user {@link Org}
     * @return list of methods
     * @throws DataExchangeException throws
     */
    public HashSet<String> getAllowedMethodIdentifiersFromSecurityServer(Producer producer, Org org)
            throws DataExchangeException {
        // assume protocol is V6 here
        // is Org always null? It isn't when unit is consumer;
        ListMethodsQuery xRoadQuery = new ListMethodsQuery(ListMethodsQuery.Type.ALLOWED_METHODS, producer, org);
        xRoadQuery.createSOAPRequest();
        xRoadQuery.sendRequest();
        List<Query> queries = xRoadQuery.parseMethods();
        HashSet<String> identifiers = new HashSet<String>();
        for (Query query : queries) {
            identifiers.add(query.getFullIdentifier());
        }
        return identifiers;
    }

    /**
     * @param all queries to save
     * @param org org of queries
     */
    public void saveQueries(List<Query> all, Org org) {
        Map<String, Object> session = ActionContext.getContext().getSession();
        Portal portal = (Portal) session.get(Const.SESSION_PORTAL);
        for (Query temp : all) {
            // initialize X-Road request namespace to empty value, classifier action fills it if needed
            temp.setXroadRequestNamespace(null);
            if (org == null) {
                if (queryExists(temp, portal)) { // if that query exists, then setId and update id
                    getEntityManager().merge(temp);
                } else {
                    getEntityManager().persist(temp);
                    // add initial xforms to that query
                    Xforms x = new Xforms();
                    x.setQuery(temp);
                    x.setForm("");
                    x.setUrl("http://");
                    getEntityManager().persist(x);
                }
            } else {
                if (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL
                        && org.getId().intValue() == portal.getOrgId().getId().intValue()
                        && portal.getUnitIsConsumer()) {
                    // add org_query for units in universal portal
                    try {
                        List<Org> orgList = this.reAttach(org, Org.class).getOrgList();
                        for (Org o : orgList) {
                            if (!(queryExists(temp, portal))) {
                                getEntityManager().persist(temp);
                            }

                            if (orgQueryUnitExists(temp, portal, o)) {
                                getEntityManager().merge(temp);
                            } else {
                                Xforms x = new Xforms();
                                x.setQuery(temp);
                                x.setForm("");
                                x.setUrl("http://");
                                getEntityManager().persist(x);

                                OrgQuery oq = new OrgQuery();
                                oq.setOrgId(o);
                                oq.setQueryId(temp);
                                getEntityManager().persist(oq);
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else {
                    if (orgQueryExists(temp, portal, org)) { // if that org query exists, then setId and update id
                        getEntityManager().merge(temp);
                    } else {
                        if (!(queryExists(temp, portal))) {
                            getEntityManager().persist(temp);
                            // add initial xforms to that query
                            Xforms x = new Xforms();
                            x.setQuery(temp);
                            x.setForm("");
                            x.setUrl("http://");
                            getEntityManager().persist(x);
                        }
                        // add new OrgQuery object because this is allowed methods list that comes from security server
                        OrgQuery oq = new OrgQuery();
                        oq.setOrgId(org);
                        oq.setQueryId(temp);
                        getEntityManager().persist(oq);
                    }
                }
            }
        }
    }


    /**
     * @param parser optional openApi parser
     * @param producer producer
     * @param lang language of descriptions
     * @return true if saving was successful, false otherwise
     */
    public boolean saveDescriptions(OpenApiParser parser, Producer producer, String lang, String serviceCode) {
        try {
            List<ProducerName> listOfProducerNames = parser.getProducerNameList();
            for (ProducerName temp : listOfProducerNames) {
                temp.setProducer(temp.getProducer() == null ? producer : temp.getProducer());
                if (producerDescExists(temp)) { // if that producer desc exists, then setId and update id
                    getEntityManager().merge(temp);
                } else {
                    getEntityManager().persist(temp);
                }
            }

            logger.debug("Updating query descriptions...");
            List<Query> queryList = parser.parseQueryList(producer, serviceCode);
            saveQueryNames(producer, queryList, serviceCode);

        } catch (Exception e) {
            logger.error("saveDescriptions failed: " + e.getMessage(), e);
            return false;
        }

        return true;
    }

    /**
     * @param wp wsdl parser, optional
     * @param producer producer
     * @param lang language of descriptions
     * @return true if saving was successful, false otherwise
     */
    public boolean saveDescriptions(WSDLParser wp, Producer producer, String lang) {
        try {
            if (wp == null) {
                wp = new WSDLParser(producer.getWsdlURL(), producer.getPortal().getXroadVersion());
            }
            // update producer descriptions

            List<ProducerName> listOfProducerNames = wp.getProducerDescriptions(producer, lang);
            for (ProducerName temp : listOfProducerNames) {
                if (producerDescExists(temp)) { // if that producer desc exists, then setId and update id
                    getEntityManager().merge(temp);
                } else {
                    getEntityManager().persist(temp);
                }
            }

            // update queries description
            logger.debug("Updating query descriptions...");
            TreeMap<String, List<QueryName>> listOfDescriptions = wp.getQueryDescriptions(lang, null);
            saveQueryNames(producer, listOfDescriptions, null);

        } catch (Exception e) {
            logger.error("saveDescriptions failed: " + e.getMessage(), e);
            return false;
        }

        return true;
    }


    /**
     * @param producer owner of queries
     * @param listOfDescriptions querynames to persist
     */
    private void saveQueryNames(Producer producer, TreeMap<String, List<QueryName>> listOfDescriptions, String openapiServiceCode) {
        for (Map.Entry<String, List<QueryName>> entry : listOfDescriptions.entrySet()) {
            String serviceName = entry.getKey();
            List<QueryName> queryNames = entry.getValue();
            for (QueryName qn : queryNames) {
                logger.debug("serviceName: " + serviceName + " producer " + producer.getId());
                Query toLink = findQueryByName(serviceName, producer, openapiServiceCode);
                link(qn, toLink);
            }
        }
    }

    /**
     * @param producer owner of queries
     * @param listOfQueries list of queries whom QueryNames to persist
     * @param openapiServiceCode identifier code for rest queries
     */
    private void saveQueryNames(Producer producer, List<Query> listOfQueries, String openapiServiceCode) {
        for(Query query : listOfQueries) {
            String serviceName = query.getName();
            for(QueryName qn : query.getQueryNameList()) {
                logger.debug("serviceName: " + serviceName + ", producer: " + producer.getId() + ", openapiServiceCode: " + openapiServiceCode);
                Query toLink = findQueryByName(serviceName, producer, openapiServiceCode);
                link(qn, toLink);
            }
        }
    }


    /**
     * Links {@link Query} with {@link QueryName}
     * @param queryName {@link QueryName} to link with {@link Query}
     * @param query {@link Query} to link the {@link QueryName} to
     */
    private void link(QueryName queryName, Query query) {
        logger.debug("QueryName: " + queryName.getDescription() + " toLink " + query);
        if (query != null) {
            queryName.setQuery(query);
            QueryName tempQn = findQueryNameByQueryId(query, queryName.getLang());
            if (tempQn != null && tempQn.getQueryNote() != null && !tempQn.getQueryNote().equals(""))
                queryName.setQueryNote(tempQn.getQueryNote());
            if (queryDescExists(queryName)) { // if that query desc exists, then setId and update id
                logger.debug(queryName.getDescription() + "+ with lang +" + queryName.getLang() + "+exists");
                getEntityManager().merge(queryName);
            } else {
                logger.debug("new queryname with desc" + queryName.getDescription() + queryName.getLang()
                    + queryName.getQuery().getId());
                getEntityManager().persist(queryName);
            }
        }
    }

    /**
     * @param q  for {@link Query#name} and {@link Query#producer} of query to find
     * @param portal  {@link Portal} of query to find
     * @return true if exactly one such query exists, false otherwise
     */
    public boolean queryExists(Query q, Portal portal) {
        String sql = "select q FROM Query q where q.name=:qdesc and q.producer.id=:producerId"
                + " and q.producer.portal.id=:portalId";

        if(StringUtils.isNotBlank(q.getOpenapiServiceCode())) {
            sql += " and q.openapiServiceCode=:openapiServiceCode";
        } else {
            sql += " and q.openapiServiceCode is null";
        }

        try {
            javax.persistence.Query s = getEntityManager()
                .createQuery(sql)
                .setParameter("qdesc", q.getName())
                .setParameter("portalId", +portal.getId())
                .setParameter("producerId", q.getProducer().getId());

            if(StringUtils.isNotBlank(q.getOpenapiServiceCode())) {
                s.setParameter("openapiServiceCode", q.getOpenapiServiceCode());
            }

            Query tempQuery = (Query) s.getSingleResult();
            q.setId(tempQuery.getId());
            q.setSubQueryNames(tempQuery.getSubQueryNames());
            return true;
        } catch (Exception e) {
            return false;
        }

    }

    /**
     * @param q  for {@link Query#name} and {@link Query#producer} of query to find
     * @param p  {@link Query#portal} of query to find
     * @param o org
     * @return true if exactly one such query exists, false otherwise
     */
    public boolean orgQueryExists(Query q, Portal p, Org o) {
        String sql = "select q FROM Query q, OrgQuery oq, Producer p where q.name=:query_name and p.id="
                + q.getProducer().getId() + " and oq.orgId.id=" + o.getId()
                + " and oq.queryId=q.id and p.id=q.producer.id and q.producer.portal.id=" + p.getId();

        if(StringUtils.isNotBlank(q.getOpenapiServiceCode())) {
            sql += " and q.openapiServiceCode=:openapiServiceCode";
        } else {
            sql += " and q.openapiServiceCode is null";
        }

        javax.persistence.Query s = getEntityManager()
                                     .createQuery(sql)
                                     .setParameter("query_name", q.getName());
        if(StringUtils.isNotBlank(q.getOpenapiServiceCode())) {
            s.setParameter("openapiServiceCode", q.getOpenapiServiceCode());
        }

        try {
            Query  tempQuery = (Query) s.getSingleResult();
            q.setId(tempQuery.getId());
            q.setSubQueryNames(tempQuery.getSubQueryNames());
            return true;
        } catch (Exception e) {
            return false;
        }

    }

    /**
     * @param q  for {@link Query#name} and {@link Query#producer} of query to find
     * @param p  {@link Query#portal} of query to find
     * @param o org
     * @return true if exactly one such query exists, false otherwise
     */
    public boolean orgQueryUnitExists(Query q, Portal p, Org o) {
        String sql = "select q FROM Query q, OrgQuery oq where q.id="
                        + q.getId() + " and oq.queryId=" + q.getId()
                        + " and oq.orgId.id=" + o.getId();

        if(StringUtils.isNotBlank(q.getOpenapiServiceCode())) {
            sql += " and q.openapiServiceCode=:openapiServiceCode";
        } else {
            sql += " and q.openapiServiceCode is null";
        }

        try {
            javax.persistence.Query s = getEntityManager().createQuery(sql);
            if(StringUtils.isNotBlank(q.getOpenapiServiceCode())) {
                s.setParameter("openapiServiceCode", q.getOpenapiServiceCode());
            }
            s.getSingleResult();
            return true;
        } catch (Exception e) {
            return false;
        }

    }

    /**
     * @param p for producer id and description language
     * @return true if exactly one such query exists, false otherwise
     */
    public boolean producerDescExists(ProducerName p) {
        String qlString = "select p FROM ProducerName p where p.lang=:language"
                            + " and p.producer.id=" + p.getProducer().getId();
        try {
            ProducerName tempProducer = (ProducerName) getEntityManager()
                                                        .createQuery(qlString)
                                                        .setParameter("language", p.getLang())
                                                        .getSingleResult();
            p.setId(tempProducer.getId());
            return true;
        } catch (Exception e) {
            return false;
        }

    }

    /**
     * @param q for query id and language
     * @return true if exactly one such query exists, false otherwise
     */
    public boolean queryDescExists(QueryName q) {
        String sql = "select q FROM QueryName q where q.query.id=:queryId and q.lang=:lang";
        try {
            QueryName tempQName = (QueryName) getEntityManager()
                                               .createQuery(sql)
                                               .setParameter("lang", q.getLang())
                                               .setParameter("queryId", q.getQuery().getId())
                                               .getSingleResult();
            q.setId(tempQName.getId());
            return true;
        } catch (Exception e) {
            return false;
        }

    }

    /**
     * @param query query
     * @return a list of results or null if given query doesn't have portal
     */
    @SuppressWarnings("unchecked")
    public List<Xslt> getXsltList(Query query) {
        Producer p = query.getProducer();
        Portal portal = query.getProducer().getPortal();
        String producerClause = "";

        if (p != null) {
            producerClause += " or (x.producerId=" + p.getId() + " and x.queryId is null) or (x.portal = "
                    + portal.getId() + " and x.producerId is null)";
        }
        String hql = "select x FROM Xslt x where (x.queryId=:queryId " + producerClause
                + ") and inUse=true and formType=0 order by x.priority";

        try {
            return getEntityManager()
                    .createQuery(hql)
                    .setParameter("queryId", query)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;

    }

    /**
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Xslt> findGlobalXslt() {
        String qlString = "select x FROM Xslt x where inUse=true and queryId is null and portal is null order by priority";
        return (List<Xslt>) getEntityManager().createQuery(qlString).getResultList();
    }

    /**
     * @param q query
     * @return true if exactly one such query exists, false otherwise
     */
    public boolean isQueryAllowedForCitizen(Query q) {
        String hql = "select q FROM Query q, OrgQuery oq, GroupItem gi, PersonGroup g"
                + " where gi.orgQuery.id=oq.id and gi.personGroup.id=g.id "
                + "and g.portal.id=:portalId and oq.queryId.id=q.id and q.id=:queryId";

        try {
            return getEntityManager()
                    .createQuery(hql)
                    .setParameter("portalId", q.getProducer().getPortal().getId())
                    .setParameter("queryId", q.getId())
                    .getSingleResult() != null;
        } catch (NoResultException e) {
            logger.error("This query is not allowed in citizen portal anymore");
            return Boolean.FALSE;
        }

    }

    /**
     * @param q for portal
     * @param o for supOrgId
     * @param person orgId
     * @return true if exactly one such query exists, false otherwise
     */
    public boolean isQueryAllowed(Query q, Org o, Person person) {
        String hql = "select q FROM Query q, OrgQuery oq, GroupItem gi, PersonGroup g, GroupPerson gp, Person p"
                + " where gi.orgQuery.id=oq.id and gi.personGroup.id=g.id and g.portal.id=:portalId and "
                + "oq.queryId.id=q.id and q.id=:queryId and gp.person.id=:personId and "
                + "gp.personGroup.id=g.id and (gp.validuntil is null or gp.validuntil>=:validuntil) and "
                + "(g.orgId = :orgId or g.orgId = :supOrgId) ";

        try {
            return getEntityManager()
                    .createQuery(hql)
                    .setParameter("portalId", q.getProducer().getPortal().getId())
                    .setParameter("queryId", q.getId())
                    .setParameter("personId", person.getId())
                    .setParameter("orgId", o)
                    .setParameter("validuntil", DateUtils.truncate(new Date(), Calendar.DATE))
                    .setParameter("supOrgId", o.getSupOrgId())
                    .getSingleResult() != null;
        } catch (NoResultException e) {
            logger.error("This query is not allowed in this portal under this organization anymore");
            return Boolean.FALSE;
        }
    }

    /**
     * @param query for queryId
     */
    public void deleteQueryNames(Query query) {
        String qlString = "DELETE QueryName qn WHERE qn.query.id = :query_id";
        getEntityManager()
         .createQuery(qlString)
         .setParameter("query_id", query.getId())
         .executeUpdate();
    }

    /**
     * Converts XSL indicated by xslRelativeURL in default xslt folder to InputStream. Also replaces references to
     * {@link Const#XROAD_NS_DEFAULT} with {@link Const#XROAD_NS}
     * 
     * @param xslRelativeURL
     * @return
     * @throws IOException
     *             if failed to access XSL file
     */
    private InputStream convertXSLToSanitizedInputStream(String xslRelativeURL, String xroadNamespace)
            throws IOException {
        if (xslRelativeURL != null && (xslRelativeURL.startsWith("http://") || xslRelativeURL.startsWith("https://"))) {
            logger.debug("Downloading data from URL '" + xslRelativeURL + "' during XSL transformation");
            return new URL(xslRelativeURL).openStream();
        }
        xslRelativeURL = "/resources/xslt/" + xslRelativeURL;

        InputStream xslStream = ServletActionContext.getServletContext().getResourceAsStream(xslRelativeURL);
        if (xslStream == null)
            throw new IOException("Failed to load XSL file with relative URL " + xslRelativeURL);
        String xslString = IOUtils.toString(xslStream, "UTF-8");
        xslString = xslString.replace(XROAD_VERSION.getDefault().getDefaultNamespace(), xroadNamespace);
        InputStream xslStringStream = new ByteArrayInputStream(xslString.getBytes("UTF-8"));
        return xslStringStream;
    }

    /**
     * Call to parse sub-query names from XForms: addSubQueryNames(q, x);
     * 
     * @param query query to set sub query names
     * @param xforms sub query names
     */
    public void addSubQueryNames(Query query, Xforms xforms) {
        if (query != null) {
            query.setSubQueryNames(null);
            if (query.getProducer() != null && query.getProducer().getPortal() != null && xforms != null) {
                String xformsStr = xforms.getForm();
                if (xformsStr != null) {
                    xformsStr = xformsStr.trim();
                    if (!xformsStr.isEmpty()) {
                        if (query.getProducer().getProtocol() == Producer.ProtocolType.REST) {
                            RestFormParser restFormParser = new RestFormParser(xformsStr);
                            query.setSubQueryNames(restFormParser.findSubQueryNames());
                        } else {
                            ComplexQueryAnalyzer complexServiceAnalyzer = new ComplexQueryAnalyzer(xformsStr, query
                                    .getProducer().getPortal().getXroadVersion());
                            Configuration config = ConfigurationProvider.getConfig();
                            complexServiceAnalyzer.parse(config);
                            query.setSubQueryNames(complexServiceAnalyzer.toString());

                        }
                    }
                }
            }

        }
    }

    /**
     * Input for {@link QueryService#findAllowedQueriesFilter}
     * *@param org for supOrgId
     * *@param portal for portalId
     * *@param filterDescription for like queryName description
     * *@param filterName for orgQuery
     * *@param filterProducer for orgQuery.queryId.producer.shortName
     * *@param filterAllowed orgQueryId in or not in
     * *@param filterHidden is filter invisible
     * *@param isOrg is org
     * *@param group for groupId
     * 
     * @author kristjan.kiolein
     */
    public static class QuieriesFilterInput {
        Org org;
        Portal portal;
        String filterDescription;
        String filterName;
        String filterProducer;
        Boolean filterAllowed;
        Boolean filterHidden;
        boolean isOrg;
        PersonGroup group;
        /**
         * @return the org
         */
        public Org getOrg() {
            return org;
        }
        /**
         * @param orgNew the org to set
         */
        public void setOrg(Org orgNew) {
            this.org = orgNew;
        }
        /**
         * @return the portal
         */
        public Portal getPortal() {
            return portal;
        }
        /**
         * @param portalNew the portal to set
         */
        public void setPortal(Portal portalNew) {
            this.portal = portalNew;
        }
        /**
         * @return the filterDescription
         */
        public String getFilterDescription() {
            return filterDescription;
        }
        /**
         * @param filterDescriptionNew the filterDescription to set
         */
        public void setFilterDescription(String filterDescriptionNew) {
            this.filterDescription = filterDescriptionNew;
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
         * @return the filterProducer
         */
        public String getFilterProducer() {
            return filterProducer;
        }
        /**
         * @param filterProducerNew the filterProducer to set
         */
        public void setFilterProducer(String filterProducerNew) {
            this.filterProducer = filterProducerNew;
        }
        /**
         * @return the filterAllowed
         */
        public Boolean getFilterAllowed() {
            return filterAllowed;
        }
        /**
         * @param filterAllowedNew the filterAllowed to set
         */
        public void setFilterAllowed(Boolean filterAllowedNew) {
            this.filterAllowed = filterAllowedNew;
        }
        /**
         * @return the filterHidden
         */
        public Boolean getFilterHidden() {
            return filterHidden;
        }
        /**
         * @param filterHiddenNew the filterHidden to set
         */
        public void setFilterHidden(Boolean filterHiddenNew) {
            this.filterHidden = filterHiddenNew;
        }
        /**
         * @return the isOrg
         */
        public boolean isOrg() {
            return isOrg;
        }
        /**
         * @param isOrgNew the isOrg to set
         */
        public void setOrg(boolean isOrgNew) {
            this.isOrg = isOrgNew;
        }
        /**
         * @return the group
         */
        public PersonGroup getGroup() {
            return group;
        }
        /**
         * @param groupNew the group to set
         */
        public void setGroup(PersonGroup groupNew) {
            this.group = groupNew;
        }
        
    }

    /**
     * Check if user has permission to run query.
     * @param query query entity whose access is being checked
     * @param org current session org of the user
     * @param user current session user
     * @param role current session user role
     * @param portal current session portal
     * @return true if user has permission to run query
     */
    public boolean isQueryAllowed(Query query, Org org, Person user, Integer role, Portal portal) {
        boolean queryIsAllowed = false;
        // check if query executed is allowed for this user
        if ((role == Roles.DEVELOPER || role == Roles.PORTAL_MANAGER)
                && query.getProducer().getPortal().equals(portal)) {
            queryIsAllowed = true; // developers and portal managers can execute without permissions
        } else {
            if (portal.getMispType() == Const.MISP_TYPE_CITIZEN) {
                queryIsAllowed = isQueryAllowedForCitizen(query);
            } else {
                queryIsAllowed = isQueryAllowed(query, org, user);
            }
        }
        return queryIsAllowed;
    }
}
