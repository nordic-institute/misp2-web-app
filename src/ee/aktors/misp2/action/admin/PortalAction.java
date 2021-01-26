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

package ee.aktors.misp2.action.admin;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.interceptor.validation.SkipValidation;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.Validateable;

import edu.emory.mathcs.backport.java.util.Collections;
import ee.aktors.misp2.action.SecureLoggedAction;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgName;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.PortalEula;
import ee.aktors.misp2.model.PortalName;
import ee.aktors.misp2.model.XroadInstance;
import ee.aktors.misp2.service.EulaService;
import ee.aktors.misp2.service.OrgService;
import ee.aktors.misp2.service.PortalService;
import ee.aktors.misp2.service.XroadInstanceService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Const.XROAD_VERSION;
import ee.aktors.misp2.util.LanguageUtil;
import ee.aktors.misp2.util.xroad.soap.query.unit.UnitQueryConf;

/**
 *
 * @author arnis.rips
 */
public class PortalAction extends SecureLoggedAction implements Validateable {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LogManager.getLogger(PortalAction.class.getName());
    private static final Comparator<Portal> PORTAL_ALPHABETICAL_ORDER = new Comparator<Portal>() {
        @Override
        public int compare(Portal o1, Portal o2) {
            String language = ActionContext.getContext().getLocale().getLanguage();
            String activeName1 = o1.getActiveName(language);
            String activeName2 = o2.getActiveName(language);
            if (activeName1 == null) return -1;
            else if (activeName2 == null) return 1;
            else return activeName1.compareToIgnoreCase(activeName2);
        }
    };
    
    
    private ArrayList<String> languages = LanguageUtil.getLanguages();
    private PortalService portalService;
    private OrgService oService;
    private XroadInstanceService xroadInstanceService;
    private EulaService eulaService;
    private Integer portalId;
    private Portal portal;
    private List<PortalName> portalNames;
    private List<OrgName> orgNames;
    private List<XroadInstance> serviceXroadInstances;
    private List<PortalEula> portalEulas;
    private Org org;
    private List<Person> managers;
    private List<Portal> portals;
    private boolean univUseManger;
    private boolean useEula;
    private boolean useTopics;
    private boolean useXrdIssue;
    private boolean logQuery;
    private boolean unitIsConsumer;
    private boolean registerUnits;
    private UnitQueryConf unitQueryConf;
    private int debug;

    /**
     * 
     * @param portalService portalService to inject
     * @param oService oService to inject
     * @param xroadInstanceService injected service
     * @param unitQueryConf unitQueryConf to inject
     */
    public PortalAction(PortalService portalService, OrgService oService,
            XroadInstanceService xroadInstanceService, UnitQueryConf unitQueryConf, EulaService eulaService) {
        super(portalService);
        this.portalService = portalService;
        this.oService = oService;
        this.xroadInstanceService = xroadInstanceService;
        this.unitQueryConf = unitQueryConf;
        
        // Set defaults for new portal
        this.portal = new Portal();
        // Set X-Road protocol version to v6
        this.portal.setXroadProtocolVer(XROAD_VERSION.V6.getProtocolVersion());
        this.eulaService = eulaService;
    }

    @Override
    public void validate() {
        LOGGER.debug("Validating");
        final String strUAQ = "portal.univAuthQuery";
        final String strUCQ = "portal.univCheckQuery";
        final String strUCVT = "portal.univCheckValidTime";
        final String strUCMVT = "portal.univCheckMaxValidTime";
        final int minimumValidTime = 0;
        final int maximumValidTime = 1500;

        // always make sure univCheck query times are correct if they are given
        if (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL) {
            String univCheckQuery = portal.getUnivCheckQuery();
            Integer univCheckValidTime = portal.getUnivCheckValidTime();
            Integer univCheckMaxValidTime = portal.getUnivCheckMaxValidTime();

            if ((univCheckQuery == null || univCheckQuery.isEmpty()) && registerUnits) {
                    addFieldError(strUCQ, getText("validation.input_required"));
            }
            boolean compareTimes = true;
            if (univCheckValidTime == null) {
                if (registerUnits)
                    addFieldError(strUCVT, getText("validation.input_required"));
                compareTimes = false;
            } else if (univCheckValidTime.compareTo(minimumValidTime) < 0
                    || univCheckValidTime.compareTo(maximumValidTime) > 0) {
                addFieldError(
                        strUCVT,
                        getText("validation.in_action.not_in_range",
                                Arrays.asList(new Object[] {minimumValidTime, maximumValidTime })));
            }
            if (univCheckMaxValidTime == null) {
                if (registerUnits)
                    addFieldError(strUCMVT, getText("validation.input_required"));
                compareTimes = false;
            } else if (univCheckMaxValidTime.compareTo(minimumValidTime) < 0
                    || univCheckMaxValidTime.compareTo(maximumValidTime) > 0) {
                addFieldError(
                        strUCMVT,
                        getText("validation.in_action.not_in_range",
                                Arrays.asList(new Object[] {minimumValidTime, maximumValidTime })));
            }
            if (compareTimes && univCheckValidTime.compareTo(univCheckMaxValidTime) >= 0) {
                addFieldError(strUCVT, getText("validation.reg_lteq_max"));
            }
        }

        if (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL && registerUnits
                || portal.getMispType() == Const.MISP_TYPE_ORGANISATION) {
            String univAuthQuery = portal.getUnivAuthQuery();
            if (univAuthQuery == null || univAuthQuery.isEmpty()) {
                addFieldError(strUAQ, getText("validation.input_required"));
            } else if (!portal.isV6() && !univAuthQuery.contains(".")) {
                addFieldError(strUAQ, getText("validation.auth_query.no_prod_or_serv"));
            }
        }
        if (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL && portal.getUnivCheckQuery() == null
                || portal.getUnivCheckQuery().trim().isEmpty()) {
            final String validCheckTimeKey = "validation.check_query_not_defined";
            if (portal.getUnivCheckValidTime() != null) {
                String[] fieldNameArg = new String[] {getText("portal.label.universal_check_valid_time") };
                addFieldError("portal.univCheckValidTime", getText(validCheckTimeKey, fieldNameArg));
            }
            if (portal.getUnivCheckMaxValidTime() != null) {
                String[] fieldNameArg = new String[] {getText("portal.label.universal_check_max_valid_time") };
                addFieldError("portal.univCheckMaxValidTime", getText(validCheckTimeKey, fieldNameArg));
            }
        }

        if (portal.isV6()) {
            if (logQuery
                    && (portal.getMisp2XroadServiceMemberCode() == null
                        || portal.getMisp2XroadServiceMemberCode().trim().isEmpty())) {
                addFieldError("portal.misp2XroadServiceMemberCode", getText("validation.input_required"));
            }
            LOGGER.debug("Inspecting X-Road instances");
            // Service xroad instance validation
            // show generic field error message in case of error
            String xroadInstancesError =
                    xroadInstanceService.validateXroadInstances(portal, serviceXroadInstances);
            if (xroadInstancesError != null) {
                addFieldError("serviceXroadInstances", getText(xroadInstancesError));
            }
            if (portal.getClientXroadInstance() == null || portal.getClientXroadInstance().isEmpty()) {
                addFieldError("portal.clientXroadInstance", getText("validation.input_required"));
            }
        }
        if (useEula) {
            LOGGER.debug("EULA in use " + portal.getEulaInUse());
            for (int i = 0; i < languages.size(); i++) {
                PortalEula portalEula = portalEulas.get(i);
                if (StringUtils.isBlank(portalEula.getContent())) {
                    addFieldError("portalEulas[" + i + "].content", getText("validation.input_required"));
                }
            }
        }
        if (hasErrors()) {
            addActionError(getText("text.error.form_fields"));
        }
        LOGGER.debug("Validated. " + (hasErrors() ? "Has errors." : "No errors (during first validation step)."));
        Map<String, List<String>> errors = getFieldErrors();
        for (Entry<String, List<String>> error : errors.entrySet()) {
            LOGGER.debug("Found field error " + error.getKey() + " : " + error.getValue());
        }
    }

    @Override
    public void prepare() throws Exception {
        super.prepare();

        LOGGER.debug("portalId = " + portalId);
        if (portalId != null) {
            setPortal(portalService.findObject(Portal.class, portalId));
        }
        if (portal == null) {
            portal = new Portal();
            org = new Org();
            portal.setOrgId(org);
        } else {
            initServiceXRoadInstances();
            try {
                org = portalService.reAttach(portal.getOrgId(), Org.class);
            } catch (Exception e) {
                org = new Org();
                return;
            }
            if (org != null) {
                managers = portalService.findManagers(portal, org);
            } else {
                org = new Org();
            }

            initPortalNames();
            initOrgNames();
            initPortalEulas();
        }
    }

    /**
     * @return SUCCESS if finding portals is successful
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    @SkipValidation
    public String listPortals() {
        portals = portalService.findAllPortals();
        Collections.sort(portals, PORTAL_ALPHABETICAL_ORDER);
        return SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET, HTTPMethod.POST })
    @SkipValidation
    public String showPortal() {
        univUseManger = (portal.isUnivUseManger() != null ? portal.isUnivUseManger().booleanValue() : univUseManger);
        useTopics = (portal.getUseTopics() != null ? portal.getUseTopics().booleanValue() : useTopics);
        useXrdIssue = (portal.getUseXrdIssue() != null ? portal.getUseXrdIssue().booleanValue() : useXrdIssue);
        logQuery = (portal.getLogQuery() != null ? portal.getLogQuery().booleanValue() : logQuery);
        registerUnits = (portal.getRegisterUnits() != null ? portal.getRegisterUnits().booleanValue() : registerUnits);
        unitIsConsumer = (portal.getUnitIsConsumer() != null ? portal.getUnitIsConsumer().booleanValue()
                : unitIsConsumer);
        useEula = (portal.getEulaInUse() != null ? portal.getEulaInUse().booleanValue() : useEula);
        // debug = portal.getDebug();
        session.put(Const.SESSION_PORTAL, portal);
        session.put(Const.SESSION_ACTIVE_ORG, portal.getOrgId());
        xroadInstanceService.saveActiveXroadInstancesToSession(session);
        return Action.SUCCESS;
    }

    /**
     * @return SUCCESS if remove successful
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String removePortal() {
        LOGGER.debug("Portal to delete: " + portal);
        portalService.removeAll(portal);
        session.remove(Const.SESSION_PORTAL);
        session.remove(Const.SESSION_ACTIVE_ORG);
        session.remove(Const.SESSION_ACTIVE_XROAD_INSTANCES);

        addActionMessage(getText("text.success.delete"));
        return SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String addPortal() {
        return Action.SUCCESS;
    }

    /**
     * @return SUCCESS if saving portal succeeds, ERROR otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String savePortal() {
        try {
            LOGGER.debug("0. Saving portal " + getPortal().getShortName());
            if (hasErrors()) {
                return SUCCESS;
            }
            LOGGER.debug("Has no errors ");
            LOGGER.trace("1. Save portal: validating portal short name uniqueness");
            if (getPortal() != null && !getPortal().getShortName().isEmpty()) {
                try {
                    Portal p = portalService.findPortal(getPortal().getShortName());
                    if (portalId == null && p != null) { // adding new portal
                        return duplicateShortNameError();
                    }
                // if editing existing portal, findPortal will cause a COMMIT and violate
                // 'uq_portal_short_name' constraint if entered short_name is a duplicate
                } catch (Exception e) {
                    if (portalId != null) { // editing existing portal
                        return duplicateShortNameError();
                    }
                }
            }
            LOGGER.trace("2. Save portal: setting various conf flags like topics and units..");
            portal.setUnivUseManger(univUseManger);
            portal.setUseTopics(useTopics);
            portal.setUseXrdIssue(useXrdIssue);
            portal.setLogQuery(logQuery);
            portal.setUnitIsConsumer(unitIsConsumer);
            portal.setRegisterUnits(unitIsConsumer ? false : registerUnits);
            portal.setEulaInUse(useEula);
            // portal.setDebug(debug);

            LOGGER.trace("3. Save portal: saving portal and org");
            if (portal.getId() == null) {
                portalService.save(org);
                portal.setOrgId(portalService.reAttach(org, Org.class));
            }
            portalService.save(portal);
            oService.save(org);

            LOGGER.trace("4. Save portal: saving readable names,"
                    + " X-Road instances, updating session params");
            savePortalNames();
            saveOrgNames();
            saveServiceXRoadInstances();
            savePortalEulas();

            session.put(Const.SESSION_PORTAL, portal);
            session.put(Const.SESSION_ACTIVE_ORG, org);
            xroadInstanceService.saveActiveXroadInstancesToSession(session);
            portalId = portal.getId();

            LOGGER.trace("5. Save portal: saving successfully completed");
            addActionMessage(getText("text.success.save"));
            return SUCCESS;
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), e);
            addActionError(getText("text.fail.save"));
            return ERROR;
        }
    }

    private void initPortalNames() {
        portalNames = new ArrayList<PortalName>();
        for (String language : languages) {
            PortalName portalName = portalService.findPortalName(portal, language); // Take existing one
            if (portalName == null) { // If existing one is not accessible or does not exist, then create new one
                portalName = new PortalName();
                portalName.setDescription("");
                portalName.setLang(language);
            }
            portalNames.add(portalName);
        }
    }

    private void savePortalNames() {
        for (int i = 0; i < languages.size(); i++) {
            String language = languages.get(i);
            PortalName portalName = portalNames.get(i);

            portalName.setLang(language);
            String description = portalName.getDescription();

            PortalName existingPortalName = portalService.findPortalName(portal, language);
            portalName = (existingPortalName == null ? portalName : existingPortalName); // Use existing portalName
                                                                                        // entity if it exists

            portalName.setDescription(description);
            portalName.setLang(language);
            portalName.setPortal(portal);
            portalService.save(portalName);
        }
    }
    
    private void initPortalEulas() {
        portalEulas = new ArrayList<PortalEula>();
        Map<String, PortalEula> portalEulaMap = eulaService.findPortalEulaMap(portal);
        for (String language : languages) {
            PortalEula portalEula = portalEulaMap.get(language); // Take existing one
            if (portalEula == null) { // If existing one does not exist, then create new one
                portalEula = new PortalEula();
                portalEula.setContent("");
                portalEula.setLang(language);
            }
            portalEulas.add(portalEula);
        }
    }

    private void savePortalEulas() {
        Map<String, PortalEula> portalEulaMap = eulaService.findPortalEulaMap(portal);
        for (int i = 0; i < languages.size(); i++) {
            String language = languages.get(i);
            PortalEula portalEula = portalEulas.get(i);

            portalEula.setLang(language);
            String content = portalEula.getContent();

            PortalEula existingPortalEula = portalEulaMap.get(language);
            // Use existing portalEula entity if it exists
            portalEula = (existingPortalEula == null ? portalEula : existingPortalEula);
            portalEula.setContent(content);
            portalEula.setLang(language);
            portalEula.setPortal(portal);
            eulaService.save(portalEula);
        }
    }

    

    private void initOrgNames() {
        orgNames = new ArrayList<OrgName>();
        for (String language : languages) {
            OrgName orgName = oService.findOrgName(org, language); // Take existing one
            if (orgName == null) { // If existing one is not accessible or does not exist, then create new one
                orgName = new OrgName();
                orgName.setDescription("");
                orgName.setLang(language);
            }
            orgNames.add(orgName);
        }
    }

    private void saveOrgNames() {
        for (int i = 0; i < languages.size(); i++) {
            String language = languages.get(i);
            OrgName orgName = orgNames.get(i);

            orgName.setLang(language);
            String description = orgName.getDescription();

            OrgName existingOrgName = oService.findOrgName(org, language);
            orgName = (existingOrgName == null ? orgName : existingOrgName); // Use existing orgName entity if it exists

            orgName.setDescription(description);
            orgName.setLang(language);
            orgName.setOrgId(org);
            oService.save(orgName);
        }
    }
    
    private void initServiceXRoadInstances() {
        LOGGER.debug("serviceXroadInstances " + serviceXroadInstances);
        if (serviceXroadInstances == null) {
            if (portal == null || portal.getId() == null) {
                LOGGER.debug("New portal. Not initializing service X-Road instance list.");
                //default instances can be retrieved by: 
                //  serviceXroadInstances = xroadInstanceService.getDefaultInstances();
            } else {
                serviceXroadInstances = xroadInstanceService.findInstances(portal);
                LOGGER.debug("Queried new serviceXroadInstances from DB: " + serviceXroadInstances);
            }
        } else {
            LOGGER.debug("Received serviceXroadInstances from parameters.");
            for (XroadInstance inst : serviceXroadInstances) {
                if (inst != null) {
                    LOGGER.debug(" inst[id=" + inst.getId() + "]: " + inst.getCode() + " : " + inst.getInUse());
                } else {
                    LOGGER.debug(" inst null");
                }
            }
        }
    }
    
    private void saveServiceXRoadInstances() {
        xroadInstanceService.save(serviceXroadInstances, portal);
    }

    private String duplicateShortNameError() {
        addFieldError(
                "portal.shortName",
                getText("portal.label.short_name") + " "
                        + getText("validation.in_use", new String[] {getPortal().getShortName() }));
        addActionError(getText("portal.label.short_name") + " "
                + getText("validation.in_use", new String[] {getPortal().getShortName() }) + "");
        return ERROR;
    }

    /**
     * @return the languages
     */
    public ArrayList<String> getLanguages() {
        return languages;
    }

    /**
     * @param languagesNew the languages to set
     */
    public void setLanguages(ArrayList<String> languagesNew) {
        this.languages = languagesNew;
    }

    /**
     * @return the portalService
     */
    public PortalService getPortalService() {
        return portalService;
    }

    /**
     * @param portalServiceNew the portalService to set
     */
    public void setPortalService(PortalService portalServiceNew) {
        this.portalService = portalServiceNew;
    }

    /**
     * @return the portalId
     */
    public Integer getPortalId() {
        return portalId;
    }

    /**
     * @param portalIdNew the portalId to set
     */
    public void setPortalId(Integer portalIdNew) {
        this.portalId = portalIdNew;
    }

    /**
     * @return the portal
     */
    public Portal getPortal() {
        return portal;
    }

    /**
     * @param portalNew the portal to set
     */
    public void setPortal(Portal portalNew) {
        this.portal = portalNew;
    }

    /**
     * @return the portalNames
     */
    public List<PortalName> getPortalNames() {
        return portalNames;
    }

    /**
     * @param portalNamesNew the portalNames to set
     */
    public void setPortalNames(List<PortalName> portalNamesNew) {
        this.portalNames = portalNamesNew;
    }

    /**
     * @return the orgNames
     */
    public List<OrgName> getOrgNames() {
        return orgNames;
    }

    /**
     * @param orgNamesNew the orgNames to set
     */
    public void setOrgNames(List<OrgName> orgNamesNew) {
        this.orgNames = orgNamesNew;
    }

    /**
     * @return the org
     */
    public Org getOrg() {
        return org;
    }

    /**
     * @param orgNew the org to set
     */
    public void setOrg(Org orgNew) {
        this.org = orgNew;
    }

    /**
     * @return the managers
     */
    public List<Person> getManagers() {
        return managers;
    }

    /**
     * @param managersNew the managers to set
     */
    public void setManagers(List<Person> managersNew) {
        this.managers = managersNew;
    }

    /**
     * @return the portals
     */
    public List<Portal> getPortals() {
        return portals;
    }

    /**
     * @param portalsNew the portals to set
     */
    public void setPortals(List<Portal> portalsNew) {
        this.portals = portalsNew;
    }

    /**
     * @return the univUseManger
     */
    public boolean isUnivUseManger() {
        return univUseManger;
    }

    /**
     * @param univUseMangerNew the univUseManger to set
     */
    public void setUnivUseManger(boolean univUseMangerNew) {
        this.univUseManger = univUseMangerNew;
    }

    /**
     * @return the useTopics
     */
    public boolean isUseTopics() {
        return useTopics;
    }

    /**
     * @param useTopicsNew the useTopics to set
     */
    public void setUseTopics(boolean useTopicsNew) {
        this.useTopics = useTopicsNew;
    }
    

    /**
     * @return true, if EULA prompt is in use for given portal, false if not
     */
    public boolean isUseEula() {
        return useEula;
    }

    /**
     * Set EULA prompt in use or disable it for currently edited portal.
     * @param useEula true, if EULA prompt is in use for given portal, false if not
     */
    public void setUseEula(boolean useEula) {
        this.useEula = useEula;
    }

    /**
     * @return the useXrdIssue
     */
    public boolean isUseXrdIssue() {
        return useXrdIssue;
    }

    /**
     * @param useXrdIssueNew the useXrdIssue to set
     */
    public void setUseXrdIssue(boolean useXrdIssueNew) {
        this.useXrdIssue = useXrdIssueNew;
    }

    /**
     * @return the logQuery
     */
    public boolean isLogQuery() {
        return logQuery;
    }

    /**
     * @param logQueryNew the logQuery to set
     */
    public void setLogQuery(boolean logQueryNew) {
        this.logQuery = logQueryNew;
    }

    /**
     * @return the unitIsConsumer
     */
    public boolean isUnitIsConsumer() {
        return unitIsConsumer;
    }

    /**
     * @param unitIsConsumerNew the unitIsConsumer to set
     */
    public void setUnitIsConsumer(boolean unitIsConsumerNew) {
        this.unitIsConsumer = unitIsConsumerNew;
    }

    /**
     * @return the registerUnits
     */
    public boolean isRegisterUnits() {
        return registerUnits;
    }

    /**
     * @param registerUnitsNew the registerUnits to set
     */
    public void setRegisterUnits(boolean registerUnitsNew) {
        this.registerUnits = registerUnitsNew;
    }

    /**
     * @return the debug
     */
    public int getDebug() {
        return debug;
    }

    /**
     * @param debugNew the debug to set
     */
    public void setDebug(int debugNew) {
        this.debug = debugNew;
    }

    /**
     * @return the unitQueryConf
     */
    public UnitQueryConf getUnitQueryConf() {
        return unitQueryConf;
    }
    
    /**
     * @return the serviceXroadInstances
     */
    public List<XroadInstance> getServiceXroadInstances() {
        return serviceXroadInstances;
    }

    /**
     * @param newServiceXroadInstances the serviceXroadInstances to set
     */
    public void setServiceXroadInstances(List<XroadInstance> newServiceXroadInstances) {
        this.serviceXroadInstances = newServiceXroadInstances;
    }

    /**
     * @return translations of end user license agreement associated with the portal
     */
    public List<PortalEula> getPortalEulas() {
        return portalEulas;
    }

    /**
     * Set translations of end user license agreement associated with the portal.
     * @param list of PortalEula entities
     */
    public void setPortalEulas(List<PortalEula> portalEulas) {
        this.portalEulas = portalEulas;
    }
    
}
