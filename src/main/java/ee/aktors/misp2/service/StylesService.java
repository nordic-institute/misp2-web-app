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

import ee.aktors.misp2.model.Portal;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.transaction.annotation.Transactional;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.model.Xslt;

/**
 *
 * @author arnis.rips
 */
@Transactional
public class StylesService extends BaseService {

    /**
     * @param portal {@link Producer#portal} of producers to find
     * @return list of result or empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Producer> findAllProducers(Portal portal) {
        javax.persistence.Query s = getEntityManager().createQuery(
                "select p FROM Producer p where p.portal=:portal order by inUse desc, shortName").
                setParameter("portal", portal);
        return s.getResultList();
    }

    /**
     * @param portal {@link Xslt#portal} of xslt to count
     * @param xName {@link Xslt#name} of xslt to count
     * @param pName {@link Producer#shortName} of producer
     * @param qName {@link Query#name} of query
     * @return number of results
     */
    public long countXslts(Portal portal, String xName, String pName, String qName) {

        String sql = "select count(*) FROM Xslt x ";
        String join = "";
        String where = " where 1=1 and (x.portal=:portal or x.portal=null) ";
        Map<String, Object> parameters = new HashMap<String, Object>();
        boolean bx = xName != null && !xName.isEmpty();
        boolean bp = pName != null && !pName.isEmpty();
        boolean bq = qName != null && !qName.isEmpty();

        join += (bp ? ",Producer p " : "");
        join += (bq ? ",Query q " : "");

        where += (bx ? " and lower(x.name) like :xname  " : "");
        where += (bp ? " and lower(p.shortName) like :pname and x.producerId=p.id " : "");
        where += (bq ? " and lower(q.name) like :qname and x.queryId=q.id " : "");
        where += (bq && bp ? " and q.producer.id=p.id " : "");
        sql += join;
        sql += where;
        if (bx) parameters.put("xname", "%" + xName.toLowerCase() + "%");
        if (bp) parameters.put("pname", "%" + pName.toLowerCase() + "%");
        if (bq) parameters.put("qname", "%" + qName.toLowerCase() + "%");
        parameters.put("portal", portal);
        javax.persistence.Query s = getEntityManager().createQuery(sql);
        for (String param : parameters.keySet()) {
            s.setParameter(param, parameters.get(param));
        }
        return ((Long) s.getSingleResult()).longValue();
    }

    /**
     * @param portal {@link Xslt#portal} of xslt to count
     * @param xName {@link Xslt#name} of xslt to count
     * @param pName {@link Producer#shortName} of producer
     * @param qName {@link Query#name} of query
     * @param pageNr number of page
     * @param pageSize results per page
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Xslt> findXslts(Portal portal, String xName, String pName, String qName, int pageNr, int pageSize) {

        String sql = "select x FROM Xslt x ";
        String join = "";
        String where = " where 1=1 and (x.portal=:portal or x.portal=null) ";
        Map<String, Object> parameters = new HashMap<String, Object>();
        boolean bx = xName != null && !xName.isEmpty();
        boolean bp = pName != null && !pName.isEmpty();
        boolean bq = qName != null && !qName.isEmpty();

        join += (bp ? ",Producer p " : "");
        join += (bq ? ",Query q " : "");

        where += (bx ? " and lower(x.name) like :xname " : "");
        where += (bp ? " and lower(p.shortName) like :pname and x.producerId=p.id " : "");
        where += (bq ? " and lower(q.name) like :qname and x.queryId=q.id " : "");
        where += (bq && bp ? " and q.producer.id=p.id " : "");
        sql += join;
        sql += where;
        sql += " order by x.name";
        if (bx) parameters.put("xname", "%" + xName.toLowerCase() + "%");
        if (bp) parameters.put("pname", "%" + pName.toLowerCase() + "%");
        if (bq) parameters.put("qname", "%" + qName.toLowerCase() + "%");
        parameters.put("portal", portal);
        javax.persistence.Query s = getEntityManager().createQuery(sql);
        for (String param : parameters.keySet()) {
            s.setParameter(param, parameters.get(param));
        }
        if (pageSize > -1) {
            s.setMaxResults(pageSize);
            if (pageNr > -1) {
                s.setFirstResult(pageNr * (pageSize));
            }
        }
        return s.getResultList();
    }

    /**
     * @param procuderId {@link Query#producer} for queries to find
     * @param start {@link Query#name} for queries to find
     * @return list of results, empty list if no results
     */
    @SuppressWarnings("unchecked")
    public List<Query> findQueries(Integer procuderId, String start) {
        String s = (start == null) ? "" : start;
        javax.persistence.Query q = getEntityManager()
                .createQuery("select q FROM Query q where q.producer.id=:p_id and q.name like :qname");
        q.setParameter("p_id", procuderId).setParameter("qname", s + "%");
        return q.getResultList();
    }

}
