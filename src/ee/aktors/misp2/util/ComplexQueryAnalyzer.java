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

package ee.aktors.misp2.util;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

import javax.xml.namespace.NamespaceContext;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPMessage;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.Attributes;
import org.xml.sax.ContentHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;

import ee.aktors.misp2.util.Const.XROAD_VERSION;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.CommonXRoadSOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad4SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad5SOAPMessageBuilder;
import ee.aktors.misp2.util.xroad.soap.XRoad6SOAPMessageBuilder;

/**
 * <p>
 * Parses XForms from string and extracts X-Road request SOAP messages. Then
 * extracts X-Road service data from those messages.
 * </p>
 * <p>
 * #toString() method creates a string containing comma separated list of all
 * found service descriptors. Tree alternative methods are provided:
 * </p>
 * <p>
 * 1) {@link #parseWithSax()} - parses service names from XForms with SAX
 * streamline XML processing. Faster than 2). Processing is namespace aware and
 * handles namespaces correctly. Recommended choice.
 * </p>
 * <p>
 * 2) {@link #parseWithDom()} - parses service names from XForms with DOM XML
 * processing. 3-4 times slower than 1). Processing is namespace aware and
 * handles namespaces correctly.
 * </p>
 * <p>
 * 3) {@link #parseWithStringProcessing()} - parses service names from XForms
 * with String processing. By far, the fastest (tens of times faster than the
 * others). Processing does <b>NOT</b> handle namespaces correcly for many
 * possible use-cases, that's why it is not recommended.
 * </p>
 * <p>
 * If incoming portal X-Road version is 6, only v6 SOAP headers are extracted.
 * If X-Road version is earlier, various earlier service definitions are
 * considered (but not v6).
 * </p>
 * <p>
 * Usage:
 * </p>
 * 
 * <pre>
 * ComplexQueryAnalyzer ComplexQueryAnalyzer = new ComplexQueryAnalyzer(xforms, XROAD_VERSION.V6);
 * ComplexQueryAnalyzer.parse(config);
 * String subQueries = ComplexQueryAnalyzer.toString()
 * </pre>
 * 
 * @author sander.kallo
 *
 */
public class ComplexQueryAnalyzer {

    private static Logger logger = LogManager.getLogger(ComplexQueryAnalyzer.class);
    private XMLReader parser;
    private String xforms;
    private List<String> subQueryNames;
    private XROAD_VERSION xroadVersion;

    /**
     * Initialize parser, XROAD_VERSION.V6
     * 
     * @param xforms XForms entity
     * @param xroadVersion X-Road version
     */
    public ComplexQueryAnalyzer(String xforms, XROAD_VERSION xroadVersion) {
        this.xforms = xforms;
        this.xroadVersion = xroadVersion;
        this.subQueryNames = new ArrayList<String>();
    }

    /**
     * Set parser type from config object
     * 
     * @param config
     *            configuration object
     */
    public void parse(Configuration config) {
        try {
            // this configuration key enables to select different parsing
            // method, values can be SAX, DOM and STR
            // probably not neededed, useful for development purposes
            String key = "complex_service.subquery_extraction_method";
            String value = "";

            // only set value if the conf value is not null, otherwise default
            // "" is left
            if (config != null && config.containsKey(key) && config.getString(key) != null) {
                value = config.getString(key);
            }

            // enable options to configure DOM or STR parser
            if (value.equals("DOM")) {
                parseWithDom();
            } else if (value.equals("STR")) {
                parseWithStringProcessing();
            } else { // default is SAX
                parseWithSax();
            }
        } catch (IOException | SAXException | XPathExpressionException | XMLUtilException | DataExchangeException
                | SOAPException e) {
            logger.error("Failed to extract X-Road v" + XROAD_VERSION.V6.getIndex() + " subqueries from XForms", e);
            logger.trace(xforms);
        }
    }

    /**
     * @return unique xforms subquery service names as list of comma-separated
     * entities. Actually, separator is ', ' so that the result is
     * human-readable
     */
    public String toString() {
        if (subQueryNames.size() == 0)
            return null;
        Set<String> uniqueSubQueryNames = new LinkedHashSet<String>();
        uniqueSubQueryNames.addAll(subQueryNames);
        return StringUtils.join(uniqueSubQueryNames, Const.SUB_QUERY_NAME_SEPARATOR);
    }

    /**
     * @param subQueryNames sub-query names as string
     * @return list of sub-query names
     */
    public static List<String> subQueryNamesToList(String subQueryNames) {
        if (subQueryNames == null)
            return null;
        logger.trace("Converting the following subqueries to list: " + subQueryNames);
        return Arrays.asList(subQueryNames.split(Pattern.quote(Const.SUB_QUERY_NAME_SEPARATOR)));
    }

    /**
     * @return sub-query names as list
     */
    public List<String> getSubQueryNames() {
        return subQueryNames;
    }

    protected void parseWithDom()
            throws XMLUtilException, XPathExpressionException, DataExchangeException, SOAPException {
        subQueryNames.clear();
        Date d0 = new Date();
        Document doc = XMLUtil.convertXMLToDocument(xforms);
        XPathFactory xpFactory = XPathFactory.newInstance();
        XPath xpath = xpFactory.newXPath();
        XFormsNamespaceContext namespaceContext = new XFormsNamespaceContext();
        xpath.setNamespaceContext(namespaceContext);
        XPathExpression soapMessageExpr = xpath
                .compile("xhtml:html/xhtml:head/xforms:model/xforms:instance/SOAP-ENV:Envelope");
        NodeList soapMessages = (NodeList) soapMessageExpr.evaluate(doc, XPathConstants.NODESET);
        for (int i = 0; i < soapMessages.getLength(); i++) {
            Element element = (Element) soapMessages.item(i);
            SOAPMessage soapMessage = XRoadUtil.convertNodeToSOAPMessage(doc, element);
            CommonXRoadSOAPMessageBuilder builder = XRoadUtil.getXRoadSOAPMessageBuilder(soapMessage,
                    xroadVersion == XROAD_VERSION.V6);
            if (builder.hasService()) {
                subQueryNames.add(builder.getServiceSummary());
            }
        }
        logger.debug("Complex service subquery extraction done. Parsing with DOM time "
                + (new Date().getTime() - d0.getTime()) + " ms");
    }

    /**
     * Parse services out of {@link #xforms} with SAX streamline parser
     * 
     * @throws IOException
     * @throws SAXException
     */
    protected void parseWithSax() throws IOException, SAXException {
        subQueryNames.clear();
        // specify the SAXParser
        Date d0 = new Date();
        parser = XMLReaderFactory.createXMLReader("com.sun.org.apache.xerces.internal.parsers.SAXParser");
        ContentHandler complexServiceHandler = new ComplexServiceHandler(xroadVersion == XROAD_VERSION.V6,
                subQueryNames);
        parser.setContentHandler(complexServiceHandler);
        InputStream in = new ByteArrayInputStream(xforms.getBytes(StandardCharsets.UTF_8));
        InputSource source = new InputSource(in);
        parser.parse(source);
        in.close();
        logger.debug("Complex service subquery extraction done. Parser parsing with SAX time "
                + (new Date().getTime() - d0.getTime()) + " ms");
    }

    /**
     * Logic moved to current method and adapted from
     * GroupAction#groupEditRights(). The code is very fast but does not cover
     * all special cases needed to parse service names out of XML. It does not
     * work when 1) X-Road namespace is declared withing SOAP-ENV:Envelope with
     * another prefix (it only uses the first prefix it finds for current
     * namespace) 2) namespace is not declared in the x-forms root element, but
     * locally, this local namespace is counted as global 3) service element has
     * an attribute declared or even space after start tag name, for example
     * &lt;xtee:nimi >aktorstest.isikuteList.v1&lt;/xtee:nimi>
     * &gt;xtee:nimi xsi:type="xsd:string"&gt;aktorstest.isikuteList.v1&lt;/xtee:nimi&gt; 4)
     * X-Road namespace is declared without prefix xmlns=".." Point 3 could be
     * easily fixed with regex, fixig the other failure points is complicated,
     * you basically have to implement your own XML processing framework which
     * does not make sense. Instead two other methods are created that fix all
     * listed failure points of this method. Those alternatives are
     * #parseWithSax() and #parseWithDom(). SAX one is ~3-4 times faster than
     * DOM one, but still 20 times slower than current method.
     */
    protected void parseWithStringProcessing() {
        subQueryNames.clear();
        Date d0 = new Date();
        List<String[]> namespaces = new ArrayList<String[]>(); // list stringide
                                                                // arraydest.
                                                                // Iga stringide
                                                                // array koosneb
                                                                // kahest
                                                                // liikmest,
                                                                // millest
                                                                // esimene on
                                                                // namespace tag
                                                                // ja teine on
                                                                // elemendi nimi
        if (xroadVersion != XROAD_VERSION.V6) {
            fillNamespacePrefixexWithStringProcessing(namespaces, Const.XROAD_VERSION.V4.getDefaultNamespace(),
                    XRoad4SOAPMessageBuilder.SERVICE_TAG_NAME);
            fillNamespacePrefixexWithStringProcessing(namespaces, Const.XROAD_VERSION.V5.getDefaultNamespace(),
                    XRoad5SOAPMessageBuilder.SERVICE_TAG_NAME);
            fillNamespacePrefixexWithStringProcessing(namespaces, "http://x-rd.net/xsd/xroad.xsd",
                    XRoad5SOAPMessageBuilder.SERVICE_TAG_NAME); // some
                                                                // temporary
                                                                // namespace
                                                                // used long
                                                                // time ago
        } else {
            fillNamespacePrefixexWithStringProcessing(namespaces, Const.XROAD_VERSION.V6.getDefaultNamespace(),
                    XRoad6SOAPMessageBuilder.SERVICE_TAG_NAME); // some
                                                                // temporary
                                                                // namespace
                                                                // used long
                                                                // time ago
        }

        for (int i = 0; i < namespaces.size(); i++) {
            String[] namespace = namespaces.get(i);
            String tag = namespace[0] + ":" + namespace[1];
            // NB! not defining the end bracket '>' for start tag: that enables
            // including attributes, for example in v6 iden:objectType="SERVICE"
            logger.trace("Looking for text within " + "<" + tag + "..attrs..>" + " and " + "</" + tag + ">");
            String[] array = getTextBetweenTags(xforms, tag);
            logger.trace("Found " + namespaces.size() + " entries");
            subQueryNames.addAll(Arrays.asList(array));
        }

        if (xroadVersion == XROAD_VERSION.V6) {
            for (int i = 0; i < subQueryNames.size(); i++) {
                String subQueryName = subQueryNames.get(i);
                String[] serviceIdentifiersWithEmptyFields = StringUtils.substringsBetween(subQueryName, "<", "</");
                // serviceIdentifiersWithEmptyFields may be start tags with
                // text, like 'iden:memberClass>COM', but it will never end with
                // a tag
                XRoadV6ServiceContainer serviceContainer = new XRoadV6ServiceContainer();
                for (int j = 0; j < serviceIdentifiersWithEmptyFields.length; j++) {
                    String serviceIdentifier = serviceIdentifiersWithEmptyFields[j];
                    // if identifier is empty, continue
                    if (serviceIdentifier == null || serviceIdentifier.trim().isEmpty())
                        continue;
                    // get rid of start tag if start tag exists
                    int startTagEnd = serviceIdentifier.lastIndexOf(">");
                    if (startTagEnd >= 0) {
                        int localNameStart = serviceIdentifier.indexOf(":") + 1;
                        String name = serviceIdentifier.substring(localNameStart, startTagEnd);
                        String value = serviceIdentifier.substring(startTagEnd + 1);
                        serviceContainer.set(name, value);
                    }
                }

                if (serviceContainer.isFilled()) {
                    subQueryNames.set(i, serviceContainer.toString());
                }
            }
        }
        logger.debug("Complex service subquery extraction done. Parser parsing with String processing time "
                + (new Date().getTime() - d0.getTime()) + " ms");
    }

    private String[] getTextBetweenTags(String text, String tag) {
        String[] array = StringUtils.substringsBetween(text, "<" + tag, "</" + tag + ">");
        if (array == null)
            return new String[] {};
        for (int j = 0; j < array.length; j++) {
            String serviceName = array[j];
            if (serviceName.contains(">")) {
                serviceName = serviceName.substring(serviceName.indexOf(">") + 1);
                array[j] = serviceName;
            }
        }
        return array;
    }

    /**
     * Used to populate X-Road v6 service identifiers and print them to a
     * summary.
     * 
     * @author sander.kallo
     *
     */
    private class XRoadV6ServiceContainer {
        private String xRoadInstance;
        private String memberClass;
        private String memberCode;
        private String subsystemCode;
        private String serviceCode;
        private String serviceVersion;

        public void set(String tagName, String value) {
            if (tagName == null)
                return;
            else if (tagName.equals(XRoad6SOAPMessageBuilder.XROAD_INSTANCE_TAG_NAME)) {
                xRoadInstance = value;
            } else if (tagName.equals(XRoad6SOAPMessageBuilder.MEMBER_CLASS_TAG_NAME)) {
                memberClass = value;
            } else if (tagName.equals(XRoad6SOAPMessageBuilder.MEMBER_CODE_TAG_NAME)) {
                memberCode = value;
            } else if (tagName.equals(XRoad6SOAPMessageBuilder.SUBSYSTEM_CODE_TAG_NAME)) {
                subsystemCode = value;
            } else if (tagName.equals(XRoad6SOAPMessageBuilder.SERVICE_CODE_TAG_NAME)) {
                serviceCode = value;
            } else if (tagName.equals(XRoad6SOAPMessageBuilder.SERVICE_VERSION_TAG_NAME)) {
                serviceVersion = value;
            }
        }

        public boolean isFilled() {
            return XRoadUtil.hasXRoadV6Service(xRoadInstance, memberClass, memberCode, subsystemCode, serviceCode,
                    serviceVersion);
        }

        public String toString() {
            return XRoadUtil.getXRoadV6ServiceSummary(xRoadInstance, memberClass, memberCode, subsystemCode,
                    serviceCode, serviceVersion);
        }
    }

    /**
     * SAX handler for {@link #parseWithSax()} method
     * 
     * @author sander.kallo
     *
     */
    private class ComplexServiceHandler extends DefaultHandler {
        private static final String SOAP_ENVELOPE_NS = "http://schemas.xmlsoap.org/soap/envelope/";
        private boolean inSoapEnvelope = false;
        private boolean inSoapHeader = false;
        private boolean inV6Service = false;
        private boolean inV5Service = false;
        private boolean inV6ServiceElement = false;
        private StringWriter stringWriter;
        private boolean xroadV6;
        private List<String> subQueryNames;
        private XRoadV6ServiceContainer xroadV6ServiceContainer;

        ComplexServiceHandler(boolean xroadV6, List<String> subQueryNames) {
            this.xroadV6 = xroadV6;
            this.subQueryNames = subQueryNames;
        }

        public void startElement(String namespaceUri, String localName, String qualifiedName, Attributes attrs)
                throws SAXException {
            if (!inSoapEnvelope && isSoapMessage(namespaceUri, localName)) {
                inSoapEnvelope = true;
            } else if (inSoapEnvelope && isSoapHeader(namespaceUri, localName)) {
                inSoapHeader = true;
            } else if (inSoapHeader && isV6Service(namespaceUri, localName)) {
                inV6Service = true;
                xroadV6ServiceContainer = new XRoadV6ServiceContainer();
            } else if (inSoapHeader && isV5Service(namespaceUri, localName)) {
                inV5Service = true;
                stringWriter = new StringWriter();
            } else if (inV6Service) {
                inV6ServiceElement = true;
                stringWriter = new StringWriter();
            }
        }

        public void endElement(String namespaceUri, String localName, String qualifiedName) throws SAXException {
            if (inSoapEnvelope && isSoapMessage(namespaceUri, localName)) {
                inSoapEnvelope = false;
            } else if (inSoapHeader && isSoapHeader(namespaceUri, localName)) {
                inSoapHeader = false;
            } else if (inV6Service && isV6Service(namespaceUri, localName)) {
                inV6Service = false;
                if (xroadV6ServiceContainer.isFilled()) {
                    subQueryNames.add(xroadV6ServiceContainer.toString());
                }
            } else if (inV5Service && isV5Service(namespaceUri, localName)) {
                inV5Service = false;
                String subQueryName = stringWriter.toString();
                if (!subQueryName.isEmpty()) {
                    subQueryNames.add(subQueryName);
                }
            } else if (inV6ServiceElement) {
                inV6ServiceElement = false;
                xroadV6ServiceContainer.set(localName, stringWriter.toString());
            }
        }

        private boolean isSoapMessage(String namespaceUri, String localName) {
            return localName.equals("Envelope") && namespaceUri != null && namespaceUri.equals(SOAP_ENVELOPE_NS);
        }

        private boolean isSoapHeader(String namespaceUri, String localName) {
            return localName.equals("Header") && namespaceUri != null && namespaceUri.equals(SOAP_ENVELOPE_NS);
        }

        private boolean isV6Service(String namespaceUri, String localName) {
            return localName.equals("service") && namespaceUri != null
                    && namespaceUri.equals(XROAD_VERSION.V6.getDefaultNamespace());
        }

        private boolean isV5Service(String namespaceUri, String localName) {
            return namespaceUri != null
                    && (localName.equals("nimi") && namespaceUri.equals(XROAD_VERSION.V4.getDefaultNamespace()) || // v4
                            localName.equals("service") // v5, namespace is not
                                                        // restricted (it is
                                                        // dynamic)
            );
        }

        public void characters(char[] ch, int start, int length) throws SAXException {
            if (!xroadV6 && inV5Service || xroadV6 && inV6Service && inV6ServiceElement) {
                for (int i = start; i < start + length; i++) {
                    stringWriter.append(ch[i]);
                }
            }
        }
    }

    /**
     * Fill namespaces List with namespace prefix and service name to be search
     * from xforms.
     * 
     * @param namespaces
     *            List to be filled with namespace prefixes and 'service' tag
     *            names
     * @param namespaceUri
     * @param serviceTagName
     */
    private void fillNamespacePrefixexWithStringProcessing(List<String[]> namespaces, String namespaceUri,
            String serviceTagName) {
        String ns = null;
        int index1, index2;

        index1 = xforms.indexOf("=\"" + namespaceUri + "\""); // ntx
                                                                // xmlns:xtee="http://x-tee.riik.ee/xsd/xtee.xsd"
                                                                // puhul saame
                                                                // namespaceks
                                                                // {xtee, nimi}
        if (index1 != -1) {
            index2 = xforms.lastIndexOf(":", index1);
            ns = xforms.substring(index2 + 1, index1);
            namespaces.add(new String[] {ns, serviceTagName});
        }
    }

    static class XFormsNamespaceContext implements NamespaceContext {
        @Override
        public String getNamespaceURI(String prefix) {
            if (prefix.equals("SOAP-ENV")) {
                return "http://schemas.xmlsoap.org/soap/envelope/";
            } else if (prefix.equals("xhtml")) {
                return "http://www.w3.org/1999/xhtml";
            } else if (prefix.equals("xforms")) {
                return "http://www.w3.org/2002/xforms";
            } else
                return null;
        }

        @Override
        public String getPrefix(String uri) {
            throw new UnsupportedOperationException();
        }

        @Override
        public Iterator<?> getPrefixes(String uri) {
            throw new UnsupportedOperationException();
        }
    }
}
