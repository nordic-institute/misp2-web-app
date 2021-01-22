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
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeSet;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;

import ee.aktors.misp2.flash.FlashUtil;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.News;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.Package;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.model.TabGrouping;
import ee.aktors.misp2.model.Topic;
import ee.aktors.misp2.model.TopicName;
import ee.aktors.misp2.service.PortalService;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Const.QUERY_TYPE;
import ee.aktors.misp2.util.MenuUtil;
import ee.aktors.misp2.util.Roles;

/**
 */
public class EntranceAction extends QuickTipAction implements StrutsStatics {
    private static final long serialVersionUID = 1L;
    private PortalService portalService;
    private UserService uService;
    private List<Query> queries;
    private SortedMap<Topic, List<Query>> queryTopics;
    private Set<TabGrouping> tabGroupings;
    private List<Producer> producers;
    private List<Package> packages;
    private Integer orgId;
    private List<TopicName> topicNames;
    private String action;
    private List<News> news;
    private boolean redirectToIDCardLogin = false;
    private static final Logger LOG = LogManager.getLogger(EntranceAction.class);

    /**
     * @param portalService portalService to inject
     * @param uService uService to inject
     */
    public EntranceAction(PortalService portalService, UserService uService) {
        this.portalService = portalService;
        this.uService = uService;
    }

    /**
     * @return SUCCESS
     * @throws Exception if re attaching user fails
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String enter() throws Exception {
        if (redirectToIDCardLogin) {
            return "redirectToIDCardLogin";
        }
        if (user == null) {
            LOG.debug("User doesn't exist in session. Returning not_logged_in");
            return "not_logged_in";
        }

        OrgPerson orgPerson;
        int role;
        if (portal == null) {
            LOG.debug("First time entered selecting portal myself");
            List<Portal> allPortals = portalService.findUserPortalsAllowed(user);
            if (allPortals != null && !allPortals.isEmpty() && user.getId() != null) {
                Person userDB = uService.findObject(Person.class, user.getId());
                portal = userDB.getLastPortal();
                if (portal == null) {
                    portal = allPortals.get(0);
                    userDB.setLastPortal(portal);
                    user.setLastPortal(portal);
                }
            } else {
                addActionError(getText("text.no_portal_assigned"));
                LOG.debug("No portals bound with you");
                session.remove(Const.SESSION_USER_HANDLE);
                return "no_portal";
            }
        }

        if (portal.getMispType() == Const.MISP_TYPE_CITIZEN) {
            orgPerson = uService.findOrgPerson(user.getId(), portal.getOrgId().getId(), portal.getId());
            role = Roles.DUMBUSER;
        } else {
            orgPerson = determinWeakestRoleOP(user, portal);
            role = Roles.findWeakestRole(orgPerson.getRole());
            if (role == 0) {
                role = Roles.UNREGISTERED;
            }
        }

        session.put(Const.SESSION_USER_ROLE, role);

        if (orgPerson != null) {
            session.put(Const.SESSION_ACTIVE_ORG, uService.reAttach(orgPerson.getOrgId(), Org.class));
        } else {
            session.put(Const.SESSION_ACTIVE_ORG, portal.getOrgId());
        }

        action = "login_";
        switch (role) {
        case Roles.DUMBUSER:
            action += "user";
            break;
        case Roles.PERMISSION_MANAGER:
            action += "perm_manager";
            break;
        case Roles.DEVELOPER:
            action += "developer";
            break;
        case Roles.PORTAL_MANAGER:
            action += "manager";
            break;
        case Roles.UNREGISTERED:
            action += "unregistered";
            break;
        default:
            action = "login";
        }
        LOG.debug("action = " + action);

        return SUCCESS;
    }

    private OrgPerson determinWeakestRoleOP(Person person, Portal portal) throws IllegalArgumentException {
        LOG.debug("Determining weakest role org person");
        if (person == null) {
            throw new IllegalArgumentException("person is null");
        }
        if (portal == null) {
            throw new IllegalArgumentException("portal is null");
        }

        List<OrgPerson> orgPersonList = uService.findPortalOrgPersons(portal, person);
        int weakestRole = (portal.getMispType() == Const.MISP_TYPE_CITIZEN ? Roles.DUMBUSER : Roles.UNREGISTERED);
        OrgPerson orgPerson = null;
        if (orgPersonList != null && !orgPersonList.isEmpty()) {
            // user has orgs bound
            for (OrgPerson op : orgPersonList) {
                int opWeakest = Roles.findWeakestRole(op.getRole());
                if (opWeakest <= weakestRole) {
                    weakestRole = opWeakest;
                    try {
                        orgPerson = uService.reAttach(op, OrgPerson.class);
                    } catch (Exception ex) {
                        LOG.error(ex.getMessage(), ex);
                    }
                }
            }
        } else {
            orgPerson = new OrgPerson();
            orgPerson.setPersonId(person);
            orgPerson.setRole(weakestRole);
            orgPerson.setOrgId(portal.getOrgId());
            orgPerson.setPortal(portal);
        }
        return orgPerson;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String enterManager() {
        return SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String enterUnregistered() {
        return SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String enterLimitedRepresentative() {
        action = MenuUtil.MENU_AC_REG_UK_MANAGER.get(0);
        return SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String enterRepresentative() {
        action = MenuUtil.MENU_AC_REG_USER.get(0);
        return SUCCESS;
    }

    /**
     * @return SUCCESS
     * @throws Exception throws
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String enterUser() throws Exception {
        addActionMessage((String) FlashUtil.getFlash().get("errorMessage"));
        String lang = getLocale().getLanguage();
        setNews(portalService.findAllNews(portal, getLocale().getLanguage()));
        if (portal.getMispType() == Const.MISP_TYPE_CITIZEN) {
            setQueries(portalService.findAllAllowed(QUERY_TYPE.X_ROAD.ordinal(), portal));
        } else {
            if (user != null) {
                setQueries(portalService.findAllowed(user, org, portal, QUERY_TYPE.X_ROAD.ordinal()));
            }
        }
        if (portal.getUseTopics()) {
            if (CONFIG.getString("topics.layout", "list").equals("tabs")) { // tab layout
                tabGroupings = new TreeSet<TabGrouping>();
                SortedMap<Topic, List<Query>> topicMap = portalService.findQueryTopics(getQueries(), getText("topic.void_name"));
                topicNames = portalService.findTopicNames(lang, portal);
                for (Topic topic : topicMap.keySet()) {
                    List<Query> queryList = topicMap.get(topic);
                    List<Producer> producerList = portalService.findProducers(queryList);
                    tabGroupings.add(new TabGrouping (topic, portalService.findTopicName(topic, topicNames, lang), producerList, queryList));
                }
            } else { // normal layout
                setQueryTopics(portalService.findQueryTopics(getQueries(), getText("topic.void_name")));
                setTopicNames(portalService.findTopicNames(lang, portal));
                // add unsorted topic name if void topic has been created
                TopicName voidName = new TopicName();
                Iterator<?> itr = getQueryTopics().keySet().iterator();
                while (itr.hasNext()) {
                    Topic temp = (Topic) itr.next();
                    if (temp.getName().equals(getText("topic.void_name"))) {
                        voidName.setLang(lang);
                        voidName.setDescription(getText("topic.void_name"));
                        voidName.setTopic(temp);
                    }
                }
                if (voidName.getDescription() != null)
                    getTopicNames().add(voidName);
            }

        } else {
            setProducers(portalService.findProducers(getQueries()));
        }
        setPackages(new ArrayList<>());

        return SUCCESS;
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
     * @return the queryTopics
     */
    public SortedMap<Topic, List<Query>> getQueryTopics() {
        return queryTopics;
    }

    /**
     * @param queryTopicsNew the queryTopics to set
     */
    public void setQueryTopics(SortedMap<Topic, List<Query>> queryTopicsNew) {
        this.queryTopics = queryTopicsNew;
    }

    /**
     * @return the producers
     */
    public List<Producer> getProducers() {
        return producers;
    }

    /**
     * @param producersNew the producers to set
     */
    public void setProducers(List<Producer> producersNew) {
        this.producers = producersNew;
    }

    /**
     * @return the packages
     */
    public List<Package> getPackages() {
        return packages;
    }

    /**
     * @param packagesNew the packages to set
     */
    public void setPackages(List<Package> packagesNew) {
        this.packages = packagesNew;
    }

    /**
     * @return the orgId
     */
    public Integer getOrgId() {
        return orgId;
    }

    /**
     * @param orgIdNew the orgId to set
     */
    public void setOrgId(Integer orgIdNew) {
        this.orgId = orgIdNew;
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
     * @return the action
     */
    public String getAction() {
        return action;
    }

    /**
     * @param actionNew the action to set
     */
    public void setAction(String actionNew) {
        this.action = actionNew;
    }

    /**
     * @return the news
     */
    public List<News> getNews() {
        return news;
    }

    /**
     * @param newsNew the news to set
     */
    public void setNews(List<News> newsNew) {
        this.news = newsNew;
    }

    /**
     * @return the redirectToIDCardLogin
     */
    public boolean isRedirectToIDCardLogin() {
        return redirectToIDCardLogin;
    }

    /**
     * @param redirectToIDCardLoginNew the redirectToIDCardLogin to set
     */
    public void setRedirectToIDCardLogin(boolean redirectToIDCardLoginNew) {
        this.redirectToIDCardLogin = redirectToIDCardLoginNew;
    }

    /**
     * @return tab groupings if topics are grouped into tabs
     */
    public Set<TabGrouping> getTabGroupings() {
        return tabGroupings;
    }

}
