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

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.persistence.NoResultException;

import org.apache.logging.log4j.LogManager;

import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.model.QueryTopic;
import ee.aktors.misp2.model.Topic;
import ee.aktors.misp2.model.TopicName;

/**
 * Topic entity service methods
 * 
 * @author arnis.rips
 */
public class TopicService extends BaseService {

    /**
     * Find topic by portal and name; optionally exclude one ID. Used for checking uniqueness of a new topic name:
     * that's why one topic ID can be excluded - to exclude currently modified entry from uniqueness check.
     * 
     * @param portal
     *            portal entity the session user is currently associated with
     * @param name
     *            topic entity name
     * @param excludeTopicId
     *            exclude the topic entity with this ID from search results, could be null to exclude nothing
     * @return topic entity matching the criteria or null
     */
    public Topic findTopic(Portal portal, String name, Integer excludeTopicId) {
        try {
            Map<String, Object> params = new HashMap<String, Object>();
            String hql = "SELECT t FROM Topic t WHERE t.portal=:portal AND t.name=:name";
            params.put("portal", portal);
            params.put("name", name);
            if (excludeTopicId != null) {
                hql += " AND t.id!=:excludeTopicId";
                params.put("excludeTopicId", excludeTopicId);
            }
            return (Topic) createQuery(hql, params).getSingleResult();
        } catch (NoResultException nre) {
            return null;
        }
    }

    /**
     * Find all topics from portal ordered by topic name.
     * 
     * @param portal
     *            portal entity the session user is currently associated with
     * @return list of topics found
     */
    @SuppressWarnings("unchecked")
    public List<Topic> findTopics(Portal portal) {
        return getEntityManager().createQuery("SELECT t FROM Topic t WHERE t.portal=:portal ORDER BY t.name")
                .setParameter("portal", portal).getResultList();
    }

    /**
     * Save topic entity to database.
     * 
     * @param topic
     *            entity to be saved
     * @param name
     *            topic name
     * @param priority
     *            topic priority
     * @param portal
     *            portal entity the session user is currently associated with
     */
    public void saveTopic(Topic topic, String name, Integer priority, Portal portal) {
        topic.setName(name);
        topic.setPriority(priority);
        topic.setPortal(portal);
        save(topic);
    }

    /**
     * Find topic names by its description or part of it.
     * @param portal
     *           portal entity the session user is currently associated with
     * @param filterName
     *          a text part of {@link TopicName} description
     * @param lang
     *          topic name language
     * @return list of found topic names
     */
    @SuppressWarnings("unchecked")
    public List<TopicName> findTopicNames(Portal portal, String filterName, String lang) {
        try {
            String hql = "select tn from TopicName tn where lower(tn.description) like :topics "
                    + "and tn.topic.portal.id=:portal" + " and tn.lang=:lang";
            LogManager.getLogger(this.getClass()).debug(hql + lang + portal.getId());
            javax.persistence.Query s = getEntityManager().createQuery(hql).setParameter("portal", portal.getId())
                    .setParameter("lang", lang)
                    .setParameter("topics", "%" + (filterName == null ? "" : filterName.toLowerCase()) + "%");
            @SuppressWarnings("rawtypes")
            List list = s.getResultList();
            Collections.sort(list, TopicName.COMPARE_BY_DESCRIPTION);
            return list;
        } catch (Exception e) {
            // LogManager.getLogger(TopicService.class).warn(e.getMessage());
            return null;
        }
    }

    /**
     * Find {@link QueryTopic} many-to-many association entity by the respective Topic and Query IDs.
     * @param topicId {@link Topic} entity ID
     * @param queryId {@link Query} entity ID
     * @return found {@link QueryTopic} entity or null, if nothing was found
     */
    public QueryTopic findQueryTopic(Integer topicId, Integer queryId) {
        try {
            javax.persistence.Query s = getEntityManager()
                    .createQuery("select qt from QueryTopic qt where qt.query.id=:queryId and qt.topic.id=:topicId")
                    .setParameter("queryId", queryId).setParameter("topicId", topicId);
            return (QueryTopic) s.getSingleResult();
        } catch (NoResultException nre) {
            return null;
        }
    }

    /**
     * Find all many-to-many association {@link QueryTopic} entities belonging to given {@link Topic}
     * @param topicId {@link Topic} entity ID
     * @return list of found {@link QueryTopic} entities
     */
    @SuppressWarnings("unchecked")
    public List<QueryTopic> findAllQueryTopic(Integer topicId) {
        try {
            javax.persistence.Query s = getEntityManager()
                    .createQuery("select qt from QueryTopic qt where qt.topic.id=:topicId")
                    .setParameter("topicId", topicId);
            return s.getResultList();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Save {@link QueryTopic} association (in other words, link query to topic)
     * @param queryTopic {@link QueryTopic} entity to be saved
     * @param query {@link Query} entity to be linked with QueryTopic
     * @param topic {@link Topic} entity to be linked with QueryTopic
     */
    public void saveQueryTopic(QueryTopic queryTopic, Query query, Topic topic) {
        queryTopic.setQuery(query);
        queryTopic.setTopic(topic);
        save(queryTopic);
    }

    /**
     * Find topic names for a given {@link Topic} entity
     * @param topic {@link Topic} entity
     * @return list of {@link TopicName} belonging to given topic
     */
    @SuppressWarnings("unchecked")
    public List<TopicName> findTopicNames(Topic topic) {
        try {
            javax.persistence.Query s = getEntityManager()
                    .createQuery("select tn from TopicName tn where tn.topic=:topic").setParameter("topic", topic);
            return (List<TopicName>) s.getResultList();
        } catch (Exception e) {
            LogManager.getLogger(TopicService.class).warn(e.getMessage());
            return null;
        }
    }

    /**
     * Find topic name by topic and language
     * @param topic {@link Topic} entity
     * @param language topic name language
     * @return {@link TopicName} entity
     */
    public TopicName findTopicName(Topic topic, String language) {
        try {
            javax.persistence.Query s = getEntityManager()
                    .createQuery("select tn FROM TopicName tn where tn.topic.id=:topicId and tn.lang=:language");
            return (TopicName) s.setParameter("topicId", topic.getId()).setParameter("language", language)
                    .getSingleResult();
        } catch (NoResultException nre) {
            return null;
        }
    }

    /**
     * Add field values to {@link TopicName} entity and then save it to database.
     * @param topicName {@link TopicName} entity to be saved
     * @param topic {@link Topic} entity to be associated with TopicName before saving
     * @param lang topic name language
     * @param description topic name description
     */
    public void saveTopicName(TopicName topicName, Topic topic, String lang, String description) {
        topicName.setTopic(topic);
        topicName.setLang(lang);
        topicName.setDescription(description);
        save(topicName);
    }

}
