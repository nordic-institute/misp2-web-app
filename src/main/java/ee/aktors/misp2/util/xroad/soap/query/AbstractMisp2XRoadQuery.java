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

package ee.aktors.misp2.util.xroad.soap.query;

import java.net.URL;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.ServletActionContext;
import org.springframework.context.ApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.service.XroadInstanceService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.CommonXRoadVer4And5SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad6SOAPMessageBuilder;

/**
 * Adds X-Road request SOAP headers, such as client and unit, from MISP2 user
 * session. Also picks X-Road message builder type based on the portal used.
 * Creates abstract service data fields, those need to be implemented by child
 * classes.
 * 
 * @author sander.kallo
 *
 */
public abstract class AbstractMisp2XRoadQuery extends AbstractXRoadQuery {

    private static Logger log = LogManager.getLogger(AbstractMisp2XRoadQuery.class);

    protected Portal portal;
    protected Org org;
    protected Person user;

    private XroadInstanceService xroadInstanceService;

    protected AbstractMisp2XRoadQuery() throws DataExchangeException {
        super(null);
        init(false, null);
        setSOAPRequestBuilder(XRoadUtil.getXRoadSOAPMessageBuilder(portal));
        if (log.isTraceEnabled()) {
            log.trace(user + " initialized X-Road query with default org " + org + ".");
        }
    }

    protected AbstractMisp2XRoadQuery(Org org) {
        super(null);
        init(true, org);
        if (log.isTraceEnabled()) {
            log.trace(user + " initialized X-Road query with org " + org + ".");
        }
    }

    private void init(boolean useOrgNew, Org orgNew) {
        Map<String, Object> session = ActionContext.getContext().getSession();
        this.portal = (Portal) session.get(Const.SESSION_PORTAL);
        this.user = (Person) session.get(Const.SESSION_USER_HANDLE);

        ApplicationContext context =
                WebApplicationContextUtils.getWebApplicationContext(ServletActionContext.getServletContext());
        this.xroadInstanceService = (XroadInstanceService) context.getBean("xroadInstanceService");
        
        if (useOrgNew) {
            this.org = orgNew;
        } else if (portal.getUnitIsConsumer() != null && portal.getUnitIsConsumer().booleanValue()) {
            this.org = (Org) session.get(Const.SESSION_ACTIVE_ORG);
        } else {
            this.org = portal.getOrgId();
        }
        
        setSecurityServerUrl(portal.getMessageMediator());
    }

    protected String getUserId() {
        return user.getSsn();
    }

    protected String getOrganizationCode() {
        return org.getCode();
    }

    /**
     * Needs to be overridden to initialize
     * 
     * @throws SOAPException
     */
    @Override
    protected void initSOAPRequestHeader() throws DataExchangeException {
        if (user != null) {

            if (getUserId() == null) {
                throw new DataExchangeException(DataExchangeException.Type.XROAD_USER_PERSONAL_CODE_MISSING,
                        "User " + user.getGivenname() + " SSN missing during SOAP header initialization", null);
            }
            if (getOrganizationCode() == null) {
                throw new DataExchangeException(DataExchangeException.Type.XROAD_USER_ORGANIZATION_CODE_MISSING,
                        "User selected organization code was missing in AptusBaseUser during "
                        + "SOAP header initialization.",
                        null);
            }

            soapRequestBuilder.setUserId(getUserId());
            soapRequestBuilder.setQueryId(XRoadUtil.getXRoadRequestId());

            if (soapRequestBuilder instanceof XRoad6SOAPMessageBuilder) {
                XRoad6SOAPMessageBuilder ver6MessageBuilder = (XRoad6SOAPMessageBuilder) soapRequestBuilder;
                ver6MessageBuilder.setServiceXRoadInstance(getServiceXRoadInstance());
                ver6MessageBuilder.setServiceMemberClass(getServiceMemberClass());
                ver6MessageBuilder.setServiceMemberCode(getServiceMemberCode());
                ver6MessageBuilder.setServiceSubsystemCode(getServiceSubsystemCode());
                ver6MessageBuilder.setServiceCode(getServiceCode());
                ver6MessageBuilder.setServiceVersion(getServiceVersion());

                String xroadInstance = portal.getClientXroadInstance();
                ver6MessageBuilder.setClientXRoadInstance(xroadInstance);
                ver6MessageBuilder.setClientMemberClass(org.getMemberClass());
                ver6MessageBuilder.setClientMemberCode(org.getCode());
                ver6MessageBuilder.setClientSubsystemCode(org.getSubsystemCode());

            } else if (soapRequestBuilder instanceof CommonXRoadVer4And5SOAPMessageBuilder) {
                CommonXRoadVer4And5SOAPMessageBuilder ver4And5MessageBuilder =
                        (CommonXRoadVer4And5SOAPMessageBuilder) soapRequestBuilder;
                String producer = getXRoad5Producer();
                if (producer == null || producer.isEmpty()) {
                    throw new DataExchangeException(DataExchangeException.Type.XROAD_PRODUCER_MISSING,
                            "Cannot assemble X-Road request, because X-Road producer missing", null);
                }
                ver4And5MessageBuilder.setService(getXRoad5Service());
                ver4And5MessageBuilder.setProducer(producer);
                ver4And5MessageBuilder.setIssue(getIssue());
                ver4And5MessageBuilder.setConsumer(getOrganizationCode());
            }
        }
    }
    
    /**
     * Wraps around {@link AbstractXRoadQuery#sendRequest()}: first checks that service X-Road instance is valid,
     * then executes request.
     * @throws DataExchangeException in case service X-Road instance is not valid,
     *  also when super.sendRequest() fails
     * @see {@link AbstractXRoadQuery#sendRequest()}
     */
    @Override
    public void sendRequest() throws DataExchangeException {
        if (soapRequestBuilder instanceof XRoad6SOAPMessageBuilder) {
            String xroadInstanceCode = getServiceXRoadInstance();
            if (xroadInstanceService.getActiveXroadInstanceCode(xroadInstanceCode) == null) {
                // active instance not found
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_INSTANCE_NOT_ACTIVE_FOR_PORTAL, "X-Road instance '"
                                + xroadInstanceCode + "' is not active in portal '" + portal.getShortName() + "'.",
                        null, xroadInstanceCode, portal.getShortName());
            }
        }
        super.sendRequest();
    }

    /**
     * Needs to be implemented by child classes.
     * The method return value is used in X-Road v6 request xrd:service/iden:xRoadInstance field.
     * In case of X-Road v5 service, the parameter is not used and null is recommended to be returned;
     * @return service member class
     */
    public abstract String getServiceXRoadInstance();

    /**
     * Needs to be implemented by child classes.
     * The method return value is used in X-Road v6 request xrd:service/iden:memberClass field.
     * In case of X-Road v5 service, the parameter is not used and null is recommended to be returned;
     * @return service member class
     */
    public abstract String getServiceMemberClass();

    /**
     * Needs to be implemented by child classes.
     * The method return value is used:
     *  a) in X-Road v6 request as xrd:service/iden:memberCode field value
     *  b) in X-Road v5 request as xrd:producer field value
     *  c) in X-Road v4 request as xtee:andmekogu field value
     * @return service member code
     */
    public abstract String getServiceMemberCode();

    /**
     * Needs to be implemented by child classes.
     * The method return value is used in X-Road v6 request xrd:service/iden:subsystemCode field.
     * In case of X-Road v5 service, the parameter is not used and null is recommended to be returned;
     * @return service member subsystem code
     */
    public abstract String getServiceSubsystemCode();

    /**
     * Needs to be implemented by child classes.
     * The method return value is used:
     *  a) in X-Road v6 request as xrd:service/iden:serviceCode field value
     *  b) in X-Road v5 request as xrd:service field
     *     (only service name without without service version or producer name -> producer.[serviceCode].version)
     *  c) in X-Road v4 request as xtee:nimi field
     *     (only service name without without service version or producer name -> producer.[serviceCode].version)
     * @return service code
     */
    public abstract String getServiceCode();
    /**
     * Needs to be implemented by child classes.
     * The method return value is used:
     *  a) in X-Road v6 request as xrd:service/iden:serviceVersion field value
     *  b) in X-Road v5 request as xrd:service field
     *     (only service version without service name or producer name -> producer.name.[serviceVersion])
     *  c) in X-Road v4 request as xtee:nimi field
     *     (only service version without service name or producer name -> producer.name.[serviceVersion])
     * @return service version
     */
    public abstract String getServiceVersion();

    /**
     * @return service summary in X-Road v5 xrd:service tag content format
     */
    public String getXRoad5Service() {
        String version = getServiceVersion();
        return getServiceMemberCode() + "." + getServiceCode() + (StringUtils.isNotEmpty(version) ? "." + version : "");
    }
    /**
     * @return producer name as added to X-Road v5 xrd:producer tag
     */
    public String getXRoad5Producer() {
        return getServiceMemberCode();
    }

    /**
     * Default issue is null, override if setting issue is necessary.
     * @return issue
     */
    public String getIssue() {
        return null;
    }

    @Override
    protected URL getEndpointUrl() throws DataExchangeException {
        return XRoadUtil.getMetaServiceEndpointUrlWithTimeouts(getSecurityServerUrl());
    }
}
