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

package ee.aktors.misp2.service;

import ee.aktors.misp2.model.Producer.ProtocolType;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map.Entry;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.ServletActionContext;
import org.springframework.transaction.annotation.Transactional;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.SAXException;

import com.fasterxml.jackson.databind.JsonNode;
import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.action.exception.MispException;
import ee.aktors.misp2.exportImport.QueryImportData;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgQuery;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.ProducerName;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.model.QueryName;
import ee.aktors.misp2.model.Xforms;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Const.QUERY_TYPE;
import ee.aktors.misp2.util.FileUtil;
import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.XMLUtilException;
import ee.aktors.misp2.util.ZipUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * @author karol.kartau
 */
@Transactional
public class QueryExportImportService extends BaseService {

    private static Logger logger = LogManager.getLogger(QueryExportImportService.class);

    private QueryService queryService;
    private ProducerService producerService;
    private OrgService orgService;

    /**
     * @param producers producer entity list; Xforms entities are looked up for each one
     * @return Producer entities with associated Xforms entities
     */
    public LinkedHashMap<Producer, List<Xforms>> getProducersWithXforms(List<Producer> producers) {
        LinkedHashMap<Producer, List<Xforms>> producersWithXforms = new LinkedHashMap<Producer, List<Xforms>>();
        for (Producer producer : producers) {
            List<Xforms> xForms = queryService.findXFormsByProducer(producer);
            producersWithXforms.put(producer, xForms);
        }
        return producersWithXforms;
    }

    /**
     * @param producersNode JSON node from export XML file referring to list of imported or exported producers
     * @return Producer entities with associated Xforms entities extracted from input node
     * @throws MispException on data structure assembling failure
     */
    public LinkedHashMap<Producer, List<Xforms>> getProducersWithXforms(JsonNode producersNode) throws MispException {
        LinkedHashMap<Producer, List<Xforms>> producersWithXforms = new LinkedHashMap<Producer, List<Xforms>>();

        Iterator<Entry<String, JsonNode>> producersIt = producersNode.fields();
        while (producersIt.hasNext()) {
            Entry<String, JsonNode> producerEntry = producersIt.next();
            Producer producer = producerService.findObject(Producer.class, Integer.parseInt(producerEntry.getKey()));

            List<Xforms> xforms = new ArrayList<Xforms>();
            producersWithXforms.put(producer, xforms);
            JsonNode xFormsNode = producerEntry.getValue();
            Iterator<JsonNode> xFormsIt = xFormsNode.elements();
            while (xFormsIt.hasNext()) {
                JsonNode xFormNode = xFormsIt.next();
                Xforms xForm = queryService.findObject(Xforms.class, Integer.parseInt(xFormNode.textValue()));
                if (xForm.getQuery().getProducer() != producer)
                    throw new MispException(
                            "xForm with id " + xForm.getId() + " does not have a producer with id " + producer.getId());
                xforms.add(xForm);
            }
        }

        return producersWithXforms;
    }

    /**
     * Create export file containing all the necessary information about given portal
     * @param producersWithXforms data container consisting of producers and corresponding XForms entities
     * @return reference to created export file
     * @throws XMLUtilException on XML processing failure
     * @throws IOException on IO failure
     * @throws SAXException on parse failure
     * @throws MispException on internal error (this exception in unexpected)
     */
    public File getExportFile(LinkedHashMap<Producer, List<Xforms>> producersWithXforms)
            throws XMLUtilException, IOException, SAXException, MispException {
        File tempDir = FileUtil.getTempDir();

        Document doc = XMLUtil.getEmptyDocument();
        String ns = "http://www.aktors.ee/support/xroad/xsd/xForms_export.xsd"; // namespace

        Element producersElement = (Element) doc.appendChild(doc.createElementNS(ns, "producers"));
        Portal portal = null;
        for (Entry<Producer, List<Xforms>> entry : producersWithXforms.entrySet()) {
            Producer producer = entry.getKey();
            if (portal == null && producer != null && producer.getPortal() != null) {
                portal = producer.getPortal();
            }
            List<Xforms> xforms = entry.getValue();
            
            Element producerElement = (Element) producersElement.appendChild(doc.createElementNS(ns, "producer"));
            
            String xroadInstance = producer.getXroadInstance();
            if (!StringUtils.isEmpty(xroadInstance)) {
                producerElement.appendChild(doc.createElementNS(ns, "xroadInstance"))
                        .appendChild(doc.createTextNode(xroadInstance));
            }

            ProtocolType protocol = producer.getProtocol();
            if (protocol != null) {
                producerElement.appendChild(doc.createElementNS(ns, "protocol"))
                    .appendChild(doc.createTextNode(protocol.toString()));
            }
            
            String memberClass = producer.getMemberClass();
            if (!StringUtils.isEmpty(memberClass)) {
                producerElement.appendChild(doc.createElementNS(ns, "memberClass"))
                        .appendChild(doc.createTextNode(memberClass));
            }
            
            producerElement.appendChild(doc.createElementNS(ns, "shortName"))
                    .appendChild(doc.createTextNode(producer.getShortName()));

            String subsystemCode = producer.getSubsystemCode();
            if (!StringUtils.isEmpty(subsystemCode)) {
                producerElement.appendChild(doc.createElementNS(ns, "subsystemCode"))
                        .appendChild(doc.createTextNode(subsystemCode));
            }

            boolean isComplex = (producer.getIsComplex() != null ? producer.getIsComplex() : false);
            producerElement.appendChild(doc.createElementNS(ns, "isComplex"))
                    .appendChild(doc.createTextNode("" + isComplex));
            producerElement.appendChild(getProducerNamesElement(doc, ns, producer.getProducerNameList()));

            Element queriesElement = (Element) producerElement.appendChild(doc.createElementNS(ns, "queries"));
            for (Xforms xForm : xforms) {
                File xFormFile = getXFormFile(tempDir, producer, xForm, false);
                xFormFile.getParentFile().mkdirs();
                FileUtils.writeStringToFile(xFormFile, (xForm.getForm() != null ? xForm.getForm() : ""), "UTF-8");

                Element queryElement = (Element) queriesElement.appendChild(doc.createElementNS(ns, "query"));
                queryElement.appendChild(doc.createElementNS(ns, "shortName"))
                        .appendChild(doc.createTextNode(xForm.getQuery().getName()));
                queryElement.appendChild(doc.createElementNS(ns, "URL"))
                        .appendChild(doc.createTextNode(xForm.getUrl()));
                if (xForm.getQuery().getOpenapiServiceCode() != null) {
                    queryElement.appendChild(doc.createElementNS(ns, "openapiServiceCode"))
                        .appendChild(doc.createTextNode(xForm.getQuery().getOpenapiServiceCode()));
                }
                queryElement.appendChild(getQueryNamesElement(doc, ns, xForm.getQuery().getQueryNameList()));

            }
        }

        File xsdFile = new File(
                ServletActionContext.getServletContext().getRealPath("/") + "/resources/xsd/xforms_export.xsd");
        XMLUtil.validateDocumentIgnoringMissingAttributes(doc, new FileInputStream(xsdFile));

        FileUtils.writeStringToFile(new File(tempDir, "xforms_export.xml"), XMLUtil.convertDocumentToXML(doc), "UTF-8");

        ArrayList<File> inputFiles = new ArrayList<File>(Arrays.asList(tempDir.listFiles()));
        File exportFile = new File(FileUtil.getTempDir(),
                FileUtil.getExportFileName("export-services", portal, "zip"));
        ZipUtil.zip(inputFiles, exportFile);
        FileUtils.deleteDirectory(tempDir);

        return exportFile;
    }

    /**
     * Parse import data from XML file to QueryImportData data structure
     * @param importFile import data file
     * @param portal Portal entity for import
     * @return parsed import data
     * @throws IOException on IO failure
     * @throws XMLUtilException on XML handling failure
     * @throws SAXException on SAX parsing failure
     * @throws MispException on imported data logical inconsistencies
     */
    public QueryImportData getImportData(File importFile, Portal portal)
            throws IOException, XMLUtilException, SAXException, MispException {
        File tempDir = FileUtil.getTempDir();
        ZipUtil.unzip(importFile, tempDir);
        File xmlFile = new File(tempDir, "xforms_export.xml");
        Document doc = XMLUtil.convertXMLToDocument(FileUtils.readFileToString(xmlFile, "UTF-8"));

        File xsdFile = new File(
                ServletActionContext.getServletContext().getRealPath("/") + "/resources/xsd/xforms_export.xsd");
        XMLUtil.validateDocumentIgnoringMissingAttributes(doc, new FileInputStream(xsdFile));

        LinkedHashMap<Producer, List<Xforms>> activeProducersXforms = new LinkedHashMap<Producer, List<Xforms>>();
        LinkedHashMap<Producer, List<Xforms>> complexProducersXforms = new LinkedHashMap<Producer, List<Xforms>>();

        int idCounter = -1; // Used for giving id-s to elements, which do not exist in base, so they may be identified.
                           // Is negative and decreases in value.
        // Its negative in order to make difference between elements which are saved to database and which are not.

        Element producersElement = doc.getDocumentElement();
        ArrayList<Element> producerElements = XMLUtil.getChildren(producersElement, "producer");
        for (Element producerElement : producerElements) {
            Producer producer = new Producer();
            String xroadInstance = XMLUtil.getTagValue(producerElement, "xroadInstance");
            if (StringUtils.isEmpty(xroadInstance)) {
                // in case X-Road instance is not given by the producer, take it from
                // Portal client instance: that ensures compatibility with prior export-import format
                // where only portal had X-Road instance defined which was also used by the producer
                xroadInstance = portal.getClientXroadInstance();
            }
            producer.setXroadInstance(xroadInstance);
            if (portal.isV6() && StringUtils.isEmpty(xroadInstance)) {
                logger.warn("Producer  " + producer.getXroadIdentifier()
                        + " has empty xroad instance.");
            }

           String memberClass = XMLUtil.getTagValue(producerElement, "memberClass");
            if (StringUtils.isEmpty(memberClass)) {
                memberClass = null;
            }
            producer.setMemberClass(memberClass);
            
            producer.setShortName(XMLUtil.getTagValue(producerElement, "shortName"));

            String subsystemCode = XMLUtil.getTagValue(producerElement, "subsystemCode");
            if (StringUtils.isEmpty(subsystemCode)) {
                subsystemCode = null;
            }
            producer.setSubsystemCode(subsystemCode);

            producer.setIsComplex(Boolean.valueOf(XMLUtil.getTagValue(producerElement, "isComplex")));

            boolean isComplex = producer.getIsComplex();
            producer.setInUse(isComplex == false);

            String protocol = XMLUtil.getTagValue(producerElement, "protocol");
            ProtocolType protocolType;
            if (protocol != null) {
                protocolType = ProtocolType.valueOf(protocol);
            } else {
                protocolType = ProtocolType.SOAP;
            }
            producer.setProtocol(protocolType);

            Producer baseProducer = producerService.findProducer(producer, portal); // Give id to producer
            producer.setId(baseProducer != null ? baseProducer.getId() : idCounter--);

            ArrayList<Element> producerNameElements = XMLUtil.getChildren(XMLUtil.getChild(producerElement, "names"),
                    "name");
            List<ProducerName> producerNameList = new ArrayList<ProducerName>();
            producer.setProducerNameList(producerNameList);
            for (Element nameElement : producerNameElements) {
                ProducerName producerName = new ProducerName();
                producerName.setProducer(producer);
                producerName.setDescription(XMLUtil.getTagValue(nameElement, "description"));
                producerName.setLang(nameElement.getAttribute("lang"));
                producerNameList.add(producerName);
            }

            ArrayList<Element> queryElements = XMLUtil.getChildren(XMLUtil.getChild(producerElement, "queries"),
                    "query");
            List<Xforms> xFormsList = new ArrayList<Xforms>();
            if (isComplex) {
                complexProducersXforms.put(producer, xFormsList); // producers need to have id-s!
            } else {
                activeProducersXforms.put(producer, xFormsList);
            }
            for (Element queryElement : queryElements) {
                Xforms xForm = new Xforms();
                xFormsList.add(xForm);
                xForm.setUrl(XMLUtil.getTagValue(queryElement, "URL"));
                Query query = new Query();
                xForm.setQuery(query);
                query.setName(XMLUtil.getTagValue(queryElement, "shortName"));
                query.setProducer(producer);
                query.setType(isComplex ? 2 : 0);
                query.setOpenapiServiceCode(XMLUtil.getTagValue(queryElement, "openapiServiceCode"));

                // validate form file existence
                getXFormFile(tempDir, producer, xForm, true);

                xForm.setId(0); // temporary
                if (baseProducer != null) {
                    Query baseQuery = queryService.findQueryByName(query.getName(), baseProducer, query.getOpenapiServiceCode());
                    if (baseQuery != null) {
                        Xforms baseXform = queryService.findXformEntityByQuery(baseQuery.getId());
                        if (baseXform != null) {
                            xForm.setId(baseXform.getId());
                        }
                    }
                }
                if (xForm.getId() == 0) { // no match was found from database
                    xForm.setId(idCounter--);
                }

                ArrayList<Element> queryNameElements = XMLUtil.getChildren(XMLUtil.getChild(queryElement, "names"),
                        "name");
                List<QueryName> queryNameList = new ArrayList<QueryName>();
                query.setQueryNameList(queryNameList);
                for (Element nameElement : queryNameElements) {
                    QueryName queryName = new QueryName();
                    queryName.setQuery(query);
                    queryName.setDescription(XMLUtil.getTagValue(nameElement, "description"));
                    queryName.setQueryNote(XMLUtil.getTagValue(nameElement, "note"));
                    queryName.setLang(nameElement.getAttribute("lang"));
                    queryNameList.add(queryName);
                }
            }
        }

        return new QueryImportData(tempDir, activeProducersXforms, complexProducersXforms);
    }

    /**
     * Derive expected X-Forms file path in the exported archive.
     * The path is found from producer and xForm entities and tempDir directory.
     * Also optionally check whether the file exists (mustExist input parameter).
     * Method is used by both
     * @param tempDir import archive root directory
     * @param producer Producer entity for current X-Forms entity
     * @param xForm X-Forms entity, its query name is used as file name
     * @param mustExist if true, then require the existence of the file,
     *  otherwise fail with MispException. If false, return the file without
     *  checking existence
     * @return X-Forms File object
     * @throws IOException on file reading failure
     * @throws MispException if file must exist (mustExist parameter), but does not
     */
    private File getXFormFile(File tempDir, Producer producer, Xforms xForm, final boolean mustExist)
            throws IOException, MispException {
        File xFormFile;
        List<String> filePaths = new ArrayList<String>();
        
        // Look up xFormFile
        if (producer.getMemberClass() == null) { // X-Road v5 service
            // X-Road v5 format is the same as X-Road v6 legacy
            String formFilePath = producer.getShortName() + "/" + producer.getShortName() + "."
                    + xForm.getQuery().getName() + ".xhtml";
            xFormFile = new File(tempDir, formFilePath);
            filePaths.add(xFormFile.getPath());
            
        } else { // X-Road v6 service
            
            // On X-Road v6, first try to find file with newer path format
            String formFilePath = producer.getXroadIdentifier().replace(" ", "").replace(":", ".")
                    + "/"  + xForm.getQuery().getName() + ".xhtml";
            xFormFile = new File(tempDir, formFilePath);
            filePaths.add(xFormFile.getPath());
            
            // If file does not exist at path with newer format (but is expected to),
            // try to find the file with legacy path format
            if (mustExist && !xFormFile.exists()) {
                formFilePath = producer.getShortName() + "/" + producer.getShortName() + "."
                        + xForm.getQuery().getName() + ".xhtml";
                xFormFile = new File(tempDir, formFilePath);
                filePaths.add(xFormFile.getPath());
            }
        }
        // If file must exist, but does not, throw MispException
        if (mustExist && !xFormFile.exists()) {
            if (filePaths.size() > 1) {
                throw new MispException("File does not exist at any of the following paths: "
                        + filePaths + "!");
            } else {
                throw new MispException("File with path '" + xFormFile.getPath() + "' does not exist!");
            }
        }
        // Finally, return the found file
        return xFormFile;
    }

    /**
     * Parse from import data structure producer IDs along with Xforms IDs
     * @param producersNode XML node containing producers import data
     * @return producer ID-s and respective associations with Xforms entity IDs
     */
    public LinkedHashMap<Integer, List<Integer>> getProducerIdsWithXformIds(JsonNode producersNode) {
        LinkedHashMap<Integer, List<Integer>> producerIdsWithXformIds = new LinkedHashMap<Integer, List<Integer>>();

        Iterator<Entry<String, JsonNode>> producersIt = producersNode.fields();
        while (producersIt.hasNext()) {
            Entry<String, JsonNode> producerEntry = producersIt.next();
            int producerId = Integer.parseInt(producerEntry.getKey());

            List<Integer> xformIds = new ArrayList<Integer>();
            producerIdsWithXformIds.put(producerId, xformIds);
            JsonNode xFormsNode = producerEntry.getValue();
            Iterator<JsonNode> xFormsIt = xFormsNode.elements();
            while (xFormsIt.hasNext()) {
                JsonNode xFormNode = xFormsIt.next();
                int xFormId = Integer.parseInt(xFormNode.textValue());
                xformIds.add(xFormId);
            }
        }

        return producerIdsWithXformIds;
    }

    /**
     * Import data from parsed import data structure
     * @param importData parsed import data object
     * @param producerIdsWithXformIds producer IDs and associations with Xforms IDs
     * @param portal Portal entity where data is imported
     * @param org current user session organization used in allowedMethods X-Road meta queries
     * @throws Exception on failure
     */
    public void importData(QueryImportData importData, LinkedHashMap<Integer, List<Integer>> producerIdsWithXformIds,
            Portal portal, Org org) throws Exception {
        File tempDir = (File) importData.getTempDir();
        LinkedHashMap<Producer, List<Xforms>> activeProducersXforms = importData.getActiveProducersWithXforms();
        LinkedHashMap<Producer, List<Xforms>> complexProducersXforms = importData.getComplexProducersWithXforms();
        HashMap<Integer, Producer> producerHandles = new HashMap<Integer, Producer>(); // Handles to producers. Keys are
                                                                                      // producers id-s.
        for (Producer producer : activeProducersXforms.keySet()) {
            producerHandles.put(producer.getId(), producer);
        }
        for (Producer producer : complexProducersXforms.keySet()) {
            producerHandles.put(producer.getId(), producer);
        }
        for (Entry<Integer, List<Integer>> entry : producerIdsWithXformIds.entrySet()) {
            Integer producerId = entry.getKey();
            List<Integer> xformIds = entry.getValue();

            Producer producer = null;
            Producer importedProducer = producerHandles.get(producerId);
            if (producerId > 0) { // producer exists and will be overwritten
                producer = producerService.findObject(Producer.class, producerId);
            }
            if(producer == null) {
                producer = producerService.findProducer(importedProducer, portal);
            }
            if(producer != null) {
                producer.setProducerNameList(null);
                producerService.deleteProducerNames(producer);
            } else {
                producer = new Producer();
            }

            producer.setPortal(portal);
            producer.setProtocol(importedProducer.getProtocol());
            producer.setShortName(importedProducer.getShortName());
            String xroadInstance = importedProducer.getXroadInstance();
            if (xroadInstance == null) {
            	logger.warn("Imported producer '" + importedProducer.getXroadIdentifier()
            	    + "' does not have X-Road instance information. Using client's.");
                xroadInstance = portal.getClientXroadInstance();
            }
            producer.setXroadInstance(xroadInstance);
            producer.setMemberClass(importedProducer.getMemberClass());
            producer.setSubsystemCode(importedProducer.getSubsystemCode());
            producer.setInUse(importedProducer.getInUse());
            producer.setIsComplex(importedProducer.getIsComplex());

            producerService.save(producer);
            for (ProducerName producerName : importedProducer.getProducerNameList()) {
                producerName.setProducer(producer);
                producerService.save(producerName);
            }

            List<Xforms> xFormsList;
            boolean isComplex = producer.getIsComplex();
            // If producer is complex, all its queries are automatically allowed to be operated. Otherwise they are only
            // allowed if they are in this set.
            HashSet<String> allowedQueries = new HashSet<String>();
            if (isComplex) {
                xFormsList = complexProducersXforms.get(importedProducer);
            } else {
                xFormsList = activeProducersXforms.get(importedProducer);
                // get allowed methods (queries) HashSet and later check each not complex query whether it contains in
                // this HashSet.
                // If it does, then add OrqQuery
                if(ProtocolType.REST.equals(producer.getProtocol())) {
                    try {
                        allowedQueries = queryService.getAllowedMethodIdentifiersFromSecurityServer(producer, org);
                    } catch (DataExchangeException e) {
                        // (query rights only influence how they are displayed to viewer, so not a show-stopper: just log
                        // exception)
                        logger.error("Allowed query refresh failed for producer '" + producer.getXroadIdentifier()
                            + "', but carrying on with query import regardless.", e);
                    }
                }
            }
            // Handles to xForms. Keys are xForms
            HashMap<Integer, Xforms> xFormHandles = new HashMap<Integer, Xforms>();
                                                                                    // id-s.
            for (Xforms xForm : xFormsList) {
                xFormHandles.put(xForm.getId(), xForm);
            }

            for (Integer xformId : xformIds) {
                Xforms xForm;
                Query query;
                Xforms importedXform = xFormHandles.get(xformId);
                if (xformId > 0) { // xForm exists and will be overwritten
                    xForm = queryService.findObject(Xforms.class, xformId);
                    query = xForm.getQuery();
                    query.setQueryNameList(null);
                    queryService.deleteQueryNames(query);
                } else { // xForm does not exist and will be created
                    xForm = new Xforms();
                    query = new Query();
                    xForm.setQuery(query);
                    query.setProducer(producer);
                }

                xForm.setUrl(importedXform.getUrl());
                query.setType(importedXform.getQuery().getType());
                query.setName(importedXform.getQuery().getName());
                query.setOpenapiServiceCode(importedXform.getQuery().getOpenapiServiceCode());

                File xFormFile = getXFormFile(tempDir, producer, xForm, true);
                xForm.setForm(FileUtils.readFileToString(xFormFile, "UTF-8"));

                // for X-Forms complex queries and all REST queries
                if (query.getType() == QUERY_TYPE.X_ROAD_COMPLEX.ordinal()
                        || query.getProducer().getProtocol() == Producer.ProtocolType.REST) {
                    queryService.addSubQueryNames(query, xForm);
                }

                queryService.save(query);
                for (QueryName queryName : importedXform.getQuery().getQueryNameList()) {
                    queryName.setQuery(query);
                    queryService.save(queryName);
                }

                queryService.save(xForm);

                boolean isQueryAllowed = isComplex || allowedQueries.contains(query.getFullIdentifier())
                    || ProtocolType.REST.equals(producer.getProtocol());

                if (isQueryAllowed) { // Generate OrgQuery object(s) if allowed
                    if (isComplex == false) {
                        if (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL
                                && org.getId().intValue() == portal.getOrgId().getId().intValue()
                                && portal.getUnitIsConsumer()) { // universal portal
                            List<Org> orgList = queryService.reAttach(org, Org.class).getOrgList();
                            for (Org o : orgList) {
                                if (queryService.orgQueryUnitExists(query, portal, o) == false) {
                                    queryService.saveOrgQuery(new OrgQuery(), o, query);
                                }
                            }
                        } else {
                            if (queryService.orgQueryExists(query, portal, org) == false) {
                                queryService.saveOrgQuery(new OrgQuery(), org, query);
                            }
                        }
                    } else { // isComplex
                        if (portal.getMispType() == Const.MISP_TYPE_UNIVERSAL && portal.getUnitIsConsumer()) {
                            // universal portal
                            Org supOrg = queryService.reAttach(
                                    (Org) ActionContext.getContext().getSession().get(Const.SESSION_ACTIVE_ORG),
                                    Org.class);
                            if (supOrg.getSupOrgId() == null) { // if active org is suporg
                                List<Org> suborgs = supOrg.getOrgList();
                                for (Org suborg : suborgs) {
                                    if (!queryService.orgQueryExists(query, portal, suborg)) {
                                        queryService.saveOrgQuery(new OrgQuery(), suborg, query);
                                    }
                                }
                            }
                        } else {
                            if (queryService.orgQueryExists(query, portal, org) == false) {
                                queryService.saveOrgQuery(new OrgQuery(), org, query);
                            }
                        }
                    }
                } else { // not allowed
                    orgService.deleteOrgQueries(query.getId()); // these might exist in database from past, but are not
                                                                // allowed anymore
                }

            }
        }
    }

    private Element getProducerNamesElement(Document doc, String ns, List<ProducerName> producerNames) {
        Element producerNamesElement = doc.createElementNS(ns, "names");
        for (ProducerName producerName : producerNames) {
            Element nameElement = (Element) producerNamesElement.appendChild(doc.createElementNS(ns, "name"));
            nameElement.setAttribute("lang", producerName.getLang());
            nameElement.appendChild(doc.createElementNS(ns, "description"))
                    .appendChild(doc.createTextNode(producerName.getDescription()));
        }
        return producerNamesElement;
    }

    private Element getQueryNamesElement(Document doc, String ns, List<QueryName> queryNames) {
        Element queryNamesElement = doc.createElementNS(ns, "names");
        for (QueryName queryName : queryNames) {
            Element nameElement = (Element) queryNamesElement.appendChild(doc.createElementNS(ns, "name"));
            nameElement.setAttribute("lang", queryName.getLang());
            nameElement.appendChild(doc.createElementNS(ns, "description"))
                    .appendChild(doc.createTextNode(queryName.getDescription()));
            nameElement.appendChild(doc.createElementNS(ns, "note"))
                    .appendChild(doc.createTextNode(queryName.getQueryNote()));
        }
        return queryNamesElement;
    }

    /**
     * Set queryService
     * @param queryServiceNew QueryService bean
     */
    public void setQueryService(QueryService queryServiceNew) {
        this.queryService = queryServiceNew;
    }

    /**
     * Set producerService
     * @param producerServiceNew ProducerService bean
     */
    public void setProducerService(ProducerService producerServiceNew) {
        this.producerService = producerServiceNew;
    }

    /**
     * Set orgService
     * @param orgServiceNew OrgService bean
     */
    public void setOrgService(OrgService orgServiceNew) {
        this.orgService = orgServiceNew;
    }
}
