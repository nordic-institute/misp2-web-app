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
package ee.aktors.misp2.util.openapi;

import com.networknt.oas.OpenApi3Parser;
import com.networknt.oas.model.OpenApi3;
import com.networknt.oas.model.Operation;
import com.networknt.oas.model.Path;
import com.networknt.oas.validator.ValidationResults;
import com.networknt.oas.validator.ValidationResults.ValidationItem;
import com.networknt.utility.StringUtils;
import ee.aktors.misp2.action.exception.QueryException;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.ProducerName;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.model.QueryName;
import ee.aktors.misp2.util.Const.QUERY_TYPE;
import ee.aktors.misp2.util.openapi.generator.OpenApiFormBuilder;
import ee.aktors.misp2.util.LanguageUtil;
import java.io.File;
import java.io.StringWriter;
import java.net.URI;
import java.util.*;

/**
 * Extract data from OpenAPI description YAML file and generate HTML forms from it.
 * <p>
 * Usage:
 * <pre>
 *  OpenApiParser parser = new OpenApiParser(file);
 *  // Extract query list
 *  List<Query> queryList = parser.parseQueryList(producer);
 *  // Generate HTML form for given Query instance
 *  String form = parser.generateForm(query);
 *  </pre>
 * @author sander.kallo
 *
 */
public class OpenApiParser {
    // parsed OpenAPI description
    OpenApi3 model;

    // operationMap is used to faster access of operations in OpenAPI description based on operation name
    Map<String, OperationData> operationMap;
    
    /**
     * Construct parser instance from OpenAPI description file.
     * @param modelFile OpenAPI YAML File instance
     * @throws QueryException on parsing or OpenAPI validation failure.
     */
    public OpenApiParser(File modelFile) throws QueryException {
        try {
            model = new OpenApi3Parser().parse(modelFile, true);
        } catch (Exception e) {
            String path = modelFile != null ? modelFile.getAbsolutePath() : null;
            throw new QueryException(QueryException.Type.OPENAPI_PARSING_FAILED,
                    "Failed to read OpenAPI model from file " + path + ".", e);
        }
        init();
    }
    
    /**
     * Construct parser instance from OpenAPI description file loaded from given URI.
     * @param modelUri OpenAPI YAML file URI
     * @throws QueryException on parsing or OpenAPI validation failure.
     */    
    public OpenApiParser(URI modelUri) throws QueryException {
        try {
            model = new OpenApi3Parser().parse(modelUri, true);
        } catch (Exception e) {
            throw new QueryException(QueryException.Type.OPENAPI_PARSING_FAILED,
                    "Failed to read OpenAPI model from URI " + modelUri, e);
        }
        init();
    }
    private void init() throws QueryException {
        validateModel();
        initOperationMapIfNeeded(); // parse operations to a map for quick access
    }
    private void validateModel() throws QueryException {
        if (!model.isValid()) {
            ValidationResults results = model.getValidationResults();
            StringWriter sw = new StringWriter();
            int i = 0;
            for (ValidationItem validationItem : results.getItems()) {
                sw.append((++i) + ". " + validationItem.getMsg() + " " + validationItem.getPositionInfo() + "\n");
            }
            throw new QueryException(QueryException.Type.OPENAPI_MODEL_NOT_VALID,
                    "OpenAPI model not valid. \n" + sw.toString(), null);
        }
    }

    private void initOperationMapIfNeeded() {
        if (operationMap != null) { // repeated calls are ignored
            return;
        }
        operationMap = new LinkedHashMap<String, OperationData>();
        for (String actionPath : model.getPaths().keySet()) {
            Path modelPath = model.getPaths().get(actionPath);
            for (String method : modelPath.getOperations().keySet()) {
                Operation modelOp = modelPath.getOperations().get(method);
             // in case operation ID is missing, generate one beforehand
                if (modelOp.getOperationId() == null) {
                    String operationId = generateOperationId(method, actionPath);
                    modelOp.setOperationId(operationId);
                }
                operationMap.put(modelOp.getOperationId(), new OperationData(actionPath, method, modelOp));
            }
        }
    }
    
    /**
     * Assemble a new operation ID from method and its corresponding action path.
     * The operationId is used as a key in operationMap, so it needs to be unique.
     * In case the generated operationId conflicts with an existing entry in {@link #operationMap},
     * add a numeral suffix to it to resolve the conflict.
     * This functionality is needed when operationId-s are missing in OpenAPI definition.
     * @param method HTTP method for current operation
     * @param actionPath HTTP path for current operation
     * @return unique operationId
     */
    private String generateOperationId(String method, String actionPath) {
        // Put together operationId from defined operation method and its action path
        // Use camelCase and ignore path parameters
        StringWriter swOperationId = new StringWriter();
        
        // make method name more human readable and add it as first entry
        swOperationId.append(
                method.toLowerCase()
                    .replace("post", "add")
                    .replace("put", "update")
        );
        // add path section entries
        String[] splitPath = actionPath.split("/");
        StringWriter swQueryParams = new StringWriter();
        for (String section : splitPath) {
            // ignore parameters and empty sections
            if (section != null && !section.isEmpty()) {
                if (section.startsWith("{")) {
                    swQueryParams.append(clean(section));
                } else {
                    swOperationId.append(clean(section));
                }
            }
        }
        // If query parameter names were extracted, append them after By
        String swParamsPart = swQueryParams.toString();
        if (!swParamsPart.isEmpty()) {
            swOperationId.append("By");
            swOperationId.append(swParamsPart);
        }
        
        String operationId = swOperationId.toString();
        
        // Crop operationId string if it is too long (has to fit in query.name column)
        final int maxOpIdLength = 250;
        if (operationId.length() > maxOpIdLength) {
            operationId = operationId.substring(0, maxOpIdLength);
        }
        // Make sure the operation ID is unique.
        // If it is not, append it with a number big enough, so it would become unique.
        String uniqueId = operationId;
        int i = 2; // start from two, since an entry (without numeral suffix) already exists
        while (operationMap.containsKey(uniqueId)) {
            uniqueId = operationId + i;
            i++;
        }
        return uniqueId;
    }
    
    private String clean(String section) {
        StringWriter sw = new StringWriter();
        if (StringUtils.isNotBlank(section)) {
            // only allow for simple text-characters in operationId, remove the rest
            section = section.replaceAll("[^A-Za-z0-9]+", "");
            if (StringUtils.isNotBlank(section)) {
                // first letter is a capital letter (in every path section)
                sw.append(section.toUpperCase().substring(0, 1));
                // other letters are lower case
                if (section.length() > 1) {
                    sw.append(section.toLowerCase().substring(1));
                }
            }
        }
        return sw.toString();
    }

    /**
     * Parse query list from OpenAPI description.
     * @param producer
     *      Producer instance to assign to each Query object
     * @return
     *      list of <b>new</b> Query entities with query names initialized from OpenAPI description.
     *      Query entities have given producer assigned, but since each entity is new, no entities have
     *      ID-s, even if given query is already associated with the producer.
     */
    public List<Query> parseQueryList(Producer producer, String serviceCode) throws QueryException {
        List<Query> queryList = new ArrayList<Query>();
        
        // Add queries from operation map
        for (OperationData opData : operationMap.values()) {
            Operation op = opData.getOperation();
            
            Query query = new Query();
            queryList.add(query);
            query.setOpenapiServiceCode(serviceCode);
            query.setProducer(producer);
            query.setName(op.getOperationId());
            query.setType(producer.getIsComplex() ? QUERY_TYPE.X_ROAD_COMPLEX.ordinal() : QUERY_TYPE.X_ROAD.ordinal());
            List<QueryName> queryNameList = new ArrayList<QueryName>();
            query.setQueryNameList(queryNameList);
            {
                QueryName queryName = new QueryName();
                //queryName.setLang("en"); // default is en
                queryName.setLang(LanguageUtil.ALL_LANGUAGES);
                String description = op.getSummary();
                if (StringUtils.isBlank(description)) {
                    description = op.getDescription();
                }
                queryName.setDescription(op.getSummary()); // Description remains unused
                queryNameList.add(queryName);
            }
        }
        return queryList;
    }

    /**
     * Get producer name list from OpenAPI description.
     * @return list of new ProducerName entities with producer name extracted from OpenAPI model info title
     */
    public List<ProducerName> getProducerNameList() throws QueryException {
        // Add producer name(s)
        List<ProducerName> producerNameList = new ArrayList<ProducerName>();
        {
            ProducerName producerName = new ProducerName();
            producerName.setLang("en"); // default is en
            producerName.setDescription(model.getInfo().getTitle()); // Description remains unused
            producerNameList.add(producerName);
        }
        return producerNameList;
    }

    /**
     * Generate REST HTML form from OpenAPI description for given Query object.
     * @param query Query entity (with initialized Producer)
     * @return generated form HTML content for given Query as String
     * @throws QueryException on form generation failure 
     *      (e.g. if given query is not found from OpenAPI description)
     */
    public String generateForm(Query query) throws QueryException {
        String operationId = query.getName();
        Producer producer = query.getProducer();
        String methodPrefix = producer.getXroadInstance() + "/"
                + producer.getMemberClass() + "/"
                + producer.getShortName()
                + (StringUtils.isNotBlank(producer.getSubsystemCode()) ? 
                        "/" + producer.getSubsystemCode() : "")
                + (StringUtils.isNotBlank(query.getOpenapiServiceCode()) ? 
                        "/" + query.getOpenapiServiceCode() : "");
        return generateForm(operationId, methodPrefix);
    }
    
    /**
     * Generate form from OpenAPI description, given operation identifier and action prefix.
     * @param operationId
     *      OpenAPI operation ID that corresponds Query entity 'name' value
     * @param actionPrefix
     *      X-Road service path prepended to each security server request context path.
     *      Contains query producer X-road identifier (e.g. ee-dev/COM/12345678/testsystem).
     * @return generated form HTML string 
     * @see {@link #generateForm(Query)}
     */
    String generateForm(String operationId, String actionPrefix) throws QueryException {
        OperationData opData = operationMap.get(operationId);
        if (opData == null) {
            throw new QueryException(QueryException.Type.OPENAPI_QUERY_NOT_FOUND,
                    "Query was not found from OpenAPI description.", null);
        }
        String action = opData.getActionPath();
        if (actionPrefix != null) { // if actionPrefix exists, prepend it to action
            String sep = "";
            if (!actionPrefix.endsWith("/") && !action.startsWith("/")) {
                sep = "/";
            }
            action = actionPrefix + sep + action;
        }
        // Generate form with form builder
        OpenApiFormBuilder formBuilder = new OpenApiFormBuilder(
                opData.getMethod().toUpperCase(), action, opData.getOperation());
        return formBuilder.getForm();
    }

    /**
     * Container for OpenAPI operation and path to be used internally in this class as map value.
     */
    private class OperationData {
        private String method;
        private String actionPath;
        private Operation operation;
        public OperationData(String actionPath, String method, Operation operation) {
            this.method = method;
            this.actionPath = actionPath;
            this.operation = operation;
        }
        public String getActionPath() {
            return actionPath;
        }
        public String getMethod() {
            return method;
        }
        public Operation getOperation() {
            return operation;
        }
    }
}
