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

import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "org_person")
@NamedQueries({ @NamedQuery(name = "OrgPerson.findAll", query = "SELECT o FROM OrgPerson o") })
public class OrgPerson extends GeneralBean {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "org_person_id_seq")
    @SequenceGenerator(name = "org_person_id_seq", sequenceName = "org_person_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @Basic(optional = false)
    @Column(name = "role", nullable = false)
    private Integer role;
    @Column(name = "profession", length = Const.LENGTH_50)
    private String profession;
    @JoinColumn(name = "person_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Person personId;
    @JoinColumn(name = "org_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Org orgId;
    @JoinColumn(name = "portal_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Portal portal;

    /**
     * Empty constructor with no additional actions
     */
    public OrgPerson() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public OrgPerson(Integer id) {
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
     * @return the role
     */
    public Integer getRole() {
        return role;
    }

    /**
     * @param roleNew the role to set
     */
    public void setRole(Integer roleNew) {
        this.role = roleNew;
    }

    /**
     * @return the profession
     */
    public String getProfession() {
        return profession;
    }

    /**
     * @param professionNew the profession to set
     */
    public void setProfession(String professionNew) {
        this.profession = professionNew;
    }

    /**
     * @return the personId
     */
    public Person getPersonId() {
        return personId;
    }

    /**
     * @param personIdNew the personId to set
     */
    public void setPersonId(Person personIdNew) {
        this.personId = personIdNew;
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
        if (!(object instanceof OrgPerson)) {
            return false;
        }
        OrgPerson other = (OrgPerson) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.OrgPerson[id=" + getId() + "]";
    }

}
