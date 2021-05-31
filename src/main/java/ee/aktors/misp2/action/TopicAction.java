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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.model.QueryName;
import ee.aktors.misp2.model.QueryTopic;
import ee.aktors.misp2.model.Topic;
import ee.aktors.misp2.model.TopicName;
import ee.aktors.misp2.service.QueryService;
import ee.aktors.misp2.service.TopicService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.LanguageUtil;
import ee.aktors.misp2.util.xroad.XRoadUtil;

/**
 *
 * @author arnis.rips
 */
public class TopicAction extends SessionPreparedBaseAction implements IManagementAction {
    private static final long serialVersionUID = 1L;

    private ArrayList<String> languages = LanguageUtil.getLanguages();
    private TopicService tService;
    private QueryService qService;
    private String filterName;
    private Integer topicId;
    private List<TopicName> searchResults;
    private Topic topic;
    private List<TopicName> topicNames;
    private List<QueryName> allAllowedQueries = new ArrayList<>();
    private List<Map<Producer, List<Query>>> allowedProducersWithQueries = new ArrayList<>();
    private List<Integer> groupAllowedQueryIdList = new ArrayList<>();
    private static final Logger LOG = LogManager.getLogger(TopicAction.class);
    private static final String FILTER = "filter";

    /**
     * @param tService tService to inject
     * @param qService qService to inject
     */
    public TopicAction(TopicService tService, QueryService qService) {
        this.tService = tService;
        this.qService = qService;
    }

    @Override
    public void prepare() throws Exception {
        super.prepare();
        if (!FILTER.equals(getContext().getActionInvocation().getProxy().getMethod())) {
            List<Query> allQueryList = qService.findAllPortalQueries(portal);
            if (topicId != null) {
                topic = tService.findObject(Topic.class, topicId);
                LOG.debug("Found topic " + topic);
            } else {
                LOG.debug("topicId == null");
            }
            for (Query q : allQueryList) {
                if (q.getQueryNameList().size() != 0) {
                    QueryName qn = q.getActiveName(getLocale().getLanguage());
                    if(qn == null && !q.getQueryNameList().isEmpty()) {
                        qn = q.getQueryNameList().get(0);
                    }
                    if (qn != null) {
                        allAllowedQueries.add(qn);
                    }
                }
            }

            if (topic != null && topic.getQueryTopicList() != null) {
                for (QueryTopic qt : topic.getQueryTopicList()) {
                    groupAllowedQueryIdList.add(qt.getQuery().getId());
                }
            }

            getAllAllowedQueries().sort(QueryName.COMPARE_BY_PRODUCER_SHORT_NAME);

            List<Producer> allowedProducers = new ArrayList<>();
            Set<Producer> prevProducers = new HashSet<>();

            for (QueryName qn : getAllAllowedQueries()) {
                if (XRoadUtil.isProducerUniqueInSet(qn.getQuery().getProducer(), prevProducers)) {
                    prevProducers.add(qn.getQuery().getProducer());
                    if (qn.getQuery().getProducer() != null) {
                        allowedProducers.add(qn.getQuery().getProducer());
                    }
                }
            }

            getAllAllowedQueries().sort(QueryName.COMPARE_BY_QUERY_DESCRIPTION);

            List<Producer> allowedProducersCopy = new ArrayList<>(allowedProducers);
            allowedProducersCopy.sort(Producer.COMPARE_BY_PRODUCER_DESCRIPTION);
            for (Producer ap : allowedProducersCopy) {
                List<Query> allowedProducersQueries = new ArrayList<>();
                for (QueryName aqn : getAllAllowedQueries()) {
                    if (aqn.getQuery().getProducer().getId().equals(ap.getId())) {
                        allowedProducersQueries.add(aqn.getQuery());
                    }
                }

                Map<Producer, List<Query>> map = new HashMap<>();
                map.put(ap, allowedProducersQueries);
                getAllowedProducersWithQueries().add(map);
            }

            initTopicNames();
        }
    }

    @Override
    public void validate() {
        for (List<String> s : getFieldErrors().values()) {
            setActionErrors(s);
        }
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String showFilter() {
        return filter();
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String filter() {
        searchResults = tService.findTopicNames(portal, filterName, getLocale().getLanguage());
        return SUCCESS;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String addItem() {
        return SUCCESS;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String showItem() {
        if (topic != null && isDenied(topic)) {
            addActionError(getText("text.error.item_not_allowed"));
            return ERROR;
        }
        return SUCCESS;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String submitItem() {
        if (topic != null) {
            if (topic.getId() != null && isDenied(topic)) {
                addActionError(getText("text.error.item_not_allowed"));
                return ERROR;
            } else if (tService.findTopic(portal, topic.getName(), topic.getId()) != null) {
                LOG.error("Duplicate topic " + topic + " cannot save topic '" + topic.getName() + "'!");
                addActionError(getText("text.error.service_duplicate"));
                return SUCCESS;
            }
            List<QueryTopic> qts = new ArrayList<>();
            List<QueryTopic> allTopicQueries = tService.findAllQueryTopic(topic.getId());
            for (Integer qId : groupAllowedQueryIdList) {
                QueryTopic qt = tService.findQueryTopic(topic.getId(), qId);
                if (qt == null) {
                    qt = new QueryTopic();
                    qt.setTopic(topic);
                    try {
                        qt.setQuery(tService.findObject(Query.class, qId));
                    } catch (Exception ex) {
                        LOG.warn(ex.getMessage(), ex);
                    }
                }
                qts.add(qt);
            }

            for (QueryTopic tq : allTopicQueries) {
                if (!groupAllowedQueryIdList.contains(tq.getQuery().getId())) {
                    topic.getQueryTopicList().remove(tq);
                    tService.remove(tq);
                }
            }

            topic.setQueryTopicList(qts);
            try {

                topic.setPortal(portal);
                tService.save(topic);

                saveTopicNames();

                addActionMessage(getText("text.success.save"));
            } catch (Exception e) {
                addActionError(getText("text.fail.save"));
            }
            topicId = topic.getId();
        }

        return SUCCESS;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String deleteItem() {
        if (topicId != null) {
            Topic t;
            t = tService.findObject(Topic.class, topicId);
            if (t != null) {

                if (isDenied(t)) {
                    addActionError(getText("text.error.item_not_allowed"));
                    return ERROR;
                }

                tService.remove(t);
                addActionMessage(getText("text.success.delete"));
                return SUCCESS;
            } else {
                LOG.error("No topic found for id=" + topicId + ". Nothing was deleted");
            }
        } else {
            LOG.error("Topic id not set topicId=" + topicId + ". Nothing was deleted");
        }
        addActionError(getText("text.fail.delete"));
        return ERROR;
    }

    /**
     * @param topicIn topic to check
     * @return is topic is allowed in session
     */
    private boolean isDenied(Topic topicIn) {
        return !session.get(Const.SESSION_PORTAL).equals(topicIn.getPortal());
    }

    private void initTopicNames() {
        topicNames = new ArrayList<>();
        for (String language : languages) {
            TopicName topicName = null;
            if (topicId != null) {
                topicName = tService.findTopicName(topic, language); // Take existing one
            }
            if (topicName == null) { // If existing one is not accessible or does not exist, then create new one
                topicName = new TopicName();
                topicName.setDescription("");
                topicName.setLang(language);
            }
            topicNames.add(topicName);
        }
    }

    private void saveTopicNames() {
        for (int i = 0; i < languages.size(); i++) {
            String language = languages.get(i);
            TopicName topicName = topicNames.get(i);

            topicName.setLang(language);
            String description = topicName.getDescription();
            TopicName existingTopicName = tService.findTopicName(topic, language);
            topicName = (existingTopicName == null ? topicName : existingTopicName);
            // Use existing topicName entity if it exists

            topicName.setDescription(description);
            topicName.setLang(language);
            topicName.setTopic(topic);
            tService.save(topicName);
        }
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
     * @return the topicId
     */
    public Integer getTopicId() {
        return topicId;
    }

    /**
     * @param topicIdNew the topicId to set
     */
    public void setTopicId(Integer topicIdNew) {
        this.topicId = topicIdNew;
    }

    /**
     * @return the topic
     */
    public Topic getTopic() {
        return topic;
    }

    /**
     * @param topicNew the topic to set
     */
    public void setTopic(Topic topicNew) {
        this.topic = topicNew;
    }

    /**
     * @return the groupAllowedQueryIdList
     */
    public List<Integer> getGroupAllowedQueryIdList() {
        return groupAllowedQueryIdList;
    }

    /**
     * @param groupAllowedQueryIdListNew the groupAllowedQueryIdList to set
     */
    public void setGroupAllowedQueryIdList(List<Integer> groupAllowedQueryIdListNew) {
        this.groupAllowedQueryIdList = groupAllowedQueryIdListNew;
    }

    /**
     * @return the searchResults
     */
    public List<TopicName> getSearchResults() {
        return searchResults;
    }

    /**
     * @param filterNameNew the filterName to set
     */
    public void setFilterName(String filterNameNew) {
        this.filterName = filterNameNew;
    }

    /**
     * @return the topicNames
     */
    public List<TopicName> getTopicNames() {
        return topicNames;
    }

    /**
     * @param topicNamesNew the topicNames to set
     */
    public void setTopicNames(List<TopicName> topicNamesNew) {
        this.topicNames = topicNamesNew;
    }

    /**
     * @return the allAllowedQueries
     */
    public List<QueryName> getAllAllowedQueries() {
        return allAllowedQueries;
    }

    /**
     * @param allAllowedQueriesNew the allAllowedQueries to set
     */
    public void setAllAllowedQueries(List<QueryName> allAllowedQueriesNew) {
        this.allAllowedQueries = allAllowedQueriesNew;
    }

    /**
     * @return the allowedProducersWithQueries
     */
    public List<Map<Producer, List<Query>>> getAllowedProducersWithQueries() {
        return allowedProducersWithQueries;
    }

    /**
     * @param allowedProducersWithQueriesNew the allowedProducersWithQueries to set
     */
    public void setAllowedProducersWithQueries(List<Map<Producer, List<Query>>> allowedProducersWithQueriesNew) {
        this.allowedProducersWithQueries = allowedProducersWithQueriesNew;
    }
}
