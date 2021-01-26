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

import java.util.List;

import javax.persistence.NoResultException;
import javax.persistence.NonUniqueResultException;
import javax.persistence.Query;

import org.springframework.transaction.annotation.Transactional;

import ee.aktors.misp2.model.GroupItem;
import ee.aktors.misp2.model.PersonGroup;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgQuery;
import ee.aktors.misp2.model.Portal;

/**
 *
 */
@Transactional
public class GroupService extends BaseService {

    /**
     * Find person group by its name and org
     * @param org org of person group
     * @param name name of person group
     * @return null if no result, found result otherwise
     */
    public PersonGroup findDirectlyRelatedGroup(Org org, String name) {
        try {
            return (PersonGroup) getEntityManager()
                    .createQuery("SELECT g FROM PersonGroup g WHERE g.orgId=:org and g.name=:name")
                    .setParameter("org", org).setParameter("name", name).getSingleResult();
        } catch (NoResultException nre) {
            return null;
        }
    }

    /**
     * find groups of active org and head org
     * @param orgId org id
     * @param portalId portal id
     * @return found groups
     */
    @SuppressWarnings("unchecked")
    public List<PersonGroup> findGroups(int orgId, int portalId) {
        return getEntityManager()
                .createQuery(
                        "FROM PersonGroup g " + "WHERE (g.orgId.id = :orgId OR g.orgId.id = "
                                + "(SELECT o.supOrgId.id FROM Org o WHERE o.id = :orgId))"
                                + " and g.portal.id=:portalId ORDER BY g.name ASC")
                                .setParameter("orgId", orgId)
                .setParameter("portalId", portalId).getResultList();
    }

    /**
     * Find person group by its name and org
     * @param org org of person group
     * @return null if no result, found result otherwise
     */
    @SuppressWarnings("unchecked")
    public List<PersonGroup> findDirectlyRelatedGroups(Org org) {
        return getEntityManager().createQuery("SELECT g FROM PersonGroup g WHERE g.orgId=:org ORDER BY g.name")
                .setParameter("org", org).getResultList();
    }

    /**
     * Save person group
     * @param personGroup group to save
     * @param name name of the group
     * @param org org of the group
     * @param portal portal of the group
     */
    public void saveGroup(PersonGroup personGroup, String name, Org org, Portal portal) {
        personGroup.setName(name);
        personGroup.setOrgId(org);
        personGroup.setPortal(portal);
        save(personGroup);
    }

    /**
     * Find distinct group allowed queries
     * @param personGroup group whom quries to find
     * @return list of results
     */
    @SuppressWarnings("unchecked")
    public List<Object[]> findDistinctGroupAllowedQueries(PersonGroup personGroup) {
        return getEntityManager()
                .createQuery(
                        "SELECT DISTINCT q, gi.invisible "
                                + "FROM GroupItem gi INNER JOIN gi.orgQuery as oq INNER JOIN gi.orgQuery.queryId as q "
                                + "WHERE gi.personGroup.id = :groupId ORDER BY q.name")
                .setParameter("groupId", personGroup.getId()).getResultList();
    }

    /**
     * is group name unique amongst all groups visible to unit (unit groups and global groups)
     * (also checked when global group is being saved)
     * @param personGroup person group whom name to chec
     * @param org org
     * @return true if no match is found, false otherwise
     */
    public boolean isGroupNameUniqueInUnit(PersonGroup personGroup, Org org) {
        try {
            Query q = getEntityManager()
                    .createQuery(
                            "FROM PersonGroup g WHERE g.name = :groupName AND "
                                    + "(g.orgId.id = :orgId OR g.orgId.id = :supOrgId OR g.orgId.supOrgId.id = :orgId)"
                                    + (personGroup.getId() != null ? " AND g.id != :groupId" : ""))
                    .setParameter("groupName", personGroup.getName()).setParameter("orgId", org.getId())
                    .setParameter("supOrgId", org.getSupOrgId() != null ? org.getSupOrgId().getId() : null);
            if (personGroup.getId() != null)
                q.setParameter("groupId", personGroup.getId());
            q.getSingleResult();
        } catch (NoResultException nre) {
            return true;
        } catch (NonUniqueResultException nure) {
            return false;
        }

        return false;
    }

    /**
     * @param personGroup to whom the item refers to
     * @param orgQuery items orgQuery
     * @return null if no such item is found, result otherwise
     */
    public GroupItem findGroupItem(PersonGroup personGroup, OrgQuery orgQuery) {
        try {
            return (GroupItem) getEntityManager()
                    .createQuery("SELECT gi FROM GroupItem gi WHERE gi.personGroup=:group and gi.orgQuery=:orgQuery")
                    .setParameter("group", personGroup).setParameter("orgQuery", orgQuery).getSingleResult();
        } catch (NoResultException nre) {
            return null;
        }
    }

    /**
     * Save group item
     * @param groupItem group item to save
     * @param personGroup group items person group
     * @param orgQuery group items org query
     * @param invisible is group item invisible
     */
    public void saveGroupItem(GroupItem groupItem, PersonGroup personGroup, OrgQuery orgQuery, boolean invisible) {
        groupItem.setPersonGroup(personGroup);
        groupItem.setOrgQuery(orgQuery);
        groupItem.setInvisible(invisible);
        save(groupItem);
    }
}
