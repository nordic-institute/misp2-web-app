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

package ee.aktors.misp2.action;

import java.io.IOException;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.action.SecureLoggedAction;
import ee.aktors.misp2.beans.Auth;
import ee.aktors.misp2.beans.Auth.AUTH_TYPE;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.PersonEula;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.service.EulaService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.DateUtil;
import ee.aktors.misp2.util.JsonUtil;
import ee.aktors.misp2.util.MISPUtils;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * Action for accepting/rejecting EULA and storing necessary changes to DB.
 */
public class EulaAction extends SecureLoggedAction implements StrutsStatics {
    private static final long serialVersionUID = 1L;
    private static final Logger LOG = LogManager.getLogger(EulaAction.class);
    private EulaService eulaService;

    /**
     * Initialize action
     * @param eulaServiceNew EULA service for DB interaction
     */
    public EulaAction(EulaService eulaServiceNew) {
        super(null);
        this.eulaService = eulaServiceNew;
    }

    /**
     * User has accepted EULA. Create necessary changes
     * @return null to avoid Struts2 response handling
     * @throws IOException on JSON mapping failure
     */
    @HTTPMethods(methods = { HTTPMethod.GET, HTTPMethod.POST })
    public String acceptEula() throws IOException {
        handlePersonEulaStatusChangeJson(true);
        return null;
    }

    /**
     * User has rejected EULA. Add necessary changes.
     * @return null to avoid Struts2 response handling
     * @throws IOException on JSON mapping failure
     */
    @HTTPMethods(methods = { HTTPMethod.GET, HTTPMethod.POST })
    public String rejectEula() throws IOException {
        handlePersonEulaStatusChangeJson(false);
        return null;
    }

    private void handlePersonEulaStatusChangeJson(boolean accept) throws IOException {
        HttpServletResponse response = (HttpServletResponse) ActionContext.getContext().get(HTTP_RESPONSE);
        response.setContentType(JsonUtil.JSON_CONTENT_TYPE);
        ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
        
        try {
            PersonEula personEula = savePersonEula(accept);
            
            Map<String, Object> respMap =  new LinkedHashMap<String, Object>();
            eulaService.savePendingEulasToSession(session);
            
            respMap.put("personEula", getPersonEulaResponseMap(personEula));
            response.setStatus(HttpServletResponse.SC_OK);
            ow.writeValue(response.getWriter(), respMap);
        } catch (DataExchangeException e) {
            LOG.error("Accepting EULA query failed", e);
            Map<String, Object> respMap = JsonUtil.getErrorResponseMap(
                    e.getType().toString(), getText(e.getTranslationCode(), e.getParameters()));
            ow.writeValue(response.getWriter(), respMap);
        }
    }
    
    /**
     * Create or query suitable PersonEula object (by current user and selected portal) from DB.
     * @param accept true, if EULA was accepted, false if rejected
     * @return PersonEula entity
     * @throws DataExchangeException on various state change exception,
     * for example modifying already accepted PersonEula entry is not allowed.
     */
    private PersonEula savePersonEula(boolean accept) throws DataExchangeException {
        if (portal == null || !eulaService.isEulaInUse(portal)) {
            throw new DataExchangeException(
                    DataExchangeException.Type.EULA_NOT_USED_IN_PORTAL,
                    "Eula is not configured for portal " + portal + ".", null);
        }
        if (user == null) {
            throw new DataExchangeException(
                    DataExchangeException.Type.EULA_USER_NOT_FOUND,
                    "User was not found from session.", null);
        }
        HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
        
        // Get client IP address
        String ipAddress = MISPUtils.getSourceIp(request);
        
        // Get client Authentication method
        Auth auth = (Auth)session.get(Const.SESSION_AUTH);
        String authMethod = AUTH_TYPE.getXrdTypeFor(auth.getType());
        
        if (accept) {
            LOG.debug("Accepting EULA: portal " + portal + " - user " + user);
        } else {
            LOG.debug("Rejecting EULA: portal " + portal + " - user " + user);
        }

        PersonEula personEula = savePersonEula(portal, user, accept, ipAddress, authMethod);
        return personEula;
    }

    /**
     * Create map for JSON response of PersonEula entity.
     * @param personEula PersonEula entity
     * @return map with most important parameters from the entity
     */
    private Map<String, Object> getPersonEulaResponseMap(PersonEula personEula) {
        Map<String, Object> personEulaMap =  new LinkedHashMap<String, Object>();
        personEulaMap.put("id", personEula.getId());
        personEulaMap.put("person_id", personEula.getPerson().getId());
        personEulaMap.put("portal_id", personEula.getPortal().getId());
        personEulaMap.put("accepted", personEula.getAccepted());
        personEulaMap.put("created", DateUtil.convertDateToUsDate(personEula.getCreated()));
        personEulaMap.put("modified", DateUtil.convertDateToUsDate(personEula.getLastModified()));
        return personEulaMap;
    }

    /**
     * Create or modify PersonEula entity for given portal and user,
     * setting  'accepted' field to specified value.
     * FIXME: 
     *  For implementation reasons, saving cannot be executed within service. 
     *  Getting "possible non-threadsafe access to session" error.
     * @param portal Portal entity associated with PersonEula entity
     * @param person user entity associated with PersonEula entity
     * @param accepted boolean value specifying whether EULA was
     *        accepted or rejected by the user in given portal
     * @return modified PersonEula entity. <br/>
     *         Entity is detached from Hibernate session: the modifications are not persisted..
     */
    private PersonEula savePersonEula(Portal portal, Person person, boolean accepted, String srcAddr, String authMethod)
            throws DataExchangeException {
        PersonEula personEula = eulaService.findPersonEula(portal, person);
        if (personEula == null) {
            LOG.debug("Creating new PersonEula instance.");
            personEula = new PersonEula();
            personEula.setPortal(portal);
            personEula.setPerson(person);
        } else {
            LOG.debug("Found existing PersonEula instance: " + personEula);
            if (personEula.getAccepted() != null && personEula.getAccepted().booleanValue()) {
                throw new DataExchangeException(
                        DataExchangeException.Type.EULA_ALREADY_ACCEPTED,
                        "EULA has been already accepted PersonEula[id=" + personEula.getId()
                            + "]. Cannot alter it after the fact.", null);
            }
        }
        
        personEula.setAccepted(accepted);
        personEula.setSrcAddr(srcAddr);
        personEula.setAuthMethod(authMethod);
        personEula.setLastModified(new Date());
        eulaService.save(personEula);
        eulaService.detach(personEula);
        return personEula;
    }
}
