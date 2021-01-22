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
@Table(name = "xslt")
@NamedQueries({ @NamedQuery(name = "Xslt.findAll", query = "SELECT x FROM Xslt x") })
public class Xslt extends GeneralBean {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "xslt_id_seq")
    @SequenceGenerator(name = "xslt_id_seq", sequenceName = "xslt_id_seq", allocationSize = 1)
    @Column(name = "id")
    private Integer id;
    @JoinColumn(name = "query_id", referencedColumnName = "id")
    @ManyToOne(fetch = FetchType.LAZY)
    private Query queryId;
    @Column(name = "xsl", length = Const.LENGTH_2147483647)
    private String xsl;
    @Column(name = "priority")
    private Short priority;
    @Column(name = "name", length = Const.LENGTH_50)
    private String name;
    @Basic(optional = false)
    @Column(name = "form_type", nullable = false)
    private int formType;
    @Basic(optional = false)
    @Column(name = "in_use", nullable = false)
    // yes_no is uniport only
    private Boolean inUse;
    @Column(name = "producer_id")
    private Integer producerId;
    @Column(name = "url", length = Const.LENGTH_256)
    private String url;
    @JoinColumn(name = "portal_id", referencedColumnName = "id")
    @ManyToOne(fetch = FetchType.LAZY)
    private Portal portal;

    /**
     * Empty constructor with no additional actions
     */
    public Xslt() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public Xslt(Integer id) {
        this.id = id;
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     * @param formType the formType to set
     * @param inUse the inUse to set
     */
    public Xslt(Integer id, int formType, boolean inUse) {
        this.id = id;
        this.formType = formType;
        this.inUse = inUse;
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
     * @return the queryId
     */
    public Query getQueryId() {
        return queryId;
    }

    /**
     * @param queryIdNew the queryId to set
     */
    public void setQueryId(Query queryIdNew) {
        this.queryId = queryIdNew;
    }

    /**
     * @return the xsl
     */
    public String getXsl() {
        return xsl;
    }

    /**
     * @param xslNew the xsl to set
     */
    public void setXsl(String xslNew) {
        this.xsl = xslNew;
    }

    /**
     * @return the priority
     */
    public Short getPriority() {
        return priority;
    }

    /**
     * @param priorityNew the priority to set
     */
    public void setPriority(Short priorityNew) {
        this.priority = priorityNew;
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
     * @return the formType
     */
    public int getFormType() {
        return formType;
    }

    /**
     * @param formTypeNew the formType to set
     */
    public void setFormType(int formTypeNew) {
        this.formType = formTypeNew;
    }

    /**
     * @return the inUse
     */
    public Boolean getInUse() {
        return inUse;
    }

    /**
     * @param inUseNew the inUse to set
     */
    public void setInUse(Boolean inUseNew) {
        this.inUse = inUseNew;
    }

    /**
     * @return the producerId
     */
    public Integer getProducerId() {
        return producerId;
    }

    /**
     * @param producerIdNew the producerId to set
     */
    public void setProducerId(Integer producerIdNew) {
        this.producerId = producerIdNew;
    }

    /**
     * @return the url
     */
    public String getUrl() {
        return url;
    }

    /**
     * @param urlNew the url to set
     */
    public void setUrl(String urlNew) {
        this.url = urlNew;
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
        if (!(object instanceof Xslt)) {
            return false;
        }
        Xslt other = (Xslt) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.Xslt[id=" + getId() + "]";
    }

}
