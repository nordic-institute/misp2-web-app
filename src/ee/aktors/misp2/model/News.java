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

package ee.aktors.misp2.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import ee.aktors.misp2.util.Const;

/**
 * news entity
 */
@Entity
@Table(name = "news")
@NamedQueries({ @NamedQuery(name = "News.findAll", query = "SELECT x FROM News x") })
public class News extends GeneralBean {

    
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "news_id_seq")
    @SequenceGenerator(name = "news_id_seq", sequenceName = "news_id_seq", allocationSize = 1)
    @Column(name = "id")
    private Integer id;
    @Column(name = "news", length = Const.LENGTH_512)
    private String news;
    @Column(name = "lang", length = Const.LENGTH_10)
    private String lang;
    @JoinColumn(name = "portal_id", referencedColumnName = "id", nullable = false)
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Portal portal;

    /**
     * Empty constructor with no additional actions
     */
    public News() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public News(Integer id) {
        this.id = id;
    }
    
    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     * @param news the news to set
     */
    public News(Integer id, String news) {
        super();
        this.id = id;
        this.news = news;
    }


    @Override
    public int hashCode() {
        int hash = 0;
        hash += (getId() != null ? getId().hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        //Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof News)) {
            return false;
        }
        News other = (News) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.News[id=" + getId() + "]";
    }

    /**
     * @return the id
     */
    public Integer getId() {
        return id;
    }

    /**
     * @param idNew the id to set
     */
    public void setId(Integer idNew) {
        this.id = idNew;
    }

    /**
     * @return the news
     */
    public String getNews() {
        return news;
    }

    /**
     * @param newsNew the news to set
     */
    public void setNews(String newsNew) {
        this.news = newsNew;
    }

    /**
     * @return the lang
     */
    public String getLang() {
        return lang;
    }

    /**
     * @param langNew the lang to set
     */
    public void setLang(String langNew) {
        this.lang = langNew;
    }

    /**
     * @return the portal
     */
    public Portal getPortal() {
        return portal;
    }

    /**
     * @param portalNew the portal to set
     */
    public void setPortal(Portal portalNew) {
        this.portal = portalNew;
    }


}
