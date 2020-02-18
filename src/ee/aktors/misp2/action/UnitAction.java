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

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.beans.T3SecWrapper;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgName;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.service.OrgService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.LanguageUtil;
import ee.aktors.misp2.util.LogQuery;

/**
 *
 * @author arnis.rips
 */
public class UnitAction extends SecureLoggedAction implements IManagementAction {
    private static final long serialVersionUID = 1L;
    private ArrayList<String> languages = LanguageUtil.getLanguages();
    private OrgService oService;
    private List<Org> searchResults;
    private String filterName;
    private String filterCode;
    private Integer unitId;
    private Org unit;
    private List<OrgName> unitNames;
    private boolean btnSaveAndRegister;
    private String redirectAction;
    private Portal portal;
    private String filterPartyClass;

    /**
     * For redirecting to registerUnit
     */
    private String sessionCSRFToken;

    private static final Logger LOG = LogManager.getLogger(UnitAction.class);

    /**
     * @param oService oService to inject
     */
    public UnitAction(OrgService oService) {
        super(oService);
        this.oService = oService;
    }

    @Override
    public void prepare() throws Exception {
        super.prepare();
        session = ActionContext.getContext().getSession();

        if (session == null) {
            LOG.error("Session is null, cannot initialize portal in UnitAction");
        } else {
            portal = (Portal) session.get(Const.SESSION_PORTAL);
            LOG.info("Portal: " + portal);
        }
        if (unitId != null) {
            unit = oService.findObject(Org.class, unitId);
        }
        initUnitNames();

        HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(StrutsStatics.HTTP_REQUEST);
        sessionCSRFToken = (String) request.getSession().getAttribute(Const.SESSION_CSRF_TOKEN);
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String showFilter() {
        return filter();
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String filter() {
        searchResults = oService.findOrgs(filterPartyClass, filterName, filterCode, portal.getOrgId().getId());
        return SUCCESS;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String addItem() {
        return SUCCESS;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String showItem() {
        if (unit != null) {
            if (!isAllowed(unit)) {
                addActionError(getText("text.error.item_not_allowed"));
                return ERROR;
            }

            List<Org> allowed = new ArrayList<Org>(1);
            allowed.add(unit);
            session.put(Const.SESSION_ALLOWED_ORG_LIST, allowed);
        }
        return SUCCESS;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String submitItem() {
        if (unit != null) {

            if (unit.getId() != null && !isAllowed(unit)) {
                addActionError(getText("text.error.item_not_allowed"));
                return ERROR;
            }

            try {
                unit.setSupOrgId(oService.reAttach(portal.getOrgId(), Org.class));
                if (unitId != null || unit.getId() != null) { // existing unit
                    Org oldUnit = oService.findObject(Org.class, unitId == null ? unit.getId() : unitId);
                    if (oldUnit != null) {
                        unit.setCode(oldUnit.getCode()); // users cannot change units' code
                        unit.setCreated(oldUnit.getCreated());
                    }
                } else { // new unit
                    // saveUnitNames();

                    T3SecWrapper t3 = initT3(LogQuery.UNIT_ADD);
                    if (!log(t3)) {
                        addActionError(getText("text.fail.save.log"));
                        LOG.warn("Adding new unit failed because of logging problems.");
                        return INPUT;
                    }
                }
                oService.save(unit);
                saveUnitNames();
                if (btnSaveAndRegister) {
                    List<Org> allowed = new ArrayList<Org>(1);
                    allowed.add(unit);
                    session.put(Const.SESSION_ALLOWED_ORG_LIST, allowed);
                    session.put(Const.SESSION_USE_MANAGER, Boolean.TRUE);
                    return REDIRECT;
                }
                addActionMessage(getText("text.success.save"));
            } catch (Exception e) {
                LOG.error(e.getMessage(), e);
                addActionMessage(getText("text.fail.save"));
                return INPUT;
            }
            unitId = unit.getId();
        }
        return SUCCESS;
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String deleteItem() {
        if (unitId != null) {
            Org o = oService.findObject(Org.class, unitId);

            if (o != null) {

                if (!isAllowed(o)) {
                    addActionError(getText("text.error.item_not_allowed"));
                    return ERROR;
                }

                T3SecWrapper t3 = initT3(LogQuery.UNIT_DELETE);
                if (!log(t3)) {
                    addActionError(getText("text.fail.delete.log"));
                    LOG.warn("Unit delete failed because of logging problems");
                    return ERROR;
                }
                oService.remove(o);
                return SUCCESS;
            } else {
                LOG.error("No org found for id=" + unitId + ". Nothing was deleted");
            }
        } else {
            LOG.error("Org id not set orgId=" + unitId + ". Nothing was deleted");
        }
        return ERROR;
    }

    /**
     * @param unitIn unit to check
     * @return if unit is allowed in portal
     */
    private boolean isAllowed(Org unitIn) {
        return portal.getOrgId().getId().equals(unitIn.getSupOrgId().getId());
    }

    private void initUnitNames() {
        unitNames = new ArrayList<OrgName>();
        for (String language : languages) {
            OrgName unitName = null;
            if (unitId != null) {
                unitName = oService.findOrgName(unit, language); // Take existing one
            }
            if (unitName == null) { // If existing one is not accessible or does not exist, then create new one
                unitName = new OrgName();
                unitName.setDescription("");
                unitName.setLang(language);
            }
            unitNames.add(unitName);
        }
    }

    private void saveUnitNames() {
        for (int i = 0; i < languages.size(); i++) {
            String language = languages.get(i);
            OrgName unitName = unitNames.get(i);

            unitName.setLang(language);
            String description = unitName.getDescription();

            OrgName existingUnitName = oService.findOrgName(unit, language);
            unitName = (existingUnitName == null ? unitName : existingUnitName);
            // Use existing orgName entity if it exists

            unitName.setDescription(description);
            unitName.setLang(language);
            unitName.setOrgId(unit);
            oService.save(unitName);
        }
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
     * @return the unitId
     */
    public Integer getUnitId() {
        return unitId;
    }

    /**
     * @param unitIdNew the unitId to set
     */
    public void setUnitId(Integer unitIdNew) {
        this.unitId = unitIdNew;
    }

    /**
     * @return the unit
     */
    public Org getUnit() {
        return unit;
    }

    /**
     * @param unitNew the unit to set
     */
    public void setUnit(Org unitNew) {
        this.unit = unitNew;
    }

    /**
     * @return the searchResults
     */
    public List<Org> getSearchResults() {
        return searchResults;
    }

    /**
     * @param filterNameNew the filterName to set
     */
    public void setFilterName(String filterNameNew) {
        this.filterName = filterNameNew;
    }

    /**
     * @param filterCodeNew the filterCode to set
     */
    public void setFilterCode(String filterCodeNew) {
        this.filterCode = filterCodeNew;
    }

    /**
     * @return the unitNames
     */
    public List<OrgName> getUnitNames() {
        return unitNames;
    }

    /**
     * @param unitNamesNew the unitNames to set
     */
    public void setUnitNames(List<OrgName> unitNamesNew) {
        this.unitNames = unitNamesNew;
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

    /**
     * @return the filterPartyClass
     */
    public String getFilterPartyClass() {
        return filterPartyClass;
    }

    /**
     * @param filterPartyClassNew the filterPartyClass to set
     */
    public void setFilterPartyClass(String filterPartyClassNew) {
        this.filterPartyClass = filterPartyClassNew;
    }

    /**
     * @return the filterName
     */
    public String getFilterName() {
        return filterName;
    }

    /**
     * @return the filterCode
     */
    public String getFilterCode() {
        return filterCode;
    }

    /**
     * @return the portal
     */
    public Portal getPortal() {
        return portal;
    }

    /**
     * @return the sessionCSRFToken
     */
    public String getSessionCSRFToken() {
        return sessionCSRFToken;
    }

    /**
     * @param str set btnSaveAndRegister to false if null, to true otherwise
     */
    public void setBtnSaveAndRegister(String str) {
        this.btnSaveAndRegister = (str == null || str.isEmpty() ? false : true);
    }
}
