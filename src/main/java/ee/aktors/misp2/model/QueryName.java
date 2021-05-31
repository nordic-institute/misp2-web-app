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

import java.util.Comparator;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import ee.aktors.misp2.util.Const;

/**
 * query_name entity
 */
@Entity
@Table(name = "query_name")
public class QueryName extends GeneralBeanName {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "query_name_id_seq")
    @SequenceGenerator(name = "query_name_id_seq", sequenceName = "query_name_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @Column(name = "query_note", length = Const.LENGTH_256)
    private String queryNote;
    @JoinColumn(name = "query_id", referencedColumnName = "id")
    @ManyToOne(fetch = FetchType.LAZY)
    private Query query;


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
     * @return the queryNote
     */
    public String getQueryNote() {
        return queryNote;
    }

    /**
     * @param queryNoteNew the queryNote to set
     */
    public void setQueryNote(String queryNoteNew) {
        this.queryNote = queryNoteNew;
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

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (getId() != null ? getId().hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof QueryName)) {
            return false;
        }
        QueryName other = (QueryName) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.QueryName[id=" + getId() + "]";
    }

    public static final Comparator<QueryName> COMPARE_BY_QUERY_DESCRIPTION = new Comparator<QueryName>() {
        public int compare(QueryName one, QueryName other) {
            String oneDescription = one.getDescription() != null ? one.getDescription() : "";

            String otherDescription = other.getDescription() != null ? other.getDescription() : "";
            if (oneDescription != null && otherDescription != null) {
                return oneDescription.toUpperCase().compareTo(otherDescription.toUpperCase());
            }
            return 0;
        }
    };

    public static final Comparator<QueryName> COMPARE_BY_PRODUCER_SHORT_NAME = new Comparator<QueryName>() {
        public int compare(QueryName one, QueryName other) {
            String oneShortName = one.getQuery().getProducer() != null
                    ? one.getQuery().getProducer().getShortName() : "";

            String otherShortName = other.getQuery().getProducer() != null ? other.getQuery().getProducer()
                    .getShortName() : "";
            if (oneShortName != null && otherShortName != null) {
                return oneShortName.toUpperCase().compareTo(otherShortName.toUpperCase());
            }
            return 0;
        }
    };

}
