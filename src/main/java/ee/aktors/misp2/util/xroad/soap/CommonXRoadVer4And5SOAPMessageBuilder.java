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

package ee.aktors.misp2.util.xroad.soap;

import javax.xml.soap.SOAPMessage;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Node;

import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;


/**
 * Utility to build X-Road SOAP query SOAPMessage - contains methods for header element initialization.
 * Has implementations (where X-Road SOAP request header tag names have been specified) in the same package.
 * The need for implementations comes from different X-Road versions.
 * X-Road version 5 defines different header tag names and different namespace to version 4, but the tag
 * names can be almost directly mapped from one version to another so the meaning is exactly the same.
 * 
 * @author sander.kallo
 *
 */
public abstract class CommonXRoadVer4And5SOAPMessageBuilder extends CommonXRoadSOAPMessageBuilder {
    protected Logger log = LogManager.getLogger(CommonXRoadVer4And5SOAPMessageBuilder.class);
    
    /**
     * Main constructor which should directly be called only by the implementing class constructor.
     * @param soapProtocol SOAP version as {@link javax.xml.soap.SOAPConstants} version string.
     * @param xmlNamespaceContainer XML namespace of X-Road header elements
     * @throws DataExchangeException when initialization fails
     */
    protected CommonXRoadVer4And5SOAPMessageBuilder(XMLNamespaceContainer xroadNamespace) throws DataExchangeException {
        super(xroadNamespace);
    }

    /**
     * Main constructor which should directly be called only by the implementing class constructor.
     * @param soapProtocol SOAP version as {@link javax.xml.soap.SOAPConstants} version string.
     * @param xmlNamespaceContainer XML namespace of X-Road header elements
     * @throws DataExchangeException when initialization fails
     */
    protected CommonXRoadVer4And5SOAPMessageBuilder(SOAPMessage soapMessage) throws DataExchangeException {
        super(soapMessage);
    }
    
    // Getters for XRad query header element names - have to implemented in child class
    protected abstract String getConsumerTagName();
    protected abstract String getProducerTagName();
    protected abstract String getUserIdTagName();
    protected abstract String getUserTagName();
    protected abstract String getServiceTagName();
    
    protected abstract String getIssueTagName();
    protected abstract String getUnitTagName();
    protected abstract String getPositionTagName();
    protected abstract String getAuthenticatorTagName();
    protected abstract String getUserNameTagName();
    
    protected abstract String getAsyncTagName();
    protected abstract String getEncodeTagName();
    

    // Getters for X-Road query header elements, uses element tag names
    
    @Override
    protected Node getUserId() throws DataExchangeException {
        return getHeaderField(getUserIdTagName());
    }
    @Override
    protected Node getQueryId() throws DataExchangeException {
        return getHeaderField(getQueryIdTagName());
    }
    
    /** Getters for header tag contents */
    // Implementations of #CommonXRoadSOAPMessageBuilder

    // standalone v4 and v5 component getters
    protected Node getIssue() throws DataExchangeException {
        return getHeaderField(getIssueTagName());
    }
    protected Node getUser() throws DataExchangeException {
        return getHeaderField(getUserTagName());
    }
    protected Node getConsumer() throws DataExchangeException {
        return getHeaderField(getConsumerTagName());
    }
    
    protected Node getProducer() throws DataExchangeException {
        return getHeaderField(getProducerTagName());
    }
    
    protected Node getService() throws DataExchangeException {
        return getHeaderField(getServiceTagName());
    }
    protected Node getUnit() throws DataExchangeException {
        return getHeaderField(getUnitTagName());
    }
    

    /**
     * Get issue SOAP header element value
     * @return issue element content
     * @throws DataExchangeException on element retrieval failure
     */
    public String getIssueValue() throws DataExchangeException {
        return XMLUtil.getElementValueSafely(getIssue());
    }
    
    /**
     * Get user SOAP header element value
     * @return user element content
     * @throws DataExchangeException on element retrieval failure
     */
    public String getUserValue() throws DataExchangeException {
        return XMLUtil.getElementValueSafely(getUser());
    }
    
    /**
     * Get consumer SOAP header element value
     * @return consumer element content
     * @throws DataExchangeException on element retrieval failure
     */
    public String getConsumerValue() throws DataExchangeException {
        return XMLUtil.getElementValueSafely(getConsumer());
    }
    
    /**
     * Get producer SOAP header element value
     * @return producer element content
     * @throws DataExchangeException on element retrieval failure
     */
    public String getProducerValue() throws DataExchangeException {
        return XMLUtil.getElementValueSafely(getProducer());
    }
    
    /**
     * Get service SOAP header element value
     * @return service element content
     * @throws DataExchangeException on element retrieval failure
     */
    public String getServiceValue() throws DataExchangeException {
        return XMLUtil.getElementValueSafely(getService());
    }
    
    /**
     * Get unit SOAP header element value
     * @return unit element content
     * @throws DataExchangeException on element retrieval failure
     */
    public String getUnitValue() throws DataExchangeException {
        return XMLUtil.getElementValueSafely(getUnit());
    }
    
    
    // Setters for X-Road query header elements, uses element tag names
    @Override
    public void setUserId(String s) throws DataExchangeException {
        setHeaderField(getUserIdTagName(), s);
    }
    @Override
    public void setQueryId(String s) throws DataExchangeException {
        setHeaderField(getQueryIdTagName(), s);
    }
    
    // standalone v4 and v5 component setters
    /**
     * Set issue SOAP header element value
     * @param issue new element content
     * @throws DataExchangeException on setting failure
     */
    public void setIssue(String issue) throws DataExchangeException {
        setHeaderField(getIssueTagName(), issue);
    }
    /**
     * Set user SOAP header element value
     * @param user new element content
     * @throws DataExchangeException on setting failure
     */
    public void setUser(String user) throws DataExchangeException {
        setHeaderField(getUserTagName(), user);
    }
    /**
     * Set consumer SOAP header element value
     * @param consumer new element content
     * @throws DataExchangeException on setting failure
     */
    public void setConsumer(String consumer) throws DataExchangeException {
        setHeaderField(getConsumerTagName(), consumer);
    }
    /**
     * Set producer SOAP header element value
     * @param producer new element content
     * @throws DataExchangeException on setting failure
     */
    public void setProducer(String producer) throws DataExchangeException {
        setHeaderField(getProducerTagName(), producer);
    }
    /**
     * Set service SOAP header element value
     * @param service new element content
     * @throws DataExchangeException on setting failure
     */
    public void setService(String service) throws DataExchangeException {
        setHeaderField(getServiceTagName(), service);
    }
    /**
     * Set unit SOAP header element value
     * @param unit new element content
     * @throws DataExchangeException on setting failure
     */
    public void setUnit(String unit) throws DataExchangeException {
        setHeaderField(getUnitTagName(), unit);
    }

    @Override
    public String getServiceSummary() throws DataExchangeException {
        return getServiceValue();
    }
    @Override
    public boolean hasService() throws DataExchangeException {
        return getServiceValue() != null && !getServiceValue().trim().isEmpty();
    }
}
