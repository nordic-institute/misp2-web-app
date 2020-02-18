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

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.transaction.annotation.Transactional;

import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.PersonEula;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.PortalEula;
import ee.aktors.misp2.util.Const;

import org.commonmark.Extension;
import org.commonmark.ext.autolink.AutolinkExtension;
import org.commonmark.ext.gfm.strikethrough.StrikethroughExtension;
import org.commonmark.ext.gfm.tables.TablesExtension;
import org.commonmark.ext.heading.anchor.HeadingAnchorExtension;
import org.commonmark.ext.ins.InsExtension;
import org.commonmark.node.*;
import org.commonmark.parser.Parser;
import org.commonmark.renderer.html.HtmlRenderer;

/**
 * EULA service, saving, retrieving and manipulation of
 * end user license agreement entities (PortalEula and PersonEula)
 */
@Transactional(readOnly=true)
public class EulaService extends BaseService {

    private static Logger logger = LogManager.getLogger(EulaService.class);

    /**
     * Get PortalEula entities for given portal as a map.
     * NB! Entities in the map are detached from Hibernate session: the modifications are not persisted.
     * @param portal portal associated with PortalEula entities
     * @return a list of the results. <br/>
     */
    @SuppressWarnings("unchecked")
    public Map<String, PortalEula> findPortalEulaMap(Portal portal) {
        javax.persistence.Query s = getEntityManager().createQuery(
                "select pe FROM PortalEula pe where "
                + " pe.portal.id=:portalId order by created");
        List<PortalEula> portalEulas = s.setParameter("portalId", portal.getId()).getResultList();
        
        // Create lang - entity map.
        Map<String, PortalEula> portalEulaMap = new LinkedHashMap<String, PortalEula>();
        for (PortalEula portalEula : portalEulas) {
            // detach each entity from session so that changes to the object would not be instantanious
            detach(portalEula);
            portalEulaMap.put(portalEula.getLang(), portalEula);
        }
        return portalEulaMap;
    }

    /**
     * Get PortalEula entity for given portal and language.
     * The entity contains EULA (Markdown) text content.
     * @param portal Portal entity associated with PortalEula entity
     * @param lang two-letter language code for EULA
     * @return PortalEula entity or null if entity was not found. <br/>
     *         NB! Entity is detached from Hibernate session: the modifications are not persisted..
     */
    @SuppressWarnings("unchecked")
    public PortalEula findPortalEula(Portal portal, String lang) {
        javax.persistence.Query s = getEntityManager().createQuery(
                "select pe FROM PortalEula pe where "
                + " pe.portal.id=:portalId AND pe.lang=:lang order by created");
        List<PortalEula> portalEulas = s
                .setParameter("portalId", portal.getId())
                .setParameter("lang", lang)
                .getResultList();
        if (portalEulas == null || portalEulas.isEmpty()) {
            return null;
        }
        PortalEula portalEula = portalEulas.get(0);
        detach(portalEula);
        return portalEula;
    }
    
    /**
     * @param portal Portal entity
     * @return true if EULA acceptance is required from portal users, false if EULA is not in use in portal
     */
    public boolean isEulaInUse(Portal portal) {
        return portal.getEulaInUse() != null && portal.getEulaInUse().booleanValue();
    }

    /**
     * Get PersonEula entity for given portal and user.
     * The entity shows whether person has accepted EULA in given portal.
     * @param portal Portal entity associated with PersonEula entity
     * @param person user entity associated with PersonEula entity
     * @return PersonEula entity or null if entity was not found. <br/>
     *         NB! Entity is detached from Hibernate session: the modifications are not persisted..
     */
    @SuppressWarnings("unchecked")
    public PersonEula findPersonEula(Portal portal, Person person) {
        javax.persistence.Query s = getEntityManager().createQuery(
                "select pe FROM PersonEula pe where "
                + " pe.portal.id=:portalId AND pe.person.id=:personId order by created");
        List<PersonEula> personEulas = s
                .setParameter("portalId", portal.getId())
                .setParameter("personId", person.getId())
                .getResultList();
        if (personEulas == null || personEulas.isEmpty()) {
            return null;
        }
        PersonEula personEula = personEulas.get(0);
        detach(personEula);
        return personEula;
    }

    /**
     * Convenience method to determine whether EULA is accepted or not based on PersonEula entity.
     * @param personEula PersonEula entity
     * @return true if user has accepted EULA, false if EULA has not (yet) been accepted
     */
    public boolean isAccepted(PersonEula personEula) {
        return personEula != null && personEula.getAccepted() != null && personEula.getAccepted().booleanValue() == true;
    }

    /**
     * Save portal's end user license agreement translations into session
     * in case user is required to accept the agreement. In case user is not required
     * to uphold the agreement, remove the object from session.
     * @param session Struts session object map
     */
    public void savePendingEulasToSession(Map<String, Object> session) {
        Portal portal = (Portal) session.get(Const.SESSION_PORTAL);
        Person user = (Person) session.get(Const.SESSION_USER_HANDLE);
        if (isEulaInUse(portal)) { // if EULA acceptance has been configured
            PersonEula personEula = findPersonEula(portal, user);
            // if EULA has not (yet) been accepted by user, put EULA map to session
            if (!isAccepted(personEula)) {
                Map<String, PortalEula> portalEulaMap = findPortalEulaMap(portal);
                session.put(Const.SESSION_EULA_MAP, portalEulaMap);
                logger.debug("EULA required for person " + user + " portal " + portal);
                return;
            }
        }
        // if EULA is not in use in portal or if user has already accepted, remove the key
        session.remove(Const.SESSION_EULA_MAP);
    }
    
    /**
     * @param session user session map
     * @param lang language code
     * @return EULA text from session or NULL if EULA acceptance is not required
     */
    public static String getEulaContentFromSession(Map<String, Object> session, String lang) {
        if (session.get(Const.SESSION_EULA_MAP) != null) {
            @SuppressWarnings("unchecked")
            Map<String, PortalEula> portalEulaMap = (Map<String, PortalEula>)session.get(Const.SESSION_EULA_MAP);
            PortalEula portalEula = portalEulaMap.get(lang);
            if (portalEula != null) {
                String markdwon = portalEula.getContent();
                return convertMarkdownToHtml(markdwon);
            }
        }
        return null;
    }

    private static String convertMarkdownToHtml(String markdwon) {
        List<Extension> extensions = Arrays.asList(
                AutolinkExtension.create(),
                TablesExtension.create(),
                StrikethroughExtension.create(),
                InsExtension.create(),
                HeadingAnchorExtension.create());
        Parser parser = Parser.builder()
                .extensions(extensions)
                .build();
        Node document = parser.parse(markdwon);
        HtmlRenderer renderer = HtmlRenderer.builder()
                .extensions(extensions)
                .build();
        return renderer.render(document);
    }
}
