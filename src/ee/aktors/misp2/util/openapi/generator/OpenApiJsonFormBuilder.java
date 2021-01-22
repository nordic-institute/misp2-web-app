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
package ee.aktors.misp2.util.openapi.generator;

import java.util.Map;

import org.jsoup.nodes.Element;

import com.networknt.oas.model.Schema;

import ee.aktors.misp2.util.openapi.generator.OpenApiFormBuilder.FormElementType;
import ee.aktors.misp2.util.openapi.generator.input.InputGenerator;

/**
 * Enables populating Jsoup container node with REST form HTML elements corresponding to OpenAPI JSON schema. 
 * @author sander.kallo
 */
class OpenApiJsonFormBuilder {
    private OpenApiFormBuilder mainBuilder;
    private Element containerNode;
    private Schema schema;
    private FormElementType elementType;
    private String multipartId;
    
    /**
     * Construct JSON form builder instance.
     * @param mainBuilder main OpenAPI builder with methods to add nodes, etc
     * @param containerNode container in HTML document where to content is added
     * @param schema OpenAPI schema instance containing JSON message structure
     * @param formElementType
     * @param multipartId optional multipart property ID; null if not multipart content
     */
    OpenApiJsonFormBuilder(OpenApiFormBuilder mainBuilder, Element containerNode, Schema schema,
            FormElementType formElementType) {
        this.mainBuilder = mainBuilder;
        this.containerNode = containerNode;
        this.schema = schema;
        this.elementType = formElementType;
        this.multipartId = null;
    }
    
    /**
     * Set multipart ID value. Use before {@link #addElements()} is called.
     * @param multipartId multipart ID
     */
    void setMultipartId(String multipartId) {
        this.multipartId = multipartId;
    }
    
    /**
     * Traverse schema recursively and generate output elements for each schema node.
     * Internally use {@link #addJsonElementsFromSchema(Element, String, Schema, FormElementType, int, String)}
     * with parameters initialized in constructor.
     */
    void addElements() {
        addJsonElementsFromSchema(containerNode, "", schema, elementType, 1, multipartId);
    }

    private static final int MAX_SCHEMA_DEPTH = 100; // limit recursion stack to avoid possible stack overflow
    
    /**
     * Traverse schema recursively and generate output elements for each schema node.
     * Usage: addOutputsFromSchema(outputNode, "", schema, true, 1)
     * @param fieldNode container in HTML document where content is added
     * @param path current path of HTML node
     * @param schema schema element of given HTML node
     * @param depth recursion depth
     */
    private void addJsonElementsFromSchema(Element containerNode, String path, Schema schema, FormElementType elementType, int depth, String multipartId) {
        if (schema == null) {
            throw new RuntimeException("Schema does not exist."); // schema does not exist
        }
        if (depth > MAX_SCHEMA_DEPTH) { // avoids infinite recursion
            throw new RuntimeException("Allowed schema traverse recursion depth " + MAX_SCHEMA_DEPTH + " exceeded.");
        }
        if (schema.getType().equals("array")) { // element is array, add listing node
            Element fieldNode = mainBuilder.addFieldWithLabel(containerNode, schema, path);
            Element repeatTemplateNode = mainBuilder.addRepeatContainer(fieldNode, schema, path, multipartId);
            addJsonElementsFromSchema(repeatTemplateNode, "", schema.getItemsSchema(), elementType, depth + 1, multipartId);
            mainBuilder.addRepeatButtons(repeatTemplateNode, elementType);
            
        } else { // element is not array
            Map<String, Schema> properties = schema.getProperties();
            if (properties != null && properties.size() > 0) { // element is object with multiple properties
                for (String propertyName : properties.keySet()) {
                    addJsonElementsFromSchema(containerNode, concatJsonPaths(path, propertyName),
                            properties.get(propertyName), elementType, depth + 1, multipartId);
                }
            } else { // element is atomic type
                Element fieldNode = mainBuilder.addFieldWithLabel(containerNode, schema, path);
                Element valueNode = null;
                if (elementType == FormElementType.INPUT) { // generate input element
                    InputGenerator inputGenerator = mainBuilder.addInputNode(fieldNode, path, schema, false, null, multipartId);
                    valueNode = inputGenerator.getInputNode();
                } else if (elementType == FormElementType.OUTPUT) { // generate generate output element
                    valueNode = mainBuilder.addOutputNode(fieldNode, path, schema, multipartId);
                }
                
                // Add JSON type to node
                addValueType(valueNode, schema);
                
                // do not allow binary content in JSON, instead use base64
                if (valueNode != null && valueNode.hasClass("binary")) {
                    valueNode.removeClass("binary");
                    valueNode.addClass("base64");
                }
            }
        }
    }

    private String concatJsonPaths(String path, String propertyName) {
        String newPath = new String(path);
        if (!newPath.equals("") && !propertyName.equals("") && !propertyName.startsWith("[")) {
            newPath = newPath + ".";
        }
        newPath = newPath + propertyName;
        return newPath;
    }
    
    static void addValueType(Element node, Schema schema) {
        if (schema != null && schema.getType() != null) {
            if (schema.getType().equals("string") && schema.getFormat() != null && schema.getFormat().startsWith("date")) {
                node.attr("data-rf-type", "date");
            } else if (schema.getType().startsWith("int")) {
                node.attr("data-rf-type", "integer");
            } else if (schema.getType().startsWith("bool")) {
                node.attr("data-rf-type", "boolean");
            }
        }
    }
}
