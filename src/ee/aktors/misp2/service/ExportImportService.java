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

package ee.aktors.misp2.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map.Entry;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.ObjectUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.ServletActionContext;
import org.springframework.transaction.annotation.Transactional;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.xml.sax.SAXException;

import ee.aktors.misp2.action.exception.BusinessException;
import ee.aktors.misp2.action.exception.MispException;
import ee.aktors.misp2.exportImport.QueryImportData;
import ee.aktors.misp2.model.GeneralBeanName;
import ee.aktors.misp2.model.GroupItem;
import ee.aktors.misp2.model.GroupPerson;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgName;
import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.OrgQuery;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.PersonGroup;
import ee.aktors.misp2.model.PersonMailOrg;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.model.QueryTopic;
import ee.aktors.misp2.model.Topic;
import ee.aktors.misp2.model.TopicName;
import ee.aktors.misp2.model.Xforms;
import ee.aktors.misp2.model.XroadInstance;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.DateUtil;
import ee.aktors.misp2.util.FileUtil;
import ee.aktors.misp2.util.Roles;
import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.XMLUtilException;
import ee.aktors.misp2.util.ZipUtil;

/**
 * @author karol.kartau
 */
@Transactional
public class ExportImportService extends BaseService {
    private static Logger logger = LogManager.getLogger(ExportImportService.class);

    private OrgService orgService;
    private UserService userService;
    private GroupService groupService;
    private TopicService topicService;
    private ProducerService producerService;
    private QueryService queryService;
    private PortalService portalService;
    private QueryExportImportService queryExportImportService;
    private XroadInstanceService xroadInstanceService;

    /**
     * Generate file containing portal configuration data so it can later be imported
     * @param portal portal
     * @param includeSubOrgsAndGroups include sub orgs and groups
     * @param includeGroupPersons include group persons
     * @param includeGroupQueries include group queries
     * @param includeTopics include topics
     * @param includeQueries include queries
     * @param chosenSubOrg can be null
     * @return generated file
     * @throws FileNotFoundException file not found
     * @throws SAXException document validation fails
     * @throws IOException in case of file writing failure
     * @throws XMLUtilException if getting empty document fails
     * @throws MispException in case of internal error
     */
    public File getExportFile(Portal portal, boolean includeSubOrgsAndGroups, boolean includeGroupPersons,
            boolean includeGroupQueries, boolean includeTopics, boolean includeQueries, Org chosenSubOrg)
            throws FileNotFoundException, SAXException, IOException, XMLUtilException, MispException {

        logger.info("Exporting portal '" + portal.getShortName() + "' data.");
        File tempDir = FileUtil.getTempDir();

        Document doc = XMLUtil.getEmptyDocument();
        String ns = "http://www.aktors.ee/support/xroad/xsd/export.xsd"; // namespace

        Element rootElement = (Element) doc.appendChild(doc.createElementNS(ns, "root"));

        HashSet<Person> persons = new HashSet<Person>();

        boolean universal = portal.getMispType() == Const.MISP_TYPE_UNIVERSAL
                            || portal.getMispType() == Const.MISP_TYPE_ORGANISATION;
        rootElement.appendChild(doc.createElementNS(ns, "universal")).appendChild(doc.createTextNode("" + universal));
        rootElement.appendChild(doc.createElementNS(ns, "xroadProtocolVer")).appendChild(
                doc.createTextNode(portal.getXroadProtocolVer()));
        if (portal.isV6()) {
            rootElement.appendChild(doc.createElementNS(ns, "xroadInstance")).appendChild(
                    doc.createTextNode(portal.getClientXroadInstance()));
        }
        Element headOrgElement = (Element) rootElement.appendChild(doc.createElementNS(ns, "headOrg"));
        Org headOrg = portal.getOrgId();
        
        
        GetElementInput input = new GetElementInput();
        
        input.doc = doc;
        input.ns = ns;
        input.org = headOrg;
        input.chosenSubOrg = chosenSubOrg;
        input.portal = portal;
        input.persons = persons;
        input.includeTopics = includeTopics;
        input.includeGroupPersons = includeGroupPersons;
        input.includeSubOrgsAndGroups = includeSubOrgsAndGroups;
        input.includeGroupQueries = includeGroupQueries;
        
        headOrgElement.appendChild(getOrgPersonsElement(input));
        headOrgElement.appendChild(getGroupsElement(input));
        rootElement.appendChild(getSubOrgsElement(input));
        rootElement.appendChild(getTopicsElement(input));
        // Create personsElement from those persons which were included in other elements
        rootElement.appendChild(getPersonsElement(input));
        if (portal.isV6()) {
            rootElement.appendChild(getServiceXroadInstancesElement(input));
        }

        File xsdFile = new File(ServletActionContext.getServletContext().getRealPath("/")
                                                                 + "/resources/xsd/export.xsd");
        XMLUtil.validateDocumentIgnoringMissingAttributes(doc, new FileInputStream(xsdFile));

        File xmlFile = new File(tempDir, "export.xml");
        FileUtils.writeStringToFile(xmlFile, XMLUtil.convertDocumentToXML(doc), "UTF-8");

        if (includeQueries) {
            List<Producer> producers = new ArrayList<Producer>();
            producers.addAll(producerService.findActiveProducers(portal));
            producers.addAll(producerService.findComplexProducers(portal));
            File queryExportFile = queryExportImportService.getExportFile(queryExportImportService
                    .getProducersWithXforms(producers));
            ZipUtil.unzip(queryExportFile, tempDir);
            queryExportFile.delete();
        }

        ArrayList<File> inputFiles = new ArrayList<File>(Arrays.asList(tempDir.listFiles()));
        File exportFile = new File(FileUtil.getTempDir(),
                FileUtil.getExportFileName("export", portal, "zip"));
        ZipUtil.zip(inputFiles, exportFile);
        FileUtils.deleteDirectory(tempDir);

        return exportFile;
    }


    /**
     * Import portal configuration from file
     * @param importFile file to import
     * @param portal portal
     * @param includeSubOrgsAndGroups include sub orgs and groups
     * @param includeGroupPersons include group persons
     * @param includeGroupQueries include group queries
     * @param includeTopics include topics
     * @param includeQueries include queries
     * @throws BusinessException business rule violation
     * @throws SAXException document validation fails
     * @throws XMLUtilException if getting empty document fails
     * @throws IOException throws
     * @throws Exception throws
     * @throws MispException throws
     */
    public void importFile(File importFile, Portal portal, boolean includeSubOrgsAndGroups,
            boolean includeGroupPersons, boolean includeGroupQueries, boolean includeTopics, boolean includeQueries)
            throws IOException, XMLUtilException, MispException, SAXException, BusinessException, Exception {
        logger.info("Importing data to '" + portal.getShortName() + "' portal.");
        File tempDir = FileUtil.getTempDir();
        ZipUtil.unzip(importFile, tempDir);

        File xmlFile = new File(tempDir, "export.xml");
        Document doc = XMLUtil.convertXMLToDocument(FileUtils.readFileToString(xmlFile, "UTF-8"));

        File xsdFile = new File(ServletActionContext.getServletContext().getRealPath("/")
                                                                + "/resources/xsd/export.xsd");
        XMLUtil.validateDocumentIgnoringMissingAttributes(doc, new FileInputStream(xsdFile));

        Element rootElement = doc.getDocumentElement();

        boolean universal = Boolean.parseBoolean(XMLUtil.getTagValue(rootElement, "universal"));
        boolean currentPortalUniversal = portal.getMispType() == Const.MISP_TYPE_UNIVERSAL
                                        || portal.getMispType() == Const.MISP_TYPE_ORGANISATION;
        if (universal == false && currentPortalUniversal)
            throw new BusinessException("exportImport.import.error.fromNonuniversalPortalToUniversal");

        savePortal(portal, rootElement);

        File queryImportFile = new File(tempDir, "xforms_export.xml");
        if (queryImportFile.exists()) {
            importQueries(importFile, portal, includeQueries);
        }

        savePersons(XMLUtil.getChild(rootElement, "persons"));

        Org headOrg = portal.getOrgId();

        // Handle special case of importing from universal portal to non-universal
        // (leave subOrgs unsaved, but save subOrgs data to headOrg)
        if (universal && currentPortalUniversal == false) {
            saveSubOrgsDataToHeadOrg(XMLUtil.getChild(rootElement, "subOrgs"), headOrg, portal,
                    includeSubOrgsAndGroups, includeGroupPersons, includeGroupQueries);
        } else {
            saveSubOrgs(XMLUtil.getChild(rootElement, "subOrgs"), headOrg, portal, includeSubOrgsAndGroups,
                    includeGroupPersons, includeGroupQueries);
        }

        saveTopics(XMLUtil.getChild(rootElement, "topics"), portal, includeTopics);

        Element headOrgElement = XMLUtil.getChild(rootElement, "headOrg");
        saveOrgPersons(XMLUtil.getChild(headOrgElement, "orgPersons"), headOrg, portal, includeGroupPersons);
        // It is important to save headOrg groups after subOrgs,
        //because groupPersons and groupQueries might reference subOrgs
        saveGroups(XMLUtil.getChild(headOrgElement, "groups"), headOrg, portal, includeSubOrgsAndGroups,
                includeGroupPersons, includeGroupQueries);
        if (portal.isV6()) {
            saveServiceXroadInstances(
                    XMLUtil.getChild(rootElement, "serviceXroadInstances"), portal);
        }
        
        FileUtils.deleteDirectory(tempDir);
    }

    /**
     * Override X-Road version related fields to give context to exported services (which only work in given xroad
     * version)
     * 
     * @param sessionPortal
     *            portal from user session: is disconnected from session and does not have all fields in sync with DB
     * @param rootElement
     *            import data configuration file
     */
    private void savePortal(Portal sessionPortal, Element rootElement) {
        Portal portal = portalService.findObject(Portal.class, sessionPortal.getId());
        String xroadProtocolVer = XMLUtil.getTagValue(rootElement, "xroadProtocolVer");
        // default to X-Road v5, because legacy MISP2 X-Road v5 portals did not export protocol version field
        if (StringUtils.isEmpty(xroadProtocolVer)) {
            xroadProtocolVer = Const.XROAD_VERSION.V5.getProtocolVersion();
        }
        portal.setXroadProtocolVer(xroadProtocolVer);
        portal.setClientXroadInstance(XMLUtil.getTagValue(rootElement, "xroadInstance"));
    }

    @SuppressWarnings({ "unchecked", "rawtypes" })
    private Element getSubOrgsElement(GetElementInput input) {
        Element subOrgsElement = input.doc.createElementNS(input.ns, "subOrgs");
        Org oldOrg = input.org;
        if (input.includeSubOrgsAndGroups) {
            for (Org subOrg : orgService.findSubOrgs(input.org)) {
                if (input.chosenSubOrg != null && subOrg.equals(input.chosenSubOrg) == false)
                    continue; // If chosenSubOrg is specified, then subOrg has to match it
                input.org = subOrg;
                Element subOrgElement = (Element) subOrgsElement
                             .appendChild(input.doc.createElementNS(input.ns, "subOrg"));
                if (subOrg.getMemberClass() != null) {
                    subOrgElement.appendChild(input.doc.createElementNS(input.ns, "memberClass"))
                                 .appendChild(input.doc.createTextNode(subOrg.getMemberClass()));
                }
                subOrgElement.appendChild(input.doc.createElementNS(input.ns, "code"))
                             .appendChild(input.doc.createTextNode(subOrg.getCode()));
                subOrgElement.appendChild(getNamesElement(input.doc, input.ns, (List) subOrg.getOrgNameList()));
                subOrgElement.appendChild(getOrgPersonsElement(input));
                subOrgElement.appendChild(getGroupsElement(input));
            }
        }
        input.org = oldOrg;
        return subOrgsElement;
    }

    @SuppressWarnings({ "unchecked", "rawtypes" })
    private Element getTopicsElement(GetElementInput input) {
        Element topicsElement = input.doc.createElementNS(input.ns, "topics");
        if (input.includeTopics) {
            for (Topic topic : topicService.findTopics(input.portal)) {
                Element topicElement = (Element) topicsElement
                            .appendChild(input.doc.createElementNS(input.ns, "topic"));
                topicElement.appendChild(input.doc.createElementNS(input.ns, "name"))
                            .appendChild(input.doc.createTextNode(topic.getName()));
                if (topic.getPriority() != null)
                    topicElement.appendChild(input.doc.createElementNS(input.ns, "priority"))
                                .appendChild(input.doc.createTextNode("" + topic.getPriority()));
                topicElement.appendChild(
                        getNamesElement(input.doc, input.ns, (List) topicService.findTopicNames(topic)));
                topicElement.appendChild(getTopicQueriesElement(input.doc, input.ns, topic));
            }
        }
        return topicsElement;
    }

    private Element getPersonsElement(GetElementInput input) {
        Element personsElement = input.doc.createElementNS(input.ns, "persons");
        for (Person person : input.persons) {
            Element personElement = (Element) personsElement.appendChild(input.doc.createElementNS(input.ns, "person"));
            personElement.appendChild(input.doc.createElementNS(input.ns, "ssn"))
                         .appendChild(input.doc.createTextNode(person.getSsn()));
            personElement.appendChild(input.doc.createElementNS(input.ns, "givenname"))
                         .appendChild(input.doc.createTextNode(StringUtils.defaultString(person.getGivenname())));
            personElement.appendChild(input.doc.createElementNS(input.ns, "surname"))
                         .appendChild(input.doc.createTextNode(person.getSurname()));
        }
        return personsElement;
    }

    private Element getNamesElement(Document doc, String ns, List<GeneralBeanName> names) {
        Element namesElement = doc.createElementNS(ns, "names");
        for (GeneralBeanName name : names) {
            Element nameElement = (Element) namesElement.appendChild(doc.createElementNS(ns, "name"));
            nameElement.setAttribute("lang", name.getLang());
            nameElement.appendChild(doc.createElementNS(ns, "description")).appendChild(
                    doc.createTextNode(name.getDescription()));
        }
        return namesElement;
    }

    private Element getOrgPersonsElement(GetElementInput input) {
        Element orgPersonsElement = input.doc.createElementNS(input.ns, "orgPersons");
        if (input.includeGroupPersons && (input.chosenSubOrg == null || input.org.equals(input.chosenSubOrg))) {
            for (OrgPerson orgPerson : orgService.findAllOrgPersons(input.portal, input.org)) {
                Person person = orgPerson.getPersonId();
                input.persons.add(person);

                Element orgPersonElement = (Element) orgPersonsElement
                        .appendChild(input.doc.createElementNS(input.ns, "orgPerson"));
                orgPersonElement.appendChild(input.doc.createElementNS(input.ns, "ssn"))
                                .appendChild(input.doc.createTextNode(person.getSsn()));
                int role = Roles.removeRoles(orgPerson.getRole(), Roles.PORTAL_MANAGER);
                orgPersonElement.appendChild(input.doc.createElementNS(input.ns, "role"))
                                .appendChild(input.doc.createTextNode("" + role));
                orgPersonElement.appendChild(input.doc.createElementNS(input.ns, "profession"))
                        .appendChild(input.doc.createTextNode(StringUtils.defaultString(orgPerson.getProfession())));

                PersonMailOrg personMailOrg = userService.findPersonMailOrg(person.getId(), input.org.getId());
                orgPersonElement.appendChild(input.doc.createElementNS(input.ns, "mail"))
                                .appendChild(input.doc.createTextNode(personMailOrg != null
                                                    ? StringUtils.defaultString(personMailOrg.getMail()) : ""));
                boolean notifyChanges = (personMailOrg != null ? personMailOrg.getNotifyChanges() : false);
                orgPersonElement.appendChild(input.doc.createElementNS(input.ns, "notifyChanges"))
                                .appendChild(input.doc.createTextNode(Boolean.toString(notifyChanges)));
            }
        }
        return orgPersonsElement;
    }
    
    private Element getGroupsElement(GetElementInput input) {
        Element groupsElement = input.doc.createElementNS(input.ns, "groups");
        if (input.includeSubOrgsAndGroups) {
            for (PersonGroup personGroup : groupService.findDirectlyRelatedGroups(input.org)) {
                input.personGroup = personGroup;
                Element groupElement = (Element) groupsElement
                            .appendChild(input.doc.createElementNS(input.ns, "group"));
                groupElement.appendChild(input.doc.createElementNS(input.ns, "name"))
                            .appendChild(input.doc.createTextNode(personGroup.getName()));
                groupElement.appendChild(getGroupPersonsElement(input));
                groupElement.appendChild(getGroupQueriesElement(input));
            }
        }
        input.personGroup = null;
        return groupsElement;
    }

    private Element getGroupPersonsElement(GetElementInput input) {
        Element groupPersonsElement = input.doc.createElementNS(input.ns, "groupPersons");
        if (input.includeGroupPersons) {
            for (GroupPerson groupPerson : input.personGroup.getGroupPersonList()) {
                Org org = groupPerson.getOrg();
                if (input.chosenSubOrg != null && org.equals(input.chosenSubOrg) == false)
                    continue; // If chosenSubOrg is specified, then org has to match it
                Person person = groupPerson.getPerson();
                input.persons.add(person);

                Element groupPersonElement = (Element) groupPersonsElement
                                  .appendChild(input.doc.createElementNS(input.ns, "groupPerson"));
                groupPersonElement.appendChild(input.doc.createElementNS(input.ns, "ssn"))
                                  .appendChild(input.doc.createTextNode(person.getSsn()));

                // If grouPerson is related to different org, than group's org, then set that org's code as subOrgCode
                if (org.equals(input.personGroup.getOrgId()) == false) {
                    groupPersonElement.appendChild(input.doc.createElementNS(input.ns, "subOrgCode"))
                                      .appendChild(input.doc.createTextNode(org.getCode()));
                }

                if (groupPerson.getValiduntil() != null) {
                    groupPersonElement.appendChild(input.doc.createElementNS(input.ns, "validuntil"))
                    .appendChild(input.doc.createTextNode(DateUtil.convertDateToISODate(groupPerson.getValiduntil())));
                }
            }
        }
        return groupPersonsElement;
    }

    private Element getGroupQueriesElement(GetElementInput input) {
        Element groupQueriesElement = input.doc.createElementNS(input.ns, "groupQueries");
        if (input.includeGroupQueries) {
            for (GroupItem groupItem : input.personGroup.getGroupItemList()) {
                Org org = groupItem.getOrgQuery().getOrgId();
                // If chosenSubOrg is specified, then org has to match it, unless org is headOrg
                if (input.chosenSubOrg != null && org.equals(input.chosenSubOrg) == false && org.getSupOrgId() != null)
                    continue;
                Query query = groupItem.getOrgQuery().getQueryId();
                if (query.getProducer() == null)
                    continue; // Although query not having producer is illogical, it is still theoretically possible,
                              // so simply continue

                Element groupQueryElement = (Element) groupQueriesElement
                        .appendChild(input.doc.createElementNS(input.ns, "groupQuery"));
                groupQueryElement.appendChild(input.doc.createElementNS(input.ns, "name"))
                                 .appendChild(input.doc.createTextNode(StringUtils.defaultString(query.getName())));

                Producer producer = query.getProducer();
                exportProducerToXml(input.doc, groupQueryElement, input.ns, producer);
                // If groupQuery is related to different org, than group's org, then set that org's code as subOrgCode
                if (org.equals(input.personGroup.getOrgId()) == false) {
                    groupQueryElement.appendChild(input.doc.createElementNS(input.ns, "subOrgCode"))
                                     .appendChild(input.doc.createTextNode(org.getCode()));
                }

                groupQueryElement.appendChild(input.doc.createElementNS(input.ns, "invisible"))
                .appendChild(input.doc.createTextNode("" + ObjectUtils.defaultIfNull(groupItem.getInvisible(), false)));
            }
        }
        return groupQueriesElement;
    }

    private Element getTopicQueriesElement(Document doc, String ns, Topic topic) {
        Element topicQueriesElement = doc.createElementNS(ns, "topicQueries");
        for (QueryTopic queryTopic : topic.getQueryTopicList()) {
            Query query = queryTopic.getQuery();
            if (query.getProducer() == null)
                continue; // Although query not having producer is illogical, it is still theoretically possible,
                          //  so simply continue
            Element topicQueryElement = (Element) topicQueriesElement
                    .appendChild(doc.createElementNS(ns, "topicQuery"));
            topicQueryElement.appendChild(doc.createElementNS(ns, "name")).appendChild(
                    doc.createTextNode(StringUtils.defaultString(query.getName())));
            exportProducerToXml(doc, topicQueryElement, ns, query.getProducer());
        }
        return topicQueriesElement;
    }
    
    private Node getServiceXroadInstancesElement(GetElementInput input) {
        Element serviceXroadInstancesElement = input.doc.createElementNS(input.ns, "serviceXroadInstances");
        List<XroadInstance> serviceXroadInstances = xroadInstanceService.findInstances(input.portal);
        for (XroadInstance xroadInstance : serviceXroadInstances) {
            Element xroadInstanceElement = (Element) serviceXroadInstancesElement
                    .appendChild(input.doc.createElementNS(input.ns, "xroadInstance"));
            xroadInstanceElement.appendChild(input.doc.createElementNS(input.ns, "code")).appendChild(
                    input.doc.createTextNode(StringUtils.defaultString(xroadInstance.getCode())));
            String inUseStr = xroadInstance.getInUse() != null
                    ? xroadInstance.getInUse().toString() : "" + false;
            xroadInstanceElement.appendChild(input.doc.createElementNS(input.ns, "inUse")).appendChild(
                    input.doc.createTextNode(inUseStr));
            String selectedStr = xroadInstance.getSelected() != null
                    ? xroadInstance.getSelected().toString() : "" + false;
            xroadInstanceElement.appendChild(input.doc.createElementNS(input.ns, "selected")).appendChild(
                    input.doc.createTextNode(selectedStr));
        }
        return serviceXroadInstancesElement;
    }

    private void importQueries(File queriesImportFile, Portal portal, boolean includeQueries) throws Exception {
        if (includeQueries) {
            QueryImportData queryImportData = queryExportImportService.getImportData(queriesImportFile, portal);

            LinkedHashMap<Integer, List<Integer>> producerIdsWithXformIds = new LinkedHashMap<Integer, List<Integer>>();
            LinkedHashMap<Producer, List<Xforms>> producersWithXforms = new LinkedHashMap<Producer, List<Xforms>>();
            producersWithXforms.putAll(queryImportData.getActiveProducersWithXforms());
            producersWithXforms.putAll(queryImportData.getComplexProducersWithXforms());
            for (Entry<Producer, List<Xforms>> entry : producersWithXforms.entrySet()) {
                int producerId = entry.getKey().getId();
                List<Integer> xformIds = new ArrayList<Integer>();
                producerIdsWithXformIds.put(producerId, xformIds);
                for (Xforms xform : entry.getValue()) {
                    xformIds.add(xform.getId());
                }
            }

            queryExportImportService.importData(queryImportData, producerIdsWithXformIds, portal, portal.getOrgId());
            FileUtils.deleteDirectory(queryImportData.getTempDir());
        }
    }

    private void savePersons(Element personsElement) {
        for (Element personElement : XMLUtil.getChildren(personsElement, "person")) {
            String ssn = XMLUtil.getTagValue(personElement, "ssn");
            Person person = userService.findPersonBySSN(ssn);
            person = (person != null ? person : new Person());
            userService.savePerson(person, ssn, XMLUtil.getTagValue(personElement, "givenname"),
                    XMLUtil.getTagValue(personElement, "surname"));
        }
    }

    private void saveSubOrgs(Element subOrgsElement, Org org, Portal portal, boolean includeSubOrgsAndGroups,
            boolean includeGroupPersons, boolean includeGroupQueries) {
        if (includeSubOrgsAndGroups) {
            for (Element subOrgElement : XMLUtil.getChildren(subOrgsElement, "subOrg")) {
                String code = XMLUtil.getTagValue(subOrgElement, "code");
                String memberClass = XMLUtil.getTagValue(subOrgElement, "memberClass");
                if (StringUtils.isEmpty(memberClass)) {
                    memberClass = null;
                }
                Org subOrg = orgService.findSubOrg(org, code);
                subOrg = (subOrg != null ? subOrg : new Org());
                orgService.saveOrg(subOrg, memberClass, code, org);

                saveOrgNames(XMLUtil.getChild(subOrgElement, "names"), subOrg);
                saveOrgPersons(XMLUtil.getChild(subOrgElement, "orgPersons"), subOrg, portal, includeGroupPersons);
                saveGroups(XMLUtil.getChild(subOrgElement, "groups"), subOrg, portal, includeSubOrgsAndGroups,
                        includeGroupPersons, includeGroupQueries);
            }
        }
    }

    private void saveSubOrgsDataToHeadOrg(Element subOrgsElement, Org headOrg, Portal portal,
            boolean includeSubOrgsAndGroups, boolean includeGroupPersons, boolean includeGroupQueries) {
        if (includeSubOrgsAndGroups) {
            for (Element subOrgElement : XMLUtil.getChildren(subOrgsElement, "subOrg")) {
                saveOrgPersons(XMLUtil.getChild(subOrgElement, "orgPersons"), headOrg, portal, includeGroupPersons);
                saveGroups(XMLUtil.getChild(subOrgElement, "groups"), headOrg, portal, includeSubOrgsAndGroups,
                        includeGroupPersons, includeGroupQueries);
            }
        }
    }

    private void saveTopics(Element topicsElement, Portal portal, boolean includeTopics) {
        if (includeTopics) {
            for (Element topicElement : XMLUtil.getChildren(topicsElement, "topic")) {
                String name = XMLUtil.getTagValue(topicElement, "name");
                Topic topic = topicService.findTopic(portal, name, null);
                topic = (topic != null ? topic : new Topic());
                String priorityString = XMLUtil.getTagValue(topicElement, "priority");
                topicService.saveTopic(topic, name, (priorityString != null ? Integer.parseInt(priorityString) : null),
                        portal);

                saveTopicNames(XMLUtil.getChild(topicElement, "names"), topic);
                saveTopicQueries(XMLUtil.getChild(topicElement, "topicQueries"), topic, portal);
            }
        }
    }

    private void saveOrgNames(Element orgNamesElement, Org org) {
        for (Element nameElement : XMLUtil.getChildren(orgNamesElement, "name")) {
            String lang = nameElement.getAttribute("lang");
            OrgName name = orgService.findOrgName(org, lang);
            name = (name != null ? name : new OrgName());
            orgService.saveOrgName(name, org, lang, XMLUtil.getTagValue(nameElement, "description"));
        }
    }

    private void saveOrgPersons(Element orgPersonsElement, Org org, Portal portal, boolean includeGroupPersons) {
        if (includeGroupPersons) {
            for (Element orgPersonElement : XMLUtil.getChildren(orgPersonsElement, "orgPerson")) {
                Person person = userService.findPersonBySSN(XMLUtil.getTagValue(orgPersonElement, "ssn"));

                OrgPerson orgPerson = userService.findOrgPerson(person.getId(), org.getId(), portal.getId());
                orgPerson = (orgPerson != null ? orgPerson : new OrgPerson());
                int role = Roles.addRoles((orgPerson.getRole() != null ? orgPerson.getRole() : 0),
                        Integer.parseInt(XMLUtil.getTagValue(orgPersonElement, "role")));
                userService.saveOrgPerson(orgPerson, org, person, portal, role,
                        XMLUtil.getTagValue(orgPersonElement, "profession"));

                PersonMailOrg personMailOrg = userService.findPersonMailOrg(person.getId(), org.getId());
                personMailOrg = (personMailOrg != null ? personMailOrg : new PersonMailOrg());
                userService.savePersonMailOrg(personMailOrg, person, org,
                        XMLUtil.getTagValue(orgPersonElement, "mail"),
                        Boolean.parseBoolean(XMLUtil.getTagValue(orgPersonElement, "notifyChanges")));
            }
        }
    }

    private void saveGroups(Element groupsElement, Org org, Portal portal, boolean includeSubOrgsAndGroups,
            boolean includeGroupPersons, boolean includeGroupQueries) {
        if (includeSubOrgsAndGroups) {
            for (Element groupElement : XMLUtil.getChildren(groupsElement, "group")) {
                String name = XMLUtil.getTagValue(groupElement, "name");
                PersonGroup group = groupService.findDirectlyRelatedGroup(org, name);
                group = (group != null ? group : new PersonGroup());
                groupService.saveGroup(group, name, org, portal);

                saveGroupPersons(XMLUtil.getChild(groupElement, "groupPersons"), group, portal, includeGroupPersons);
                saveGroupQueries(XMLUtil.getChild(groupElement, "groupQueries"), group, portal, includeGroupQueries);
            }
        }
    }

    private void saveGroupPersons(Element groupPersonsElement, PersonGroup group, Portal portal,
            boolean includeGroupPersons) {
        if (includeGroupPersons) {
            for (Element groupPersonElement : XMLUtil.getChildren(groupPersonsElement, "groupPerson")) {
                Person person = userService.findPersonBySSN(XMLUtil.getTagValue(groupPersonElement, "ssn"));
                Org org = getGroupOrg(group, portal, XMLUtil.getTagValue(groupPersonElement, "subOrgCode"));

                GroupPerson groupPerson = userService.findGroupPerson(group.getId(), person.getId(), org.getId());
                groupPerson = (groupPerson != null ? groupPerson : new GroupPerson());

                String validuntilString = XMLUtil.getTagValue(groupPersonElement, "validuntil");
                userService.saveGroupPerson(groupPerson, group, person, org,
                        (validuntilString != null ? DateUtil.convertISODateToDate(validuntilString) : null));
            }
        }
    }

    private void exportProducerToXml(Document doc, Element groupQueryElement, String ns, Producer producer) {
        // set xroadInstance field value if it is set for producer
        String xroadInstance = producer.getXroadInstance();
        if (xroadInstance != null) {
            groupQueryElement.appendChild(doc.createElementNS(ns, "producerXroadInstance")).appendChild(
                    doc.createTextNode(xroadInstance));
        }
        
        // set memberClass field value if it is set for producer
        String memberClass = producer.getMemberClass();
        if (memberClass != null) {
            groupQueryElement.appendChild(doc.createElementNS(ns, "producerMemberClass")).appendChild(
                    doc.createTextNode(memberClass));
        }
        
        // always set shortName (memberCode in X-Road v6)
        groupQueryElement.appendChild(doc.createElementNS(ns, "producerShortName")).appendChild(
                doc.createTextNode(producer.getShortName()));
        
        // set subsystem code field value if it is set for producer
        String subsystemCode = producer.getSubsystemCode();
        if (subsystemCode != null) {
            groupQueryElement.appendChild(doc.createElementNS(ns, "producerSubsystemCode")).appendChild(
                    doc.createTextNode(subsystemCode));
        }
        if (producer.getProtocol() != null) {
            groupQueryElement.appendChild(doc.createElementNS(ns, "producerProtocol")).appendChild(
                    doc.createTextNode(producer.getProtocol().toString()));
        }
    }

    private Producer getTempProducerFromXml(Element groupsElement, Portal portal) {
        Producer tmpProducer = new Producer();
        
        // set xroad instance of producer
        String producerXroadInstance = XMLUtil.getTagValue(groupsElement, "producerXroadInstance");
        // use portal client x-road instance as default value for X-Road v6 protocol
        if (portal.isV6() && StringUtils.isEmpty(producerXroadInstance)) {
            producerXroadInstance = portal.getClientXroadInstance();
        }
        // if X-Road instance is still empty, set it to null
        if (StringUtils.isEmpty(producerXroadInstance)) {
            producerXroadInstance = null;
        }
        tmpProducer.setXroadInstance(producerXroadInstance);
        
        // set member class producer field
        String producerMemberClass = XMLUtil.getTagValue(groupsElement, "producerMemberClass");
        // if it is empty, set to null for consistent handling of non-existent values
        if (StringUtils.isEmpty(producerMemberClass)) {
            producerMemberClass = null;
        }
        tmpProducer.setMemberClass(producerMemberClass);

        // set shortName (memberCode in X-Road v6)
        String producerShortname = XMLUtil.getTagValue(groupsElement, "producerShortName");
        // producer short name is never expected to be empty,
        // that's why empty value is not set to null as the others are
        tmpProducer.setShortName(producerShortname);
        
        // set subsystem code producer field
        String producerSubsystemCode = XMLUtil.getTagValue(groupsElement, "producerSubsystemCode");
        // if it is empty, set to null for consistent handling of non-existent values
        if (StringUtils.isEmpty(producerSubsystemCode)) {
            producerSubsystemCode = null;
        }
        tmpProducer.setSubsystemCode(producerSubsystemCode);

        // set subsystem code producer field
        String producerProtocolStr = XMLUtil.getTagValue(groupsElement, "producerProtocol");
        Producer.ProtocolType producerProtocol;
        // if it is empty, set to null for consistent handling of non-existent values
        if (StringUtils.isBlank(producerProtocolStr)) {
            producerProtocol = Producer.ProtocolType.SOAP;
        } else {
            producerProtocol = Producer.ProtocolType.valueOf(producerProtocolStr);
        }
        tmpProducer.setProtocol(producerProtocol);

        return tmpProducer;
    }

    private void saveGroupQueries(Element groupQueriesElement, PersonGroup group, Portal portal,
            boolean includeGroupQueries) {
        if (includeGroupQueries) {
            for (Element groupQueryElement : XMLUtil.getChildren(groupQueriesElement, "groupQuery")) {
                Query query = findImportedQuery(groupQueryElement, portal);
                Org org = getGroupOrg(group, portal, XMLUtil.getTagValue(groupQueryElement, "subOrgCode"));
                OrgQuery orgQuery = queryService.findOrgQueryByOrgIdAndQueryId(org.getId(), query.getId());
                orgQuery = (orgQuery != null ? orgQuery : new OrgQuery());
                queryService.saveOrgQuery(orgQuery, org, query);

                GroupItem groupItem = groupService.findGroupItem(group, orgQuery);
                groupItem = (groupItem != null ? groupItem : new GroupItem());
                groupService.saveGroupItem(groupItem, group, orgQuery,
                        Boolean.parseBoolean(XMLUtil.getTagValue(groupQueryElement, "invisible")));
            }
        }
    }

    private Query findImportedQuery(Element groupQueryElement, Portal portal) {
        String name = XMLUtil.getTagValue(groupQueryElement, "name");
        String openapiServiceCode = XMLUtil.getTagValue(groupQueryElement, "openapiServiceCode");

        Producer tempProducer = getTempProducerFromXml(groupQueryElement, portal);
        Producer producer = producerService.findProducer(tempProducer, portal);

        String producerIdentifier = tempProducer.getProtocol() + " - "
                + tempProducer.getXroadIdentifier();
        if (producer == null) {
            throw new RuntimeException("Imported producer '" + producerIdentifier
                    + "' not found from DB during import. Input " + tempProducer
                    + " | " + XMLUtil.nodeToString(groupQueryElement));
        }
        Query query = queryService.findQueryByName(name, producer, openapiServiceCode);
        if (query == null) {
            String openapiServiceCodeStr = "";
            if (StringUtils.isNotBlank(openapiServiceCode)) {
                openapiServiceCodeStr = "(service code: " + openapiServiceCode + ")";
            }
            throw new RuntimeException("Imported query '" + name + "' " + openapiServiceCodeStr
                    + " not found from DB during import. Input producer " + producerIdentifier
                    + " | id=" + producer.getId()
                    + " | " + XMLUtil.nodeToString(groupQueryElement));
        }
        return query;
    }


    private void saveTopicNames(Element topicNamesElement, Topic topic) {
        for (Element nameElement : XMLUtil.getChildren(topicNamesElement, "name")) {
            String lang = nameElement.getAttribute("lang");
            TopicName name = topicService.findTopicName(topic, lang);
            name = (name != null ? name : new TopicName());
            topicService.saveTopicName(name, topic, lang, XMLUtil.getTagValue(nameElement, "description"));
        }
    }

    private void saveTopicQueries(Element topicQueriesElement, Topic topic, Portal portal) {
        for (Element topicQueryElement : XMLUtil.getChildren(topicQueriesElement, "topicQuery")) {
            Query query = findImportedQuery(topicQueryElement, portal);
            QueryTopic queryTopic = topicService.findQueryTopic(topic.getId(), query.getId());
            queryTopic = (queryTopic != null ? queryTopic : new QueryTopic());
            topicService.saveQueryTopic(queryTopic, query, topic);
        }
    }

    private void saveServiceXroadInstances(Element serviceXroadInstancesElement, Portal portal) {
        if (serviceXroadInstancesElement != null) {
            ArrayList<Element> xroadInstanceElements =
                    XMLUtil.getChildren(serviceXroadInstancesElement, "xroadInstance");
            for (Element xroadInstanceElement : xroadInstanceElements) {
                String code = XMLUtil.getTagValue(xroadInstanceElement, "code");
                String inUseStr = XMLUtil.getTagValue(xroadInstanceElement, "inUse");
                Boolean inUse = inUseStr != null && inUseStr.equals("true");
                String selectedStr = XMLUtil.getTagValue(xroadInstanceElement, "selected");
                Boolean selected = selectedStr != null && selectedStr.equals("true");
                XroadInstance xroadInstance = new XroadInstance();
                xroadInstance.setPortal(portal);
                xroadInstance.setCode(code);
                xroadInstance.setInUse(inUse);
                xroadInstance.setSelected(selected);
                xroadInstanceService.persistXroadInstance(xroadInstance);
            }
        } else { // no service X-Road instances defined, take it from client
            XroadInstance xroadInstance = new XroadInstance();
            xroadInstance.setPortal(portal);
            xroadInstance.setCode(portal.getClientXroadInstance());
            xroadInstance.setInUse(true);
            xroadInstance.setSelected(true);
            xroadInstanceService.persistXroadInstance(xroadInstance);
            
        }
    }
    
    /**
     * Get group's org with regard to portal and subOrgCode.<br/>
     * If portal is universal and subOrgCode is not null, then returns group's org's subOrg with given code. Else
     * returns group's org
     * 
     * @param group
     * @param subOrgCode
     * @return
     */
    private Org getGroupOrg(PersonGroup group, Portal portal, String subOrgCode) {
        Org org = group.getOrgId();
        boolean universal = portal.getMispType() == Const.MISP_TYPE_UNIVERSAL
                || portal.getMispType() == Const.MISP_TYPE_ORGANISATION;
        if (universal && subOrgCode != null) {
            org = orgService.findSubOrg(org, subOrgCode);
        }
        return org;
    }

    /**
     * @param orgServiceNew the orgService to set
     */
    public void setOrgService(OrgService orgServiceNew) {
        this.orgService = orgServiceNew;
    }

    /**
     * @param userServiceNew the userService to set
     */
    public void setUserService(UserService userServiceNew) {
        this.userService = userServiceNew;
    }

    /**
     * @param groupServiceNew the groupService to set
     */
    public void setGroupService(GroupService groupServiceNew) {
        this.groupService = groupServiceNew;
    }

    /**
     * @param topicServiceNew the topicService to set
     */
    public void setTopicService(TopicService topicServiceNew) {
        this.topicService = topicServiceNew;
    }

    /**
     * @param producerServiceNew the producerService to set
     */
    public void setProducerService(ProducerService producerServiceNew) {
        this.producerService = producerServiceNew;
    }

    /**
     * @param queryServiceNew the queryService to set
     */
    public void setQueryService(QueryService queryServiceNew) {
        this.queryService = queryServiceNew;
    }

    /**
     * @param portalServiceNew the portalService to set
     */
    public void setPortalService(PortalService portalServiceNew) {
        this.portalService = portalServiceNew;
    }

    /**
     * @param queryExportImportServiceNew the queryExportImportService to set
     */
    public void setQueryExportImportService(QueryExportImportService queryExportImportServiceNew) {
        this.queryExportImportService = queryExportImportServiceNew;
    }
    
    
    /**
     * @param xroadInstanceServiceNew the xroadInstanceService to set
     */
    public void setXroadInstanceService(XroadInstanceService xroadInstanceServiceNew) {
        this.xroadInstanceService = xroadInstanceServiceNew;
    }

    /**
     * This class is for providing input data for {@link ExportImportService} methods
     * @author kristjan.kiolein
     */
    private class GetElementInput {
        
        
        private Document doc;
        private String ns;
        private Org org;
        private boolean includeTopics;
        private boolean includeSubOrgsAndGroups;
        private boolean includeGroupPersons;
        private boolean includeGroupQueries;
        private Org chosenSubOrg;
        private Portal portal;
        private HashSet<Person> persons;
        
        private PersonGroup personGroup;
    }
}
