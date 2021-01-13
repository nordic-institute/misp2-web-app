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

import ee.aktors.misp2.model.Admin;
import ee.aktors.misp2.model.GroupPerson;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.PersonGroup;
import ee.aktors.misp2.model.PersonMailOrg;
import ee.aktors.misp2.model.Portal;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import javax.persistence.NoResultException;
import javax.persistence.Query;
import org.apache.logging.log4j.LogManager;
import org.springframework.transaction.annotation.Transactional;

/**
 * user service
 */
@Transactional
public class UserService extends BaseService {

    /**
     * @param loginUsername {@link Admin#loginUsername} of admin to find
     * @return result if exactly one result, null otherwise
     */
    public Admin findAdminByLoginUsername(String loginUsername) {
        try {
            return (Admin) getEntityManager()
                    .createQuery("SELECT a FROM Admin a WHERE a.loginUsername = :loginUsername")
                    .setParameter("loginUsername", loginUsername).getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }

    /**
     * @param ssn {@link Person#ssn} of person to find
     * @return result if exactly one result, null otherwise
     */
    public Person findPersonBySSN(String ssn) {
        try {
            String sql = "select p from Person p where p.ssn like :ssn";
            Query s = getEntityManager().createQuery(sql);
            s.setParameter("ssn", ssn);
            return (Person) s.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } catch (Exception e) {
            LogManager.getLogger(UserService.class).error(e.getMessage(), e);
            return null;
        }
    }

    /**
     * @param cert base64encoded string
     * @return result if exactly one result, null otherwise
     */
    public Person findPersonByB64encCert(String cert) {
        LogManager.getLogger(UserService.class).debug("Searching user for cert = " + cert);
        try {
            Query s = getEntityManager().createQuery("select p from Person p where p.certificate=:cert");
            s.setParameter("cert", cert);
            return (Person) s.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } catch (Exception e) {
            LogManager.getLogger(UserService.class).error(e.getMessage(), e);
            return null;
        }
    }

    /**
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Person> findAllUsers() {
        Query s = getEntityManager().createQuery("select p from Person p order by p.surname");
        return s.getResultList();
    }

    /**
     * @param person {@link Person#person} of person to save
     * @param ssn {@link Person#ssn} of person to save
     * @param givenname {@link Person#givenname} of person to save
     * @param surname {@link Person#surname} of person to save
     */
    public void savePerson(Person person, String ssn, String givenname, String surname) {
        person.setSsn(ssn);
        person.setGivenname(givenname);
        person.setSurname(surname);
        save(person);
    }

    /**
     * @param portal {@link OrgPerson#portal} of org person to find
     * @param person {@link OrgPerson#personId} of org person to find
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<OrgPerson> findPortalOrgPersons(Portal portal, Person person) {
        String hql = "select op from OrgPerson op where op.portal.id=:portal and op.personId.id=:person";
        Query s = getEntityManager().createQuery(hql).setParameter("portal", portal.getId())
                .setParameter("person", person.getId());

        return s.getResultList();

    }

    /**
     * @param portal orgPerson portal
     * @return set of results, empty set if no results, null if exception occurs
     */
    @SuppressWarnings("unchecked")
    public Set<Person> findAllPortalUsers(Portal portal) {
        try {
            Query s = getEntityManager().createQuery(
                    "select op.personId from OrgPerson op where op.portal.id=:pId order by op.personId.givenname asc");
            s.setParameter("pId", portal.getId());
            return new LinkedHashSet<Person>(s.getResultList());
        } catch (NoResultException nre) {
            return null;
        } catch (Exception e) {
            LogManager.getLogger(UserService.class).error(e.getMessage(), e);
            return null;
        }
    }

    /**
     * @param activeOrg for orgId {@link OrgPerson#orgId}
     * @param portal for portal {@link OrgPerson#portal}
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Person> findAllOrgUsers(Org activeOrg, Portal portal) {
        try {
            Query s = getEntityManager()
                    .createQuery("select op.personId from OrgPerson op where op.orgId.id=:oId "
                            + "and op.portal.id=:pId order by op.personId.surname");
            s.setParameter("oId", activeOrg.getId());
            s.setParameter("pId", portal.getId());
            return s.getResultList();
        } catch (NoResultException nre) {
            return null;
        } catch (Exception e) {
            LogManager.getLogger(UserService.class).error(e.getMessage(), e);
            return null;
        }
    }

    /**
     * @param groupId {@link GroupPerson#personGroup} of GroupPerson to find
     * @param personId {@link GroupPerson#person} of GroupPerson to find
     * @param orgId {@link GroupPerson#org} of GroupPerson to find
     * @return result if exactly one is found, null otherwise
     */
    public GroupPerson findGroupPerson(Integer groupId, Integer personId, Integer orgId) {
        if (groupId != null && personId != null && orgId != null) {
            Query s = getEntityManager().createQuery(
                    "select gp FROM GroupPerson gp where "
                            + " gp.personGroup.id=:groupId and gp.person.id=:personId and gp.org.id=:orgId");
            s.setParameter("groupId", groupId);
            s.setParameter("personId", personId);
            s.setParameter("orgId", orgId);
            try {
                return (GroupPerson) s.getSingleResult();
            } catch (NoResultException e) {
                return null;
            }
        }
        return null;
    }

    /**
     * @param groupPerson {@link GroupPerson} to save
     * @param group {@link GroupPerson#personGroup} of GroupPerson to save
     * @param person {@link GroupPerson#person} of GroupPerson to save
     * @param org {@link GroupPerson#org} of GroupPerson to save
     * @param validuntil {@link GroupPerson#validuntil} of GroupPerson to save
     */
    public void saveGroupPerson(GroupPerson groupPerson, PersonGroup group, Person person, Org org, Date validuntil) {
        groupPerson.setPersonGroup(group);
        groupPerson.setPerson(person);
        groupPerson.setOrg(org);
        groupPerson.setValiduntil(validuntil);
        save(groupPerson);
    }

    /**
     * @param personId of person of orgPeson
     * @param orgId of org of orgPeson
     * @param portalId of portal oforgPeson
     * @return result if exactly one is found, null otherwise
     */
    public OrgPerson findOrgPerson(Integer personId, Integer orgId, Integer portalId) {
        if (personId != null && orgId != null && portalId != null) {
            Query s = getEntityManager().createQuery(
                    "select op FROM OrgPerson op where "
                            + " op.personId.id=:pId and op.orgId.id=:oId and op.portal.id=:portalId");
            s.setParameter("pId", personId);
            s.setParameter("oId", orgId);
            s.setParameter("portalId", portalId);
            try {
                return (OrgPerson) s.getSingleResult();
            } catch (NoResultException nre) {
                return null;
            }
        }
        return null;
    }

    /**
     * @param orgPerson orgPerson to save
     * @param org org of orgPerson
     * @param person person of orgPerson
     * @param portal portal of orgPerson
     * @param role role of orgPerson
     * @param profession proffesion of orgPerson
     */
    public void saveOrgPerson(OrgPerson orgPerson, Org org, Person person, Portal portal, int role, String profession) {
        orgPerson.setOrgId(org);
        orgPerson.setPersonId(person);
        orgPerson.setPortal(portal);
        orgPerson.setRole(role);
        orgPerson.setProfession(profession);
        save(orgPerson);
    }

    /**
     * @param personId of person of groupPerson
     * @param orgId of org of groupPerson
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<GroupPerson> findGroupPersons(Integer personId, Integer orgId) {
        if (personId != null && orgId != null) {
            Query s = getEntityManager().createQuery(
                    "select gp FROM GroupPerson gp where gp.person.id=:personId and gp.org.id=:orgId");
            s.setParameter("personId", personId);
            s.setParameter("orgId", orgId);
            try {
                return s.getResultList();
            } catch (NoResultException nre) {
                return null;
            }
        }
        return null;
    }

    /**
     * @param gName given name of person
     * @param sName surname of person
     * @param ssn ssn of person
     * @param pageNr page number
     * @param pageSize results per page
     * @return list of results, empty list if no results
     */
    @Transactional(readOnly = true)
    public List<Person> findUsers(String gName, String sName, String ssn, int pageNr, int pageSize) {
        return findOrgUsers(gName, sName, ssn, null, pageNr, pageSize);
    }

    /**
     * @param gName given name of user
     * @param sName surname of user
     * @param ssn ssn of user
     * @return number of users that match criteria
     */
    @Transactional(readOnly = true)
    public long countUsers(String gName, String sName, String ssn) {
        return countOrgUsers(gName, sName, ssn, null);
    }

    /**
     * @param gName given name of user
     * @param sName surename of user
     * @param ssn ssn of user
     * @param org org of user
     * @param pageNr page number
     * @param pageSize number of results per page
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    @Transactional(readOnly = true)
    public List<Person> findOrgUsers(String gName, String sName, String ssn, Org org, int pageNr,
            int pageSize) {
        Query q = getOrgUsersQuery(gName, sName, ssn, org, true);
        if (pageSize > 0) {
            q.setMaxResults(pageSize);
            if (pageNr >= 0) {
                q.setFirstResult(pageSize * pageNr);
            }
        }
        return q.getResultList();
    }

    /**
     * @param gName given name of user
     * @param sName surename of user
     * @param ssn ssn of user
     * @param org org of user
     * @return number of org users
     */
    @Transactional(readOnly = true)
    public int countOrgUsers(String gName, String sName, String ssn, Org org) {
        Query q = getOrgUsersQuery(gName, sName, ssn, org, false);
        return ((Long) q.getSingleResult()).intValue();
    }
    
    private Query getOrgUsersQuery(String gName, String sName, String ssn, Org org, boolean isSelectQuery) {
        // start HQL query statement
        StringWriter swHql = new StringWriter();
        if (isSelectQuery) { // if query type is 'select'
            swHql.append("select p FROM Person p ");
        } else { // if query type is 'count'
            swHql.append("select count(*) FROM Person p ");
        }
        
        // add filters and filter params
        LinkedHashMap<String, Object> params = new LinkedHashMap<String, Object>();
        
        List<String> hqlFilters = new ArrayList<String>();
        if (gName != null && !gName.trim().isEmpty()) {
            hqlFilters.add("lower(p.givenname) like :givenName");
            params.put("givenName", gName.trim().replace("*", "%").toLowerCase() + "%");
        }
        if (sName != null && !sName.trim().isEmpty()) {
            hqlFilters.add("lower(p.surname) like :surname");
            params.put("surname", sName.trim().replace("*", "%").toLowerCase() + "%");
        }
        if (ssn != null && !ssn.trim().isEmpty()) {
            hqlFilters.add("p.ssn like :ssn");
            params.put("ssn", ssn.replace("*", "%").trim() + "%");
        }
        if (org != null && org.getId() != null) {
            hqlFilters.add("p.id in (select op.personId from OrgPerson op where op.orgId = :inputorg)");
            params.put("inputorg", org);
        }
        
        // add HQL filters concatenated with AND
        if (hqlFilters.size() > 0) {
            swHql.append(" where " + String.join(" and ", hqlFilters));
        }
        // add order-by clause in case of select
        if (isSelectQuery) {
            swHql.append(" order by p.givenname");
        }

        // create query
        Query q = getEntityManager().createQuery(swHql.toString());
        // add params to query
        for (String param : params.keySet()) {
            q.setParameter(param, params.get(param));
        }
        
        return q;
    }

    /**
     * @param pId {@link PersonMailOrg#personId}
     * @param oId {@link PersonMailOrg#orgId}
     * @return result if exactly one is found, null otherwise
     */
    public PersonMailOrg findPersonMailOrg(Integer pId, Integer oId) {
        if (pId != null && oId != null) {
            Query s = getEntityManager().createQuery(
                    "select pmo FROM PersonMailOrg pmo where pmo.personId.id=:pId and pmo.orgId.id=:oId");
            s.setParameter("pId", pId);
            s.setParameter("oId", oId);
            try {
                return (PersonMailOrg) s.getSingleResult();
            } catch (NoResultException nre) {
                return null;
            } catch (Exception e) {
                LogManager.getLogger(UserService.class).error(e.getMessage(), e);
                return null;
            }
        }
        return null;
    }

    /**
     * @param personMailOrg personMailOrg to save
     * @param person {@link PersonMailOrg#person} of personMailOrg to save
     * @param org {@link PersonMailOrg#org} of personMailOrg to save
     * @param mail {@link PersonMailOrg#mail} of personMailOrg to save
     * @param notifyChanges {@link PersonMailOrg#notifyChanges} of personMailOrg to save
     */
    public void savePersonMailOrg(PersonMailOrg personMailOrg, Person person, Org org, String mail,
            boolean notifyChanges) {
        personMailOrg.setPersonId(person);
        personMailOrg.setOrgId(org);
        personMailOrg.setMail(mail);
        personMailOrg.setNotifyChanges(notifyChanges);
        save(personMailOrg);
    }

    /**
     * @return concatenation of two random longs in hex
     */
    public String generateOvertakeCode() {
        String overtakeCode = Long.toHexString(Double.doubleToLongBits(Math.random()))
                      .concat(Long.toHexString(Double.doubleToLongBits(Math.random())));
        return overtakeCode;
    }

}
