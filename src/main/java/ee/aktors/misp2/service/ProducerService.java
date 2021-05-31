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

package ee.aktors.misp2.service;

import com.opensymphony.xwork2.ActionContext;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Producer.ProtocolType;
import ee.aktors.misp2.model.ProducerName;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.URLReader;
import ee.aktors.misp2.util.XMLUtil;
import ee.aktors.misp2.util.XMLUtilException;
import ee.aktors.misp2.util.xroad.XRoadUtil;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.rest.model.ListClientsResponse.ProducerInfo;
import ee.aktors.misp2.util.xroad.rest.model.ListClientsResponse.ProducerInfo.Id;
import ee.aktors.misp2.util.xroad.rest.query.ListClientsQuery;
import ee.aktors.misp2.util.xroad.soap.query.meta.ListProducersQuery;
import java.io.IOException;
import java.io.StringWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.persistence.NoResultException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.transaction.annotation.Transactional;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * Producer service
 */
@Transactional
public class ProducerService extends BaseService {

	private static final Logger logger = LogManager.getLogger(ProducerService.class);

	private String getProducerHqlOrder() {
		return "p.xroadInstance,"
			+ " p.memberClass,"
			+ " p.shortName,"
			+ " case when p.subsystemCode is null then '' else p.subsystemCode end";
	}

	/**
	 * Get producers where producer.use is true
	 *
	 * @param portal portal of producer
	 * @return a list of the results
	 */
	public List<Producer> findActiveProducers(Portal portal) {
		return findActiveProducers(portal, null);
	}

	/**
	 * Get producers where producer.use is true and has given portal
	 *
	 * @param portal portal of producer
	 * @param protocolType producer protocol type
	 * @return a list of the results
	 */
	@SuppressWarnings("unchecked")
	public List<Producer> findActiveProducers(Portal portal, ProtocolType protocolType) {
		String query = "select p FROM Producer p where p.inUse=true ";

		if (protocolType != null) {
			query += " and p.protocol = :protocol ";
		}
		query += " and p.portal.id=:portalId order by " + getProducerHqlOrder();

		javax.persistence.Query s = getEntityManager()
			.createQuery(query)
			.setParameter("portalId", portal.getId());
		if (protocolType != null) {
			s.setParameter("protocol", protocolType);
		}

		return s.getResultList();
	}

	/**
	 * Get producers who have given portal and producer.isComplex is false or null
	 *
	 * @param portal portal of producer
	 * @param protocolType producer protocol type
	 * @return a list of the results
	 */
	@SuppressWarnings("unchecked")
	public List<Producer> findAllProducers(Portal portal, ProtocolType protocolType) {
		String qlString = "select p FROM Producer p where p.portal.id=:portalId "
			+ "and (p.isComplex=false or p.isComplex is null)";
		if (protocolType != null) {
			qlString += " and p.protocol = :protocol ";
		}
		qlString +=  " order by p.inUse desc, " + getProducerHqlOrder();

		javax.persistence.Query s = getEntityManager()
			.createQuery(qlString)
			.setParameter("portalId", portal.getId());

		if (protocolType != null) {
			s.setParameter("protocol", protocolType);
		}
		return  s.getResultList();
	}

	/**
	 * @param tempProducer producer used to build the query
	 * @param portal portal of producer to find
	 * @return result if one is found, null otherwise
	 */
	public Producer findProducer(Producer tempProducer, Portal portal) {
		try {
			StringWriter queryStringWriter = new StringWriter();
			queryStringWriter.append("select p FROM Producer p where ");
			HashMap<String, Object> parameters = new LinkedHashMap<>();

			queryStringWriter.append("p.portal.id=:portalId ");
			parameters.put("portalId", portal.getId());

			queryStringWriter.append("and p.shortName=:shortName ");
			parameters.put("shortName", tempProducer.getShortName());

			queryStringWriter.append("and p.protocol=:protocol ");
			parameters.put("protocol", tempProducer.getProtocol());

			if (tempProducer.getXroadInstance() != null) {
				queryStringWriter.append("and p.xroadInstance=:xroadInstance ");
				parameters.put("xroadInstance", tempProducer.getXroadInstance());
			} else {
				queryStringWriter.append("and p.xroadInstance is null ");
			}

			if (tempProducer.getMemberClass() != null) {
				queryStringWriter.append("and p.memberClass=:memberClass ");
				parameters.put("memberClass", tempProducer.getMemberClass());
			} else {
				queryStringWriter.append("and p.memberClass is null ");
			}

			if (tempProducer.getSubsystemCode() != null) {
				queryStringWriter.append("and p.subsystemCode=:subsystemCode ");
				parameters.put("subsystemCode", tempProducer.getSubsystemCode());
			} else {
				queryStringWriter.append("and p.subsystemCode is null ");
			}

			queryStringWriter.append(" order by p.inUse desc, ").append(getProducerHqlOrder());
			// logger.debug("Query str: " + queryStringWriter.toString());
			javax.persistence.Query s = getEntityManager().createQuery(queryStringWriter.toString());
			for (String key : parameters.keySet()) {
				s.setParameter(key, parameters.get(key));
			}
			return (Producer) s.getSingleResult();
		} catch (NoResultException nre) {
			return null;
		}
	}

	/**
	 * @param producer producer whom name to find
	 * @param language language for producer name
	 * @return result if there is one, null otherwise
	 */
	public ProducerName findProducerName(Producer producer, String language) {
		try {
			String qlString = "select pn FROM ProducerName pn where pn.producer.id=:producerId and pn.lang=:language";
			javax.persistence.Query q = getEntityManager()
										.createQuery(qlString)
										.setParameter("producerId", producer.getId())
										.setParameter("language", language);

			return (ProducerName) q.getSingleResult();
		} catch (NoResultException nre) {
			return null;
		}
	}

	/**
	 * Sets producers inUse to true (ones given in activeProducerIds) or deletes producer queries and sets
	 * producer inUse to false (ones not in activeProducerIds)
	 * @param producers producers whom state to change
	 * @param activeProducerIds producer id-s to set active
	 */
	public void changeProducersState(List<Producer> producers, HashSet<Integer> activeProducerIds) {
		for (Producer producer : producers) {
			boolean state = activeProducerIds.contains(producer.getId());
			if (state != producer.getInUse()) {
				producer.setInUse(state);
				save(producer);
				if (!state) {
					deleteProducerQueries(producer);
				}
			}
		}
	}

	/**
	 * @param portal session portal
	 * @param activeXroadInstanceCodes allowed X-Road v6 service instances for given portal
	 * @param selectedXroadInstanceCodes instances for which X-Road v6 producers are listed
	 * @return true if listing was successful
	 * @throws DataExchangeException X-Road getting url failure or when SOAP-Fault is found
	 */
	public boolean listProducersFromSecurityServer(Portal portal,
		Set<String> activeXroadInstanceCodes, List<String> selectedXroadInstanceCodes, ProtocolType protocolType)
		throws DataExchangeException {
		if (portal.isV6()) {
			switch (protocolType) {
				case SOAP:
					return listClientsForV6Soap(portal, activeXroadInstanceCodes, selectedXroadInstanceCodes);
				case REST:
					return listClientsForV6Rest(portal, activeXroadInstanceCodes, selectedXroadInstanceCodes);
				default:
					throw new RuntimeException(String.format("Unknown ProtocolType: %s", protocolType));
			}
		} else {
			return listProducersForV5();
		}
	}

	/**
	 * Updates clients list via SOAP interface
	 * @param portal portal which clients to get
	 * @param activeXroadInstanceCodes currently in use xroad instances
	 * @param selectedXroadInstanceCodes instances selected by user
	 * @return true if clients were update
	 * @throws DataExchangeException if something went wrong with acquiring client list
	 */
	private boolean listClientsForV6Soap(Portal portal, Set<String> activeXroadInstanceCodes,
		List<String> selectedXroadInstanceCodes) throws DataExchangeException {
		List<Producer> beforeUpdate = findAllProducers(portal, ProtocolType.SOAP);
		List<Producer> activeProducers = findActiveProducers(portal, ProtocolType.SOAP);
		List<ProducerName> producerNames = new ArrayList<>();
		List<Producer> producers = new ArrayList<>();
		try {
			// in case no instance codes is given, perform query with no xRoadInstance parameter
			// this option is not allowed in ProducerAction
			if (selectedXroadInstanceCodes.size() == 0) {
				selectedXroadInstanceCodes.add(null);
			}
			for (String instCode : selectedXroadInstanceCodes) {

				String listProducersUrl = portal.getSecurityHost() + Const.XROAD_V6_LIST_CLIENTS;
				// in case instance code is not null, add it as a query parameter
				if (instCode != null) {
					listProducersUrl += "?xRoadInstance="
						+ URLEncoder.encode(instCode, StandardCharsets.UTF_8.name());
				}
				String listProducersResponseStr = URLReader.readUrlStr(
					XRoadUtil.getMetaServiceEndpointUrlWithTimeouts(listProducersUrl), false);
				Document doc = XMLUtil.convertXMLToDocument(listProducersResponseStr);
				XRoadUtil.checkFault(doc, "/listClients query for X-Road v6 failed");

				NodeList members = doc.getDocumentElement().getChildNodes();
				for (int i = 0; i < members.getLength(); i++) {
					Node memberNode = members.item(i);
					if (memberNode instanceof Element) {
						Element member = (Element) memberNode;
						Element id = XMLUtil.getElementByLocalTagName(member, "id");
						// String objectType = XMLUtil.getAttributeByLocalName(id, "objectType");
						String xroadInstance = XMLUtil.getElementByLocalTagName(id, "xRoadInstance").getTextContent();
						String memberClass = XMLUtil.getElementByLocalTagName(id, "memberClass").getTextContent();
						String memberCode = XMLUtil.getElementByLocalTagName(id, "memberCode").getTextContent();

						Node subsystemCodeEl = XMLUtil.getElementByLocalTagName(id, "subsystemCode");

						String subsystemCode = subsystemCodeEl != null ? subsystemCodeEl.getTextContent() : null;

						String name = XMLUtil.getElementByLocalTagName(member, "name").getTextContent();

						Producer producer = new Producer();
						producer.setXroadInstance(xroadInstance);
						producer.setShortName(memberCode);
						producer.setMemberClass(memberClass);
						producer.setSubsystemCode(subsystemCode);
						addProducerToProducerNamesWithDescription(producerNames, name, producer);
						producer.setInUse(false);

						// if producer with that name is active then set
						// temporary producer to active
						for (Producer activeProducer : activeProducers) {
							boolean equalToLegacyXroadProducer = !activeProducer.getPortal().isV6()
									&& memberCode.equalsIgnoreCase(activeProducer.getShortName());
							boolean equalToXroadV6Producer = activeProducer.getPortal().isV6()
									&& xroadInstance.equals(activeProducer.getXroadInstance())
									&& memberClass.equals(activeProducer.getMemberClass())
									&& memberCode.equalsIgnoreCase(activeProducer.getShortName())
									&& (
									subsystemCode == null && activeProducer.getSubsystemCode() == null
											|| subsystemCode != null
											&& subsystemCode.equals(activeProducer.getSubsystemCode()
									));
							if (equalToLegacyXroadProducer || equalToXroadV6Producer) {
								producer.setInUse(true);
								break;
							}
						}
						producer.setPortal(portal);
						producer.setProtocol(ProtocolType.SOAP);
						producers.add(producer); // add producer to list
					}
				}
				List<Producer> afterUpdate = saveProducersFromXml(producers, portal); // update DAO
				compare(beforeUpdate, afterUpdate, activeXroadInstanceCodes);
				addProducerDescriptions(producerNames, portal);
			}
			return Boolean.TRUE;
		} catch (IOException e) {
			logger.error("X-Road v6 client HTTP(S) list query failed", e);
		} catch (XMLUtilException e) {
			logger.error("X-Road v6 client list query response parsing failed", e);
		}
		return Boolean.FALSE;
	}

	private void addProducerToProducerNamesWithDescription(List<ProducerName> producerNames, String name, Producer temp) {
		String key = temp.getXroadIdentifier();
		logger.trace("Inserting into producerNames '" + key + "' : '" + name + "'");
		ProducerName tempProducerName = new ProducerName();
		tempProducerName.setProducer(temp);
		tempProducerName.setDescription(name);
		tempProducerName.setLang(ActionContext.getContext().getLocale().getLanguage());
		producerNames.add(tempProducerName);
	}

	/**
	 * Updates clients list via REST interface
	 * @param portal portal which clients to get
	 * @param activeXroadInstanceCodes currently in use xroad instances
	 * @param selectedXroadInstanceCodes instances selected by user
	 * @return true if clients were update
	 * @throws DataExchangeException if something went wrong with acquiring client list
	 */
	@SuppressWarnings("SameReturnValue")
	private boolean listClientsForV6Rest(Portal portal, Set<String> activeXroadInstanceCodes,
										 List<String> selectedXroadInstanceCodes) throws DataExchangeException {
		List<Producer> beforeUpdate = findAllProducers(portal, ProtocolType.REST);
		List<Producer> activeProducers = findActiveProducers(portal, ProtocolType.REST);
		List<ProducerName> producerNames = new ArrayList<>();
		List<Producer> producers = new ArrayList<>();

		// in case no instance codes is given, perform query with no xRoadInstance parameter
		// this option is not allowed in ProducerAction
		if (selectedXroadInstanceCodes.size() == 0) {
			selectedXroadInstanceCodes.add(null);
		}
		for (String instCode : selectedXroadInstanceCodes) {

			ListClientsQuery listClientsQuery = new ListClientsQuery(portal);
			List<ProducerInfo> producerInfoList = listClientsQuery.fetchProducerInfo(instCode);

			for (ProducerInfo producerInfo : producerInfoList) {
				Producer producer = new Producer();
				Id id = producerInfo.getId();
				producer.setMemberClass(id.getMemberClass());
				producer.setShortName(id.getMemberCode());
				producer.setSubsystemCode(id.getSubsystemCode());
				producer.setXroadInstance(id.getXroadInstance());
				producer.setInUse(false);

				String name = producerInfo.getName();
				addProducerToProducerNamesWithDescription(producerNames,name,producer);
				for (Producer activeProducer : activeProducers) {
					boolean equalToLegacyXroadProducer = !activeProducer.getPortal().isV6()
							&& producer.getShortName().equalsIgnoreCase(activeProducer.getShortName());
					boolean equalToXroadV6Producer = activeProducer.getPortal().isV6()
							&& producer.getXroadInstance().equals(activeProducer.getXroadInstance())
							&& producer.getMemberClass().equals(activeProducer.getMemberClass())
							&& producer.getShortName().equalsIgnoreCase(activeProducer.getShortName())
							&& (
							producer.getSubsystemCode() == null && activeProducer.getSubsystemCode() == null
									|| producer.getSubsystemCode() != null
									&& producer.getSubsystemCode().equals(activeProducer.getSubsystemCode()
							));
					if (equalToLegacyXroadProducer || equalToXroadV6Producer) {
						producer.setInUse(true);
						break;
					}
				}
				producer.setPortal(portal);
				producer.setProtocol(ProtocolType.REST);
				producers.add(producer); // add producer to list
			}
			List<Producer> afterUpdate = saveProducersFromXml(producers, portal); // update DAO
			compare(beforeUpdate, afterUpdate, activeXroadInstanceCodes);
			addProducerDescriptions(producerNames, portal);
		}
		return Boolean.TRUE;
	}


	private boolean listProducersForV5() {
		try {
			ListProducersQuery xRoadQuery = new ListProducersQuery();
			xRoadQuery.createSOAPRequest();
			xRoadQuery.sendRequest();
			processResponseForV5(xRoadQuery, xRoadQuery.getPortal());
			return Boolean.TRUE;
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
		return Boolean.FALSE;
	}

	private void processResponseForV5(ListProducersQuery xRoadQuery, Portal portal) throws Exception {
		List<Producer> beforeUpdate = findAllProducers(portal, ProtocolType.SOAP);
		xRoadQuery.processResponse(this.findActiveProducers(portal, ProtocolType.SOAP));

		if (xRoadQuery.hasResponse()) {
			List<Producer> afterUpdate = saveProducersFromXml(xRoadQuery.getProducers(), portal); // update DAO
			compare(beforeUpdate, afterUpdate, null);
			addProducerDescriptions(xRoadQuery.getProducerNames(), portal);
		}
	}

	/**
	 * Sets descriptions for producers
	 *
	 * @param producerNames descriptions to set
	 * @param portal portal of producers
	 */
	public void addProducerDescriptions(List<ProducerName> producerNames, Portal portal) {
		for (ProducerName tempProducerName : producerNames) {
			Producer p = findProducer(tempProducerName.getProducer(), portal);
			ProducerName pn = new ProducerName();
			pn.setDescription(tempProducerName.getDescription());
			pn.setProducer(p);
			pn.setLang(tempProducerName.getLang());

			// if that producer exists, then setId and update
			if (producerDescExists(pn, portal)) {
				getEntityManager().merge(pn);
			} else {
				getEntityManager().persist(pn);
			}
		}
	}

	/**
	 * @param all producers
	 * @param portal portal of producer
	 * @return list of results, empty if no results
	 */
	public List<Producer> saveProducersFromXml(List<Producer> all, Portal portal) {
		List<Producer> list = new ArrayList<>();
		for (Producer temp : all) {
			if (XRoadUtil.isProducerExcluded(temp)) {
				logger.trace("Not persisting producer '" + temp.getXroadIdentifier()
					+ "' because it is excluded in conf");
				continue;
			}
			if (producerExists(temp, portal)) { // if that producer exists, then setId and update
				getEntityManager().merge(temp);
			} else {
				logger.trace("Persisting producer '" + temp.getXroadIdentifier()
					+ "' because it does not exist");
				getEntityManager().persist(temp);
			}
			list.add(temp);
		}
		return list;

	}

	/**
	 * @param p producer to check
	 * @param portal portal of producer
	 * @return true if such producer is found, false otherwise
	 */
	public boolean producerExists(Producer p, Portal portal) {
		try {
			if (portal.isV6()) {
				String hqlStr = "select p FROM Producer p where"
					+ " p.xroadInstance=:xroadInstance"
					+ " and p.memberClass=:memberClass"
					+ " and p.shortName=:shortName"
					+ " and p.portal.id=:portalId"
					+ " and p.protocol=:protocolIn";
				if (p.getSubsystemCode() != null) {
					hqlStr += " and p.subsystemCode=:subsystemCode";
				} else {
					hqlStr += " and p.subsystemCode is null";
				}

				javax.persistence.Query q = getEntityManager()
											.createQuery(hqlStr)
											.setParameter("portalId", portal.getId())
											.setParameter("xroadInstance", p.getXroadInstance())
											.setParameter("memberClass", p.getMemberClass())
											.setParameter("shortName", p.getShortName())
											.setParameter("protocolIn", p.getProtocol());

				if (p.getSubsystemCode() != null) {
					q.setParameter("subsystemCode", p.getSubsystemCode());
				}
				Producer temp2 = (Producer) q.getSingleResult();
				p.setId(temp2.getId());
				return true;

			} else {
				String qlString = "select p FROM Producer p where p.shortName=:shortName and p.portal.id=:portalId";
				javax.persistence.Query s = getEntityManager()
											.createQuery(qlString)
											.setParameter("portalId", portal.getId())
											.setParameter("shortName", p.getShortName());
				Producer temp2 = (Producer) s.getSingleResult();
				p.setId(temp2.getId());
				return true;
			}
		} catch (Exception e) {
			logger.trace("Producer existence query failed", e);
			return false;
		}
	}

	private Map<String, Producer> mapIdentifierToProducer(List<Producer> producers) {
		Map<String, Producer> mappings = new LinkedHashMap<>();
		for (Producer producer : producers) {
			if (producer != null) {
				String identifier = producer.getXroadIdentifier();
				if (identifier != null) {
					mappings.put(identifier, producer);
				} else {
					logger.error("Producer " + producer + " has null identifier.");
				}
			}
		}
		return mappings;
	}

	/**
	 * Add not in use producers to session, merge those in use producers
	 *
	 * @param before producers before
	 * @param after producers after
	 * @param activeXroadInstanceCodes service X-Road instance codes allowed in this portal
	 */
	private void compare(List<Producer> before, List<Producer> after,
		Set<String> activeXroadInstanceCodes) {
		if (after != null && !after.isEmpty()) {
			ArrayList<String> outOfSync = new ArrayList<>();
			Map<String, Producer> beforeMap = mapIdentifierToProducer(before);
			Map<String, Producer> afterMap = mapIdentifierToProducer(after);
			String afterXroadInstanceCode = getCommonXroadInstanceCode(afterMap);
			for (String beforeIdentifier : beforeMap.keySet()) {
				Producer beforeProducer = beforeMap.get(beforeIdentifier);
				String beforeXroadInstanceCode = beforeProducer.getXroadInstance();
				if (!afterMap.containsKey(beforeIdentifier)
					&& isRemovalAllowed(beforeXroadInstanceCode, afterXroadInstanceCode,
					activeXroadInstanceCodes)) {
					if (!beforeProducer.getInUse()) {
						getEntityManager().remove(getEntityManager().merge(beforeProducer));
						logger.debug("removing old query: " + beforeIdentifier);
					} else {
						outOfSync.add(beforeIdentifier);
					}
				}
			}
			if (!outOfSync.isEmpty()) {
				ActionContext.getContext().getSession().put("outOfSync", outOfSync);
			}
		}

	}

	private String getCommonXroadInstanceCode(Map<String, Producer> producerMap) {
		String commonXroadInstanceCode = null;
		for (Producer producer : producerMap.values()) {
			String producerXroadInstanceCode = producer.getXroadInstance();
			if (commonXroadInstanceCode == null) { // producerXroadInstanceCode != null
				// assign current producer instance to common instance
				commonXroadInstanceCode = producerXroadInstanceCode;
			} else if (!commonXroadInstanceCode.equals(producerXroadInstanceCode)) {
				// commonXroadInstanceCode != null && producerXroadInstanceCode != null
				// in case there are multiple different X-Road instances, common instance does not exist,
				// so return null
				return null;
			} // else commonXroadInstanceCode.equals(producerXroadInstanceCode): continue
		}
		return commonXroadInstanceCode;
	}

	/**
	 * Check if producer with given X-Road instance can be removed from #after list.
	 *
	 * @param beforeXroadInstanceCode X-Road instance code for existing producer
	 * (null for X-Road v4 or v5 producer)
	 * NB! It represents the instance that is being removed.
	 * @param afterXroadInstanceCode common X-Road instance code for all newly obtained producers
	 * in #after list or null if common X-Road instance does not exist.
	 * @param activeXroadInstanceCodes service X-Road instance codes allowed in this portal
	 * @return true if existing producer can be removed in case it is not found from #after list.
	 * producer can be removed if it is X-Road v4 or v5 producer or in case of X-Road v6 producer,
	 * if its X-Road instance matches X-Road instances of all obtained producers.
	 */
	private boolean isRemovalAllowed(String beforeXroadInstanceCode, String afterXroadInstanceCode,
		Set<String> activeXroadInstanceCodes) {
		return afterXroadInstanceCode == null
			|| beforeXroadInstanceCode == null
			|| beforeXroadInstanceCode.equals(afterXroadInstanceCode)
			// allow removal if instance is no longer active
			|| activeXroadInstanceCodes != null
			&& !activeXroadInstanceCodes.contains(beforeXroadInstanceCode);
	}

	/**
	 * @param p producer name
	 * @param portal portal of producer
	 * @return true if description exists and no errors occurred, false otherwise
	 */
	public boolean producerDescExists(ProducerName p, Portal portal) {
		String qlString = "select p FROM ProducerName p, Producer pr where p.lang=:lang and "
			+ "p.producer.id=:producerId and p.producer.id=pr.id and pr.portal.id=:portalId";
		try {
			ProducerName temp2 = (ProducerName) getEntityManager()
												 .createQuery(qlString)
												 .setParameter("lang", p.getLang())
												 .setParameter("producerId", p.getProducer().getId())
												 .setParameter("portalId", portal.getId())
												 .getSingleResult();
			p.setId(temp2.getId());
			return true;
		} catch (Exception e) {
			return false;
		}

	}

	/**
	 * Finds complex producers
	 *
	 * @param portal portal of producers
	 * @return list of results, empty list if no results
	 */
	public List<Producer> findComplexProducers(Portal portal) {
		return findComplexProducers(portal, null);
	}

	/**
	 * Complex producers with given protocol
	 *
	 * @param portal portal of producers
	 * @param protocolType producer protocol type
	 * @return list of results, empty list if no results
	 */
	@SuppressWarnings("unchecked")
	public List<Producer> findComplexProducers(Portal portal, ProtocolType protocolType) {
		String hql = "select p FROM Producer p where p.isComplex=true and p.portal.id=:portalId ";

		if (protocolType != null) {
			hql += "and p.protocol =:protocol ";
		}
		hql += " order by p.shortName";

		logger.trace(hql);
		javax.persistence.Query s = getEntityManager()
			.createQuery(hql)
			.setParameter("portalId", portal.getId());

		if (protocolType != null) {
			s.setParameter("protocol", protocolType);
		}

		return s.getResultList();
	}

	/**
	 * @param producer producer whom names to delete
	 */
	public void deleteProducerNames(Producer producer) {
		String qlString = "DELETE FROM ProducerName pn WHERE pn.producer.id = :producer_id";
		getEntityManager()
			.createQuery(qlString)
			.setParameter("producer_id", producer.getId())
			.executeUpdate();
	}

	/**
	 * @param producer producer whom queries to delete
	 */
	public void deleteProducerQueries(Producer producer) {
		String qlString = "DELETE FROM Query q WHERE q.producer=:producer";
		getEntityManager()
			.createQuery(qlString)
			.setParameter("producer", producer)
			.executeUpdate();
	}


}
