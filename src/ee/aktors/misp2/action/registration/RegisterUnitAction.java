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

package ee.aktors.misp2.action.registration;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.configuration.Configuration;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.action.SecureLoggedAction;
import ee.aktors.misp2.beans.T3SecWrapper;
import ee.aktors.misp2.csrfProtection.ApplyCSRFProtectionAlways;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.service.ClassifierService;
import ee.aktors.misp2.service.ManagerCandidateService;
import ee.aktors.misp2.service.OrgService;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.CountryUtil;
import ee.aktors.misp2.util.LogQuery;
import ee.aktors.misp2.util.MenuUtil;
import ee.aktors.misp2.util.Roles;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.query.unit.OrgPortalAuthQuery;
import ee.aktors.misp2.util.xroad.soap.query.unit.OrgPortalAuthQueryBuilder;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitAuthQuery;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf.AuthQueryConf;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf.OrgPortalAuthQueryConf;

/**
 *
 * @author arnis.rips
 */
public class RegisterUnitAction extends SecureLoggedAction {
    private static final long serialVersionUID = -5211187483923627459L;
    private static final Logger LOGGER = LogManager.getLogger(RegisterUnitAction.class);
    private static final int COUNRTY_CODE_LENGTH = 2;
    // XXX: HARDCODED constants
    private static final String DEFAULT_COUNTRY_CODE = CountryUtil.getDefaultCountry().getCountry();
    // constructor added
    protected final OrgService serviceOrg;
    protected final UserService serviceUser;
    protected final ManagerCandidateService serviceMgrCand;
    protected final ClassifierService serviceClssf;
    protected final Configuration orgPortalConfiguration;
    protected final Configuration univPortalConfiguration;
    // --
    private String orgCode; // for getting URL parameters
    private Org activeOrg;
    protected Person activeUser;
    private List<Org> allowedOrgList = new ArrayList<Org>();
    private List<Org> unknownOrgList = new ArrayList<Org>();
    protected boolean registerUnknown = false;
    protected String redirectAction;
    private UnitQueryConf unitQueryConf;
    /**
     * For redirecting to registerUnit
     */
    private String sessionCSRFToken;

    /**
     * @param orgService orgService to inject
     * @param uService   uService   to inject
     * @param clService  clService  to inject
     * @param mcService  mcService  to inject
     * @param orgPortalConfiguration  orgPortalConfiguration  to inject
     * @param univPortalConfiguration univPortalConfiguration to inject
     * @param unitQueryConf unitQueryConf to inject
     */
    public RegisterUnitAction(OrgService orgService, UserService uService, ClassifierService clService,
            ManagerCandidateService mcService, Configuration orgPortalConfiguration,
            Configuration univPortalConfiguration, UnitQueryConf unitQueryConf) {
        super(uService);
        this.serviceOrg = orgService;
        this.serviceUser = uService;
        this.serviceClssf = clService;
        this.serviceMgrCand = mcService;
        this.orgPortalConfiguration = orgPortalConfiguration;
        this.univPortalConfiguration = univPortalConfiguration;
        this.unitQueryConf = unitQueryConf;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String registerUkUnit() {
        return SUCCESS;
    }
    @Override
    public void prepare() throws Exception {
        super.prepare();

        HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(StrutsStatics.HTTP_REQUEST);
        sessionCSRFToken = (String) request.getSession().getAttribute(Const.SESSION_CSRF_TOKEN);
    }

    /**
     * @return ERROR if registering fails, SUCCESS otherwise
     * @throws Exception if null pointer
     */
    @SuppressWarnings("unchecked")
    @HTTPMethods(methods = { HTTPMethod.GET, HTTPMethod.POST })
    // TODO  Should be only POST, but some actions redirect to this method
    @ApplyCSRFProtectionAlways
    public String registerUnit() throws Exception {
        List<Org> orgList = null;
        LogManager.getLogger(this.getClass()).debug("registerUnknown = " + registerUnknown);
        // TODO  REMOVE - // registerUnknown
        if (registerUnknown) {
            orgList = (List<Org>) session.get(Const.SESSION_UNKNOWN_ORG_LIST);
        } else {
            orgList = (List<Org>) session.get(Const.SESSION_ALLOWED_ORG_LIST);
        }
        LogManager.getLogger(this.getClass()).debug("orgList = " + orgList);
        // TODO  REMOVE - orgList

        boolean unitExists = false;
        if (orgCode != null) {

            Org activeOrgPrivate = null;
            if (orgList != null && !orgList.isEmpty()) {
                for (Org o : orgList) {
                    if (o.getCode().equals(orgCode)) {
                        activeOrgPrivate = o;
                        break;
                    }
                }
            }

            LogManager.getLogger(this.getClass()).debug("active_org = " + activeOrgPrivate); // TODO REMOVE - active_org
            if (activeOrgPrivate != null) {
                // Org exOrg = serviceOrg.findExistingSubOrg(portal, orgCode);
                Org mainOrg = serviceOrg.reAttach(portal.getOrgId(), Org.class);
                List<Org> subOL = mainOrg.getOrgList();
                Org exOrg = null;
                for (Org so : subOL) {
                    if (so.getCode().equals(orgCode)) {
                        exOrg = so;
                        unitExists = true;
                        break;
                    }
                }

                if (exOrg == null) {
                    activeOrgPrivate.setSupOrgId(serviceOrg.reAttach(((Portal) session.get(Const.SESSION_PORTAL))
                            .getOrgId(),
                            Org.class));
                    T3SecWrapper t3 = initT3(LogQuery.UNIT_ADD);
                    if (!log(t3)) {
                        addActionError(getText("text.fail.save.log"));
                        LogManager.getLogger(RegisterUnitAction.class).warn(
                                "Adding new unit failed because of logging problems");
                        return ERROR;
                    }
                    serviceOrg.save(activeOrgPrivate); // new org, save it

                } else {
                    activeOrgPrivate = exOrg;
                }
            }
            LogManager.getLogger(this.getClass()).debug("active_org to session= " + activeOrgPrivate);
            // TODO REMOVE - active_org
            session.put(Const.SESSION_ACTIVE_ORG, activeOrgPrivate);
            if (unitExists) {
                addActionMessage(getText("units.register.exists"));
            } else {
                addActionMessage(getText("units.register.success"));
            }
            if (!registerUnknown) {
                session.put(Const.SESSION_USER_ROLE, Roles.REPRESENTATIVE); // gets automatically manager role (for this
                                                                            // session)
                redirectAction = MenuUtil.MENU_AC_REG_USER.get(0);
            } else {
                session.put(Const.SESSION_USER_ROLE, Roles.LIMITED_REPRESENTATIVE);
                redirectAction = MenuUtil.MENU_AC_REG_UK_MANAGER.get(0);
            }

            return SUCCESS;
        } else {
            addActionError(getText("text.invalid_orgcode"));
            return ERROR;
        }
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String execute() throws Exception {
        if (portal == null) {
            LogManager.getLogger(RegisterUnitAction.class).error("Portal is null");
            return ERROR;
        }
        if (portal.getMispType() != Const.MISP_TYPE_ORGANISATION && portal.getMispType() != Const.MISP_TYPE_UNIVERSAL) {
            addActionError(getText("text.invalid.portal_type"));
            return ERROR; // invalid portal type
        }
        try {
            activeOrg = serviceOrg.reAttach(portal.getOrgId(), Org.class);
            activeUser = user;
            if (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL) {
                LOGGER.debug("UnivPortal auth query: " + portal.getUnivAuthQuery());
                AuthQueryConf authQueryConf = unitQueryConf.getAuthQueryConf(portal.getUnivAuthQuery());
                UnitAuthQuery xRoadQuery = new UnitAuthQuery(authQueryConf, univPortalConfiguration,
                        DEFAULT_COUNTRY_CODE, COUNRTY_CODE_LENGTH, activeUser, activeOrg);
                xRoadQuery.createSOAPRequest();
                logUnivAuthQuery();
                xRoadQuery.sendRequest();
                xRoadQuery.processResponse(allowedOrgList);
            } else if (portal.getMispType() == Const.MISP_TYPE_ORGANISATION) {
                LOGGER.info("OrgPortal auth query: " + portal.getUnivAuthQuery());
                OrgPortalAuthQueryConf orgPortalAuthQueryConf = unitQueryConf.getOrgPortalAuthQueryConf(portal
                        .getUnivAuthQuery());
                OrgPortalAuthQuery xRoadQuery = new OrgPortalAuthQuery(new OrgPortalAuthQueryBuilder()
                        .setOrgPortalAuthQueryConf(orgPortalAuthQueryConf)
                        .setOrgPortalConfiguration(orgPortalConfiguration).setConfig(CONFIG)
                        .setDefaultCountryCode(DEFAULT_COUNTRY_CODE).setCountryCodeLength(COUNRTY_CODE_LENGTH)
                        .setUser(activeUser).setOrg(serviceOrg.reAttach(portal.getOrgId(), Org.class))
                        .setLocale(getLocale()));
                xRoadQuery.createSOAPRequest();
                logUnivAuthQuery();
                xRoadQuery.sendRequest();
                xRoadQuery.processResponse(allowedOrgList, unknownOrgList);
                if (xRoadQuery.getBoardOfDirectors() != null) {
                    session.put(Const.SESSION_BOARD_OF_DIRECTORS, xRoadQuery.getBoardOfDirectors());
                }

            }

            session.put(Const.SESSION_ALLOWED_ORG_LIST, allowedOrgList); // units, where user can get manager role
            session.put(Const.SESSION_UNKNOWN_ORG_LIST, unknownOrgList); // units, where user can't get manager role

            return SUCCESS;
        } catch (DataExchangeException e) {
            LOGGER.error("Unit auth X-Road query failed", e);
            addActionError(getText("manager.error.query_failed") + e.getFaultSummary());
            return ERROR;
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), e);
            addActionError(getText("manager.error.query_failed"));
            return ERROR;
        }
    }

    private void logUnivAuthQuery() {
        // --- Log "Esindusõiguste kontroll"
        T3SecWrapper t3 = initT3(LogQuery.REPRESENTION_CHECK);
        t3.getT3sec().setQuery(portal.getUnivAuthQuery());
        if (!log(t3)) {
            LogManager.getLogger(RegisterUnitAction.class).error(
                    "'" + getText(ACTION_TEXT_PREFIX + LogQuery.REPRESENTION_CHECK) + "' NOT LOGGED");
        }
        // ----- end log "Esindusõiguste kontroll" ----- //
    }

    /**
     * @return the orgCode
     */
    public String getOrgCode() {
        return orgCode;
    }

    /**
     * @param orgCodeNew the orgCode to set
     */
    public void setOrgCode(String orgCodeNew) {
        this.orgCode = orgCodeNew;
    }

    /**
     * @return the allowedOrgList
     */
    public List<Org> getAllowedOrgList() {
        return allowedOrgList;
    }

    /**
     * @param allowedOrgListNew the allowedOrgList to set
     */
    public void setAllowedOrgList(List<Org> allowedOrgListNew) {
        this.allowedOrgList = allowedOrgListNew;
    }

    /**
     * @return the unknownOrgList
     */
    public List<Org> getUnknownOrgList() {
        return unknownOrgList;
    }

    /**
     * @param unknownOrgListNew the unknownOrgList to set
     */
    public void setUnknownOrgList(List<Org> unknownOrgListNew) {
        this.unknownOrgList = unknownOrgListNew;
    }

    /**
     * @return the registerUnknown
     */
    public boolean isRegisterUnknown() {
        return registerUnknown;
    }

    /**
     * @param registerUnknownNew the registerUnknown to set
     */
    public void setRegisterUnknown(boolean registerUnknownNew) {
        this.registerUnknown = registerUnknownNew;
    }

    /**
     * @return the redirectAction
     */
    public String getRedirectAction() {
        return redirectAction;
    }

    /**
     * @param redirectActionNew the redirectAction to set
     */
    public void setRedirectAction(String redirectActionNew) {
        this.redirectAction = redirectActionNew;
    }

  

}
