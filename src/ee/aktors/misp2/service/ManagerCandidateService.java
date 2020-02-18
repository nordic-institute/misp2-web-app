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
import javax.persistence.Query;
import ee.aktors.misp2.model.ManagerCandidate;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import javax.persistence.NoResultException;

/**
 *
 * @author arnis.rips
 */
public class ManagerCandidateService extends BaseService {

    /**
     * Finds manager candidates
     * @param portal candidates portal
     * @param org candidates org
     * @return sorted list of candidates
     */
    @SuppressWarnings("unchecked")
    public List<ManagerCandidate> findOrgSortedMgrCandidates(Portal portal, Org org) {

        Query q = getEntityManager().createQuery(
            "select mg from ManagerCandidate mg where mg.orgId.id=:org and mg.portal.id=:portal order by mg.managerId").
                setParameter("org", org.getId()).
                setParameter("portal", portal.getId());

        return q.getResultList();
    }

    /**
     * @param portal candidates portal
     * @param org candidates org
     * @param candidate candidates id
     * @param authSSN candidates ssn
     * @return null if there was no results or more than one, result otherwise
     */
    public ManagerCandidate findManagerCandidate(Portal portal, Org org, Person candidate, String authSSN) {
        Query q = getEntityManager().
                createQuery("select mg from ManagerCandidate mg "
                + "where mg.orgId.id=:org and mg.portal.id=:portal "
                + "and mg.managerId.id=:candidate and mg.authSsn=:ssn").
                setParameter("org", org.getId()).
                setParameter("portal", portal.getId()).
                setParameter("candidate", candidate.getId()).
                setParameter("ssn", authSSN);

        ManagerCandidate mc = null;
        try {
            mc = (ManagerCandidate) q.getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
        return mc;
    }

    /**
     * Remove manager candidate that matches given attributes
     * @param portal candidates portal
     * @param org candidates org
     * @param userId person
     * @param authSSN candidates ssn
     */
    public void removeManagerCandidate(Portal portal, Org org, Integer userId, String authSSN) {
        getEntityManager().createQuery(
                "delete ManagerCandidate mg "
                + "where mg.orgId.id=:org and mg.portal.id=:portal and mg.authSsn=:ssn and mg.managerId.id=:person").
                setParameter("org", org.getId()).
                setParameter("portal", portal.getId()).
                setParameter("ssn", authSSN).
                setParameter("person", userId).
                executeUpdate();
    }

}
