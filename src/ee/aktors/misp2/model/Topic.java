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

import java.util.List;

import javax.persistence.Basic;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "topic")
public class Topic extends GeneralBean implements Comparable<Topic> {

    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "topic_id_seq")
    @SequenceGenerator(name = "topic_id_seq", sequenceName = "topic_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @Basic(optional = false)
    @Column(name = "name", nullable = false, length = Const.LENGTH_150)
    private String name;
    @Column(name = "priority")
    private Integer priority;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "topic", fetch = FetchType.LAZY)
    private List<QueryTopic> queryTopicList;
    @JoinColumn(name = "portal_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Portal portal;

    /**
     * Empty constructor with no additional actions
     */
    public Topic() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public Topic(Integer id) {
        this.id = id;
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     * @param name the name to set
     */
    public Topic(Integer id, String name) {
        this.id = id;
        this.name = name;
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
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * @param nameNew the name to set
     */
    public void setName(String nameNew) {
        this.name = nameNew;
    }

    /**
     * @return the priority
     */
    public Integer getPriority() {
        return priority;
    }

    /**
     * @param priorityNew the priority to set
     */
    public void setPriority(Integer priorityNew) {
        this.priority = priorityNew;
    }

    /**
     * @return the queryTopicList
     */
    public List<QueryTopic> getQueryTopicList() {
        return queryTopicList;
    }

    /**
     * @param queryTopicListNew the queryTopicList to set
     */
    public void setQueryTopicList(List<QueryTopic> queryTopicListNew) {
        this.queryTopicList = queryTopicListNew;
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

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (getId() != null ? getId().hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Topic)) {
            return false;
        }
        Topic other = (Topic) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "model.Topic[id=" + getId() + "]";
    }

    /**
     * @see java.lang.Comparable#compareTo(java.lang.Object)
     * @param o object to compare this to
     * @return 0 if equal, 1 if this is larger, -1 this is smaller
     */
    public int compareTo(Topic o) {
        if (this.hashCode() == o.hashCode()) {
            return 0;
        }
        Integer thisPrior = (this.getPriority() == null ? Integer.MAX_VALUE : this.getPriority());
        Integer othrPrior = (o.getPriority() == null ? Integer.MAX_VALUE : o.getPriority());
        if (thisPrior.equals(othrPrior)) {
            String thisName = (this.getName() == null ? "" : this.getName());
            String othrName = (o.getName() == null ? "" : o.getName());
            return thisName.compareToIgnoreCase(othrName);
        }
        return thisPrior.compareTo(othrPrior);

    }

}
