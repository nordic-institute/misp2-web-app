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

import java.util.Date;

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
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "query_log")
@NamedQueries({ @NamedQuery(name = "QueryLog.findAll", query = "SELECT q FROM QueryLog q") })
public class QueryLog extends GeneralBean {

    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "query_log_id_seq")
    @SequenceGenerator(name = "query_log_id_seq", sequenceName = "query_log_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false, insertable = false)
    private Integer id;
    @Basic(optional = false)
    @Column(name = "query_name", nullable = false, length = Const.LENGTH_256)
    private String queryName;
    @Basic(optional = false)
    @Column(name = "main_query_name", nullable = false, length = Const.LENGTH_256)
    private String mainQueryName;
    @Column(name = "org_code", length = Const.LENGTH_20)
    private String orgCode;
    @Column(name = "unit_code", length = Const.LENGTH_20)
    private String unitCode;
    @Basic(optional = false)
    @Column(name = "query_id", nullable = false, length = Const.LENGTH_50)
    private String queryId;
    @Column(name = "query_time")
    @Temporal(TemporalType.TIMESTAMP)
    private Date queryTime;
    @Column(name = "person_ssn", length = Const.LENGTH_20)
    private String personSsn;
    @Column(name = "query_time_sec")
    private Double queryTimeSec;
    @Column(name = "query_size")
    private Double querySize;
    @Column(name = "description")
    private String description;
    @Column(name = "success")
    private Boolean success;
    @JoinColumn(name = "portal_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Portal portal;
    @OneToOne(cascade = CascadeType.ALL, mappedBy = "queryLog", fetch = FetchType.LAZY)
    private QueryErrorLog queryErrorLogId;

    /**
     * Empty constructor with call to super
     */
    public QueryLog() {
        super();
    }
    
    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public QueryLog(Integer id) {
        this.id = id;
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     * @param queryName the queryName to set
     * @param queryId the queryId to set
     */
    public QueryLog(Integer id, String queryName, String queryId) {
        this.id = id;
        this.queryName = queryName;
        this.queryId = queryId;
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
     * @return the queryName
     */
    public String getQueryName() {
        return queryName;
    }

    /**
     * @param queryNameNew the queryName to set
     */
    public void setQueryName(String queryNameNew) {
        this.queryName = queryNameNew;
    }

    /**
     * @return the mainQueryName
     */
    public String getMainQueryName() {
        return mainQueryName;
    }

    /**
     * @param mainQueryNameNew the mainQueryName to set
     */
    public void setMainQueryName(String mainQueryNameNew) {
        this.mainQueryName = mainQueryNameNew;
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
     * @return the unitCode
     */
    public String getUnitCode() {
        return unitCode;
    }

    /**
     * @param unitCodeNew the unitCode to set
     */
    public void setUnitCode(String unitCodeNew) {
        this.unitCode = unitCodeNew;
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

    /**
     * @return the queryTime
     */
    public Date getQueryTime() {
        return queryTime;
    }

    /**
     * @param queryTimeNew the queryTime to set
     */
    public void setQueryTime(Date queryTimeNew) {
        this.queryTime = queryTimeNew;
    }

    /**
     * @return the personSsn
     */
    public String getPersonSsn() {
        return personSsn;
    }

    /**
     * @param personSsnNew the personSsn to set
     */
    public void setPersonSsn(String personSsnNew) {
        this.personSsn = personSsnNew;
    }

    /**
     * @return the queryTimeSec
     */
    public Double getQueryTimeSec() {
        return queryTimeSec;
    }

    /**
     * @param queryTimeSecNew the queryTimeSec to set
     */
    public void setQueryTimeSec(Double queryTimeSecNew) {
        this.queryTimeSec = queryTimeSecNew;
    }
    
    /**
     * @param queryTimeSecNew the queryTimeSec to set
     */
    public void setQueryTimeSec(String queryTimeSecNew) {
        this.queryTimeSec = Double.parseDouble(queryTimeSecNew);
    }
    
    /**
     * @return the querySize
     */
    public Double getQuerySize() {
        return querySize;
    }

    /**
     * @param querySizeNew the querySize to set
     */
    public void setQuerySize(Double querySizeNew) {
        this.querySize = querySizeNew;
    }

    /**
     * @param querySizeNew the querySize to set
     */
    public void setQuerySize(String querySizeNew) {
        this.querySize = Double.parseDouble(querySizeNew);
    }
    
    /**
     * @return the description
     */
    public String getDescription() {
        return description;
    }

    /**
     * @param descriptionNew the description to set
     */
    public void setDescription(String descriptionNew) {
        this.description = descriptionNew;
    }

    /**
     * @return the success
     */
    public Boolean getSuccess() {
        return success;
    }

    /**
     * @param successNew the success to set
     */
    public void setSuccess(Boolean successNew) {
        this.success = successNew;
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

    /**
     * @return the queryErrorLogId
     */
    public QueryErrorLog getQueryErrorLogId() {
        return queryErrorLogId;
    }

    /**
     * @param queryErrorLogIdNew the queryErrorLogId to set
     */
    public void setQueryErrorLogId(QueryErrorLog queryErrorLogIdNew) {
        this.queryErrorLogId = queryErrorLogIdNew;
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
        if (!(object instanceof QueryLog)) {
            return false;
        }
        QueryLog other = (QueryLog) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.QueryLog[id=" + getId() + "]";
    }

}
