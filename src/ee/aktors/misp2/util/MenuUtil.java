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

package ee.aktors.misp2.util;

import java.util.Arrays;
import java.util.List;

/**
 *
 * @author arnis.rips
 */
public final class MenuUtil {
    // menu items
    private MenuUtil() {
    }
    
    public static final int MENU_MG_SERVICES = 1;
    public static final int MENU_MG_USERS = 2;
    public static final int MENU_MG_GROUPS = 3;
    public static final int MENU_MG_CLASSIFIERS = 4;
    public static final int MENU_MG_XSL = 5;
    public static final int MENU_PORTALS = 6;
    public static final int MENU_THEMES = 7;
    public static final int MENU_LOGS = 8;
    public static final int MENU_MG_UNITS = 9;
    public static final int MENU_SERVICES = 10;
    public static final int MENU_USER_SETTINGS = 11;
    public static final int MENU_QUERY_LOGS = 12;
    public static final int MENU_REG_UNIT = 13;
    public static final int MENU_REG_MANAGER = 14;
    public static final int MENU_REG_USER = 15;
    public static final int MENU_CHANGE_ADMIN_PASSWORD = 16;
    public static final int MENU_NEWS = 17;
    public static final int MENU_EXPORT_IMPORT = 18;
    public static final int MENU_MG_OPENAPI_SERVICES = 19;
    public static final int MENU_SERVICE_AC_DIGITAL_SIGNING = 20;
    public static final String MENU_AC_HELP_POSTFIX = "_help";
    public static final String MENU_AC_MANAGER_HELP_POSTFIX = "_help_manager";
    public static final String CHECK_TIMEOUT = "checkTimeout";
    public static final List<String> MENU_AC_LOGIN = Arrays.asList(new String[]{
            "login",
            "enter",
            "portalChange",
            "formLogin",
            "IDCardLogin",
            "version"
            //"certCreate", "certGenerate", "certLoad"
            });
    public static final List<String> MENU_AC_EULA = Arrays.asList(new String[]{
            "acceptEula",
            "rejectEula"
            });
    public static final List<String> MENU_AC_MG_SERVICES = Arrays.asList(new String[]{
                "listProducers",
                "listAllProducers",
                "producerEdit",
                "producerSave",
                "producerDelete",
                "queriesExport",
                "updateAndGenerateForms",
                "queriesExportReceiveFile",
                "queriesImport",
                "runQuery",
                "xforms-query",
                "restMediator",
                "listQueries",
                "removeMissingQueries",
                "editXforms",
                "login_manager",
                "login_developer",
                "loadPdf",
                "addActiveProducer",
                "soapRefreshProducers",
                "saveXforms",
                "getAllowedMethods",
                "updateServicesList",
                "updateServicesXFroms",
                "complexProducerEdit",
                "complexProducerSave",
                "complexProducerDelete",
                "listComplexQueries",
                "addComplexQuery",
                "changeComplexDesc",
                "saveComplexData",
                "deleteComplex",
                "saveQueryLog",
                "saveQueryLogResponse"
            });
    public static final List<String> MENU_AC_MG_OPENAPI_SERVICES = Arrays.asList(new String[]{
        "openApiListProducers",
        "listProducers",
        "listAllProducers",
        "updateAndGenerateForms",
        "producerEdit",
        "producerSave",
        "producerDelete",
        "queriesExport",
        "queriesExportReceiveFile",
        "queriesImport",
        "runQuery",
        "xforms-query",
        "restMediator",
        "listQueries",
        "removeMissingQueries",
        "editXforms",
        "bpelPackagesList",
        "bpelQueriesList",
        "login_manager",
        "login_developer",
        "loadPdf",
        "addActiveProducer",
        "soapRefreshProducers",
        "saveXforms",
        "getAllowedMethods",
        "updateServicesList",
        "updateServicesXFroms",
        "bpelPackageUpload",
        "bpelPackagesUpload",
        "bpelPackagesDelete",
        "bpelQueriesGetXforms",
        "complexProducerEdit",
        "complexProducerSave",
        "complexProducerDelete",
        "listComplexQueries",
        "addComplexQuery",
        "changeComplexDesc",
        "saveComplexData",
        "deleteComplex",
        "saveQueryLog",
        "saveQueryLogResponse"
    });

    public static final List<String> MENU_AC_MG_UNITS = Arrays.asList(new String[]{
                "unitsFilter",
                "showUnit",
                "unitSubmit",
                "registerUnit",
                "addUnit",
                "unitDelete",
                "userSubmit",
                // --
                "managerRegisterUnitFilter",
                "managerRegisterUnitUKFilter",
                "addUnitManager",
                "removeUnitManager"
            });
    public static final List<String> MENU_AC_MG_USERS = Arrays.asList(new String[]{
                "manageUsers",
                "usersFilter",
                "showUser",
                "userDelete",
                "userSubmit",
                "addUser",
                "userGenCode",
                "userDeleteConfirmed"
            });
    public static final List<String> MENU_AC_MG_GROUPS = Arrays.asList(new String[]{
                "groupManage",
                "login_perm_manager",
                "groupEditData",
                "groupEditRights",
                "groupEditMembers",
                "groupSaveData",
                "groupDelete",
                "groupSaveRights",
                "groupSaveMembers"
            });
    public static final List<String> MENU_AC_MG_GROUPS_WITHOUT_MG_MEMBERS = Arrays.asList(new String[]{
            "groupManage",
            "login_perm_manager",
            "groupEditData",
            "groupEditRights",
            "groupSaveData",
            "groupDelete",
            "groupSaveRights"
            });
    public static final List<String> MENU_AC_MG_CLASSIFIERS = Arrays.asList(new String[]{
                "listClassifiers",
                "listClassifierQuerys",
                "listQueryClassifiers",
                "removeClassifier",
                "updateClassifier"
            });
    public static final List<String> MENU_AC_MG_XSL = Arrays.asList(new String[]{
                "stylesFilter",
                "styleSubmit",
                "showStyle",
                "ajaxReadUrl",
                "ajaxProdQuery",
                "addStyle",
                "styleDelete", });
    public static final List<String> MENU_AC_PORTALS = Arrays.asList(new String[]{
                "listPortals",
                "savePortal",
                "showPortal",
                "removePortal",
                "addPortal",
                "addManager",
                "saveManager",
                "saveUserAdmin",
                "userAddAdmin",
                "usersFilterAdmin",
                "managerDelete",
                "userDeleteAdmin",
                "userGenCodeAdmin",
                "getXroadInstances"
            });
    public static final List<String> MENU_AC_TOPICS = Arrays.asList(new String[]{
                "topicsFilter",
                "showTopic",
                "topicSubmit",
                "addTopic",
                "topicDelete"
            });
    public static final List<String> MENU_AC_LOGS = Arrays.asList(new String[]{
                "t3SecFilterInit",
                "t3SecFilter"
            });
    public static final List<String> MENU_AC_SERVICES = Arrays.asList(new String[]{
                "login_user",
                "xforms-query",
                "searchQueries",
                "loadPdf",
                "runQuery",
                "restMediator",
                "saveQueryLog",
                "saveQueryLogResponse"
            });
    public static final List<String> MENU_AC_USER_SETTINGS = Arrays.asList(new String[]{
                "changeUserAccount",
                "saveUserAccount"
            });
    public static final List<String> MENU_AC_QUERY_LOGS = Arrays.asList(new String[]{
                "userQueryLogs",
                "queryLogFilter"
            });
    public static final List<String> MENU_AC_MGR_QUERY_LOGS = Arrays.asList(new String[]{
                "managerQueryLogs",
                "managerQueryLogFilter"
                
            });
    public static final List<String> MENU_AC_REG_UNIT = Arrays.asList(new String[]{
                "getUnitList",
                "login_user",
//                "login_representative",
//                "login_limited_representative",
                "login_unregistered",
                "registerUnit",
                "registerUnknownUnit"
            });
    public static final List<String> MENU_AC_REG_MANAGER = Arrays.asList(new String[]{
                "registerManager",
                "login_representative",
                "userSubmit",
                // --
                "managerRegisterUnitFilter",
                "addUnitManager",
                "removeUnitManager", });
    public static final List<String> MENU_AC_REG_UK_MANAGER = Arrays.asList(new String[]{
                "registerUkManager",
                "userSubmit",
                "login_limited_representative",
                // --
                "managerRegisterUnitUKFilter",
                "addUnitManager",
                "removeUnitManager",
                // --
                "addManagerCandidate",
                "removeManagerCandidate"
            });
    public static final List<String> MENU_AC_REG_USER = Arrays.asList(new String[]{
                "registerUser",
                "userSubmit",
                "login_representative",
                // --
                "registerUnitSimple",
                "userRegisterUnitFilter",
                "addUnitUser",
                "removeUnitUser"
            });
    public static final List<String> MENU_AC_CHANGE_ADMIN_PASSWORD = Arrays.asList(new String[]{
            "changeAdminPassword",
            "saveAdminPassword"
            });
    public static final List<String> MENU_AC_NEWS = Arrays.asList(new String[]{
            "editNews",
            "deleteNews",
            "saveNews"
        });
    public static final List<String> MENU_AC_EXPORT_IMPORT = Arrays.asList(new String[] {
            "exportImport",
            "exportFile",
            "importFile"
            });

    public static final List<String> SERVICE_AC_DIGITAL_SIGNING = Arrays.asList(new String[] {
            "testDigitalSigning",
            "getTranslations",
            "getDefaultSigningMethod",
            "uploadDataToSign",
            "downloadContainer",

            "generateHash",
            "createContainer",

            "sendSignatureRequest",
            "signMobileContainer",
    });
}
