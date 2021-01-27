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

package ee.aktors.misp2.action.admin;

import java.util.List;
import java.util.Locale;

import javax.transaction.NotSupportedException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.Validateable;

import ee.aktors.misp2.action.SecureLoggedAction;
import ee.aktors.misp2.beans.T3SecWrapper;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.mail.NotificationMail;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.PersonMailOrg;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.service.PortalService;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.CountryUtil;
import ee.aktors.misp2.util.LogQuery;
import ee.aktors.misp2.util.PasswordUtil;
import ee.aktors.misp2.util.Roles;
import ee.aktors.misp2.util.SSNValidator;
import ee.aktors.misp2.util.StrutsUtil;

/**
 *
 * @author arnis.rips
 */
public class ManagerAction extends SecureLoggedAction implements Validateable {

    private static final long serialVersionUID = 1L;
    private static final int PAGE_NR = -2;
    private static final Logger LOGGER = LogManager.getLogger(ManagerAction.class.getName());
    private UserService srvcUser;
    private PortalService srvcPortal;
    private OrgPerson orgPerson;
    private Person person;
    private Portal portal;
    private Integer userId;
    private Org org;
    private PersonMailOrg personMailOrg;
    private NotificationMail notificationMail = new NotificationMail();
    private boolean notifyUser = false;
    private List<Person> users;
    private List<Person> searchResults;
    private String filterGivenName = "";
    private String filterSurname = "";
    private String filterSSN = "";
    private String filterCountryCode = "";
    private String ssn = "";
    private boolean updatePassword = false;
    private String newPassword = "";
    private String confirmNewPassword = "";
    private boolean addExisting = false;
    private static final int COUNRTY_CODE_LENGTH = 2;
    private String countryCode = CountryUtil.getDefaultCountry().getCountry();
    private List<Locale> countryList = CountryUtil.getCountries();
    private String generatedOvertakeCode;
    private String lang;

    /**
     * @param uService
     *            uService to inject
     * @param pService
     *            pService to inject
     */
    public ManagerAction(UserService uService, PortalService pService) {
        super(uService);
        this.srvcUser = uService;
        this.srvcPortal = pService;
    }

    /**
     * Searches for users
     * 
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String filter() {
        searchResults = srvcUser.findUsers(filterGivenName, filterSurname, (filterCountryCode.isEmpty() ? "__"
                : filterCountryCode) + filterSSN, PAGE_NR, PAGE_NR);
        return SUCCESS;
    }

    @Override
    public void validate() {
        String methodName = "";
        try {
            methodName = StrutsUtil.getInvokedActionMethod(ActionContext.getContext().getActionInvocation()).getName();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

        if (methodName.equals("saveUserAdmin") || methodName.equals("saveManager")) {
            if (countryCode == null || countryCode.trim().isEmpty()) {
                String msg = getText("validation.input_required");
                addFieldError("ssn", msg);
                LOGGER.debug("Not valid: " + msg);
                return;
            }
            if (person != null) {
                LOGGER.debug("validating");
                if (person.getGivenname() == null || person.getGivenname().trim().isEmpty()) {
                    String msg = getText("validation.input_required");
                    addFieldError("person.givenname", msg);
                }

                if (person.getSurname() == null || person.getSurname().trim().isEmpty()) {
                    String msg = getText("validation.input_required");
                    addFieldError("person.surname", msg);
                }

                // TODO Password update validation should be after ssn validation, but can't, because ssn validation
                // block returns prematurely
                if (updatePassword) {
                    if (CONFIG.getBoolean("auth.password") == false) {
                        addFieldError("updatePassword", getText("login.errors.form.not_supported"));
                    } else {
                        if (newPassword.equals(confirmNewPassword) == false) {
                            addFieldError("confirmNewPassword", getText("change.password.mismatch"));
                        }
                    }
                }

                if (ssn != null && !ssn.trim().isEmpty()) {
                    LOGGER.info("Validating ssn [" + ssn + "]");
                    try {
                        if (!SSNValidator.validateSSN(ssn, countryCode)) {
                            String msg = getText("validation.not_valid",
                                    new String[] {getText("users.show.label.ssn")});
                            addFieldError("ssn", msg);
                            LOGGER.debug("Not valid: " + msg);
                            return;
                        }
                    } catch (NotSupportedException ex) {
                        // XXX: ssn validation not supported (ignore this)
                        // at the moment just ignore and move on
                    }
                    Person p = srvcUser.findPersonBySSN(countryCode + ssn.trim());
                    if (person.getId() == null && p != null) {
                        String msg = getText("validation.in_use", new String[] {getText("users.show.label.ssn") });
                        addFieldError("ssn", msg);
                        LOGGER.debug("Not valid: " + msg);
                        return;
                    } else if (p != null && p.getId() != null && !p.getId().equals(person.getId())) {
                        String msg = getText("validation.in_use", new String[] {getText("users.show.label.ssn") });
                        addFieldError("ssn", msg);
                        LOGGER.debug("Not valid: " + msg);
                        return;
                    }
                    LOGGER.debug("Valid ssn " + ssn);

                    Person existingUser = srvcUser.findPersonBySSN(countryCode + ssn);
                    person.setSsn(countryCode + ssn.trim());

                    if (existingUser != null && (person.getId() == null || !existingUser.equals(person))) {
                        addFieldError("ssn",
                                getText("validation.in_use", new String[] {getText("users.show.label.ssn") }));
                    }
                }
            }
        }
        for (List<String> s : getFieldErrors().values()) {
            setActionErrors(s);
        }
    }
    
    @Override
    public void prepare() throws Exception {
        super.prepare();
        lang = ActionContext.getContext().getLocale().getLanguage();
        portal = (Portal) session.get(Const.SESSION_PORTAL);
        org = (Org) session.get(Const.SESSION_ACTIVE_ORG);

        if (userId != null) {
            person = srvcPortal.findObject(Person.class, userId);
            orgPerson = srvcPortal.findOrgPerson(portal, org, person);
            personMailOrg = srvcUser.findPersonMailOrg(userId, org.getId());
            ssn = person.getSsn().trim().substring(COUNRTY_CODE_LENGTH);
            countryCode = person.getSsn().substring(0, COUNRTY_CODE_LENGTH);
            if (personMailOrg != null) {
                notifyUser = personMailOrg.getNotifyChanges();
                LOGGER.debug("Set notifyUser = " + notifyUser);
            }
            if (orgPerson == null) {
                orgPerson = new OrgPerson();
            }
            if (personMailOrg == null) {
                personMailOrg = new PersonMailOrg();
            }
        } else {
            LOGGER.debug("new person");
            person = new Person();
            orgPerson = new OrgPerson();
            personMailOrg = new PersonMailOrg();
        }
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET, HTTPMethod.POST })
    public String addManager() {
        return Action.SUCCESS;
    }

    /**
     * @return SUCCESS when saving is successful, ERROR otherwise
     * @throws Exception when salting the password fails
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String saveUserAdmin() throws Exception {
        if (person.getId() == null) { // new user
            person.setSsn(countryCode + ssn.trim());
            // --- Log new user addition
            T3SecWrapper t3 = initT3(LogQuery.USER_ADD);
            Person p = srvcUser.findPersonBySSN(countryCode + ssn.trim());
            if (person.getId() == null && p != null) {
                if (person.getSsn().equals(p.getSsn()) && person.getGivenname().equals(p.getGivenname())
                        && person.getSurname().equals(p.getSurname())) {
                    addExisting = true;
                    person = p;
                    System.out.println("addexisting");
                } else {
                    String msg = getText("validation.in_use", new String[] {getText("users.show.label.ssn") });
                    addFieldError("ssn", msg + " (" + ssn + ")");
                    addActionError(msg + " (" + ssn + ")");
                    return Action.ERROR;
                }
            }
            t3.getT3sec().setUserTo(person.getSsn());
            t3.getT3sec().setUserFrom("../src/main/webapp/admin");

            if (!log(t3)) {
                addActionError(getText("text.fail.save.log"));
                LOGGER.warn("Saving user failed because of logging problems.");
                return Action.ERROR;
            }
            // ----- end log new user add ----- //
        } else {
            Person oldPerson = srvcUser.findObject(Person.class, person.getId());
            if (notifyUser) {
                Integer oldRole = (orgPerson.getRole() == null ? Roles.NO_RIGHTS : orgPerson.getRole());
                int newRole = Roles.addRoles(oldRole, Roles.PORTAL_MANAGER);
                notificationMail.setAddedRoles(Roles.addedRoles(oldRole, newRole));
                notificationMail.setReceiverEmail(personMailOrg.getMail());
                notificationMail.setReceiverName(person.getFullName());
                notificationMail.setOrganizationName(org.getFullName(lang));
                notificationMail.send();
            }
            if (oldPerson == null) {
                LOGGER.error("oldPerson is null");
            }
        }

        if (updatePassword) {
            person.setPasswordSalt(PasswordUtil.getSalt());
            person.setPassword(PasswordUtil.encryptPassword(newPassword, person.getPasswordSalt()));
        }

        // --- Log portal manager setting
        T3SecWrapper t3 = initT3(LogQuery.MANAGER_SETTING);
        t3.getT3sec().setUserTo(person.getSsn());
        t3.getT3sec().setUserFrom("../src/main/webapp/admin");
        if (!log(t3)) {
            addActionError(getText("text.fail.save.log"));
            LOGGER.warn("Setting manager failed because of logging problems.");
            return ERROR;
        }
        // ----- end log portal manager setting ----- //
        try {
            person.setGivenname(person.getGivenname().trim());
            person.setSurname(person.getSurname().trim());
            if (!addExisting)
                srvcPortal.save(person);
        } catch (Exception bue) {
            LOGGER.error(bue.getMessage(), bue);
            addActionError(getText("text.fail.save"));
            return ERROR;
        }

        if (personMailOrg.getMail() != null && !addExisting) {
            personMailOrg.setPersonId(person);
            personMailOrg.setOrgId(org);
            srvcUser.save(personMailOrg);
        }

        return Action.SUCCESS;
    }

    /**
     * @return SUCCESS when saving is successful, ERROR otherwise
     * @throws Exception when salting the password fails
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String saveManager() throws Exception {
        Integer oldRole = (orgPerson.getRole() == null ? Roles.NO_RIGHTS : orgPerson.getRole());
        int newRole = Roles.addRoles(oldRole, Roles.PORTAL_MANAGER);
        String result = saveUserAdmin();
        if (result.equals(Action.SUCCESS)) {
            OrgPerson op = srvcUser.findOrgPerson(person.getId(), org.getId(), portal.getId());
            if (op == null || !(op.getRole().equals(Roles.PORTAL_MANAGER))) {
                orgPerson.setOrgId(org);
                orgPerson.setPersonId(person);
                orgPerson.setPortal(portal);
                orgPerson.setRole(newRole); // at first manager with all permissions is created
                srvcPortal.save(orgPerson);
            }
        }
        return result;
    }

    /**
     * @return SUCCESS when deleting is successful, ERROR otherwise
     * @throws Exception when salting the password fails
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String deleteManager() throws Exception {
        Integer oldRole = (orgPerson.getRole() == null ? Roles.NO_RIGHTS : orgPerson.getRole());
        int newRole = Roles.addRoles(Roles.removeRoles(oldRole, Roles.PORTAL_MANAGER));

        LOGGER.debug("org_person to change roles: " + orgPerson.getId());
        // --- Log portal manager setting
        T3SecWrapper t3 = initT3(LogQuery.MANAGER_DELETE);
        t3.getT3sec().setUserTo(orgPerson.getPersonId().getSsn());
        t3.getT3sec().setUserFrom("../src/main/webapp/admin");
        if (!log(t3)) {
            addActionError(getText("text.fail.delete.log"));
            LOGGER.warn("Deleting manager failed because of logging problems.");
            return Action.ERROR;
        }

        if (notifyUser) {
            notificationMail.setRemovedRoles(Roles.removedRoles(oldRole, newRole));
            notificationMail.setReceiverEmail(personMailOrg.getMail());
            notificationMail.setReceiverName(person.getFullName());
            notificationMail.setOrganizationName(org.getFullName(lang));
            notificationMail.send();
        }

        // ----- end log portal manager setting ----- //
        if (newRole == Roles.NO_RIGHTS) {
            srvcUser.remove(orgPerson);
        } else {
            orgPerson.setRole(newRole); // changing permissions to user permissions only
            srvcUser.save(orgPerson);
        }

        return SUCCESS;
    }

    /**
     * @return the orgPerson
     */
    public OrgPerson getOrgPerson() {
        return orgPerson;
    }

    /**
     * @param orgPersonNew the orgPerson to set
     */
    public void setOrgPerson(OrgPerson orgPersonNew) {
        this.orgPerson = orgPersonNew;
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
     * @return the personMailOrg
     */
    public PersonMailOrg getPersonMailOrg() {
        return personMailOrg;
    }

    /**
     * @param personMailOrgNew the personMailOrg to set
     */
    public void setPersonMailOrg(PersonMailOrg personMailOrgNew) {
        this.personMailOrg = personMailOrgNew;
    }

    /**
     * @return the users
     */
    public List<Person> getUsers() {
        return users;
    }

    /**
     * @param usersNew the users to set
     */
    public void setUsers(List<Person> usersNew) {
        this.users = usersNew;
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
     * @return the ssn
     */
    public String getSsn() {
        return ssn;
    }

    /**
     * @param ssnNew the ssn to set
     */
    public void setSsn(String ssnNew) {
        this.ssn = ssnNew;
    }

    /**
     * @return the updatePassword
     */
    public boolean isUpdatePassword() {
        return updatePassword;
    }

    /**
     * @param updatePasswordNew the updatePassword to set
     */
    public void setUpdatePassword(boolean updatePasswordNew) {
        this.updatePassword = updatePasswordNew;
    }

    /**
     * @return the newPassword
     */
    public String getNewPassword() {
        return newPassword;
    }

    /**
     * @param newPasswordNew the newPassword to set
     */
    public void setNewPassword(String newPasswordNew) {
        this.newPassword = newPasswordNew;
    }

    /**
     * @return the confirmNewPassword
     */
    public String getConfirmNewPassword() {
        return confirmNewPassword;
    }

    /**
     * @param confirmNewPasswordNew the confirmNewPassword to set
     */
    public void setConfirmNewPassword(String confirmNewPasswordNew) {
        this.confirmNewPassword = confirmNewPasswordNew;
    }

    /**
     * @return the countryCode
     */
    public String getCountryCode() {
        return countryCode;
    }

    /**
     * @param countryCodeNew the countryCode to set
     */
    public void setCountryCode(String countryCodeNew) {
        this.countryCode = countryCodeNew;
    }

    /**
     * @return the countryList
     */
    public List<Locale> getCountryList() {
        return countryList;
    }

    /**
     * @param countryListNew the countryList to set
     */
    public void setCountryList(List<Locale> countryListNew) {
        this.countryList = countryListNew;
    }

    /**
     * @return the generatedOvertakeCode
     */
    public String getGeneratedOvertakeCode() {
        return generatedOvertakeCode;
    }

    /**
     * @param generatedOvertakeCodeNew the generatedOvertakeCode to set
     */
    public void setGeneratedOvertakeCode(String generatedOvertakeCodeNew) {
        this.generatedOvertakeCode = generatedOvertakeCodeNew;
    }






 
}
