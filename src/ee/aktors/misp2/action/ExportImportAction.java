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

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.action.exception.BusinessException;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgName;
import ee.aktors.misp2.service.ExportImportService;
import ee.aktors.misp2.service.OrgService;
import ee.aktors.misp2.util.Const;

/**
 */
public class ExportImportAction extends SessionPreparedBaseAction implements StrutsStatics {
    private static final long serialVersionUID = 1L;

    private ExportImportService exportImportService;
    private OrgService orgService;

    private boolean includeSubOrgsAndGroups;
    private boolean includeGroupPersons;
    private boolean includeGroupQueries;
    private boolean includeTopics;
    private boolean includeQueries;

    private boolean universalPortal;
    private LinkedHashMap<Org, String> subOrgs;
    private Integer chosenSubOrgId;
    private InputStream inputStream;
    private File importFile;
    private String exportFileName;
    private static final Logger LOG = LogManager.getLogger(ExportImportAction.class);

    /**
     * @param exportImportService exportImportService to inject
     * @param orgService orgService to inject
     */
    public ExportImportAction(ExportImportService exportImportService, OrgService orgService) {
        this.exportImportService = exportImportService;
        this.orgService = orgService;
    }

    @Override
    public void prepare() throws Exception {
        super.prepare();
        universalPortal = portal.getMispType() == Const.MISP_TYPE_UNIVERSAL
                || portal.getMispType() == Const.MISP_TYPE_ORGANISATION;
        subOrgs = prepareSubOrgs(universalPortal);
    }

    @Override
    public void validate() {
        for (List<String> s : getFieldErrors().values()) {
            setActionErrors(s);
        }
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String exportImport() {
        includeSubOrgsAndGroups = true;
        includeGroupPersons = true;
        includeGroupQueries = true;
        includeTopics = true;
        includeQueries = true;

        chosenSubOrgId = 0;

        return Action.SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String exportFile() {
        try {
            Org chosenSubOrg =
                chosenSubOrgId != null && chosenSubOrgId != 0 ? orgService.findObject(Org.class, chosenSubOrgId) : null;
            
            File exportFile = exportImportService.getExportFile(portal, includeSubOrgsAndGroups, includeGroupPersons,
                    includeGroupQueries, includeTopics, includeQueries, chosenSubOrg);
            inputStream = new FileInputStream(exportFile);
            // set exportFileName for Content-Disposition HTTP header specified in struts.xml
            exportFileName = exportFile.getName()
                    .replace("\"", ""); // remove quotes if necessary, so that file name can be surrounded with quotes
            
            LOG.debug("Created export file " + exportFile.getName());
        } catch (Exception e) {
            LOG.debug("Creating export file failed", e);
            addActionError(getText("exportImport.export.exception"));
            return Action.ERROR;
        }

        return Action.SUCCESS;
    }

    /**
     * @return ERROR if file import fails, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String importFile() {
        try {
            exportImportService.importFile(importFile, portal, includeSubOrgsAndGroups, includeGroupPersons,
                    includeGroupQueries, includeTopics, includeQueries);
        } catch (BusinessException e) {
            addActionError(getText(e.getMessage()));
            return Action.ERROR;
        } catch (Exception e) {
            LOG.debug("Importing data from file failed", e);
            addActionError(getText("exportImport.import.exception"));
            return Action.ERROR;
        }

        addActionMessage(getText("text.success.save"));
        return Action.SUCCESS;
    }

    private LinkedHashMap<Org, String> prepareSubOrgs(boolean universalPortalIn) {
        LinkedHashMap<Org, String> subOrgsPrivate = new LinkedHashMap<Org, String>();
        List<Org> subOrgsList = (universalPortalIn ? orgService.findSubOrgs(portal.getOrgId()) : new ArrayList<Org>());
        String lang = ActionContext.getContext().getLocale().getLanguage();
        for (Org subOrg : subOrgsList) {
            String label = subOrg.getCode();
            OrgName orgName = orgService.findOrgName(subOrg, lang);
            if (orgName != null) {
                label = label + "/" + orgName.getDescription();
            }
            subOrgsPrivate.put(subOrg, label);
        }
        return subOrgsPrivate;
    }
    

    /**
     * @return the includeSubOrgsAndGroups
     */
    public boolean isIncludeSubOrgsAndGroups() {
        return includeSubOrgsAndGroups;
    }

    /**
     * @param includeSubOrgsAndGroupsNew the includeSubOrgsAndGroups to set
     */
    public void setIncludeSubOrgsAndGroups(boolean includeSubOrgsAndGroupsNew) {
        this.includeSubOrgsAndGroups = includeSubOrgsAndGroupsNew;
    }

    /**
     * @return the includeGroupPersons
     */
    public boolean isIncludeGroupPersons() {
        return includeGroupPersons;
    }

    /**
     * @param includeGroupPersonsNew the includeGroupPersons to set
     */
    public void setIncludeGroupPersons(boolean includeGroupPersonsNew) {
        this.includeGroupPersons = includeGroupPersonsNew;
    }

    /**
     * @return the includeGroupQueries
     */
    public boolean isIncludeGroupQueries() {
        return includeGroupQueries;
    }

    /**
     * @param includeGroupQueriesNew the includeGroupQueries to set
     */
    public void setIncludeGroupQueries(boolean includeGroupQueriesNew) {
        this.includeGroupQueries = includeGroupQueriesNew;
    }

    /**
     * @return the includeTopics
     */
    public boolean isIncludeTopics() {
        return includeTopics;
    }

    /**
     * @param includeTopicsNew the includeTopics to set
     */
    public void setIncludeTopics(boolean includeTopicsNew) {
        this.includeTopics = includeTopicsNew;
    }

    /**
     * @return the includeQueries
     */
    public boolean isIncludeQueries() {
        return includeQueries;
    }

    /**
     * @param includeQueriesNew the includeQueries to set
     */
    public void setIncludeQueries(boolean includeQueriesNew) {
        this.includeQueries = includeQueriesNew;
    }

    /**
     * @return the chosenSubOrgId
     */
    public Integer getChosenSubOrgId() {
        return chosenSubOrgId;
    }

    /**
     * @param chosenSubOrgIdNew the chosenSubOrgId to set
     */
    public void setChosenSubOrgId(Integer chosenSubOrgIdNew) {
        this.chosenSubOrgId = chosenSubOrgIdNew;
    }

    /**
     * @return the universalPortal
     */
    public boolean isUniversalPortal() {
        return universalPortal;
    }

    /**
     * @return the subOrgs
     */
    public LinkedHashMap<Org, String> getSubOrgs() {
        return subOrgs;
    }

    /**
     * @return the inputStream
     */
    public InputStream getInputStream() {
        return inputStream;
    }

    /**
     * @param importFileNew the importFile to set
     */
    public void setImportFile(File importFileNew) {
        this.importFile = importFileNew;
    }

    /**
     * @return export file name for 
     *  Content-Disposition HTTP header value referred to in struts.xml
     */
    public String getExportFileName() {
        return exportFileName;
    }
}
