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

package ee.aktors.misp2.service;

import java.util.List;

import javax.persistence.NoResultException;
import javax.persistence.Query;

import org.springframework.transaction.annotation.Transactional;

import ee.aktors.misp2.model.News;
import ee.aktors.misp2.model.Portal;

/**
 * News service
 */
@Transactional
public class NewsService extends BaseService {

    /**
     * Find all news of the language
     * @param lang language of the news
     * @param portal portal
     * @return null if no news are found, list of news otherwise
     */
    @SuppressWarnings("unchecked")
    public List<News> findAllNews(String lang, Portal portal) {
        Query s = getEntityManager().createQuery(
                "select n from News n where lang=:lang and portal_id=:portal order by n.lastModified");
        s.setParameter("lang", lang).setParameter("portal", portal.getId());
        try {
            return (List<News>) s.getResultList();
        } catch (NoResultException e) {
            return null;
        }
    }

}
