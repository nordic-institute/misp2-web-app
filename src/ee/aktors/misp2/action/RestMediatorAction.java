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

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.pdfbox.io.IOUtils;
import org.apache.struts2.StrutsStatics;
import org.springframework.http.HttpStatus;

import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.model.QueryLog;
import ee.aktors.misp2.model.QueryName;
import ee.aktors.misp2.service.QueryLogService;
import ee.aktors.misp2.service.QueryService;
import ee.aktors.misp2.service.XroadInstanceService;
import ee.aktors.misp2.servlet.mediator.ByteBufferInputStream;
import ee.aktors.misp2.servlet.mediator.ByteCounter;
import ee.aktors.misp2.servlet.mediator.ByteCounterInputStream;
import ee.aktors.misp2.service.QueryLogService.LogQueryInput;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.JsonUtil;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.identifier.XRoad6ClientIdentifierData;
import ee.aktors.misp2.util.xroad.soap.identifier.XRoad6ServiceIdentifierData;

/**
 * Action for mediating REST query to security server.
 */
public class RestMediatorAction extends SessionPreparedBaseAction implements StrutsStatics {
    private static final long serialVersionUID = 1L;
    private static final Logger LOG = LogManager.getLogger(RestMediatorAction.class);

    private QueryService queryService;
    private QueryLogService queryLogService;
    private XroadInstanceService xroadInstanceService;
    
    /**
     * Initialize action
     */
    public RestMediatorAction(QueryService queryService, QueryLogService queryLogService, XroadInstanceService xroadInstanceService) {
        this.queryService = queryService;
        this.queryLogService = queryLogService;
        this.xroadInstanceService = xroadInstanceService;
    }

    /**
     * Mediate REST message to security server
     * @return null to avoid Struts2 response handling
     * @throws IOException on JSON mapping failure
     */
    @HTTPMethods(methods = { HTTPMethod.PUT }) // method has to be PUT, because POST triggers Struts2 attachment processing
    public String mediate() throws IOException {
        ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
        HttpServletResponse response = (HttpServletResponse) ActionContext.getContext().get(HTTP_RESPONSE);
        
        try {
            if (portal == null) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_REST_PORTAL_MISSING,
                        "Portal was not found from user session.", null);
            }
            if (org == null) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_REST_ORG_MISSING,
                        "Portal organization was not found from session.", null);
            }
            if (user == null) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_REST_USER_MISSING,
                        "Logged in user was not found from session.", null);
            }

            HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
            String targetAction = request.getHeader("X-REST-action");
            String targetBaseUrl = concatUrl(portal.getSecurityHost(), "r1"); // security server address from DB
            
            // TODO remove dummy answer
            if (targetAction != null && targetAction.contains("ee-dev/GOV/11223344/testsystem")) {
                sendDummyResponse(response, ow);
                return null;
            }
            
            XRoad6ServiceIdentifierData serviceData = new XRoad6ServiceIdentifierData(targetAction);
            if (!serviceData.isValid()) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_REST_SERVICE_IDENTIFIER_INVALID,
                        "Service identifier is not valid: " + serviceData.toString(), null, serviceData.toString());
            }

            // Check if target service X-Road instance is allowed
            String requestXroadInstance = serviceData.getXRoadInstance();
            String activeXroadInstanceCode = xroadInstanceService.getActiveXroadInstanceCode(requestXroadInstance);
            if (activeXroadInstanceCode == null) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_INSTANCE_NOT_ACTIVE_FOR_PORTAL,
                        "X-Road instance '" + requestXroadInstance
                        + "' is not active in portal '" + portal.getShortName() + "'.",
                        null, requestXroadInstance, portal.getShortName());
            }

            String targetHttpMethod = request.getHeader("X-REST-method");
            if (targetHttpMethod == null) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_REST_METHOD_MISSING,
                        "Missing REST query method (should be in 'X-REST-method' header).", null);
            }
            targetHttpMethod = targetHttpMethod.toUpperCase();
            
            Query mainQuery = validateQuery(request.getHeader("X-REST-main-query-id"), targetHttpMethod, targetAction);
            
            if (false) { // FIXME TEST override target URL
                // commented out: hard replace of X-Road identifer from target URL
                targetBaseUrl = "http://192.168.219.190:9090/v2/"; // direct server url
                targetAction = targetAction.replaceAll("^[^/]*/[^/]*/[^/]*/[^/\\?]*", "");
            }
            
            // Create URL with default timeouts
            URL url = XRoadUtil.getMediatorServiceEndpointUrlWithTimeouts(concatUrl(targetBaseUrl, targetAction));

            long startTime = System.currentTimeMillis();
            // Open URL connection
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            // Set request HTTP method
            con.setRequestMethod(targetHttpMethod);
            // Enable writing to output
            
            // Copy headers (Note: request.getHeaderNames() gives all headers with lower case)
            final String formHeaderPrefix = "X-REST-Form-Header-";
            Enumeration<?> headerNames = request.getHeaderNames();
            while (headerNames.hasMoreElements()) {
                Object headerNameObj = headerNames.nextElement();
                if (headerNameObj != null) {
                    String headerName = headerNameObj.toString();
                    Enumeration<?> headerValues = request.getHeaders(headerName);
                    if (headerName.toLowerCase().startsWith(formHeaderPrefix.toLowerCase())) {
                        // replace prefix in header name denoting form header (needs to be forwarded)
                        headerName = headerName.substring(formHeaderPrefix.length());
                        addHeadersToCon(con, headerName, headerValues);
                    } else if (this.isHeaderForwarded(headerName)) {
                        addHeadersToCon(con, headerName, headerValues);
                    }
                }
            }
            
            // Gather X-Road client data from session user portal and org
            XRoad6ClientIdentifierData clientData = new XRoad6ClientIdentifierData(portal, org);
            String xroadQueryId = XRoadUtil.getXRoadRequestId();
            QueryLog queryLog = saveQueryLogRequest(clientData, serviceData, xroadQueryId, mainQuery);
            
            
            // Set X-Road specific headers
            con.setRequestProperty("X-Road-Client", clientData.getRestClientIdentifier());
            con.setRequestProperty("X-Road-Id", xroadQueryId);
            con.setRequestProperty("X-Road-User-Id", user.getSsn());
            // TODO Do not set service for now
            //con.setRequestProperty("X-Road-Service", targetAction);
            if (clientData.hasRepresentedParty()) { // add represented party if it exists
                con.setRequestProperty("X-Road-Represented-Party", clientData.getRepresentedPartyIdentifier());
            }
            
            // Log HTTP request if needed
            StringWriter swLogReq = null;
            StringWriter swLogResp = null;
            if (LOG.isTraceEnabled()) {
                swLogReq = new StringWriter().append("REST request message: "); // for logging HTTP request
                swLogResp = new StringWriter().append("REST response message: "); // for logging HTTP response
            }
            
            if (swLogReq != null) {
                swLogReq.append("\n URI         : " + url.toString());
                swLogReq.append("\n Method      : " + targetHttpMethod);
                swLogReq.append("\n Headers     : ");
            } else {
                LOG.info("Sending REST request to URL " + url + ". HTTP method: " + targetHttpMethod);
            }
            
            // Add request headers to request log writer, if request is being logged
            if (swLogReq != null) {
                for (String headerName : con.getRequestProperties().keySet()) {
                    List<String> headerValues = con.getRequestProperties().get(headerName);
                    for (String headerValue : headerValues) {
                        swLogReq.append("\n   " + headerName + ": " + headerValue);
                    }
                }
            }
            
            // Copy request body
            LOG.debug("Proxying request to target");
            // in case method is GET or DELETE, do not send request body
            if (!targetHttpMethod.equals("GET") && !targetHttpMethod.equals("DELETE") ) {
                con.setDoOutput(true);
                if (swLogReq != null) { // Log request
                    ByteBufferInputStream requestInputStream = new ByteBufferInputStream(request.getInputStream());
                    IOUtils.copy(requestInputStream, con.getOutputStream());
                    requestInputStream.appendBuffer(swLogReq, "Request body");
                } else { // Do not log the request, proxy request body directly to target connection
                    InputStream requestInputStream = request.getInputStream();
                    IOUtils.copy(requestInputStream, con.getOutputStream());
                }
            }
            if (swLogReq != null) {
                LOG.trace(swLogReq.toString());
            }
            LOG.debug("Sending response back to client");
            
            // Read response status code
            int status = con.getResponseCode();

            if (swLogResp != null) { // If response is logged, add status to response log
                swLogResp.append("\n Status code  : " + status);
                swLogResp.append("\n Headers      : ");
            }
            
            
            // Copy received headers to response
            Map<String, List<String>> responseHeaders = con.getHeaderFields();
            for (String headerName : responseHeaders.keySet()) {
                if (headerName != null) { // first line in HTTP request has null header name
                    List<String> headerValues = responseHeaders.get(headerName);
                    for (String headerValue : headerValues) {
                        response.addHeader("X-REST-Response-Header-" + headerName, headerValue);
                        if (swLogResp != null) { // if response is logged, add headers
                            swLogResp.append("\n   " + headerName + ": " + headerValue);
                        }
                        // add content type to response
                        if (headerName != null && headerName.toLowerCase().equals("content-type")) {
                            response.addHeader(headerName, headerValue);
                        }
                    }
                }
            }
            // Put returned response status code to a special header
            response.setHeader("X-REST-Response-Code", "" + status);
            response.setHeader("X-REST-Response-Text", HttpStatus.valueOf(status).getReasonPhrase());
            response.setStatus(HttpServletResponse.SC_OK);
            
            InputStream responseInputStream = getResponseStream(con, status, swLogResp);
            IOUtils.copy(responseInputStream, response.getOutputStream());
            ByteCounter byteCounter = (ByteCounter)responseInputStream;
            String responseContent = getResponseContent(responseInputStream);
            saveQueryLogResponse(queryLog, startTime, status, byteCounter.getByteCount(), responseContent);
            logResponseToLogFile(responseInputStream, swLogResp);
            
        } catch (DataExchangeException e) {
            LOG.error("Mediating REST message failed", e);
            Map<String, Object> respMap = JsonUtil.getErrorResponseMap(
                    getText("app.title") + 
                        "." + this.getClass().getSimpleName() + 
                        "." + e.getClass().getSimpleName() + 
                        "." + e.getType().toString(), 
                    getText(e.getTranslationCode(), e.getParameters()));
            response.setStatus(500);
            response.setHeader("X-REST-Response-Code", "" + 500);
            response.setHeader("X-REST-Response-Text", "MISP2 Data Exchange Error");
            response.addHeader("Content-Type", "application/json; charset=UTF-8");
            response.addHeader("X-REST-Response-Header-" + "Content-Type", "application/json; charset=UTF-8");
            ow.writeValue(response.getWriter(), respMap);
        }
        return null;
    }

    /**
     * Return query entity where the current request is from. If query is not found or some inconsistency is detected,
     * throw an error - so current method works as both getter and validator.
     * @param mainQueryIdStr query ID from user header input. Serves mostly to retrieve and validate request quicker, since otherwise
     *      query needs to retrieved by URL which requires a more sophisticated query mechanism.
     * @param userRequestHttpMethod HTTP method in user request header (e.g POST, DELETE etc)
     * @param userRequestAction HTTP request URI which also starts with reference to X-Road v6 service identifier.
     * @return Query entity instance if valid query was found and request was permitted
     * @throws DataExchangeException in case request was not found to be permitted for the user
     */
    private Query validateQuery(String mainQueryIdStr, String userRequestHttpMethod, String userRequestAction) throws DataExchangeException {
        //String mainQueryCode = request.getHeader("X-REST-main-service-id");
        if (mainQueryIdStr == null) {
            throw new DataExchangeException(
                    DataExchangeException.Type.XROAD_REST_QUERY_ID_MISSING,
                    "Missing REST query entity ID (should be in 'X-REST-main-query-id' header).", null);
        }
        Integer mainQueryId;
        try {
            mainQueryId = Integer.parseInt(mainQueryIdStr);
        } catch (NumberFormatException e) {
            throw new DataExchangeException(
                    DataExchangeException.Type.XROAD_REST_QUERY_ID_NOT_INTEGER,
                    "Could not parse REST query entity ID to integer. Value given was '" + mainQueryIdStr + "'", e, mainQueryIdStr);
        }
        Query mainQuery = queryLogService.findObject(Query.class, mainQueryId);
        if (mainQuery == null) {
            throw new DataExchangeException(
                    DataExchangeException.Type.XROAD_REST_QUERY_NOT_FOUND,
                    "REST query not found (id = " + mainQueryId + ").", null, "" + mainQueryId);
        }

        // Check if user has access to query
        Integer role = (Integer) session.get(Const.SESSION_USER_ROLE);
        boolean queryIsAllowed = queryService.isQueryAllowed(mainQuery, org, user, role, portal);
        if (!queryIsAllowed) {
            throw new DataExchangeException(
                    DataExchangeException.Type.XROAD_REST_QUERY_NOT_ALLOWED_FOR_USER,
                    "REST query (id=" + mainQuery.getId() + ") is not allowed for user (id=" + user.getId() + ")"
                            + " within portal(id=" + portal.getId() + "), org(id=" + org.getId() + ") and role(" + role.toString() + ").", null);
        }
        
        // Check if request HTTP method and target action are actually among the subqueries in the query form.
        // This will stop users manipulating data and accessing any query - however, it will not stop them fiddling with the queries allowed to them.
        String subQueryNames = mainQuery.getSubQueryNames();
        
        if (!isUserRequestAllowed(subQueryNames, userRequestHttpMethod, userRequestAction)) {
            // Throw error if no known sub-query matched current request's method and action.
            // That means request sender does not have permission to perform current request.
            String userRequest = userRequestHttpMethod +" " + userRequestAction;
            throw new DataExchangeException(
                    DataExchangeException.Type.XROAD_REST_REQUEST_DOES_NOT_MATCH_FORM,
                    "REST query (id=" + mainQuery.getId() + ") is not allowed,"
                    + " because request method and action (" + userRequest +")"
                    + " do not match with the methods and actions of known sub-queries (" + subQueryNames + ").", null,
                    userRequest, subQueryNames);
        }
        return mainQuery;
    }

    /**
     * Check whether user REST request method and URI match allowed URI patterns parsed from query form.
     * @param subQueryNames expected method/action combinations for given query. May contain OpenAPI URL paramters: e.g. {param}.
     * @param userRequestHttpMethod HTTP method of user request that is being validated
     * @param userRequestAction HTTP action of user request that is being validated
     * @return true, if request method/action matched the method and action of the form.
     */
    static boolean isUserRequestAllowed(String subQueryNames, String userRequestHttpMethod, String userRequestAction) {
        String userRequest =  "" + userRequestHttpMethod + " " + userRequestAction; // variable is for logging
        if (subQueryNames != null) {
            String[] allowedRequests = subQueryNames.split(Const.SUB_QUERY_NAME_SEPARATOR);
            for (String allowedRequest : allowedRequests) {
                int separatorIndex = allowedRequest.indexOf(' ');
                String allowedHttpMethod = allowedRequest.substring(0, separatorIndex);
                String allowedAction = allowedRequest.substring(separatorIndex );
                if (allowedHttpMethod != null && allowedAction != null && userRequestHttpMethod != null && userRequestAction != null) {
                    allowedHttpMethod = allowedHttpMethod.trim();
                    allowedAction = allowedAction.trim();
                    
                    LOG.debug("Comparing user request '" + userRequest + "' to allowed request '" + allowedRequest + "'.");
                    if (!allowedHttpMethod.equals(userRequestHttpMethod)) {
                        continue;
                    }
                    
                    // try direct comparison first
                    if (!allowedAction.contains("{") && allowedAction.equals(userRequestAction)) {
                        LOG.info("Found direct request method/action match."
                                + " User request '" + userRequest + "' matched subquery '" + allowedRequest + "'. ");
                        return true;
                    } else if (actionsMatch(allowedAction, userRequestAction)) {
                        LOG.info("Found parameter-based request method/action match."
                                + " User action '" + userRequest + "' matched subquery '" + allowedRequest + "'.");
                        return true;
                    }
                }
            }
        }
        return false;
    }

    private static boolean actionsMatch(String allowedActionPattern, String userRequestAction) {

        // if that did not work, compare ignoring OpenAPI parameters within allowed request
        String[] allowedActionAr = allowedActionPattern.split("\\?")[0].split("/"); 
        String[] userRequestActionAr = userRequestAction.split("\\?")[0].split("/");
        
        boolean matches = true;
        if (allowedActionAr.length != userRequestActionAr.length) {
            LOG.debug("User request '" + userRequestAction
                    + "' has got different segment length (" + userRequestActionAr.length + " segments)"
                    + " to allowed '" + allowedActionPattern + "' (\" + allowedRequest.length + \" segments).");
            return false;
        }
        for (int i = 0; i < allowedActionAr.length; i++) {
            if (!allowedActionAr[i].contains("{")) { // ignore entries with parameters in it
                if (i < allowedActionAr.length - 1 && !allowedActionAr[i].equals(userRequestActionAr[i])) {
                    LOG.debug("User action segment " + i + " '" + userRequestActionAr[i]
                            + "' does not match segment '" + allowedActionAr[i] + "' in allowed action ");
                    matches = false;
                    break;
                } else if (i == allowedActionAr.length - 1) {
                    int endIndex = userRequestActionAr[i].indexOf('?');
                    String finalSection = endIndex != -1 ? userRequestActionAr[i].substring(0, endIndex) : userRequestActionAr[i];
                    if (!allowedActionAr[i].equals(finalSection)) {
                        LOG.debug("Final user action segment " + i + " '" + finalSection
                                + "' does not match segment '" + allowedActionAr[i] + "' in allowed action ");
                        matches = false;
                        break;
                    }
                }
            }
        }
        return matches;
    }

    private InputStream getResponseStream(HttpURLConnection con, int status, StringWriter swLogResp) {
        InputStream responseInputStream = null;
        try {
            responseInputStream = con.getInputStream();
        } catch (IOException e) {
            String errorMessage = "Failed to open inputStream to " + con.getURL()  + " failed. ";
            if (LOG.isTraceEnabled()) {
                LOG.warn(errorMessage, e);
            } else {
                LOG.warn(errorMessage +  e.getMessage());
            }
            responseInputStream = con.getErrorStream();
        }
        if (responseInputStream == null) { // neither input stream or error stream could be opened
            // open empty stream to avoid over-complicating programming logi
            responseInputStream = new ByteArrayInputStream(new byte[] {});
        }
        boolean logErrorToQueryLog = hasError(status);
        boolean logResponseToLogFile = swLogResp != null;
        InputStream wrapper;
        if (logErrorToQueryLog || logResponseToLogFile) {
            wrapper = new ByteBufferInputStream(responseInputStream);
        } else {
            wrapper = new ByteCounterInputStream(responseInputStream);
        }
        return wrapper;
    }

    private String getResponseContent(InputStream responseInputStream) {
        if (responseInputStream instanceof ByteBufferInputStream) {
            ByteBufferInputStream byteBuffer = (ByteBufferInputStream)responseInputStream;
            return byteBuffer.bufferToString();
        } else {
            return null;
        }
    }

    private QueryLog saveQueryLogRequest(XRoad6ClientIdentifierData clientData, XRoad6ServiceIdentifierData serviceData,
            String xroadQueryId, Query mainQuery) {
        final String headerFieldSeparator = Const.XROAD_V6_FIELD_SEPARATOR;
        LogQueryInput input = new QueryLogService.LogQueryInput();
        input.setSsn(user.getSsn());
        input.setPortal(portal);
        input.setConsumer(clientData.getRestClientIdentifier(headerFieldSeparator));
        input.setUnit(clientData.getRepresentedPartyIdentifier(headerFieldSeparator));
        input.setQueryId(xroadQueryId);

        // Set current REST request X-Road service identifier
        String queryServiceIdentifier = serviceData.getRestServiceIdentifier(headerFieldSeparator);
        input.setService(queryServiceIdentifier);
        
        // Set main query identifier and find query description by that identifier
        input.setDescription(null);
        
        // Set query identifier
        input.setMainServiceName(mainQuery.getFullIdentifier());
        // Set description from query entity
        QueryName queryName = mainQuery.getActiveName(getLocale().getLanguage());
        if (queryName != null) {
            input.setDescription(queryName.getDescription());
        }
        
        input.setLanguage(getLocale().getLanguage());
        input.setQueryTimeSec("" + 0);
        QueryLog queryLog = queryLogService.logQuery(input);
        queryLogService.save(queryLog);
        
        return queryLog;
    }
    
    private void saveQueryLogResponse(
            QueryLog queryLog, long startTime, int statusCode, long responseByteCount, String errContent) {
        try {
            queryLog.setQuerySize("" + (double)responseByteCount); // measured in B
            long endTime = System.currentTimeMillis();
            final double kilo = 1000.0;
            queryLog.setQueryTimeSec("" + (double) (endTime - startTime) / kilo);
            LOG.debug("Query took " + (endTime - startTime) + " ms");
            if (hasError(statusCode)) {
                LOG.debug("Response had error status code: " + statusCode + ".");
                queryLogService.logQueryError(queryLog, 
                        "" + statusCode, HttpStatus.valueOf(statusCode).getReasonPhrase(), errContent);
            } else {
                queryLog.setSuccess(true);
                queryLogService.save(queryLog);
            }
        } catch (Exception e) {
            LOG.error("Failed to log query into database", e);
        }
    }

    private void logResponseToLogFile(InputStream responseInputStream, StringWriter swLogResp) {
        if (swLogResp != null && responseInputStream instanceof ByteBufferInputStream) { // log error response body if logging is on
            ByteBufferInputStream byteBuffer = (ByteBufferInputStream)responseInputStream;
            if (swLogResp != null) {
                byteBuffer.appendBuffer(swLogResp, "Response body");
                LOG.trace(swLogResp.toString());
            }
        }
    }

    private boolean hasError(int status) {
        return status >= 400;
    }

    private void addHeadersToCon(HttpURLConnection con, String headerName, Enumeration<?> headerValues) {
        while (headerValues.hasMoreElements()) {
            String headerValue = headerValues.nextElement().toString();
            con.addRequestProperty(headerName, headerValue.toString());
        }
    }

    private boolean isHeaderForwarded(String headerName) {
        final Set<String> forwardedHeaderNames = new HashSet<String>(
                Arrays.asList("accept", "content-type"));
        return forwardedHeaderNames.contains(headerName.toLowerCase());
    }

    /**
     * Concatenate servicePath to baseUrl separated by a single '/'.
     * @param baseUrl base URL string
     * @param servicePath path string
     * @return concatenated string with '/' separator, avoiding duplicate slash or no slash
     */
    private String concatUrl(String baseUrl, String servicePath) {
        StringWriter sw = new StringWriter();
        sw.append(baseUrl);
        if (servicePath != null) {
            if (baseUrl.endsWith("/") && servicePath.startsWith("/")) {
                sw.append(servicePath.substring(1, servicePath.length()));
            } else if (baseUrl.endsWith("/") || servicePath.startsWith("/")) {
                sw.append(servicePath);
            } else {
                sw.append("/");
                sw.append(servicePath);
            }
        }
        return sw.toString();
    }

    private void sendDummyResponse(HttpServletResponse response, ObjectWriter ow) throws JsonGenerationException, JsonMappingException, IOException {
        Map<String, Object> respMap =  new LinkedHashMap<String, Object>();
    
        List<Object> persons = new ArrayList<Object>();
        
        Map<String, Object> person =  new LinkedHashMap<String, Object>();
        person.put("isikukood", "11111111112");
        person.put("nimi", "Ly Cuusk");
        Map<String, Object> aadress1 =  new LinkedHashMap<String, Object>();
        aadress1.put("linn", "Tallinn");
        aadress1.put("maja", "45");
        Map<String, Object> aadress2 =  new LinkedHashMap<String, Object>();
        aadress2.put("linn", "Tartu");
        aadress2.put("maja", "36");
        person.put("aadressid", Arrays.asList(aadress1, aadress2));
        persons.add(person);
    
        Map<String, Object> person2 =  new LinkedHashMap<String, Object>();
        person2.put("isikukood", "11111111113");
        person2.put("nimi", "Vassili Õigusega on Päris Äge Õö");
    
        Map<String, Object> aadress3 =  new LinkedHashMap<String, Object>();
        aadress3.put("linn", "Tapa");
        aadress3.put("maja", "99");
        person2.put("aadressid", Arrays.asList(aadress3));
        persons.add(person2);
        respMap.put("isikud", persons);
        respMap.put("kokku", 2);
    
        Map<String, Object> varia =  new LinkedHashMap<String, Object>();
        varia.put("varvid", Arrays.asList("punane", "sinine", "roheline", "kollane"));
        respMap.put("varia", varia);
        response.setHeader("X-REST-Response-Code", "200");
        response.setContentType(JsonUtil.JSON_CONTENT_TYPE);
        response.setStatus(HttpServletResponse.SC_OK);
        ow.writeValue(response.getWriter(), respMap);
    }
}