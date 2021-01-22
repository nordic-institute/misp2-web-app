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

package ee.aktors.misp2.action.admin;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.action.SecureLoggedAction;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.JsonUtil;
import ee.aktors.misp2.util.Roles;
import ee.aktors.misp2.util.xroad.XRoadInstanceUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * Action for downloading list of federated X-Road instances from security server.
 */
public class XroadInstanceAction extends SecureLoggedAction implements StrutsStatics {
    private static final long serialVersionUID = 1L;
    private static final Logger LOG = LogManager.getLogger(XroadInstanceAction.class);

    /**
     * Initialize action
     */
    public XroadInstanceAction() {
        super(null);
    }

    /**
     * @return null to avoid Struts2 response handling
     * @throws IOException on JSON mapping failure
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String getXroadInstances() throws IOException {
        HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
        HttpServletResponse response = (HttpServletResponse) ActionContext.getContext().get(HTTP_RESPONSE);

      //ApplicationContext context = WebApplicationContextUtils.getWebApplicationContext(getServletContext());
        response.setContentType(JsonUtil.JSON_CONTENT_TYPE);
        ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
        try {
            HttpSession session = request.getSession();
            Object userRole = session.getAttribute(Const.SESSION_USER_ROLE);
            // Only application administrator can perform this action
            if (userRole == null || !userRole.equals(Roles.PORTAL_ADMIN)) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_INSTANCE_QUERY_NOT_ADMIN,
                        "User is not portal admin.", null);
            }
            final String secServerBaseUrlParamName = "secServerUrl";
            String secServerBaseUrl = request.getParameter(secServerBaseUrlParamName);
            if (secServerBaseUrl == null || secServerBaseUrl.isEmpty()) {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_INSTANCE_QUERY_URL_MISSING,
                        "Parameter '" + secServerBaseUrlParamName + "' is missing.", null);
            }
            
            LOG.debug("Getting federated instances from  " + secServerBaseUrl);
            
            List<String> federatedInstances = XRoadInstanceUtil.getFederatedInstances(secServerBaseUrl);
            response.setStatus(HttpServletResponse.SC_OK);
            ow.writeValue(response.getWriter(), federatedInstances);
        } catch (DataExchangeException e) {
            LOG.error("Federated instances query failed", e);
            Map<String, Object> respMap = JsonUtil.getErrorResponseMap(
                    e.getType().toString(), getText(e.getTranslationCode(), e.getParameters()));
            ow.writeValue(response.getWriter(), respMap);
        }
        
        return null;
    }
}
