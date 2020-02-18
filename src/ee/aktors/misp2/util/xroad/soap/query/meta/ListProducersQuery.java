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

package ee.aktors.misp2.util.xroad.soap.query.meta;

import java.util.ArrayList;
import java.util.List;

import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;

import org.apache.commons.lang.NotImplementedException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.ProducerName;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * Request producer list from security server. The query only applies to x-road
 * v4 and v5. X-Road v6 uses GET query, not an SOAP query, and is implemented
 * elsewhere for this reason.
 * 
 * @author sander.kallo
 */
public class ListProducersQuery extends AbstractMisp2MetaQuery {

    private static Logger logger = LogManager.getLogger(ListProducersQuery.class);

    private List<Producer> producers;
    private List<ProducerName> producerNames;
    private boolean responseProcessed;

    /**
     * NB! do not use from X-Road v6 portal, otherwise
     * {@link NotImplementedException} is thrown. Get producer list in X-Road v4
     * and v5. X-Road v6 uses get query so it is implemented separately from
     * X-Road SOAP queries.
     * 
     * @throws DataExchangeException on failure
     */
    public ListProducersQuery() throws DataExchangeException {
        super();
        if (isV6()) {
            throw new NotImplementedException("Cannot initialize v6 listProducers SOAP query. "
                    + "listProducers meta-service has been removed from X-Road v6.");
        }
        responseProcessed = false;
        producers = new ArrayList<Producer>();
        producerNames = new ArrayList<ProducerName>();
    }

    @Override
    public String getServiceXRoadInstance() {
        return null;
    }

    @Override
    public String getServiceMemberClass() {
        return null;
    }

    @Override
    public String getServiceMemberCode() {
        return getMetaServiceMemberCode();
    }

    @Override
    public String getServiceSubsystemCode() {
        return null;
    }

    @Override
    public String getServiceCode() {
        return Const.LIST_PRODUCERS;
    }

    @Override
    public String getServiceVersion() {
        return null;
    }

    @Override
    protected void initSOAPRequestBody() throws DataExchangeException {
        try {
            logger.debug("Initializing listProducers request.");
            SOAPBody soapBody = soapRequestBuilder.getBody();
            SOAPElement rootElement = soapBody.addChildElement(getServiceCode(),
                    soapRequestBuilder.getXRoadNamespace().getPrefix(),
                    soapRequestBuilder.getXRoadNamespace().getUri());

            rootElement.addChildElement(getRequestQName());
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_BODY_INIT_FAILED,
                    "X-Road request SOAP body could not be initialized.", e);
        }

    }

    /**
     * @return portal through which current user is performing the query
     */
    public Portal getPortal() {
        return portal;
    }

    /**
     * Fill activeList with active producers from SOAP response.
     * Also add producers to list 'producers'.
     * @param activeList list to be filled with active producers
     * @throws SOAPException on response reading failure
     */
    public void processResponse(List<Producer> activeList) throws SOAPException {
        if (super.hasResponse()) {
            NodeList nodeList = soapResponse.getSOAPBody().getElementsByTagName("item"); // find:
                                                                                            // keha/item
            for (int s = 0; s < nodeList.getLength(); s++) {
                Node child = nodeList.item(s);
                if (child.getNodeType() == Node.ELEMENT_NODE) {
                    Element root = (Element) child;
                    // get names
                    NodeList listOfNames = root.getElementsByTagName("name");
                    Element names = (Element) listOfNames.item(0);
                    NodeList name = names.getChildNodes();
                    // get descriptions
                    NodeList listOfDescriptions = root.getElementsByTagName("description");
                    Element descriptions = (Element) listOfDescriptions.item(0);
                    NodeList description = descriptions.getChildNodes();

                    Producer temp = new Producer();
                    temp.setShortName(name.item(0).getNodeValue().toString());
                    ProducerName tempProducerName = new ProducerName();
                    tempProducerName.setProducer(temp);
                    tempProducerName.setDescription(description.item(0).getNodeValue().toString());
                    tempProducerName.setLang(ActionContext.getContext().getLocale().getLanguage());
                    producerNames.add(tempProducerName);
                    temp.setInUse(false);

                    for (int z = 0; z < activeList.size(); z++) { // if producer
                                                                    // with that
                                                                    // name is
                                                                    // active
                                                                    // then set
                                                                    // temporary
                                                                    // producer
                                                                    // to active
                        if (name.item(0).getNodeValue().toString().equalsIgnoreCase(activeList.get(z).getShortName())) {
                            temp.setInUse(true);
                        }
                    }
                    temp.setPortal(portal);
                    producers.add(temp); // add producer to list
                }
            }
            responseProcessed = true;
        } else {
            throw new RuntimeException("No query response received, cannot process response");
        }
    }

    @Override
    public boolean hasResponse() {
        return responseProcessed;
    }

    /**
     * @return producers list
     */
    public List<Producer> getProducers() {
        return producers;
    }
    
    /**
     * @return producer name list
     */
    public List<ProducerName> getProducerNames() {
        return producerNames;
    }
}
