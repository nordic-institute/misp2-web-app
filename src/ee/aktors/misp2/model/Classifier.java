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
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "classifier", uniqueConstraints = {
        @UniqueConstraint(columnNames = {
                "name", "xroad_query_member_code",
                "xroad_query_xroad_protocol_ver", "xroad_query_xroad_instance",
                "xroad_query_member_class", "xroad_query_subsystem_code",
                "xroad_query_service_code", "xroad_query_service_version" }) })
public class Classifier extends GeneralBean {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "classifier_id_seq")
    @SequenceGenerator(name = "classifier_id_seq", sequenceName = "classifier_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;

    @Basic(optional = false)
    @Column(name = "name", nullable = false, length = Const.LENGTH_50)
    private String name;
    @Basic(optional = false)
    @Column(name = "content", nullable = false)
    private String content;

    // Classifier request parameters. For system classifier, the following values are all nulls
    @Column(name = "xroad_query_member_code", nullable = true, length = Const.LENGTH_50)
    private String xroadQueryMemberCode;
    @Column(name = "xroad_query_xroad_protocol_ver", nullable = true, length = Const.LENGTH_5)
    private String xroadQueryXroadProtocolVer;
    @Column(name = "xroad_query_xroad_instance", nullable = true, length = Const.LENGTH_64)
    private String xroadQueryXroadInstance;
    @Column(name = "xroad_query_member_class", nullable = true, length = Const.LENGTH_16)
    private String xroadQueryMemberClass;
    @Column(name = "xroad_query_subsystem_code", nullable = true, length = Const.LENGTH_64)
    private String xroadQuerySubsystemCode;
    @Column(name = "xroad_query_service_code", nullable = true, length = Const.LENGTH_256)
    private String xroadQueryServiceCode;
    @Column(name = "xroad_query_service_version", nullable = true, length = Const.LENGTH_256)
    private String xroadQueryServiceVersion;
    /**
     * This member is used when downloading classifiers with X-Road request defined by this instance. E.g. it is used
     * for X-Road v6 loadClassification request body creation.
     */
    @Column(name = "xroad_query_request_namespace", nullable = true, length = Const.LENGTH_256)
    private String xroadQueryRequestNamespace;

    /**
     * Empty constructor with no additional actions
     */
    public Classifier() {
    }
    
    

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public Classifier(Integer id) {
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
     * @return the content
     */
    public String getContent() {
        return content;
    }

    /**
     * @param contentNew the content to set
     */
    public void setContent(String contentNew) {
        this.content = contentNew;
    }

    /**
     * @return the xroadQueryMemberCode
     */
    public String getXroadQueryMemberCode() {
        return xroadQueryMemberCode;
    }

    /**
     * @param xroadQueryMemberCodeNew the xroadQueryMemberCode to set
     */
    public void setXroadQueryMemberCode(String xroadQueryMemberCodeNew) {
        this.xroadQueryMemberCode = xroadQueryMemberCodeNew;
    }

    /**
     * @return the xroadQueryXroadProtocolVer
     */
    public String getXroadQueryXroadProtocolVer() {
        return xroadQueryXroadProtocolVer;
    }

    /**
     * @param xroadQueryXroadProtocolVerNew the xroadQueryXroadProtocolVer to set
     */
    public void setXroadQueryXroadProtocolVer(String xroadQueryXroadProtocolVerNew) {
        this.xroadQueryXroadProtocolVer = xroadQueryXroadProtocolVerNew;
    }

    /**
     * @return the xroadQueryXroadInstance
     */
    public String getXroadQueryXroadInstance() {
        return xroadQueryXroadInstance;
    }

    /**
     * @param xroadQueryXroadInstanceNew the xroadQueryXroadInstance to set
     */
    public void setXroadQueryXroadInstance(String xroadQueryXroadInstanceNew) {
        this.xroadQueryXroadInstance = xroadQueryXroadInstanceNew;
    }

    /**
     * @return the xroadQueryMemberClass
     */
    public String getXroadQueryMemberClass() {
        return xroadQueryMemberClass;
    }

    /**
     * @param xroadQueryMemberClassNew the xroadQueryMemberClass to set
     */
    public void setXroadQueryMemberClass(String xroadQueryMemberClassNew) {
        this.xroadQueryMemberClass = xroadQueryMemberClassNew;
    }

    /**
     * @return the xroadQuerySubsystemCode
     */
    public String getXroadQuerySubsystemCode() {
        return xroadQuerySubsystemCode;
    }

    /**
     * @param xroadQuerySubsystemCodeNew the xroadQuerySubsystemCode to set
     */
    public void setXroadQuerySubsystemCode(String xroadQuerySubsystemCodeNew) {
        this.xroadQuerySubsystemCode = xroadQuerySubsystemCodeNew;
    }

    /**
     * @return the xroadQueryServiceCode
     */
    public String getXroadQueryServiceCode() {
        return xroadQueryServiceCode;
    }

    /**
     * @param xroadQueryServiceCodeNew the xroadQueryServiceCode to set
     */
    public void setXroadQueryServiceCode(String xroadQueryServiceCodeNew) {
        this.xroadQueryServiceCode = xroadQueryServiceCodeNew;
    }

    /**
     * @return the xroadQueryServiceVersion
     */
    public String getXroadQueryServiceVersion() {
        return xroadQueryServiceVersion;
    }

    /**
     * @param xroadQueryServiceVersionNew the xroadQueryServiceVersion to set
     */
    public void setXroadQueryServiceVersion(String xroadQueryServiceVersionNew) {
        this.xroadQueryServiceVersion = xroadQueryServiceVersionNew;
    }

    /**
     * @return the xroadQueryRequestNamespace
     */
    public String getXroadQueryRequestNamespace() {
        return xroadQueryRequestNamespace;
    }

    /**
     * @param xroadQueryRequestNamespaceNew the xroadQueryRequestNamespace to set
     */
    public void setXroadQueryRequestNamespace(String xroadQueryRequestNamespaceNew) {
        this.xroadQueryRequestNamespace = xroadQueryRequestNamespaceNew;
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
        if (!(object instanceof Classifier)) {
            return false;
        }
        Classifier other = (Classifier) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.Classifier[id=" + getId() + "]";
    }

    /**
     * Check if xroadQueryXroadProtocolVer is set
     * @return false if {@code xroadQueryXroadProtocolVer} is null, true otherwise
     */
    public boolean isSystemClassifier() {
        return xroadQueryXroadProtocolVer == null;
    }

}
