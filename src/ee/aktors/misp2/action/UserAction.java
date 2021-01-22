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

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import javax.transaction.NotSupportedException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.Validateable;

import ee.aktors.misp2.beans.Auth;
import ee.aktors.misp2.beans.GroupValidPair;
import ee.aktors.misp2.beans.T3SecWrapper;
import ee.aktors.misp2.beans.UserPortal;
import ee.aktors.misp2.csrfProtection.ApplyCSRFProtectionAlways;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.mail.NotificationMail;
import ee.aktors.misp2.model.GroupPerson;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.PersonGroup;
import ee.aktors.misp2.model.PersonMailOrg;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.service.ClassifierService;
import ee.aktors.misp2.service.GroupService;
import ee.aktors.misp2.service.OrgService;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.CountryUtil;
import ee.aktors.misp2.util.LogQuery;
import ee.aktors.misp2.util.PasswordUtil;
import ee.aktors.misp2.util.Roles;
import ee.aktors.misp2.util.SSNValidator;

/**
 *
 * @author arnis.rips
 */
public class UserAction extends SecureLoggedAction implements Validateable {
    private static final long serialVersionUID = 1L;
    private static final int COUNRTY_CODE_LENGTH = 2;
    private static final String SESSION_LAST_ROLE = "LAST_ROLE";
    private static final Logger LOG = LogManager.getLogger(UserAction.class);
    private static final Map<Integer, String> ALL_ROLES = new HashMap<Integer, String>();
    protected static final int PAGE_SIZE = 20;
    // XXX: HARDCODED constants
    private UserService serviceUsr;
//    private ClassifierService serviceCl;
    private GroupService serviceGrp;
    private OrgService oService;
    private Integer userId;
    private Integer orgId;
    private Integer portalId;
    private String profession;
    private Person person;
    private String mail;
    private String ssn = "";
    private String countryCode = CountryUtil.getDefaultCountry().getCountry();
    private boolean updatePassword = false;
    private String newPassword = "";
    private String confirmNewPassword = "";
    private PersonMailOrg personMailOrg;
    private Org activeOrg;
    private List<PersonGroup> allGroups;
    private List<Integer> userGroups = new ArrayList<Integer>();
    private Map<Integer, Date> userGroupsValid = new HashMap<Integer, Date>();
    private Map<Integer, Date> userGroupsVret = new HashMap<Integer, Date>();
    private List<Person> searchResults;
    private String filterGivenName = "";
    private String filterSurname = "";
    private String filterSSN = "";
    private String filterCountryCode = "";
    private boolean filterAllUsers;
    private OrgPerson orgPerson;
    private boolean btnSubmit = false;
    private boolean btnSearch = false;
    private List<Locale> countryList = CountryUtil.getCountries();
    private String redirectAction = null;
    private boolean resetAllGroups = false;
    private boolean keepEmptyParameters = false;
    private boolean removeAllGroups = false;
    private Integer orgCode = null;
    private Set<Integer> permissionRoles;
    private Integer roleValue;
    private boolean remote = false;
    private boolean notifyUser = false;
    private boolean anythingChanged = false;
    private NotificationMail notificationMail = new NotificationMail();
    private String generatedOvertakeCode;
    private Map<Org, List<Person>> orgUsers;
    protected int pageNumber;
    protected long itemCount;
    /** If true, display units associated with each user in user search results */
    private boolean showUserUnits;

    /** If true, display portals associated with each user in user search results */
    private boolean showUserPortalsAll;
    private boolean showUserPortalsOnly;

    /**
     * @param serviceUsr serviceUsr to inject
     * @param serviceCl  serviceCl  to inject (unused)
     * @param serviceGrp serviceGrp to inject
     * @param oService   oService   to inject
     */
    public UserAction(UserService serviceUsr, ClassifierService serviceCl,
            GroupService serviceGrp, OrgService oService) {
        super(serviceUsr);
        this.serviceUsr = serviceUsr;
//        this.serviceCl = serviceCl;
        this.serviceGrp = serviceGrp;
        this.oService = oService;
    }

    private void initAllRoles() {
        // user role is shown for organization's portal always, and for universal & businessportal if a unit is active
        // org
        if (portal != null && activeOrg != null
                && (portal.getMispType() == Const.MISP_TYPE_SIMPLE
                    || (portal.getMispType() == Const.MISP_TYPE_ORGANISATION
                    || portal.getMispType() == Const.MISP_TYPE_UNIVERSAL)
                    && activeOrg.getSupOrgId() != null)) {
                ALL_ROLES.put(Roles.DUMBUSER, getText("roles." + Roles.DUMBUSER));
        }

        ALL_ROLES.put(Roles.PERMISSION_MANAGER, getText("roles." + Roles.PERMISSION_MANAGER));
        if (activeOrg.getSupOrgId() == null) { // only for top level org users we can set services manager role
            ALL_ROLES.put(Roles.DEVELOPER, getText("roles." + Roles.DEVELOPER));
        }
        if (role == Roles.PORTAL_MANAGER) // only for PORTAL_MANAGER we show portal manager role
            ALL_ROLES.put(Roles.PORTAL_MANAGER, getText("roles." + Roles.PORTAL_MANAGER));
    }

    @Override
    public void prepare() throws Exception {
        super.prepare();
        setPortalId(portal.getId());

        if (org != null) {
            activeOrg = serviceUsr.reAttach(org, Org.class);
        } else {
            throw new NullPointerException("Org is null");
        }

        if (portal.getMispType() == Const.MISP_TYPE_SIMPLE
                || (portal.getMispType() == Const.MISP_TYPE_ORGANISATION
                || portal.getMispType() == Const.MISP_TYPE_UNIVERSAL)
                && activeOrg.getSupOrgId() != null) {
            allGroups = serviceGrp.findGroups(activeOrg.getId(), portal.getId());
        }
        
        
        // Only portal manager may see user roles in other portals if configured
        String userPortalConf = CONFIG.getString("show_user_portals", "false");
        showUserPortalsOnly = false;
        showUserPortalsAll = false;
        if (role == Roles.PORTAL_MANAGER) {
            if (userPortalConf.equals("portals_only")) {
                showUserPortalsOnly = true;
            } else if (userPortalConf.trim().equals("all")) {
                showUserPortalsAll = true;
            }
        }

        // Show unit column for each user if units are used
        // and info for all portals is not already shown (otherwise unit info is duplicated)
        showUserUnits = !showUserPortalsAll && activeOrg != null
                && activeOrg.getSupOrgId() == null && (
                           portal.getMispType() == Const.MISP_TYPE_UNIVERSAL
                        || portal.getMispType() == Const.MISP_TYPE_ORGANISATION);
        
        initAllRoles();

        // if action is called out by redirect for instance from UnitRegistration
        if (remote) {
            permissionRoles = Roles.getAllRolesSet(roleValue);
        }
        
        try {
            if (userId != null) { // show existing user, this part is run only when showing user
                person = serviceUsr.findObject(Person.class, userId);

                ssn = person.getSsn().substring(COUNRTY_CODE_LENGTH, person.getSsn().length());
                countryCode = person.getSsn().substring(0, COUNRTY_CODE_LENGTH);

                personMailOrg = serviceUsr.findPersonMailOrg(userId, activeOrg.getId());
                if (personMailOrg != null) {
                    notifyUser = personMailOrg.getNotifyChanges();
                    LOG.debug("Set notifyUser = " + notifyUser);
                }
                orgPerson = serviceUsr.findOrgPerson(userId, activeOrg.getId(), portal.getId());
                LOG.debug("Org person in prepare " + orgPerson);
                if (userGroups.isEmpty()) {
                    for (GroupPerson groupPrivate : person.getGroupPersonList()) {
                        if (Integer.valueOf(groupPrivate.getOrg().getId()).equals(activeOrg.getId())
                                && groupPrivate.getPersonGroup().getPortal().equals(portal)) {
                            userGroups.add(groupPrivate.getPersonGroup().getId());
                        }
                    }
                }
                if (userGroupsValid.isEmpty()) {
                    for (GroupPerson g : person.getGroupPersonList()) {
                        if (Integer.valueOf(g.getOrg().getId()).equals(activeOrg.getId())
                                && g.getPersonGroup().getPortal().equals(portal)) {
                            userGroupsValid.put(g.getPersonGroup().getId(), g.getValiduntil());
                        }
                    }
                }
            }
        } catch (Exception e) {
            LOG.error(e.getMessage(), e);
        }
    }

    /**
     * @return ERROR if deleting or saving users fails, SUCCESS otherwise
     */
    @HTTPMethods(methods = {HTTPMethod.GET, HTTPMethod.POST})//TODO: Should be only POST, but "ee.aktors.misp2.action.registration" package actions redirect to this method
    @ApplyCSRFProtectionAlways
    public String userViewSubmit() {
        int oldRole = Roles.NO_RIGHTS;
        int role = Roles.calculateRole(permissionRoles);

        if (resetAllGroups) {
            LOG.debug("Resetting all groups");
            userGroups = new ArrayList<Integer>(allGroups.size());
            userGroupsValid= new HashMap<Integer, Date>();
            for (PersonGroup g : allGroups) {
                userGroups.add(g.getId());
            }
        }
        if (removeAllGroups) {
            LOG.debug("All person group relationships will be removed");
            userGroups = new ArrayList<Integer>(0);
            userGroupsValid = new HashMap<Integer, Date>(0);
            userGroupsVret = new HashMap<Integer, Date>(0);
        }
        try {
            List<GroupPerson> gps = null;
            Person oldPerson = null;
            if (person.getId() != null) { // existing user submitted
                LOG.debug("Existing user submitted");
                personMailOrg = serviceUsr.findPersonMailOrg(person.getId(), activeOrg.getId());
                if (personMailOrg != null) {
                    notifyUser = personMailOrg.getNotifyChanges();
                }
                oldPerson = serviceUsr.findObject(Person.class, person.getId());
                if (oldPerson != null) {
                    person.setPassword(oldPerson.getPassword());
                    person.setPasswordSalt(oldPerson.getPasswordSalt());
                    person.setOvertakeCode(oldPerson.getOvertakeCode());
                    person.setOvertakeCodeSalt(oldPerson.getOvertakeCodeSalt());
                    person.setCertificate(oldPerson.getCertificate());
                    person.setCreated(oldPerson.getCreated());
                    gps = oldPerson.getGroupPersonList();
                } else {
                    LOG.error("oldPerson is null");
                }
            } else {
                LOG.debug("New user sumitted");
                gps = (gps != null ? gps : new ArrayList<GroupPerson>(1));// new users do not have bound orgs or groups yet
            }
            personMailOrg = (personMailOrg == null ? new PersonMailOrg() : personMailOrg);

            //Social security nr stuff
            person.setSsn(countryCode + ssn.trim());
            // -------------------------------- ssn end ---

            if(updatePassword){
                person.setPasswordSalt(PasswordUtil.getSalt());
                person.setPassword(PasswordUtil.encryptPassword(newPassword, person.getPasswordSalt()));
            }
            
            List<GroupValidPair> addedGroups = new ArrayList<GroupValidPair>();
            List<GroupValidPair> removedGroups = new ArrayList<GroupValidPair>();// for logging

            if (person.getId() == null) { // new user
                T3SecWrapper t3 = initT3(LogQuery.USER_ADD);
                t3.getT3sec().setUserTo(person.getSsn());
                if (!log(t3)) {
                    addActionError(getText("text.fail.save.log"));
                    LOG.warn("Saving user failed because of logging problems.");
                    return ERROR;
                }
                person.setGivenname(person.getGivenname().trim());
                person.setSurname(person.getSurname().trim());
                serviceUsr.save(person);
                personMailOrg.setMail(mail);
                personMailOrg.setPersonId(person);
                personMailOrg.setOrgId(activeOrg);

                // new user always gets new association with PersonMailOrg
                List<PersonMailOrg> pmos = new ArrayList<PersonMailOrg>(1);
                pmos.add(personMailOrg);
                person.setPersonMailOrgList(pmos);


                //this is where new user gets his groups bound
                for (Integer gId : userGroups) {
                    GroupPerson gp = new GroupPerson();
                    gp.setPerson(person);
                    gp.setPersonGroup(serviceUsr.findObject(PersonGroup.class, gId));
                    gp.setOrg(activeOrg);
                    Date valDate = userGroupsVret.get(gId);
                    if (valDate != null) {
                        gp.setValiduntil(valDate);
                    }
                    addedGroups.add(new GroupValidPair(gp.getPersonGroup().getName(), (valDate != null ? valDate.toString() : null)));
                    gps.add(gp);
                }
            } else { //existing user
                List<GroupPerson> userOrgGroupPersons = serviceUsr.findGroupPersons(person.getId(), activeOrg.getId());


                // SSN change not allowed
                Person oldP = serviceUsr.findObject(Person.class, person.getId());
                // reset ssn to whatever was there b4
                person.setSsn(oldP.getSsn());
                person.setCreated(oldP.getCreated());

                for (GroupPerson gp : userOrgGroupPersons) {
                    if (!userGroups.contains(gp.getPersonGroup().getId())) {
                        removedGroups.add(new GroupValidPair(gp.getPersonGroup().getName()));
                        gps.remove(gp);
                        serviceUsr.remove(gp);
                    }
                }
                //log only if any groups were removed
                if (!removedGroups.isEmpty()) {
                    anythingChanged = true;
                    T3SecWrapper t3 = initT3(LogQuery.USER_DELETE_FROM_GROUP);
                    t3.getT3sec().setUserTo(person.getSsn());
                    t3.setGroups(removedGroups);
                    if (!log(t3)) {
                        addActionError(getText("text.fail.save.log"));
                        LOG.warn("Deleting user from group failed because of logging problems.");
                        return ERROR;
                    }
                }
                for (Integer gId : userGroups) {
                    GroupPerson gp = serviceUsr.findGroupPerson(gId, person.getId(), activeOrg.getId());

                    Date valDate = userGroupsVret.get(gId);
                    if (gp == null) {
                        // new group added to user
                        gp = new GroupPerson();
                        gp.setPerson(person);
                        gp.setPersonGroup(serviceUsr.findObject(PersonGroup.class, gId));
                        gp.setOrg(activeOrg);

                        addedGroups.add(new GroupValidPair(gp.getPersonGroup().getName(), (valDate != null ? valDate.toString() : null)));
                    } else if (gp.getValiduntil() != null) {
                        if (!gp.getValiduntil().equals(valDate)) {// user was in group before but his valid_until date was changed 
                            addedGroups.add(new GroupValidPair(gp.getPersonGroup().getName(), (valDate != null ? valDate.
                                    toString() : null)));
                        }
                    } else {
                        if (valDate != null) {
                            addedGroups.add(new GroupValidPair(gp.getPersonGroup().getName(), (valDate != null ? valDate.
                                    toString() : null)));
                        }
                    }

                    gp.setValiduntil(valDate);
                    int idx = 0;
                    boolean ex = false;
                    for (GroupPerson gp1 : gps) {
                        if (gp1.equals(gp)) {
                            ex = true;
                            break;
                        }
                        idx++;
                    }
                    if (ex) {
                        gps.set(idx, gp);
                    } else {
                        gps.add(gp);
                    }
                }

                if (!addedGroups.isEmpty()) {
                    anythingChanged = true;
                    T3SecWrapper t3 = initT3(LogQuery.USER_ADD_TO_GROUP);
                    t3.getT3sec().setUserTo(person.getSsn());
                    t3.setGroups(addedGroups);
                    if (!log(t3)) {
                        addActionError(getText("text.fail.save.log"));
                        LOG.warn("Adding user to group failed because of logging problems.");
                        return ERROR;
                    }
                }

                List<PersonMailOrg> pmos = person.getPersonMailOrgList();
                pmos = (pmos == null ? new ArrayList<PersonMailOrg>(1) : pmos);
                int idx = 0;
                boolean ex = false;
                for (PersonMailOrg pmo : pmos) {
                    if (pmo.equals(personMailOrg)) {
                        ex = true;
                        personMailOrg = pmo;
                        break;
                    }
                    idx++;
                }
                if (personMailOrg == null) {
                    personMailOrg = new PersonMailOrg();
                }
                personMailOrg.setPersonId(person);
                personMailOrg.setOrgId(activeOrg);
                if (!keepEmptyParameters) {
                    personMailOrg.setMail(mail);
                    personMailOrg.setNotifyChanges(notifyUser);
                }

                if (ex) {
                    pmos.set(idx, personMailOrg);
                } else {
                    pmos.add(personMailOrg);
                }
                person.setPersonMailOrgList(pmos);
            }

            // organisatsiooni ja kasutaja vahelise seose loomine
            List<OrgPerson> newOps = new ArrayList<OrgPerson>();

            LOG.debug("Starting to bind active org with user. OrgPerson = " + orgPerson);
            if (orgPerson != null) {
                if (orgPerson.getId() != null) {
                    oldRole = serviceUsr.reAttach(orgPerson, OrgPerson.class).getRole();
                } else {
                    LOG.warn("Cannot set oldRole because orgPerson does not have id field set.");
                }
                // Don't allow setting portal manager or admin roles (1)
                if (Roles.hasRoleChangedInReference(oldRole, role, Roles.PORTAL_MANAGER, Roles.PORTAL_ADMIN)) {
                    addActionError(getText("users.error.changing_admin_role_not_allowed"));
                    LOG.error("Cannot set portal admin or portal manager user roles through this view!"
                            + " (1. roles " + permissionRoles + ", oldRole: " + oldRole + ", newRole: " + role + ")");
                    return ERROR;
                }
                // Don't allow setting roles not defined in ALL_ROLES (1)
                List<Integer> undefinedRoles = Roles.findUndefinedRoles(role, ALL_ROLES.keySet());
                if (undefinedRoles.size() > 0) {
                    String[] args = {undefinedRoles.toString()};
                    addActionError(getText("users.error.cannot_set_undefined_roles", args));
                    LOG.error("Cannot set role " + role
                            + ". (1. It contains unexpected (sub)role(s) "
                            + undefinedRoles + " not defined in " + ALL_ROLES.keySet() + ".)");
                    return ERROR;
                }
                if (Roles.hasAnyRights(role)) { // vaja luua seos
                    LOG.debug("New binding must be created");
                    orgPerson.setPersonId(person);
                    orgPerson.setOrgId(activeOrg);
                    orgPerson.setPortal(portal);
                    orgPerson.setRole(role);

                    boolean ex = false;
                    if (oldPerson != null) {
                        if (oldPerson.getOrgPersonList() != null && !oldPerson.getOrgPersonList().isEmpty()) {
                            for (OrgPerson op : oldPerson.getOrgPersonList()) {
                                if (!op.equals(orgPerson)) {
                                    newOps.add(op);
                                } else {
                                    ex = true;
                                    newOps.add(orgPerson);
                                }
                            }
                        }
                    }
                    if (!ex) {
                        newOps.add(orgPerson);
                    }
                } else {
                    // seost ei looda ja olemasolev kustutatakse
                    LOG.debug("No new bound made and any resident ones will be deleted.");
                    if (oldPerson != null) {
                        List<OrgPerson> ops = oldPerson.getOrgPersonList();
                        oldPerson.setOrgPersonList(null);
                        for (OrgPerson op : ops) {
                            if (op.equals(orgPerson)) {
                                serviceUsr.remove(op);
                            } else {
                                newOps.add(op);
                            }
                        }
                    }
                }
            } else {
                LOG.debug("orgPerson is null. Role = " + role);
                // Don't allow setting portal manager or admin roles (2)
                if (Roles.hasRoleChangedInReference(oldRole, role, Roles.PORTAL_MANAGER, Roles.PORTAL_ADMIN)) {
                    addActionError(getText("users.error.changing_admin_role_not_allowed"));
                    LOG.error("Cannot set portal admin or portal manager user roles through this view!"
                            + " (2. roles " + permissionRoles + ", oldRole: " + oldRole + ", newRole: " + role + ")");
                    return ERROR;
                }
                // Don't allow setting roles not defined in ALL_ROLES (2)
                List<Integer> undefinedRoles = Roles.findUndefinedRoles(role, ALL_ROLES.keySet());
                if (undefinedRoles.size() > 0) {
                    String[] args = {undefinedRoles.toString()};
                    addActionError(getText("users.error.cannot_set_undefined_roles", args));
                    LOG.error("Cannot set role " + role
                            + ". (2. It contains unexpected (sub)role(s) "
                            + undefinedRoles + " not defined in " + ALL_ROLES.keySet() + ".)");
                    return ERROR;
                }
                if (Roles.hasAnyRights(role)) {
                    boolean ex = false;
                    LOG.debug("Creating new orgPerson");
                    orgPerson = new OrgPerson();
                    orgPerson.setPersonId(person);
                    orgPerson.setOrgId(activeOrg);
                    orgPerson.setRole(role);
                    orgPerson.setPortal(portal);
                    if (person.getId().equals(((Person) session.get(Const.SESSION_USER_HANDLE)).getId())) {
                        Auth a = (Auth) session.get(Const.SESSION_AUTH);
                        a.setNewUser(false);
                        session.put(Const.SESSION_AUTH, a);
                    }


                    if (oldPerson != null) {
                        if (oldPerson.getOrgPersonList() != null && !oldPerson.getOrgPersonList().isEmpty()) {
                            for (OrgPerson op : oldPerson.getOrgPersonList()) {
                                if (!op.equals(orgPerson)) {
                                    newOps.add(op);
                                } else {
                                    ex = true;
                                    newOps.add(orgPerson);
                                }
                            }
                        }
                    }
                    if (!ex) {
                        newOps.add(orgPerson);
                    }
                    LOG.debug("All persons orgPersons: " + newOps);
                }
            }

            person.setOrgPersonList(newOps);
            if (removeAllGroups) {
                person.setGroupPersonList(null);
            } else {
                person.setGroupPersonList(gps);
            }

            if (Roles.hasRoleChanged(oldRole, role)) {
                anythingChanged = true;
            }

            Boolean addedManager = Roles.wasManagerAdded(oldRole, role);

            if (addedManager != null) {

                T3SecWrapper t3 = null;
                if (addedManager) {
                    anythingChanged = true;
                    LOG.debug("Manager was added");
                    t3 = initT3(LogQuery.MANAGER_SETTING);
                } else {
                    anythingChanged = true;
                    LOG.debug("Manager was deleted");
                    t3 = initT3(LogQuery.MANAGER_DELETE);
                }
                t3.getT3sec().setUserTo(person.getSsn());
                if (!log(t3)) {
                    addActionError(addedManager ? getText("text.fail.save.log") : getText("text.fail.delete.log"));
                    LOG.warn(addedManager ? getText("text.fail.save.log") : getText("text.fail.delete.log"));
                    return ERROR;
                }

            }
            person.setGivenname(person.getGivenname().trim());
            person.setSurname(person.getSurname().trim());
            serviceUsr.save(person);
            if (person.equals(session.get(Const.SESSION_USER_HANDLE))) {
                session.put(Const.SESSION_USER_HANDLE, person);
            }

            // send notification mail
            if (anythingChanged && notifyUser) {
                notificationMail.setAddedGroups(addedGroups);
                notificationMail.setRemovedGroups(removedGroups);
                notificationMail.setAddedRoles(Roles.addedRoles(oldRole, role));
                notificationMail.setRemovedRoles(Roles.removedRoles(oldRole, role));
                notificationMail.setReceiverEmail(personMailOrg.getMail());
                notificationMail.setReceiverName(person.getFullName());
                notificationMail.setOrganizationName(serviceUsr.findObject(Org.class, ((Org) session.get(Const.SESSION_ACTIVE_ORG)).getId()).getFullName(getLocale().getLanguage()));
                notificationMail.send();
            }

            addActionMessage(getText("text.success.save"));
        } catch (NullPointerException e) {
            LOG.error("Something was null over here.");
            LOG.error(e.getMessage(), e);

        } catch (Exception e) {
            LOG.error(e.getMessage(), e);
        }
        userId = person.getId();

        if (redirectAction != null) {
            return "redirect";
        }
        return SUCCESS;
    }


    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String showUser() {
        if (userId != null) {
            if (personMailOrg != null) {
                mail = personMailOrg.getMail();
            }

            if (orgPerson != null) {
                Integer r = orgPerson.getRole();
                permissionRoles = Roles.getAllRolesSet(r);
                session.put(SESSION_LAST_ROLE, r);
            }
        }
        return SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String showFilter() {
        return SUCCESS;
    }

    /**
     * @return ERROR if ssn filter is missing, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String filter() {
        String countrySSN = (filterCountryCode != null && filterCountryCode.isEmpty()
                ? "__" : filterCountryCode) + filterSSN;
        if (!filterAllUsers) {
            LOG.debug("Searching only active units users");
            searchResults = serviceUsr.findOrgUsers(
                    filterGivenName, filterSurname, countrySSN, activeOrg, pageNumber, PAGE_SIZE);
            itemCount = serviceUsr.countOrgUsers(
                    filterGivenName, filterSurname, countrySSN, activeOrg);
            if (portal != null
                    && (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL
                    || portal.getMispType() == Const.MISP_TYPE_ORGANISATION)
                    && (filterGivenName == null || filterGivenName.isEmpty())
                    && (filterSurname == null || filterSurname.isEmpty())
                    && (filterCountryCode == null || filterCountryCode.isEmpty())
                    && (filterSSN == null || filterSSN.isEmpty())) {
                orgUsers = new HashMap<Org, List<Person>>();
                List<Org> subOrgs = oService.findSubOrgs(activeOrg);
                if (subOrgs != null) {
                    for (Org o : subOrgs) {
                        List<Person> p = serviceUsr.findAllOrgUsers(o, portal);
                        if (p != null && !p.isEmpty()) {
                            orgUsers.put(o, p);
                        }
                    }
                }
            }
        } else {
            LOG.debug("Searching user with ssn: "
                    + (filterCountryCode != null
                    && filterCountryCode.isEmpty() ? "__" : filterCountryCode) + filterSSN);
            searchResults = new ArrayList<Person>();
            if (session.get(Const.SESSION_USER_ROLE).equals(Roles.PORTAL_MANAGER)) { // for portal manager
                searchResults = serviceUsr.findUsers(filterGivenName, filterSurname, countrySSN, pageNumber, PAGE_SIZE);
                itemCount = serviceUsr.countUsers(filterGivenName, filterSurname, countrySSN);
            } else { // for everyone else
                if (filterSSN == null || filterSSN.isEmpty()) {
                    searchResults = null;
                    addActionError(getText("users.filter.ssn.missing"));
                    return ERROR;
                }
                Person findPerson = serviceUsr.findPersonBySSN((filterCountryCode != null
                        && filterCountryCode.isEmpty() ? "__" : filterCountryCode)
                        + filterSSN);
                if (findPerson != null) {
                    searchResults.add(findPerson);
                }
            }
        }
        return SUCCESS;
    }

    @Override
    public void validate() {
        if (btnSearch && filterAllUsers && filterSSN.trim().isEmpty()) {
            addActionError(getText("validation.illegal_search"));
            addFieldError("filterSSN", getText("validation.input_required"));
        }

        if (btnSubmit) {
            if (countryCode == null || countryCode.isEmpty()) {
                String msg = getText("validation.input_required");
                addFieldError("ssn", msg);
                LOG.debug("Not valid: " + msg);
                return;
            }
            if (person != null) {

                if (activeOrg != null) {
                    if (orgPerson != null) {
                        OrgPerson activeOP = serviceUsr
                                .findOrgPerson(person.getId(), activeOrg.getId(), portal.getId());
                        int r = (Integer) session.get(Const.SESSION_USER_ROLE);
                        if (activeOP != null) {
                            if (!Roles.isSet(r, Roles.PORTAL_MANAGER) // no portal manager
                                    && !Roles.isSet(activeOP.getRole(), Roles.PORTAL_MANAGER) // user not portal manager
                                                                                              // already
                                    && Roles.isSet(Roles.calculateRole(permissionRoles), Roles.PORTAL_MANAGER)
                                    // new role has portal managers flag
                            ) {
                                addFieldError("permissionRoles", getText(""));
                                // return;
                            }
                        } else {
                            // user didn't have orgPerson relationship with current org
                            if (!Roles.isSet(r, Roles.PORTAL_MANAGER) // no portal manager
                                    && Roles.isSet(Roles.calculateRole(permissionRoles), Roles.PORTAL_MANAGER)
                                    // new role has portal managers flag
                            ) {
                                addFieldError("permissionRoles", getText("validation.role_add.portal_manager"));
                            }
                        }
                        // }
                    } else {
                        LOG.warn("orgPerson is null");
                    }
                } else {
                    LOG.warn("activeOrg is null");
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

                if (ssn != null && !ssn.isEmpty()) {
                    LOG.debug("Validating ssn [" + ssn + "]");
                    try {
                        if (!SSNValidator.validateSSN(ssn, countryCode)) {
                            String msg = getText("validation.not_valid",
                                    new String[] {getText("users.show.label.ssn") });
                            addFieldError("ssn", msg);
                            LOG.debug("Not valid: " + msg);
                            return;
                        }
                    } catch (NotSupportedException ex) {
                        // XXX: ssn validation not supported (ignore this)
                        // at the moment just ignore and move on
                    }
                    Person p = serviceUsr.findPersonBySSN(countryCode + ssn);
                    if (person.getId() == null && p != null) {
                        String msg = getText("validation.in_use", new String[] {getText("users.show.label.ssn") });
                        addFieldError("ssn", msg);
                        LOG.debug("Not valid: " + msg);
                        return;
                    } else if (p != null && p.getId() != null && !p.getId().equals(person.getId())) {
                        String msg = getText("validation.in_use", new String[] {getText("users.show.label.ssn") });
                        addFieldError("ssn", msg);
                        LOG.debug("Not valid: " + msg);
                        return;
                    }
                    LOG.debug("Valid ssn " + ssn);

                    Person existingUser = serviceUsr.findPersonBySSN(countryCode + ssn);
                    person.setSsn(countryCode + ssn);

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

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String deleteUserConfirmed() {
        if (userId != null) {
            Person xs = null;
            try {
                xs = serviceUsr.findObject(Person.class, userId);
            } catch (Exception e) {
                LOG.error(e.getMessage(), e);
            }

            if (xs != null) {
                serviceUsr.remove(xs);
            } else {
                LOG.error("No user found for id=" + userId + ". Nothing was deleted");
            }
        }
        addActionMessage(getText("text.success.delete"));
        return SUCCESS;
    }

    /**
     * @return ERROR if user deleting fails, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String deleteUser() {
        if (userId != null) {

            Person p = null;
            try {
                p = serviceUsr.findObject(Person.class, userId);
                Org activeOrgPrivate = (Org) session.get(Const.SESSION_ACTIVE_ORG);
                OrgPerson activeOrgPerson = null;
                List<OrgPerson> orgPersons = p.getOrgPersonList();
                for (OrgPerson op : orgPersons) {
                    if (op.getOrgId().getId().equals(activeOrgPrivate.getId())) {
                        // Found OrgPerson with active organization
                        activeOrgPerson = op;
                    } else { // Deletion will be denied if person has rights in non-active organization
                        if (Roles.hasAnyRights(op.getRole().intValue())) {
                            addActionError(getText("users.error.other_rights"));
                            return ERROR;
                        }
                    }
                }
                // If user has any rights in active organization, then ask for confirmation for deletion
                if (activeOrgPerson != null && Roles.hasAnyRights(activeOrgPerson.getRole().intValue())) {
                    return "confirm";
                }

            } catch (Exception e) {
                LOG.error(e.getMessage(), e);
            }

            if (p != null) {
                // log user delete
                T3SecWrapper t3 = initT3(LogQuery.USER_DELETE);
                t3.getT3sec().setUserTo(p.getSsn());
                if (!log(t3)) {
                    addActionError(getText("text.fail.delete.log"));
                    LOG.warn("User delete failed because of logging problems.");
                    return ERROR;
                }
                serviceUsr.remove(p);
            } else {
                LOG.error("No user found for id=" + userId + ". Nothing was deleted");
            }
        } else {
            LOG.error("User id not set styleId=" + userId + ". Nothing was deleted");
        }
        addActionMessage(getText("text.success.delete"));
        return SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String addUser() {
        return SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String genCodeUser() {
        setGeneratedOvertakeCode(serviceUsr.generateOvertakeCode());
        LOG.debug(getGeneratedOvertakeCode());
        if (userId != null) {

            Person p = null;
            try {
                p = serviceUsr.findObject(Person.class, userId);
                p.setOvertakeCodeSalt(PasswordUtil.getSalt());
                p.setOvertakeCode(PasswordUtil.encryptPassword(getGeneratedOvertakeCode(), p.getOvertakeCodeSalt()));
                serviceUsr.save(p);
            } catch (Exception e) {
                LOG.error(e.getMessage(), e);
            }
        }
        return Action.SUCCESS;
    }

    /**
     * @return the updatePassword
     */
    public boolean getUpdatePassword(){
        return updatePassword;
    }

    /**
     * @return allRoles
     */
    public Map<Integer, String> getAllRoles() {
        return ALL_ROLES;
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
     * @return the profession
     */
    public String getProfession() {
        return profession;
    }

    /**
     * @param professionNew the profession to set
     */
    public void setProfession(String professionNew) {
        this.profession = professionNew;
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
     * @return the allGroups
     */
    public List<PersonGroup> getAllGroups() {
        return allGroups;
    }

    /**
     * @param allGroupsNew the allGroups to set
     */
    public void setAllGroups(List<PersonGroup> allGroupsNew) {
        this.allGroups = allGroupsNew;
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
     * @return the filterAllUsers
     */
    public boolean isFilterAllUsers() {
        return filterAllUsers;
    }

    /**
     * @param filterAllUsersNew the filterAllUsers to set
     */
    public void setFilterAllUsers(boolean filterAllUsersNew) {
        this.filterAllUsers = filterAllUsersNew;
    }

    /**
     * @return the userGroups
     */
    public List<Integer> getUserGroups() {
        return userGroups;
    }

    /**
     * @return the searchResults
     */
    public List<Person> getSearchResults() {
        return searchResults;
    }

    /**
     * @param userGroupsNew the userGroups to set
     */
    public void setUserGroups(List<Integer> userGroupsNew) {
        this.userGroups = userGroupsNew;
    }

    /**
     * @return the userGroupsValid
     */
    public Map<Integer, Date> getUserGroupsValid() {
        return userGroupsValid;
    }

    /**
     * @param userGroupsValidNew the userGroupsValid to set
     */
    public void setUserGroupsValid(Map<Integer, Date> userGroupsValidNew) {
        this.userGroupsValid = userGroupsValidNew;
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
     * @return the userGroupsVret
     */
    public Map<Integer, Date> getUserGroupsVret() {
        return userGroupsVret;
    }

    /**
     * @param userGroupsVretNew the userGroupsVret to set
     */
    public void setUserGroupsVret(Map<Integer, Date> userGroupsVretNew) {
        this.userGroupsVret = userGroupsVretNew;
    }

    /**
     * @param btnSubmitNew btnSubmit to set
     */
    public void setBtnSubmit(String btnSubmitNew) {
        this.btnSubmit = !(btnSubmitNew == null || btnSubmitNew.isEmpty());
    }

    /**
     * @param btnSearchNew btnSearch to set
     */
    public void setBtnSearch(String btnSearchNew) {
        this.btnSearch = !(btnSearchNew == null || btnSearchNew.isEmpty());
    }

    /**
     * @return the orgId
     */
    public Integer getOrgId() {
        return orgId;
    }

    /**
     * @param orgIdNew the orgId to set
     */
    public void setOrgId(Integer orgIdNew) {
        this.orgId = orgIdNew;
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
     * @return the mail
     */
    public String getMail() {
        return mail;
    }

    /**
     * @param mailNew the mail to set
     */
    public void setMail(String mailNew) {
        this.mail = mailNew;
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
     * @return the resetAllGroups
     */
    public boolean isResetAllGroups() {
        return resetAllGroups;
    }

    /**
     * @param resetAllGroupsNew the resetAllGroups to set
     */
    public void setResetAllGroups(boolean resetAllGroupsNew) {
        this.resetAllGroups = resetAllGroupsNew;
    }

    /**
     * @return the keepEmptyParameters
     */
    public boolean isKeepEmptyParameters() {
        return keepEmptyParameters;
    }

    /**
     * @param keepEmptyParametersNew the keepEmptyParameters to set
     */
    public void setKeepEmptyParameters(boolean keepEmptyParametersNew) {
        this.keepEmptyParameters = keepEmptyParametersNew;
    }

    /**
     * @return the orgCode
     */
    public Integer getOrgCode() {
        return orgCode;
    }

    /**
     * @return the permissionRoles
     */
    public Set<Integer> getPermissionRoles() {
        return permissionRoles;
    }

    /**
     * @param orgCodeNew the orgCode to set
     */
    public void setOrgCode(Integer orgCodeNew) {
        this.orgCode = orgCodeNew;
    }


    /**
     * @param permissionRolesNew the permissionRoles to set
     */
    public void setPermissionRoles(Set<Integer> permissionRolesNew) {
        this.permissionRoles = permissionRolesNew;
    }

    /**
     * @return the removeAllGroups
     */
    public boolean isRemoveAllGroups() {
        return removeAllGroups;
    }

    /**
     * @param roleValueNew the roleValue to set
     */
    public void setRoleValue(Integer roleValueNew) {
        this.roleValue = roleValueNew;
    }

    /**
     * @param remoteNew the remote to set
     */
    public void setRemote(boolean remoteNew) {
        this.remote = remoteNew;
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

    /**
     * @param removeAllGroupsNew the removeAllGroups to set
     */
    public void setRemoveAllGroups(boolean removeAllGroupsNew) {
        this.removeAllGroups = removeAllGroupsNew;
    }

    /**
     * @return the portal
     */
    public Portal getPortal() {
        return portal;
    }

    /**
     * @return the orgUsers
     */
    public Map<Org, List<Person>> getOrgUsers() {
        return orgUsers;
    }

    /**
     * @param orgUsersNew the orgUsers to set
     */
    public void setOrgUsers(Map<Org, List<Person>> orgUsersNew) {
        this.orgUsers = orgUsersNew;
    }

    /**
     * @return the activeOrg
     */
    public Org getActiveOrg() {
        return activeOrg;
    }

    /**
     * @return the pageNumber
     */
    public int getPageNumber() {
        return pageNumber + 1;
    }

    /**
     * @param pageNumberNew to set
     */
    public void setPageNumber(int pageNumberNew) {
        if ((pageNumberNew - 1) > -1) {
            this.pageNumber = pageNumberNew - 1;
        } else {
            this.pageNumber = 0;
        }
    }

    /**
     * @return the itemCount
     */
    public long getItemCount() {
        return itemCount;
    }

    /**
     * @return the pageSize
     */
    public int getPageSize() {
        return PAGE_SIZE;
    }

    /**
     * @return true if associated units need to be displayed in user search results;
     *      false if not
     */
    public boolean isShowUserUnits() {
        return showUserUnits;
    }

    /**
     * @return true if associated portals with units and roles
     *      need to be displayed in user search results;
     *      false if not
     */
    public boolean isShowUserPortalsAll() {
        return showUserPortalsAll;
    }

    /**
     * @return true if associated portals with no units and roles need to be displayed in user search results;
     *      false if not
     */
    public boolean isShowUserPortalsOnly() {
        return showUserPortalsOnly;
    }
    
    /**
     * Find user portals from OrgPerson entity list and assemble it to a string.
     * @param orgPersons entity list for given user
     * @return user portal list as string
     */
    public List<UserPortal> getPortals(List<OrgPerson> orgPersons) {
        LOG.trace("Finding users with associated portals. "
                + "Show portals only: " + showUserPortalsOnly + ", show all: " + showUserPortalsAll);
        return UserPortal.getPortals(orgPersons);
    }
}
