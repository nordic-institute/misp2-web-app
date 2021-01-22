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
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

import ee.aktors.misp2.util.Const;

/**
 * Entity for holding portal service X-Road instance data
 */
@Entity
@Table(
    name = "xroad_instance",
    uniqueConstraints = { @UniqueConstraint(columnNames = { "portal_id", "code" }) })
public class XroadInstance extends GeneralBean implements Comparable<XroadInstance> {

    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "xroad_instance_id_seq")
    @SequenceGenerator(name = "xroad_instance_id_seq", sequenceName = "xroad_instance_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @Basic(optional = false)
    @Column(name = "code", nullable = false, length = Const.XROAD_INSTANCE_MAX_LENGTH)
    private String code;
    @Column(name = "in_use")
    private Boolean inUse;
    @Column(name = "selected")
    private Boolean selected;
    @JoinColumn(name = "portal_id", referencedColumnName = "id", nullable = false)
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Portal portal;

    /**
     * Empty constructor with no additional actions
     */
    public XroadInstance() {
        this.id = null;
        this.code = null;
        this.portal = null;
        this.inUse = null;
        this.selected = null;
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     * @param code the name to set
     */
    public XroadInstance(Integer id, String code) {
        this.id = id;
        this.code = code;
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
     * @return the code (e.g. ee-dev)
     */
    public String getCode() {
        return code;
    }

    /**
     * @param codeNew the name to set
     */
    public void setCode(String codeNew) {
        this.code = codeNew;
    }

    /**
     * @return true if code is in use in the portal
     */
    public Boolean getInUse() {
        return inUse;
    }

    /**
     * @param newInUse is instance in use in the portal
     */
    public void setInUse(Boolean newInUse) {
        this.inUse = newInUse;
    }


    /**
     * @return true if code is in use by default in the portal
     */
    public Boolean getSelected() {
        return selected;
    }

    /**
     * @param newSelected is instance in use by default in the portal
     */
    public void setSelected(Boolean newSelected) {
        this.selected = newSelected;
    }
    
    /**
     * @return the associated portal
     */
    public Portal getPortal() {
        return portal;
    }

    /**
     * @param portalNew associated portal to set
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
        if (!(object instanceof XroadInstance)) {
            return false;
        }
        XroadInstance other = (XroadInstance) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        Integer portalId = portal != null ? portal.getId() : null;
        return "model.XroadInstance[id=" + getId() + " code=" + getCode() + " portalId=" + portalId + "]";
    }

    /**
     * @see java.lang.Comparable#compareTo(java.lang.Object)
     * @param o object to compare this to
     * @return 0 if equal, 1 if this is larger, -1 this is smaller
     */
    @Override
    public int compareTo(XroadInstance o) {
        String thisCode = (this.getCode() == null ? "" : this.getCode());
        String otherCode = (o.getCode() == null ? "" : o.getCode());
        return thisCode.compareToIgnoreCase(otherCode);
    }
}
