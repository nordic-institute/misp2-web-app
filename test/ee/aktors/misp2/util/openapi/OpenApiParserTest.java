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
package ee.aktors.misp2.util.openapi;

import static org.junit.Assert.*;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.junit.Test;

import com.networknt.oas.OpenApi3Parser;
import com.networknt.oas.model.OpenApi3;
import com.networknt.oas.model.Operation;
import com.networknt.oas.model.Path;
import com.networknt.oas.validator.ValidationResults.ValidationItem;

import ee.aktors.misp2.action.exception.QueryException;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.ProducerName;
import ee.aktors.misp2.model.Query;

/**
 * Test OpenApiParser class methods and related functionality.
 */
public class OpenApiParserTest {
    protected static Logger log = LogManager.getLogger(OpenApiParserTest.class);

    private OpenApi3 getModel() throws Exception {
        URI modelUri = getUri();
        return new OpenApi3Parser().parse(modelUri, true);
    }
    
    private URI getUri() throws URISyntaxException {
        return OpenApiParserTest.class.getResource("openapi-petstore-xroad.yaml").toURI();
    }

    /**
     * Test if OpenAPI YAML model is valid.
     */
    @Test
    public void testValidation() throws Exception {
        OpenApi3 model = getModel();
        //System.out.println(model.getValidationItems());
        if (!model.isValid()) {
            for (ValidationItem item : model.getValidationItems()) {
                log.warn(item);
            }
        }
        assertTrue("Model is valid", model.isValid());
        
        // Print out main model structure
        /*log.info(String.format("- Title: %s\n", model.getInfo().getTitle()));
        for (Path path : model.getPaths().values()) {
            log.info(String.format("-- Path %s:\n", Overlay.of(path).getPathInParent()));
            for (Operation op : path.getOperations().values()) {
                log.info(String.format("---  %s: [%s] %s\n", Overlay.of(op).getPathInParent().toUpperCase(),
                        op.getOperationId(), op.getSummary()));
                for (Parameter param : op.getParameters()) {
                    log.info(String.format("----    %s[%s]:, %s - %s\n", param.getName(), param.getIn(),
                            getParameterType(param),
                            param.getDescription()));
                }
            }
        }*/
    }
    
    /*private static String getParameterType(Parameter param) {
        Schema schema = param.getSchema();
        return schema != null ? schema.getType() : "unknown";
    }*/
    

    /**
     * Test that OpenAPI YAML model has existing operations.
     * @throws Exception
     */
    @Test
    public void testOperations() throws Exception {
        OpenApi3 model = getModel();
        int count = 0;
        for (Path path : model.getPaths().values()) {
            for (Operation op : path.getOperations().values()) {
                log.info("" + op.getOperationId() + " - " + op.getSummary());
                count++;
            }
        }
        assertTrue("At least one operation parsed from YAML", count > 0);
    }


    /**
     * Test parsing query list and producer names from YAML.
     */
    @Test
    public void testParseProducerQueryList() throws Exception {
        Producer producer = new Producer();
        OpenApiParser parser = new OpenApiParser(getUri());
        
        // Update producer name and desription
        List<ProducerName> producerNames = parser.getProducerNameList();
        assertEquals("Petstore", producerNames.get(0).getDescription());
        
        // Parse queries out
        List<Query> queryList = parser.parseQueryList(producer, "Petstore");
        List<String> queryNames = new ArrayList<String>();
        List<String> queryDescriptions = new ArrayList<String>();
        for (Query query : queryList) {
            queryNames.add(query.getName());
            String queryDescription = query.getActiveName("en").getDescription();
            queryDescriptions.add(queryDescription);
        }
        // Check if services are correctly given
        assertEquals(16, queryList.size());
        assertEquals(16, parser.operationMap.size());
        assertEquals(
                  "[getPets, addPet, getPetById, updatePet, deletePet,"
                + " uploadFile, getInventory, placeOrder, getOrderById, deleteOrder,"
                + " createUser, loginUser, logoutUser, getUserByName, updateUser, deleteUser"
                + "]", queryNames.toString());
        assertEquals(
                  "[Get pets from store, Add a new pet to the store, Find pet by ID, Update an existing pet, Deletes a pet,"
                + " Uploads an image, Returns pet inventories by status, Place an order for a pet, Find purchase order by ID, Delete purchase order by ID,"
                + " Create user, Logs user into the system, Logs out current logged in user session, Get user by user name, Updated user, Delete user"
                + "]", queryDescriptions.toString());
    }
    
    /**
     * Test form generation from OpenAPI description.
     */
    @Test
    public void testGenerateForm() throws QueryException, URISyntaxException {
        OpenApiParser parser = new OpenApiParser(getUri());
        String formHtml = parser.generateForm("getPets", "ee-dev/COM/12345678/petstore");
        log.debug("getPets:\n" + formHtml);
        assertTrue(formHtml.contains("html"));
        assertTrue(formHtml.contains("action=\"ee-dev/COM/12345678/petstore/pets\""));
        formHtml = parser.generateForm("updatePet", "ee-dev/COM/12345678/petstore");
        log.debug("updatePet:\n" + formHtml);
        assertTrue(formHtml.contains("action=\"ee-dev/COM/12345678/petstore/pets/"));
    }
}
