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
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "org")
@NamedQueries({ @NamedQuery(name = "Org.findAll", query = "SELECT o FROM Org o") })
public class Org extends GeneralBean implements Cloneable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "org_id_seq")
    @SequenceGenerator(name = "org_id_seq", sequenceName = "org_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;

    // v5: NULL; v6: member class / unit class
    @Column(name = "member_class", length = Const.LENGTH_16)
    private String memberClass;
    // v5: NULL; v6: subsystem code
    @Column(name = "subsystem_code", length = Const.LENGTH_64)
    private String subsystemCode;

    @Basic(optional = false)
    @Column(name = "code", nullable = false, length = Const.LENGTH_20)
    private String code;
    @JoinColumn(name = "sup_org_id", referencedColumnName = "id")
    @ManyToOne(fetch = FetchType.EAGER)
    private Org supOrgId;
    @OneToOne(cascade = CascadeType.ALL, mappedBy = "orgId", fetch = FetchType.LAZY)
    private OrgValid orgValid;
    @OneToMany(cascade = { CascadeType.ALL }, mappedBy = "orgId", fetch = FetchType.LAZY)
    private List<OrgPerson> orgPersonList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "orgId", fetch = FetchType.LAZY)
    private List<ManagerCandidate> managerCandidateList;
    @OneToMany(mappedBy = "orgId", fetch = FetchType.LAZY)
    private List<PersonMailOrg> personMailOrgList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "orgId", fetch = FetchType.LAZY)
    private List<PersonGroup> groupList;
    @OneToMany(mappedBy = "supOrgId", fetch = FetchType.LAZY)
    private List<Org> orgList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "orgId", fetch = FetchType.EAGER)
    private List<OrgName> orgNameList;

    /**
     * Empty constructor with no additional actions
     */
    public Org() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public Org(Integer id) {
        this.id = id;
    }

    /**
     * Makes a shallow copy. After copying still points to original complex objects(e.g. Org, List etc).
     */
    @Override
    public Object clone() throws CloneNotSupportedException {
        Org clone = (Org) super.clone();
        clone.setSupOrgId(this.getSupOrgId());
        clone.setOrgValid(this.getOrgValid());
        clone.setOrgPersonList(this.getOrgPersonList());
        clone.setManagerCandidateList(this.getManagerCandidateList());
        clone.setPersonMailOrgList(this.getPersonMailOrgList());
        clone.setGroupList(this.getGroupList());
        clone.setOrgList(this.getOrgList());
        return clone;
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
     * @return the memberClass
     */
    public String getMemberClass() {
        return memberClass;
    }

    /**
     * @param memberClassNew the memberClass to set
     */
    public void setMemberClass(String memberClassNew) {
        this.memberClass = memberClassNew;
    }

    /**
     * @return the subsystemCode
     */
    public String getSubsystemCode() {
        return subsystemCode;
    }

    /**
     * @param subsystemCodeNew the subsystemCode to set
     */
    public void setSubsystemCode(String subsystemCodeNew) {
        this.subsystemCode = subsystemCodeNew;
    }

    /**
     * @return the code
     */
    public String getCode() {
        return code;
    }

    /**
     * @param codeNew the code to set
     */
    public void setCode(String codeNew) {
        this.code = codeNew;
    }

    /**
     * @return the supOrgId
     */
    public Org getSupOrgId() {
        return supOrgId;
    }

    /**
     * @param supOrgIdNew the supOrgId to set
     */
    public void setSupOrgId(Org supOrgIdNew) {
        this.supOrgId = supOrgIdNew;
    }

    /**
     * @return the orgValid
     */
    public OrgValid getOrgValid() {
        return orgValid;
    }

    /**
     * @param orgValidNew the orgValid to set
     */
    public void setOrgValid(OrgValid orgValidNew) {
        this.orgValid = orgValidNew;
    }

    /**
     * @return the orgPersonList
     */
    public List<OrgPerson> getOrgPersonList() {
        return orgPersonList;
    }

    /**
     * @param orgPersonListNew the orgPersonList to set
     */
    public void setOrgPersonList(List<OrgPerson> orgPersonListNew) {
        this.orgPersonList = orgPersonListNew;
    }

    /**
     * @return the managerCandidateList
     */
    public List<ManagerCandidate> getManagerCandidateList() {
        return managerCandidateList;
    }

    /**
     * @param managerCandidateListNew the managerCandidateList to set
     */
    public void setManagerCandidateList(List<ManagerCandidate> managerCandidateListNew) {
        this.managerCandidateList = managerCandidateListNew;
    }

    /**
     * @return the personMailOrgList
     */
    public List<PersonMailOrg> getPersonMailOrgList() {
        return personMailOrgList;
    }

    /**
     * @param personMailOrgListNew the personMailOrgList to set
     */
    public void setPersonMailOrgList(List<PersonMailOrg> personMailOrgListNew) {
        this.personMailOrgList = personMailOrgListNew;
    }

    /**
     * @return the groupList
     */
    public List<PersonGroup> getGroupList() {
        return groupList;
    }

    /**
     * @param groupListNew the groupList to set
     */
    public void setGroupList(List<PersonGroup> groupListNew) {
        this.groupList = groupListNew;
    }

    /**
     * @return the orgList
     */
    public List<Org> getOrgList() {
        return orgList;
    }

    /**
     * @param orgListNew the orgList to set
     */
    public void setOrgList(List<Org> orgListNew) {
        this.orgList = orgListNew;
    }

    /**
     * @return the orgNameList
     */
    public List<OrgName> getOrgNameList() {
        return orgNameList;
    }

    /**
     * @param orgNameListNew the orgNameList to set
     */
    public void setOrgNameList(List<OrgName> orgNameListNew) {
        this.orgNameList = orgNameListNew;
    }

    /**
     * Gets full name
     * @param lang language
     * @return full name
     */
    public String getFullName(String lang) {
        return getActiveName(lang) + " (" + getCode() + ")";
    }

    /** Gets active org name
     * @param language language in what the name will be fetched
     * @return org active name in given language if there is one, null otherwise
     */
    public String getActiveName(String language) {
        for (OrgName on : this.getOrgNameList()) {
            if (on.getLang().equalsIgnoreCase(language)) {
                return on.getDescription();
            }
        }
        return null;
    }

    /**
     * Only compares codes
     * @param obj object to compare this to
     * @return true if objects are equal
     */
    public boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof Org)) {
            return false;
        }
        final Org other = (Org) obj;

        return hashCode() == other.hashCode();

    }

    @Override
    public int hashCode() {
        int hash = Const.PRIME_3;

        hash = Const.PRIME_97 * hash + (this.getCode() != null ? this.getCode().hashCode() : 0)
                + (this.getId() != null ? this.getId().hashCode() : 0);

        return hash;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.Org[id=" + getId() + "]";
    }

}
