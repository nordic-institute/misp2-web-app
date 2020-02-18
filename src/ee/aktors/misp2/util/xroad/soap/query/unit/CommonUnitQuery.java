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

package ee.aktors.misp2.util.xroad.soap.query.unit;

import java.util.Iterator;

import javax.xml.namespace.QName;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.configuration.Configuration;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.beans.QueryBean;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.util.MISPUtils;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.query.AbstractMisp2XRoadQuery;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf.SingleQueryConf;
import ee.aktors.misp2.util.xroad.soap.XMLNamespaceContainer;

/**
 * Used for univ-portal and org-portal user registration and user unit validity
 * check queries. Contains common functionality for all the aforementioned
 * queries. Uses {@link UnitQueryConf} for X-Road configuration
 * reading for v6 and a separate configuration file for earlier versions.
 * 
 * @author sander.kallo
 *
 */
public abstract class CommonUnitQuery extends AbstractMisp2XRoadQuery {

    private static Logger logger = LogManager.getLogger(UnitCheckQuery.class);
    protected XMLNamespaceContainer bodyRootElementNamespace;

    protected String xroadInstance;
    protected String memberClass;
    protected String memberCode;
    protected String subsystemCode;
    protected String serviceCode;
    protected String serviceVersion;

    protected SingleQueryConf singleQueryConf;
    protected QueryBean queryBean;
    private XPath xpath;
    protected Configuration configuration;
    SOAPElement requestRootElement;

    /**
     * Initialize common unit query with configuration parameters and used Org.
     * Org needs to be a parameter, since in check unit query, user session org is not the one
     * we need to request validation for.
     * @param singleQueryConf query configuration for X-Road v6
     * @param org request organization unit
     * @param configuration X-Road v5 query configuration
     * @throws DataExchangeException on init error
     */
    public CommonUnitQuery(SingleQueryConf singleQueryConf, Org org, Configuration configuration)
            throws DataExchangeException {
        super(org);
        this.singleQueryConf = singleQueryConf; // object values read from
                                                // configuration file
        this.configuration = configuration; // for legacy X-Road (v4 and v5)
        queryBean = null;
        this.xpath = XPathFactory.newInstance().newXPath();
        this.requestRootElement = null;
        if (portal.isV6()) {
            if (singleQueryConf == null) {
                throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_HEADER_INIT_FAILED,
                        "Cannot perform X-Road v6 query. Query-description '" + portal.getUnivCheckQuery()
                                + "' was not found from configuration.",
                        null);
            }
            xroadInstance = singleQueryConf.getXroadInstance();
            memberClass = singleQueryConf.getMemberClass();
            memberCode = singleQueryConf.getMemberCode();
            subsystemCode = singleQueryConf.getSubsystemCode();
            serviceCode = singleQueryConf.getServiceCode();
            serviceVersion = singleQueryConf.getServiceVersion();
            bodyRootElementNamespace = new XMLNamespaceContainer(getBodyRootElementNamespacePrefix(),
                    singleQueryConf.getNamespace());
            setSOAPRequestBuilder(XRoadUtil.getXRoadSOAPMessageBuilder(portal));
        } else {
            String queryName = getXRoadV4Or5QueryName();
            queryBean = MISPUtils.parseQueryString(queryName);
            
            xroadInstance = null;
            memberClass = null;
            memberCode = queryBean.getProducerName();
            subsystemCode = null;
            serviceCode = queryBean.getQueryName();
            serviceVersion = queryBean.getVersion();
            // special case: X-Road message can be different from portal version
            // depending on conf
            setSOAPRequestBuilder(XRoadUtil.getXRoadSOAPMessageBuilder(getXRoadVersion()));
        }
    }

    protected abstract int getXRoadVersion();

    protected abstract String getXRoadV4Or5QueryName();


    @Override
    public String getServiceXRoadInstance() {
        return xroadInstance;
    }
    
    @Override
    public String getServiceMemberClass() {
        return memberClass;
    }

    @Override
    public String getServiceMemberCode() {
        return memberCode;
    }

    @Override
    public String getServiceSubsystemCode() {
        return subsystemCode;
    }

    @Override
    public String getServiceCode() {
        return serviceCode;
    }

    @Override
    public String getServiceVersion() {
        return serviceVersion;
    }

    protected String getBodyRootElementNamespacePrefix() {
        return "prod";
    }

    private String getVersionString() {
        int version = getXRoadVersion();
        String versionString = "v" + version;
        return versionString;
    }

    protected void setXRoadV5Namespace(String defaultCountryCode, String namespaceKey) {
        String versionString = getVersionString();
        final String producerNSformat = configuration.getString(versionString + namespaceKey);
        String bodyRootElementNamespaceUri = producerNSformat.replaceAll("#producer", queryBean.getProducerName())
                .replaceAll("#country", defaultCountryCode.toLowerCase());

        this.bodyRootElementNamespace = new XMLNamespaceContainer(getBodyRootElementNamespacePrefix(),
                bodyRootElementNamespaceUri);

    }

    protected String getXRoadV5RequestPath(String requestXPathKey) {
        String versionString = getVersionString();
        String requestPath = configuration.getString(versionString + requestXPathKey);
        if (requestPath == null || requestPath.isEmpty()) {
            logger.warn(versionString + requestXPathKey + " not set");
        }
        return requestPath;
    }

    @Override
    protected void initSOAPRequestBody() throws DataExchangeException {
        try {
            logger.debug("Initializing unit query '" + soapRequestBuilder.getServiceSummary() + "' request.");
            SOAPBody soapBody = soapRequestBuilder.getBody();
            requestRootElement = soapBody.addChildElement(getServiceCode(), bodyRootElementNamespace.getPrefix(),
                    bodyRootElementNamespace.getUri());
            initSOAPRequestParameters();
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_BODY_INIT_FAILED,
                    "X-Road request SOAP body could not be initialized.", e);
        }
    }

    /**
     * Override in child classes to fill SOAP request parameters. Use
     * {@link #addRequestElement(String requestPath, String requestValue)}
     * method to set parameter value in request.
     * 
     * @throws SOAPException
     */
    protected abstract void initSOAPRequestParameters() throws SOAPException, DataExchangeException;

    /**
     * Helper method enabling to add a nested element with a String-value in
     * X-Road SOAP request. If used twice or more, the method does not add
     * another element with the same name, if this element is already added in
     * SOAP request. For instance, setting xpath node1/node2 to 'a' and
     * node1/node3 to 'b' results in the following XML with only one node1.
     * &lt;node1&gt; &lt;node2&gt;a&lt;/node2&gt; &lt;node3&gt;b&lt;/node3&gt;
     * &lt;/node1&gt;
     * 
     * @param requestPath
     *            relative xpath describing the nested element structure
     *            starting from first node inside the X-Road request root
     *            element: SOAP-ENV:Envelope/SOAP-ENV:Body/serv:serviceName/[our
     *            xpath describes that part], e.g. request/unitCode
     * @param requestValue
     *            text content to be set to last #requestPath node.
     * @throws SOAPException
     */
    protected void addRequestElement(String requestPath, String requestValue) throws SOAPException {
        String[] nodeNames = requestPath.split("/");
        SOAPElement node = requestRootElement;
        for (int i = 0; i < nodeNames.length; i++) {
            QName qname = new QName(nodeNames[i]);
            SOAPElement childNode = null;
            Iterator<?> it = node.getChildElements(qname);
            while (it.hasNext()) {
                Object childObj = it.next();
                if (childObj instanceof SOAPElement) {
                    childNode = (SOAPElement) childObj;
                    break;
                }
            }
            if (childNode != null) {
                node = childNode;
            } else {
                node = node.addChildElement(qname);
            }
        }
        node.addTextNode(requestValue);
    }

    protected Object evaluateXpath(String path, Object item, QName returnType) throws XPathExpressionException {
        Object result = null;
        if (path != null && !path.isEmpty()) {
            result = xpath.evaluate(path, item, returnType);
        }
        return result;
    }
}
