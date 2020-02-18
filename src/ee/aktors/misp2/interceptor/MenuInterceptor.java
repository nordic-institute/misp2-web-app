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

import ee.aktors.misp2.model.Producer.ProtocolType;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;

import com.opensymphony.xwork2.ActionInvocation;

import ee.aktors.misp2.beans.MenuActions;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.MenuUtil;
import ee.aktors.misp2.util.Roles;

/**
 *
 * @author arnis.rips
 */
public class MenuInterceptor extends BaseInterceptor implements StrutsStatics {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LogManager.getLogger(MenuInterceptor.class.getName());
    private static final String ACTIVE_MENU_ITEM = "activeMenuItem";
    private static final int NO_ACTIVE_MENU_ITEM = 0;
    private static final String ROLE_ACTIONS = "roleActions";
    private static MenuActions maServicesManage = new MenuActions(
                                                      MenuUtil.MENU_MG_SERVICES,
                                                      MenuUtil.MENU_AC_MG_SERVICES);
    private static MenuActions maOpenAPIServicesManage = new MenuActions(
                                                             MenuUtil.MENU_MG_OPENAPI_SERVICES,
                                                             "listProducers?protocol=REST",
                                                             MenuUtil.MENU_AC_MG_SERVICES);
    private static MenuActions maXslManage = new MenuActions(MenuUtil.MENU_MG_XSL, MenuUtil.MENU_AC_MG_XSL);
    private static MenuActions maGroupManage = new MenuActions(MenuUtil.MENU_MG_GROUPS, MenuUtil.MENU_AC_MG_GROUPS);
    private static MenuActions maGroupManageWithoutMembers = new MenuActions(MenuUtil.MENU_MG_GROUPS,
                                                                 MenuUtil.MENU_AC_MG_GROUPS_WITHOUT_MG_MEMBERS);
    private static MenuActions maUsersManage = new MenuActions(MenuUtil.MENU_MG_USERS, MenuUtil.MENU_AC_MG_USERS);
    private static MenuActions maRegUnit = new MenuActions(MenuUtil.MENU_REG_UNIT, MenuUtil.MENU_AC_REG_UNIT);
    private static MenuActions maUseServices = new MenuActions(MenuUtil.MENU_SERVICES, MenuUtil.MENU_AC_SERVICES);
    private static MenuActions maUserQueryLogs = new MenuActions(MenuUtil.MENU_QUERY_LOGS, MenuUtil.MENU_AC_QUERY_LOGS);
    private static MenuActions maUserSettings = new MenuActions(MenuUtil.MENU_USER_SETTINGS,
                                                                MenuUtil.MENU_AC_USER_SETTINGS);
    private static MenuActions maClassifiers = new MenuActions(MenuUtil.MENU_MG_CLASSIFIERS,
                                                               MenuUtil.MENU_AC_MG_CLASSIFIERS);
    private static MenuActions maThemes = new MenuActions(MenuUtil.MENU_THEMES, MenuUtil.MENU_AC_TOPICS);
    private static MenuActions maMgrQueryLogs = new MenuActions(MenuUtil.MENU_QUERY_LOGS,
                                                                MenuUtil.MENU_AC_MGR_QUERY_LOGS);
    private static MenuActions maRegUser = new MenuActions(MenuUtil.MENU_REG_USER, MenuUtil.MENU_AC_REG_USER);
    private static MenuActions maRegManager = new MenuActions(MenuUtil.MENU_REG_MANAGER, MenuUtil.MENU_AC_REG_MANAGER);
    private static MenuActions maMgUnits = new MenuActions(MenuUtil.MENU_MG_UNITS, MenuUtil.MENU_AC_MG_UNITS);
    private static MenuActions maLogs = new MenuActions(MenuUtil.MENU_LOGS, MenuUtil.MENU_AC_LOGS);
    private static MenuActions maRegUkManager = new MenuActions(MenuUtil.MENU_REG_MANAGER,
                                                                MenuUtil.MENU_AC_REG_UK_MANAGER);
    private static MenuActions maLogins = new MenuActions(NO_ACTIVE_MENU_ITEM, MenuUtil.MENU_AC_LOGIN);
    private static MenuActions maChangeAdminPassword = new MenuActions(MenuUtil.MENU_CHANGE_ADMIN_PASSWORD,
                                                                       MenuUtil.MENU_AC_CHANGE_ADMIN_PASSWORD);
    private static MenuActions maNews = new MenuActions(MenuUtil.MENU_NEWS, MenuUtil.MENU_AC_NEWS);
    private static MenuActions maExportImport = new MenuActions(MenuUtil.MENU_EXPORT_IMPORT,
                                                                MenuUtil.MENU_AC_EXPORT_IMPORT);
    private static MenuActions maServiceDigitalSigning = new MenuActions(MenuUtil.MENU_SERVICE_AC_DIGITAL_SIGNING,
                                                                         MenuUtil.SERVICE_AC_DIGITAL_SIGNING,
                                                                        false);

    /**
     * Validates if action performed by user is allowed
     * @see com.opensymphony.xwork2.interceptor.Interceptor#intercept(com.opensymphony.xwork2.ActionInvocation)
     * @param invocation a action invocation
     * @return invocation return code
     * @throws Exception can throw
     */
    public String intercept(ActionInvocation invocation) throws Exception {
        LOGGER.debug("MENU INTERCEPTOR");
        Map<String, Object> session = invocation.getInvocationContext().getSession();

        Integer userRole = (Integer) session.get(Const.SESSION_USER_ROLE);
        
        if (userRole == null) {
            LOGGER.error("NO ROLE SET");
            userRole = Roles.NO_RIGHTS;
        }

        HashMap<Integer, List<MenuActions>> roleActions = setUpRoles(invocation, session, userRole);
        
        invocation.getInvocationContext().put(ROLE_ACTIONS, roleActions);

        String currentActionName = invocation.getInvocationContext().getName();
        if (currentActionName.startsWith("runQuery")) {
            currentActionName = "runQuery";
        }

        List<MenuActions> currentActions = new ArrayList<MenuActions>();

        if (userRole == Roles.NO_RIGHTS) {
            currentActions.add(maLogins);
        } else {
            currentActions = roleActions.get(session.get(Const.SESSION_USER_ROLE));
        }

        boolean isActionAllowed = false;
        if (currentActions != null) {
            if(invocation.getInvocationContext().getParameters().contains("protocol")
            && ProtocolType.REST.toString().equals(invocation.getInvocationContext().getParameters().get("protocol").toString())
            && maOpenAPIServicesManage.contains(currentActionName)) {
                isActionAllowed = true;
                invocation.getInvocationContext().put(ACTIVE_MENU_ITEM, maOpenAPIServicesManage.getMenuItem());
            } else {
                for (MenuActions ma : currentActions) {
                    if (ma.contains(currentActionName)) {
                        isActionAllowed = true;
                        invocation.getInvocationContext().put(ACTIVE_MENU_ITEM, ma.getMenuItem());
                        break;
                    }
                }
            }
        }

        if (!isActionAllowed) {
            if (currentActionName.endsWith(MenuUtil.MENU_AC_HELP_POSTFIX)
                    || MenuUtil.MENU_AC_LOGIN.contains(currentActionName)
                    || currentActionName.endsWith(MenuUtil.MENU_AC_MANAGER_HELP_POSTFIX)
                    || MenuUtil.CHECK_TIMEOUT.equals(currentActionName)
                    || MenuUtil.MENU_AC_EULA.contains(currentActionName)) {

                if (userRole != Roles.NO_RIGHTS && userRole != Roles.UNREGISTERED && userRole != Roles.DUMBUSER
                        && currentActionName.endsWith(MenuUtil.MENU_AC_MANAGER_HELP_POSTFIX)) {
                    LOGGER.debug("Action is used for either help or login.");
                    isActionAllowed = true;
                    invocation.getInvocationContext().put(ACTIVE_MENU_ITEM, NO_ACTIVE_MENU_ITEM);
                } else if (currentActionName.endsWith(MenuUtil.MENU_AC_HELP_POSTFIX)
                        || MenuUtil.MENU_AC_LOGIN.contains(currentActionName)) {
                    LOGGER.debug("Action is used for either help or login.");
                    isActionAllowed = true;
                    invocation.getInvocationContext().put(ACTIVE_MENU_ITEM, NO_ACTIVE_MENU_ITEM);
                } else if (MenuUtil.CHECK_TIMEOUT.equals(currentActionName)) {
                    LOGGER.debug("Checking timeout");
                    isActionAllowed = true;
                    invocation.getInvocationContext().put(ACTIVE_MENU_ITEM, NO_ACTIVE_MENU_ITEM);
                } else if (MenuUtil.MENU_AC_EULA.contains(currentActionName)) {
                    LOGGER.debug("Action is used for EULA status change.");
                    isActionAllowed = true;
                    invocation.getInvocationContext().put(ACTIVE_MENU_ITEM, NO_ACTIVE_MENU_ITEM);
                } else {
                    LOGGER.warn("Denying action '" + currentActionName
                            + "' because it was not found in permitted actions list");
                    invocation.getInvocationContext().put(ACTIVE_MENU_ITEM, NO_ACTIVE_MENU_ITEM);
                    addActionError(invocation, getText("message.restricted_area"));
                    return UNAUTHORIZED;
                }
            } else {
                LOGGER.warn("Denying action '" + currentActionName
                        + "' because it was not found in permitted actions list");
                invocation.getInvocationContext().put(ACTIVE_MENU_ITEM, NO_ACTIVE_MENU_ITEM);
                addActionError(invocation, getText("message.restricted_area"));
                return UNAUTHORIZED;
            }
        }
        // -------------------------------------------------------------------------------------------
        return invocation.invoke();
    }

    private HashMap<Integer, List<MenuActions>> setUpRoles(ActionInvocation invocation, Map<String, Object> session,
            Integer userRole) {
        HashMap<Integer, List<MenuActions>> roleActions = new HashMap<Integer, List<MenuActions>>();


        if (userRole == Roles.PORTAL_ADMIN) {
            // --- PORTAL ADMIN
            List<MenuActions> portalAdmin = new ArrayList<MenuActions>();
            portalAdmin.add(new MenuActions(MenuUtil.MENU_PORTALS, MenuUtil.MENU_AC_PORTALS));
            portalAdmin.add(maXslManage);
            portalAdmin.add(maChangeAdminPassword);
            roleActions.put(Roles.PORTAL_ADMIN, portalAdmin);

        } else {
            // all the rest
            Portal portal = (Portal) session.get(Const.SESSION_PORTAL);
            if (portal == null) {
                LOGGER.error("NO PORTAL");
                addActionError(invocation, getText("text.no_portal"));
            }

            boolean universalPortal = portal.getMispType() == Const.MISP_TYPE_ORGANISATION
                    || portal.getMispType() == Const.MISP_TYPE_UNIVERSAL;

            Org activeOrg = (Org) session.get(Const.SESSION_ACTIVE_ORG);
            
            if (activeOrg == null)
                LOGGER.debug("NO ORGANIZATION");
            else
                invocation.getInvocationContext().put("activeOrgName",
                        activeOrg.getActiveName(getLocale().getLanguage()));


            // --- DEVELOPER
            if (userRole == Roles.DEVELOPER) {

                List<MenuActions> developer = new ArrayList<MenuActions>();
                developer.add(maServicesManage);
                developer.add(maOpenAPIServicesManage);
                developer.add(maXslManage);
                developer.add(maThemes);
                developer.add(maServiceDigitalSigning);
                roleActions.put(Roles.DEVELOPER, developer);

                // --- PERMISSION MANAGER
            } else if (userRole == Roles.PERMISSION_MANAGER) {

                List<MenuActions> permissionMgr = new ArrayList<MenuActions>();
                permissionMgr.add(maGroupManage);
                permissionMgr.add(maUsersManage);
                permissionMgr.add(maMgrQueryLogs);
                permissionMgr.add(maServiceDigitalSigning);
                roleActions.put(Roles.PERMISSION_MANAGER, permissionMgr);

                // --- DUMBUSER
            } else if (userRole == Roles.DUMBUSER) {

                List<MenuActions> dumbuser = new ArrayList<MenuActions>();

                dumbuser.add(maUseServices);
                dumbuser.add(maUserQueryLogs);
                dumbuser.add(maUserSettings);
                dumbuser.add(maServiceDigitalSigning);

                if (universalPortal && activeOrg.getSupOrgId() == null) {
                        dumbuser = new ArrayList<MenuActions>();
                }
                roleActions.put(Roles.DUMBUSER, dumbuser);

                // --- PORTAL MANAGER
            } else if (userRole == Roles.PORTAL_MANAGER) {

                List<MenuActions> portalMgr = new ArrayList<MenuActions>();
                portalMgr.add(maServicesManage);
                portalMgr.add(maOpenAPIServicesManage);
                portalMgr.add(maXslManage);
                portalMgr.add(maClassifiers);
                portalMgr.add(maThemes);
                portalMgr.add(maMgrQueryLogs);
                portalMgr.add(maUsersManage);
                portalMgr.add(maNews);
                portalMgr.add(maServiceDigitalSigning);
                if (universalPortal) {
                    if (activeOrg.getSupOrgId() != null)
                        portalMgr.add(maGroupManage);
                    else
                        portalMgr.add(maGroupManageWithoutMembers);
                    portalMgr.add(maMgUnits);
                } else {
                    portalMgr.add(maGroupManage);
                    // portalMgr.add(maUsersManage);
                }
                if (portal.getLogQuery() != null) {
                    portalMgr.add(maLogs);
                }
                portalMgr.add(maExportImport);
                roleActions.put(Roles.PORTAL_MANAGER, portalMgr);

                // --- REPRESENTATIVE
            } else if (userRole == Roles.REPRESENTATIVE) {
                List<MenuActions> representative = new ArrayList<MenuActions>();
                representative.add(maRegUser);

                boolean useManagers = portal.isUnivUseManger();

                if (session.get(Const.SESSION_USE_MANAGER) instanceof Boolean) {
                    useManagers = ((Boolean) session.get(Const.SESSION_USE_MANAGER)).booleanValue();
                }

                if (universalPortal && useManagers) {
                    representative.add(maRegManager);
                }
                roleActions.put(userRole, representative);

                // --- REPRESENTATIVE WITH LIMITATIONS
            } else if (userRole == Roles.LIMITED_REPRESENTATIVE) {

                List<MenuActions> limited = new ArrayList<MenuActions>();
                limited.add(maRegUkManager);
                roleActions.put(userRole, limited);

                // --- UNREGISTERED USER
            } else if (userRole == Roles.UNREGISTERED) {

                List<MenuActions> unregistered = new ArrayList<MenuActions>();
                unregistered.add(maRegUnit); // TODO change this to a less rights later,
                                            // only allow showing list of units
                roleActions.put(Roles.UNREGISTERED, unregistered);
            }
        }
        return roleActions;
    }

}
