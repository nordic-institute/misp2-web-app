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
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
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
@Table(name = "t3_sec")
@NamedQueries({ @NamedQuery(name = "T3Sec.findAll", query = "SELECT t FROM T3Sec t") })
public class T3Sec extends GeneralBean implements Cloneable {

    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "t3_sec_id_seq")
    @SequenceGenerator(name = "t3_sec_id_seq", sequenceName = "t3_sec_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @Basic(optional = false)
    @Column(name = "user_from", nullable = false, length = Const.LENGTH_20)
    private String userFrom;
    @Column(name = "user_to", length = Const.LENGTH_20)
    private String userTo;
    @Basic(optional = false)
    @Column(name = "action_id", nullable = false)
    private int actionId = -1;
    @Column(name = "query", length = Const.LENGTH_256)
    private String query;
    @Column(name = "group_name", length = Const.LENGTH_150)
    private String groupName;
    @Column(name = "org_code", length = Const.LENGTH_20)
    private String orgCode;
    @Column(name = "portal_name", length = Const.LENGTH_32)
    private String portalName;
    @Column(name = "valid_until", length = Const.LENGTH_50)
    private String validUntil;
    @Column(name = "query_id", length = Const.LENGTH_100)
    private String queryId;

    /**
     * Empty constructor with no additional actions
     */
    public T3Sec() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public T3Sec(Integer id) {
        this.id = id;
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     * @param userFrom the userForm to set
     * @param actionId the actionId to set
     */
    public T3Sec(Integer id, String userFrom, int actionId) {
        this.id = id;
        this.userFrom = userFrom;
        this.actionId = actionId;
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
     * @return the userFrom
     */
    public String getUserFrom() {
        return userFrom;
    }

    /**
     * @param userFromNew the userFrom to set
     */
    public void setUserFrom(String userFromNew) {
        this.userFrom = userFromNew;
    }

    /**
     * @return the userTo
     */
    public String getUserTo() {
        return userTo;
    }

    /**
     * @param userToNew the userTo to set
     */
    public void setUserTo(String userToNew) {
        this.userTo = userToNew;
    }

    /**
     * @return the actionId
     */
    public int getActionId() {
        return actionId;
    }

    /**
     * @param actionIdNew the actionId to set
     */
    public void setActionId(int actionIdNew) {
        this.actionId = actionIdNew;
    }

    /**
     * @return the query
     */
    public String getQuery() {
        return query;
    }

    /**
     * @param queryNew the query to set
     */
    public void setQuery(String queryNew) {
        this.query = queryNew;
    }

    /**
     * @return the groupName
     */
    public String getGroupName() {
        return groupName;
    }

    /**
     * @param groupNameNew the groupName to set
     */
    public void setGroupName(String groupNameNew) {
        this.groupName = groupNameNew;
    }

    /**
     * @return the orgCode
     */
    public String getOrgCode() {
        return orgCode;
    }

    /**
     * @param orgCodeNew the orgCode to set
     */
    public void setOrgCode(String orgCodeNew) {
        this.orgCode = orgCodeNew;
    }

    /**
     * @return the portalName
     */
    public String getPortalName() {
        return portalName;
    }

    /**
     * @param portalNameNew the portalName to set
     */
    public void setPortalName(String portalNameNew) {
        this.portalName = portalNameNew;
    }

    /**
     * @return the validUntil
     */
    public String getValidUntil() {
        return validUntil;
    }

    /**
     * @param validUntilNew the validUntil to set
     */
    public void setValidUntil(String validUntilNew) {
        this.validUntil = validUntilNew;
    }

    /**
     * @return the queryId
     */
    public String getQueryId() {
        return queryId;
    }

    /**
     * @param queryIdNew the queryId to set
     */
    public void setQueryId(String queryIdNew) {
        this.queryId = queryIdNew;
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
        if (!(object instanceof T3Sec)) {
            return false;
        }
        T3Sec other = (T3Sec) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.T3Sec[id=" + getId() + "]";
    }

    @Override
    public T3Sec clone() {
        T3Sec clone = new T3Sec();
        clone.setActionId(getActionId());
        clone.setGroupName(getGroupName());
        clone.setOrgCode(getOrgCode());
        clone.setPortalName(getPortalName());
        clone.setQuery(getQuery());
        clone.setQueryId(getQueryId());
        clone.setUserFrom(getUserFrom());
        clone.setUserTo(getUserTo());
        clone.setValidUntil(getValidUntil());
        clone.setCreated(getCreated());
        clone.setUsername(getUsername());
        clone.setLastModified(getLastModified());
        return clone;
    }

}
