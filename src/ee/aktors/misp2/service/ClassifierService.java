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
import javax.persistence.Query;

import org.apache.logging.log4j.LogManager;
import org.springframework.transaction.annotation.Transactional;

import ee.aktors.misp2.model.Classifier;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.service.exception.DatabaseException;

/**
 *
 */
@Transactional
public class ClassifierService extends BaseService {

    /**
     * Find all {@link Classifier}s whom {@code xroadQueryXroadProtocolVer} isn't null
     * @return found classifiers
     */
    @SuppressWarnings({ "unchecked" })
    public List<Classifier> findAll() {
        Query q = getEntityManager().createQuery(
                "select x from Classifier x where x.xroadQueryXroadProtocolVer is not null");
        return q.getResultList();
    }

    /**
     * Fill find {@link Classifier} whom {@code name} equals input name and {@code xroadQueryXroadProtocolVer} is null
     * @param name name of the classifier
     * @return found classifier
     * @throws DatabaseException if no result is found or other exception occurs
     */
    public Classifier findSystemClassifierByName(String name) throws DatabaseException {
        try {
            Query s = getEntityManager().createQuery(
                    "select x from Classifier x where x.name=:name and x.xroadQueryXroadProtocolVer is null");
            return (Classifier) s.setParameter("name", name).getSingleResult();
        } catch (NoResultException nre) {
            throw new DatabaseException("System classifier \"" + name
                    + "\" not found. Please notify your administrator about this.");
        } catch (Exception e) {
            LogManager.getLogger(ClassifierService.class).error(e.getMessage(), e);
            throw new DatabaseException(e.getMessage());
        }
    }

    /**
     * Fill find {@link Classifier} whom {@code name} equals input name
     * and {@code xroadQueryXroadProtocolVer} is not null
     * @param name name of the classifier
     * @return found classifier, null if none was found
     */
    public Classifier findClassifierByName(String name) {
        try {
            Query s = getEntityManager().createQuery(
                    "select x from Classifier x where x.name=:name and x.xroadQueryXroadProtocolVer is not null");
            return (Classifier) s.setParameter("name", name).getSingleResult();
        } catch (NoResultException nre) {
            LogManager.getLogger(ClassifierService.class).warn(nre.getMessage());
            return null;
        } catch (Exception e) {
            LogManager.getLogger(ClassifierService.class).error(e.getMessage(), e);
            return null;
        }
    }

    /**
     * Find all {@link Classifier}s whom {@code xroadQueryXroadProtocolVer} is null
     * @return found classifiers
     */
    @SuppressWarnings("unchecked")
    public List<Classifier> findAllSystem() {
        Query q = getEntityManager().createQuery(
                "select x from Classifier x where x.xroadQueryXroadProtocolVer is null");
        return q.getResultList();
    }

    /**
     * Fill find {@link Classifier} whom {@code name} equals input name
     * and {@code xroadQueryXroadProtocolVer} is not null. If many classifiers exist,
     * one for newest {@code xroadQueryXroadProtocolVer} is taken.
     * @param name name of the classifier
     * @return found classifier
     */
    public Classifier findAnyClassifierByName(String name) {
        try {
            Query s = getEntityManager().createQuery(
                    "select x from Classifier x where x.name=:name"
                    + " order by x.xroadQueryXroadProtocolVer desc nulls last  ");
            s.setMaxResults(1);
            return (Classifier) s.setParameter("name", name).getSingleResult();
        } catch (NoResultException nre) {
            LogManager.getLogger(ClassifierService.class).warn(nre.getMessage());
            return null;
        } catch (Exception e) {
            LogManager.getLogger(ClassifierService.class).error(e.getMessage(), e);
            return null;
        }
    }

    /**
     * Makes new classifier with given data
     * @param query query object for producer, service code and service version
     * @param classifierName classifierName
     * @return classifier
     */
    public Classifier createNewClassifer(ee.aktors.misp2.model.Query query, String classifierName) {
        Classifier classifier = new Classifier();
        Producer producer = query.getProducer();
        Portal portal = producer.getPortal();
        classifier.setName(classifierName);

        classifier.setXroadQueryXroadProtocolVer(portal.getXroadProtocolVer());
        classifier.setXroadQueryXroadInstance(producer.getXroadInstance());
        classifier.setXroadQueryMemberClass(producer.getMemberClass());
        classifier.setXroadQueryMemberCode(producer.getShortName());
        classifier.setXroadQuerySubsystemCode(producer.getSubsystemCode());
        classifier.setXroadQueryServiceCode(query.getServiceCode());
        classifier.setXroadQueryServiceVersion(query.getServiceVersion());
        return classifier;
    }

}
