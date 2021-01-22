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

package ee.aktors.misp2.util.xroad.soap.wsdl;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.action.exception.QueryException;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.util.WSDLParser;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.query.meta.WsdlQuery;

/**
 * Collect query WSDL to LinkedHashMap with query operation name in WSDL as key and
 * populated WSDLParser as value. The latter also contains a document.
 * @author sander.kallo
 *
 */
public final class XRoadV6WsdlCollector {
    private static Logger log = LogManager.getLogger(XRoadV6WsdlCollector.class);

    private LinkedHashMap<String, WsdlContainer>  operationToWsdlContainerMap;
    private List<WsdlContainer>  uniqueWsdlContainers;
    private List<String>  missingOperations;
    private List<String>  processedOperations;
    private Producer producer = null;
    private Portal portal = null;
    
    /**
     * Initialize WSDL collector
     */
    public XRoadV6WsdlCollector() {
        operationToWsdlContainerMap = new LinkedHashMap<String, WsdlContainer>();
        uniqueWsdlContainers = new ArrayList<WsdlContainer>();
        missingOperations = new ArrayList<String>(0);
        processedOperations = new ArrayList<String>();
        producer = null;
        portal = null;
    }
    
    /**
     * @return {@link Iterator} over unique WsdlContainers added to current collector
     */
    public Iterator<WsdlContainer> iterator() {
        // find unique WsdlContainers
        return uniqueWsdlContainers.iterator();
    }

    /**
     * Request WSDL from security server corresponding to given query.
     * If WSDL has already been added to collector, skip querying WSDL again.
     * @param query entity current WSDL is collected
     * @throws QueryException on failure
     * @throws DataExchangeException on fault
     */
    public void collect(Query query) throws QueryException, DataExchangeException {
        if (producer == null) {
            producer = query.getProducer();
        }
        if (portal == null) {
            portal = producer.getPortal();
        }
        // WSDL operation name, serves as a key for WSDL container (same as X-Road service code)
        // the map structure avoids downloading WSDL again, if key (operation) already exist
        String operationName = getKey(query);
        log.debug("Operation name (original): " + operationName);
        // if operation has not been added to map, download WSDL and add it to map
        if (!operationToWsdlContainerMap.containsKey(operationName)) {
            // download WSDL if it has not been downloaded before
            this.add(query);
            log.debug("Adding WSDL container for " + operationName);
            
        } else { // operation has been added so the WSDL has been downloaded, not downloading the same WSDL again
            log.debug("Query " + query + " WSDL already downloaded. Skipping downloading the same file repeatedly.");
        }
        // at this point, operation key must be in the map with WSDL container as value, so request it
        WsdlContainer wsdlContainer = operationToWsdlContainerMap.get(operationName);
        if (wsdlContainer != null) {
            processedOperations.add(operationName);
            // add query to WSDL container in request map, associating it with given WSDL
            wsdlContainer.addAssociatedQuery(query);
        } else {
            missingOperations.add(operationName);
            log.error("Operation '" + operationName + "' not found from WSDL.");
        }
    }

    /**
     * Process query name, e.g. remove version if needed.
     * @param operationName op name with version
     * @return processed name
     */
    public static String processKey(String operationName) {
        return operationName;
    }
    
    private String getKey(Query query) {
        return processKey(query.getName()); // getName
    }
    
    /**
     * @return operations that were expected, but found to be missing from WSDL
     */
    public List<String> getMissingOperations() {
        return missingOperations;
    }
    
    /**
     * @return operations successfully parsed from WSDL
     */
    public List<String> getProcessedOperations() {
        return processedOperations;
    }
    
    /**
     * @return operations not parsed from WSDL
     */
    public List<String> getUnprocessedOperations() {
        List<String> unprocessedOperations =
                new ArrayList<String>(operationToWsdlContainerMap.keySet());
        unprocessedOperations.removeAll(missingOperations);
        unprocessedOperations.removeAll(processedOperations);
        return unprocessedOperations;
    }

    private WsdlContainer add(Query query) throws QueryException, DataExchangeException {
        WsdlContainer wsdlContainer = WsdlQuery.downloadWsdl(portal, producer, query);
        uniqueWsdlContainers.add(wsdlContainer);
        WSDLParser wsdlParser = new WSDLParser(
                wsdlContainer.getWsdlDocument(), portal.getXroadVersion());
        
        // add all operations in WSDL so to avoid adding new WSDL-s later
        for (String operation : wsdlParser.getOperations()) {
            String operationKey = processKey(operation);
            log.debug("Operation key (actually mapped): " + operationKey
                    + "| (full operation name: " + operation + ")");
            operationToWsdlContainerMap.put(operationKey, wsdlContainer);
        }
        return wsdlContainer;
    }

    /**
     * Log errors after collecting operations from WSDL
     * @throws QueryException if collecting some operations failed
     */
    public void checkError() throws QueryException {
        if (missingOperations.size() > 0) {
            List<String> unprocessedOperations = getUnprocessedOperations();
            String unprocessed = "";
            // There should be no unprocessed or missing operations.
            // If there are missing operations, see if there are version differences or
            // other inconsistencies between unprocessed and missing operations.
            if (unprocessedOperations.size() > 0) {
                unprocessed = "\n\t Unprocessed operations in WSDL:" + unprocessedOperations;
            }
            
            throw new QueryException(QueryException.Type.WSDL_MISSING_OPERATION,
                    "Missing operations or operation version inconsistencies"
                    + " in WSDL for: " + missingOperations
                    + unprocessed, null);
            
        }
    }
}
