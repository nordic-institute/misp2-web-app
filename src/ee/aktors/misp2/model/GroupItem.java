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

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "group_item")
@NamedQueries({
    @NamedQuery(name = "GroupItem.findAll", query = "SELECT g FROM GroupItem g")})
public class GroupItem extends GeneralBean {

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "group_item_id_seq")
    @SequenceGenerator(name = "group_item_id_seq", sequenceName = "group_item_id_seq", allocationSize = 1)
    @Column(name = "id")
    private Integer id;
    @Column(name = "invisible")
    private Boolean invisible;
    @JoinColumn(name = "org_query_id", referencedColumnName = "id", nullable = false)
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private OrgQuery orgQuery;
    @JoinColumn(name = "group_id", referencedColumnName = "id", nullable = false)
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private PersonGroup personGroup;

    /**
     * Empty constructor with no additional actions
     */
    public GroupItem() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public GroupItem(Integer id) {
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
     * @return the invisible
     */
    public Boolean getInvisible() {
        return invisible;
    }

    /**
     * @param invisibleNew the invisible to set
     */
    public void setInvisible(Boolean invisibleNew) {
        this.invisible = invisibleNew;
    }

    /**
     * @return the orgQuery
     */
    public OrgQuery getOrgQuery() {
        return orgQuery;
    }

    /**
     * @param orgQueryNew the orgQuery to set
     */
    public void setOrgQuery(OrgQuery orgQueryNew) {
        this.orgQuery = orgQueryNew;
    }


    /**
     * @return the personGroup
     */
    public PersonGroup getPersonGroup() {
        return personGroup;
    }

    /**
     * @param personGroupNew the personGroup to set
     */
    public void setPersonGroup(PersonGroup personGroupNew) {
        this.personGroup = personGroupNew;
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
        if (!(object instanceof GroupItem)) {
            return false;
        }
        GroupItem other = (GroupItem) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.GroupItem[id=" + getId() + "]";
    }

}
