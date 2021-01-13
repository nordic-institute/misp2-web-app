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
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "query_topic")
public class QueryTopic extends GeneralBean {

    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "query_topic_id_seq")
    @SequenceGenerator(name = "query_topic_id_seq", sequenceName = "query_topic_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @JoinColumn(name = "topic_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Topic topic;
    @JoinColumn(name = "query_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Query query;

    /**
     * Empty constructor with no additional actions
     */
    public QueryTopic() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public QueryTopic(Integer id) {
        this.id = id;
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
     * @return the topic
     */
    public Topic getTopic() {
        return topic;
    }

    /**
     * @param topicNew the topic to set
     */
    public void setTopic(Topic topicNew) {
        this.topic = topicNew;
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
    public boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final QueryTopic other = (QueryTopic) obj;
        if (this.getTopic() != other.getTopic() && (this.getTopic() == null || !this.topic.equals(other.topic))) {
            return false;
        }
        if (this.getQuery() != other.getQuery() && (this.getQuery() == null || !this.query.equals(other.query))) {
            return false;
        }
        return true;
    }

    @Override
    public int hashCode() {
        int hash = Const.PRIME_7;
        hash = Const.PRIME_41 * hash + (this.getTopic() != null ? this.getTopic().hashCode() : 0);
        hash = Const.PRIME_41 * hash + (this.getQuery() != null ? this.getQuery().hashCode() : 0);
        return hash;
    }

    @Override
    public String toString() {
        return "model.QueryTopic[id=" + getId() + "]";
    }

}
