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
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "group_")
@NamedQueries({ @NamedQuery(name = "PersonGroup.findAll", query = "SELECT g FROM PersonGroup g") })
public class PersonGroup extends GeneralBean {

    
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "group__id_seq")
    @SequenceGenerator(name = "group__id_seq", sequenceName = "group__id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @Basic(optional = false)
    @Column(name = "name", nullable = false, length = Const.LENGTH_150)
    private String name;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "personGroup", fetch = FetchType.LAZY)
    private List<GroupPerson> groupPersonList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "personGroup", fetch = FetchType.LAZY)
    private List<GroupItem> groupItemList;
    @JoinColumn(name = "org_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Org orgId;
    @JoinColumn(name = "portal_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Portal portal;

    /**
     * Empty constructor with no additional actions
     */
    public PersonGroup() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public PersonGroup(Integer id) {
        this.id = id;
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     * @param name the name to set
     */
    public PersonGroup(Integer id, String name) {
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
     * @return the groupPersonList
     */
    public List<GroupPerson> getGroupPersonList() {
        return groupPersonList;
    }

    /**
     * @param groupPersonListNew the groupPersonList to set
     */
    public void setGroupPersonList(List<GroupPerson> groupPersonListNew) {
        this.groupPersonList = groupPersonListNew;
    }

    /**
     * @return the groupItemList
     */
    public List<GroupItem> getGroupItemList() {
        return groupItemList;
    }

    /**
     * @param groupItemListNew the groupItemList to set
     */
    public void setGroupItemList(List<GroupItem> groupItemListNew) {
        this.groupItemList = groupItemListNew;
    }

    /**
     * @return the orgId
     */
    public Org getOrgId() {
        return orgId;
    }

    /**
     * @param orgIdNew the orgId to set
     */
    public void setOrgId(Org orgIdNew) {
        this.orgId = orgIdNew;
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
        if (!(object instanceof PersonGroup)) {
            return false;
        }
        PersonGroup other = (PersonGroup) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.PersonGroup[id=" + getId() + "]";
    }

}
