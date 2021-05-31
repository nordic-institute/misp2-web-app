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

package ee.aktors.misp2.model;

import javax.persistence.Basic;
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
 * xforms entity
 */
@Entity
@Table(name = "xforms")
@NamedQueries({ @NamedQuery(name = "Xforms.findAll", query = "SELECT x FROM Xforms x") })
public class Xforms extends GeneralBean {

    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "xforms_id_seq")
    @SequenceGenerator(name = "xforms_id_seq", sequenceName = "xforms_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @Column(name = "form", length = Const.LENGTH_2147483647)
    private String form;
    @JoinColumn(name = "query_id", referencedColumnName = "id")
    @ManyToOne(fetch = FetchType.LAZY)
    private Query query;
    @Column(name = "url", length = Const.LENGTH_256)
    private String url;

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
     * @return the form
     */
    public String getForm() {
        return form;
    }

    /**
     * @param formNew the form to set
     */
    public void setForm(String formNew) {
        this.form = formNew;
    }

    /**
     * @return the query
     */
    public Query getQuery() {
        return query;
    }

    /**
     * @param queryNew the query to set
     */
    public void setQuery(Query queryNew) {
        this.query = queryNew;
    }

    /**
     * @return the url
     */
    public String getUrl() {
        return url;
    }

    /**
     * @param urlNew the url to set
     */
    public void setUrl(String urlNew) {
        this.url = urlNew;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (getId() != null ? getId().hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Xforms)) {
            return false;
        }
        Xforms other = (Xforms) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.Xforms[id=" + getId() + "]";
    }

}
