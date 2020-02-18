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

package ee.aktors.misp2.interceptor;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.configuration.Configuration;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.ActionSupport;

import ee.aktors.misp2.action.exception.RoleNotAllowedException;
import ee.aktors.misp2.beans.Auth;
import ee.aktors.misp2.model.CheckRegisterStatus;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.OrgValid;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.service.PortalService;
import ee.aktors.misp2.util.ArrayUtils;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.CountryUtil;
import ee.aktors.misp2.util.Roles;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitCheckQuery;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf.CheckQueryConf;

/**
 *
 */
public class RoleChangeInterceptor extends BaseInterceptor {
    private static final long serialVersionUID = -4724797107579299735L;
    private static final Logger LOGGER = LogManager.getLogger(RoleChangeInterceptor.class.getName());
    private static final int CHECK_INTERVAL_MIN = 5;
    private PortalService portalService;
    private Org currentOrg;
    private ActionSupport action;
    protected final Configuration univConfiguration;
    private static final String DEFAULT_COUNTRY_CODE = CountryUtil.getDefaultCountry().getCountry();
    private UnitQueryConf unitQueryConf;

    /**
     * Dependency injection
     * @param portalService portalService
     * @param univConfiguration univConfiguration
     * @param unitQueryConf unitQueryConf
     */
    public RoleChangeInterceptor(PortalService portalService, Configuration univConfiguration,
            UnitQueryConf unitQueryConf) {
        this.portalService = portalService;
        this.univConfiguration = univConfiguration;
        this.unitQueryConf = unitQueryConf;
    }

    @SuppressWarnings("unchecked")
    @Override
    public String intercept(ActionInvocation invocation) throws Exception {
        Map<String, Object> session = invocation.getInvocationContext().getSession();
        Portal portal = null;
        HashMap<String, String> roles;
        action = ((ActionSupport) invocation.getAction());

        if (session.get(Const.SESSION_PORTAL) instanceof Portal) {
            portal = (Portal) session.get(Const.SESSION_PORTAL);
            if (portal.getId() != null) {
                portal = portalService.reAttach(portal, Portal.class);
            }
        }

        roles = explodeRepresentatives(session);

        Auth auth = ((Auth) session.get(Const.SESSION_AUTH));

        if (session.get(Const.SESSION_USER_HANDLE) == null || auth == null || auth.isAdmin()) {

            LOGGER.error("NO USER or user is admin"); // no user - no roles
            return invocation.invoke();
        } else {

            Person user = portalService.reAttach((Person) session.get(Const.SESSION_USER_HANDLE), Person.class);
            String dumbUser = getText("roles." + Roles.DUMBUSER);
            String permManager = getText("roles." + Roles.PERMISSION_MANAGER);
            String developer = getText("roles." + Roles.DEVELOPER);
            String portalManager = getText("roles." + Roles.PORTAL_MANAGER);
            String unregistered = getText("roles." + Roles.UNREGISTERED);

            Integer role = (Integer) session.get(Const.SESSION_USER_ROLE);

            boolean citizenPortal = portal.getMispType() == Const.MISP_TYPE_CITIZEN;
            boolean isRoleAllowed = true;

            String actionName = ActionContext.getContext().getName();
            if (actionName.startsWith("login_")) {
                try {
                    role = doRoleChange(invocation);
                } catch (DataExchangeException e) {
                    isRoleAllowed = false;
                    addActionError(invocation, getText("portal.change.error") + e.getFaultSummary());
                    LOGGER.error("Unit check X-Road query failed. User not authorized for role. | " + "action="
                            + actionName + ", role=" + role, e);
                    // return UNAUTHORIZED;
                } catch (RoleNotAllowedException roleNotAllowedException) {
                    isRoleAllowed = false;
                    addActionError(invocation, roleNotAllowedException.getMessage());
                    LOGGER.warn("User not authorized because role is not allowed: action=" + actionName + ", role="
                            + role + " " + roleNotAllowedException.getMessage());
                    // return UNAUTHORIZED;
                }
            }

            if (portal.getMispType() == Const.MISP_TYPE_ORGANISATION) {
                roles.put(Roles.ROLE_UNREGISTERED, unregistered);
            } else if (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL) {
                if (portal.getRegisterUnits().booleanValue()) {
                    roles.put(Roles.ROLE_UNREGISTERED, unregistered);
                }
            } else if (citizenPortal) {
                roles.put(Roles.ROLE_DUMBUSER + portal.getOrgId().getId(), dumbUser);
            }

            boolean representative = role != null && (Roles.REPRESENTATIVE == role
                    || Roles.LIMITED_REPRESENTATIVE == role);
            if (representative) {
                interceptRepresentative(role, (Org) session.get(Const.SESSION_ACTIVE_ORG), roles);
            } else {
                Iterator<String> i = roles.keySet().iterator();
                while (i.hasNext()) {
                    String key = i.next();
                    if (key.startsWith(Roles.ROLE_REPRESENTATIVE) || key.startsWith(Roles.ROLE_LTD_REPRESENTATIVE)) {
                        roles.remove(key);
                        break;
                    }
                }
            }

            List<OrgPerson> orgPersonList = portalService.findPortalOrgPersons(portal, user);

            boolean oneOrgPortal = portal.getMispType() == Const.MISP_TYPE_CITIZEN
                    || portal.getMispType() == Const.MISP_TYPE_SIMPLE;

            if (orgPersonList != null) {
                Org tempOrg = null;
                for (OrgPerson temp : orgPersonList) {

                    tempOrg = temp.getOrgId();

                    List<Org> subOrgs = portalService.findSubOrgs(portal.getOrgId());
                    if (subOrgs == null) {
                        LOGGER.debug("No sub orgs found for org: " + portal.getOrgId());
                        subOrgs = new ArrayList<Org>();
                    }
                    if (tempOrg != null) {
                        String orgName = tempOrg.getActiveName(getLocale().getLanguage());
                        for (int j : Roles.getAllRolesSet(temp.getRole())) {
                            switch (j) {
                            case Roles.DUMBUSER:
                                roles.put(Roles.ROLE_DUMBUSER + tempOrg.getId(), dumbUser
                                        + (oneOrgPortal ? "" : " (" + orgName + "/" + tempOrg.getCode() + ")"));
                                break;
                            case Roles.PERMISSION_MANAGER:
                                roles.put(Roles.ROLE_PERMISSION_MANAGER + tempOrg.getId(), permManager
                                        + (oneOrgPortal || !oneOrgPortal && tempOrg.getSupOrgId() == null ? "" : " ("
                                                + orgName + "/" + tempOrg.getCode() + ")"));
                                break;
                            case Roles.DEVELOPER:
                                roles.put(Roles.ROLE_DEVELOPER + tempOrg.getId(), developer
                                        + (oneOrgPortal || !oneOrgPortal && tempOrg.getSupOrgId() == null ? "" : " ("
                                                + orgName + ")"));
                                break;
                            case Roles.PORTAL_MANAGER:
                                roles.put(Roles.ROLE_PORTAL_MANAGER + tempOrg.getId(), portalManager);
                                break;
                            default:
                                break;
                            }
                        }
                    }
                }
            }

            roles = ArrayUtils.sortHashMap(roles);

            LOGGER.debug("roles to session= " + roles);
            synchronized (session) {
                session.put(Const.SESSION_ALL_ROLES, roles);
            }
            if (!isRoleAllowed) {
                return UNAUTHORIZED;
            }
            return invocation.invoke();
        }
    }

    private HashMap<String, String> explodeRepresentatives(Map<String, Object> session) {
        @SuppressWarnings("unchecked")
        HashMap<String, String> rlz = (HashMap<String, String>) session.get(Const.SESSION_ALL_ROLES);
        HashMap<String, String> res = new HashMap<String, String>();

        if (rlz != null && !rlz.isEmpty()) {
            for (String key : rlz.keySet()) {
                if (key.startsWith(Roles.ROLE_REPRESENTATIVE) || key.startsWith(Roles.ROLE_LTD_REPRESENTATIVE)) {
                    res.put(key, rlz.get(key));
                }
            }
        }
        return res;
    }

    private Integer doRoleChange(ActionInvocation ai) throws RoleNotAllowedException, DataExchangeException, Exception {
        // roleselection changed
        int role = 0;
        Map<String, Object> session = ai.getInvocationContext().getSession();
        Portal portal = (Portal) session.get(Const.SESSION_PORTAL);
        String actionName = ActionContext.getContext().getName();

        if (actionName.equals("login_user")) {
            role = Roles.DUMBUSER;
        } else if (actionName.equals("login_perm_manager")) {
            role = Roles.PERMISSION_MANAGER;
        } else if (actionName.equals("login_developer")) {
            role = Roles.DEVELOPER;
        } else if (actionName.equals("login_manager")) {
            role = Roles.PORTAL_MANAGER;
        } else if (actionName.equals("login_unregistered")) {
            role = Roles.UNREGISTERED;
        } else if (actionName.equals("login_representative")) {
            role = Roles.REPRESENTATIVE;
        } else if (actionName.equals("login_limited_representative")) {
            role = Roles.LIMITED_REPRESENTATIVE;
        }
        portal = portalService.reAttach(portal, Portal.class);
        LOGGER.debug("portal = " + portal);

        Integer orgId = (Integer) ((HttpServletRequest) ai.getInvocationContext().get(HTTP_REQUEST))
                .getAttribute("orgId");

        if (orgId != null) {
            currentOrg = portalService.findObject(Org.class, orgId);
            if (currentOrg == null) {
                return (Integer) session.get(Const.SESSION_USER_ROLE);
            }
        } else {
            if (session.get(Const.SESSION_ACTIVE_ORG) instanceof Org) {
                currentOrg = portalService.reAttach((Org) session.get(Const.SESSION_ACTIVE_ORG), Org.class);
            }
        }
        if (currentOrg == null) {
            currentOrg = portalService.findObject(Org.class, portal.getOrgId().getId());
        }
        LOGGER.debug("4. nochange " + currentOrg);
        boolean isValidOrg = true;
        Integer univCheckValidTime = portal.getUnivCheckValidTime();
        if (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL && role != Roles.UNREGISTERED
                && currentOrg.getSupOrgId() != null && univCheckValidTime != null && univCheckValidTime > 0) {
            OrgValid ov = currentOrg.getOrgValid();
            if (ov != null) {
                Calendar cal = Calendar.getInstance();
                cal.setTime(ov.getValidDate());
                cal.add(Calendar.HOUR_OF_DAY, univCheckValidTime);
                // DEBUG to always query from unitCheck service, add always true conditional
                if (cal.before(Calendar.getInstance())) {
                    LOGGER.info("Org valid has expired. Re-checking");
                    isValidOrg = checkOrgValidity(currentOrg, portal);
                } else {
                    isValidOrg = true;
                }
                logOrgValid("OrgValid entity exists", isValidOrg);

            } else {
                LOGGER.debug("First time checking orgs=" + currentOrg + " validity.");
                ov = new OrgValid();
                ov.setOrgId(currentOrg);
                Calendar cal = Calendar.getInstance();
                cal.setTimeInMillis(0);
                ov.setValidDate(cal.getTime());
                currentOrg.setOrgValid(ov);
                portalService.save(ov);
                isValidOrg = checkOrgValidity(currentOrg, portal);
                logOrgValid("OrgValid entity does not exist", isValidOrg);
            }

        }

        @SuppressWarnings("unchecked")
        Map<String, String> roleSelectItems = (Map<String, String>) session.get(Const.SESSION_ALL_ROLES);

        Map<String, Integer> roleMappings = Roles.instance().getRoleMappings();

        if (roleSelectItems != null) {
            for (String key : roleSelectItems.keySet()) {
                String type = key.substring(0, Roles.TYPE_LENGTH);
                Integer roleType = roleMappings.get(type);

                if (roleType.equals(role)) {

                    Integer oid = null;
                    if (key.length() > Roles.TYPE_LENGTH) {
                        String strOid = key.substring(Roles.TYPE_LENGTH);

                        try {
                            oid = Integer.valueOf(strOid);
                        } catch (NumberFormatException numberFormatException) {
                            LOGGER.debug("strOid has wrong format", numberFormatException);
                        }
                    }

                    if (orgId == null || oid.equals(orgId)) { // orgId is not required
                        synchronized (session) {
                            session.put(Const.SESSION_ACTIVE_ORG, currentOrg);
                            LOGGER.debug("set Session active org" + currentOrg);
                            session.put(Const.SESSION_USER_ROLE, role);
                        }
                        if (!isValidOrg) {
                            throw new RoleNotAllowedException(getText("portal.change.error"));
                        }
                        return role;
                    }
                }
            }
        } else {
            if (!isValidOrg) {
                throw new RoleNotAllowedException(getText("portal.change.error"));
            }
            return (Integer) session.get(Const.SESSION_USER_ROLE);
        }
        throw new RoleNotAllowedException(action.getText("message.restricted_area"));
    }

    private void logOrgValid(String remark, boolean isValidOrg) {
        if (!isValidOrg) {
            LOGGER.error(remark + " " + "Org is not valid not allowing this change");
        } else {
            LOGGER.debug(remark + " " + "Org is valid");
        }
    }

    private void interceptRepresentative(int role, Org org, HashMap<String, String> roles) throws Exception {
        LOGGER.debug("REPRESENTAIVE USER");

        Org activeOrg = portalService.reAttach(org, Org.class);

        if (activeOrg != null) {
            String repr = action.getText("roles." + role);
            roles.put((role == Roles.REPRESENTATIVE ? Roles.ROLE_REPRESENTATIVE : Roles.ROLE_LTD_REPRESENTATIVE)
                    + activeOrg.getId(), repr + " (" + activeOrg.getActiveName(getLocale().getLanguage()) + ")");
        }
    }

    private boolean checkOrgValidity(Org org, Portal portal) throws DataExchangeException {
        CheckRegisterStatus registerStatus = portalService.findCheckRegisterStatus(portal.getUnivCheckQuery());
        Calendar maxValidTime = Calendar.getInstance();
        maxValidTime.setTime(org.getOrgValid().getValidDate());
        maxValidTime.add(Calendar.HOUR_OF_DAY, portal.getUnivCheckMaxValidTime());

        if (registerStatus == null || registerStatus.isOk()) {
            return runCheckQuery(org, portal, maxValidTime, registerStatus);
        } else {
            Calendar lastRun = Calendar.getInstance();
            lastRun.setTime(registerStatus.getQueryTime());
            lastRun.add(Calendar.MINUTE, CHECK_INTERVAL_MIN);
            Calendar now = Calendar.getInstance();
            if (lastRun.before(now)) {
                return runCheckQuery(org, portal, maxValidTime, registerStatus);
            } else if (maxValidTime.before(now)) {
                return false;
            } else {
                return true;
            }
        }
    }

    private boolean runCheckQuery(Org org, Portal portal, Calendar maxValidTime,
            CheckRegisterStatus registerStatus) throws DataExchangeException {
        LOGGER.debug("Running org validity check");
        Calendar now = Calendar.getInstance();
        if (registerStatus == null) {
            registerStatus = new CheckRegisterStatus();
            registerStatus.setQueryName(portal.getUnivCheckQuery());
        }
        try {
            boolean companyStatusOK = isCompanyStatusOK(org, portal);
            registerStatus.setOk(true);
            if (companyStatusOK) {
                OrgValid orgValid = org.getOrgValid();
                orgValid.setValidDate(now.getTime());
                portalService.save(orgValid);
                LOGGER.debug("Org status ok, refreshing valid date");
                return true;
            }
        } catch (DataExchangeException e) {
            throw e;
        } catch (Exception e) {
            LOGGER.error("Org validity check returned error=" + e.getMessage(), e);
            registerStatus.setOk(false);
            if (maxValidTime.after(now)) {
                return true;
            }
        } finally {
            registerStatus.setQueryTime(now.getTime());
            portalService.save(registerStatus);
        }
        return false;
    }

    // actual check query
    private boolean isCompanyStatusOK(Org org, Portal portal) throws DataExchangeException {
        CheckQueryConf checkQueryConf = unitQueryConf.getCheckQueryConf(portal.getUnivCheckQuery());
        UnitCheckQuery xRoadQuery = new UnitCheckQuery(checkQueryConf, univConfiguration, DEFAULT_COUNTRY_CODE, org);
        xRoadQuery.createSOAPRequest();
        xRoadQuery.sendRequest();
        return xRoadQuery.isResponseValid(); // the response of soap message should be true to keep this org in a list
    }

    /**
     * Get portalService
     * @return portalService
     */
    public PortalService getPortalService() {
        return portalService;
    }

    /**
     * Set portalService
     * @param pService PortalService to set as portalService
     */
    public void setPortalService(PortalService pService) {
        this.portalService = pService;
    }

}
