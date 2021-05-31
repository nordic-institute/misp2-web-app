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
 * Entity represents user acceptance (or rejection) of portal EULA (end user license agreement).
 * Many-to-many association between portal and user.
 */
@Entity
@Table(name = "person_eula")
@NamedQueries({ @NamedQuery(name = "PersonEula.findAll", query = "SELECT pe FROM PersonEula pe") })
public class PersonEula extends GeneralBean {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "person_eula_id_seq")
    @SequenceGenerator(name = "person_eula_id_seq", sequenceName = "person_eula_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id; // primary key
    
    @JoinColumn(name = "person_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Person person; // reference to user

    @JoinColumn(name = "portal_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Portal portal; // reference to portal where EULA is in use

    @Column(name = "accepted", nullable = false)
    private Boolean accepted = Boolean.FALSE; // state of user EULA acceptance (true: accepted / false: rejected)
    

    @Column(name = "auth_method", nullable = false, length = Const.LENGTH_64)
    private String authMethod; // reference to authentication method of logged in user

    @Column(name = "src_addr", nullable = false, length = Const.LENGTH_64)
    private String srcAddr; // source (IP) address of logged in user
    
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
     * @return reference to user with accepted/rejected EULA
     */
    public Person getPerson() {
        return person;
    }
    
    /**
     * Set reference to user having accepted/rejected EULA.
     * @param person reference to user
     */
    public void setPerson(Person person) {
        this.person = person;
    }
    
    /**
     * @return portal entity with associated EULA that user has accepted/rejected
     */
    public Portal getPortal() {
        return portal;
    }
    
    /**
     * @param portal Portal entity with EULA enabled
     */
    public void setPortal(Portal portal) {
        this.portal = portal;
    }
    
    /**
     * @return status of user EULA acceptance: accepted (true) or rejected (false)
     */
    public Boolean getAccepted() {
        return accepted;
    }
    
    /**
     * Set status of user EULA acceptance.
     * @param accepted true if accepted, false if rejected
     */
    public void setAccepted(Boolean accepted) {
        this.accepted = accepted;
    }
    
    /**
     * @return user authentication method during EULA acceptance
     */
    public String getAuthMethod() {
        return authMethod;
    }
    
    /**
     * Set user authentication method during EULA acceptance.
     * @param user authentication method in plain text
     */
    public void setAuthMethod(String authMethod) {
        this.authMethod = authMethod;
    }
    
    /**
     * @return source (IP) address of user during EULA acceptance.
     */
    public String getSrcAddr() {
        return srcAddr;
    }
    
    /**
     * Set source (IP) address of user during EULA acceptance.
     * @param srcAddr logged in user source IP address
     */
    public void setSrcAddr(String srcAddr) {
        this.srcAddr = srcAddr;
    }
    
}
