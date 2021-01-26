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

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Iterator;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.soap.SOAPElement;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Text;
import org.w3c.dom.bootstrap.DOMImplementationRegistry;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSOutput;
import org.w3c.dom.ls.LSSerializer;
import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import net.sf.saxon.TransformerFactoryImpl;

/**
 */
public final class XMLUtil {
    private XMLUtil() { }
    /**
     * Defines default DocumentBuilderFactory for usage in building Document in order to avoid problems with multiple
     * DocumentBuilderFactory instances in classpath
     */
    private static final String DOCUMENT_BUILDER_FACTORY_CLASS_NAME =
            "com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderFactoryImpl";
    private static Logger logger = LogManager.getLogger(XMLUtil.class);

    /**
     * Get empty Document, ready for appending elements
     * 
     * @return document
     * @throws XMLUtilException if parsing fails
     */
    public static Document getEmptyDocument() throws XMLUtilException {
        try {
            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance(DOCUMENT_BUILDER_FACTORY_CLASS_NAME,
                    null);
            docFactory.setNamespaceAware(true);
            DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
            Document doc = docBuilder.newDocument();
            return doc;
        } catch (ParserConfigurationException e) {
            throw new XMLUtilException(e);
        }
    }

    /**
     * Convert Document doc to indented String representing it's XML
     * @param doc doc to convert
     * @return xml
     * @throws XMLUtilException if class not fount, illegal access or initiation fails
     */
    public static String convertDocumentToXML(Document doc) throws XMLUtilException {
        try {
            DOMImplementationRegistry registry = DOMImplementationRegistry.newInstance();
            DOMImplementationLS implLS = (DOMImplementationLS) registry.getDOMImplementation("LS");
            LSSerializer lsSerializer = implLS.createLSSerializer();
            lsSerializer.getDomConfig().setParameter("format-pretty-print", true);

            LSOutput lsOutput = implLS.createLSOutput();
            lsOutput.setEncoding("UTF-8");
            Writer stringWriter = new StringWriter();
            lsOutput.setCharacterStream(stringWriter);
            lsSerializer.write(doc, lsOutput);
            String result = stringWriter.toString();

            return result;
        } catch (ClassNotFoundException e) {
            throw new XMLUtilException(e);
        } catch (InstantiationException e) {
            throw new XMLUtilException(e);
        } catch (IllegalAccessException e) {
            throw new XMLUtilException(e);
        }
    }

    /**
     * Convert UTF-8 encoded String xml representing XML to Document
     * 
     * @param xml xml
     * @return document
     * @throws XMLUtilException if class not fount, illegal access or initiation fails
     */
    public static Document convertXMLToDocument(String xml) throws XMLUtilException {
        try {
            InputStream inputStream = new ByteArrayInputStream(xml.getBytes("UTF-8"));
            return convertInputStreamToDocument(inputStream);
        } catch (UnsupportedEncodingException e) {
            throw new XMLUtilException(e);
        }
    }

    /**
     * Convert input stream representing XML to Document
     * 
     * @param inputStream XML input stream
     * @return document
     * @throws XMLUtilException if class not fount, illegal access or initiation fails
     */
    public static Document convertInputStreamToDocument(InputStream inputStream) throws XMLUtilException {
        try {
            DocumentBuilderFactory docFactory =
                    DocumentBuilderFactory.newInstance(DOCUMENT_BUILDER_FACTORY_CLASS_NAME, null);
            docFactory.setNamespaceAware(true);
            DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
            Document doc = docBuilder.parse(inputStream);
            doc.getDocumentElement().normalize();
            return doc;
        } catch (ParserConfigurationException e) {
            throw new XMLUtilException(e);
        } catch (SAXException e) {
            throw new XMLUtilException(e);
        } catch (IOException e) {
            throw new XMLUtilException(e);
        }
    }
    /**
     * Validate xml document against xsd represented by schemaStream
     * 
     * @param doc document
     * @param schemaStream schema stream
     * @throws SAXException If a SAX error occurs during parsing.
     * @throws IOException If the validator is processing a javax.xml.transform.sax.SAXSource and the underlying
     * org.xml.sax.XMLReader throws an IOException.
     */
    public static void validateDocument(Document doc, InputStream schemaStream) throws SAXException, IOException {
        DOMSource source = new DOMSource(doc);
        SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
        Schema schema = schemaFactory.newSchema(new StreamSource(schemaStream));
        Validator validator = schema.newValidator();
        validator.validate(source);
    }

    /**
     * Validate xml document against xsd represented by schemaStream,
     * while ignoring errors about missing attributes.<br/>
     * Needed because for some reason validator validates attributes incorrectly (complains about missing attribute,
     * although it exists), while other validators (online, Notepad ++, etc) validate correctly
     * 
     * @param doc document
     * @param schemaStream schema stream
     * @throws SAXException If a SAX error occurs during parsing.
     * @throws IOException If the validator is processing a javax.xml.transform.sax.SAXSource and the underlying
     * org.xml.sax.XMLReader throws an IOException.
     */
    public static void validateDocumentIgnoringMissingAttributes(Document doc, InputStream schemaStream)
            throws SAXException, IOException {
        SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
        Schema schema = schemaFactory.newSchema(new StreamSource(schemaStream));
        Validator validator = schema.newValidator();
        validator.setErrorHandler(new ErrorHandler() {
            @Override
            public void warning(SAXParseException ex) throws SAXException {
                throw ex;
            }

            @Override
            public void fatalError(SAXParseException ex) throws SAXException {
                throw ex;
            }

            @Override
            public void error(SAXParseException ex) throws SAXException {
                String message = ex.getMessage().replaceAll("'.*?'", "");
                // remove strings between ' symbols, with those symbols.
                // Ignore error about attribute missing in element. We do it because validator has some problems with
                // namespaces. Online validators don't have these problems.
                if (message.equals("cvc-complex-type.3.2.2: Attribute  is not allowed to appear in element .")
                        || message.equals("cvc-complex-type.4: Attribute  must appear on element ."))
                    return;
                throw ex;
            }
        });
        validator.validate(new DOMSource(doc));
    }

    /**
     * Get children of parent element which have given name.
     * @param parent parent element
     * @param name - name of children elements.
     * @return children element(s)
     */
    public static ArrayList<Element> getChildren(Element parent, String name) {
        ArrayList<Element> children = new ArrayList<Element>();

        for (Node child = parent.getFirstChild(); child != null; child = child.getNextSibling()) {
            if (child instanceof Element && name.equals(child.getNodeName()))
                children.add((Element) child);
        }
        return children;
    }

    /**
     * Get one child of parent element which have given name. Returns null, if none found.
     * @param parent parent element
     * @param name  - name of child element.
     * @return child element
     */
    public static Element getChild(Element parent, String name) {
        for (Node child = parent.getFirstChild(); child != null; child = child.getNextSibling()) {
            if (child instanceof Element && name.equals(child.getNodeName()))
                return (Element) child;
        }
        return null;
    }

    /**
     * Get text value of child element of parent element with given name. Returns null, if child element is not found.
     * 
     * @param parent parent element
     * @param name - name of child element.
     * @return child element tag
     */
    public static String getTagValue(Element parent, String name) {
        Element tag = getChild(parent, name);
        if (tag != null)
            return getTagValue(tag);
        return null;
    }

    /**
     * Get text value of given element. Returns empty string if no text child is found.
     * @param tag element wich ag to find
     * @return tag value
     */
    public static String getTagValue(Element tag) {
        for (Node child = tag.getFirstChild(); child != null; child = child.getNextSibling()) {
            if (child instanceof Text)
                return ((Text) child).getNodeValue();
        }
        return "";
    }

    /**
     * Remove element from it's parent's children and return it. Also removes previous and/or next sibling if either of
     * those is text node with only whitespaces
     * 
     * @param element - DOM element, which has parent (so cannot be root)
     * @return removed element
     */
    public static Element removeElement(Element element) {
        Element parent = (Element) element.getParentNode();
        Node prevSibling = element.getPreviousSibling();
        Node nextSibling = element.getNextSibling();
        if (prevSibling != null && prevSibling instanceof Text && prevSibling.getNodeValue().trim().equals(""))
            parent.removeChild(prevSibling);
        if (nextSibling != null && nextSibling instanceof Text && nextSibling.getNodeValue().trim().equals(""))
            parent.removeChild(nextSibling);
        parent.removeChild(element);
        return element;
    }

    /**
     * Convert XML document to its string representation
     * 
     * @param doc document to be serialized
     * @return serialized XML document
     */
    public static String documentToString(Document doc) {
        try {
            DOMSource domSource = new DOMSource(doc);
            StringWriter writer = new StringWriter();
            StreamResult result = new StreamResult(writer);
            TransformerFactory tf = XMLUtil.getTransformerFactory();
            Transformer transformer = tf.newTransformer();
            transformer.transform(domSource, result);
            return writer.toString();
        } catch (TransformerException ex) {
            ex.printStackTrace();
            return null;
        }
    }

    /**
     * Get first SOAPElement under given SOAPElement
     * 
     * @param parentEl parent soap element
     * @return first child element
     */
    public static SOAPElement getFirstElement(SOAPElement parentEl) {
        Iterator<?> it = parentEl.getChildElements();
        while (it.hasNext()) {
            Object nodeObject = it.next();
            if (nodeObject instanceof SOAPElement) {
                return (SOAPElement) nodeObject;
            }
        }
        return null;
    }

    /**
     * Get child from element by the local name of the element (excluding namespace prefix and ':' separator)
     * 
     * @param element element to search from
     * @param tagName tag to search
     * @return found element or null if one was not found
     */
    public static Element getElementByLocalTagName(Element element, String tagName) {
        if (element == null)
            return null;
        NodeList childNodes = element.getChildNodes();
        for (int i = 0; i < childNodes.getLength(); i++) {
            Node node = childNodes.item(i);
            if (node instanceof Element) {
                Element child = (Element) node;
                if (child.getLocalName().equals(tagName))
                    return child;
            }
        }
        return null;
    }

    /**
     * Abstraction for retrieving attribute of certain name
     * 
     * @param element XML element
     * @param attributeName XML element attribute
     * @return XML element attribute attribute value
     */
    public static String getAttributeByLocalName(Element element, String attributeName) {
        NamedNodeMap attributes = element.getAttributes();
        for (int i = 0; i < attributes.getLength(); i++) {
            Node attributeNode = attributes.item(i);
            if (attributeNode instanceof Attr) {
                Attr attribute = (Attr) attributeNode;
                if (attribute.getLocalName().equals(attributeName)) {
                    return attribute.getValue();
                }
            }
        }
        return null;
    }

    /**
     * Get XML element text content or null if element is null
     * 
     * @param node XML dom node
     * @return node text content or null
     */
    public static String getElementValueSafely(Node node) {
        if (node == null)
            return null;
        return node.getTextContent();
    }

    /**
     * @param node node
     * @return node as string
     */
    public static String nodeToString(Node node) {
        if (node == null)
            return null;
        StringWriter sw = new StringWriter();
        try {
            Transformer t = XMLUtil.getTransformerFactory().newTransformer();
            t.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
            t.setOutputProperty(OutputKeys.INDENT, "yes");
            t.transform(new DOMSource(node), new StreamResult(sw));
        } catch (TransformerException e) {
            logger.error("Transforming XML node to string failed.", e);
        }
        return sw.toString();
    }
    
    /**
     * Get Saxon transformer factory instance without accessing
     * TransformerFactory.newInstance() which has been shown to sometimes return
     * Xalan implementations with XPath 1.0 capabilities only. Our XSL-s
     * rely on XPath 2.0, therefore other implementations are not adequate.
     * @return Saxon transformer factory implementation.
     */
    public static TransformerFactory getTransformerFactory() {
        return new TransformerFactoryImpl();
    }
}