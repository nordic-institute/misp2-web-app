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

import java.util.Date;
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
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "group_person")
@NamedQueries({ @NamedQuery(name = "GroupPerson.findAll", query = "SELECT g FROM GroupPerson g") })
public class GroupPerson extends GeneralBean {

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "group_person_id_seq")
    @SequenceGenerator(name = "group_person_id_seq", sequenceName = "group_person_id_seq", allocationSize = 1)
    @Column(name = "id", nullable = false)
    private Integer id;
    @Column(name = "validuntil")
    @Temporal(TemporalType.DATE)
    private Date validuntil;
    @JoinColumn(name = "person_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Person person;
    @JoinColumn(name = "group_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private PersonGroup personGroup;
    @JoinColumn(name = "org_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Org org;

    /**
     * Empty constructor with no additional actions
     */
    public GroupPerson() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public GroupPerson(Integer id) {
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
     * @return the validuntil
     */
    public Date getValiduntil() {
        return validuntil;
    }

    /**
     * @param validuntilNew the validuntil to set
     */
    public void setValiduntil(Date validuntilNew) {
        this.validuntil = validuntilNew;
    }

    /**
     * @return the person
     */
    public Person getPerson() {
        return person;
    }

    /**
     * @param personNew the person to set
     */
    public void setPerson(Person personNew) {
        this.person = personNew;
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

    /**
     * @return the org
     */
    public Org getOrg() {
        return org;
    }

    /**
     * @param orgNew the org to set
     */
    public void setOrg(Org orgNew) {
        this.org = orgNew;
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
        if (!(object instanceof GroupPerson)) {
            return false;
        }
        GroupPerson other = (GroupPerson) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.GroupPerson[id=" + getId() + "]";
    }

}
