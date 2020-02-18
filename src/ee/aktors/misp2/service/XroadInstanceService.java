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

package ee.aktors.misp2.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.configuration.Configuration;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.transaction.annotation.Transactional;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.XroadInstance;
import ee.aktors.misp2.provider.ConfigurationProvider;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.xroad.XRoadInstanceUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * XroadInstanceService service, saving, retrieving and manipulation of
 * service X-Road instances in given portal.
 */
@Transactional(readOnly=true)
public class XroadInstanceService extends BaseService {

    private static Logger logger = LogManager.getLogger(XroadInstanceService.class);

    /**
     * Get XroadInstance entities for given portal where inUse is true.
     * NB! Instances are detached from Hibernate session: the modifications are not persisted.
     * @param portal portal associated with XroadInstances
     * @return a list of the results
     */
    @SuppressWarnings("unchecked")
    public List<XroadInstance> findActiveInstances(Portal portal) {
        javax.persistence.Query s = getEntityManager().createQuery(
                "select x FROM XroadInstance x where x.inUse=true and"
                + " x.portal.id=:portalId order by created");
        return detach(s.setParameter("portalId", portal.getId()).getResultList());
    }
    
    private List<XroadInstance> detach(List<XroadInstance> xroadInstances) {
        for (XroadInstance xroadInstance : xroadInstances) {
            getEntityManager().detach(xroadInstance);
        }
        return xroadInstances;
    }
    
    /**
     * Get all XroadInstance entities for given portal
     * @param portal portal associated with XroadInstances
     * @return a list of the results
     */
    @SuppressWarnings("unchecked")
    public List<XroadInstance> findInstances(Portal portal) {
        javax.persistence.Query s = getEntityManager().createQuery(
                "select x FROM XroadInstance x where x.portal.id=:portalId order by created");
        return s.setParameter("portalId", portal.getId()).getResultList();
    }

    /**
     * @return list of XroadInstances from webapp configuration
     *  NB! Returned XRoad instances are not persisted in DB
     */
    public List<XroadInstance> getDefaultInstances() {
        List<String> instanceCodes = XRoadInstanceUtil.getDefaultInstances();
        List<XroadInstance> xroadInstances = new ArrayList<XroadInstance>();
        for (String instanceCode : instanceCodes) {
            XroadInstance xroadInstance = new XroadInstance();
            xroadInstance.setCode(instanceCode);
            xroadInstance.setInUse(true);
            xroadInstances.add(xroadInstance);
        }
        return xroadInstances;
    }
    
    /**
     * Save service xroad instances, preserver order
     * @param serviceXroadInstances service xroad instances for given portal
     * @param portal portal to which instances are saved
     */
    @Transactional(readOnly=false)
    public void save(List<XroadInstance> serviceXroadInstances, Portal portal) {
        if (serviceXroadInstances == null || serviceXroadInstances.size() == 0) {
            logger.debug("Service X-Road v6 instances not saved (none given as input).");
        } else {
            logger.debug("Saving X-Road v6 instances.");
            // Add code->instance mappings for new instances
            LinkedHashMap<String, XroadInstance> newMappings = mapCodeToInstance(serviceXroadInstances);
            
            // Find all existing instances for given portal
            List<XroadInstance> existingInstances = this.findInstances(portal);
            // Add code->instance mappings for existing instances
            LinkedHashMap<String, XroadInstance> existingMappings = mapCodeToInstance(existingInstances);
            
            // Pre-process input serviceXroadInstances
            // set inUse and selected to non-null values
            preprocessInstances(serviceXroadInstances);
            
            // To preserve instance order in DB, entries are all deleted and then recreated,
            // if incoming instances are out of order. Otherwise instances are simply updated
            boolean recreateAll = !XRoadInstanceUtil.containsOrderedSubset(
                    existingMappings.keySet(), newMappings.keySet());
            if (recreateAll) {
                logger.debug("Re-create all X-Road instance entries "
                        + "(delete all existing for portal and then create)");
                logger.debug("1. X-Road v6 instances to be deleted: " + existingMappings.keySet());
                for (String code: existingMappings.keySet()) {
                    XroadInstance deletedInstance = existingMappings.get(code);
                    logger.debug("Deleting " + deletedInstance);
                    this.remove(deletedInstance);
                }
                // Need to call flush() here, otherwise Hibernate commits deletes after creates causing
                // uniqueness constraint failure
                getEntityManager().flush();
                logger.debug("2. X-Road v6 instances to be added: " + newMappings.keySet());
                for (String code: newMappings.keySet()) {
                    XroadInstance newInstance = newMappings.get(code);
                    newInstance.setPortal(portal);
                    if (newInstance.getInUse() == null) {
                        newInstance.setInUse(false);
                    }
                    if (newInstance.getSelected() == null) {
                        newInstance.setInUse(false);
                    }
                    logger.debug("Creating " + newInstance);
                    this.save(newInstance);
                }
            } else {
                logger.debug("Only update (and delete if needed) X-Road instance entries,"
                        + " no need to create new ones");
                // Update existing elements
                Set<String> matchingCodes = new LinkedHashSet<String>(existingMappings.keySet());
                matchingCodes.retainAll(newMappings.keySet());
                logger.debug("1. X-Road v6 instances updated: " + matchingCodes);
                for (String code : matchingCodes) {
                    XroadInstance existingInstance = existingMappings.get(code);
                    XroadInstance newInstance = newMappings.get(code);
                    boolean changed = copyParameters(newInstance, existingInstance);
                    if (changed) {
                        logger.debug("Saving " + existingInstance);
                        this.save(existingInstance);
                    }
                }
                // Delete removed elements
                Set<String> deletedCodes = new LinkedHashSet<String>(existingMappings.keySet());
                deletedCodes.removeAll(newMappings.keySet());
                logger.debug("2. X-Road v6 instances to be deleted: " + deletedCodes);
                for (String code: deletedCodes) {
                    XroadInstance deletedInstance = existingMappings.get(code);
                    logger.debug("Deleting " + deletedInstance);
                    this.remove(deletedInstance);
                }
            }
            
        }
    }

    private LinkedHashMap<String, XroadInstance> mapCodeToInstance(List<XroadInstance> serviceXroadInstances) {
        LinkedHashMap<String, XroadInstance> mappings = new LinkedHashMap<String, XroadInstance>();
        for (XroadInstance inst : serviceXroadInstances) {
            if (inst != null && inst.getCode() != null) {
                mappings.put(inst.getCode(), inst);
            }
        }
        return mappings;
    }
    /**
     * Replace 'null' values in #inUse and #selected fields
     * and set correct #selected for each X-Road instance group.
     * Set #selected to true to only one instance entry (actually the first) per portal.
     * @param serviceXroadInstances X-Road instance group for given portal;
     *  the entities in this list are modified
     */
    private void preprocessInstances(List<XroadInstance> serviceXroadInstances) {
        // remove null-elements
        serviceXroadInstances.removeAll(Collections.singleton(null));
        
        boolean hasDefault = false;
        for (XroadInstance xroadInstance: serviceXroadInstances) {
            if (xroadInstance.getSelected() != null && xroadInstance.getSelected() == true) {
                hasDefault = true;
                break;
            }
        }
        // if there is no default element defined, set default to first instance in use
        if (!hasDefault) {
            boolean defaultSet = false; // flag used to set only first element as default
            for (XroadInstance xroadInstance: serviceXroadInstances) {
                if (xroadInstance.getInUse() == null) {
                    xroadInstance.setInUse(false);
                }
                if (!defaultSet && xroadInstance.getSelected() == null
                        && xroadInstance.getInUse() == true) {
                    xroadInstance.setSelected(true);
                    defaultSet = true;
                } else {
                    xroadInstance.setSelected(false);
                }
            }
        } else {
            for (XroadInstance xroadInstance: serviceXroadInstances) {
                if (xroadInstance.getInUse() == null) {
                    xroadInstance.setInUse(false);
                }
                if (xroadInstance.getSelected() == null) {
                    xroadInstance.setSelected(false);
                }
            }
        }
    }
    
    private boolean copyParameters(XroadInstance sourceInstance, XroadInstance targetInstance) {
        boolean changed = false;
        if (sourceInstance.getInUse() != targetInstance.getInUse()) {
            targetInstance.setInUse(sourceInstance.getInUse());
            changed = true;
        }
        if (sourceInstance.getSelected() != targetInstance.getSelected()) {
            targetInstance.setSelected(sourceInstance.getSelected());
            changed = true;
        }
        return changed;
    }
    
    /**
     * @param portal current portal
     * @return X-Road v6 instance codes for X-Road instances allowed in portal (inUse == true)
     */
    public Set<String> getActiveInstanceCodes(Portal portal) {
        // Active X-Road instances can be listed only for X-Road v6
        if (!portal.isV6()) {
            return null;
        }
        
        // Find existing active instances for given portal
        List<XroadInstance> activeInstances = findActiveInstances(portal);
        // Add code->instance mappings for existing instances
        Map<String, XroadInstance> activeMappings = mapCodeToInstance(activeInstances);
        
        return activeMappings.keySet();
    }
    
    /**
     * Check if incoming X-Road v6 instance codes are among allowed X-Road instances in portal and
     * return instance codes for those received instances with inUse == true.
     * #inUse field in #serviceXroadInstances marks whether instance code of given instance
     * is added to returned list or whether it is not.
     * @param portal current portal
     * @param serviceXroadInstances input X-Road instances for given portal
     * @return instance codes from input list with inUse property set to true
     * @throws DataExchangeException in case a received instance is not active for given portal
     */
    public List<String> getSelectedInstanceCodes(Portal portal, List<XroadInstance> serviceXroadInstances)
            throws DataExchangeException {
        // X-Road instances can be listed only for X-Road v6
        if (!portal.isV6()) {
            return null;
        }
        
        // Find mappings of input instances
        Map<String, XroadInstance> receivedMappings = mapCodeToInstance(serviceXroadInstances);
        
        // Add code->instance mappings for existing instances
        Set<String> activeInstanceCodes = getActiveInstanceCodes(portal);
        
        List<String> instanceCodesUsed = new ArrayList<String>();
        for (String instanceCode : receivedMappings.keySet()) {
            XroadInstance receivedInstance = receivedMappings.get(instanceCode);
            logger.trace(instanceCode + " : "
                    + "id:" + receivedInstance.getId() + " "
                    + "code:" + receivedInstance.getCode() + " "
                    + "selected:" +  receivedInstance.getSelected() + " "
                    + "inUse:" +  receivedInstance.getInUse() + " "
                    + "portal:" +  receivedInstance.getPortal());
            Boolean selected = receivedInstance.getSelected();
            if (selected != null && selected == true) {
                logger.debug("Instance selected: " + instanceCode);
                if (activeInstanceCodes.contains(instanceCode)) {
                    instanceCodesUsed.add(instanceCode);
                } else {
                    throw new DataExchangeException(
                            DataExchangeException.Type.XROAD_INSTANCE_NOT_ACTIVE_FOR_PORTAL,
                            "Service X-Road instance '" + instanceCode
                            + "' is not active for portal '" + portal.getShortName() + "'.", null,
                            instanceCode);
                }
            } else {
                logger.debug("Instance not selected: " + instanceCode);
            }
        }
        return instanceCodesUsed;
    }
    /**
     * Set serviceXroadInstance.selected = true for list of instance entities.
     * @param serviceXroadInstances list of instance entities
     * @param selectedXroadInstanceCodeObjs
     *          list of instance code strings. Each code represents selected instance.
     *          All other instances are set unselected (serviceXroadInstance.selected = false).
     *          List does not have a type to avoid casting issues. List items are assumbed to be
     *          strings.
     */
    public void setSelected(List<XroadInstance> serviceXroadInstances,
            List<?> selectedXroadInstanceCodeObjs) {
        // Add instances to a set for quick contains-check
        Set<String> xroadInstanceCodes = new HashSet<String>();
        for (Object xroadInstanceCodeObj : selectedXroadInstanceCodeObjs) {
            xroadInstanceCodes.add((String)xroadInstanceCodeObj);
        }
        // Check if instances are among selected codes and adjust "selected" parameter
        // of #serviceXroadInstances
        for (XroadInstance serviceXroadInstance : serviceXroadInstances) {
            if (xroadInstanceCodes.contains(serviceXroadInstance.getCode())) {
                serviceXroadInstance.setSelected(true);
            } else {
                serviceXroadInstance.setSelected(false);
            }
        }
    }
    
    private XroadInstance find(Portal portal, String code) {
        javax.persistence.Query s = getEntityManager()
                .createQuery(
                    "select x FROM XroadInstance x where"
                    + " x.portal.id=:portalId and x.code=:code order by created")
                .setParameter("portalId", portal.getId())
                .setParameter("code", code);
        List<?> xroadInstances = s.getResultList();
        if (xroadInstances.size() == 0) {
            return null;
        } else if (xroadInstances.size() == 1) {
            return (XroadInstance)xroadInstances.get(0);
        } else { // DB constraint takes care that this scenario will not happen
            throw new RuntimeException(
                    "Internal error. Multiple X-Road instances returned."
                     + "Portal " + portal.getId() + ", code: " + code);
        }
    }
    
    /**
     * Create or update X-Road instance in the database. Instance is modified if
     * an entry with given portal ID and code already exists in the DB.
     * @param xroadInstance X-Road instance to be persisted or modified
     * @return persisted entity
     */
    @Transactional(readOnly=false)
    public XroadInstance persistXroadInstance(XroadInstance xroadInstance) {
        XroadInstance existingXroadInstance = find(xroadInstance.getPortal(), xroadInstance.getCode());
        if (existingXroadInstance != null) {
            existingXroadInstance.setInUse(xroadInstance.getInUse());
            existingXroadInstance.setSelected(xroadInstance.getSelected());
            logger.debug("Updateing existing X-Road instance '" + xroadInstance + "' to DB.");
            return super.save(existingXroadInstance);
        } else {
            logger.debug("Saving new X-Road instance '" + xroadInstance + "' to DB.");
            return super.save(xroadInstance);
        }
    }
    
    /**
     * Validate user input of X-Road instances.
     * @param portal current portal
     * @param serviceXroadInstances user input of X-Road instances that need to be validated
     * @return true if instances are valid, false if some are invalid
     */
    public String validateXroadInstances(Portal portal, List<XroadInstance> serviceXroadInstances) {
        String errorCode = null;
        if (!portal.isV6()) {
            errorCode = null; // portal is not v6: do not validate X-Road instances
        } else if (serviceXroadInstances == null) {
            logger.error("X-Road v6 portal has no X-Road instances (null). Must have at least 1.");
            errorCode = "portal.error.service_xroad_instances_missing";
        } else {
            // validate instance codes being not null
            List<String> codes = new ArrayList<String>();
            for (XroadInstance inst : serviceXroadInstances) {
                if (inst != null) {
                    String code = inst.getCode();
                    if (code != null) {
                        codes.add(code);
                    } else {
                        logger.error("Portal form has null-valued X-Road instance codes.");
                        errorCode = "portal.error.service_xroad_instances";
                    }
                }
            }
            if (codes.size() == 0) {
                logger.error("X-Road v6 portal has no X-Road instances (size 0). Must have at least 1.");
                errorCode = "portal.error.service_xroad_instances_missing";
            }
            // make sure there are
            // validate uniqueness of instance codes
            Map<String, Integer> codeCounts = new LinkedHashMap<String, Integer>();
            List<String> repeatedCodes = new ArrayList<String>();
            for (String code : codes) {
                if (!codeCounts.containsKey(code)) {
                    codeCounts.put(code, 1);
                } else {
                    Integer count = codeCounts.get(code) + 1;
                    codeCounts.put(code, count);
                    if (count == 2) {
                        repeatedCodes.add(code);
                    }
                }
            }
            if (repeatedCodes.size() > 0) {
                logger.error("Portal form has repeated service X-Road instance codes: "
                        + repeatedCodes);
                errorCode = "portal.error.service_xroad_instances";
            }
            
            // validate length of X-Road instance codes
            List<String> tooLongCodes = new ArrayList<String>();
            for (XroadInstance inst : serviceXroadInstances) {
                if (inst != null) {
                    String code = inst.getCode();
                    if (code != null && code.length() > Const.XROAD_INSTANCE_MAX_LENGTH) {
                        tooLongCodes.add(code);
                    }
                }
            }
            if (tooLongCodes.size() > 0) {
                logger.error("Portal form has service X-Road instance codes that are too long: "
                        + tooLongCodes);
                errorCode = "portal.error.service_xroad_instances";
            }
        }
        return errorCode;
    }

    
    // --- Session X-Road instance code management methods
    /**
     * Map-wrapper holding active X-Road instances of current HTTP session,
     * but also containing lastModified field to check cache expiration.
     * The map is cached in session to reduce active X-Road instance DB queries
     * in MediatorServlet.
     */
    private static final class InstanceCodeMap extends LinkedHashSet<String> {
        private static final long serialVersionUID = 7545132196824062544L;
        long lastModified;
        
        private InstanceCodeMap(int size) {
            super(size);
            lastModified = System.currentTimeMillis();
        }

        @Override
        public boolean add(String code) {
            boolean result = super.add(code);
            lastModified = System.currentTimeMillis();
            return result;
        }

        public boolean hasExpired() {
            final String confKey = "sessionCacheExpirationInterval"; // in minutes
            Configuration config = ConfigurationProvider.getConfig();
            if (config.containsKey(confKey)) { // key exists in conf, read its value and test expiration
                final int millisPerSecond = 1000;
                final int secondsPerMinute = 60;
                double millisSinceLastChange = (double)(System.currentTimeMillis() - lastModified);
                double minutesSinceLastChange = millisSinceLastChange / millisPerSecond / secondsPerMinute;
                
                Double expirationInterval = config.getDouble(confKey);
                return expirationInterval != null
                        && minutesSinceLastChange > expirationInterval.doubleValue();
            } else { // NB! if key is missing from conf, session instance codes do NOT expire
                return false;
            }
        }

        public String getActiveXroadInstance(String xroadInstanceCode) {
            // If instance is active, return true instantly
            if (this.contains(xroadInstanceCode)) {
                return xroadInstanceCode;
            }
            // If instance is not active, see if there are any similar instances that are active
            String xroadInstanceGroup = extractGroupIdentifier(xroadInstanceCode);
            for (String activeInstanceCode : this) {
                String activeInstanceGroup = extractGroupIdentifier(activeInstanceCode);
                if (xroadInstanceGroup.equals(activeInstanceGroup)) {
                    logger.debug("Matched incoming X-Road instance '" + xroadInstanceCode + "'"
                            + " with active instance '" + activeInstanceCode + "'"
                            + " based on instance group identifier '" + activeInstanceGroup + "'.");
                    return activeInstanceCode;
                }
            }
            // If match was not found, return false
            return null;
        }

        private String extractGroupIdentifier(String xroadInstanceCode) {
            // X-Road instance is split to tokens
            String envSeparator = "-";
            // split X-Road instance to lower case tokens
            String tokens[] = xroadInstanceCode.toLowerCase().split(envSeparator);
            // filter out tokens representing X-Road environment
            List<String> identifierTokens = new ArrayList<String>();
            for (String token : tokens) {
                // 'dev' and 'test' in instance name are ignored
                if (!token.equals("dev") && !token.equals("test")) {
                    identifierTokens.add(token);
                }
            }
            //join tokens back together with separator without environment keywords
            return String.join(envSeparator, identifierTokens);
        }
    }
    /**
     * Save active X-Road service instances to User session.
     * @param session HTTP user session
     * @return active X-Road service instance codes in a set
     */
    @Transactional(readOnly=true)
    public InstanceCodeMap saveActiveXroadInstancesToSession(Map<String, Object> session) {
        Portal portal = (Portal) session.get(Const.SESSION_PORTAL);
        if (portal != null && portal.isV6()) {
            List<XroadInstance> activeInstances = findActiveInstances(portal);
            
            InstanceCodeMap instanceCodes = new InstanceCodeMap(activeInstances.size());
            for (XroadInstance instance : activeInstances) {
                instanceCodes.add(instance.getCode());
            }
            synchronized (session) {
                session.put(Const.SESSION_ACTIVE_XROAD_INSTANCES,
                        instanceCodes);
                logger.debug("Reloaded active X-Road instances to session: " + instanceCodes);
            }
            return instanceCodes;
        } else {
            return null;
        }
    }
    
    /**
     * Check whether X-Road instance code is active (queries allowed) in current session portal
     * and return it.
     * If it is not allowed, try to reload instances and query again.
     * The implementation basically uses cached codes from session, but in case of permission failure,
     * it also performs DB query to refresh the cache. Otherwise cache is only filled during
     * portal change.
     * @param xroadInstanceCode instance code to be validated
     * @return #xroadInstanceCode if it is among active codes, null if no matching active code exists
     */
    @Transactional(readOnly=true)
    public String getActiveXroadInstanceCode(String xroadInstanceCode) {
        long t0 = System.currentTimeMillis();
        try {
            if (xroadInstanceCode == null) return null; // no check if code is not given
            String activeXRoadInstanceCode = null;
            
            // session is Struts2 HTTP user session
            Map<String, Object> session = ActionContext.getContext().getSession();
            // load active X-Road instances from session
            InstanceCodeMap activeXroadInstances =
                    (InstanceCodeMap)session.get(Const.SESSION_ACTIVE_XROAD_INSTANCES);
            // if given X-Road instance is active in session, return true at once without querying from DB
            if (activeXroadInstances != null && !activeXroadInstances.hasExpired()) {
                activeXRoadInstanceCode = activeXroadInstances.getActiveXroadInstance(xroadInstanceCode);
            }
            // if given X-Road instance is not active in session, reload X-Road instances and try again
            if (activeXRoadInstanceCode == null) {
                activeXroadInstances = saveActiveXroadInstancesToSession(session);
                if (activeXroadInstances == null) {
                    return null;
                }
                activeXRoadInstanceCode = activeXroadInstances.getActiveXroadInstance(xroadInstanceCode);
            }
            return activeXRoadInstanceCode;
        } finally {
            logger.debug("Active X-Road instance check took " + (System.currentTimeMillis() - t0) + " ms");
        }
    }
}
