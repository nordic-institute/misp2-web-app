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

package ee.aktors.misp2.util.xroad.soap.query.meta;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.util.Const.QUERY_TYPE;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.XRoad6SOAPMessageBuilder;

/**
 * List methods for given producer. Applies for X-Road v4, v5 and v6. In v4 or
 * v5, only ALLOWED_METHODS type can be used. In v6, query type may also be
 * LIST_METHODS which lists all the methods.
 * 
 * @author sander.kallo
 *
 */
public class ListMethodsQuery extends AbstractMisp2MetaQuery {

    private static Logger logger = LogManager.getLogger(ListMethodsQuery.class);
    /**
     * List methods query type: all or only allowed methods
     */
    public enum Type {
        LIST_METHODS("listMethods"), ALLOWED_METHODS("allowedMethods");
        String methodName;

        Type(String methodName) {
            this.methodName = methodName;
        }

        String getMethodName() {
            return methodName;
        }
    }

    private Type type;
    private Producer producer;

    /**
     * Initialize list methods query
     * @param type query type: all or only allowed
     * @param producer entity containing xrd:service data
     * @param org current user session organization
     * @throws DataExchangeException on failure
     */
    public ListMethodsQuery(Type type, Producer producer, Org org) throws DataExchangeException {
        super();
        this.producer = producer;

        if (isV6()) {
            this.type = type;
        } else {
            // earlier versions only have allowedMethods service method
            this.type = Type.ALLOWED_METHODS;
        }

        if (org != null)
            this.org = org;
    }

    @Override
    public String getServiceXRoadInstance() {
        return producer.getXroadInstance();
    }

    @Override
    public String getServiceMemberClass() {
        return producer.getMemberClass();
    }

    @Override
    public String getServiceMemberCode() {
        return producer.getShortName();
    }

    @Override
    public String getServiceSubsystemCode() {
        return producer.getSubsystemCode();
    }

    @Override
    public String getServiceCode() {
        return type.getMethodName();
    }

    @Override
    public String getServiceVersion() {
        return null;
    }

    @Override
    protected void initSOAPRequestBody() throws DataExchangeException {
        try {
            SOAPBody soapBody = soapRequestBuilder.getBody();
            soapBody.addChildElement(type.getMethodName(), soapRequestBuilder.getXRoadNamespace().getPrefix(),
                    soapRequestBuilder.getXRoadNamespace().getUri());
        } catch (SOAPException e) {
            throw new DataExchangeException(DataExchangeException.Type.XROAD_SOAP_BODY_INIT_FAILED,
                    "X-Road request SOAP body could not be initialized.", e);
        }
    }

    /**
     * Called after response has been received.
     * 
     * @return list of Query objects parsed from response
     */
    public List<Query> parseMethods() {

        logger.debug("Starting getMethods()");
        List<Query> methods = new ArrayList<Query>();
        SOAPElement responseElement;
        try {
            responseElement = (SOAPElement) soapResponse.getSOAPBody().getFirstChild();
            // earlier versions have another wrapper element called 'response'
            if (!isV6()) {
                responseElement = (SOAPElement) responseElement.getFirstChild();
            }
        } catch (SOAPException e) {
            e.printStackTrace();
            return methods;
        }
        Iterator<?> itServices = responseElement.getChildElements();

        logger.debug("Starting to iterate over response child elements");

        while (itServices.hasNext()) { // iterate over xrd:service sequence
            Object serviceObj = itServices.next();
            if (serviceObj instanceof SOAPElement) {
                SOAPElement serviceElement = (SOAPElement) serviceObj;
                Query query = new Query();

                if (soapRequestBuilder instanceof XRoad6SOAPMessageBuilder) {
                    String serviceCode = XRoadUtil.getChildTextByLocalName(serviceElement,
                            XRoad6SOAPMessageBuilder.SERVICE_CODE_TAG_NAME);
                    String serviceVersion = XRoadUtil.getChildTextByLocalName(serviceElement,
                            XRoad6SOAPMessageBuilder.SERVICE_VERSION_TAG_NAME);
                    query.setName(serviceCode, serviceVersion);
                } else {
                    String str = serviceElement.getTextContent();
                    logger.debug("Adding | " + str);
                    String[] identifierParts = str.split(Pattern.quote("."));

                    // set shortname + version (if the latter exists)
                    final int partsExpected = 3; // to work around RIA checkstyle limitations
                    query.setName(identifierParts[1], identifierParts.length == partsExpected
                        ? identifierParts[2] : null);
                }
                query.setProducer(producer);
                query.setType(QUERY_TYPE.X_ROAD.ordinal());
                methods.add(query);
                logger.debug("Adding query " + query.getName());
            }
        }

        return methods;
    }
}
