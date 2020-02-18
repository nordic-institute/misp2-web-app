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

import org.apache.commons.lang.StringEscapeUtils;

import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "person")
@NamedQueries({ @NamedQuery(name = "Person.findAll", query = "SELECT p FROM Person p") })
public class Person extends GeneralBean {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "person_id_seq")
    @SequenceGenerator(name = "person_id_seq", sequenceName = "person_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @Basic(optional = false)
    @Column(name = "ssn", nullable = false, length = Const.LENGTH_20)
    private String ssn;
    @Column(name = "givenname", length = Const.LENGTH_50)
    private String givenname;
    @Basic(optional = false)
    @Column(name = "surname", nullable = false, length = Const.LENGTH_50)
    private String surname;
    @Column(name = "password", length = Const.LENGTH_50)
    private String password;
    @Column(name = "password_salt", nullable = false, length = Const.LENGTH_50)
    private String passwordSalt = "";
    @Column(name = "overtake_code", length = Const.LENGTH_50)
    private String overtakeCode;
    @Column(name = "overtake_code_salt", nullable = false, length = Const.LENGTH_50)
    private String overtakeCodeSalt = "";
    @Column(name = "certificate", length = Const.LENGTH_1042)
    private String certificate;
    @JoinColumn(name = "last_portal", referencedColumnName = "id")
    @ManyToOne(fetch = FetchType.LAZY)
    private Portal lastPortal;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "person", fetch = FetchType.LAZY)
    private List<GroupPerson> groupPersonList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "personId", fetch = FetchType.LAZY)
    private List<PersonMailOrg> personMailOrgList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "managerId", fetch = FetchType.LAZY)
    private List<ManagerCandidate> managerCandidateList;
    @OneToMany(cascade = { CascadeType.MERGE, CascadeType.REMOVE }, mappedBy = "personId", fetch = FetchType.EAGER)
    private List<OrgPerson> orgPersonList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "person", fetch = FetchType.LAZY)
    private List<PersonEula> personEulaList;

    /**
     * Empty constructor with no additional actions
     */
    public Person() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public Person(Integer id) {
        this.id = id;
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     * @param ssn the ssn to set
     * @param surname the surname to set
     */
    public Person(Integer id, String ssn, String surname) {
        this.id = id;
        this.ssn = ssn;
        this.surname = surname;
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
     * @return the ssn
     */
    public String getSsn() {
        return ssn;
    }

    /**
     * @param ssnNew the ssn to set
     */
    public void setSsn(String ssnNew) {
        this.ssn = ssnNew;
    }

    /**
     * @return the givenname
     */
    public String getGivenname() {
        return givenname;
    }

    /**
     * @param givennameNew the givenname to set
     */
    public void setGivenname(String givennameNew) {
        this.givenname = givennameNew;
    }

    /**
     * @return the surname
     */
    public String getSurname() {
        return surname;
    }

    /**
     * @param surnameNew the surname to set
     */
    public void setSurname(String surnameNew) {
        this.surname = surnameNew;
    }

    /**
     * @return the password
     */
    public String getPassword() {
        return password;
    }

    /**
     * @param passwordNew the password to set
     */
    public void setPassword(String passwordNew) {
        this.password = passwordNew;
    }

    /**
     * @return the passwordSalt
     */
    public String getPasswordSalt() {
        return passwordSalt;
    }

    /**
     * @param passwordSaltNew the passwordSalt to set
     */
    public void setPasswordSalt(String passwordSaltNew) {
        this.passwordSalt = passwordSaltNew;
    }

    /**
     * @return the overtakeCode
     */
    public String getOvertakeCode() {
        return overtakeCode;
    }

    /**
     * @param overtakeCodeNew the overtakeCode to set
     */
    public void setOvertakeCode(String overtakeCodeNew) {
        this.overtakeCode = overtakeCodeNew;
    }

    /**
     * @return the overtakeCodeSalt
     */
    public String getOvertakeCodeSalt() {
        return overtakeCodeSalt;
    }

    /**
     * @param overtakeCodeSaltNew the overtakeCodeSalt to set
     */
    public void setOvertakeCodeSalt(String overtakeCodeSaltNew) {
        this.overtakeCodeSalt = overtakeCodeSaltNew;
    }

    /**
     * @return the certificate
     */
    public String getCertificate() {
        return certificate;
    }

    /**
     * @param certificateNew the certificate to set
     */
    public void setCertificate(String certificateNew) {
        this.certificate = certificateNew;
    }

    /**
     * @return the lastPortal
     */
    public Portal getLastPortal() {
        return lastPortal;
    }

    /**
     * @param lastPortalNew the lastPortal to set
     */
    public void setLastPortal(Portal lastPortalNew) {
        this.lastPortal = lastPortalNew;
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
     * @return list of user's EULA acceptances (and rejections)
     */
    public List<PersonEula> getPersonEulaList() {
        return personEulaList;
    }

    /**
     * Set list of user's EULA acceptances and rejetions.
     * @param personEulaListNew list of user's EULA acceptances (and rejections)
     */
    public void setPersonEulaList(List<PersonEula> personEulaListNew) {
        this.personEulaList = personEulaListNew;
    }

    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof Person)) {
            return false;
        }

        final Person other = (Person) obj;

        return hashCode() == other.hashCode();
    }

    /**
     * @return givenname and surname concatenation, without null values
     */
    public String getFullName() {
        return (getGivenname() != null ? getGivenname() + " " : "") + (getSurname() != null ? getSurname() : "");
    }

    /**
     * @return givenname, surname and ssn concatenation, givenname and surname null values won't be added
     */
    public String getFullNameSsn() {
        return (getGivenname() != null ? getGivenname() + " " : "") + (getSurname() != null ? getSurname() + " " : "")
                + getSsn();
    }

    /**
     * @return givenname, surname and ssn concatenation, with ssn in parenthesis givenname
     * and surname null values won't be added
     */
    public String getFullNameSsnParenthesis() {
        return (getGivenname() != null ? getGivenname() + " " : "") + (getSurname() != null ? getSurname() + " " : "")
                + "(" + getSsn() + ")";
    }
    

    /**
     * @see {@link #getFullNameSsnParenthesis()}
     * @return person full name with SSN as string with HTML entities escaped
     */
    public String getFullNameSsnParenthesisEscapeHtml() {
        return StringEscapeUtils.escapeHtml(getFullNameSsnParenthesis());
    }

    @Override
    public int hashCode() {
        int hash = Const.PRIME_7;

        hash = Const.PRIME_17 * hash + (this.getSsn() != null ? this.getSsn().hashCode() : 0);
        return hash;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.Person[id=" + getId() + "]";
    }

}
