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

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

import javax.persistence.NoResultException;

import org.apache.commons.lang3.time.DateUtils;
import org.apache.logging.log4j.LogManager;
import org.springframework.transaction.annotation.Transactional;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.model.CheckRegisterStatus;
import ee.aktors.misp2.model.GroupItem;
import ee.aktors.misp2.model.GroupPerson;
import ee.aktors.misp2.model.News;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.Package;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.PersonGroup;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.PortalName;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.model.QueryName;
import ee.aktors.misp2.model.QueryTopic;
import ee.aktors.misp2.model.Topic;
import ee.aktors.misp2.model.TopicName;
import ee.aktors.misp2.model.Xforms;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Const.QUERY_TYPE;
import ee.aktors.misp2.util.Roles;

/**
 * portal service
 */
@Transactional
public class PortalService extends BaseService {

    /**
     * @param queryName checkRegisterStatuses queryName
     * @return null if no results, result otherwise
     */
    public CheckRegisterStatus findCheckRegisterStatus(String queryName) {
        javax.persistence.Query s = getEntityManager().createQuery(
                "select c from CheckRegisterStatus c where c.queryName=:qn");
        s.setParameter("qn", queryName);
        try {
            return (CheckRegisterStatus) s.getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }

    /**
     * @param shortName portals short name
     * @return null if no results or exception, result otherwise
     */
    public Portal findPortal(String shortName) {
        String hql = "select p from Portal p where p.shortName=:sname";
        javax.persistence.Query s = getEntityManager().createQuery(hql);
        s.setParameter("sname", shortName);
        try {
            Portal p = (Portal) s.getSingleResult();
            return p;
        } catch (NoResultException e) {
            return null;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * @param org supOrg
     * @return a list of the results
     */
    @SuppressWarnings("unchecked")
    public List<Org> findSubOrgs(Org org) {
        javax.persistence.Query q = getEntityManager().createQuery(
                "select o from Org o where o.supOrgId.id=:oId order by o.code");
        q.setParameter("oId", org.getId());
        return q.getResultList();
    }

    /**
     * @return null if no results, a list of the results otherwise
     */
    @SuppressWarnings("unchecked")
    public List<Portal> findAllPortals() {
        javax.persistence.Query s = getEntityManager().createQuery(
                "select p from Portal p order by p.shortName, p.mispType desc");
        try {
            return (List<Portal>) s.getResultList();
        } catch (NoResultException e) {
            return null;
        }
    }

    /**
     * @param person person whom portals will be used
     * @param language language of active name (value of result pairs)
     * @return empty list if no portals are found, results otherwise
     */
    public Map<String, String> findUserPortalsAllowedActiveNames(Person person, String language) {
        List<Portal> resultPortals = findUserPortalsAllowed(person);
        Map<String, String> result = new LinkedHashMap<String, String>();
        if (resultPortals != null) {
            for (Portal p : resultPortals) {
                result.put(p.getShortName(), p.getActiveName(language));
            }
        }
        return result;
    }

    /**
     * @param person person whom portals will be fetched
     * @return empty list if no allowed portals, allowed portals otherwise
     */
    @SuppressWarnings("unchecked")
    public List<Portal> findUserPortalsAllowed(Person person) {
        List<Portal> result = new ArrayList<Portal>();
        String hql = "select distinct op.portal from OrgPerson op " + "where op.personId.id=:person";
        javax.persistence.Query s = getEntityManager().createQuery(hql).setParameter("person", person.getId());
        List<Portal> resultList = s.getResultList();
        if (resultList != null && !resultList.isEmpty()) {
            // we  order portals by their descriptions
            
            hql = "SELECT pn.portal FROM PortalName pn WHERE pn.lang=:language"
                    + " AND pn.portal IN (:portals) ORDER BY pn.description";
            s = getEntityManager().createQuery(hql)
                    .setParameter("language", ActionContext.getContext().getLocale().getLanguage())
                    .setParameter("portals", resultList);
                    resultList = s.getResultList();
        }

        if (resultList != null) {
            result.addAll(resultList);
        }

        List<Portal> allPortals = findAllPortals();
        List<Portal> allowedPortals = new ArrayList<Portal>();

        if (allPortals != null) {
            for (Portal p : allPortals) {
                if (p.isOpenPortal() && !result.contains(p)) {
                    allowedPortals.add(p);
                }
            }
        }

        for (Portal p : result) {
            allowedPortals.add(p);
        }
        /*
         * Collections.sort(allowedPortals, new Comparator(){ public int compare(Object o1, Object o2) { Portal p1 =
         * (Portal) o1; Portal p2 = (Portal) o2; return p1.getMispType()-p2.getMispType(); } });
         */

        LogManager.getLogger(this.getClass()).debug("result = " + allowedPortals);
        return allowedPortals;
    }

    /**
     * @param org org
     * @param person subject
     * @param searchTerm term searched
     * @param portal portal
     * @return searched queries
     */
    public List<Query> filterSearchQueries(Org org, Person person, String searchTerm, Portal portal) {
        LogManager.getLogger(PortalService.class).debug(
                "Searching for queries with: orgId=" + org + ", personId=" + person + ", searchTerm=" + searchTerm);
        List<Query> allowed = findAllowed(person, org, portal, QUERY_TYPE.X_ROAD.ordinal());
        // List<Query> allowedComplex = findAllowed(person, org, portal, Const.QUERY_TYPE_X_ROAD_COMPLEX);
        List<Query> result = new ArrayList<Query>();
        String lang = ActionContext.getContext().getLocale().getLanguage();
        if (searchTerm != null && !searchTerm.isEmpty()) {
            for (Query q : allowed) {
                if (q.getFullIdentifier() != null && q.getFullIdentifier().toLowerCase().contains(searchTerm.toLowerCase())) {
                    result.add(q);
                } else {
                    List<QueryName> qnames = q.getQueryNameList();
                    for (QueryName qn : qnames) {
                        if (qn.getLang().equals(lang) && qn.getDescription().toLowerCase().contains(searchTerm.toLowerCase())) {
                            result.add(q);
                        }
                    }
                }
            }
        } else {
            for (Query q : allowed) {
                result.add(q);
            }
        }
        return result;
    }

    /**
     * @param portal org persons portal
     * @param person org persons person
     * @return a list of the results
     */
    @SuppressWarnings("unchecked")
    public List<OrgPerson> findPortalOrgPersons(Portal portal, Person person) {
        String hql = "select op from OrgPerson op where op.portal.id=:portal and op.personId.id=:person";
        javax.persistence.Query s = getEntityManager().createQuery(hql).setParameter("portal", portal.getId())
                .setParameter("person", person.getId());

        return s.getResultList();
    }

    /**
     * @param portal portal of org person
     * @param org org of org person
     * @param person person of org person
     * @return null if no results, the result otherwise
     */
    public OrgPerson findOrgPerson(Portal portal, Org org, Person person) {
        String hql = "select op from OrgPerson op where op.personId.id=:person"
                + " and op.orgId.id=:org and op.portal.id=:portal";
        javax.persistence.Query s = getEntityManager().createQuery(hql).setParameter("person", person.getId())
                .setParameter("org", org.getId()).setParameter("portal", portal.getId());
        try {
            return (OrgPerson) s.getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }

    /**
     * @param type type of query
     * @param portal portal of group items person group
     * @return empty list if no results, results otherwise
     */
    public List<Query> findAllAllowed(Integer type, Portal portal) {
        List<Query> queries = new ArrayList<Query>();
        // em.merge(p);
        javax.persistence.Query s = getEntityManager().createQuery(
                "select gi from GroupItem gi where gi.personGroup.portal.id=:portalId");
        @SuppressWarnings("unchecked")
        List<GroupItem> giList = (List<GroupItem>) s.setParameter("portalId", portal.getId()).getResultList();
        for (int j = 0; j < giList.size(); j++) {
            GroupItem gi = giList.get(j);
            if (type == QUERY_TYPE.X_ROAD.ordinal() && !gi.getInvisible() || type == QUERY_TYPE.X_ROAD_COMPLEX
                    .ordinal() && gi.getOrgQuery().getQueryId().getProducer() == null) {
                Query q = gi.getOrgQuery().getQueryId();
                if (!(queries.contains(q)) && !(isXFormsEmpty(q))) {
                    queries.add(q);
                }
            }
        }
        Collections.sort(queries, Query.COMPARE_BY_QUERY_DESCRIPTION);
        return queries;
    }

    /**
     * @param p person
     * @param o org
     * @param portal portal
     * @param type query type
     * @return empty list if no results, results otherwise
     */
    public List<Query> findAllowed(Person p, Org o, Portal portal, Integer type) {
        List<Query> queries = new ArrayList<Query>();
        try {
            Org ora = this.reAttach(o, Org.class);
            if (portal.getMispType() == Const.MISP_TYPE_CITIZEN) {

                List<PersonGroup> groupList = ora.getGroupList();
                if (ora.getSupOrgId() != null) {
                    groupList.addAll(ora.getSupOrgId().getGroupList());
                }

                for (PersonGroup g : groupList) {
                    for (GroupItem gi : g.getGroupItemList()) {
                        if (!gi.getInvisible()) {
                            Query q = gi.getOrgQuery().getQueryId();
                            if (!queries.contains(q) && !isXFormsEmpty(q)) {
                                queries.add(q);
                            }
                        }
                    }
                }
            } else {
                Person pra = this.reAttach(p, Person.class);

                List<GroupPerson> gps = pra.getGroupPersonList();
                for (GroupPerson gp : gps) {
                    Date currentDate = DateUtils.truncate(new Date(), Calendar.DATE);//Normalize for comparing against validuntil
                    boolean valid = (gp.getValiduntil()==null || gp.getValiduntil().compareTo(currentDate)>=0);//Validuntil has to be unset or not before current date
                    
                    if (gp.getOrg().getId() == ora.getId().intValue() && valid) {
                        PersonGroup g = gp.getPersonGroup();
                        if (g.getOrgId().getId().intValue() == ora.getId().intValue() // group.org = active org
                                || ora.getSupOrgId() != null // active org is suborg and suporg is the group maintainer
                                && g.getOrgId().getId().intValue() == ora.getSupOrgId().getId().intValue()) {
                            List<GroupItem> items = g.getGroupItemList();
                            for (GroupItem gi : items) {

                                int orgId = gi.getOrgQuery().getOrgId().getId().intValue();
                                // if super org does not exist, assign 0 for id
                                // (any value would work, the value will be never used)
                                int supOrgId = 0;
                                if (ora.getSupOrgId() != null) {
                                    supOrgId = ora.getSupOrgId().getId().intValue();
                                }
                                Query q = gi.getOrgQuery().getQueryId();
                                
                                if (
                                    (
                                        // only this portal groups
                                        gi.getPersonGroup().getPortal().getId().intValue() == portal.getId().intValue()
                                        //allowed queries only to this org
                                        &&
                                        (
                                            orgId == ora.getId().intValue()
                                            ||
                                            ora.getSupOrgId() != null // allowed to superior org
                                            && orgId == supOrgId
                                        )
                                        && type == QUERY_TYPE.X_ROAD.ordinal() // simple queries
                                        && !(gi.getInvisible()) // and not invisible
                                        || // or complex queries with no producer set
                                        type == QUERY_TYPE.X_ROAD_COMPLEX.ordinal() && q.getProducer() == null
                                    )
                                    && !queries.contains(q)
                                    && !isXFormsEmpty(q)) {
                                    
                                        queries.add(q);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            LogManager.getLogger(PortalService.class).error(e.getMessage(), e);
        }
        Collections.sort(queries, Query.COMPARE_BY_QUERY_DESCRIPTION);
        return queries;
    }

    /**
     * Sorts queries into groups by topic.
     * Those without topic will all be added to voidName topic
     * @param queries queries to find topics for
     * @param voidName topic name
     * @return map of topics and corresponding queries
     * @throws Exception throws
     */
    public SortedMap<Topic, List<Query>> findQueryTopics(List<Query> queries, String voidName) throws Exception {
        SortedMap<Topic, List<Query>> result = new TreeMap<Topic, List<Query>>();
        for (Query q : queries) {
            if (q.getQueryTopicList() != null && !q.getQueryTopicList().isEmpty()) {
                for (QueryTopic qt : q.getQueryTopicList()) {
                    Topic t = qt.getTopic();
                    if (!result.containsKey(t)) {
                        result.put(t, new ArrayList<Query>());
                    }
                    result.get(t).add(q);
                }
            } else {
                Topic t = new Topic(null, voidName);
                if (!result.containsKey(t)) {
                    result.put(t, new ArrayList<Query>());
                }
                result.get(t).add(q);
            }
        }
        return result;
    }

    /**
     * @param lang topic name language
     * @return null if exception, result list otherwise
     */
    @SuppressWarnings("unchecked")
    public List<TopicName> findTopicNames(String lang, Portal portal) {
        try {
            javax.persistence.Query s = getEntityManager().createQuery(
                    "select tn from TopicName tn where tn.topic.portal.id=:portalId and tn.lang=:lang")
                    .setParameter("portalId", portal.getId())
                    .setParameter("lang", lang);
            return (List<TopicName>) s.getResultList();
        } catch (Exception e) {
            LogManager.getLogger(TopicService.class).warn(e.getMessage());
            return null;
        }
    }

    /**
     * @param q queries
     * @return empty list if no producers, results otherwise
     */
    public List<Producer> findProducers(List<Query> q) {
        List<Producer> producers = new ArrayList<Producer>();
        for (int i = 0; i < q.size(); i++) {
            Query temp = q.get(i);
            if (temp.getProducer() != null) {
                Producer p = temp.getProducer();
                if (!(producers.contains(p))) {
                    producers.add(p);
                }
            }
        }
        return producers;
    }

    /**
     * @param portal portal
     * @param o org
     * @return null if exception, empty list if no results, results otherwise
     */
    public List<Person> findManagers(Portal portal, Org o) {
        List<Person> managers = new ArrayList<Person>();

        try {
            Org org = this.reAttach(o, Org.class);
            List<OrgPerson> ops = org.getOrgPersonList();
            for (int i = 0; i < ops.size(); i++) {
                OrgPerson op = ops.get(i);
                if (op.getPortal().equals(portal) && Roles.isSet(op.getRole().intValue(), Roles.PORTAL_MANAGER)) {
                    Person p = op.getPersonId();
                    if (!(managers.contains(p))) {
                        managers.add(p);
                    }
                }

            }
            return managers;
        } catch (Exception e) {
            LogManager.getLogger(PortalService.class).error(e.getMessage(), e);
            return null;
        }

    }

    /**
     * @param portal portal of PortalName
     * @param language portal names language
     * @return null if no results, result otherwise
     */
    public PortalName findPortalName(Portal portal, String language) {
        try {
            javax.persistence.Query s = getEntityManager().createQuery(
                    "select pn from PortalName pn where pn.portal.id=:portalId and pn.lang=:language");
            return (PortalName) s.setParameter("portalId", portal.getId()).setParameter("language", language)
                    .getSingleResult();
        } catch (NoResultException nre) {
            return null;
        }
    }

    /**
     * @param q query
     * @return true if no results or when result is empty string, false otherwise
     */
    public boolean isXFormsEmpty(Query q) {
        javax.persistence.Query s = getEntityManager().createQuery("select x FROM Xforms x where x.query.id=:queryId");
        Xforms x = (Xforms) s.setParameter("queryId", q.getId()).getSingleResult();
        return x.getForm() == null || x.getForm().equals("");
    }

    /**
     * @param portal portal whom person group to delete
     */
    public void removeAll(Portal portal) {
        getEntityManager().createNativeQuery("delete from Group_ where portal_id=:portalId")
                .setParameter("portalId", portal.getId()).executeUpdate();
        remove(portal);
    }

    /**
     * @param p portal whom news to get
     * @param lang language of news
     * @return null if no results, a list of results otherwise
     */
    @SuppressWarnings("unchecked")
    public List<News> findAllNews(Portal p, String lang) {
        if (p == null) {
           return null;
        }
        javax.persistence.Query s = getEntityManager().createQuery(
                "select n from News n where lang=:lang and portal_id=:portal order by n.lastModified desc");
        s.setParameter("lang", lang).setParameter("portal", p.getId());
        try {
            return (List<News>) s.getResultList();
        } catch (NoResultException e) {
            return null;
        }
    }

    /**
     * Find topic name from a list of topic names using topic and language code.
     * @param topic topic to which topic name is being searched for
     * @param topicNames list of topic names
     * @param lang language code
     * @return topic name associated with given topic
     */
    public TopicName findTopicName(Topic topic, List<TopicName> topicNames, String lang) {
        if (topic == null || topic.getId() == null || topicNames == null) {
            return null;
        }
        if (lang != null) {
            // Search for topic name matching topic with given language
            for (TopicName topicName : topicNames) {
                if (topicName != null && topicName.getLang() != null && topicName.getLang().equals(lang) && topic.equals(topicName.getTopic())) {
                    return topicName;
                }
            }
        }
        // If correct language name was not found, find any topic name that matches given topic
        for (TopicName topicName : topicNames) {
            if (topicName != null && topic.equals(topicName.getTopic())) {
                return topicName;
            }
        }
        return  null;
    }

}
