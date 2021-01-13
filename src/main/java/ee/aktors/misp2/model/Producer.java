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

import java.util.Comparator;
import java.util.List;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.lang.StringEscapeUtils;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "producer")
public class Producer extends GeneralBean {
   
    private static final long serialVersionUID = 7430552899493582519L;

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "producer_id_seq")
    @SequenceGenerator(name = "producer_id_seq", sequenceName = "producer_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;

    // v5: NULL; v6: xroadInstance
    @Column(name = "xroad_instance", length = Const.LENGTH_64)
    private String xroadInstance;
    // v5: producer name; v6: member code
    @Basic(optional = false)
    @Column(name = "short_name", nullable = false, length = Const.LENGTH_50)
    private String shortName;
    // v5: NULL; v6: member class / unit class
    @Column(name = "member_class", length = Const.LENGTH_16)
    private String memberClass;
    // v5: NULL; v6: subsystem code
    @Column(name = "subsystem_code", length = Const.LENGTH_64)
    private String subsystemCode;

    @Column(name = "in_use")
    private Boolean inUse;
    @Column(name = "is_complex")
    private Boolean isComplex;
    @Column(name = "wsdl_url", length = Const.LENGTH_256)
    private String wsdlURL;
    @Column(name = "repository_url", length = Const.LENGTH_256)
    private String repositoryUrl;
    @OneToMany(mappedBy = "producer", fetch = FetchType.LAZY)
    private List<Query> queryList;
    @OneToMany(mappedBy = "producer", fetch = FetchType.LAZY)
    private List<ProducerName> producerNameList;
    @JoinColumn(name = "portal_id", referencedColumnName = "id", nullable = false)
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Portal portal;


    @Enumerated(EnumType.STRING)
    @Column(name = "protocol")
    private ProtocolType protocol;

    /**
     * Empty constructor with no additional actions
     */
    public Producer() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public Producer(Integer id) {
        this.id = id;
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     * @param shortName the shortName to set
     */
    public Producer(Integer id, String shortName) {
        this.id = id;
        this.shortName = shortName;
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
     * @return the xroadInstance
     */
    public String getXroadInstance() {
        return xroadInstance;
    }

    /**
     * @param newXroadInstance the xroadInstance to set
     */
    public void setXroadInstance(String newXroadInstance) {
        this.xroadInstance = newXroadInstance;
    }

    /**
     * @return the shortName
     */
    public String getShortName() {
        return shortName;
    }

    /**
     * @param shortNameNew the shortName to set
     */
    public void setShortName(String shortNameNew) {
        this.shortName = shortNameNew;
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
     * @return the isComplex
     */
    public Boolean getIsComplex() {
        return isComplex != null && isComplex;
    }

    /**
     * @param isComplexNew the isComplex to set
     */
    public void setIsComplex(Boolean isComplexNew) {
        this.isComplex = isComplexNew;
    }

    /**
     * @return the wsdlURL
     */
    public String getWsdlURL() {
        return wsdlURL;
    }

    /**
     * @param wsdlURLNew the wsdlURL to set
     */
    public void setWsdlURL(String wsdlURLNew) {
        this.wsdlURL = wsdlURLNew;
    }

    /**
     * @return the repositoryUrl
     */
    public String getRepositoryUrl() {
        return repositoryUrl;
    }

    /**
     * @param repositoryUrlNew the repositoryUrl to set
     */
    public void setRepositoryUrl(String repositoryUrlNew) {
        this.repositoryUrl = repositoryUrlNew;
    }

    /**
     * @return the queryList
     */
    public List<Query> getQueryList() {
        return queryList;
    }

    /**
     * @param queryListNew the queryList to set
     */
    public void setQueryList(List<Query> queryListNew) {
        this.queryList = queryListNew;
    }

    /**
     * @return the producerNameList
     */
    public List<ProducerName> getProducerNameList() {
        return producerNameList;
    }

    /**
     * @param producerNameListNew the producerNameList to set
     */
    public void setProducerNameList(List<ProducerName> producerNameListNew) {
        this.producerNameList = producerNameListNew;
    }

    /**
     * Checks if producer has given protocol type
     *
     * @param protocol protocol type to check
     * @return true if producer has protocol, false otherwise or if protocol to check is null
     */
    public boolean hasProtocol(ProtocolType protocol) {
        return this.protocol.equals(protocol);
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
     * Gets activeName in given language
     * @param language language
     * @return active name in given language, null if active name is not available in that language
     */
    public ProducerName getActiveName(String language) {
        for (ProducerName pn : this.getProducerNameList()) {
            if (pn.getLang().equals(language)) {
                return pn;
            }
        }
        return null;
    }

    /**
     * @return protocol type
     */
    public ProtocolType getProtocol() {
        return protocol;
    }

    /**
     * @param protocol set protocol type
     */
    public void setProtocol(ProtocolType protocol) {
        this.protocol = protocol;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (getId() != null ? getId().hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {

        //Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Producer)) {
            return false;
        }
        Producer other = (Producer) object;

        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.Producer[id=" + getId() + "]";
    }

    public static final Comparator<Producer> COMPARE_BY_PRODUCER_DESCRIPTION = new Comparator<Producer>() {
        public int compare(Producer one, Producer other) {
            String language = ActionContext.getContext().getLocale().getLanguage();
            String oneDescription = one.getActiveName(language) != null ? one.getActiveName(language).getDescription()
                    : "";
            String otherDescription = other.getActiveName(language) != null ? other.getActiveName(language)
                    .getDescription() : "";
            if (oneDescription != null && otherDescription != null) {
                return oneDescription.trim().toUpperCase().compareTo(otherDescription.trim().toUpperCase());
            }
            return 0;
        }

    };

    /**
     * Gets shortName if memberClass and subsystem are null otherwise concatenation of
     * xroadInstance, memberClass, memberCode (shortName) and subsystemCode (if the latter exists)
     * separated with a separator given as method argument.
     * @param sep separator of X-Road v6 identifier parts.
     * @return X-Road identifier string
     */
    public String getXroadIdentifier(String sep) {
        if (shortName != null && subsystemCode == null && memberClass == null) {
            return shortName;
        } else {
            return xroadInstance + sep + memberClass + sep + shortName
                    + (subsystemCode != null ? sep + subsystemCode : "");
        }
    }

    /**
     * Call to {@link #getXroadIdentifier(String sep)} with sep=" : ".
     * @return X-Road identifier
     */
    public String getXroadIdentifier() {
        return getXroadIdentifier(" : ");
    }

    /**
     * @see #getXroadIdentifier()
     * @return X-Road identifier with escaped HTML
     */
    public String getXroadIdentifierEscapeHtml() {
        return StringEscapeUtils.escapeHtml(getXroadIdentifier());
    }

    public enum ProtocolType {
        SOAP, REST
    }
}

