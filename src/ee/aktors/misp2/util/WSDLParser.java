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

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.TreeMap;

import javax.xml.XMLConstants;
import javax.xml.namespace.NamespaceContext;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import ee.aktors.misp2.action.exception.QueryException;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.ProducerName;
import ee.aktors.misp2.model.QueryName;
import ee.aktors.misp2.util.Const.XROAD_VERSION;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * WSDL parser
 */
public class WSDLParser {
    
    private static final Logger LOGGER = LogManager.getLogger(WSDLParser.class.getName());
    
    public URL wsdlUrl;
    private Document doc;
    private File file;
    private XPath xpath;
    private XPathFactory xpFactory;
    private String xroadNamespace;
    private XROAD_VERSION xroadVersion;

    /**
     * Initializes WSDLParser and sets given values
     * @param wsdlUri uri of wsdl to parse
     * @param xroadVersion version of x-road
     * @throws DataExchangeException when SOAP-Fault is found
     * (+ faultCode and faultString are embedded into the exception)
     * @throws QueryException if reading WSDL fails
     */
    public WSDLParser(String wsdlUri, XROAD_VERSION xroadVersion)
            throws DataExchangeException, QueryException {
        this.doc = null;
        this.wsdlUrl = XRoadUtil.getMetaServiceEndpointUrlWithTimeouts(wsdlUri);
        this.xroadVersion = xroadVersion;
        init();
    }

    /**
     * Initializes WSDLParser and sets given values
     * @param doc document to set
     * @param xroadVersion version of x-road
     * @throws DataExchangeException when SOAP-Fault is found
     * (+ faultCode and faultString are embedded into the exception)
     * @throws QueryException if reading WSDL fails
     */
    public WSDLParser(Document doc, XROAD_VERSION xroadVersion) throws DataExchangeException, QueryException {
        this.doc = doc;
        this.wsdlUrl = null;
        this.xroadVersion = xroadVersion;
        init();
    }

    /**
     * Initializes WSDLParser and sets given values
     * @param file file to set
     * @param xroadVersion version of x-road
     * @throws DataExchangeException when SOAP-Fault is found
     * (+ faultCode and faultString are embedded into the exception)
     * @throws QueryException if reading WSDL fails
     */
    public WSDLParser(File file, XROAD_VERSION xroadVersion) throws DataExchangeException, QueryException {
        this.file = file;
        this.doc = null;
        this.wsdlUrl = null;
        this.xroadVersion = xroadVersion;
        init();
    }

    /**
     * @throws DataExchangeException when SOAP-Fault is found
     * (+ faultCode and faultString are embedded into the exception)
     * @throws QueryException if reading WSDL fails
     */
    public void init() throws DataExchangeException, QueryException {
        if (this.doc == null && (wsdlUrl != null || file != null)) {
            try {
                DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance(); // factory + builder + doc =>
                                                                                       // parse XML
                factory.setNamespaceAware(true);
                DocumentBuilder builder = factory.newDocumentBuilder();
                LOGGER.debug("Parsing WSDL from URI: " + wsdlUrl);
                if(wsdlUrl != null) {
                    doc = builder.parse(wsdlUrl.openConnection().getInputStream(), StandardCharsets.UTF_8.name());
                } else if(file != null) {
                    doc = builder.parse(file);
                }
                // xpath init
            } catch (ParserConfigurationException | SAXException | IOException e) {
                throw new QueryException(QueryException.Type.WSDL_READING_FAILED, "Reading WSDL from URL " + wsdlUrl
                        + " failed", e);
            }
        }
        xpFactory = XPathFactory.newInstance();
        xpath = xpFactory.newXPath();
        PersonalNamespaceContext namespaceContext = new PersonalNamespaceContext();
        xpath.setNamespaceContext(namespaceContext);
        if (xroadVersion == XROAD_VERSION.V6) {
            xroadNamespace = xroadVersion.getDefaultNamespace();
        } else {
            try {
                xroadNamespace = getXRoadNamespaceFromWsdlV4And5();
                LOGGER.debug("Extracted X-Road namespace (v4 or v5): " + xroadNamespace);
            } catch (Exception e) {
                throw new QueryException(QueryException.Type.WSDL_XROAD_NAMESPACE_NOT_FOUND,
                        "Failed to extract X-Road namespace from WSDL", e);
            }
            if (xroadNamespace == null) {
                throw new QueryException(QueryException.Type.WSDL_XROAD_NAMESPACE_NOT_FOUND,
                        "Did not find X-Road namespace from WSDL", null);
            }
        }
        namespaceContext.setXRoadNamespace(xroadNamespace);

        try {
            XRoadUtil.checkFault(doc, wsdlUrl != null ? wsdlUrl.toString() : "unknown URL", xpath);
        } catch (DataExchangeException e) {
            throw e;
            // throw new QueryException(QueryException.Type.WSDL_HAS_SOAP_FAULT, "WSDL validation failed", e);
        }
    }

    /**
     * @return X-Road namespace
     */
    public String getXRoadNamespace() {
        return xroadNamespace;
    }

    private String getXRoadNamespaceFromWsdlV4And5() throws XPathExpressionException {
        XPathExpression messageAttributeExpr = xpath.compile("/wsdl:definitions/wsdl:service/wsdl:port/*");
        NodeList portChildNodes = (NodeList) messageAttributeExpr.evaluate(doc, XPathConstants.NODESET);
        for (int i = 0; i < portChildNodes.getLength(); i++) {
            Node node = portChildNodes.item(i);
            if (node instanceof Element) {
                Element element = (Element) node;
                String name = element.getLocalName();
                String namespace = element.getNamespaceURI();

                if (namespace != null && (name.equals("title") || name.equals("address"))
                        && !namespace.equals("http://schemas.xmlsoap.org/wsdl/soap/")) {
                    return namespace;
                }
            }
        }
        return null;
    }

    /**
     * @return doc
     */
    public Document getDoc() {
        return doc;
    }

    /**
     * @return false
     */
    public Boolean validateWsdl() {
        return false;
    }

    /**
     * @return list of operations
     */
    public List<String> getOperations() {
        List<String> operations = new ArrayList<String>();
        try {
            XPathExpression expr = xpath.compile("//wsdl:binding/wsdl:operation[@name]");
            NodeList nodes = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);
            for (int i = 0; i < nodes.getLength(); i++) {
                String serviceName = nodes.item(i).getAttributes().getNamedItem("name").getTextContent();
                String version = getVersion(serviceName);
                if (!(version.equals("")))
                    serviceName += "." + version;
                operations.add(serviceName);
            }
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), e);
        }
        return operations;
    }

    /**
     * @param operationName operation name in WSDL for which namespace is found for
     * @return  operation request namespace
     */
    public String getOperationRequestNamespace(String operationName) {
        String namespaceUri = null;
        try {
            Long t0 = new Date().getTime();
            XPathExpression messageAttributeExpr = xpath
                    .compile("/wsdl:definitions/wsdl:portType/wsdl:operation[@name='" + operationName
                            + "']/wsdl:input/@message");
            Attr messageAttribute = (Attr) messageAttributeExpr.evaluate(doc, XPathConstants.NODE);

            String messageValue = messageAttribute.getValue();
            // strip namespace prefix if needed
            if (messageValue.contains(":"))
                messageValue = messageValue.split(":")[1];
            // logger.debug("Found message attribute " + messageValue);
            Long t1 = new Date().getTime();
            XPathExpression messageElementExpr = xpath.compile("/wsdl:definitions/wsdl:message[@name='" + messageValue
                    + "']/wsdl:part/@element");
            Attr elementAttribute = (Attr) messageElementExpr.evaluate(doc, XPathConstants.NODE);
            String requestElementName = elementAttribute.getValue();

            if (requestElementName.contains(":")) {
                String namespacePrefix = requestElementName.split(":")[0];
                namespaceUri = elementAttribute.lookupNamespaceURI(namespacePrefix);
                // logger.debug("namespaceUri " + namespaceUri );
            }
            Long t2 = new Date().getTime();
            LOGGER.debug("Operation request namespace retrieval took: total " + (t2 - t0) + " ms , step one "
                    + (t1 - t0) + " ms , step two " + (t2 - t1) + " ms ");
            return namespaceUri;
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), e);
        }
        throw new RuntimeException("Operation '" + operationName + "' namespace was not found from WSDL");
    }

    /**
     * @param producer producer
     * @param lang language
     * @return list of producer names
     */
    public List<ProducerName> getProducerDescriptions(Producer producer, String lang) {
        List<ProducerName> producerNames = new ArrayList<ProducerName>();
        try {
            XPathExpression findXrdAddress = xpath.compile("/wsdl:definitions/wsdl:service//"
                    + Const.XROAD_NS_PREFIX_OLD + ":address");
            NodeList addressNodes = (NodeList) findXrdAddress.evaluate(doc, XPathConstants.NODESET);
            if (addressNodes == null || addressNodes.getLength() == 0)
                addressNodes = (NodeList) xpath.compile(
                        "/wsdl:definitions/wsdl:service//" + Const.XROAD_NS_PREFIX + ":address").evaluate(doc,
                        XPathConstants.NODESET);
            if (addressNodes != null && addressNodes.getLength() > 0) {
                XPathExpression expr = xpath.compile("/wsdl:definitions/wsdl:service//" + Const.XROAD_NS_PREFIX_OLD
                        + ":title");
                NodeList nodes = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);
                if (nodes.getLength() == 0)
                    nodes = (NodeList) xpath.compile(
                            "/wsdl:definitions/wsdl:service//" + Const.XROAD_NS_PREFIX + ":title").evaluate(doc,
                            XPathConstants.NODESET);
                for (int i = 0; i < nodes.getLength(); i++) {
                    Element descs = (Element) nodes.item(i); // get the first one that includes title
                    NodeList desc = descs.getChildNodes();
                    String descript = desc.item(0).getNodeValue().toString(); // get value of title
                    String wsdlLang = descs.getAttribute("xml:lang");
                    if (wsdlLang == null)
                        wsdlLang = lang;
                    producerNames.add(initProducerName(descript, wsdlLang, producer));
                }
            } else {
                LOGGER.warn("Cannot find wsdl xrd:address or xtee:address element");
            }

        } catch (Exception e) {
            LOGGER.error(e.getMessage(), e);
        }
        return producerNames;
    }

    /**
     * @param lang language
     * @param operationName optional parameter for getting query description for only given operation.
     *      null means no filter.
     * @return map of queries
     */
    public TreeMap<String, List<QueryName>> getQueryDescriptions(String lang, String operationName) {
        TreeMap<String, List<QueryName>> queryWithDescriptions = new TreeMap<String, List<QueryName>>();
        try {
            XPathExpression exprNames = xpath.compile("/wsdl:definitions/wsdl:portType/wsdl:operation[@name]");
            NodeList nodes = (NodeList) exprNames.evaluate(doc, XPathConstants.NODESET);
            LOGGER.debug("WSDL operations amount: " + nodes.getLength());
            for (int i = 0; i < nodes.getLength(); i++) {
                String serviceName = nodes.item(i).getAttributes().getNamedItem("name").getTextContent();
                // if we have service Name defined, then only find description for that service, needed for X-Road v6
                if (serviceName == null || operationName != null && !operationName.equals(serviceName))
                    continue;
                List<QueryName> queryNames = new ArrayList<QueryName>();
                // FIXME: v4, should be working without commented out lines, but that has not been tested
                // XPathExpression exprTitles =
                // xpath.compile("/wsdl:definitions/wsdl:portType/wsdl:operation[@name='"+serviceName+"']//"
                //+Const.XROAD_NS_PREFIX_OLD+":title");
                String xpathString = "/wsdl:definitions/wsdl:portType/wsdl:operation[@name='" + serviceName + "']//"
                        + Const.XROAD_NS_PREFIX + ":title";
                NodeList nodesTitles = (NodeList) xpath.compile(xpathString).evaluate(doc, XPathConstants.NODESET);
                // if(nodesTitles.getLength()==0)
                // nodesTitles = (NodeList) exprTitles.evaluate(doc, XPathConstants.NODESET);
                if (nodesTitles.getLength() > 0) {
                    for (int j = 0; j < nodesTitles.getLength(); j++) {
                        NodeList desc = nodesTitles.item(j).getChildNodes();
                        String descript = desc.item(0) != null ? desc.item(0).getNodeValue() : ""; // get value of title
                        LOGGER.debug("Found node " + j + " descript " + descript);
                        String wsdlLang = (String) ((Element) nodesTitles.item(j)).getAttribute("xml:lang");
                        if (wsdlLang == null || wsdlLang.equals(""))
                            wsdlLang = lang;
                        String note = getServiceNote(serviceName, wsdlLang);
                        queryNames.add(initQueryName(descript, note, wsdlLang));
                    }
                    String version = getVersion(serviceName);
                    if (!version.equals(""))
                        serviceName += "." + version;
                    queryWithDescriptions.put(serviceName, queryNames);
                } else {
                    LOGGER.debug("Did not find a single node for" + xpathString);
                }
            }
        } catch (XPathExpressionException e) {
            LOGGER.error(e.getMessage(), e);
        }

        return queryWithDescriptions;
    }

    /**
     * @param operation operation wich version to get
     * @return version of the operation
     */
    public String getVersion(String operation) {
        String version = "";
        try {
            XPathExpression expr = xpath.compile("//wsdl:operation[@name='" + operation + "']//"
                    + Const.XROAD_NS_PREFIX_OLD + ":version");
            NodeList nodes = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);
            if (nodes.getLength() == 0)
                nodes = (NodeList) xpath.compile(
                        "//wsdl:operation[@name='" + operation + "']//" + Const.XROAD_NS_PREFIX + ":version").evaluate(
                        doc, XPathConstants.NODESET);
            for (int i = 0; i < nodes.getLength(); i++) {
                version = ((Element) nodes.item(i)).getChildNodes().item(0).getNodeValue().toString();
            }
        } catch (XPathExpressionException e) {
            LOGGER.error(e.getMessage(), e);
        }
        return version.trim();
    }

    /**
     * @param operation operation
     * @param lang language
     * @return note of service
     * @throws XPathExpressionException can throw
     */
    public String getServiceNote(String operation, String lang) throws XPathExpressionException {
        String note = "";
        try {
            XPathExpression exprNotes = xpath.compile("//wsdl:operation[@name='" + operation + "']//"
                    + Const.XROAD_NS_PREFIX + ":notes[@xml:lang='" + lang + "']");
            XPathExpression exprNotesOld = xpath.compile("//wsdl:operation[@name='" + operation + "']//"
                    + Const.XROAD_NS_PREFIX_OLD + ":notes[@xml:lang='" + lang + "']");
            NodeList nodesNotes = (NodeList) exprNotes.evaluate(doc, XPathConstants.NODESET);
            if (nodesNotes != null && nodesNotes.getLength() == 0)
                nodesNotes = (NodeList) exprNotesOld.evaluate(doc, XPathConstants.NODESET);
            if (nodesNotes != null && nodesNotes.getLength() > 0
                    && nodesNotes.item(0).getChildNodes().item(0) != null) {
                note = nodesNotes.item(0).getChildNodes().item(0).getNodeValue().toString(); // get value of note
                return note;
            }
        } catch (XPathExpressionException e) {
            LOGGER.error(e.getMessage(), e);
        }
        return note.trim();
    }

    /**
     * @param description description to set
     * @param note note to set
     * @param wsdlLang language of wsdl to set
     * @return queryName
     */
    public QueryName initQueryName(String description, String note, String wsdlLang) {
        QueryName temp = new QueryName();
        temp.setQueryNote(note);
        temp.setDescription(description);
        temp.setLang(wsdlLang);
        return temp;
    }

    /**
     * @param description description to set
     * @param lang language to set
     * @param producer producer to set
     * @return initiated producer name
     */
    public ProducerName initProducerName(String description, String lang, Producer producer) {
        ProducerName temp = new ProducerName();
        temp.setDescription(description);
        temp.setLang(lang);
        temp.setProducer(producer);
        return temp;
    }

    private class PersonalNamespaceContext implements NamespaceContext {

        private String xroadNamespace;

        PersonalNamespaceContext() {
            xroadNamespace = null;
        }

        public void setXRoadNamespace(String xroadNamespaceIn) {
            this.xroadNamespace = xroadNamespaceIn;
        }

        public String getNamespaceURI(String prefix) {
            if (prefix == null)
                throw new NullPointerException("Null prefix");
            else if ("".equals(prefix))
                return "http://schemas.xmlsoap.org/wsdl/";
            else if (Const.XROAD_NS_PREFIX_OLD.equals(prefix))
                return XROAD_VERSION.V4.getDefaultNamespace();
            else if (Const.XROAD_NS_PREFIX.equals(prefix))
                return xroadNamespace;
            else if ("xsd".equals(prefix))
                return "http://www.w3.org/2001/XMLSchema";
            else if ("xml".equals(prefix))
                return "http://www.w3.org/XML/1998/namespace";
            else if ("wsdl".equals(prefix))
                return "http://schemas.xmlsoap.org/wsdl/";
            else if ("SOAP-ENV".equals(prefix))
                return "http://schemas.xmlsoap.org/soap/envelope/";
            return XMLConstants.NULL_NS_URI;
        }

        // This method isn't necessary for XPath processing.
        @Override
        public String getPrefix(String uri) {
            throw new UnsupportedOperationException();
        }

        // This method isn't necessary for XPath processing either.
        @Override
        public Iterator<?> getPrefixes(String uri) {
            throw new UnsupportedOperationException();
        }
    }
}
