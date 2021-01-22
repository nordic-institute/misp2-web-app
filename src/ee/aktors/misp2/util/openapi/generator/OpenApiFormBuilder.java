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

import java.io.StringWriter;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Comment;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import com.networknt.oas.model.Header;
import com.networknt.oas.model.MediaType;
import com.networknt.oas.model.Operation;
import com.networknt.oas.model.Parameter;
import com.networknt.oas.model.RequestBody;
import com.networknt.oas.model.Response;
import com.networknt.oas.model.Schema;

import ee.aktors.misp2.util.openapi.generator.input.InputGenerator;
import ee.aktors.misp2.util.openapi.generator.input.string.FileInputGenerator;
import ee.aktors.misp2.util.openapi.generator.lang.Lang;
import ee.aktors.misp2.util.openapi.generator.lang.OpenApiFormTranslations;
import ee.aktors.misp2.util.openapi.generator.lang.OpenApiFormTranslations.Translation;

/**
 * Builds REST query HTML form using OpenAPI operation description object.
 */
public class OpenApiFormBuilder {
    // HTML form syntax format version
    private static final String REST_FORM_VERSION = "1.0";
    private static final String CONTENT_TYPE_JSON = "application/json";
    private static final String CONTENT_TYPE_MULTIPART = "multipart/form-data";
    
    // input parameters
    private final String method;
    private final String actionPath;
    private final Operation modelOp;
    
    // Form HTML DOM object (Jsoup document instane)
    private final Document doc;
    
    // Input and output view ID-s
    private String inputViewId;
    private String outputViewId;
    
    // Input and output elements
    private Element htmlNode;
    private Element bodyNode;
    private Element inputFormNode;

    private Element outputViewNode;

    OpenApiFormTranslations formTranslations;
    
    public enum FormElementType {INPUT, OUTPUT}
    
    /**
     * Construct form builder and build HTML Jsoup document object ready to be serialized.
     * @param method HTTP method (e.g. GET, PUT, POST, DELETE)
     * @param actionPath service target URL context path
     * @param modelOp OpenAPI model operation object instance
     */
    public OpenApiFormBuilder(String method, String actionPath, Operation modelOp) {
        // Initialize input parameters
        this.method = method;
        this.actionPath = actionPath;
        this.modelOp = modelOp;
        this.formTranslations = new OpenApiFormTranslations();
        // Initialize HTML document with head and body elements 
        doc = Jsoup.parse("", "UTF-8");
        
        buildForm();
    }
    
    private void buildForm() {
        // Initalize version
        htmlNode = doc.child(0);
        htmlNode.attr("data-rf-version", REST_FORM_VERSION); // add version attribute
        
        // Create form heading
        bodyNode = htmlNode.getElementsByTag("body").get(0);
        Element headingNode = bodyNode.appendElement("h1")
            .text(modelOp.getSummary());
        if (StringUtils.isNotBlank(modelOp.getDescription())) {
            headingNode.attr("title", modelOp.getDescription());
        }

        // Initialize view ID-s
        inputViewId = modelOp.getOperationId() + ".input";
        outputViewId = modelOp.getOperationId() + ".output";
        
        // Create input view
        addInputView();
        
        // Create output view
        addOutputView();
    }

    private void addInputView() {
        // add comment
        appendBlockComment(bodyNode, inputViewId, 80);
        // Add input view and form
        inputFormNode =
            bodyNode.appendElement("div")
                .attr("class", "view")
                .attr("id", inputViewId)
                .appendElement("form")
                    .attr("action", actionPath)
                    .attr("method", method);
        // Add parameters
        List<Parameter> parameters = modelOp.getParameters();
        if (parameters != null) {
            for (Parameter parameter : parameters) {
                // Add label
                Element fieldNode = addFieldWithLabel(inputFormNode, null, parameter.getDescription(), parameter.getName());
                
                // Find output element type
                String dataParamLocation = null;
                String in = parameter.getIn();
                if (in != null) {
                    if (in.equals("header")) {
                        dataParamLocation = "header";
                    } else if (in.equals("path") || in.equals("query")) {
                        dataParamLocation = "url";
                    }
                }
                
                // Add input element
                addInputNode(fieldNode, parameter.getName(), parameter.getSchema(), parameter.getRequired(), dataParamLocation, null);
            } 
        }
        
        // Add JSON request body
        RequestBody requestBody = modelOp.getRequestBody();
        if (requestBody != null) {
            String description = requestBody.getDescription();
            if (description != null) {
                inputFormNode.appendElement("h2").text(description);
            }
            Map<String, MediaType> contentMediaTypes = requestBody.getContentMediaTypes();
            if (contentMediaTypes != null) {
                // prioritize json and multipart content types
                if (contentMediaTypes.keySet().contains(CONTENT_TYPE_JSON)) {
                    MediaType mediaType = contentMediaTypes.get(CONTENT_TYPE_JSON);
                    OpenApiJsonFormBuilder jsonBuilder =
                            new OpenApiJsonFormBuilder(this, inputFormNode, mediaType.getSchema(), FormElementType.INPUT);
                    jsonBuilder.addElements();
                    inputFormNode.attr("data-rf-content-type", CONTENT_TYPE_JSON);
                } else if (contentMediaTypes.keySet().contains(CONTENT_TYPE_MULTIPART)) {
                    MediaType mediaType = contentMediaTypes.get(CONTENT_TYPE_MULTIPART);
                    OpenApiMultipartBuilder multipartBuilder =
                            new OpenApiMultipartBuilder(this, inputFormNode, mediaType, FormElementType.INPUT);
                    multipartBuilder.addElements();
                    inputFormNode.attr("data-rf-content-type", CONTENT_TYPE_MULTIPART);
                } else if (!contentMediaTypes.isEmpty()) {
                    // allow uploading content as file if content type was not recognized
                    String mediaTypeName = contentMediaTypes.keySet().iterator().next();
                    MediaType mediaType = contentMediaTypes.get(mediaTypeName);
                    Element fieldNode = addFieldWithLabel(inputFormNode, null, mediaTypeName);
                    
                    FileInputGenerator fileInputGenerator = new FileInputGenerator(mediaType.getSchema());
                    // set general input generator fields
                    fileInputGenerator
                            .setTranslations(formTranslations)
                            .setParentNode(fieldNode)
                            .setDataParamLocation("body")
                            .setRequired(true)
                            .setReadOnly();
                    // set file input generator fields
                    fileInputGenerator
                            .setAccept(mediaTypeName)
                            .setContentType(mediaTypeName);
                    inputFormNode.attr("data-rf-content-type", mediaTypeName);
                    
                } // else TODO log warning
                
            }
        }
        
        // Add send-buttons to input form with different translations
        Element containerNode = inputFormNode.appendElement("div").appendElement("span");
        Translation translation = formTranslations.submit;
        for (Lang lang : translation.keySet()) {
            containerNode
                .appendElement("button")
                    .attr("class", "send")
                    .attr("data-rf-target", outputViewId)
                    .attr("data-rf-lang", lang.name())
                    .text(translation.get(lang));
        }
    }
    
    private void appendBlockComment(Element parentNode, String commentText, final int width) {
        // top border
        final String border = StringUtils.repeat('-', width);
        
        // content
        appendComment(parentNode, border);
        StringWriter sw = new StringWriter();
        sw.append('-');
        int leftSpaceLen = (width - 2 - commentText.length())/2;
        int rightSpaceLen = width - 2 - commentText.length() - leftSpaceLen;
        sw.append(StringUtils.repeat(' ', leftSpaceLen));
        sw.append(commentText);
        sw.append(StringUtils.repeat(' ', rightSpaceLen));
        sw.append('-');
        appendComment(parentNode, sw.toString());
        
        // bottom border
        appendComment(parentNode, border);
    }

    private Element appendComment(Element parentNode, String commentText) {
        return parentNode.appendChild(new Comment(commentText, ""));
        
    }

    private void addOutputView() {
        // add comment
        appendBlockComment(bodyNode, outputViewId, 80);
        // Add output view
        outputViewNode =
            bodyNode.appendElement("div")
                .attr("class", "view")
                .attr("id", outputViewId);
        
        // Build response structure
        for (String responseCode : modelOp.getResponses().keySet()) {
            Response response = modelOp.getResponses().get(responseCode);

            // Add response-code specific container
            Element responseContainerNode = addResponseContainer(responseCode, null);
            

            // Add response code based select element to response output with descriptions
            addResponseCodeOutput(responseContainerNode, responseCode, response.getDescription());
            
            // Add response headers to output
            Map<String, Header> headers = response.getHeaders();
            if (headers != null) {
                for (String headerName : headers.keySet()) {
                    Header header = headers.get(headerName);

                    Element fieldNode = addFieldWithLabel(responseContainerNode, null, header.getDescription(), headerName);
                    addOutputNode(fieldNode, headerName, header.getSchema(), null)
                            .attr("data-rf-param-location", "header");
                } 
            }
            
            // Add response body schema content objects to output
            Map<String, MediaType> contentMediaTypes = response.getContentMediaTypes();
            if (contentMediaTypes != null) {
                if (contentMediaTypes.keySet().contains(CONTENT_TYPE_JSON)) {
                    MediaType mediaType = contentMediaTypes.get(CONTENT_TYPE_JSON);
                    OpenApiJsonFormBuilder jsonBuilder =
                            new OpenApiJsonFormBuilder(this, responseContainerNode, mediaType.getSchema(), FormElementType.OUTPUT);
                    jsonBuilder.addElements();
                    responseContainerNode.attr("data-rf-content-type", CONTENT_TYPE_JSON);
                } else if (contentMediaTypes.keySet().contains(CONTENT_TYPE_MULTIPART)) {
                    MediaType mediaType = contentMediaTypes.get(CONTENT_TYPE_MULTIPART);
                    OpenApiMultipartBuilder multipartBuilder =
                            new OpenApiMultipartBuilder(this, responseContainerNode, mediaType, FormElementType.OUTPUT);
                    multipartBuilder.addElements();
                    responseContainerNode.attr("data-rf-content-type", CONTENT_TYPE_MULTIPART);
                } else if (!contentMediaTypes.isEmpty()) {
                    // allow uploading content as file if content type was not recognized
                    String mediaTypeName = contentMediaTypes.keySet().iterator().next();
                    MediaType mediaType = contentMediaTypes.get(mediaTypeName);
                    Element fieldNode = addFieldWithLabel(responseContainerNode, null, mediaTypeName);
                    responseContainerNode.addClass("single-file");
                    responseContainerNode.attr("data-rf-content-type", mediaTypeName);
                    Element downloadNode = fieldNode
                            .appendElement("span")
                            .attr("class", "output-field");
                    downloadNode
                            .appendElement("div")
                            .attr("class", "link-container");
                    Schema schema = mediaType.getSchema();
                    if (schema != null && schema.getFormat() != null) {
                        downloadNode.addClass(schema.getFormat());
                    }
                } // else TODO log warning
                
            }
            if (responseContainerNode.childNodes().size() == 0) { // If no children were added, remove the empty node
                responseContainerNode.remove();
            }
        }
        
        if (!modelOp.getResponses().containsKey("default")) {
            Element defaultResponseContainerNode = addResponseContainer("default", formTranslations.unspecifiedResponse);

            // Always add response code to output form
            addResponseCodeOutput(defaultResponseContainerNode, "default", null);
            defaultResponseContainerNode.appendElement("div")
                .addClass("dynamic"); // generate input element structure into this block
        }
        
        // Add button(s) to output view toggling back to input view
        // Add send-buttons to input form with different translations
        Element containerNode = outputViewNode.appendElement("div");
        Translation translation = formTranslations.back;
        for (Lang lang : translation.keySet()) {
            containerNode
                .appendElement("button")
                    .attr("class", "toggle")
                    .attr("data-rf-target", inputViewId)
                    .attr("data-rf-lang", lang.name())
                    .text(translation.get(lang));
        }
    }

    private void addResponseCodeOutput(Element responseContainerNode, String responseCode, String description) {
        if (responseCode != null) {
            Element responseCodeFfieldNode = addFieldWithLabel(responseContainerNode, null, "Response code");
            if (!responseCode.equals("default")) { // fixed response code: show that
                responseCodeFfieldNode
                    .appendElement("span")
                        .attr("class", "output-field resp-code")
                        .text(responseCode);
                
            } else { // default response, show actual response code from the header
                responseCodeFfieldNode
                    .appendElement("span")
                        .attr("data-rf-path", "X-REST-Response-Code")
                        .attr("data-rf-param-location", "header")
                        .attr("class", "resp-code");
            }
        }
        
        // Add response description to response select
        if (StringUtils.isNotBlank(description)) {
            // Add response code based select element to response output with descriptions
            addFieldWithLabel(responseContainerNode, null, "Response status")
                    .appendElement("span")
                        .attr("class", "output-field")
                        .text(description);
        }
    }

    /**
     * Create response container with given HTTP response code, if it does not exist and add optional heading.
     * If container already exists, return existing.
     * 
     * @param responseCode HTTP response code
     * @param unspecifiedResponse optional response heading, applied only if new response is created
     * @return
     */
    private Element addResponseContainer(String responseCode, Translation translation) {
        Elements nodes = outputViewNode.getElementsByAttributeValue("data-rf-resp-code", responseCode);
        
        if (nodes != null && nodes.size() > 0 ) { // container already exists, use it
            return nodes.get(0);
        } else { // container does not exist, create new one
            Element responseContainerNode = outputViewNode.appendElement("div")
                .attr("data-rf-resp-code", responseCode);
            if (translation != null) { // optionally add

                // Add send-buttons to input form with different translations
                for (Lang lang : translation.keySet()) {
                    responseContainerNode
                        .appendElement("h2")
                            .attr("data-rf-lang", lang.name())
                            .text(translation.get(lang));
                }
            }
            return responseContainerNode;
        }
    }
    
    /**
     * Serializes generated Jsoup document object instance as String.
     * @return generated HTML form as text
     */
    public String getForm() {
        return doc.html();
    }

    /**
     * Method is accessed from generator subpackages during form generation, and is not meant for end-consumer.
     * @return HTML output form being generated as Jsoup document
     */
    Document getDoc() {
        return doc;
    }

    /**
     * Method is accessed also from generator subpackages during form generation, and is not meant for end-consumer.
     * @param containerNode Jsoup node into which field is added
     * @param schema content node OpenAPI schema object describing type
     * @param labelTexts label text in order of priority: first not-null is chosen as label text
     * @return Jsoup field container element with added label ready to accept a content node next to it
     */
    Element addFieldWithLabel(Element containerNode, Schema schema, String... labelTexts) {
        Element fieldNode = containerNode.appendElement("div").attr("class", "field");
        String labelText = null;
        if (schema != null) {
            labelText = schema.getDescription();
        }
        boolean firstChoice = true;
        if (labelText == null) {
            for (String s : labelTexts) {
                if (s != null) {
                    labelText = s;
                    firstChoice = false;
                    break;
                }
            }
        }
        if (labelText != null && !labelText.isEmpty()) {
            Element labelNode = fieldNode.appendElement("label");

            // add class to labels that are derived from JSON field names first letter of lower priority lowercase labels
            if (!firstChoice && !labelText.contains(" ")) {
                labelNode.attr("class", "property-derived");
            }
            labelNode.text(labelText);
        }
        return fieldNode;
    }

    InputGenerator addInputNode(Element fieldNode, String path, Schema schema, Boolean required, String dataParamLocation, String multipartProperty) {
        InputGenerator inputGenerator = InputGenerator
            .build(schema)
            .setTranslations(formTranslations)
            .setParentNode(fieldNode)
            .setPath(path)
            .setDataParamLocation(dataParamLocation)
            .setMultipartId(multipartProperty)
            .setRequired(required)
            .setReadOnly();
        return inputGenerator;
    }

    Element addOutputNode(Element fieldNode, String path, Schema schema, String multipartId) {
        Element valueNode = fieldNode.appendElement("span").attr("data-rf-path", path);
        InputGenerator.setMultipartId(valueNode, multipartId);
        InputGenerator.addFormat(valueNode, schema);
        InputGenerator.setWriteOnly(valueNode, schema);
        return valueNode;
    }

    Element addRepeatContainer(Element fieldNode, Schema schema, String path, String multipartId) {
        Element repeatContainerNode = fieldNode.appendElement("div").attr("class", "repeat-container");
        if (schema.getMinItems() != null) {
            repeatContainerNode.attr("data-rf-validate-min-items", "" + schema.getMinItems());
        }
        if (schema.getMaxItems() != null) {
            repeatContainerNode.attr("data-rf-validate-max-items", "" + schema.getMaxItems());
        }
        if (schema.getUniqueItems() != null) {
            repeatContainerNode.attr("data-rf-validate-unique-items", "" + schema.getUniqueItems());
        }
        Element repeatTemplateNode = repeatContainerNode.appendElement("div").attr("data-rf-repeat-template-path", path);
        InputGenerator.setMultipartId(repeatTemplateNode, multipartId);
        return repeatTemplateNode;
    }
    
    void addRepeatButtons(Element repeatTemplateNode, FormElementType elementType) {
        if (elementType == FormElementType.INPUT) {
            Element deleteButtonContainerNode;
            if (repeatTemplateNode.childNodes().size() == 1) { // if only one element is added, add delete button to the same line
                deleteButtonContainerNode = repeatTemplateNode.child(0);
            } else { // if more than one element is added, add delete button to next line and align right
                deleteButtonContainerNode = repeatTemplateNode
                        .appendElement("div").attr("class", "align-right");
            }
            deleteButtonContainerNode.appendElement("button").attr("class", "delete delete_btn").text("-");
            repeatTemplateNode.parent()
                .appendElement("button").attr("class", "add regular_btn").text("+");
        }
    }

}
