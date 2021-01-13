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

package ee.aktors.misp2.util;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeMap;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 */
public class XMLDiffMerge {

    /**
     */
    public static enum Difference {
        ADDED, DELETED, EQUAL;
        /**
         * @return lower case enum name
         */
        public String toLowerCase() {
            return this.toString().toLowerCase();
        }

        /**
         * @return attribute name
         */
        public static String getAttributeName() {
            return "diff";
        }
    }

    private Document baseDoc;
    private Document modifiedDoc;
    private Document diffDoc;
    private DocumentBuilderFactory docBuildFactory;
    private static Logger logger = LogManager.getLogger(XMLDiffMerge.class);

    private XMLDiffMerge() {
        docBuildFactory = DocumentBuilderFactory.newInstance();
        docBuildFactory.setIgnoringElementContentWhitespace(true);
        docBuildFactory.setNamespaceAware(true);
        this.diffDoc = null;
    }

    /**
     * @param baseInputStream document input stream
     * @param modifiedInputStream modified document input stream
     * @throws Exception if parsing fails
     */
    public XMLDiffMerge(InputStream baseInputStream, InputStream modifiedInputStream) throws Exception {
        this();
        DocumentBuilder docBuilder = docBuildFactory.newDocumentBuilder();
        this.baseDoc = docBuilder.parse(baseInputStream);
        this.modifiedDoc = docBuilder.parse(modifiedInputStream);
    }

    /**
     * @param baseDocument base document to set
     * @param modifiedDocument modified document to set
     * @throws ParserConfigurationException can throw
     */
    public XMLDiffMerge(Document baseDocument, Document modifiedDocument) throws ParserConfigurationException {
        this();
        this.baseDoc = baseDocument;
        this.modifiedDoc = modifiedDocument;
    }

    private void cloneToDiffDoc(Document doc) throws ParserConfigurationException {
        diffDoc = docBuildFactory.newDocumentBuilder().newDocument();
        diffDoc.appendChild(diffDoc.importNode(doc.getDocumentElement(), true));
    }

    class ElementContainer {
        String xpath;
        String hash;
        Element element;
        int level;
        boolean alreadyAddedByParent;

        public ElementContainer(String xpath, String hash, Element element, int level) {
            this.xpath = xpath;
            this.hash = hash;
            this.element = element;
            this.level = level;
            this.alreadyAddedByParent = false;
        }

        public String getXpath() {
            return xpath;
        }

        public String getHash() {
            return hash;
        }

        public Element getElement() {
            return element;
        }

        public String getKey() {
            return xpath + "|" + hash;
        }

        public int getLevel() {
            return level;
        }

        public boolean isAlreadyAddedByParent() {
            return alreadyAddedByParent;
        }

        public void setAlreadyAddedByParent(boolean alreadyAddedByParentIn) {
            this.alreadyAddedByParent = alreadyAddedByParentIn;
        }

    }

    /**
     * @return document difference
     * @throws Exception if doucment cloning fails
     */
    public Document getDifferenceDocument() throws Exception {
        long t = new Date().getTime();
        // insert mark all diff attributes
        cloneToDiffDoc(this.baseDoc);

        // collect all comparable base document nodes to hashmap
        // a key is a unique string for given element consisting of parent names with component/section/code/@code
        // attributes +
        // all the text content and attributes of that element so it can be uniquely identified
        logger.trace("...Parsing base elements...\n");
        HashMap<String, ElementContainer> baseElements = new LinkedHashMap<String, ElementContainer>();
        // use cloned diff doc so elements do not have to be exported
        parseComparisonElements(this.diffDoc, baseElements);

        // collect all comparable modified document nodes to hashmap
        logger.trace("...Parsing modified elements...\n");
        HashMap<String, ElementContainer> modifiedElements = new LinkedHashMap<String, ElementContainer>();
        parseComparisonElements(this.modifiedDoc, modifiedElements);

        long t1 = new Date().getTime();
        // find all the entries existing only in base document
        HashSet<String> baseKeySet = new LinkedHashSet<String>();
        baseKeySet.addAll(baseElements.keySet());
        logger.trace("1. baseKeySet: " + baseKeySet.size());
        baseKeySet.removeAll(modifiedElements.keySet());
        logger.trace("2. baseKeySet: " + baseKeySet.size());

        // all nodes not existing in modified document must be deleted
        for (String key : baseKeySet) {
            ElementContainer elementContainer = baseElements.get(key);
            Element element = elementContainer.getElement();
            logger.trace("Deleted: " + key);
            element.setAttribute(Difference.getAttributeName(), Difference.DELETED.toLowerCase());
        }

        // find all the entries existing only in modified document
        HashSet<String> modifiedKeySet = new LinkedHashSet<String>();
        modifiedKeySet.addAll(modifiedElements.keySet());
        logger.trace("1. modifiedKeySet: " + modifiedKeySet.size());
        modifiedKeySet.removeAll(baseElements.keySet());
        logger.trace("2. modifiedKeySet: " + modifiedKeySet.size());

        // modified nodes need to be added to diffDoc
        mergeFromCoparisonElements(this.diffDoc, modifiedElements, modifiedKeySet);

        logger.trace("t: " + (t1 - t));
        return diffDoc;

    }

    private void parseComparisonElements(Document doc, HashMap<String, ElementContainer> elementContainerMap) {
        // extract comparable elements from elementContainerMap to doc
        extractElements(doc.getDocumentElement(), "", elementContainerMap, 0);

        // remove comparison elements that have comparable children: we dont want to do anything to those
        HashSet<String> keysForRemoval = new LinkedHashSet<String>();
        for (String key : elementContainerMap.keySet()) {
            ElementContainer elementContainer = elementContainerMap.get(key);
            String xpath = elementContainer.getXpath();

            for (String key2 : elementContainerMap.keySet()) {
                ElementContainer elementContainer2 = elementContainerMap.get(key2);
                String xpath2 = elementContainer2.getXpath();
                if (xpath2.startsWith(xpath + "/")) {
                    keysForRemoval.add(key);
                    break;
                }
            }
        }
        for (String key : keysForRemoval) {
            // logger.trace("Removing key: " + key);
            keysForRemoval.add(key);
        }
        elementContainerMap.keySet().removeAll(keysForRemoval);
    }

    /**
     * Recursive method that traverses element and takes element order-agnostic xpath as input and builds #nodes
     * parameter when comparison element is found.
     * 
     * @param element
     * @param xpath
     * @param nodes
     */
    private void extractElements(Element element, String xpath, HashMap<String, ElementContainer> nodes, int level) {
        if (element == null)
            return;
        if (isComparisonElement(element, level)) {
            ElementContainer elementContainer = new ElementContainer(xpath, getHash(element), element, level + 1);
            nodes.put(elementContainer.getKey(), elementContainer);
        }
        NodeList childNodes = element.getChildNodes();
        for (int i = 0; i < childNodes.getLength(); i++) {
            Node childNode = childNodes.item(i);
            if (!(childNode instanceof Element))
                continue;
            Element childElement = (Element) childNode;
            extractElements(childElement, getCurrentXpath(childElement, xpath), nodes, level + 1);
        }
    }

    private static String getCurrentXpath(Element element, String parentXpath) {
        String elementRelativeXpath = getRelativeXpathForComparison(element);
        return parentXpath + "/" + elementRelativeXpath;
    }

    private static String getRelativeXpathForComparison(Element element) {
        if (element == null)
            return "";
        String attrs = "";
        if (element.getNodeName().endsWith("component")) {
            for (Element sectionElement : getChildren(element)) {
                if (!sectionElement.getNodeName().endsWith("section"))
                    continue;
                for (Element codeElement : getChildren(sectionElement)) {
                    if (!codeElement.getNodeName().endsWith("code"))
                        continue;
                    attrs += "[" + codeElement.getAttribute("code") + "]";
                }
            }
        }

        return element.getLocalName() + attrs;
    }

    private boolean isComparisonElement(Element element, int level) {
        String name = element.getNodeName();

        return name != null
                && level > 1
                && (name.endsWith("component") || name.endsWith("entry")
                        || name.endsWith("tr") && element.getParentNode().getNodeName().endsWith("tbody"));
    }

    // /**
    // * stackoverflow.com/questions/415953/how-can-i-generate-an-md5-hash#answer-6565597
    // * @param md5
    // * @return
    // */
    // private String MD5(String str) {
    // try {
    // java.security.MessageDigest md = java.security.MessageDigest
    // .getInstance("MD5");
    // byte[] array = md.digest(str.getBytes());
    // StringBuffer sb = new StringBuffer();
    // for (int i = 0; i < array.length; ++i) {
    // sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100)
    // .substring(1, 3));
    // }
    // return sb.toString();
    // } catch (java.security.NoSuchAlgorithmException e) {
    // }
    // return null;
    // }

    private String getHash(Element element) {
        // include both attributes and tag texts to comparison
        return normalizeElement(element, 0, -1, true, true, null);
    }

    private void mergeFromCoparisonElements(Document base,
            HashMap<String, ElementContainer> modifiedElements, HashSet<String> modifiedKeySet) {
        // all nodes not existing in modified document must be deleted
        for (String key : modifiedKeySet) {
            // this is just an normal element for modification, includes parents
            ElementContainer modifiedElementContainer = modifiedElements.get(key);
            if (modifiedElementContainer.isAlreadyAddedByParent()) {
                logger.trace("Is already added by parent: " + key);
                continue;
            }

            // find if modified container should be inserted to original or not
            boolean deepestChild =
                    isDeepestChild(modifiedKeySet, modifiedElements, modifiedElementContainer.getXpath());

            // insert only deepest children, do not insert parents, otherwise there is a duplicate insert
            if (deepestChild) {
                // get element in base container that can be the parent of modified element, so at least one level above
                // it
                // modified element gets inserted directly into this element
                ElementContainer firstUsableBaseContainer = getFirstExstingBaseNodeFromXpath(base.getDocumentElement(),
                        "", modifiedElementContainer);
                Element adjustedModifiedElement = modifiedElementContainer.getElement();
                // if base element is a grandparent or grand-grandparent etc, then select parent or grandparent, etc of
                // modified element
                // so that modified element is always a direct child of base element
                boolean insertedParent = false;
                for (int i = 0;
                        i < (modifiedElementContainer.getLevel() - firstUsableBaseContainer.getLevel() - 1); i++) {
                    adjustedModifiedElement = (Element) adjustedModifiedElement.getParentNode();
                    insertedParent = true;
                }
                Element newBaseNode = (Element) base.importNode(adjustedModifiedElement, true);
                logger.trace("Added: " + key);
                firstUsableBaseContainer.getElement().appendChild(newBaseNode);
                newBaseNode.setAttribute(Difference.getAttributeName(), Difference.ADDED.toLowerCase());

                if (insertedParent) { // mark all children as already inserted if parent was inserted, otherwise we get
                                      // duplicate elements when children are inserted again
                    String childXpathPrefix = firstUsableBaseContainer.getXpath() + "/"
                            + getRelativeXpathForComparison(adjustedModifiedElement) + "/";
                    for (String key2 : modifiedKeySet) {
                        ElementContainer potentialChildElementContainer = modifiedElements.get(key2);
                        if (potentialChildElementContainer.getXpath().startsWith(childXpathPrefix)) { // then must be
                                                                                                      // child, mark it
                                                                                                      // already done
                            potentialChildElementContainer.setAlreadyAddedByParent(true);
                            logger.trace("blocking modified path: " + potentialChildElementContainer.getXpath()
                                    + " because of " + childXpathPrefix);
                        }
                    }
                }
            }
        }
    }

    private ElementContainer getFirstExstingBaseNodeFromXpath(Element baseElement, String baseXpath,
            ElementContainer modifiedElementContainer) {
        String modifiedXpath = modifiedElementContainer.getXpath();
        int modifiedLevel = getDepthFromXpath(modifiedXpath);

        for (int i = 0; i < modifiedLevel; i++) {
            List<Element> baseChildren = getChildren(baseElement);
            boolean foundNext = false;
            for (Element baseChildElement : baseChildren) {
                String childBaseXpath = getCurrentXpath(baseChildElement, baseXpath);
                if (modifiedXpath.startsWith(childBaseXpath + "/")) {
                    baseXpath = childBaseXpath;
                    baseElement = baseChildElement;
                    foundNext = true;
                    break; // jump out from children search loop: correct child was found
                }
            }
            if (!foundNext)
                break;

        }
        return new ElementContainer(baseXpath, "", baseElement, getDepthFromXpath(baseXpath));

    }

    private boolean isDeepestChild(HashSet<String> keySet, HashMap<String, ElementContainer> elementContainerMap,
            String xpath) {
        boolean deepestChild = true;
        for (String key2 : keySet) {
            ElementContainer modifiedElementContainer2 = elementContainerMap.get(key2);
            String modifiedXpath2 = modifiedElementContainer2.getXpath();
            if (modifiedXpath2.startsWith(xpath + "/")) {
                deepestChild = false;
                break;
            }
        }
        return deepestChild;
    }

    private int getDepthFromXpath(String xpath) {
        return xpath.split("/").length;
    }

    /**
     * Recursive method to transform {@link Element} to string so that elements can be compared if they are equal or
     * not. Children are sorted by tag-name and then by content alphabetically so that different child order still
     * results in the same string. Compare one XML element to another, return true, if elements are equal, false if not
     * 
     * @param base
     *            first XML element to be compared to #modified
     * @param level
     *            current level
     * @param maxLevel
     *            maximum child level comparison goes into; -1 means no limit
     * @param includeAttributes
     *            compare elements and subelements attributes
     * @param includeContent
     *            compare elements and subelements text-only nodes
     * @param entrySubTagNamesForComparison
     *            only compare tags with the following names
     * @return element as string which can be used to compare element equality
     */
    public String normalizeElement(Element base, int level, final int maxLevel, final boolean includeAttributes,
            final boolean includeContent, final Set<String> entrySubTagNamesForComparison) {
        final String nullString = "";
        final String separator = ">";
        final String attrSeparator = "=";
        if (base == null || maxLevel >= 0 && level > maxLevel) {
            return nullString;
        } else {
            String baseName = base.getLocalName();
            if (entrySubTagNamesForComparison != null && baseName != null
                    && !entrySubTagNamesForComparison.contains(baseName)) {
                logger.trace("baseName: " + baseName + " is not in entrySubTagNamesForComparison -> 13");
                return nullString;
            } else if (baseName != null
                    && (baseName.equals("assignedAuthor") || baseName.equals("originalText")
                            || baseName.equals("content") || baseName.equals("effectiveTime"))) {
                return nullString;
            } else if (baseName == null) {
                return nullString;
            }
            StringBuilder sBuf = new StringBuilder();
            sBuf.append(baseName + separator);

            if (includeAttributes) {
                NamedNodeMap baseAttrs = base.getAttributes();
                // sort baseattrs
                if (baseAttrs != null) {
                    for (int i = 0; i < baseAttrs.getLength(); i++) {
                        Node baseAttr = baseAttrs.item(i);
                        if (baseAttr == null) {
                            continue;
                        }
                        String name = baseAttr.getNodeName();
                        if (name == null || name.equals("codeSystemName") || name.equals("typeCode")
                                || name.equals("xsi:type"))
                            continue;
                        sBuf.append(name + attrSeparator);
                        String baseValue = baseAttr.getNodeValue();
                        if (baseValue == null)
                            continue;
                        sBuf.append(baseValue + separator);
                    }
                }
            }
            List<Element> baseElements = getChildren(base);

            if (baseElements.size() > 0) {
                TreeMap<String, Element> sortedElements = new TreeMap<String, Element>();
                // sort
                for (int i = 0; i < baseElements.size(); i++) {
                    Element baseElement = baseElements.get(i);
                    String baseHash = normalizeElement(baseElement, level, maxLevel, includeAttributes, includeContent,
                            entrySubTagNamesForComparison);
                    sortedElements.put(baseHash, baseElement);
                }
                for (String baseHash : sortedElements.keySet()) {
                    sBuf.append(baseHash);
                }
            } else if (includeContent) {
                sBuf.append(base.getTextContent().trim());
            }
            return sBuf.toString();
        }
    }

    private static List<Element> getChildren(Element el) {
        List<Element> elements = new ArrayList<Element>();
        NodeList nodes = el.getChildNodes();
        if (nodes != null) {
            for (int i = 0; i < nodes.getLength(); i++) {
                Node child = nodes.item(i);
                if (child instanceof Element)
                    elements.add((Element) child);
            }
        }
        return elements;
    }
}
