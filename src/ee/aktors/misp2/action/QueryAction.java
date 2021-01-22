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

package ee.aktors.misp2.action;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.action.exception.QueryException;
import ee.aktors.misp2.action.exception.Translatable;
import ee.aktors.misp2.beans.Auth.AUTH_TYPE;
import ee.aktors.misp2.flash.FlashUtil;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.*;
import ee.aktors.misp2.model.Producer.ProtocolType;
import ee.aktors.misp2.service.QueryService;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.servlet.mediator.MediatorServlet;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Const.QUERY_TYPE;
import ee.aktors.misp2.util.Const.XROAD_VERSION;
import ee.aktors.misp2.util.WSDLParser;
import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.openapi.OpenApiParser;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.rest.model.ListMethodsResponse;
import ee.aktors.misp2.util.xroad.rest.query.GetOpenApiQuery;
import ee.aktors.misp2.util.xroad.soap.query.meta.ListMethodsQuery;
import ee.aktors.misp2.util.xroad.soap.wsdl.WsdlContainer;
import ee.aktors.misp2.util.xroad.soap.wsdl.XRoadV6WsdlCollector;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.StrutsStatics;
import org.xml.sax.SAXParseException;

import javax.servlet.http.HttpServletRequest;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.*;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

/**
 */
public class QueryAction extends QuickTipAction {
    private static final long serialVersionUID = 1L;
    private static final Logger LOG = LogManager.getLogger(QueryAction.class);
    private QueryService qService;
    private UserService uService;
    private List<Query> queries;
    private List<Query> orgQueries;
    private List<OrgQuery> unitsAllowedQueries;
    private List<Producer> producers;
    private List<Xforms> xformsList;
    private LinkedHashSet<String> openapiServiceCodes;
    private Query query;
    private Xforms xforms;
    private Producer producer;
    private QueryName queryName;
    private Xslt xslt;
    private Integer id;
    private Integer qId;
    private TreeMap<String, Boolean> statesOfUpdatesMap;
    private String xformsGroup;
    private String next;
    private String formHtml;
    private String userMail;
    private String queryId;
    private String queryNote;
    private String wsdlURL;
    private String repositoryUrl;
    private String queryUUID;
    private String xmlDebug;
    private List<Query> missingQueries;
    private String restQueryForm; // holds REST query form in case query is REST query
    private ServiceDescriptionSource wsdlSource;
    private File sourceFile;
    private String sourceFileContentType;
    private String sourceFileFileName;
    /**
     * Default: {@link ProtocolType#SOAP}
     * Determines active tab in {@link ee.aktors.misp2.interceptor.MenuInterceptor#intercept}
     */
    private ProtocolType protocol;
    private boolean updateAllXForms;
    private List<Query> foundQueries;
    private boolean securityServerAllAllowed;
    private String openapiServiceCode;


    private boolean isRootContext() {
        HttpServletRequest request = ServletActionContext.getRequest();
        // if request is in root context, set rootContext flag to 'true'.
        if (request != null) {
            String contextPath = request.getContextPath();
            if (contextPath == null || contextPath.equals("")) {
                LOG.trace("QueryAction request runs in root context");
                return true;
            } else {
                LOG.trace("QueryAction request runs in " + contextPath + " context");
            }
        }
        return false;
    }

    /**
     * @param qService qService to inject
     * @param uService uService to inject
     */
    public QueryAction(QueryService qService, UserService uService) {
        this.qService = qService;
        this.uService = uService;
    }

    @Override
    public void prepare() throws Exception {
        super.prepare();
        protocol = protocol == null ? ProtocolType.SOAP : protocol;
        org = qService.reAttach(org, Org.class);
        user = qService.reAttach(user, Person.class);
        PersonMailOrg pmo = null;
        if (getPortal().getMispType() == Const.MISP_TYPE_CITIZEN) { // in citizen portal personMailOrg.orgId is null
            for (PersonMailOrg p : user.getPersonMailOrgList()) {
                if (p.getOrgId() == null) {
                    setUserMail(p.getMail());
                    break;
                }
            }
        } else {
            pmo = uService.findPersonMailOrg(user.getId(), org.getId());
            if (pmo != null) {
                setUserMail(pmo.getMail());
            }
        }
        if (protocol == ProtocolType.REST) {
            openapiServiceCodes = new LinkedHashSet<String>();
        } else {
            openapiServiceCodes = null;
        }
    }

    /**
     * Update services from selected source
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String updateServicesList() throws DataExchangeException {
        recoverOrStoreSourceFile();
        switch (wsdlSource) {
            case SECURITY_SERVER:
                if(portal.isV6()) {
                    next = isSecurityServerAllAllowed() ? Const.XROAD_V6_LIST_ALLOWED_METHODS_FROM_SECURITY_SERVER : Const.XROAD_V6_LIST_ALL_METHODS_FROM_SECURITY_SERVER;
                } else {
                    next = Const.XROAD_V5_LIST_ALLOWED_METHODS_FROM_SECURITY_SERVER;
                }
                return getAllowedMethods();
            case WSDL_URL:
                next = Const.XROAD_LIST_ALL_METHODS_FROM_WSDL;
                return getAllowedMethods();
            case FILE_UPLOAD:
                return updateProcedureFromFile(getId(), getSourceFile());
            case SERVICE_URLS:
                return ERROR;
        }

        return ERROR;
    }

	/**
	 * Update service xforms from selected source
	 */
	@HTTPMethods(methods = { HTTPMethod.POST })
	public String updateServicesXFrom() throws DataExchangeException {
		recoverOrStoreSourceFile();
		switch (getWsdlSource()) {
			case SECURITY_SERVER:
				wsdlURL = null;
				next = Const.XROAD_V6_GENERATE_XFORMS_FROM_SECURITY_SERVER;
				return listQueries();
			case FILE_UPLOAD:
				return updateXFromsFromFile();
			case WSDL_URL:
				next = Const.GENERATE_XFORMS;
				return listQueries();
			case SERVICE_URLS:
				next = "update";
				return listQueries();

        }
        return ERROR;
    }

    /**
     * @return SUCCESS
     * @throws DataExchangeException can throw
     */
    @HTTPMethods(methods = { HTTPMethod.GET, HTTPMethod.POST })
    public String listQueries() throws DataExchangeException {
        setProducer(qService.findObject(Producer.class, getId()));

        if(getProducer() == null || !protocol.equals(getProducer().getProtocol())) {
            addActionError(getText("producer.error.notFound", Arrays.asList(getId().toString(), protocol)));
            setProducer(null);
            return "input";
        }

        if (!portal.isV6() && StringUtils.isEmpty(getProducer().getWsdlURL())) {
            getProducer().setWsdlURL(
                    getPortal().getSecurityHost() + (getPortal().getSecurityHost().endsWith("/") ? "" : "/")
                            + "cgi-bin/uriproxy?producer=" + getProducer().getShortName());
        }
        if (StringUtils.isEmpty(getProducer().getRepositoryUrl())) {
            getProducer().setRepositoryUrl(
                    getPortal().getSecurityHost() + (getPortal().getSecurityHost().endsWith("/") ? "" : "/")
                            + "cgi-bin/uriproxy?service=");
        }
        setXformsList(qService.findXFormsByProducer(getProducer()));
        setQueries(qService.findQueriesByProducer(getProducer(), getProtocol()));
        setOrgQueries(qService.findOrgQueriesByOrgAndProducer(org, getProducer()));
        if (org.getId().intValue() == getPortal().getOrgId().getId().intValue()
                && getPortal().getMispType() == Const.MISP_TYPE_UNIVERSAL && getPortal().getUnitIsConsumer()) {
            setUnitsAllowedQueries(qService.findAllowedQueriesInSubOrgs(org, getPortal(), getProducer()));
        }

        HttpServletRequest req = (HttpServletRequest) ActionContext.getContext().get(StrutsStatics.HTTP_REQUEST);
        if (req.getMethod().equals("POST")) {
            try {
                if (getXformsGroup() != null) {


                    if (getNext() != null
                            && (getNext().equals(Const.GENERATE_XFORMS)
                            || getNext().equals(Const.XROAD_V6_GENERATE_XFORMS_FROM_SECURITY_SERVER))) {
                        if (StringUtils.isNotBlank(getWsdlURL())) {
                            getProducer().setWsdlURL(getWsdlURL());
                            qService.save(getProducer());
                        }

                        TreeMap<String, Boolean> statesMap = new TreeMap<>();
                        String xFormsGeneratedLabel = getText("services.show.list.url.xform_generated") + " "
                                + (new SimpleDateFormat(getText("datetimeformat"))).format(new Date());
                        if (getNext().equals(Const.XROAD_V6_GENERATE_XFORMS_FROM_SECURITY_SERVER)) {
                            switch (protocol) {
                                case SOAP:
                                    statesMap = qService.updateDescriptionsFromSecurityServerV6(
                                        getXformsGroup(), getProducer(), xFormsGeneratedLabel,
                                        CONFIG.getString("misp2.internal.url"));
                                    break;
                                case REST:
                                    statesMap = qService.updateOpenApiDescriptionsFromSecurityServer(
                                        getProducer(), getXformsGroup(), xFormsGeneratedLabel);
                                    break;
                            }
                        } else {
                            switch (protocol){
                                case SOAP:
                                    statesMap = qService.updateDescriptions(
                                            null, getXformsGroup(), getProducer(),
                                            xFormsGeneratedLabel, CONFIG.getString("misp2.internal.url"));
                                    break;
                                case REST:
                                    if(StringUtils.isBlank(getOpenapiServiceCode())) {
                                        return getUpdateProducerResultMessage("ERROR_SERVICE_CODE_MISSING", null, null);
                                    } else {
                                        statesMap = qService.updateOpenApiDescriptions(
                                                new OpenApiParser(new URI(wsdlURL)), getXformsGroup(),
                                                xFormsGeneratedLabel, getOpenapiServiceCode());
                                    }
                                    break;
                            }
                        }
                        setStatesOfUpdatesMap(statesMap);
                    } else {
                        if (StringUtils.isNotBlank(getRepositoryUrl())) {
                            getProducer().setRepositoryUrl(getRepositoryUrl());
                            qService.save(getProducer());
                        }
                        switch (protocol) {
                            case SOAP:
                                setStatesOfUpdatesMap(qService.updateDescriptions(getXformsGroup(),
                                        CONFIG.getString("misp2.internal.url")));
                                break;
                            case REST:
                                if(StringUtils.isBlank(getOpenapiServiceCode())) {
                                    return getUpdateProducerResultMessage("ERROR_SERVICE_CODE_MISSING", null, null);
                                } else {
                                    setStatesOfUpdatesMap(qService.updateOpenApiDescriptions(null, getXformsGroup(),
                                            null, getOpenapiServiceCode()));
                                }
                                break;
                        }
                    }

                    for (Map.Entry<String, Boolean> entry : statesOfUpdatesMap.entrySet()) {
                        String updatedQuery = entry.getKey();
                        Boolean updateSuccessful = entry.getValue();
                        if (updateSuccessful) {
                            addActionMessage(getText("xforms.note_refreshed." + protocol) + " (" + updatedQuery + ")");
                        } else {
                            addActionError(getText("xforms.error_not_refreshed." + protocol) + " (" + updatedQuery + ")");
                        }
                    }
                }
            } catch (QueryException | DataExchangeException | URISyntaxException e) {
                LOG.error("Generating xforms in listQuery() failed.", e);
                addActionError(getText("xforms.error_not_refreshed." + protocol) + getErrorSummary(e));
                return Action.SUCCESS;
            }
        }
        return Action.SUCCESS;

    }

    private String getErrorSummary(Exception e) {
        String faultTranslation = "";
        // add translation if it exists
        if (e instanceof Translatable) {
            Translatable eTranslatable = (Translatable)e;
            String translationCode = eTranslatable.getTranslationCode();
            if (hasKey(translationCode)) {
                faultTranslation = " " + getText(translationCode, eTranslatable.getParameters());
            }
        }
        // add fault summary if it exists
        String faultSummary = "";
        if (e.getCause() instanceof DataExchangeException) {
            faultSummary = ((DataExchangeException) (e.getCause())).getFaultSummary();
        } else if (e instanceof DataExchangeException && ((DataExchangeException)e).hasFault()) {
            faultSummary = ((DataExchangeException)e).getFaultSummary();
        }
        return faultTranslation + faultSummary;

    }

    /**
     * xforms'i redigeerimiseks
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String editXforms() {
        try {
            if (id != null) {
                setXforms(qService.findObject(Xforms.class, id));
                setQuery(getXforms().getQuery());
                setProducer(getXforms().getQuery().getProducer());
                QueryName qn = getQuery().getActiveName(getLocale().getLanguage());
                if (qn != null) {
                    setQueryName(qn);
                    queryNote = qn.getQueryNote();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return Action.SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String saveXforms() {
        try {
            if (getXforms().getQuery().getId() != null) {
                setQuery(qService.findObject(Query.class, getXforms().getQuery().getId()));
            }
            getXforms().setQuery(getQuery());
            // apply subquery extraction to XForms complex queries and all REST queries
            if (getQuery().getType() == QUERY_TYPE.X_ROAD_COMPLEX.ordinal()
                    || query.getProducer().getProtocol() == Producer.ProtocolType.REST) {
                qService.addSubQueryNames(getQuery(), getXforms());
            }

            getXforms().setUrl(
                    getText("services.show.list.url.xform_saved") + " "
                            + (new SimpleDateFormat(getText("datetimeformat"))).format(new Date()));
            qService.save(getXforms());
            QueryName qn = getQuery().getActiveName(getLocale().getLanguage());
            setProducer(getXforms().getQuery().getProducer());
            if (qn != null) {
                qn.setQueryNote(queryNote);
                qService.save(qn);
            }
            addActionMessage(getText("text.success.save") + " ");
        } catch (Exception e) {
            e.printStackTrace();
            addActionError(getText("text.fail.save"));
        }
        return Action.SUCCESS;
    }

    /**
     * @return  "remove" when producer has queries, SUCCESS if producer doesn't have queries, ERROR otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String getAllowedMethods() {
        String updated = "";
        String additionalErrorInfo = "";
        List<Query> foundQueries = null;

        setProducer(qService.findObject(Producer.class, getId()));
        getProducer().setWsdlURL(getWsdlURL());

        if (StringUtils.isNotBlank(getProducer().getWsdlURL())) {
            qService.save(producer);
        }

        // TODO Unit query like in the next block
        try {
            ListMethodsQuery.Type type = null;
            String xroadMethodRefreshActionType = getNext();

            if (xroadMethodRefreshActionType.equals(Const.XROAD_V6_LIST_ALLOWED_METHODS_FROM_SECURITY_SERVER)) {
                type = ListMethodsQuery.Type.ALLOWED_METHODS;
            } else if (xroadMethodRefreshActionType.equals(Const.XROAD_V6_LIST_ALL_METHODS_FROM_SECURITY_SERVER)) {
                type = ListMethodsQuery.Type.LIST_METHODS;
            }

            LOG.info("Updating service method list for producer " + producer + " ");

            // allowed methods from security server
            if (portal.isV6() && type != null || !portal.isV6()
                    && getNext().equals(Const.XROAD_V5_LIST_ALLOWED_METHODS_FROM_SECURITY_SERVER)) {
                boolean unitIsConsumer = getPortal().getMispType() == Const.MISP_TYPE_UNIVERSAL
                        && org.getId().intValue() == getPortal().getOrgId().getId().intValue()
                        && getPortal().getUnitIsConsumer();

                switch (protocol) {
                    case SOAP:
                        String wsdlUrl = portal.isV6() ? null : getProducer().getWsdlURL();


                        if (!unitIsConsumer) {
                            LOG.info("Querying methods for org (unit is not consumer) " + org);
                            foundQueries = qService.getMethodsFromSecurityServer(type, producer);
                            updated = updateAllowedMethods(foundQueries, producer, org, wsdlUrl);
                            if (type != null && type.equals(ListMethodsQuery.Type.LIST_METHODS)
                                    && updated != null && updated.equals("NO_ALLOWED")) {
                                updated = "NO_METHODS";
                            }
                        } else { // universal portal with units and unit is consumer enabled
                            LOG.info("Querying methods for org (unit is consumer) " + org);
                            List<Org> orgList;
                            try {
                                orgList = qService.reAttach(org, Org.class).getOrgList();
                                foundQueries = new ArrayList<>();
                                for (Org o : orgList) { // for each unit a soap request for allowed methods is made

                                    // FIXME use current organization o
                                    List<Query> allowedMethods = qService.getMethodsFromSecurityServer(type, getProducer(), o);
                                    foundQueries.addAll(allowedMethods);
                                    updated = updateAllowedMethods(allowedMethods, getProducer(), o, wsdlUrl);
                                    String orgName = o.getActiveName(getLocale().getLanguage());
                                    if (updated.equals("ERROR")) {
                                        addActionError(orgName + " (" + o.getCode() + "): "
                                                + getText("queries.note.not_updated"));
                                    } else if (updated.equals("NO_ALLOWED")) {
                                        addActionMessage(orgName + " (" + o.getCode() + "): "
                                                + getText("queries.note.no_allowed"));
                                    } else if (updated.equals("NO_METHODS")) {
                                        addActionMessage(orgName + " (" + o.getCode() + "): "
                                                + getText("queries.note.no_methods"));
                                    } else {
                                        addActionMessage(orgName + " (" + o.getCode() + "): "
                                                + getText("queries.note.updated"));
                                    }
                                }
                                updated = "UNIV_OK";
                            } catch (Exception e) {
                                updated = "ERROR";
                                additionalErrorInfo = getErrorSummary(e);
                                LOG.error("Error querying methods.", e);
                            }
                        }
                        break;
                    case REST:
                        foundQueries = new ArrayList<>();
                        ee.aktors.misp2.util.xroad.rest.query.ListMethodsQuery listMethodsQuery =
                            new ee.aktors.misp2.util.xroad.rest.query.ListMethodsQuery(producer);
                        List<ListMethodsResponse.QueryInfo> queryInfos = listMethodsQuery.fetchQueries(isSecurityServerAllAllowed());

                        for(ListMethodsResponse.QueryInfo queryInfo: queryInfos) {
                            String serviceCode = queryInfo.getServiceCode();
                            try {
                                GetOpenApiQuery getOpenApiQuery = new GetOpenApiQuery(producer);
                                OpenApiParser openApiParser = getOpenApiQuery.fetchOpenApi(serviceCode);
                                if(openApiParser != null) {
                                    List<Query> queries = openApiParser.parseQueryList(getProducer(), serviceCode);
                                    qService.saveQueries(queries, org);
                                    qService.saveDescriptions(openApiParser, getProducer(), null, serviceCode);
                                    foundQueries.addAll(queries);
                                }
                            } catch (DataExchangeException e) {
                                String message = String.format("Query '%s' does not have openApi", serviceCode);
                                LOG.debug(message, e);
                            }
                        }

                        break;
                }



            } else if (!portal.isV6() || portal.isV6()
                    && xroadMethodRefreshActionType.equals(Const.XROAD_LIST_ALL_METHODS_FROM_WSDL)) {
                try {
                    String wsdlUrl = getProducer().getWsdlURL();
                    if (StringUtils.isNotBlank(wsdlUrl)) {
                        LOG.info("Querying methods from " + protocol+ " " + wsdlUrl);

                        switch (protocol) {
                            case SOAP:
                                foundQueries = qService.getMethodsFromWSDL(getProducer());
                                updated = updateAllowedMethods(foundQueries, getProducer(), org, wsdlUrl);
                                break;
                            case REST:
                                OpenApiParser parser = new OpenApiParser(new URI(wsdlUrl));
                                if(StringUtils.isBlank(getOpenapiServiceCode())) {
                                    updated = "ERROR_SERVICE_CODE_MISSING";
                                } else {
                                    foundQueries = parser.parseQueryList(getProducer(), getOpenapiServiceCode());
                                    updated = updateAllowedMethods(foundQueries, getProducer(), org, wsdlUrl);
                                }
                                break;
                        }
                    } else {
                        updated = "ERROR_WSDL_URL_MISSING";
                    }
                } catch (QueryException e) {
                    LOG.error("Updating method lists failed.", e);
                    if (e.getCause() instanceof IOException) {
                        updated = "ERROR_WSDL_STATUS";
                        LOG.error("WSDL not accessible.", e);
                    } else if (e.getCause() instanceof SAXParseException) {
                        updated = "ERROR_WSDL_SYNTAX";
                        LOG.error("WSDL parsing failed.", e);
                    } else {
                        updated = "ERROR";
                        additionalErrorInfo = getErrorSummary(e);
                        LOG.error("Failed to process WSDL.", e);
                    }
                }
            } else {
                throw new RuntimeException("Unknown method list refresh type; next: " + xroadMethodRefreshActionType);
            }
        } catch (DataExchangeException e) {
            LOG.error("updateAllowedMethods failed with DataExchangeException", e);
            addActionError(getText("queries.note.not_updated") + getErrorSummary(e));
            return Action.ERROR;
        } catch (Exception e) {
            updated = "ERROR";
            additionalErrorInfo = getErrorSummary(e);
            LOG.error("updateAllowedMethods failed unexpectedly ", e);
        }
        this.foundQueries = foundQueries;
        return getUpdateProducerResultMessage(updated, additionalErrorInfo, foundQueries);
    }

    /**
     * Removes queries from producer that don't exist on the updated source
     * ie. WSDL got changed
     * @return SUCCESS
     */
    @SuppressWarnings("unchecked")
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String removeMissingQueries() {
        missingQueries = (List<Query>) session.remove("missingQueries");
        if (missingQueries != null) {
            for (Query q : missingQueries) {
                LOG.debug("removing old query: " + q.getName());
                qService.remove(q);
            }
        }

        addActionMessage(getText("queries.note.missing_removed"));
        return SUCCESS;
    }

    /**
     * 0. write xforms to the temporary file run%serviceName-id%.jsp 1. apply global xsls 2. apply local xsls 3. show
     * transformed xhtml to user
     * @return ERROR if form is missing or if executed query is not allowed, SUCCESS otherwise
     * @throws Exception can throw
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String executeXforms() throws Exception {
        if (id != null) {
            Xforms temp = qService.findXformEntityByQuery(id);
            setQuery(qService.findObject(Query.class, id));
            setQueryName(query.getActiveName(getLocale().getLanguage()));
            HttpServletRequest request = ServletActionContext.getRequest();
            String basepath = CONFIG.getString("misp2.internal.url") + request.getContextPath();
            if (temp.getForm() == null || temp.getForm().equals("")) {
                addActionError(getText("services.no_description." + protocol));
                return Action.ERROR;
            }

            try {
                boolean queryIsAllowed = qService.isQueryAllowed(query, org, user, role, portal);

                if (queryIsAllowed) {
                    if (this.query.getProducer().getProtocol() == ProtocolType.REST) { //REST query: display REST form
                        // set query form that is going to be rendered
                        setRestQueryForm(temp.getForm());
                    } else { // XForms query
                        setRestQueryForm(null);
                        setQueryUUID(UUID.randomUUID().toString());
                        setQueryId(getQueryUUID());
                        File runXForms = new File(ServletActionContext.getServletContext().getRealPath("/")
                                + "/xforms-jsp/runq_" + getQuery().getName() + "_" + getQueryId() + ".xhtml");
                        // create temporary file for xforms
                        if (runXForms.exists()) {
                            runXForms.delete();
                        }
                        FileUtils.writeByteArrayToFile(runXForms, temp.getForm().getBytes("UTF-8"));
                        String ssn = user.getSsn();
                        String userFullName = user.getFullName();
                        String userFirstName = user.getGivenname();
                        String userLastName = user.getSurname();
                        Org parentOrg = null;
                        Org unitOrg = null;
                        String position = "";
                        String authenticator = AUTH_TYPE.getXrdTypeFor(auth.getType());
                        for (OrgPerson op : user.getOrgPersonList()) {
                            if (op.getOrgId().getId().equals(org.getId())
                                    && op.getPersonId().getId().equals(user.getId())) {
                                position = op.getProfession();
                            }
                        }
                        String useIssue = getPortal().getUseXrdIssue() ? getPortal().getUseXrdIssue().toString() : "";
                        String description = getQueryName() != null ? getQueryName().getDescription() : "";
                        if ((getPortal().getMispType() == Const.MISP_TYPE_UNIVERSAL
                                || getPortal().getMispType() == Const.MISP_TYPE_ORGANISATION)
                                && org.getSupOrgId() != null && !org.getCode().equals(org.getSupOrgId().getCode())) {
                            // in universal  portal query may be made by unit
                            parentOrg = getPortal().getUnitIsConsumer() ? org : org.getSupOrgId();
                            unitOrg = org;
                        } else {
                            parentOrg = org;
                        }
                        List<Xslt> globalXslList = qService.findGlobalXslt();
                        List<Xslt> localXsltList = qService.getXsltList(query);
                        TransformerFactory tFactory = XMLUtil.getTransformerFactory();

                        ApplyXSLTParameter param = new ApplyXSLTParameter();
                        param.tFactory = tFactory;
                        param.xhtml = runXForms;
                        param.xslList = globalXslList;
                        param.ssn = ssn;
                        param.userFullName = userFullName;
                        param.userFirstName = userFirstName;
                        param.userLastName = userLastName;
                        param.parentOrg = parentOrg;
                        param.unitOrg = unitOrg;
                        param.authenticator = authenticator;
                        param.position = position;
                        param.description = description;
                        param.useIssue = useIssue;
                        param.basepath = basepath;

                        applyXSLT(param);
                        if (localXsltList.size() > 0) {
                            ApplyXSLTParameter parameters = new ApplyXSLTParameter();
                            parameters.tFactory = tFactory;
                            parameters.xhtml = runXForms;
                            parameters.xslList = localXsltList;
                            parameters.ssn = ssn;
                            parameters.userFullName = userFullName;
                            parameters.userFirstName = userFirstName;
                            parameters.userLastName = userLastName;
                            parameters.parentOrg = parentOrg;
                            parameters.unitOrg = unitOrg;
                            parameters.authenticator = authenticator;
                            parameters.position = position;
                            parameters.description = description;
                            parameters.useIssue = useIssue;
                            parameters.basepath = basepath;

                            applyXSLT(parameters);
                        }
                    }
                } else {
                    LOG.error("this query is not allowed anymore");
                    addActionError(getText("services.not_allowed_anymore"));
                    return Action.ERROR;
                }
            } catch (IOException e) {
                LOG.error("Failed to execute XForms.", e);
            }

        }
        return Action.SUCCESS;
    }

    /**
     * Update service and generate forms for them
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String updateAndGenerateForms() throws DataExchangeException {
        String result = updateServicesList();
        if(!ERROR.equals(result) && foundQueries != null && !foundQueries.isEmpty()) {
            xformsGroup = foundQueries.stream().map(Query::getId).map(String::valueOf)
                                      .collect(Collectors.joining(Const.LIST_ELEMENT_DELIMITER));
            result = updateServicesXFrom();
        }
        return result;
    }

    private void setRestQueryForm(String form) {
        this.restQueryForm = form;
    }

    /**
     * @return true, in case current query form type is REST; false otherwise
     */
    public boolean isRestQuery() {
        return this.restQueryForm != null;
    }

    /**
     * @return REST query form HTML &lt;head&gt; tag content in case current Query is REST query.
     *         Otherwise, return empty string.
     */
    private String getRestFormHead() {
        String content = null;
        if (isRestQuery()) {
            content = StringUtils.substringBetween(this.restQueryForm, "<head>", "</head>");
        }
        if (content != null) {
            return content;
        } else {
            return "";
        }
    }
    /**
     * @return REST query form HTML &lt;body&gt; tag content in case current Query is REST query.
     *         Otherwise, return empty string.
     */
    private String getRestFormBody() {
        String content = null;
        if (isRestQuery()) {
            content = StringUtils.substringBetween(this.restQueryForm, "<body>", "</body>");
        }
        if (content != null) {
            return content;
        } else {
            return "";
        }
    }
    /**
     * @return REST query form HTML &lt;head&gt; and &lt;body&gt; tag content in case current Query is REST query.
     *         Otherwise, return empty string.
     */
    public String getRestForm() {
        if (isRestQuery()) {
            String head = getRestFormHead();
            String body = getRestFormBody();
            return head + "\n" + body;
        } else {
            return "";
        }
    }

    /**
     * @return REST query form HTML &lt;head&gt; and &lt;body&gt; tag content in case current Query is REST query.
     *         Otherwise, return empty string.
     */
    public Set<String> getRestFormTranslationCodes() {
        ResourceBundle bundle = getTexts("ee.aktors.misp2.package");
        Set<String> translationCodes = bundle.keySet();
        Set<String> restFormTranslationCodes = new LinkedHashSet<String>();
        for (String translationCode : translationCodes) {
            if (translationCode != null && translationCode.startsWith("restform.")) {
                restFormTranslationCodes.add(translationCode);
            }
        }
        return restFormTranslationCodes;
    }

    private String updateAllowedMethods(List<Query> queriesIn, Producer producerIn, Org org, String url) {
        try {
            if (queriesIn.size() == 0) {
                return "NO_ALLOWED";
            }
            qService.saveQueries(queriesIn, org);
            // X-Road v6: download wsdl for each query and parse service from that
            boolean success = true;
            String lang = ActionContext.getContext().getLocale().getLanguage();
            if (producerIn.getPortal().isV6() && url == null) {
                XRoadV6WsdlCollector wsdlCollector = new XRoadV6WsdlCollector();

                for (Query queryIter : queriesIn) {
                    wsdlCollector.collect(queryIter);
                }
                Iterator<WsdlContainer> it = wsdlCollector.iterator();
                while (it.hasNext()) {
                    WsdlContainer wsdlContainer = it.next();
                    LOG.debug("Updating v6 service remarks (notes/descriptions, not xforms) with queryIds: "
                        + wsdlContainer.getUpdatedQueryIds());
                    WSDLParser wsdlParser = new WSDLParser(wsdlContainer.getWsdlDocument(), portal.getXroadVersion());
                    success &= qService.saveDescriptions(wsdlParser, producerIn, lang);
                }

                if (success) {
                    wsdlCollector.checkError();
                }
            } else { // X-Road v5 and v6 from wsdl: all X-Road services are described in one wsdl

                switch (protocol) {
                    case SOAP:
                        success = qService.saveDescriptions(
                                new WSDLParser(url, portal.getXroadVersion()),
                                producerIn, lang);
                        break;
                    case REST:

                        if(StringUtils.isBlank(getOpenapiServiceCode())) {
                            return "ERROR_SERVICE_CODE_MISSING";
                        } else {
                            OpenApiParser openApiParser = new OpenApiParser(new URI(url));
                            success = qService.saveDescriptions(
                                    openApiParser, getProducer(), lang, getOpenapiServiceCode());
                        }

                        break;
                }
            }
            return success ? "OK" : ERROR;
        } catch (Exception e) {
            LOG.error("Failed to update query list.", e);
            return ERROR;
        }
    }

    private static void compare(List<Query> before, List<Query> after, ProtocolType protocolType) {
        // logger.debug(before.size() + " " + after.size()) ;
        if (after != null && !after.isEmpty() && before != null) {
            Iterator<Query> it = before.iterator();
            while (it.hasNext()) {
                Query qb = it.next();
                for (Query qa : after) {
                    if(ProtocolType.REST.equals(protocolType)
                    && qb.getOpenapiServiceCode() != null
                    && !qb.getOpenapiServiceCode().equals(qa.getOpenapiServiceCode())) {
                        continue;
                    }

                    if (qb.getName().equals(qa.getName())) {
                        it.remove();
                        break;
                    }
                }
            }
        }
    }

    private void applyXSLT(ApplyXSLTParameter parameterObject)
            throws TransformerException, UnsupportedEncodingException {
        String position = parameterObject.position;
        String[] queryNameWithVersion = getQuery().getName().split("[.]");
        String echoURI = parameterObject.basepath + "/echo?service=" + query.getName();
        String logURI = parameterObject.basepath + "/log";

        String pdfURI = "/runQuery_"
                + getQuery().getName() + "_" + getQueryId() + ".action?pdf=true";

        // !parameterObject.basepath.matches("^http.?://[^/]+/.*$")
        if (isRootContext()) { // Orbeon wrongly adds its own webapp name to context path,
            // when action is called in root context (like in case of RoksNet),
            // To work around it, prepend '/../' to url to counter Orbeon's action.
            pdfURI = "/.."  + pdfURI;
        }

        String uriParamsForLogging = "mainServiceFullIdentifier="
                + URLEncoder.encode(getQuery().getFullIdentifier(), StandardCharsets.UTF_8.name())
                + "&"
                + "mainServiceHumanReadableName="
                + URLEncoder.encode(this.queryName != null ? this.queryName.getDescription() : "",
                StandardCharsets.UTF_8.name());

        String mainServiceName = getQuery().getProducer().getShortName() + "." + getQuery().getName();
        for (Xslt x : parameterObject.xslList) {
            Transformer transformer = parameterObject.tFactory
                    .newTransformer(new StreamSource(convertXSLToSanitizedInputStream(x.getXsl())));
            transformer.setParameter("authenticator", parameterObject.authenticator);
            transformer.setParameter("basepath", parameterObject.basepath);
            transformer.setParameter("description", parameterObject.description);
            transformer.setParameter("descriptionEncoded", URLEncoder.encode(parameterObject.description, "UTF-8"));
            transformer.setParameter("echoURI", echoURI);
            transformer.setParameter("userName", parameterObject.userFullName);
            transformer.setParameter("userFirstName", parameterObject.userFirstName);
            transformer.setParameter("userLastName", parameterObject.userLastName);
            transformer.setParameter("language", getLocale().getLanguage());
            transformer.setParameter("logURI", logURI);
            String userMailPrivate = getUserMail();
            if (userMailPrivate == null)
                userMailPrivate = "";
            transformer.setParameter("mail", userMailPrivate);
            //Not used anymore
            transformer.setParameter("mailEncryptAllowed", false);
            transformer.setParameter("mailSignAllowed", false);
            //
            transformer.setParameter("mainServiceName", mainServiceName);
            transformer.setParameter("messageMediator", parameterObject.basepath + MediatorServlet.SERVLET_PATH + "?"
                    + uriParamsForLogging);

            transformer.setParameter("pdfURI", pdfURI);
            transformer.setParameter("portalName", getPortal().getShortName());
            if (position == null)
                position = "";
            transformer.setParameter("position", position);
            transformer.setParameter("producer", getQuery().getProducer() == null ? "complex" : getQuery()
                    .getProducer().getShortName());
            if (portal.isV6()) {
                transformer.setParameter("xroad6-client-xroad-instance", portal.getClientXroadInstance());
                transformer.setParameter("xroad6-client-member-class", parameterObject.parentOrg.getMemberClass());
                transformer.setParameter("xroad6-client-member-code", parameterObject.parentOrg.getCode());
                transformer.setParameter("xroad6-client-subsystem-code", parameterObject.parentOrg.getSubsystemCode());

                if (parameterObject.unitOrg != null) {
                    transformer
                            .setParameter("xroad6-represented-party-class", parameterObject.unitOrg.getMemberClass());
                    transformer.setParameter("xroad6-represented-party-code", parameterObject.unitOrg.getCode());
                    transformer.setParameter("xroad6-represented-party-name",
                            parameterObject.unitOrg.getActiveName(getLocale().getLanguage()));
                }
            } else {
                transformer.setParameter("orgCode", parameterObject.parentOrg.getCode());
                transformer
                        .setParameter("suborgCode", parameterObject.unitOrg != null ? parameterObject.unitOrg.getCode() : "");
            }
            transformer.setParameter("query", queryNameWithVersion[0]);
            transformer.setParameter("queryId", getQueryUUID());
            transformer.setParameter("useIssue", parameterObject.useIssue);
            transformer.setParameter("userId", parameterObject.ssn);
            transformer.setParameter("xrdVersion", getPortal().getXroadVersionAsInt());
            if (queryNameWithVersion.length > 1)
                transformer.setParameter("version", queryNameWithVersion[1]);

            // TODO make sure this parameter is used in MISP2 debug XSL, should add inspector but does not do anything
            // if added, make sure it can be used only in debug mode
            transformer.setParameter("inspector", getXmlDebug() == null ? Boolean.TRUE : getXmlDebug());
            LOG.debug("applying xslt: " + x.getName());
            transformer.transform(new StreamSource(parameterObject.xhtml), new StreamResult(parameterObject.xhtml));
        }
    }

    /**
     * Converts XSL represented by xslString to InputStream. Also replaces references to {Const#XROAD_NS_DEFAULT}
     * with {Const#XROAD_NS}
     *
     * @param xslString
     * @return
     */
    private InputStream convertXSLToSanitizedInputStream(String xslString) {
        try {
            xslString = xslString.replace(XROAD_VERSION.getDefault().getDefaultNamespace(), portal.getXroadNamespace());
            InputStream xslStringStream = new ByteArrayInputStream(xslString.getBytes("UTF-8"));
            return xslStringStream;
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException(e);
        }
    }

    private String updateProcedureFromFile(Integer producerId, File file) {
        String updated;
        String additionalErrorInfo = "";
        List<Query> foundQueries = null;

        setProducer(qService.findObject(Producer.class, producerId));

        if(sourceFile == null) {
            return getUpdateProducerResultMessage("ERROR_NO_FILE", null, null);
        }

        try {
            LOG.info("Querying methods from file " + getSourceFileFileName());
            boolean success = false;
            String lang = ActionContext.getContext().getLocale().getLanguage();
            switch (getProducer().getProtocol()) {
                case SOAP:
                    foundQueries = qService.getMethodsFromFile(getProducer(), file);
                    qService.saveQueries(foundQueries, org);
                    success = qService.saveDescriptions(new WSDLParser(file, portal.getXroadVersion()), getProducer(), lang);
                    updated = success ? "OK" : "ERROR";
                    break;
                case REST:
                    if(StringUtils.isBlank(getOpenapiServiceCode())) {
                        updated = "ERROR_SERVICE_CODE_MISSING";
                    } else {
                        OpenApiParser openApiParser = new OpenApiParser(file);
                        foundQueries = openApiParser.parseQueryList(getProducer(), getOpenapiServiceCode());
                        qService.saveQueries(foundQueries, org);
                        success = qService.saveDescriptions(openApiParser, getProducer(), lang, getOpenapiServiceCode());
                        updated = success ? "OK" : "ERROR";
                    }
                    break;
                default:
                    updated = "ERROR";
            }
        } catch (QueryException e) {
            LOG.error("Updating method lists failed.", e);
            if (e.getCause() instanceof IOException) {
                updated = "ERROR_WSDL_STATUS";
                LOG.error("WSDL not accessible.", e);
            } else if (e.getCause() instanceof SAXParseException) {
                updated = "ERROR_WSDL_SYNTAX";
                LOG.error("WSDL parsing failed.", e);
            } else {
                updated = "ERROR";
                additionalErrorInfo = getErrorSummary(e);
                LOG.error("Failed to process WSDL.", e);
            }
        } catch (DataExchangeException e){
            LOG.error("updateAllowedMethods failed with DataExchangeException", e);
            addActionError(getText("queries.note.not_updated") + getErrorSummary(e));
            return Action.ERROR;
        } catch (Exception e) {
            updated = "ERROR";
            additionalErrorInfo = getErrorSummary(e);
            LOG.error("updateAllowedMethods failed unexpectedly ", e);
        }
        this.foundQueries = foundQueries;
        return getUpdateProducerResultMessage(updated, additionalErrorInfo, foundQueries);
    }

    private String updateXFromsFromFile() {
        setProducer(qService.findObject(Producer.class, getId()));

        setXformsList(qService.findXFormsByProducer(getProducer()));
        setQueries(qService.findQueriesByProducer(getProducer(), getProtocol()));
        setOrgQueries(qService.findOrgQueriesByOrgAndProducer(org, getProducer()));

        if (org.getId().intValue() == getPortal().getOrgId().getId().intValue()
                && getPortal().getMispType() == Const.MISP_TYPE_UNIVERSAL && getPortal().getUnitIsConsumer()) {
            setUnitsAllowedQueries(qService.findAllowedQueriesInSubOrgs(org, getPortal(), getProducer()));
        }

        if(sourceFile == null) {
            return getUpdateProducerResultMessage("ERROR_NO_FILE", null, null);
        }

        try {
            if (getXformsGroup() != null) {
                TreeMap<String, Boolean> statesOfUpdatesMap = null;
                String generatedLabel = getText("services.show.list.url.xform_generated") + " " + (new SimpleDateFormat(getText("datetimeformat"))).format(new Date());
                switch (protocol) {
                    case SOAP:
                        statesOfUpdatesMap =
                                qService.updateDescriptions(
                                        new WSDLParser(sourceFile, portal.getXroadVersion()).getDoc(),
                                        getXformsGroup(), getProducer(), generatedLabel,
                                        CONFIG.getString("misp2.internal.url"));
                        break;
                    case REST:
                        if(StringUtils.isBlank(getOpenapiServiceCode())) {
                            return getUpdateProducerResultMessage("ERROR_SERVICE_CODE_MISSING", null, null);
                        } else {
                            OpenApiParser parser = new OpenApiParser(sourceFile);
                            statesOfUpdatesMap = qService.updateOpenApiDescriptions(parser, getXformsGroup(),
                                    generatedLabel, getOpenapiServiceCode());
                        }
                        break;
                }

                setStatesOfUpdatesMap(statesOfUpdatesMap);

                for (Map.Entry<String, Boolean> entry : this.statesOfUpdatesMap.entrySet()) {
                    String updatedQuery = entry.getKey();
                    Boolean updateSuccessful = entry.getValue();
                    if (updateSuccessful) {
                        addActionMessage(getText("xforms.note_refreshed." + protocol) + " (" + updatedQuery + ")");
                    } else {
                        addActionError(getText("xforms.error_not_refreshed." + protocol) + " (" + updatedQuery + ")");
                    }
                }

            }
        } catch (QueryException | DataExchangeException e) {
            LOG.error("Generating xforms in listQuery() failed.", e);
            addActionError(getText("xforms.error_not_refreshed." + protocol) + getErrorSummary(e));
            return Action.SUCCESS;
        }
        return Action.SUCCESS;
    }

    private String getUpdateProducerResultMessage(String updated, String additionalErrorInfo, List<Query> foundQueries) {
        String notUpdated = getText("queries.note.not_updated");
        switch (updated) {
            case "ERROR":
                addActionError(notUpdated + (additionalErrorInfo != null && !notUpdated.equals(additionalErrorInfo.trim()) ? additionalErrorInfo : ""));
                return Action.ERROR;
            case "ERROR_WSDL_STATUS":
                addActionError(notUpdated + " " + getText("queries.note.not_reachable." + protocol));
                return Action.ERROR;
            case "ERROR_WSDL_SYNTAX":
                addActionError(notUpdated + " " + getText("queries.note.not_correct." + protocol));
                return Action.ERROR;
            case "ERROR_WSDL_URL_MISSING":
                addActionError(notUpdated + " " + getText("queries.note.url_missing." + protocol));
                return Action.ERROR;
            case "NO_ALLOWED":
                addActionMessage(getText("queries.note.no_allowed"));
                return Action.ERROR;
            case "NO_METHODS":
                addActionMessage(getText("queries.note.no_methods"));
                return Action.ERROR;
            case "ERROR_NO_FILE":
                LOG.error("updateProcedureFromFile failed.No file uploaded");
                addActionError(notUpdated + " " + getText("queries.note.file_missing." + protocol));
                return Action.ERROR;
            case "ERROR_SERVICE_CODE_MISSING":
                addActionError(notUpdated + " " + getText("queries.openapiServiceCode_missing"));
                return Action.ERROR;
            default:
                if (!"UNIV_OK".equals(updated)) {
                    addActionMessage(getText("queries.note.updated"));
                }
                missingQueries = qService.findQueriesByProducer(getProducer(), getProtocol());
                compare(missingQueries, foundQueries, getProtocol());
                if (missingQueries.isEmpty()) {
                    return SUCCESS;
                } else {
                    session.put("missingQueries", missingQueries);
                    return "remove";
                }
        }
    }

    /**
     * @return the queries
     */
    public List<Query> getQueries() {
        return queries;
    }

    /**
     * @param queriesNew the queries to set
     */
    public void setQueries(List<Query> queriesNew) {
        this.queries = queriesNew;
        collectOpenapiServiceCodes(this.queries);
    }


    /**
     * @return the orgQueries
     */
    public List<Query> getOrgQueries() {
        return orgQueries;
    }

    /**
     * @param orgQueriesNew orgQueries to set
     */
    public void setOrgQueries(List<Query> orgQueriesNew) {
        Collections.sort(orgQueriesNew, Query.COMPARE_BY_QUERY_SHORT_NAME);
        this.orgQueries = orgQueriesNew;
        collectOpenapiServiceCodes(orgQueriesNew);
    }


    /**
     * @return the producers
     */
    public List<Producer> getProducers() {
        return producers;
    }

    /**
     * @param producersNew the producers to set
     */
    public void setProducers(List<Producer> producersNew) {
        this.producers = producersNew;
    }

    /**
     * @return the xformsList
     */
    public List<Xforms> getXformsList() {
        return xformsList;
    }

    /**
     * @param xformsListNew the xformsList to set
     */
    public void setXformsList(List<Xforms> xformsListNew) {
        this.xformsList = xformsListNew;
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
     * @return the query
     */
    public Query getQuery() {
        return query;
    }

    /**
     * @param queryNew the query to set
     */
    public void setQuery(Query queryNew) {
        this.query = queryNew;
    }

    /**
     * @return the xforms
     */
    public Xforms getXforms() {
        return xforms;
    }

    /**
     * @param xformsNew the xforms to set
     */
    public void setXforms(Xforms xformsNew) {
        this.xforms = xformsNew;
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
     * @return the xslt
     */
    public Xslt getXslt() {
        return xslt;
    }

    /**
     * @param xsltNew the xslt to set
     */
    public void setXslt(Xslt xsltNew) {
        this.xslt = xsltNew;
    }

    /**
     * @return the xformsGroup
     */
    public String getXformsGroup() {
        return xformsGroup;
    }

    /**
     * @param xformsGroupNew the xformsGroup to set
     */
    public void setXformsGroup(String xformsGroupNew) {
        this.xformsGroup = xformsGroupNew;
    }

    /**
     * @return the next
     */
    public String getNext() {
        return next;
    }

    /**
     * @param nextNew the next to set
     */
    public void setNext(String nextNew) {
        this.next = nextNew;
    }

    /**
     * @return the formHtml
     */
    public String getFormHtml() {
        return formHtml;
    }

    /**
     * @param formHtmlNew the formHtml to set
     */
    public void setFormHtml(String formHtmlNew) {
        this.formHtml = formHtmlNew;
    }

    /**
     * @return the userMail
     */
    public String getUserMail() {
        return userMail;
    }

    /**
     * @param userMailNew the userMail to set
     */
    public void setUserMail(String userMailNew) {
        this.userMail = userMailNew;
    }

    /**
     * @return the queryId
     */
    public String getQueryId() {
        return queryId;
    }

    /**
     * @param queryIdNew the queryId to set
     */
    public void setQueryId(String queryIdNew) {
        this.queryId = queryIdNew;
    }

    /**
     * @param statesOfUpdatesMapNew the statesOfUpdatesMap to set
     */
    public void setStatesOfUpdatesMap(TreeMap<String, Boolean> statesOfUpdatesMapNew) {
        this.statesOfUpdatesMap = statesOfUpdatesMapNew;
    }

    /**
     * @return the session
     */
    public Map<String, Object> getSession() {
        return session;
    }

    /**
     * @return the queryName
     */
    public QueryName getQueryName() {
        return queryName;
    }

    /**
     * @param queryNameNew the queryName to set
     */
    public void setQueryName(QueryName queryNameNew) {
        this.queryName = queryNameNew;
    }

    /**
     * @return the queryNote
     */
    public String getQueryNote() {
        return queryNote;
    }

    /**
     * @param queryNoteNew the queryNote to set
     */
    public void setQueryNote(String queryNoteNew) {
        this.queryNote = queryNoteNew;
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
     * @return the unitsAllowedQueries
     */
    public List<OrgQuery> getUnitsAllowedQueries() {
        return unitsAllowedQueries;
    }

    /**
     * @param unitsAllowedQueriesNew the unitsAllowedQueries to set
     */
    public void setUnitsAllowedQueries(List<OrgQuery> unitsAllowedQueriesNew) {
        this.unitsAllowedQueries = unitsAllowedQueriesNew;
        collectOpenapiServiceCodes(getQueriesFrom(unitsAllowedQueriesNew));
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
     * @return the queryUUID
     */
    public String getQueryUUID() {
        return queryUUID;
    }

    /**
     * @param queryUUIDNew the queryUUID to set
     */
    public void setQueryUUID(String queryUUIDNew) {
        this.queryUUID = queryUUIDNew;
    }

    /**
     * @return the xmlDebug
     */
    public String getXmlDebug() {
        return xmlDebug;
    }

    /**
     * @param xmlDebugNew the xmlDebug to set
     */
    public void setXmlDebug(String xmlDebugNew) {
        this.xmlDebug = xmlDebugNew;
    }

    /**
     * @return the missingQueries
     */
    public List<Query> getMissingQueries() {
        return missingQueries;
    }

    /**
     * @return the portal
     */
    public Portal getPortal() {
        return portal;
    }

    /**
     * @param portal portal to set
     */
    public void setPortal(Portal portal) {
        this.portal = portal;
    }

    /**
     * @return the qId
     */
    public Integer getqId() {
        return qId;
    }

    /**
     * @param qIdNew the qId to set
     */
    public void setqId(Integer qIdNew) {
        this.qId = qIdNew;
    }

    /**
     * @return wsdlSources in order that is displayed on jsp
     */
    public ServiceDescriptionSource[] getWsdlSources() {
        return new ServiceDescriptionSource[] {
                ServiceDescriptionSource.SECURITY_SERVER, ServiceDescriptionSource.FILE_UPLOAD,
                ServiceDescriptionSource.WSDL_URL, ServiceDescriptionSource.SERVICE_URLS };
    }

    public ServiceDescriptionSource getDefaultWsdlSource() {
        ServiceDescriptionSource activeSource;
        if(wsdlSource != null) {
            activeSource = wsdlSource;
        } else if(session.get(Const.SESSION_QUERY_SOURCE_FILE) != null) {
            activeSource = ServiceDescriptionSource.FILE_UPLOAD;
        } else if(producer != null && StringUtils.isNotBlank(producer.getWsdlURL())) {
            activeSource = ServiceDescriptionSource.WSDL_URL;
        } else if(ProtocolType.REST.equals(protocol)) {
            activeSource = ServiceDescriptionSource.SECURITY_SERVER;
        } else {
            activeSource = ServiceDescriptionSource.SECURITY_SERVER;
        }

        return activeSource;
    }

    /**
     * @return wsdlSource
     */
    public ServiceDescriptionSource getWsdlSource() {
        return wsdlSource;
    }

    /**
     *
     * @param wsdlSource wsdlSource to set
     */
    public void setWsdlSource(ServiceDescriptionSource wsdlSource) {
        this.wsdlSource = wsdlSource;
    }

    /**
     * @return true if to get all allowed methods from security server,
     * false if to get all methods from security server
     */
    public boolean isSecurityServerAllAllowed() {
        return securityServerAllAllowed;
    }

    /**
     * @param securityServerAllAllowed true if to get all allowed methods from
     * security server, false if to get all methods from security server
     */
    public void setSecurityServerAllAllowed(boolean securityServerAllAllowed) {
        this.securityServerAllAllowed = securityServerAllAllowed;
    }

    /**
     * @return the file users has uploded
     */
    public File getSourceFile() {
        return sourceFile;
    }

    /**
     * @param sourceFile file uploaded
     */
    public void setSourceFile(File sourceFile) {
        this.sourceFile = sourceFile;
    }

    /**
     * @return uploaded file content type
     */
    public String getSourceFileContentType() {
        return sourceFileContentType;
    }


    /**
     * Saves source file in session if new file uploaded.
     * If no file uploaded recovers the stored file from session if it exists.
     */
    private void recoverOrStoreSourceFile() {
        if(sourceFile != null) { // original upload file is destroyed after request. Copy it to preserve
            try {
                File tmpSourceFile = File.createTempFile(
                        "service-description_" + "_" + protocol + "_", ".tmp");
                FileUtils.copyFile(sourceFile, tmpSourceFile);
                session.put(Const.SESSION_QUERY_SOURCE_FILE, tmpSourceFile);
                session.put(Const.SESSION_QUERY_SOURCE_FILE_NAME, sourceFileFileName);
            } catch (IOException e) {
                LOG.error("Could not save service description temporary source file", e);
            }

        } else {
            sourceFile = (File) session.get(Const.SESSION_QUERY_SOURCE_FILE);
        }
    }

    /**
     * @param sourceFileContentType uploaded file content type
     */
    public void setSourceFileContentType(String sourceFileContentType) {
        this.sourceFileContentType = sourceFileContentType;
    }

    /**
     * @return uploaded file name
     */
    public String getSourceFileFileName() {
        return sourceFileFileName;
    }

    /**
     * @param sourceFileFileName uploaded file name
     */
    public void setSourceFileFileName(String sourceFileFileName) {
        this.sourceFileFileName = sourceFileFileName;
    }

    /**
     * @return producer protocol
     */
    public ProtocolType getProtocol() {
        return protocol;
    }

    /**
     * @param protocol  producer protocol
     */
    public void setProtocol(ProtocolType protocol) {
        this.protocol = protocol;
    }

    /**
     * @return whether the producer has any queries
     */
    public boolean hasQueries(){
        return queries != null && !queries.isEmpty() || orgQueries != null && !orgQueries.isEmpty();
    }

    /**
     * @return service code for xroad rest queries
     */
    public String getOpenapiServiceCode() {
        // populate the item with plausible value beforehand, if it is null
        if (protocol == ProtocolType.REST) {
            // if it is null, try to retrieve from flash
            if (openapiServiceCode == null) {
                openapiServiceCode = (String)FlashUtil.getFlash().get(
                        Const.OPENAPI_SERVICE_CODE_FLASH_KEY);
            }
            // if still null, try first one of the codes from query list
            if (openapiServiceCode == null && openapiServiceCodes.size() > 0) {
                setOpenapiServiceCode(openapiServiceCodes.iterator().next());
            }
        }
        return openapiServiceCode;
    }

    /**
     * @param openapiServiceCode service code for xroad rest queries
     */
    public void setOpenapiServiceCode(String openapiServiceCode) {
        if (openapiServiceCode != null) {
            // add user-sent service code to flash to preserve it after redirect
            FlashUtil.getFlash().put(
                    Const.OPENAPI_SERVICE_CODE_FLASH_KEY, openapiServiceCode);
        }
        this.openapiServiceCode = openapiServiceCode;
    }
    
    /**
     * Collect OpenAPI service codes to a {@link #openapiServiceCodes} map.
     * @param queryList list of REST Query entities,
     *          where openapiServiceCode-s are read from
     */
    private void collectOpenapiServiceCodes(List<Query> queryList) {
        if (protocol == Producer.ProtocolType.REST && openapiServiceCodes != null) {
            if (queryList != null) {
                for (Query q : queryList) {
                    if (q != null && q.getOpenapiServiceCode() != null) {
                        openapiServiceCodes.add(q.getOpenapiServiceCode());
                    }
                }
            }
        }
    }
    
    /**
     * Traverse through a list of OrgQuery entities, collect associated Query entities
     * to a list and return it.
     * NB! Method is meant to be used for REST queries only.
     * In case of other {@link #protocol}, method returns null immediately.
     * @param orgQueryList list of input OrgQuery entities
     * @return List of Query entities associated with OrgQuery-entities.
     *         Method is null-safe: in that case null is also returned.
     *         Method also returns null if current action does not have REST protocol set.
     */
    private List<Query> getQueriesFrom(List<OrgQuery> orgQueryList) {
        if (protocol == Producer.ProtocolType.REST && orgQueryList != null) {
            List<Query> queryList = new ArrayList<Query>(orgQueryList.size());
            for (OrgQuery oq : orgQueryList) {
                if (oq != null) {
                    queryList.add(oq.getQueryId());
                }
            }
            return queryList;
        } else {
            return null;
        }
    }
    
    /**
     * @return openapiServiceCodes in a map.
     *      The map is used as select option key/value pairs in user interface,
     *      where user can choose an existing openapiServiceCode from query list.
     *      It's first option is select-text.
     */
    public Map<String, String> getOpenapiServiceCodeOptions() {
        if (hasOpenapiServiceCodeOptions()) {
            Map<String, String> options = new LinkedHashMap<String, String>();
            options.put("", "-- " + getText("services.show.Options") + " --");
            for (String code : openapiServiceCodes) {
                options.put(code, code);
            }
            return options;
        } else {
            return null;
        }
    }
    /**
     * @return true if openapiServiceCodes select is shown for the user, false if not
     */
    public boolean hasOpenapiServiceCodeOptions() {
        return openapiServiceCodes != null && openapiServiceCodes.size() > 1;
    }



    private class ApplyXSLTParameter {
        private TransformerFactory tFactory;
        private File xhtml;
        private List<Xslt> xslList;
        private String ssn;
        private String userFirstName;
        private String userLastName;
        private String userFullName;
        private Org parentOrg;
        private Org unitOrg;
        private String authenticator;
        private String position;
        private String description;
        private String useIssue;
        private String basepath;
    }

    /**
     * WsdlSource types
     */
    private enum ServiceDescriptionSource {
        SECURITY_SERVER("label.input.radio.source.securityServer"),
        WSDL_URL("label.input.radio.source.url"),
        FILE_UPLOAD("label.input.radio.source.upload"),
        SERVICE_URLS("label.input.radio.source.serviceUrls");

        private String translateKey;

        ServiceDescriptionSource(String translateKey) {
            this.translateKey = translateKey;
        }

        public String getTranslateKey() {
            return translateKey;
        }
    }
}
