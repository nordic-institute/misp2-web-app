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

package ee.aktors.misp2.action;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.beans.GroupValidPair;
import ee.aktors.misp2.beans.T3SecWrapper;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.mail.NotificationMail;
import ee.aktors.misp2.model.GroupItem;
import ee.aktors.misp2.model.GroupPerson;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgQuery;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.PersonGroup;
import ee.aktors.misp2.model.PersonMailOrg;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.service.GroupService;
import ee.aktors.misp2.service.QueryService;
import ee.aktors.misp2.service.QueryService.QuieriesFilterInput;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.LogQuery;
import ee.aktors.misp2.util.MISPUtils;
import ee.aktors.misp2.util.xroad.XRoadUtil;

/**
 */
public class GroupAction extends SecureLoggedAction {

    private static final int PAGE_SIZE = -2;
    private static final long serialVersionUID = 1L;
    private GroupService groupService;
    private UserService userService;
    private QueryService queryService;
    private Integer groupId;
    private PersonGroup group;
    private String filterProducer;
    private String filterName;
    private String filterDescription;
    private String filterAllowed;
    private String filterHidden;
    private Boolean filter;
    private List<PersonGroup> groups;
    private List<Person> persons;
    private List<String> groupPersonIdList = new ArrayList<String>();
    private List<Query> allowedQueries;
    private List<Map<Producer, List<Query>>> allowedProducersWithQueries = new ArrayList<Map<Producer, List<Query>>>();
    private List<String> groupAllowedQueryIdList = new ArrayList<String>();
    private List<String> allowedQueryIdList = new ArrayList<String>();
    private NotificationMail notificationMail = new NotificationMail();
    private String lang;
    private static final Logger LOG = LogManager.getLogger(GroupAction.class);

    /**
     * @param groupService groupService to inject
     * @param userService  userService  to inject
     * @param queryService queryService to inject
     */
    public GroupAction(GroupService groupService, UserService userService, QueryService queryService) {
        super(userService);
        this.groupService = groupService;
        this.userService = userService;
        this.queryService = queryService;
    }

    @Override
    public void prepare() throws Exception {
        super.prepare();
        lang = ActionContext.getContext().getLocale().getLanguage();
        if (groupId != null) {
            group = groupService.findObject(PersonGroup.class, groupId);
        } /*
           * else { group = new PersonGroup(); }
           */
    }

    /**
     * main list of groups
     * must return list of groups of active org and groups of head org
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String groupList() {
        groups = groupService.findGroups(((Org) session.get(Const.SESSION_ACTIVE_ORG)).getId(),
                ((Portal) session.get(Const.SESSION_PORTAL)).getId());
        return Action.SUCCESS;
    }

    /**
     * group data editing
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String groupEditData() {
        // if editing existing group - check permission
        if (group != null && group.getId() != null && !hasEditRight()) {
            addActionError(getText("text.error.item_not_allowed"));
            return Action.ERROR;
        }

        return Action.SUCCESS;
    }

    /**
     * @return ERROR if doesn't have editing rights or when logging fails, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String groupSaveData() {
        if (!groupService.isGroupNameUniqueInUnit(group, org)) {
            addFieldError("group.name", getText("groups.edit_data.name_unique"));
            return Action.INPUT;
        }

        // if editing existing group - check permission
        if (group.getId() != null) {
            PersonGroup oldGroup = groupService.findObject(PersonGroup.class, group.getId());
            group.setGroupItemList(oldGroup.getGroupItemList());
            group.setGroupPersonList(oldGroup.getGroupPersonList());
            group.setOrgId(oldGroup.getOrgId());
            group.setPortal(oldGroup.getPortal());
            group.setCreated(oldGroup.getCreated());
            group.setLastModified(oldGroup.getLastModified());
            group.setUsername(oldGroup.getUsername());

            if (!hasEditRight()) {
                addActionError(getText("text.error.item_not_allowed"));
                return Action.ERROR;
            }
        }

        if (group.getId() == null) {
            group.setOrgId(org);

            // -- Log group add
            T3SecWrapper t3 = initT3(LogQuery.USERGROUP_ADD);
            t3.getT3sec().setGroupName(group.getName());
            if (!log(t3)) {
                addActionError(getText("text.fail.save.log"));
                LOG.warn("Usergroup add failed because of logging problems.");
                return Action.ERROR;
            }
            // ----- log group add end ----- //
        }
        group.setPortal(portal);
        groupService.save(group);
        addActionMessage(getText("text.success.save"));

        return Action.SUCCESS;
    }

    /**
     * @return ERROR if doesn't have editing rights or when logging fails, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String groupDelete() {
        if (!hasEditRight()) {
            addActionError(getText("text.error.item_not_allowed"));
            return Action.ERROR;
        }
        // -- Log group delete
        T3SecWrapper t3 = initT3(LogQuery.USERGROUP_DELETE);
        t3.getT3sec().setGroupName(group.getName());
        if (!log(t3)) {
            addActionError(getText("text.fail.delete.log"));
            LOG.warn("Usergroup delete failed because of logging problems.");
            return Action.ERROR;
        }
        // ----- log group delete end ----- //
        groupService.remove(group);
        addActionMessage(getText("text.success.delete"));

        return Action.SUCCESS;
    }

    private void traceQueries(String comment, List<Query> queries) {
        for (Query query : queries) {
            LOG.trace(comment + " " + query.getFullIdentifier());
        }
    }

    /**
     *  group rights editing
     * @return ERROR if is not global group, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String groupEditRights() {
        String result;
        // has right to change query rights of group
        if (hasEditRight()) {
            result = "edit";
        // can only view query rights of group
        } else if (isGlobalGroup()) {
            result = "view";
        } else {
            addActionError(getText("text.error.item_not_allowed"));
            return Action.ERROR;
        }

        Boolean isAllowed = MISPUtils.stringToBoolean(filterAllowed, Const.FILTER_YES, Const.FILTER_NULL);
        Boolean isHidden = MISPUtils.stringToBoolean(filterHidden, Const.FILTER_YES, Const.FILTER_NULL);
        if ((portal.getMispType() == Const.MISP_TYPE_UNIVERSAL && portal.getUnitIsConsumer()
                || portal.getMispType() == Const.MISP_TYPE_ORGANISATION)
                && ((Org) session.get(Const.SESSION_ACTIVE_ORG)).getId().equals(portal.getOrgId().getId())) {
            // get all distinct allowed queries of current portal
            if (isFilter() != null && isFilter()) {
                QuieriesFilterInput input = new QuieriesFilterInput();
                input.setOrg(null);
                input.setPortal(portal);
                input.setFilterDescription(filterDescription);
                input.setFilterName(filterName);
                input.setFilterProducer(filterProducer);
                input.setFilterAllowed(isAllowed);
                input.setFilterHidden(isHidden);
                input.setOrg(false);
                input.setGroup(group);
                // remove portal id check
                allowedQueries = queryService.findAllowedQueriesFilter(input);
                traceQueries("allowedQueries branch 1 ", allowedQueries);
            } else {
                allowedQueries = queryService.findDistinctAllowedQueriesByPortal(portal);
                traceQueries("allowedQueries branch 2 ", allowedQueries);
            }
            // ids of query rights of group + id_hidden if the query must be hidden from users
            for (Object[] q : groupService.findDistinctGroupAllowedQueries(group)) {
                groupAllowedQueryIdList.add(((Query) q[0]).getId().toString());
                if (q[1] != null && (Boolean) q[1] == true) {
                    groupAllowedQueryIdList.add(((Query) q[0]).getId() + "_hidden");
                }
            }

            if (allowedQueries.size() > 0) {
                setAllowedProducersWithQueries(allowedQueries);
            }
        } else {
            // get active org (and head org, if active org is sub org) allowed queries of current portal
            if (isFilter() != null && isFilter()) {
                QuieriesFilterInput input = new QuieriesFilterInput();
                input.setOrg(org);
                input.setPortal(portal);
                input.setFilterDescription(filterDescription);
                input.setFilterName(filterName);
                input.setFilterProducer(filterProducer);
                input.setFilterAllowed(isAllowed);
                input.setFilterHidden(isHidden);
                input.setOrg(true);
                input.setGroup(group);
                allowedQueries = queryService.findAllowedQueriesFilter(input);
                traceQueries("allowedQueries branch 3 ", allowedQueries);
            } else {
                allowedQueries = queryService.findAllowedQueriesByOrgAndPortal(org, portal);
                traceQueries("allowedQueries branch 4 ", allowedQueries);
            }

            // ids of query rights of group + id_hidden if the query must be hidden from users
            for (GroupItem gi : group.getGroupItemList()) {
                groupAllowedQueryIdList.add(gi.getOrgQuery().getQueryId().getId().toString());
                if (gi.getInvisible() != null && gi.getInvisible()) {
                    groupAllowedQueryIdList.add(gi.getOrgQuery().getQueryId().getId() + "_hidden");
                }
            }

            if (allowedQueries.size() > 0) {
                setAllowedProducersWithQueries(allowedQueries);
            }
        }

        return result;
    }

    /**
     * @return ERROR if logging fails, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String groupSaveRights() {
        group = groupService.findObject(PersonGroup.class, group.getId());

        if (!hasEditRight()) {
            addActionError(getText("text.error.item_not_allowed"));
            return Action.ERROR;
        }
        List<Org> orgs = new ArrayList<Org>(); // universal (unit is consumer) portal
        if (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL) {
            if (org.getId().equals(portal.getOrgId().getId())) { // portal manager
                try {
                    org = groupService.reAttach(org, Org.class);
                } catch (Exception e) {
                    LOG.error(e.getMessage(), e);
                    addActionError(getText("text.fail.save"));
                    return Action.ERROR;
                } // add group items for all sub orgs
                orgs = org.getOrgList();
            } else { // unit manager add group items for active org
                orgs.add(org);
            }
        } else { // add group items for head org
            orgs.add(portal.getOrgId());
        }
        // create map: orgId -> groupAllowedQueryIdList (for adding selected query rights
        // to every sub org in universal, unit is consumer type of portal)
        Map<Integer, List<String>> orgGroupAllowedQueryIdMap = new HashMap<Integer, List<String>>();
        for (Org o : orgs) {
            orgGroupAllowedQueryIdMap.put(o.getId(), new ArrayList<String>(groupAllowedQueryIdList));
            if (o.getSupOrgId() != null && !orgGroupAllowedQueryIdMap.containsKey(o.getSupOrgId().getId())) {
                orgGroupAllowedQueryIdMap.put(o.getSupOrgId().getId(), new ArrayList<String>(groupAllowedQueryIdList));
            }
        }
        List<GroupItem> gilOld = group.getGroupItemList();
        List<GroupItem> gil = new ArrayList<GroupItem>();
        // can't use existing list, otherwise will get java.util.ConcurrentModificationException and Hibernate bug
        // http://opensource.atlassian.com/projects/hibernate/browse/HHH-511 when setting list back on group
        // remove reference to groupItems from group, otherwise can't remove groupItems from database
        group.setGroupItemList(null);

        List<String> removedQueryNames = new ArrayList<String>();
        List<String> addedQueryNames = new ArrayList<String>();
        String queryId = null;
        List<String> ids = null;
        for (GroupItem gi : gilOld) {
            queryId = String.valueOf(gi.getOrgQuery().getQueryId().getId());
            ids = orgGroupAllowedQueryIdMap.get(gi.getOrgQuery().getOrgId().getId());
            // log.debug("key: " + gi.getOrgQuery().getOrgId().getId() + " ids:" + ids + " orgGroupAllowedQueryIdMap: "
            // + orgGroupAllowedQueryIdMap.keySet());
            if (ids != null && !ids.remove(queryId)) { // don't readd rights which were already given
                // remove rights from database which were deselected
                if (allowedQueryIdList.contains(queryId)) {
                    groupService.remove(gi);
                    removedQueryNames.add(gi.getOrgQuery().getQueryId().getName());
                }
            } else { // if it was checked to be hidden - hide it
                if (ids != null && ids.remove(queryId + "_hidden")) {
                    gi.setInvisible(true);
                } else {
                    gi.setInvisible(false);
                } // update rights which remained given
                gil.add(gi);
                // log.debug("adding old: " + gi.getGroup().getId() + " orgQuery: " + gi.getOrgQuery().getId());
            }
        }

        GroupItem gi = null;
        OrgQuery oq = null;

        for (Org o : orgs) {
            ids = orgGroupAllowedQueryIdMap.get(o.getId());

            for (String id : ids) {
                if (!id.endsWith("_hidden")) {
                    if ((portal.getMispType() == Const.MISP_TYPE_UNIVERSAL
                            || portal.getMispType() == Const.MISP_TYPE_ORGANISATION)
                            && !portal.getOrgId().getId().equals(o.getId()))
                        oq = queryService.findOrgQueryByOrgIdAndQueryId(o.getSupOrgId().getId(), Integer.parseInt(id));
                    else
                        oq = queryService.findOrgQueryByOrgIdAndQueryId(o.getId(), Integer.parseInt(id));

                    if (oq != null) {
                        gi = new GroupItem();

                        gi.setInvisible(ids.contains(id + "_hidden"));
                        gi.setOrgQuery(oq);
                        gi.setPersonGroup(group);

                        addedQueryNames.add(oq.getQueryId().getName());

                        gil.add(gi);
                        // log.debug("adding new: " + gi.getGroup().getId() + " orgQuery: " + gi.getOrgQuery().getId() +
                        // " queryId:" + id);
                    } else {
                        addActionError(queryService.findObject(Query.class, Integer.valueOf(id)).getName() + " "
                                + getText("groups.edit_rights.not_allowed_for") + " " + o.getFullName(lang));
                    }
                }
            }
        }

        // remove duplicated items from gil it is possible id in the previous loop gets repeated
        // so the same orgQuery(oq) gets added multiple times and DB unique constraint fails
        // getting around this issue by simply removing duplicated entries from gil
        Set<Integer> existingOrgQueryIds = new HashSet<Integer>();
        for (Iterator<GroupItem> it = gil.iterator(); it.hasNext();) {
            GroupItem groupItem = it.next();
            if (groupItem == null || groupItem.getOrgQuery() == null || groupItem.getOrgQuery().getId() == null)
                continue;
            Integer orgQueryId = groupItem.getOrgQuery().getId();
            if (existingOrgQueryIds.contains(orgQueryId)) {
                it.remove();
            } else {
                existingOrgQueryIds.add(orgQueryId);
            }
        }
        for (GroupItem groupItem : gil) {
            LOG.debug("Saving: group: " + groupItem.getPersonGroup().getId() + " orgQuery: "
                    + groupItem.getOrgQuery().getId());
        }

        group.setGroupItemList(gil);

        if (!removedQueryNames.isEmpty()) {
            T3SecWrapper t3 = initT3(LogQuery.QUERY_RIGHTS_DELETE);
            t3.getT3sec().setGroupName(group.getName());
            t3.setQueries(removedQueryNames);
            if (!log(t3)) {
                addActionError(getText("text.fail.save.log"));
                LOG.warn("Saving query rights failed because of logging problems.");
                return Action.ERROR;
            }
        }
        if (!addedQueryNames.isEmpty()) {
            T3SecWrapper t3 = initT3(LogQuery.QUERY_RIGHTS_ADD);
            t3.getT3sec().setGroupName(group.getName());
            t3.setQueries(addedQueryNames);
            if (!log(t3)) {
                addActionError(getText("text.fail.delete.log"));
                LOG.warn("Deleting query rights failed because of logging problems.");
                return Action.ERROR;
            }
        }

        groupService.save(group);
        addActionMessage(getText("text.success.save"));

        return Action.SUCCESS;
    }

    /**
     * group members editing
     * @return ERROR if doesn't have editing rights or is not global, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String groupEditMembers() {
        if (!hasEditRight() && !isGlobalGroup()) {
            addActionError(getText("text.error.item_not_allowed"));
            return Action.ERROR;
        }
        // all persons
        persons = userService.findOrgUsers(null, null, null, org, PAGE_SIZE, PAGE_SIZE);

        // ids of active org persons in group
        for (GroupPerson gp : group.getGroupPersonList()) {
            if (Integer.valueOf(gp.getOrg().getId()).equals(org.getId())) {
                groupPersonIdList.add(gp.getPerson().getId().toString());
            }
        }

        return Action.SUCCESS;
    }

    /**
     * group members saving
     * @return ERROR if doesn't have editing rights or is not global, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String groupSaveMembers() {
        group = groupService.findObject(PersonGroup.class, group.getId());

        // can't add members to group of other sub org - session active org is not equal to group org
        // and it is not a global group (portal head org group)
        if (!hasEditRight() && !isGlobalGroup()) {
            addActionError(getText("text.error.item_not_allowed"));
            return Action.ERROR;
        }
        // persons under active org only
        List<GroupPerson> gplOld = new ArrayList<GroupPerson>();
        for (GroupPerson gp : group.getGroupPersonList()) {
            if (Integer.valueOf(gp.getOrg().getId()).equals(org.getId())) {
                gplOld.add(gp);
            }
        }

        List<GroupPerson> gpl = new LinkedList<GroupPerson>();
        // can't use existing list, otherwise will get java.util.ConcurrentModificationException and
        // Hibernate bug http://opensource.atlassian.com/projects/hibernate/browse/HHH-511
        // when setting list back on group remove reference to groupPersons from group,
        // otherwise can't remove groupPersons from database
        group.setGroupPersonList(null);
        String personId = null;
        List<String> addedUsers = new ArrayList<String>();
        List<String> removedUsers = new ArrayList<String>();

        ArrayList<GroupValidPair> gvpList = new ArrayList<GroupValidPair>(1); // NotifcationMail accepts GroupValidPair
                                                                              // lists
        gvpList.add(new GroupValidPair(group.getName()));

        for (GroupPerson gp : gplOld) {
            personId = String.valueOf(gp.getPerson().getId());
            if (!groupPersonIdList.contains(personId)) {
                // remove persons from database who were deselected
                Person rmPerson = gp.getPerson();
                PersonMailOrg rmPmo = userService.findPersonMailOrg(rmPerson.getId(), org.getId());

                removedUsers.add(rmPerson.getSsn()); // save users who were removed for logging

                if (rmPmo != null && rmPmo.getNotifyChanges()) {
                    notificationMail.setRemovedGroups(gvpList);
                    notificationMail.setReceiverEmail(rmPmo.getMail());
                    notificationMail.setReceiverName(rmPerson.getFullName());
                    notificationMail.setOrganizationName(org.getFullName(lang));
                    notificationMail.send();
                }

                groupService.remove(gp);
            } else {
                // keep persons who remained selected (needed for setting last_modified value)
                gpl.add(gp);
                // don't readd persons who were already selected
                groupPersonIdList.remove(personId);
            }
        }
        GroupPerson gp = null;
        Person p = null;
        for (String id : groupPersonIdList) {
            gp = new GroupPerson();
            p = userService.findObject(Person.class, Integer.parseInt(id));
            gp.setPerson(p);
            gp.setPersonGroup(group);
            gp.setOrg(org);

            Person addedPerson = gp.getPerson();
            PersonMailOrg adddedPmo = userService.findPersonMailOrg(addedPerson.getId(), org.getId());

            addedUsers.add(addedPerson.getSsn()); // save users for logging purposes

            if (adddedPmo != null && adddedPmo.getNotifyChanges()) {
                notificationMail.setAddedGroups(gvpList);
                notificationMail.setReceiverEmail(adddedPmo.getMail());
                notificationMail.setReceiverName(addedPerson.getFullName());
                notificationMail.setOrganizationName(org.getFullName(lang));
                notificationMail.send();
            }
            gpl.add(gp);
        }
        group.setGroupPersonList(gpl);

        if (!addedUsers.isEmpty()) {
            T3SecWrapper t3 = initT3(LogQuery.USER_ADD_TO_GROUP);
            t3.setUsersTo(addedUsers);
            t3.getT3sec().setGroupName(group.getName());
            if (!log(t3)) {
                addActionError(getText("text.fail.save.log"));
                LOG.warn("Saving group users failed because of logging problems.");
                return Action.ERROR;
            }
        }
        if (!removedUsers.isEmpty()) {
            T3SecWrapper t3 = initT3(LogQuery.USER_DELETE_FROM_GROUP);
            t3.setUsersTo(removedUsers);
            t3.getT3sec().setGroupName(group.getName());
            if (!log(t3)) {
                addActionError(getText("text.fail.delete.log"));
                LOG.warn("Deleting group users failed because of logging problems.");
                return Action.ERROR;
            }
        }

        groupService.save(group);
        addActionMessage(getText("text.success.save"));

        return Action.SUCCESS;
    }
    
    /**
     * not shown in citizen misp and not shown to universal misp portal head org
     * @return true if portal misp type is not MISP_TYPE_CITIZEN
     * and is not MISP_TYPE_UNIVERSAL and MISP_TYPE_ORGANISATION
     */
    public boolean getShowEditMembersButton() {
        Portal portal = (Portal) session.get(Const.SESSION_PORTAL);

        return portal.getMispType() != Const.MISP_TYPE_CITIZEN && !(
                (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL
                    || portal.getMispType() == Const.MISP_TYPE_ORGANISATION)
                && org.getId().equals(portal.getOrgId().getId()));
    }

    /**
     * extra check for if the user thinks he's clever and substitutes the groupId hidden field with another id
     * @return if has edit rights
     */
    private boolean hasEditRight() {
        return org.getId().equals(group.getOrgId().getId()) && portal.getId().equals(group.getPortal().getId());
    }

    /**
     * @return is global group
     */
    private boolean isGlobalGroup() {
        return portal.getOrgId().getId().equals(group.getOrgId().getId());
    }
    
    /**
     * @param allowedQueriesIn list of allowed queries
     */
    public void setAllowedProducersWithQueries(List<Query> allowedQueriesIn) {
        Collections.sort(allowedQueriesIn, Query.COMPARE_BY_PRODUCER_SHORT_NAME);
        List<Producer> allowedProducers = new ArrayList<Producer>();
        Set<Producer> prevProducers = new HashSet<Producer>();

        for (Query aq : allowedQueriesIn) {
            if (!XRoadUtil.isProducerDuplicatedInSet(aq.getProducer(), prevProducers)) {
                prevProducers.add(aq.getProducer());
                if (aq.getProducer() != null) {
                    allowedProducers.add(aq.getProducer());
                }
            }
        }
        Collections.sort(allowedQueriesIn, Query.COMPARE_BY_QUERY_DESCRIPTION);

        List<Producer> allowedProducersCopy = new ArrayList<Producer>(allowedProducers);
        Collections.sort(allowedProducersCopy, Producer.COMPARE_BY_PRODUCER_DESCRIPTION);
        for (Producer p : allowedProducersCopy) {
            List<Query> allowedProducersQueries = new ArrayList<Query>();
            for (Query qa : allowedQueriesIn) {
                if (qa.getProducer().getId().equals(p.getId())) {
                    allowedProducersQueries.add(qa);
                }
            }
            Map<Producer, List<Query>> map = new HashMap<Producer, List<Query>>();
            map.put(p, allowedProducersQueries);
            getAllowedProducersWithQueries().add(map);
        }
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

    /**
     * @return the groupId
     */
    public Integer getGroupId() {
        return groupId;
    }

    /**
     * @param groupIdNew the groupId to set
     */
    public void setGroupId(Integer groupIdNew) {
        this.groupId = groupIdNew;
    }


    /**
     * @return the groups
     */
    public List<PersonGroup> getGroups() {
        return groups;
    }

    /**
     * @return the persons
     */
    public List<Person> getPersons() {
        return persons;
    }

    /**
     * @return the allowedQueries
     */
    public List<Query> getAllowedQueries() {
        return allowedQueries;
    }

    /**
     * @return the groupAllowedQueryIdList
     */
    public List<String> getGroupAllowedQueryIdList() {
        return groupAllowedQueryIdList;
    }

    /**
     * @param groupAllowedQueryIdListNew the groupAllowedQueryIdList to set
     */
    public void setGroupAllowedQueryIdList(List<String> groupAllowedQueryIdListNew) {
        this.groupAllowedQueryIdList = groupAllowedQueryIdListNew;
    }

    /**
     * @return the groupPersonIdList
     */
    public List<String> getGroupPersonIdList() {
        return groupPersonIdList;
    }

    /**
     * @param groupPersonIdListNew the groupPersonIdList to set
     */
    public void setGroupPersonIdList(List<String> groupPersonIdListNew) {
        this.groupPersonIdList = groupPersonIdListNew;
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
     * @return the filterAllowed
     */
    public String getFilterAllowed() {
        return filterAllowed;
    }

    /**
     * @param filterAllowedNew the filterAllowed to set
     */
    public void setFilterAllowed(String filterAllowedNew) {
        this.filterAllowed = filterAllowedNew;
    }

    /**
     * @return the filterHidden
     */
    public String getFilterHidden() {
        return filterHidden;
    }

    /**
     * @param filterHiddenNew the filterHidden to set
     */
    public void setFilterHidden(String filterHiddenNew) {
        this.filterHidden = filterHiddenNew;
    }

    /**
     * @return the allowedQueryIdList
     */
    public List<String> getAllowedQueryIdList() {
        return allowedQueryIdList;
    }

    /**
     * @param allowedQueryIdListNew the allowedQueryIdList to set
     */
    public void setAllowedQueryIdList(List<String> allowedQueryIdListNew) {
        this.allowedQueryIdList = allowedQueryIdListNew;
    }

    /**
     * @return the allowedProducersWithQueries
     */
    public List<Map<Producer, List<Query>>> getAllowedProducersWithQueries() {
        return allowedProducersWithQueries;
    }

    /**
     * @return is filter
     */
    public Boolean isFilter() {
        return filter;
    }
    
    /**
     * @param filterNew filter to set
     */
    public void setFilter(Boolean filterNew) {
        this.filter = filterNew;
    }

}
