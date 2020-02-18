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

import java.io.Serializable;
import java.util.Date;

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
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "check_register_status")
@NamedQueries({ @NamedQuery(name = "CheckRegisterStatus.findAll", query = "SELECT c FROM CheckRegisterStatus c") })
public class CheckRegisterStatus extends GeneralBean implements Serializable, BeanInterface {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "check_register_status_id_seq")
    @SequenceGenerator(name = "check_register_status_id_seq", sequenceName = "check_register_status_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @Basic(optional = false)
    @Column(name = "query_name", nullable = false, length = Const.LENGTH_256)
    private String queryName;
    @Basic(optional = false)
    @Column(name = "query_time", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date queryTime;
    @Basic(optional = false)
    @Column(name = "is_ok", nullable = false)
    private boolean isOk;

    /**
     * Empty constructor with no additional actions
     */
    public CheckRegisterStatus() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public CheckRegisterStatus(Integer id) {
        this.id = id;
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     * @param queryName the queryName to set
     * @param queryTime the queryTime to set
     * @param isOk the isOk to set
     */
    public CheckRegisterStatus(Integer id, String queryName, Date queryTime, boolean isOk) {
        this.id = id;
        this.queryName = queryName;
        this.queryTime = queryTime;
        this.isOk = isOk;
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
     * @return the isOk
     */
    public boolean isOk() {
        return isOk;
    }

    /**
     * @param isOkNew the isOk to set
     */
    public void setOk(boolean isOkNew) {
        this.isOk = isOkNew;
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
        if (!(object instanceof CheckRegisterStatus)) {
            return false;
        }
        CheckRegisterStatus other = (CheckRegisterStatus) object;
        return this.hashCode() == other.hashCode();
    }

    @Override
    public String toString() {
        return "model.CheckRegisterStatus[id=" + getId() + "]";
    }

}
