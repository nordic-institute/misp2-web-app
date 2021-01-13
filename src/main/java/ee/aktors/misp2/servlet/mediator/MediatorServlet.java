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

package ee.aktors.misp2.servlet.mediator;

import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLDecoder;
import java.util.Date;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.SOAPConstants;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPFault;
import javax.xml.soap.SOAPMessage;

import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.context.ApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.service.QueryLogService;
import ee.aktors.misp2.service.XroadInstanceService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.MISPUtils;
import ee.aktors.misp2.util.xroad.XRoadUtil;

/**
 * Mediates SOAP queries between Orbeon and security server.
 */
public class MediatorServlet extends HttpServlet {
    public static final String SERVLET_PATH = "/mediator";
    private static final long serialVersionUID = -3676193972231791747L;
    private final Logger logger = LogManager.getLogger(MediatorServlet.class);
    static final String CONTENT_TYPE_TEXT_XML = "text/xml;charset=\"UTF-8\"";
    private HashMap<String, String> parameters;
    private QueryLogService queryLogService;
    private XroadInstanceService xroadInstanceService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public MediatorServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
     *      response)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
     *      response)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long t0 = new Date().getTime();
        try {
            logger.debug("MediatorServlet parameters " + URLDecoder.decode(request.getQueryString(), "UTF-8"));
            ApplicationContext context = WebApplicationContextUtils.getWebApplicationContext(getServletContext());
            queryLogService = (QueryLogService) context.getBean("queryLogService");
            xroadInstanceService = (XroadInstanceService) context.getBean("xroadInstanceService");
            
            // obtain actual session from request.getSession() if later needed
            HttpSession session = request.getSession();
            Portal portal = session != null ? ((Portal) session.getAttribute(Const.SESSION_PORTAL)) : null;
            if (portal == null) {
                logger.error(
                        "Access to proxy-servlet is forbidden, "
                        + "user must be logged in an have Portal instance in session");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            parameters = MISPUtils.getParameterMap(request);
            String attachmentParam = parameters.get("attachment");
            boolean processAttachments = attachmentParam != null && attachmentParam.equals("true");

            Org sessionOrg = (Org) session.getAttribute(Const.SESSION_ACTIVE_ORG);
            Person sessionUser = (Person) session.getAttribute(Const.SESSION_USER_HANDLE);

            // wrap request input stream with custom InputStream implementation,
            // read it, parse XML to SOAP-message in order to
            // 1) override X-Road SOAP headers
            // 2) log request
            // 3) set attachments
            MediatorRequestInputStream processedRequestInputStream = new MediatorRequestInputStream(request, portal,
                    sessionOrg, sessionUser, processAttachments, xroadInstanceService,
                    new QueryLogProperties(parameters.get("mainServiceHumanReadableName"),
                            parameters.get("mainServiceFullIdentifier"), queryLogService));

            // forward the request to portal.messageMediator URL
            String urlStr = portal.getMessageMediator();
            URL url = XRoadUtil.getMediatorServiceEndpointUrlWithTimeouts(urlStr);
            HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setDoOutput(true);

            processedRequestInputStream.copyHeaders(urlConnection);
            OutputStream enpointRequestStream = urlConnection.getOutputStream();
            // copy processed request input stream to target URL (security
            // server) output stream
            IOUtils.copy(processedRequestInputStream, enpointRequestStream);

            // wrap response input stream with custom InputStream
            // implementation. Again, process response SOAP-Message
            // 1) log errors + query time and size
            // 2) extract attachments
            MediatorResponseInputStream processedResponseInputStream = new MediatorResponseInputStream(urlConnection,
                    processedRequestInputStream.getQueryLog(), response, t0,
                    processedRequestInputStream.getSoapAttachmentProcessor(), queryLogService);

            // copy processed security server response input stream back to
            // client
            IOUtils.copy(processedResponseInputStream, response.getOutputStream());
        } catch (Exception e) {
            long queryDuration = new Date().getTime() - t0;
            String queryDurationStr = " Query duration: " + queryDuration + " ms.";
            logger.error("Proxying query to security server failed." + queryDurationStr + " Hash: " + e.hashCode(), e);
            response.reset();
            setResponseSoapFault(response, e);
        }
    }

    private void setResponseSoapFault(HttpServletResponse response, Exception cause) {
        try {
            SOAPMessage soapMessage = MessageFactory.newInstance(SOAPConstants.SOAP_1_1_PROTOCOL).createMessage();
            SOAPFault fault = soapMessage.getSOAPBody().addFault();
            if (cause instanceof java.net.SocketTimeoutException) {
                fault.setFaultCode("QUERY_TIMEOUT");
                fault.setFaultString("Query timed out (local). Exception identifier: " + cause.hashCode());
            } else {
                fault.setFaultCode("" + cause.hashCode());
                fault.setFaultString("Query failed. Exception identifier: " + cause.hashCode());
            }
            response.getOutputStream().write(XRoadUtil.soapMessageToByteArrayOutputStream(soapMessage).toByteArray());
            response.setContentType(CONTENT_TYPE_TEXT_XML);
            logger.debug("Assembled SOAP-Fault");
        } catch (SOAPException | IOException e) {
            logger.error("Could not initialize SOAPMessage to generate SOAPFault", e);
        }
    }
}
