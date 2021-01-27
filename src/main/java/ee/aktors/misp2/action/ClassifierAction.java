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

package ee.aktors.misp2.action;

import java.util.ArrayList;
import java.util.List;

import javax.xml.soap.SOAPConnection;
import javax.xml.soap.SOAPConnectionFactory;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Classifier;
import ee.aktors.misp2.model.Query;
import ee.aktors.misp2.service.ClassifierService;
import ee.aktors.misp2.service.QueryService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Const.XROAD_VERSION;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.query.classifier.LoadClassificationQuery;

/**
 */
public class ClassifierAction extends SessionPreparedBaseAction {
    private static final long serialVersionUID = 5215745917038458214L;
    private ClassifierService classifierService;
    private QueryService queryService;
    private List<Classifier> classifierList;
    private List<Classifier> systemClassifierList;
    private List<Query> queryList;
    private Integer queryId;
    private String classifierName;
    private Integer classifierId;
    private List<String> clNameList;
    private SOAPConnectionFactory soapConnectionFactory;
    private static final Logger LOG = LogManager.getLogger(ClassifierAction.class);

    /**
     * @param classifierService to inject
     * @param queryService to inject
     * @param soapConnectionFactory to inject
     */
    public ClassifierAction(ClassifierService classifierService, QueryService queryService,
            SOAPConnectionFactory soapConnectionFactory) {
        super();
        this.classifierService = classifierService;
        this.queryService = queryService;
        this.soapConnectionFactory = soapConnectionFactory;
    }

    /**
     * @return SUCCESS
     * @throws Exception can throw
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String listClassifiers() throws Exception {
        classifierList = classifierService.findAll();
        systemClassifierList = classifierService.findAllSystem();
        return SUCCESS;
    }
    
    /**
     * @return SUCCESS
     * @throws Exception can throw
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String listClassifierQuerys() throws Exception {
        queryList = queryService.findQueriesByQueryNameOnly(Const.CLASSIFIER_SERVICE, portal);
        return SUCCESS;
    }

    /**
     * @return SUCCESS if successful, ERROR if classifier loading fails
     * @throws Exception can throw
     */
    @HTTPMethods(methods = { HTTPMethod.GET, HTTPMethod.POST })
    public String updateClassifier() throws Exception {
        SOAPConnection connection = null;
        try {
            connection = soapConnectionFactory.createConnection();
            Classifier classifier = null;

            if (classifierName != null) {
                classifier = classifierService.findClassifierByName(classifierName);
            }
            Query query = null;
            if (queryId != null) {
                LOG.debug("Finding " + queryId);
                // both name and ID is specified for security: so that only loadClassification methods can be used
                // otherwise user alters queryId manually and could potentially run a different service from here
                query = queryService.findQueryByIdAndName(queryId, Const.CLASSIFIER_SERVICE);
                if (classifierName == null) {
                    LOG.debug("Querying classifier from X-Road by " + query + " classifierName " + classifierName);
                } else {
                    LOG.debug("Querying classifier list from X-Road by " + query);
                }
                if (classifier == null) {
                    LOG.debug("Initing new classifier" + (classifierName != null ? " '" + classifierName + "'" : "")
                            + " with query " + query);
                    classifier = classifierService.createNewClassifer(query, classifierName);
                } else {
                    LOG.debug("Updating classifier '" + classifier + " ' with query " + query);
                }
            }
            // else is classifier update

            if (classifier != null && !classifier.isSystemClassifier()) {
                // request namespace is needed only for X-Road protocol v6, so make sure both query and portal are
                // X-Road v6
                // this branch is not executed on classifier refresh, because then
                // classifier.getXroadQueryRequestNamespace() != null
                if (portal.isV6()
                        && XROAD_VERSION.V6.getProtocolVersion().equals(classifier.getXroadQueryXroadProtocolVer())
                        && classifier.getXroadQueryRequestNamespace() == null) {
                    // if query does not have namespace, get if from WSDL and save to query entity
                    if (query.getXroadRequestNamespace() == null) {
                        // for X-Road v6 get namesapce URI from generated XForms
                        String requestNamespaceUri = queryService.getQueryNamespaceUriFromWsdl(portal, classifier);
                        LOG.debug("Found query namespace from WSDL: " + requestNamespaceUri);
                        //
                        query.setXroadRequestNamespace(requestNamespaceUri);
                        queryService.save(query);
                        classifier.setXroadQueryRequestNamespace(requestNamespaceUri);
                    } else {
                        // if query does have a namespace, get it from query entity,
                        // that avoids repeatedly getting it from WSDL
                        LOG.debug("Found query namespace from query entity: " + query.getXroadRequestNamespace());
                        classifier.setXroadQueryRequestNamespace(query.getXroadRequestNamespace());
                    }
                }
                LoadClassificationQuery xRoadQuery = new LoadClassificationQuery(classifier);
                xRoadQuery.createSOAPRequest();
                xRoadQuery.sendRequest();

                clNameList = new ArrayList<String>();
                // automatically fill clNameList or classifier entity
                xRoadQuery.processResponse(clNameList);
                if (xRoadQuery.hasResponse() && !xRoadQuery.isClassifierListQuery()) {
                    // getter used for classifier in case new instance was created during processing
                    classifierService.save(xRoadQuery.getClassifier());
                    addActionMessage(getText("classifier.loaded") + ": " + classifierName);
                } else if (!xRoadQuery.isClassifierListQuery()) {
                    addActionError(getText("classifier.error.load_failed"));
                    return ERROR;
                }
                // else : do nothing when xRoadQuery.isClassifierListQuery(), clNameList has already been filled in
                // processResponse
            }
        } catch (DataExchangeException e) {
            if (e.getType() == DataExchangeException.Type.XROAD_QUERY_NOT_ALLOWED_IN_PORTAL) {
                LOG.warn("Loading classifier failed because of X-Road version incompatibility. " + e.getMessage());
                addActionError(getText("classifier.error.portal_mismatch", e.getParameters()));
                return ERROR;
            } else {
                LOG.error("Loading classifier failed", e);
                addActionError(getText("classifier.error.load_failed") + e.getFaultSummary());
                return ERROR;
            }
        } catch (Exception e) {
            LOG.error("Loading classifier failed", e);
            addActionError(getText("classifier.error.load_failed"));
            return ERROR;
        } finally {
            try {
                connection.close();
            } catch (Exception e) {
                LOG.warn(e.getMessage());
            }
        }
        return SUCCESS;
    }

    /**
     * @return SUCCESS
     * @throws Exception
     *             can throw
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String removeClassifier() throws Exception {
        Classifier classifier = classifierService.findObject(Classifier.class, classifierId);
        classifierService.remove(classifier);
        addActionMessage(getText("classifier.deleted"));
        return SUCCESS;
    }

    /**
     * @return the classifierList
     */
    public List<Classifier> getClassifierList() {
        return classifierList;
    }

    /**
     * @param classifierListNew the classifierList to set
     */
    public void setClassifierList(List<Classifier> classifierListNew) {
        this.classifierList = classifierListNew;
    }

    /**
     * @return the systemClassifierList
     */
    public List<Classifier> getSystemClassifierList() {
        return systemClassifierList;
    }

    /**
     * @param systemClassifierListNew the systemClassifierList to set
     */
    public void setSystemClassifierList(List<Classifier> systemClassifierListNew) {
        this.systemClassifierList = systemClassifierListNew;
    }

    /**
     * @return the queryList
     */
    public List<Query> getQueryList() {
        return queryList;
    }

    /**
     * @param queryListNew the queryList to set
     */
    public void setQueryList(List<Query> queryListNew) {
        this.queryList = queryListNew;
    }

    /**
     * @return the queryId
     */
    public Integer getQueryId() {
        return queryId;
    }

    /**
     * @param queryIdNew the queryId to set
     */
    public void setQueryId(Integer queryIdNew) {
        this.queryId = queryIdNew;
    }

    /**
     * @return the classifierName
     */
    public String getClassifierName() {
        return classifierName;
    }

    /**
     * @param classifierNameNew the classifierName to set
     */
    public void setClassifierName(String classifierNameNew) {
        this.classifierName = classifierNameNew;
    }

    /**
     * @return the classifierId
     */
    public Integer getClassifierId() {
        return classifierId;
    }

    /**
     * @param classifierIdNew the classifierId to set
     */
    public void setClassifierId(Integer classifierIdNew) {
        this.classifierId = classifierIdNew;
    }

    /**
     * @return the clNameList
     */
    public List<String> getClNameList() {
        return clNameList;
    }

    /**
     * @param clNameListNew the clNameList to set
     */
    public void setClNameList(List<String> clNameListNew) {
        this.clNameList = clNameListNew;
    }




}
