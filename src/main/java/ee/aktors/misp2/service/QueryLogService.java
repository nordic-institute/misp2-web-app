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

package ee.aktors.misp2.service;

import ee.aktors.misp2.beans.QueryLogItem;
import ee.aktors.misp2.model.*;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.NoResultException;
import javax.persistence.NonUniqueResultException;
import javax.xml.soap.Detail;
import java.math.BigInteger;
import java.util.*;

/**
 *
 * @author arnis.rips
 */
@Transactional
public class QueryLogService extends BaseService {
    
    private static final int MEMBER_CLASS_PART = 1;
    private static final int MEMBER_NAME_PART = 2;
    private static final int SUBSYSTEM_CODE_PART = 3;
    private static final int SERVICE_NAME_FIRST_PART = 4;
    private static final int SERVICE_NAME_SECOND_PART = 5;
    private static final int NR_OF_NAME_PARTS_MIN = 5;
    private static final int NR_OF_NAME_PARTS_MAX = 6;
    
    private static Logger logger = LogManager.getLogger(QueryLogService.class);

    /**
     * @param input input data for method see {@link QueryLogInput}
     * @return number of queries found
     */
    public long countPersonQueryLogs(QueryLogInput input) {
        Map<String, Object> parameters = new HashMap<String, Object>();
        StringBuilder queryBuf = new StringBuilder("select count(*) from QueryLog ql where ql.portal.id=:portalId ");

        queryBuf.append(" and " + getActiveOrgCheckClause(input.portal, input.activeOrg, parameters));

        if (input.personSsn != null && !input.personSsn.isEmpty()) {
            queryBuf.append(" and (");
            for (int cnt = 0; cnt < input.personSsn.size(); cnt++) {
                if (cnt > 0)
                    queryBuf.append(" or ");
                queryBuf.append(" ql.personSsn like :ssn" + cnt + " ");
                parameters.put("ssn" + cnt, input.personSsn.get(cnt));
            }
            queryBuf.append(" )");
        }

        if (input.queryDescription != null && !input.queryDescription.isEmpty()) {
            queryBuf.append(" and lower(ql.description) like :queryDesc ");
            parameters.put("queryDesc", "%" + input.queryDescription.toLowerCase() + "%");
        }

        if (input.queryId != null && !input.queryId.isEmpty()) {
            queryBuf.append(" and ql.queryId = :queryId ");
            parameters.put("queryId", input.queryId);
        }

        if (input.start != null) {
            queryBuf.append(" and ql.queryTime>=:start ");
            parameters.put("start", input.start);
        }
        if (input.end != null) {
            Calendar e = Calendar.getInstance();
            e.setTimeInMillis(input.end.getTime());
            queryBuf.append(" and ql.queryTime<=:end ");
            parameters.put("end", e.getTime());
        }

        if (input.successful) {
            queryBuf.append(" and ql.success=false ");

        }

        javax.persistence.Query q = getEntityManager().createQuery(queryBuf.toString()).setParameter("portalId",
                input.portal.getId());
        for (String param : parameters.keySet()) {
            q.setParameter(param, parameters.get(param));
        }
        return ((Long) q.getSingleResult()).intValue();
    }

    /**
     * @param input input data for method see {@link QueryLogInput}
     * @param pageNr number of page to get
     * @param pageSize size of one page
     * @return results that are on that page
     */
    public List<QueryLogItem>   findPersonQueryLogs(QueryLogInput input, int pageNr, int pageSize) {
        List<QueryLogItem> result = new ArrayList<>();

        Map<String, Object> parameters = new HashMap<String, Object>();
        StringBuilder queryBuf = new StringBuilder("select ql from QueryLog ql where ql.portal.id=:portalId ");

        if (input.personSsn != null && !input.personSsn.isEmpty()) {
            // queryBuf.append(" and ql.personSsn='").append(personSsn).append("' ");
            queryBuf.append(" and (");
            for (int cnt = 0; cnt < input.personSsn.size(); cnt++) {
                if (cnt > 0)
                    queryBuf.append(" or ");
                queryBuf.append(" ql.personSsn like :ssn" + cnt + " ");
                parameters.put("ssn" + cnt, input.personSsn.get(cnt));
            }
            queryBuf.append(" )");
        }

        if (StringUtils.isNotBlank(input.queryDescription)) {
            queryBuf.append(" and lower(ql.description) like :queryDesc ");
            parameters.put("queryDesc", "%" + input.queryDescription.toLowerCase() + "%");
        }

        if(StringUtils.isNotBlank(input.queryName)) {
            queryBuf.append(" and (lower(ql.queryName) like :queryName or lower(ql.mainQueryName) like :queryName)");
            parameters.put("queryName", "%" + input.queryName.toLowerCase() + "%");
        }

        if(StringUtils.isNotBlank(input.unitCode)) {
            queryBuf.append(" and lower(ql.unitCode) like :unitCode");
            parameters.put("unitCode", "%" + input.unitCode.toLowerCase() + "%");
        }

        if (input.queryId != null && !input.queryId.isEmpty()) {
            queryBuf.append(" and ql.queryId = :queryId ");
            parameters.put("queryId", input.queryId);
        }

        if (input.start != null) {
            Calendar s = Calendar.getInstance();
            s.setTimeInMillis(input.start.getTime());
            queryBuf.append(" and ql.queryTime>=:start ");
            parameters.put("start", s.getTime());
        }
        if (input.end != null) {
            Calendar e = Calendar.getInstance();
            e.setTimeInMillis(input.end.getTime());
            queryBuf.append(" and ql.queryTime<=:end ");
            parameters.put("end", e.getTime());
        }
        if (input.successful) {
            queryBuf.append(" and ql.success=false ");
        }
        queryBuf.append(" order by ql.queryTime DESC");
        javax.persistence.Query q = getEntityManager()
                .createQuery(queryBuf.toString()).setParameter("portalId", input.portal.getId());
        for (String param : parameters.keySet()) {
            q.setParameter(param, parameters.get(param));
        }
        if (pageSize > -1) {
            q.setMaxResults(pageSize);
            if (pageNr > -1) {
                q.setFirstResult(pageNr * (pageSize));
            }
        }
        @SuppressWarnings("unchecked")
        List<QueryLog> queryLogs = q.getResultList();
        if (queryLogs != null) {
            for (QueryLog ql : queryLogs) {
                QueryLogItem qli = new QueryLogItem();
                qli.setQueryLog(ql);
                qli.setPerson(findPerson(ql.getPersonSsn()));
                if (ql.getMainQueryName() != null && !ql.getMainQueryName().isEmpty()) {
                    qli.setQueryId(findQueryId(ql.getMainQueryName(), input.portal));
                } else if (ql.getQueryName() != null && !ql.getQueryName().isEmpty()) {
                    qli.setQueryId(findQueryId(ql.getQueryName(), input.portal));
                }
                result.add(qli);
            }
        }
        return result;
    }

    public Integer findQueryId(String nameWithProducer, Portal p) {
        try {
            if (p.isV6() && nameWithProducer.contains(":")) { // X-Road v6 normal services (non-complex-services)
                String[] splitName = nameWithProducer.split(":");

                if (splitName.length == NR_OF_NAME_PARTS_MAX || splitName.length == NR_OF_NAME_PARTS_MIN) {
                    // X-Road instance not used in query: String xroadInstance = splitName[0];
                    String memberClass = splitName[MEMBER_CLASS_PART];
                    String memberCode = splitName[MEMBER_NAME_PART];
                    String subsystemCode = splitName[SUBSYSTEM_CODE_PART];
                    String serviceName = splitName[SERVICE_NAME_FIRST_PART]
                            + (splitName.length == NR_OF_NAME_PARTS_MAX
                            ? "." + splitName[SERVICE_NAME_SECOND_PART] : "");
                    // logger.debug("Performing query with" +
                    // " mainQueryName: " + serviceName +
                    // " memberClass: " + memberClass +
                    // " memberCode: " + memberCode +
                    // " subsystemCode: " + subsystemCode);
                    return (Integer) getEntityManager()
                            .createQuery(
                                    "SELECT q.id FROM Query q " + "WHERE q.name = :serviceName "
                                            + "AND q.producer.memberClass = :memberClass "
                                            + "AND q.producer.shortName = :memberCode "
                                            + "AND q.producer.subsystemCode = :subsystemCode "
                                            + "AND q.producer.portal.id = :portalId")
                            .setParameter("serviceName", serviceName).setParameter("memberClass", memberClass)
                            .setParameter("memberCode", memberCode).setParameter("subsystemCode", subsystemCode)
                            .setParameter("portalId", p.getId()).getSingleResult();
                } else {
                    logger.error("Expected 4 or 5 elements in nameWithProducer '" + nameWithProducer
                            + "' separated by ':' for v6 portal");
                    return null;
                }
            } else { // All X-Road v5 and v4 services + X-Road v6 complex-services
                return (Integer) getEntityManager()
                        .createQuery(
                                "SELECT q.id FROM Query q "
                                        + "WHERE q.name = :mainQueryName AND q.producer.shortName = :producerName "
                                        + "AND q.producer.portal.id = :portalId")
                        .setParameter("mainQueryName", nameWithProducer.substring(nameWithProducer.indexOf('.') + 1))
                        .setParameter("producerName", nameWithProducer.substring(0, nameWithProducer.indexOf('.')))
                        .setParameter("portalId", p.getId()).getSingleResult();
            }

        } catch (NoResultException nre) {
            return null;
        } catch (NonUniqueResultException nure) {
            return null;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * @param input queryLogInput
     * @return number of queries found
     */
    public long countAllUserQueryLogs(QueryLogInput input) {
        input.personSsn = null;
        return countPersonQueryLogs(input);
    }

    /**
     * @param pageNr number of page to get
     * @param pageSize size of one page
     * @return results that are on that page
     */
    public List<QueryLogItem> findAllUsersQueryLogs(QueryLogInput input, int pageNr, int pageSize) {
        input.personSsn = null;
        return findPersonQueryLogs(input, pageNr, pageSize);
    }

    /**
     * @param ssn ssn of person
     * @return null if exception occurs (if none or more than one result), result otherwise
     */
    public Person findPerson(String ssn) {
        javax.persistence.Query s;
        Person p;
        try {
            s = getEntityManager().createQuery("select p from Person p where p.ssn=:ssn");
            s.setParameter("ssn", ssn);
            p = (Person) s.getSingleResult();
        } catch (Exception e) {
            return null;
        }
        return p;
    }

    /**
     * @param queryId query id to find
     * @return result if found exactly one matching, null otherwise
     */
    public QueryLog findByQueryId(String queryId) {
        try {
            return (QueryLog) getEntityManager().createQuery("FROM QueryLog ql " + "WHERE ql.queryId = :queryId")
                    .setParameter("queryId", queryId).getSingleResult();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * @return query_log_id_seq next value
     */
    public Integer selectNextId() {
        try {
            BigInteger id = (BigInteger) getEntityManager().createNativeQuery("select nextval('query_log_id_seq')")
                    .getSingleResult();
            return id.intValue();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * @return query_error_log_id_seq next value
     */
    public Integer selectNextIdForQueryErrorLog() {
        try {
            BigInteger id = (BigInteger) getEntityManager().createNativeQuery(
                    "select nextval('query_error_log_id_seq')").getSingleResult();
            return id.intValue();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Get HQL check clause for filtering QueryLogs (indicated by "ql" alias) based on active organization.<br/>
     * Filtering is only done if following conditions are met: <br/>
     * 1) Portal's type is either {@link Const#MISP_TYPE_UNIVERSAL} or {@link Const#MISP_TYPE_ORGANISATION} <br/>
     * 2) Portals's {@link Portal#getUnitIsConsumer()} is false <br/>
     * 3) Portal's organization is not the same as activeOrg <br/>
     * If those conditions are met, then only those QueryLogs pass filtering, which are related to activeOrg (according
     * to {@link QueryLog#getUnitCode()})
     * 
     * @param portal
     *            - User's active {@link Portal}
     * @param activeOrg
     *            - User's active {@link Org}
     * @param queryParameters
     *            - Parameters will be inserted here
     * @return
     */
    private String getActiveOrgCheckClause(Portal portal, Org activeOrg, Map<String, Object> queryParameters) {
        String checkClause = " (true=true) ";
        if ((portal.getMispType() == Const.MISP_TYPE_UNIVERSAL || portal.getMispType() == Const.MISP_TYPE_ORGANISATION)
               && portal.getUnitIsConsumer() == false && portal.getOrgId().getId().equals(activeOrg.getId()) == false) {
            checkClause = " (ql.unitCode=:unitCode) ";
            if (portal.isV6()) {
                queryParameters.put(
                        "unitCode",
                        XRoadUtil.getXRoadV6RepresentedPartySummary(activeOrg.getMemberClass(),
                                activeOrg.getCode()));
            } else {
                queryParameters.put("unitCode", activeOrg.getCode());
            }
        }
        return checkClause;
    }

    /**
     * @param input input data for method see {@link LogQueryInput}
     * @return
     */
    public QueryLog logQuery(LogQueryInput input) {
        QueryLog queryLog = new QueryLog();
        queryLog.setOrgCode(input.consumer);
        queryLog.setUnitCode(input.unit);
        queryLog.setQueryId(input.queryId);
        queryLog.setPersonSsn(input.ssn);
        queryLog.setUsername(input.ssn);
        queryLog.setQueryName(input.service);
        queryLog.setMainQueryName(input.mainServiceName);
        queryLog.setQueryTime(new Date());
        queryLog.setQueryTimeSec(input.queryTimeSec);
        queryLog.setPortal(input.portal);
        queryLog.setDescription(input.description);
        queryLog.setSuccess(true);
        logger.debug("Returning queryLog " + queryLog.getMainQueryName() + " with id " + queryLog.getQueryId());
        return queryLog;
    }

    /**
     * Persist query error log entries.
     * @param queryLog unsuccessful query log
     * @param faultCode faultCode to set to query error
     * @param faultString description to set to query error
     * @param detail detail to set to query error
     * @throws Exception 
     */
    public void logQueryError(QueryLog queryLog, String faultCode, String faultString, String detail) throws Exception {
        queryLog.setSuccess(false);
        save(queryLog);
        QueryErrorLog queryErrorLog = queryLog.getQueryErrorLogId();
        if (queryLog.getQueryErrorLogId() == null) {
            queryErrorLog = new QueryErrorLog();
            queryLog.setQueryErrorLogId(queryErrorLog);
            queryErrorLog.setQueryLog(reAttach(queryLog, QueryLog.class));
        }
        queryErrorLog.setCode(faultCode);
        queryErrorLog.setDescription(faultString);
        queryErrorLog.setUsername(queryLog.getUsername());
        queryErrorLog.setDetail(detail);
        save(queryErrorLog);
    }

    /**
     * Wrapper around #logQueryError(QueryLog queryLog, String faultCode, String faultString, String detail) to take
     * detail as SOAP Detail object instance.
     * @param queryLog unsuccessful query log
     * @param faultCode faultCode to set to query error
     * @param faultString description to set to query error
     * @param detail detail object to set to query error
     * @throws Exception
     */
    public void logQueryError(QueryLog queryLog, String faultCode, String faultString, Detail detail) throws Exception {
        logQueryError(queryLog, faultCode, faultString, XMLUtil.nodeToString(detail));;
    }
    
    
    /**
     * @author kristjan.kiolein
     * Used to give input to :<br>
     * {@link QueryLogService#countPersonQueryLogs}<br>
     * {@link QueryLogService#findPersonQueryLogs}<br>
     * {@link QueryLogService#findAllUsersQueryLogs}
     */
    public static class QueryLogInput {
        private Portal portal;
        private Org activeOrg;
        private ArrayList<String> personSsn;
        private String queryDescription;
        private String queryName;
        private String unitCode;

        private String queryId;
        private Date start;
        private Date end;
        private boolean successful;
        
        public Portal getPortal() {
            return portal;
        }
        public void setPortal(Portal portal) {
            this.portal = portal;
        }
        public Org getActiveOrg() {
            return activeOrg;
        }
        public void setActiveOrg(Org activeOrg) {
            this.activeOrg = activeOrg;
        }
        public ArrayList<String> getPersonSsn() {
            return personSsn;
        }
        public void setPersonSsn(ArrayList<String> personSsn) {
            this.personSsn = personSsn;
        }
        public String getQueryDescription() {
            return queryDescription;
        }
        public void setQueryDescription(String queryDescription) {
            this.queryDescription = queryDescription;
        }
        public String getQueryId() {
            return queryId;
        }
        public void setQueryId(String queryId) {
            this.queryId = queryId;
        }
        public Date getStart() {
            return start;
        }
        public void setStart(Date start) {
            this.start = start;
        }
        public Date getEnd() {
            return end;
        }
        public void setEnd(Date end) {
            this.end = end;
        }
        public boolean isSuccessful() {
            return successful;
        }
        public void setSuccessful(boolean successful) {
            this.successful = successful;
        }
        public String getQueryName() {
            return queryName;
        }
        public void setQueryName(String queryName) {
            this.queryName = queryName;
        }
        public String getUnitCode() {
            return unitCode;
        }
        public void setUnitCode(String unitCode) {
            this.unitCode = unitCode;
        }
    }
    
    /**
     * @author kristjan.kiolein
     * Used to give input to :<br>
     * {@link QueryLogService#logQuery}<br>
     */
    public static class LogQueryInput {
        private String ssn;
        private Portal portal;
        private String consumer;
        private String unit;
        private String queryId;
        private String mainServiceName;
        private String service;
        private String language;
        private String description;
        private String queryTimeSec;
        
        
        public String getSsn() {
            return ssn;
        }
        public void setSsn(String ssn) {
            this.ssn = ssn;
        }
        public Portal getPortal() {
            return portal;
        }
        public void setPortal(Portal portal) {
            this.portal = portal;
        }
        public String getConsumer() {
            return consumer;
        }
        public void setConsumer(String consumer) {
            this.consumer = consumer;
        }
        public String getUnit() {
            return unit;
        }
        public void setUnit(String unit) {
            this.unit = unit;
        }
        public String getQueryId() {
            return queryId;
        }
        public void setQueryId(String queryId) {
            this.queryId = queryId;
        }
        public String getMainServiceName() {
            return mainServiceName;
        }
        public void setMainServiceName(String mainServiceName) {
            this.mainServiceName = mainServiceName;
        }
        public String getService() {
            return service;
        }
        public void setService(String service) {
            this.service = service;
        }
        public String getLanguage() {
            return language;
        }
        public void setLanguage(String language) {
            this.language = language;
        }
        public String getDescription() {
            return description;
        }
        public void setDescription(String description) {
            this.description = description;
        }
        public String getQueryTimeSec() {
            return queryTimeSec;
        }
        public void setQueryTimeSec(String queryTimeSec) {
            this.queryTimeSec = queryTimeSec;
        }
    }
}
