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
package ee.aktors.misp2.util.openapi.generator;

import java.util.Map;

import org.jsoup.nodes.Element;

import com.networknt.oas.model.EncodingProperty;
import com.networknt.oas.model.MediaType;
import com.networknt.oas.model.Schema;

import ee.aktors.misp2.util.openapi.generator.OpenApiFormBuilder.FormElementType;
import ee.aktors.misp2.util.openapi.generator.input.InputGenerator;
import ee.aktors.misp2.util.openapi.generator.input.string.FileInputGenerator;
import ee.aktors.misp2.util.openapi.generator.lang.Lang;
import ee.aktors.misp2.util.openapi.generator.lang.OpenApiFormTranslations.Translation;

/**
 * Enables populating Jsoup container node with REST form HTML elements corresponding to OpenAPI multipart content. 
 * @author sander.kallo
 */
class OpenApiMultipartBuilder {

    private OpenApiFormBuilder mainBuilder;
    private Element containerNode;
    private MediaType mediaType;
    private FormElementType elementType;
    
    /**
     * Construct JSON form builder instance.
     * @param mainBuilder main OpenAPI builder with methods to add nodes, etc
     * @param containerNode container in HTML document where to content is added
     * @param mediaType OpenAPI schema with encoding properties
     * @param formElementType
     * @param multipartId optional multipart property ID; null if not multipart content
     */
    OpenApiMultipartBuilder(OpenApiFormBuilder mainBuilder, Element containerNode, MediaType mediaType,
            FormElementType formElementType) {
        this.mainBuilder = mainBuilder;
        this.containerNode = containerNode;
        this.mediaType = mediaType;
        this.elementType = formElementType;
    }

    @SuppressWarnings("unused")
    public void addElements() {
        Map<String, Schema> propertySchemas = mediaType.getSchema().getProperties();
        Map<String, EncodingProperty> encodingProperties = mediaType.getEncodingProperties();
        for (String multipartId : propertySchemas.keySet()) {
            Schema schema = propertySchemas.get(multipartId);
            EncodingProperty encodingProperty = encodingProperties.get(multipartId);

            String contentType = null;
            if (encodingProperty != null) {
                contentType = encodingProperty.getContentType();
            }
            boolean schemaTypeExists = schema.getType() != null;
            // note: null content type on object still means JSON
            boolean isArray = schemaTypeExists && schema.getType().equals("array");
            // note: null content type on array is interpreted as not JSON: this is multipart array
            boolean isJsonArray = isArray && (contentType != null && contentType.equals("application/json"));
            final boolean isMultipartArray = isArray && !isJsonArray;
            
            Element containerNode = this.containerNode;
            Element repeatTemplateNode = null;
            if (isMultipartArray) { // If is array, build repeat around normal content
                Element fieldNode = mainBuilder.addFieldWithLabel(containerNode, schema, schema.getDescription(), multipartId);
                
                repeatTemplateNode = mainBuilder.addRepeatContainer(fieldNode, schema, multipartId, multipartId);
                repeatTemplateNode.attr("class", "multipart-repeat-template");
                //InputGenerator.setMultipartId(repeatTemplateNode, multipartId);
                Element innerFieldNode = mainBuilder.addFieldWithLabel(repeatTemplateNode, null, "");
                schema = schema.getItemsSchema();
                
                // Find schema information flags again, this time from array item schema
                schemaTypeExists = schema.getType() != null;
                isArray = schemaTypeExists && schema.getType().equals("array");
                isJsonArray = isArray; // After extracting multipart array, all subarrays are considered JSON arrays
                
                // Re-assign containerNode to template content node: all fields are put into multipart array template
                containerNode = innerFieldNode;
            }
            final boolean isJsonObject = schemaTypeExists && schema.getType().equals("object")
                    && (contentType == null || contentType.equals("application/json"));
            
            
            if (encodingProperty != null) {
                if (false) { // adding headers commented out since client side does not support sending them
                    addSubHeaders(containerNode, multipartId, encodingProperty);
                }
            }
            // Add information node for current multipart section
            Element multipartInfoNode = containerNode.appendElement("div")
                    .attr("class", "multipart-info")
                    .attr("data-rf-multipart-id", multipartId) // this one can change during cloning
                    .attr("data-rf-multipart-property-name", multipartId); // this one remains unchanged after cloning
            Translation translation =mainBuilder.formTranslations.multipartSection;
            for (Lang lang : translation.keySet()) {
                // Set multipart section heading
                multipartInfoNode.appendElement("div")
                    .attr("class", "multipart-info-heading")
                    .attr("data-rf-lang", lang.name())
                    .text( translation.get(lang) + " '" + multipartId + "'");
            }
            if (isMultipartArray) {
                multipartInfoNode.appendElement("div").attr("class", "repeat-item-count");
            }
            
            // set to null, since elements are added inside multipart-info node so client adds attributes
            String multipartIdAttribute = null;
            if (isJsonObject || isJsonArray) { // Content type: JSON
                OpenApiJsonFormBuilder jsonBuilder =
                    new OpenApiJsonFormBuilder(mainBuilder, multipartInfoNode, schema, elementType);
                jsonBuilder.setMultipartId(multipartIdAttribute);
                jsonBuilder.addElements();
                if (contentType == null) {
                    contentType = "application/json";
                }
                multipartInfoNode.attr("data-rf-content-type", contentType);
            } else { // Any other content type
                String label = isMultipartArray ? null : multipartId;
                Element fieldNode = mainBuilder.addFieldWithLabel(multipartInfoNode, schema, schema.getDescription(), label);
                InputGenerator inputGenerator = null;
                if (elementType == FormElementType.INPUT) { // generate input element
                     inputGenerator =
                            mainBuilder.addInputNode(fieldNode, multipartId, schema, true, null, multipartIdAttribute);
                    
                } else if (elementType == FormElementType.OUTPUT) { // generate generate output element
                    mainBuilder.addOutputNode(fieldNode, multipartId, schema, multipartIdAttribute);
                }
                
                String format = schema.getFormat();
                if (contentType == null && format != null && format.equals("binary")) { // default is binary file content type
                    contentType = "application/octet-stream";
                }
                if (contentType != null) {
                    multipartInfoNode.attr("data-rf-content-type", contentType);
                }
                if (contentType != null && inputGenerator != null && inputGenerator instanceof FileInputGenerator) {
                    FileInputGenerator fileInputGenerator = (FileInputGenerator)inputGenerator;
                    fileInputGenerator.setContentType(contentType);
                    fileInputGenerator.setAccept(contentType);
                }
            }
            if (isMultipartArray) {
                
                mainBuilder.addRepeatButtons(repeatTemplateNode, elementType);
                
                String format = schema.getFormat();
                if (contentType == null && format != null && format.equals("binary")) { // default is binary file content type
                    contentType = "application/octet-stream";
                }
                multipartInfoNode.addClass("for-multipart-repeat-template");
            }
        }
    }

    /**
     * Add multipart section specific headers.
     * @param containerNode 
     * @param multipartId multipart section property name
     * @param encodingProperty OpenAPI encoding block data for given multipart section
     */
    private void addSubHeaders(Element containerNode, String multipartId, EncodingProperty encodingProperty) { Map<String, String> headers = encodingProperty.getHeaders();
        if (headers != null) {
            for(String headerName : headers.keySet()) {
                String headerValue = headers.get(headerName);
    
                Element fieldNode = mainBuilder.addFieldWithLabel(containerNode, null, headerName);
                String dataParamLocation = "header";
                Element valueNode = null;
                if (elementType == FormElementType.INPUT) { // generate input element
                    InputGenerator inputGenerator =
                            mainBuilder.addInputNode(fieldNode, headerName, null, false, dataParamLocation, multipartId);
                    valueNode = inputGenerator.getInputNode();
                } else if (elementType == FormElementType.OUTPUT) { // generate generate output element
                    valueNode = mainBuilder.addOutputNode(fieldNode, headerName, null, multipartId);
                }
                if (valueNode != null) {
                    valueNode.attr("data-rf-default", headerValue);
                }
            }
            
        }
    }
}
