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

import ee.aktors.misp2.util.LanguageUtil;
import java.util.Comparator;
import java.util.List;

import javax.persistence.Basic;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EntityResult;
import javax.persistence.FetchType;
import javax.persistence.FieldResult;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.apache.commons.lang.StringEscapeUtils;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.util.Const;

/**
 * query entity
 */
@SqlResultSetMapping(name = "QueryWithXform", entities = {
        @EntityResult(entityClass = Query.class),
        @EntityResult(entityClass = Xforms.class, fields = { @FieldResult(name = "id", column = "xform_id"),
                @FieldResult(name = "form", column = "form"), @FieldResult(name = "queryId", column = "query_id"),
                @FieldResult(name = "created", column = "created"),
                @FieldResult(name = "lastModified", column = "last_modified"),
                @FieldResult(name = "username", column = "username"), @FieldResult(name = "url", column = "url") }) })
@Entity
@Table(name = "query")
public class Query extends GeneralBean {

    private static final long serialVersionUID = 1L;
    @Transient
    private static final String NAME_SEPARATOR = ".";
    
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "query_id_seq")
    @SequenceGenerator(name = "query_id_seq", sequenceName = "query_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @Column(name = "type")
    private Integer type;
    @Column(name = "name", length = Const.LENGTH_50)
    private String name;
    @Column(name = "openapi_service_code", length = Const.LENGTH_256)
    private String openapiServiceCode;
    @JoinColumn(name = "producer_id", referencedColumnName = "id")
    @ManyToOne(fetch = FetchType.LAZY)
    private Producer producer;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "query", fetch = FetchType.LAZY)
    private List<QueryTopic> queryTopicList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "query", fetch = FetchType.LAZY)
    private List<QueryName> queryNameList;

    /**
     * Kui selle päringu näol on tegemist komplekspäringuga, siis siin talletuvad selle alampäringute nimed, mis
     * parsitakse XFORM xml-st.
     */
    @Column(name = "sub_query_names")
    private String subQueryNames;
    /**
     * This member is used when misp2 (not orbeon) performs programmatic X-Road request defined by this instance. It is
     * used for X-Road v6 loadClassification request body creation.
     */
    @Column(name = "xroad_request_namespace", length = Const.LENGTH_256)
    private String xroadRequestNamespace;


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
     * @return the type
     */
    public Integer getType() {
        return type;
    }

    /**
     * @param typeNew the type to set
     */
    public void setType(Integer typeNew) {
        this.type = typeNew;
    }

    /**
     * @return the name
     */
    public String getName() {
        return name;
    }
    
    /**
     * @see #getName()
     * @return HTML escaped name
     */
    public String getNameEscapeHtml() {
        return StringEscapeUtils.escapeHtml(getName());
    }

    /**
     * @param nameNew the name to set
     */
    public void setName(String nameNew) {
        this.name = nameNew;
    }

    /**
     * @return the producer
     */
    public Producer getProducer() {
        return producer;
    }

    /**
     * @param producerNew the producer to set
     */
    public void setProducer(Producer producerNew) {
        this.producer = producerNew;
    }


    /**
     * @return the queryTopicList
     */
    public List<QueryTopic> getQueryTopicList() {
        return queryTopicList;
    }

    /**
     * @param queryTopicListNew the queryTopicList to set
     */
    public void setQueryTopicList(List<QueryTopic> queryTopicListNew) {
        this.queryTopicList = queryTopicListNew;
    }

    /**
     * @return the queryNameList
     */
    public List<QueryName> getQueryNameList() {
        return queryNameList;
    }

    /**
     * @param queryNameListNew the queryNameList to set
     */
    public void setQueryNameList(List<QueryName> queryNameListNew) {
        this.queryNameList = queryNameListNew;
    }

    /**
     * @return the subQueryNames
     */
    public String getSubQueryNames() {
        return subQueryNames;
    }

    /**
     * @param subQueryNamesNew the subQueryNames to set
     */
    public void setSubQueryNames(String subQueryNamesNew) {
        this.subQueryNames = subQueryNamesNew;
    }

    /**
     * @return the xroadRequestNamespace
     */
    public String getXroadRequestNamespace() {
        return xroadRequestNamespace;
    }

    /**
     * @param xroadRequestNamespaceNew the xroadRequestNamespace to set
     */
    public void setXroadRequestNamespace(String xroadRequestNamespaceNew) {
        this.xroadRequestNamespace = xroadRequestNamespaceNew;
    }

    /**
     * @return the NAME_SEPARATOR
     */
    public String getNameSerparator() {
        return NAME_SEPARATOR;
    }

    /**
     * Gets activeName in given language
     * @param language language
     * @return active name in given language, null if active name is not available in that language
     */
    public QueryName getActiveName(String language) {
        for (QueryName qn : this.getQueryNameList()) {
            if (qn.getLang().equals(language)) {
                return qn;
            }
        }
        for (QueryName qn : this.getQueryNameList()) {
            if (qn.getLang().equals(LanguageUtil.ALL_LANGUAGES)) {
                return qn;
            }
        }
        return null;
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
        if (!(object instanceof Query)) {
            return false;
        }
        Query other = (Query) object;
        if (this.getId() == null && other.getId() != null
                || this.getId() != null && !this.getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.Query[id=" + getId() + "]";
    }

    public static final Comparator<Query> COMPARE_BY_QUERY_DESCRIPTION = new Comparator<Query>() {
        public int compare(Query one, Query other) {
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

    public static final Comparator<Query> COMPARE_BY_QUERY_SHORT_NAME = new Comparator<Query>() {
        public int compare(Query one, Query other) {
            String oneShortName = one.getName() != null ? one.getName() : "";
            String otherShortName = other.getName() != null ? other.getName() : "";
            if (oneShortName != null && otherShortName != null) {
                return oneShortName.trim().toUpperCase().compareTo(otherShortName.trim().toUpperCase());
            }
            return 0;
        }
    };

    public static final Comparator<Query> COMPARE_BY_PRODUCER_SHORT_NAME = new Comparator<Query>() {
        public int compare(Query one, Query other) {
            String oneShortName = one.getProducer() != null ? one.getProducer().getShortName() : "";

            String otherShortName = other.getProducer() != null ? other.getProducer().getShortName() : "";
            if (oneShortName != null && otherShortName != null) {
                return oneShortName.toUpperCase().compareTo(otherShortName.toUpperCase());
            }
            return 0;
        }
    };

    /**
     * Method to set query name in X-Road v6
     * @param serviceCode first part of name, mustn't be null
     * @param serviceVersion second part of name, if null wont be added
     */
    public void setName(String serviceCode, String serviceVersion) {
        this.name = serviceCode + (serviceVersion != null ? NAME_SEPARATOR + serviceVersion : "");
    }

    /**
     * @return serviceCode part of name
     */
    public String getServiceCode() {
        int separationPosition = this.name.lastIndexOf(NAME_SEPARATOR);
        if (separationPosition > 0)
            return this.name.substring(0, separationPosition);
        return this.name;
    }

    /**
     * @return serviceVersion part of name
     */
    public String getServiceVersion() {
        int separationPosition = this.name.lastIndexOf(NAME_SEPARATOR);
        if (separationPosition > 0 && separationPosition < this.name.length() - 1)
            return this.name.substring(separationPosition + 1, this.name.length());
        else
            return "";
    }

    /**
     * @return query full identifier
     */
    public String getFullIdentifier() {
        Portal portal = producer.getPortal();
        return getFullIdentifierByPortal(portal);
    }

    /**
     * @return query full identifier
     */
    public String getFullIdentifierByProtocol(Producer.ProtocolType protocolType) {
        return getFullIdentifier(producer.getPortal(), protocolType);
    }

    /**
     * Gets full identifier depending on portal X-Road version
     * @param portal portal
     * @return full identifier
     */
    public String getFullIdentifierByPortal(Portal portal) {
        return getFullIdentifier(portal, Producer.ProtocolType.SOAP);
    }

    /**
     * Gets full identifier depending on portal X-Road version
     * @param portal portal
     * @return full identifier
     */
    public String getFullIdentifier(Portal portal, Producer.ProtocolType protocolType) {
        if (portal.isV6() && producer.getMemberClass() != null) {
            String identifier = producer.getXroadInstance() + ":"
                    + producer.getMemberClass() + ":"
                    + producer.getShortName() + ":"
                    + producer.getSubsystemCode();

            if (Producer.ProtocolType.REST.equals(protocolType)) {
                identifier += ":" + getOpenapiServiceCode();
            }
            identifier += ":" + getServiceCode();
            String serviceVersion = getServiceVersion();
            if (serviceVersion != null && !serviceVersion.isEmpty()) {
                identifier = identifier + ":" + serviceVersion;
            }
            return  identifier;
        } else {
            return producer.getShortName() + "." + name;
        }
    }

    public String getOpenapiServiceCode() {
        return openapiServiceCode;
    }

    public void setOpenapiServiceCode(String openapiServiceCode) {
        this.openapiServiceCode = openapiServiceCode;
    }
}
