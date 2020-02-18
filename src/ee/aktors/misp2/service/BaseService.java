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

import java.util.Map;

import javax.persistence.Query;

import org.apache.logging.log4j.LogManager;
import org.springframework.transaction.annotation.Transactional;

import ee.aktors.misp2.model.BeanInterface;

/**
 * Represents CRUD actions for beans.
 * 
 * @author arnis.rips
 */
@Transactional
public class BaseService extends AbstractService {

    /**
     * If object is already persistent - merge object, otherwise make object persistent
     * @param ob object to save
     * @param <T> type of object to save
     * @return saved object
     */
    public <T extends BeanInterface> T save(T ob) {
        if (ob == null) {
            throw new IllegalArgumentException("Object you are trying to save is not set.");
        }
        if (ob.getId() == null) {
            getEntityManager().persist(ob);
            LogManager.getLogger(BaseService.class).debug("Added new: " + ob);
        } else {
            getEntityManager().merge(ob);
            LogManager.getLogger(BaseService.class).debug("Updated : " + ob);
        }
        return ob;

    }

    /**
     * Removes the object
     * @param ob object to remove
     * @param <T> type of object to remove
     */
    public <T extends BeanInterface> void remove(T ob) {
        LogManager.getLogger(getClass()).debug("Deleting object: " + ob);
        if (ob != null && ob.getId() != null) {
            T attached = getEntityManager().merge(ob);
            getEntityManager().remove(attached);
        } else {
            throw new IllegalArgumentException("Required parameter or its id is null");
        }
    }

    /**
     * Gets persistent object from entity manager if single result exists
     * @param ob object to re attach
     * @param clazz class of object
     * @param <T> type of object to re attach
     * @return persistent object
     * @throws Exception if object or object id is null
     */
    @SuppressWarnings("unchecked")
    public <T extends BeanInterface> T reAttach(T ob, Class<T> clazz) throws Exception {
        if (ob != null && ob.getId() != null) {

            Query q = getEntityManager().createQuery(
                    "select o from " + clazz.getSimpleName() + " o where id=" + ob.getId());
            return (T) q.getSingleResult();

        } else {
            throw new IllegalArgumentException("Required parameter or its id is null");
        }
    }

    /**
     * Find object by its id/primary key
     * @param clazz class of the object
     * @param identificator id/primary key of the object
     * @param <T> type of object to find
     * @return the found entity instance or null if the entity does not exist
     */
    public <T extends BeanInterface> T findObject(Class<T> clazz, Number identificator) {
        return getEntityManager().find(clazz, identificator);
    }
    
    /**
     * Detach object from session so it will not be persisted automatically on change
     * @param ob JPA entity
     */
    public <T extends BeanInterface> void detach(T ob) {
        if (ob.getId() != null) {
            System.out.println("Detaching " + ob);
            getEntityManager().detach(ob);
        }
    }


    /**
     * Create persistence query with HQL and query parameters.
     * @param hql HQL query string
     * @param hql query named parameters map
     * @return query object
     */
    protected Query createQuery(String hql, Map<String, Object> params) {
        Query q = getEntityManager().createQuery(hql);
        addParams(q, params);
        return q;
    }

    /**
     * Add multiple parameters from map to persistence query.
     * @param q persistence query object
     * @param params parameter map name->value
     */
    protected void addParams(Query q, Map<String, Object> params) {
        for (String paramName : params.keySet()) {
            Object paramValue = params.get(paramName);
            q.setParameter(paramName, paramValue);
        }
    }
}
