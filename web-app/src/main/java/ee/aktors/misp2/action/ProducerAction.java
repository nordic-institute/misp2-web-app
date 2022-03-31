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

package ee.aktors.misp2.action;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionContext;
import ee.aktors.misp2.exportImport.QueryImportData;
import ee.aktors.misp2.flash.FlashUtil;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Producer.ProtocolType;
import ee.aktors.misp2.model.ProducerName;
import ee.aktors.misp2.model.Xforms;
import ee.aktors.misp2.model.XroadInstance;
import ee.aktors.misp2.service.ProducerService;
import ee.aktors.misp2.service.QueryExportImportService;
import ee.aktors.misp2.service.XroadInstanceService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.LanguageUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import javax.servlet.http.HttpServletRequest;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 */
public class ProducerAction extends SessionPreparedBaseAction implements StrutsStatics {
    private static final long serialVersionUID = 1L;

    private ArrayList<String> languages = LanguageUtil.getLanguages();
    private ProducerService pService;
    private QueryExportImportService queryExportImportService;
    private List<Producer> activeProducers;
    private List<Producer> allProducers;
    private Map<Producer, List<Xforms>> activeProducersXforms;
    private Map<Producer, List<Xforms>> complexProducersXforms;
    private Producer producer;
    private List<ProducerName> producerNames;
    private String name;
    private String activeProducersGroup;
    private boolean all;
    private boolean state;
    private String[] active;
    private List<Producer> complexProducers;
    private InputStream inputStream;
    private File importFile;
    private String uuid;
    private XroadInstanceService xroadInstanceService;
    private List<XroadInstance> serviceXroadInstances;
    private String exportFileName;
    private Integer id;
    /**
     * Default: {@link ProtocolType#SOAP}
     * Determines active tab in {@link ee.aktors.misp2.interceptor.MenuInterceptor#intercept}
     */
    private ProtocolType protocol;
    private Set<String> activeInstanceCodes;
    private String activeInstanceCode;

    private static final Logger LOG = LogManager.getLogger(ProducerAction.class);

    /**
     * @param pService pService to inject
     * @param queryExportImportService queryExportImportService to inject
     * @param xroadInstanceService X-Road instance service to be injected
     */
    public ProducerAction(ProducerService pService, QueryExportImportService queryExportImportService,
                          XroadInstanceService xroadInstanceService) {
        this.pService = pService;
        this.queryExportImportService = queryExportImportService;
        this.xroadInstanceService = xroadInstanceService;
    }
    @Override
    public void prepare() throws Exception {
        super.prepare();
        setPortal(portal);
        protocol = protocol == null ? ProtocolType.SOAP : protocol;
        setActiveProducers(pService.findActiveProducers(portal, protocol));
        setAllProducers(pService.findAllProducers(portal, protocol));
        setComplexProducers(pService.findComplexProducers(portal, protocol));
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String execute() throws Exception {
        return Action.SUCCESS;
    }

    @Override
    public void validate() {
        String actionName = ActionContext.getContext().getName();
        if (actionName.equalsIgnoreCase("producerSave") && !authDeveloperMode()) {
            return;
        }
        for (List<String> s : getFieldErrors().values()) {
            setActionErrors(s);
        }
    }

    /**
     * @return SUCCESS
     * @throws Exception when parsing producer id fails
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String changeProducerState() throws Exception {
        HashSet<Integer> activeProducerIds = new HashSet<Integer>();
        for (String id : getActiveProducersGroup().split(",")) {
            if (!id.equals("")) {
                activeProducerIds.add(Integer.parseInt(id));
            }
        }
        LOG.debug("Save active producers: " + activeProducerIds);
        pService.changeProducersState(getAllProducers(), activeProducerIds);
        return Action.SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String listAllProducers() {
        setAll(true);
        // only set the parameter in case of X-Road v6 portal
        if (portal.isV6()) {
            serviceXroadInstances = xroadInstanceService.findActiveInstances(portal);
            // If there are selected instances in the flash, adjust serviceXroadInstances accordingly
            List<?> selectedXroadInstanceCodes =
                    (List<?>)FlashUtil.getFlash().get(Const.XROAD_INSTANCES_SELECTED);
            if (selectedXroadInstanceCodes != null) {
                xroadInstanceService.setSelected(serviceXroadInstances, selectedXroadInstanceCodes);
            }
            LOG.debug("selectedXroadInstanceCodes " + selectedXroadInstanceCodes);
        }

        return Action.SUCCESS;
    }

    /**
     * @return ERROR when refreshing producers fails, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String refreshProducers() {
        boolean refreshed;
        try {
            Set<String> activeXroadInstanceCodes = null;
            List<String> selectedXroadInstanceCodes = null;
            if (portal.isV6()) {
                activeXroadInstanceCodes =
                        xroadInstanceService.getActiveInstanceCodes(portal);
                selectedXroadInstanceCodes =
                        xroadInstanceService.getSelectedInstanceCodes(portal, serviceXroadInstances);
                if (selectedXroadInstanceCodes.size() == 0) {
                    addActionError(getText("producer.note_service_xroad_instances_missing"));
                    return Action.SUCCESS;
                }
            }
            try {
                refreshed = pService.listProducersFromSecurityServer(portal,
                        activeXroadInstanceCodes, selectedXroadInstanceCodes, protocol);
            } catch (Exception e) {
                LOG.error("Refreshing producers failed unexpectedly", e);
                addActionError(getText("producer.note_not_refreshed"));
                return Action.ERROR;
            }


            if (refreshed) {
                addActionMessage(getText("producer.note_refreshed"));
                @SuppressWarnings("unchecked")
                ArrayList<String> outOfSync = (ArrayList<String>) session.get("outOfSync");
                if (outOfSync != null && !outOfSync.isEmpty()) {
                    addActionMessage(getText("producer.note_out_of_sync"));
                    for (String e : outOfSync) {
                        addActionMessage(e);
                    }
                    session.remove("outOfSync");
                }
            } else {
                addActionError(getText("producer.note_not_refreshed"));
            }
            if (portal.isV6()) {
                FlashUtil.getFlash().put(Const.XROAD_INSTANCES_SELECTED, selectedXroadInstanceCodes);
            }
        } catch (DataExchangeException e) {
            LOG.warn("Refreshing producers failed with DataExchangeException", e);
            String err = "";
            String translErr = getText(e.getTranslationCode(), e.getParameters());
            if (!translErr.equals(e.getTranslationCode())) { // show only if translation exists
                err += translErr + " ";
            }
            String faultSum = e.getFaultSummary();
            if (!StringUtils.isEmpty(faultSum)) { // show only if translation exists
                err += faultSum;
            }

            if (!StringUtils.isEmpty(err)) {
                err = ". " + err;
            }

            addActionError(getText("producer.note_not_refreshed") + err);
        } catch (Exception e) {
            LOG.error("Refreshing producers failed unexpectedly", e);
            addActionError(getText("producer.note_not_refreshed"));
            return Action.ERROR;
        }

        return Action.SUCCESS;

    }

    /**
     * @return SUCCESS if is authDeveloperMode, ERROR otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String producerEdit() {

        activeInstanceCodes = xroadInstanceService.getActiveInstanceCodes(portal);

        if(getId() != null && getProtocol() == ProtocolType.REST) {
            setProducer(pService.findObject(Producer.class, getId()));
            activeInstanceCode = getProducer().getXroadInstance();
            return Action.SUCCESS;
        } else {
            activeInstanceCode = portal.getClientXroadInstance();
            return authDeveloperMode() ? Action.SUCCESS : Action.ERROR;
        }
    }

    /**
     * @return SUCCESS if saving producer succeeds, ERROR otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String producerSave() {
        if(producer == null) {
            return Action.ERROR;
        }
        if(producer.getId() != null) {
            Producer oldProducer = pService.findObject(Producer.class, producer.getId());
            oldProducer.setXroadInstance(getActiveInstanceCode());
            oldProducer.setShortName(producer.getShortName());
            oldProducer.setMemberClass(producer.getMemberClass());
            oldProducer.setSubsystemCode(producer.getSubsystemCode());
            pService.save(oldProducer);

            saveProducerNames(producer.getProducerNameList());
        } else if (authDeveloperMode()) {
            if (pService.findProducer(producer, portal) != null) {
                producer.setShortName("");
                addActionError(getText("producer.text.fail.exists"));
            } else {
                producer.setXroadInstance(activeInstanceCode);
                producer.setProtocol(protocol);
                producer.setPortal(portal);
                producer.setInUse(true);
                pService.save(producer);

                saveProducerNames();
            }
        }
        return Action.SUCCESS;
    }

    /**
     * @return ERROR if could not delete complex producer,SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String producerDelete() {
        if(getId() != null) {
            setProducer(pService.findObject(Producer.class, getId()));
        }
        if(getProducer() == null){
            return Action.ERROR;
        }

        try {
            pService.remove(getProducer());
        } catch (Exception e) {
            LOG.debug("cannot delete complex producer");
            return Action.ERROR;
        }
        return Action.SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String queriesExport() { // get producers and their queries
        activeProducersXforms = queryExportImportService.getProducersWithXforms(activeProducers);
        complexProducersXforms = queryExportImportService.getProducersWithXforms(complexProducers);
        return Action.SUCCESS;
    }

    /**
     * @return ERROR when query export failed, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String queriesExportReceiveFile() { // get chosen queries with their producers in zip file
        try {
            HttpServletRequest req = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
            String data = req.getParameter("data");

            ObjectMapper m = new ObjectMapper();
            JsonNode parentNode = m.readTree(data);
            LinkedHashMap<Producer, List<Xforms>> producersWithXforms = queryExportImportService
                    .getProducersWithXforms(parentNode.get("producers"));

            File exportFile = queryExportImportService.getExportFile(producersWithXforms);
            // set exportFileName for Content-Disposition HTTP header specified in struts.xml
            exportFileName = exportFile.getName()
                    .replace("\"", ""); // remove quotes if necessary, so that file name can be surrounded with quotes

            inputStream = new FileInputStream(exportFile);
        } catch (Exception e) {
            LOG.debug("Creating query export file failed", e);
            addActionError(getText("producer.queries.export.exception"));
            return Action.ERROR;
        }

        return Action.SUCCESS;
    }

    /**
     * @return ERROR if importing queries fails, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.GET, HTTPMethod.POST })
    public String queriesImport() { // import producers and their queries
        try {
            HttpServletRequest req = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
            if (!req.getMethod().equalsIgnoreCase("GET")) { // POST
                if (importFile != null) { // user is uploading zip file with producers and queries
                    QueryImportData importData = queryExportImportService.getImportData(importFile, portal);
                    activeProducersXforms = importData.getActiveProducersWithXforms();
                    complexProducersXforms = importData.getComplexProducersWithXforms();
                    uuid = UUID.randomUUID().toString();
                    req.getSession().setAttribute(uuid, importData); // We should also send uuid to jsp, but struts does
                    // it automatically.
                } else if (req.getParameter("queriesImport") != null) { // user is importing queries and their producers
                    uuid = req.getParameter("uuid");
                    String data = req.getParameter("data");

                    QueryImportData importData = (QueryImportData) req.getSession().getAttribute(uuid);
                    req.getSession().removeAttribute(uuid); // do not need it anymore
                    activeProducersXforms = importData.getActiveProducersWithXforms();
                    complexProducersXforms = importData.getComplexProducersWithXforms();

                    ObjectMapper m = new ObjectMapper();
                    JsonNode parentNode = m.readTree(data);
                    LinkedHashMap<Integer, List<Integer>> producerIdsWithXformIds = queryExportImportService
                            .getProducerIdsWithXformIds(parentNode.get("producers"));

                    queryExportImportService.importData(importData, producerIdsWithXformIds, portal, org);
                    FileUtils.deleteDirectory(importData.getTempDir());

                    return "redirect";
                }
            }
        } catch (Exception e) {
            LOG.debug("Importing queries failed", e);
            addActionError(getText("producer.queries.import.exception"));
            return Action.ERROR;
        }

        return Action.SUCCESS;
    }

    private void saveProducerNames() {
        for (int i = 0; i < languages.size(); i++) {
            saveProducerName(languages.get(i), producerNames.get(i));
        }
    }

    private void saveProducerNames(List<ProducerName> producerNames) {
        for (ProducerName pName : producerNames) {
            saveProducerName(pName.getLang(), pName);
        }
    }

    private void saveProducerName(String language, ProducerName producerName) {
        producerName.setLang(language);
        String description = producerName.getDescription();

        ProducerName existingProducerName = pService.findProducerName(producer, language);
        producerName = (existingProducerName == null ? producerName : existingProducerName);
        // Use existing producerName entity if it exists

        producerName.setDescription(description);
        producerName.setLang(language);
        producerName.setProducer(producer);
        pService.save(producerName);
    }

    private boolean authDeveloperMode() {
        if (portal.getDebug() != 1) {
            addActionError(getText("message.restricted_area"));
            return false;
        } else {
            return true;
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
     * @return the activeProducers
     */
    public List<Producer> getActiveProducers() {
        return activeProducers;
    }
    /**
     * @param activeProducersNew the activeProducers to set
     */
    public void setActiveProducers(List<Producer> activeProducersNew) {
        this.activeProducers = activeProducersNew;
    }
    /**
     * @return the allProducers
     */
    public List<Producer> getAllProducers() {
        return allProducers;
    }
    /**
     * @param allProducersNew the allProducers to set
     */
    public void setAllProducers(List<Producer> allProducersNew) {
        this.allProducers = allProducersNew;
    }
    /**
     * @return the activeProducersXforms
     */
    public Map<Producer, List<Xforms>> getActiveProducersXforms() {
        return activeProducersXforms;
    }
    /**
     * @param activeProducersXformsNew the activeProducersXforms to set
     */
    public void setActiveProducersXforms(Map<Producer, List<Xforms>> activeProducersXformsNew) {
        this.activeProducersXforms = activeProducersXformsNew;
    }
    /**
     * @return the complexProducersXforms
     */
    public Map<Producer, List<Xforms>> getComplexProducersXforms() {
        return complexProducersXforms;
    }
    /**
     * @param complexProducersXformsNew the complexProducersXforms to set
     */
    public void setComplexProducersXforms(Map<Producer, List<Xforms>> complexProducersXformsNew) {
        this.complexProducersXforms = complexProducersXformsNew;
    }
    /**
     * @return the producer
     */
    public Producer getProducer() {
        return producer;
    }
    /**
     * @param producerNew the producer to set
     */
    public void setProducer(Producer producerNew) {
        this.producer = producerNew;
    }
    /**
     * @return the producerNames
     */
    public List<ProducerName> getProducerNames() {
        return producerNames;
    }
    /**
     * @param producerNamesNew the producerNames to set
     */
    public void setProducerNames(List<ProducerName> producerNamesNew) {
        this.producerNames = producerNamesNew;
    }
    /**
     * @return the name
     */
    public String getName() {
        return name;
    }
    /**
     * @param nameNew the name to set
     */
    public void setName(String nameNew) {
        this.name = nameNew;
    }
    /**
     * @return the activeProducersGroup
     */
    public String getActiveProducersGroup() {
        return activeProducersGroup;
    }
    /**
     * @param activeProducersGroupNew the activeProducersGroup to set
     */
    public void setActiveProducersGroup(String activeProducersGroupNew) {
        this.activeProducersGroup = activeProducersGroupNew;
    }
    /**
     * @return the all
     */
    public boolean isAll() {
        return all;
    }
    /**
     * @param allNew the all to set
     */
    public void setAll(boolean allNew) {
        this.all = allNew;
    }
    /**
     * @return the state
     */
    public boolean isState() {
        return state;
    }
    /**
     * @param stateNew the state to set
     */
    public void setState(boolean stateNew) {
        this.state = stateNew;
    }
    /**
     * @return the active
     */
    public String[] getActive() {
        return active;
    }
    /**
     * @param activeNew the active to set
     */
    public void setActive(String[] activeNew) {
        this.active = activeNew;
    }
    /**
     * @return the complexProducers
     */
    public List<Producer> getComplexProducers() {
        return complexProducers;
    }
    /**
     * @param complexProducersNew the complexProducers to set
     */
    public void setComplexProducers(List<Producer> complexProducersNew) {
        this.complexProducers = complexProducersNew;
    }
    /**
     * @return the importFile
     */
    public File getImportFile() {
        return importFile;
    }
    /**
     * @param importFileNew the importFile to set
     */
    public void setImportFile(File importFileNew) {
        this.importFile = importFileNew;
    }
    /**
     * @return the inputStream
     */
    public InputStream getInputStream() {
        return inputStream;
    }
    /**
     * @return the uuid
     */
    public String getUuid() {
        return uuid;
    }

    /**
     * @return the portal
     */
    public Portal getPortal() {
        return portal;
    }
    /**
     * @param portal portal to set
     */
    public void setPortal(Portal portal) {
        this.portal = portal;
    }

    /**
     * @return the session
     */
    public Map<String, Object> getSession() {
        return session;
    }

    /**
     * @return X-Road v6 instances for portal services
     */
    public List<XroadInstance> getServiceXroadInstances() {
        return serviceXroadInstances;
    }

    /**
     * @param newServiceXroadInstances X-Road v6 instances for portal services
     */
    public void setServiceXroadInstances(List<XroadInstance> newServiceXroadInstances) {
        this.serviceXroadInstances = newServiceXroadInstances;
    }

    /**
     * @return export file name for 
     *  Content-Disposition HTTP header value referred to in struts.xml
     */
    public String getExportFileName() {
        return exportFileName;
    }

    /**
     * @return protcol type
     */
    public ProtocolType getProtocol() {
        return protocol;
    }

    /**
     * @param protocol protocol type
     */
    public void setProtocol(ProtocolType protocol) {
        this.protocol = protocol;
    }

    /**
     * @return possible instance codes for portal
     */
    public Set<String> getActiveInstanceCodes() {
        return activeInstanceCodes;
    }

    /**
     * @param activeInstanceCodes active instance codes to set
     */
    public void setActiveInstanceCodes(Set<String> activeInstanceCodes) {
        this.activeInstanceCodes = activeInstanceCodes;
    }

    /**
     * @return selected instance code
     */
    public String getActiveInstanceCode() {
        return activeInstanceCode;
    }

    /**
     * @param activeInstanceCode instance code to select/set
     */
    public void setActiveInstanceCode(String activeInstanceCode) {
        this.activeInstanceCode = activeInstanceCode;
    }

    /**
     *
     * @return get id of producer
     */
    public Integer getId() {
        return id;
    }

    /**
     * @param id to set for producer
     */
    public void setId(Integer id) {
        this.id = id;
    }
}
