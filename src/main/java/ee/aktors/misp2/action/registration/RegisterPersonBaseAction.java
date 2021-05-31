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

package ee.aktors.misp2.action.registration;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.struts2.StrutsStatics;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.action.SecureLoggedAction;
import ee.aktors.misp2.beans.ListClassifierItem;
import ee.aktors.misp2.beans.ManagerCandidateBean;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Classifier;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.service.ClassifierService;
import ee.aktors.misp2.service.ManagerCandidateService;
import ee.aktors.misp2.service.OrgService;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.service.exception.DatabaseException;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.CountryUtil;
import ee.aktors.misp2.util.XmlSimpleClassifierParser;

/**
 *
 * @author arnis.rips
 */
public abstract class RegisterPersonBaseAction extends SecureLoggedAction {
    // XXX: HARDCODED constants

    private static final int PAGE_NR = -2;
    private static final long serialVersionUID = 1L;
    private static final String ITEM_LEVEL_NAME = "item";
    private static final String FIRST_PARAM_NAME = "name";
    private static final String SECOND_PARAM_NAME = "code";
    private static final int MAXIMUM_COUNTRY_NAME_LENGTH = 21;

    //
    private List<Person> searchResults;
    private String filterGivenName = "";
    private String filterSurname = "";
    private String filterSSN = "";
    private String filterCountryCode = "";
    private String countryCode = CountryUtil.getDefaultCountry().getCountry();
    // constructor added
    protected OrgService serviceOrg;
    protected UserService serviceUser;
    protected ManagerCandidateService serviceMgrCand;
    protected ClassifierService serviceClssf;
    //
    protected List<Person> managerList;
    protected Integer userId;
    protected Person activeUser;
    private Person person;
    private List<ListClassifierItem> countryList;
    protected boolean registerUnknown = false;
    protected List<ManagerCandidateBean> managerCandidatesList = new ArrayList<ManagerCandidateBean>();
    protected String redirectAction;
    protected List<Integer> permissionRoles;
    protected Integer roleIntValue;
    protected OrgPerson currentOrgPerson;
    protected Org activeOrg;

    /**
     * For redirecting to userSubmit
     */
    private String sessionCSRFToken;

    /**
     * @param orgService
     *            orgService to inject
     * @param uService
     *            uService to inject
     * @param clService
     *            clService to inject
     * @param mcService
     *            mcService to inject
     */
    public RegisterPersonBaseAction(OrgService orgService, UserService uService, ClassifierService clService,
            ManagerCandidateService mcService) {
        super(uService);
        this.serviceOrg = orgService;
        this.serviceUser = uService;
        this.serviceClssf = clService;
        this.serviceMgrCand = mcService;
    }

    /**
     * Override this method to fill manager list
     */
    protected abstract void fillManagerList(Org org);

    /**
     * Stump method, always returning SUCCESS. Mainly used to hide business logic from end-user
     * 
     * @return SUCCESS
     */
    public abstract String removeUnitPerson();

    /**
     * Stump method, always returning SUCCESS. Mainly used to hide business logic from end-user
     * 
     * @return SUCCESS
     */
    public abstract String addUnitPerson();

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String showForm() {
        LogManager.getLogger(this.getClass()).debug("registerUnknown b4 registration= " + registerUnknown);
        // TODO REMOVE - registerUnknown
        fillManagerList(activeOrg);

        if (ActionContext.getContext().getName().endsWith("Filter")) {
            fillSearchResults();
        }
        return SUCCESS;
    }

    private void fillSearchResults() {
        searchResults = serviceUser.findUsers(filterGivenName, filterSurname, (filterCountryCode.isEmpty() ? "__"
                : filterCountryCode) + filterSSN, PAGE_NR, PAGE_NR);
    }

    protected void fillCurrentOrgPerson() {
        currentOrgPerson = serviceUser.findOrgPerson(userId, activeOrg.getId(), portal.getId());
    }

    @Override
    public void prepare() throws Exception {
        super.prepare();
        activeOrg = serviceUser.reAttach(org, Org.class);
        activeUser = serviceUser.reAttach(user, Person.class);
        LogManager.getLogger(this.getClass()).debug("activeOrg = " + activeOrg);
        // TODO REMOVE - activeOrg

        this.managerList = new ArrayList<Person>();
        initCountryList();

        HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(StrutsStatics.HTTP_REQUEST);
        sessionCSRFToken = (String) request.getSession().getAttribute(Const.SESSION_CSRF_TOKEN);
    }

    private void initCountryList() throws DatabaseException {
        String classifierName = getText("classifier_name.countries");
        Classifier c = serviceClssf.findSystemClassifierByName(classifierName);

        XmlSimpleClassifierParser xcp = new XmlSimpleClassifierParser(ITEM_LEVEL_NAME, FIRST_PARAM_NAME,
                SECOND_PARAM_NAME);
        String xml = c.getContent();
        countryList = xcp.parseXml((xml != null ? xml : ""), MAXIMUM_COUNTRY_NAME_LENGTH);

        countryList = (countryList == null ? new ArrayList<ListClassifierItem>(0) : countryList);
    }

    protected boolean isUserManager(Person subject) {
        if (subject == null) {
            throw new IllegalArgumentException("Subject is null");
        }
        fillManagerList(activeOrg);
        if (managerList == null) {
            throw new IllegalAccessError("Manager list is not set");
        }
        LogManager.getLogger(RegisterPersonBaseAction.class).debug("managerList = " + managerList);
        for (Person manager : managerList) {
            if (manager.getSsn().equals(subject.getSsn())) {
                return true;
            }
        }
        return false;
    }

    
    
    
    /**
     * @return the searchResults
     */
    public List<Person> getSearchResults() {
        return searchResults;
    }

    /**
     * @param searchResultsNew the searchResults to set
     */
    public void setSearchResults(List<Person> searchResultsNew) {
        this.searchResults = searchResultsNew;
    }

    /**
     * @return the filterGivenName
     */
    public String getFilterGivenName() {
        return filterGivenName;
    }

    /**
     * @param filterGivenNameNew the filterGivenName to set
     */
    public void setFilterGivenName(String filterGivenNameNew) {
        this.filterGivenName = filterGivenNameNew;
    }

    /**
     * @return the filterSurname
     */
    public String getFilterSurname() {
        return filterSurname;
    }

    /**
     * @param filterSurnameNew the filterSurname to set
     */
    public void setFilterSurname(String filterSurnameNew) {
        this.filterSurname = filterSurnameNew;
    }

    /**
     * @return the filterSSN
     */
    public String getFilterSSN() {
        return filterSSN;
    }

    /**
     * @param filterSSNNew the filterSSN to set
     */
    public void setFilterSSN(String filterSSNNew) {
        this.filterSSN = filterSSNNew;
    }

    /**
     * @return the filterCountryCode
     */
    public String getFilterCountryCode() {
        return filterCountryCode;
    }

    /**
     * @param filterCountryCodeNew the filterCountryCode to set
     */
    public void setFilterCountryCode(String filterCountryCodeNew) {
        this.filterCountryCode = filterCountryCodeNew;
    }

    /**
     * @return the managerList
     */
    public List<Person> getManagerList() {
        return managerList;
    }

    /**
     * @param managerListNew the managerList to set
     */
    public void setManagerList(List<Person> managerListNew) {
        this.managerList = managerListNew;
    }

    /**
     * @return the userId
     */
    public Integer getUserId() {
        return userId;
    }

    /**
     * @param userIdNew the userId to set
     */
    public void setUserId(Integer userIdNew) {
        this.userId = userIdNew;
    }

    /**
     * @return the person
     */
    public Person getPerson() {
        return person;
    }

    /**
     * @param personNew the person to set
     */
    public void setPerson(Person personNew) {
        this.person = personNew;
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
     * @return the permissionRoles
     */
    public List<Integer> getPermissionRoles() {
        return permissionRoles;
    }

    /**
     * @param permissionRolesNew the permissionRoles to set
     */
    public void setPermissionRoles(List<Integer> permissionRolesNew) {
        this.permissionRoles = permissionRolesNew;
    }

    /**
     * @return the roleIntValue
     */
    public Integer getRoleIntValue() {
        return roleIntValue;
    }

    /**
     * @param roleIntValueNew the roleIntValue to set
     */
    public void setRoleIntValue(Integer roleIntValueNew) {
        this.roleIntValue = roleIntValueNew;
    }

    /**
     * @return countryList
     */
    public List<ListClassifierItem> getCountryList() {
        return countryList;
    }

    /**
     * @return registerUnknown
     */
    public boolean isRegisterUnknown() {
        return registerUnknown;
    }

    /**
     * @return managerCandidatesList
     */
    public List<ManagerCandidateBean> getManagerCandidatesList() {
        return managerCandidatesList;
    }

    /**
     * @return countryCode
     */
    public String getCountryCode() {
        return countryCode;
    }

    /**
     * @return activeOrg
     */
    public Org getActiveOrg() {
        return activeOrg;
    }

    /**
     * @return sessionCSRFToken
     */
    public String getSessionCSRFToken() {
        return sessionCSRFToken;
    }

}
