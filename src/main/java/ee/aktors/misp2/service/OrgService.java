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
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.persistence.NoResultException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.transaction.annotation.Transactional;

import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgName;
import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.OrgValid;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.util.Roles;

/**
 * org service
 */
@Transactional
public class OrgService extends BaseService {
    @SuppressWarnings("unused")
    private static Logger logger = LogManager.getLogger(OrgService.class);

    /**
     * @param org org to save
     * @param code orgs code
     * @param memberClass organization member class
     * @param supOrg orgs supOrg
     */
    public void saveOrg(Org org, String memberClass, String code, Org supOrg) {
        org.setCode(code);
        org.setMemberClass(memberClass);
        org.setSupOrgId(supOrg);
        save(org);
    }

    /**
     * find managers by org id
     * @param portal portal
     * @param orgId org id
     * @return list of results, empty list if none are found
     */
    public List<Person> findOrgManagers(Portal portal, Org orgId) {
        Iterator<OrgPerson> iterator = findAllOrgPersons(portal, orgId).iterator();
        ArrayList<Person> managerList = new ArrayList<Person>();

        while (iterator.hasNext()) {
            OrgPerson orgPerson = iterator.next();
            if (Roles.isSet(orgPerson.getRole().intValue(), Roles.PERMISSION_MANAGER)) {
                managerList.add(orgPerson.getPersonId());
            }
        }
        return managerList;
    }

    /**
     * @param portal portal of org person
     * @param org org of org person
     * @return null if no results, results otherwise
     */
    @SuppressWarnings("unchecked")
    public List<OrgPerson> findAllOrgPersons(Portal portal, Org org) {
        javax.persistence.Query s = getEntityManager()
                .createQuery("select op from OrgPerson op where op.orgId.id=:org and op.portal.id=:portal")
                .setParameter("org", org.getId()).setParameter("portal", portal.getId());
        try {
            return s.getResultList();
        } catch (NoResultException e) {
            return null;
        }
    }

    /**
     * @param portal org person portal
     * @param orgId org persons org id
     * @return list of results, empty list if none are found
     */
    public List<Person> findOrgPersons(Portal portal, Org orgId) {
        Iterator<OrgPerson> iterator = findAllOrgPersons(portal, orgId).iterator();
        ArrayList<Person> managerList = new ArrayList<Person>();

        if (iterator != null) {
            while (iterator.hasNext()) {
                OrgPerson orgPerson = iterator.next();
                int role = orgPerson.getRole();

                if (Roles.isSet(role, Roles.DUMBUSER)) {
                    managerList.add(orgPerson.getPersonId());
                }
            }
        }
        return managerList;
    }

    /**
     * @param org org what for the name is searched for
     * @param lang language in what the name is fetched
     * @return null if no results, result otherwise
     */
    public OrgName findOrgName(Org org, String lang) {
        try {
            javax.persistence.Query s = getEntityManager().createQuery(
                    "select orgName from OrgName orgName where orgName.orgId.id=:orgId and orgName.lang=:lang");
            return (OrgName) s.setParameter("orgId", org.getId()).setParameter("lang", lang).getSingleResult();
        } catch (NoResultException nre) {
            return null;
        }
    }

    /**
     * @param orgName org name to save
     * @param org org names org
     * @param lang org names language
     * @param description org names description
     */
    public void saveOrgName(OrgName orgName, Org org, String lang, String description) {
        orgName.setOrgId(org);
        orgName.setLang(lang);
        orgName.setDescription(description);
        save(orgName);
    }

    /**
     * @param org has to be in persistent state
     * @param validTime valid time
     * @return true if was checked in valid time, false otherwise
     */
    public boolean ifOrgCheckedInValidTime(Org org, Integer validTime) {
        try {
            if (org.getId() == null) {
                LogManager.getLogger(OrgService.class).error("Org is not persistent returning false!");
                return false;
            }
            // org has to be in persistent state already
            // org = this.reAttach(org, Org.class); // reattach org to passs the exception with hibernate session

            OrgValid oValid = org.getOrgValid();
            if (oValid != null) { // org is linked with org_valid table
                // make native query to find the difference between now and the date check service was called last time
                javax.persistence.Query s = getEntityManager()
                        .createNativeQuery(
                                "select (date_part('day', age(CURRENT_TIMESTAMP, valid_date))* 24"
                                + " + date_part('hour', age(CURRENT_TIMESTAMP, valid_date)))"
                                + " as hours_passed_since_last_query FROM misp2.org_valid WHERE org_id=:orgId");

                // gets double by some reason
                Double i =  (Double) s.setParameter("orgId", org.getId()).getSingleResult();
                // if portal check_valid_time parameter exceeds parameter from db,
                // then there is no reason to make the query again
                return validTime > i.intValue();

             // no link with org_valid table -> no query was made at all
            } else {
                return false;
            }

        } catch (Exception e) {
            LogManager.getLogger(OrgService.class).error(e.getMessage(), e);
            return false;
        }

    }

    /**
     * @param filterPartyClass filter party class
     * @param filterName filter name
     * @param filterCode filter code
     * @param supOrgId sup org id
     * @return null if exception occured, list of results otherwise
     */
    @SuppressWarnings("unchecked")
    public List<Org> findOrgs(String filterPartyClass, String filterName, String filterCode, Integer supOrgId) {
        try {
            if (filterPartyClass != null && filterPartyClass.isEmpty())
                filterPartyClass = null;
            javax.persistence.Query s = getEntityManager()
                    .createQuery(
                            "select o from Org o where "
                                    + (filterPartyClass != null ? "o.memberClass = :filterPartyClass and " : "")
                                    + "lower(o.code) like :filterCode "
                                    + "and o.supOrgId.id=:supOrgId"
                                    + " and o.id in (SELECT orgn.orgId.id FROM OrgName orgn WHERE"
                                    + " lower(orgn.description) LIKE :filterName)"
                                    + " order by o.code ASC");
            Map<String, Object> parameters = new HashMap<String, Object>();
            if (filterPartyClass != null) {
                parameters.put("filterPartyClass", filterPartyClass);
            }
            parameters.put("filterCode", "%" + filterCode == null ? "" : filterCode.toLowerCase() + "%");
            parameters.put("filterName", "%" + filterName == null ? "" : filterName.toLowerCase() + "%");
            parameters.put("supOrgId", supOrgId);
            for (String param : parameters.keySet()) {
                s.setParameter(param, parameters.get(param));
            }
            return s.getResultList();
        } catch (Exception e) {
            LogManager.getLogger(OrgService.class).warn(e.getMessage());
            return null;
        }
    }

    /**
     * Find suborg by code (without member class parameter), assumes code is unique
     * @param supOrg sup org of org
     * @param code code of org
     * @return null if no result, result otherwise
     */
    public Org findSubOrg(Org supOrg, String code) {
        try {
            return (Org) getEntityManager().createQuery("SELECT o FROM Org o WHERE o.supOrgId=:supOrg AND code=:code")
                    .setParameter("supOrg", supOrg).setParameter("code", code).getSingleResult();
        } catch (NoResultException nre) {
            return null;
        }
    }


    /**
     * @param supOrg sup org of org
     * @param memberClass member class of org
     * @param code code of org
     * @return null if no result, result otherwise
     */
    public Org findSubOrg(Org supOrg, String memberClass, String code) {
        if (memberClass == null) return findSubOrg(supOrg, code);
        else {
            try {
                return (Org) getEntityManager().createQuery("SELECT o FROM Org o WHERE "
                        + "o.supOrgId=:supOrg AND code=:code AND memberClass=:memberClass")
                        .setParameter("supOrg", supOrg)
                        .setParameter("code", code)
                        .setParameter("memberClass", memberClass)
                        .getSingleResult();
            } catch (NoResultException nre) {
                return null;
            }
        }
    }

    /**
     * @param supOrg supOrgs to find
     * @return null if exception, results otherwise
     */
    @SuppressWarnings("unchecked")
    public List<Org> findSubOrgs(Org supOrg) {
        try {
            return getEntityManager().createQuery("select o from Org o where o.supOrgId=:supOrg")
                    .setParameter("supOrg", supOrg).getResultList();
        } catch (Exception e) {
            LogManager.getLogger(OrgService.class).warn(e.getMessage());
            return null;
        }
    }

    /**
     * @param queryId queryId to delete
     */
    public void deleteOrgQueries(int queryId) {
        javax.persistence.Query s = getEntityManager().createQuery("DELETE FROM OrgQuery WHERE queryId.id = :query_id");
        s.setParameter("query_id", queryId);
        s.executeUpdate();
    }
}
