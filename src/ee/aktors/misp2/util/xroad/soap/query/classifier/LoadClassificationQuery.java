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

package ee.aktors.misp2.util.xroad.soap.query.classifier;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.NodeList;

import ee.aktors.misp2.model.Classifier;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.query.meta.AbstractMisp2MetaQuery;
import ee.aktors.misp2.util.xroad.soap.XMLNamespaceContainer;

/**
 * Load classifiers from X-Road service. Applies for X-Road versions 4, 5 and 6.
 * Loads both: - list of classifiers when classifier name is not defined request
 * and - classifier content, if classifier.name is defined in request. Query
 * format is not configurable, but fixed.
 * 
 * @author sander.kallo
 *
 */
public class LoadClassificationQuery extends AbstractMisp2MetaQuery {

    private static Logger logger = LogManager.getLogger(LoadClassificationQuery.class);

    private boolean responseProcessed;

    private Classifier classifier;
    private XMLNamespaceContainer bodyRootElementNamespace;

    /**
     * Initialize classifier query
     * @param classifier entity, non persistent entity without name if it is a list query
     * @throws DataExchangeException on initialization failure
     */
    public LoadClassificationQuery(Classifier classifier) throws DataExchangeException {
        super();
        this.classifier = classifier;

        if (!classifier.getXroadQueryXroadProtocolVer().equals(portal.getXroadProtocolVer())) {
            DataExchangeException e = new DataExchangeException(
                    DataExchangeException.Type.XROAD_QUERY_NOT_ALLOWED_IN_PORTAL,
                    "X-Road classifier + '" + classifier + "' query '"
                            + classifier.getXroadQueryMemberCode() + "' "
                            + " has different X-Road version "
                            + classifier.getXroadQueryXroadProtocolVer()
                            + " to portal " + portal.getShortName() + " ver "
                            + portal.getXroadProtocolVer()
                            + ". Only allowing queries with the same X-Road version.",
                    null);
            e.getParameters().add(classifier.getName());
            e.getParameters().add("" + classifier.getXroadQueryXroadProtocolVer());
            e.getParameters().add("" + portal.getXroadProtocolVer());
            throw e;
        }

        if (isV6()) {
            this.bodyRootElementNamespace = new XMLNamespaceContainer("prod",
                    classifier.getXroadQueryRequestNamespace());
        } else {
            this.bodyRootElementNamespace = this.soapRequestBuilder.getXRoadNamespace();
        }
        responseProcessed = false;
    }

    @Override
    public String getServiceXRoadInstance() {
        return classifier.getXroadQueryXroadInstance();
    }

    @Override
    public String getServiceMemberClass() {
        return classifier.getXroadQueryMemberClass();
    }

    @Override
    public String getServiceMemberCode() {
        return classifier.getXroadQueryMemberCode();
    }

    @Override
    public String getServiceSubsystemCode() {
        return classifier.getXroadQuerySubsystemCode();
    }

    @Override
    public String getServiceCode() {
        return classifier.getXroadQueryServiceCode();
    }

    @Override
    public String getServiceVersion() {
        return classifier.getXroadQueryServiceVersion();
    }

    /**
     * @return true, if current query is classifier list query, false if it is a specific classifier query
     */
    public boolean isClassifierListQuery() {
        return classifier.getName() == null;
    }

    @Override
    protected void initSOAPRequestBody() throws DataExchangeException {
        try {
            logger.debug("Initializing classification loading request.");
            SOAPBody soapBody = soapRequestBuilder.getBody();
            SOAPElement rootElement = soapBody.addChildElement(getServiceCode(), bodyRootElementNamespace.getPrefix(),
                    bodyRootElementNamespace.getUri());

            SOAPElement requestElement = rootElement.addChildElement(getRequestQName());
            SOAPElement classifierNameElement = requestElement.addChildElement("name");
            if (classifier.getName() != null) {
                classifierNameElement.setTextContent(classifier.getName());
            }
            requestElement.addChildElement("subset");
            requestElement.addChildElement("from");
            requestElement.addChildElement("max");
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_BODY_INIT_FAILED,
                    "X-Road request SOAP body could not be initialized.", e);
        }
    }

    /**
     * @return portal current classifier is queried from
     */
    public Portal getPortal() {
        return portal;
    }

    /**
     * Add retrieved classifiers to clNameList or fill classifier entity with response data
     * @param clNameList classifier name list
     * @throws SOAPException on failure
     * @throws IOException on failure
     */
    public void processResponse(List<String> clNameList) throws SOAPException, IOException {

        if (super.hasResponse()) {
            if (isClassifierListQuery()) { // get cl names
                NodeList nodeList = soapResponse.getSOAPBody().getElementsByTagName("item"); // find:
                                                                                                // classifierNames/item
                                                                                                // elements
                for (int cnt = 0; cnt < nodeList.getLength(); cnt++) {
                    String name = nodeList.item(cnt).getTextContent();
                    clNameList.add(name);
                }
                responseProcessed = true;
            } else { // get cl content
                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                soapResponse.writeTo(bos);
                String xmlmessage = bos.toString("UTF-8");

                int beginIdx = xmlmessage.indexOf("<classifications>");
                beginIdx += "<classifications>".length();
                int endIdx = xmlmessage.indexOf("</classifications>");
                if (endIdx > -1) {
                    String classifierRawContent = xmlmessage.substring(beginIdx, endIdx);
                    logger.debug("<" + classifier.getName() + ">" + classifierRawContent + "</" + classifier.getName()
                            + ">");
                    classifier.setContent("<" + classifier.getName() + ">" + classifierRawContent + "</"
                            + classifier.getName() + ">");
                }
                responseProcessed = true;
            }
        } else {
            throw new RuntimeException("No query response received, cannot process response");
        }
    }

    /**
     * @return classifier entity
     */
    public Classifier getClassifier() {
        return classifier;
    }

    @Override
    public boolean hasResponse() {
        return responseProcessed;
    }
}
