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

import java.util.Iterator;
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
import javax.persistence.UniqueConstraint;

import ee.aktors.misp2.provider.ConfigurationProvider;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Const.XROAD_VERSION;

/**
 *
 * @author arnis.rips
 */
@Entity
@Table(name = "portal", uniqueConstraints = { @UniqueConstraint(columnNames = { "short_name" }) })
@NamedQueries({ @NamedQuery(name = "Portal.findAll", query = "SELECT p FROM Portal p") })
public class Portal extends GeneralBean implements Cloneable {

    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "portal_id_seq")
    @SequenceGenerator(name = "portal_id_seq", sequenceName = "portal_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @JoinColumn(name = "org_id", referencedColumnName = "id")
    @ManyToOne(cascade = CascadeType.REMOVE, optional = false, fetch = FetchType.EAGER)
    private Org orgId;
    @Basic(optional = false)
    @Column(name = "misp_type")
    private int mispType = Const.MISP_TYPE_SIMPLE;
    @Basic(optional = false)
    @Column(name = "short_name", nullable = false, length = Const.LENGTH_32)
    private String shortName;
    @Basic(optional = false)
    @Column(name = "security_host", nullable = false, length = Const.LENGTH_256)
    private String securityHost;
    @Basic(optional = false)
    @Column(name = "message_mediator", nullable = false, length = Const.LENGTH_256)
    private String messageMediator;
    @Basic(optional = false)
    @Column(name = "debug", nullable = false)
    private int debug = 0;
    @Column(name = "univ_auth_query", length = Const.LENGTH_50)
    private String univAuthQuery = null;
    @Column(name = "univ_check_query", length = Const.LENGTH_50)
    private String univCheckQuery = null;
    @Column(name = "univ_check_valid_time")
    private Integer univCheckValidTime = null;
    @Column(name = "univ_check_max_valid_time")
    private Integer univCheckMaxValidTime;
    @Column(name = "univ_use_manager")
    private Boolean univUseManger = Boolean.FALSE;
    @Column(name = "use_topics")
    private Boolean useTopics = Boolean.FALSE;
    @Column(name = "use_xrd_issue")
    private Boolean useXrdIssue = Boolean.FALSE;
    @Column(name = "log_query")
    private Boolean logQuery = Boolean.FALSE;
    @Column(name = "register_units")
    private Boolean registerUnits;
    @Column(name = "unit_is_consumer")
    private Boolean unitIsConsumer;
    // X-Road v6 specific fields
    @Column(name = "client_xroad_instance", length = Const.XROAD_INSTANCE_MAX_LENGTH)
    private String clientXroadInstance; // DEV, TEST, PROD
    @Column(name = "xroad_protocol_ver", nullable = false, length = Const.LENGTH_5)
    private String xroadProtocolVer; // default is '3.1' meaning X-Road v5, '4.0' means X-Road v6
    // logOnly service conf for X-Road v6
    @Column(name = "misp2_xroad_service_member_class", length = Const.LENGTH_16)
    private String misp2XroadServiceMemberClass;
    @Column(name = "misp2_xroad_service_member_code", length = Const.LENGTH_20)
    private String misp2XroadServiceMemberCode;
    @Column(name = "misp2_xroad_service_subsystem_code", length = Const.LENGTH_64)
    private String misp2XroadServiceSubsystemCode;
    @Column(name = "eula_in_use")
    private Boolean eulaInUse = Boolean.FALSE;

    @OneToMany(cascade = CascadeType.ALL, mappedBy = "portal", fetch = FetchType.LAZY)
    private List<PersonGroup> groupList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "portal", fetch = FetchType.LAZY)
    private List<OrgPerson> orgPersonList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "portal", fetch = FetchType.LAZY)
    private List<Xslt> xsltList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "portal", fetch = FetchType.LAZY)
    private List<Producer> producerList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "portal", fetch = FetchType.LAZY)
    private List<OrgPerson> queryLogList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "portal", fetch = FetchType.LAZY)
    private List<PortalName> portalNameList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "portal", fetch = FetchType.LAZY)
    private List<XroadInstance> serviceXroadInstanceList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "portal", fetch = FetchType.LAZY)
    private List<PortalEula> portalEulaList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "person", fetch = FetchType.LAZY)
    private List<PersonEula> personEulaList;

    /**
     * Empty constructor with no additional actions
     */
    public Portal() {
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     */
    public Portal(Integer id) {
        this.id = id;
    }

    /**
     * Initialize the parameters. No additional actions
     * @param id the id to set
     * @param orgId the orgId to set
     * @param mispType the mispType to set
     * @param messageMediator the messageMediator to set
     * @param debug the debug to set
     */
    public Portal(Integer id, Org orgId, int mispType, String messageMediator, int debug) {
        this.id = id;
        this.orgId = orgId;
        this.mispType = mispType;
        this.messageMediator = messageMediator;
        this.debug = debug;
    }

    /**
     * Makes a shallow copy. After copying still points to original complex objects(e.g. Org, List etc).
     */
    @Override
    public Object clone() throws CloneNotSupportedException {
        Portal clone = (Portal) super.clone();
        clone.setOrgId(this.getOrgId());
        clone.setGroupList(this.getGroupList());
        clone.setOrgPersonList(this.getOrgPersonList());
        clone.setXsltList(this.getXsltList());
        clone.setProducerList(this.getProducerList());
        clone.setQueryLogList(this.getQueryLogList());
        clone.setPortalNameList(this.getPortalNameList());
        clone.setServiceXroadInstanceList(this.getServiceXroadInstanceList());
        clone.setPortalEulaList(this.getPortalEulaList());
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
     * @return the orgId
     */
    public Org getOrgId() {
        return orgId;
    }

    /**
     * @param orgIdNew the orgId to set
     */
    public void setOrgId(Org orgIdNew) {
        this.orgId = orgIdNew;
    }

    /**
     * @return the mispType
     */
    public int getMispType() {
        return mispType;
    }

    /**
     * @param mispTypeNew the mispType to set
     */
    public void setMispType(int mispTypeNew) {
        this.mispType = mispTypeNew;
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
     * @return the securityHost
     */
    public String getSecurityHost() {
        return securityHost;
    }

    /**
     * @param securityHostNew the securityHost to set
     */
    public void setSecurityHost(String securityHostNew) {
        this.securityHost = securityHostNew;
    }

    /**
     * @return the messageMediator
     */
    public String getMessageMediator() {
        return messageMediator;
    }

    /**
     * @param messageMediatorNew the messageMediator to set
     */
    public void setMessageMediator(String messageMediatorNew) {
        this.messageMediator = messageMediatorNew;
    }

    /**
     * @return the debug
     */
    public int getDebug() {
        return debug;
    }

    /**
     * @param debugNew the debug to set
     */
    public void setDebug(int debugNew) {
        this.debug = debugNew;
    }

    /**
     * @return the univAuthQuery
     */
    public String getUnivAuthQuery() {
        return univAuthQuery;
    }

    /**
     * @param univAuthQueryNew the univAuthQuery to set
     */
    public void setUnivAuthQuery(String univAuthQueryNew) {
        this.univAuthQuery = univAuthQueryNew;
    }

    /**
     * @return the univCheckQuery
     */
    public String getUnivCheckQuery() {
        return univCheckQuery;
    }

    /**
     * @param univCheckQueryNew the univCheckQuery to set
     */
    public void setUnivCheckQuery(String univCheckQueryNew) {
        this.univCheckQuery = univCheckQueryNew;
    }

    /**
     * @return the univCheckValidTime
     */
    public Integer getUnivCheckValidTime() {
        return univCheckValidTime;
    }

    /**
     * @param univCheckValidTimeNew the univCheckValidTime to set
     */
    public void setUnivCheckValidTime(Integer univCheckValidTimeNew) {
        this.univCheckValidTime = univCheckValidTimeNew;
    }

    /**
     * @return the univCheckMaxValidTime
     */
    public Integer getUnivCheckMaxValidTime() {
        return univCheckMaxValidTime;
    }

    /**
     * @param univCheckMaxValidTimeNew the univCheckMaxValidTime to set
     */
    public void setUnivCheckMaxValidTime(Integer univCheckMaxValidTimeNew) {
        this.univCheckMaxValidTime = univCheckMaxValidTimeNew;
    }

    /**
     * @return the univUseManger
     */
    public Boolean isUnivUseManger() {
        return univUseManger;
    }

    /**
     * @param univUseMangerNew the univUseManger to set
     */
    public void setUnivUseManger(Boolean univUseMangerNew) {
        this.univUseManger = univUseMangerNew;
    }

    /**
     * @return the useTopics
     */
    public Boolean getUseTopics() {
        return useTopics;
    }

    /**
     * @param useTopicsNew the useTopics to set
     */
    public void setUseTopics(Boolean useTopicsNew) {
        this.useTopics = useTopicsNew;
    }

    /**
     * @return the useXrdIssue
     */
    public Boolean getUseXrdIssue() {
        return useXrdIssue;
    }

    /**
     * @param useXrdIssueNew the useXrdIssue to set
     */
    public void setUseXrdIssue(Boolean useXrdIssueNew) {
        this.useXrdIssue = useXrdIssueNew;
    }

    /**
     * @return the logQuery
     */
    public Boolean getLogQuery() {
        return logQuery;
    }

    /**
     * @param logQueryNew the logQuery to set
     */
    public void setLogQuery(Boolean logQueryNew) {
        this.logQuery = logQueryNew;
    }

    /**
     * @return the registerUnits
     */
    public Boolean getRegisterUnits() {
        return registerUnits;
    }

    /**
     * @param registerUnitsNew the registerUnits to set
     */
    public void setRegisterUnits(Boolean registerUnitsNew) {
        this.registerUnits = registerUnitsNew;
    }

    /**
     * @return the unitIsConsumer
     */
    public Boolean getUnitIsConsumer() {
        return unitIsConsumer;
    }

    /**
     * @param unitIsConsumerNew the unitIsConsumer to set
     */
    public void setUnitIsConsumer(Boolean unitIsConsumerNew) {
        this.unitIsConsumer = unitIsConsumerNew;
    }

    /**
     * @return the client X-Road instance
     */
    public String getClientXroadInstance() {
        return clientXroadInstance;
    }

    /**
     * @param xroadInstanceNew the client X-Road instance to set
     */
    public void setClientXroadInstance(String xroadInstanceNew) {
        this.clientXroadInstance = xroadInstanceNew;
    }

    /**
     * @return the xroadProtocolVer
     */
    public String getXroadProtocolVer() {
        return xroadProtocolVer;
    }

    /**
     * @param xroadProtocolVerNew the xroadProtocolVer to set
     */
    public void setXroadProtocolVer(String xroadProtocolVerNew) {
        this.xroadProtocolVer = xroadProtocolVerNew;
    }

    /**
     * @return the misp2XroadServiceMemberClass
     */
    public String getMisp2XroadServiceMemberClass() {
        return misp2XroadServiceMemberClass;
    }

    /**
     * @param misp2XroadServiceMemberClassNew the misp2XroadServiceMemberClass to set
     */
    public void setMisp2XroadServiceMemberClass(String misp2XroadServiceMemberClassNew) {
        this.misp2XroadServiceMemberClass = misp2XroadServiceMemberClassNew;
    }

    /**
     * @return the misp2XroadServiceMemberCode
     */
    public String getMisp2XroadServiceMemberCode() {
        return misp2XroadServiceMemberCode;
    }

    /**
     * @param misp2XroadServiceMemberCodeNew the misp2XroadServiceMemberCode to set
     */
    public void setMisp2XroadServiceMemberCode(String misp2XroadServiceMemberCodeNew) {
        this.misp2XroadServiceMemberCode = misp2XroadServiceMemberCodeNew;
    }

    /**
     * @return the misp2XroadServiceSubsystemCode
     */
    public String getMisp2XroadServiceSubsystemCode() {
        return misp2XroadServiceSubsystemCode;
    }

    /**
     * @param misp2XroadServiceSubsystemCodeNew the misp2XroadServiceSubsystemCode to set
     */
    public void setMisp2XroadServiceSubsystemCode(String misp2XroadServiceSubsystemCodeNew) {
        this.misp2XroadServiceSubsystemCode = misp2XroadServiceSubsystemCodeNew;
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
     * @return the xsltList
     */
    public List<Xslt> getXsltList() {
        return xsltList;
    }

    /**
     * @param xsltListNew the xsltList to set
     */
    public void setXsltList(List<Xslt> xsltListNew) {
        this.xsltList = xsltListNew;
    }

    /**
     * @return the producerList
     */
    public List<Producer> getProducerList() {
        return producerList;
    }

    /**
     * @param producerListNew the producerList to set
     */
    public void setProducerList(List<Producer> producerListNew) {
        this.producerList = producerListNew;
    }

    /**
     * @return the queryLogList
     */
    public List<OrgPerson> getQueryLogList() {
        return queryLogList;
    }
    
    /**
     * @param queryLogListNew the queryLogList to set
     */
    public void setQueryLogList(List<OrgPerson> queryLogListNew) {
        this.queryLogList = queryLogListNew;
    }

    /**
     * @return the portalNameList
     */
    public List<PortalName> getPortalNameList() {
        return portalNameList;
    }

    /**
     * @param portalNameListNew the portalNameList to set
     */
    public void setPortalNameList(List<PortalName> portalNameListNew) {
        this.portalNameList = portalNameListNew;
    }

    /**
     * @return X-Road instance list used by portal services
     */
    public List<XroadInstance> getServiceXroadInstanceList() {
        return serviceXroadInstanceList;
    }

    /**
     * @param serviceXroadInstanceListNew new X-Road instance list used by portal services
     */
    public void setServiceXroadInstanceList(List<XroadInstance> serviceXroadInstanceListNew) {
        this.serviceXroadInstanceList = serviceXroadInstanceListNew;
    }
    
    /**
     * @return list of PortalEula entities representing the same EULA in different languages for current portal.
     */
    public List<PortalEula> getPortalEulaList() {
        return portalEulaList;
    }

    /**
     * Set list of portal EULA translations.
     * @param portalEulaListNew list of PortalEula entities.
     */
    public void setPortalEulaList(List<PortalEula> portalEulaListNew) {
        this.portalEulaList = portalEulaListNew;
    }

    /**
     * @return list of Person-Eula associations pointing to users who have accepted or rejected portal's EULA.
     */
    public List<PersonEula> getPersonEulaList() {
        return personEulaList;
    }

    /**
     * @param personEulaListNew the personEulaList to set
     */
    public void setPersonEulaList(List<PersonEula> personEulaListNew) {
        this.personEulaList = personEulaListNew;
    }

    /**
     * @return true if mispType is organization, citizen or universal while having registerUnits true
     */
    public boolean isOpenPortal() {
        return this.getMispType() == Const.MISP_TYPE_ORGANISATION
                || this.getMispType() == Const.MISP_TYPE_UNIVERSAL && this.getRegisterUnits().booleanValue()
                || this.getMispType() == Const.MISP_TYPE_CITIZEN;
    }

    /**
     * Gets portal full string
     * @param language language
     * @return portal full string
     */
    public String getPortalFullString(String language) {
        StringBuilder sb = new StringBuilder(this.getActiveName(language));
        sb.append(" &#8226; ").append(this.getOrgId().getFullName(language));
        return sb.toString();
    }

    /**
     * Gets activeName in given language
     * @param language language
     * @return active name in given language, null if active name is not available in that language
     */
    public String getActiveName(String language) {
        Iterator<PortalName> iter = this.getPortalNameList().iterator();
        while (iter.hasNext()) {
            PortalName portalName = iter.next();
            if (portalName.getLang().equals(language))
                return portalName.getDescription();
        }
        return null;
    }

    /**
     * @return true, if EULA (end user license agreement) is in use for given portal, false if not
     */
    public Boolean getEulaInUse() {
        return eulaInUse;
    }

    /**
     * Switch on/off EULA acceptance dialog for portal users.
     * @param eulaInUse true, if EULA acceptance is required, false if EULA acceptance dialog is not shown
     */
    public void setEulaInUse(Boolean eulaInUse) {
        this.eulaInUse = eulaInUse;
    }

    /**
     * Compares short names
     * 
     * @param other object to compare this object to
     * @return true if objects are equal
     */
    public boolean equals(Object other) {
        if (this == other)
            return true;
        if (!(other instanceof Portal))
            return false;

        final Portal portal = (Portal) other;
        if (!portal.getShortName().equals(getShortName()))
            return false;
        return true;
    }

    /**
     * Calculates object hash
     * @see java.lang.Object#hashCode()
     * @return hash
     */
    public int hashCode() {
        int result;
        result = getShortName().hashCode();
        result = Const.PRIME_29 * result + getId();
        return result;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.Portal[id=" + getId() + "]";
    }

    /**
     * Check if portal X-Road protocol is v6
     * @return true if X-Road protocol is v6
     */
    public boolean isV6() {
        return xroadProtocolVer != null && xroadProtocolVer.equals(Const.XROAD_VERSION.V6.getProtocolVersion());
    }
    /**
     * Check if portal X-Road protocol is v5
     * @return true if X-Road protocol is v5
     */
    public boolean isV5() {
        return xroadProtocolVer == null || xroadProtocolVer.equals(Const.XROAD_VERSION.V5.getProtocolVersion());
    }

    /**
     * Check if portal X-Road protocol is v4
     * @return true if X-Road protocol is v4
     */
    public boolean isV4() {
        return xroadProtocolVer != null && xroadProtocolVer.equals(Const.XROAD_VERSION.V4.getProtocolVersion());
    }

    /**
     * Get X-Road version as int
     * @return X-Road version
     */
    public int getXroadVersionAsInt() {
        return getXroadVersion().getIndex();
    }

    /**
     * This method is in portal instead of XRoadUtil, because namespace is mostly derived from xroadProtocolVer
     * 
     * @return X-Road namespace according to X-Road protocol version
     */
    public String getXroadNamespace() {
        // Warning : if a use case arises, create database field xroad_namespace to portal table; right now general conf
        // seems sufficient
        if (isV6())
            return XROAD_VERSION.V6.getDefaultNamespace();
        if (isV5()) {
            String namespaceFromConfig = ConfigurationProvider.getConfig().getString("xrd.v5.namespace");
            return namespaceFromConfig != null ? namespaceFromConfig : XROAD_VERSION.V5.getDefaultNamespace();
        }
        if (isV4())
            return XROAD_VERSION.V4.getDefaultNamespace();
        throw new RuntimeException("Unknown xroadVersion " + xroadProtocolVer);
    }

    /**
     * Get X-Road version
     * @return X-Road version
     */
    public XROAD_VERSION getXroadVersion() {
        if (isV6())
            return XROAD_VERSION.V6;
        if (isV5())
            return XROAD_VERSION.V5;
        if (isV4())
            return XROAD_VERSION.V4;
        throw new RuntimeException("Unknown xroadVersion " + xroadProtocolVer);
    }
}
