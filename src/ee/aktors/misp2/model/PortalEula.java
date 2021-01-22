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

package ee.aktors.misp2.model;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * Entity represents EULA (end user license agreement) translation for a given portal.
 * Many-to-one association to portal.
 * Entities are created in administration interface portal form.
 */
@Entity
@Table(name = "portal_eula")
@NamedQueries({ @NamedQuery(name = "PortalEula.findAll", query = "SELECT pe FROM PortalEula pe") })
public class PortalEula extends GeneralBean {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "portal_eula_id_seq")
    @SequenceGenerator(name = "portal_eula_id_seq", sequenceName = "portal_eula_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id; // primary key

    @JoinColumn(name = "portal_id", referencedColumnName = "id")
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Portal portal; // reference to portal where EULA is in use

    @Column(name = "lang", length = 2, nullable = false)
    private String lang; // language code for give EULA

    @Column(name = "content", nullable = false)
    private String content; // EULA content in MD format
    
    /**
     * @return the id
     */
    public Integer getId() {
        return id;
    }

    /**
     * @param idNew the id to set
     */
    public void setId(Integer idNew) {
        this.id = idNew;
    }

    /**
     * @return portal entity with EULA enabled
     */
    public Portal getPortal() {
        return portal;
    }

    /**
     * Set EULA-associated portal entity.
     * @param portalNew EULA-associated portal entity
     */
    public void setPortal(Portal portalNew) {
        this.portal = portalNew;
    }

    /**
     * @return language of EULA content
     */
    public String getLang() {
        return lang;
    }

    /**
     * Set language of EULA content.
     * @param langNew 2-letter language code
     */
    public void setLang(String langNew) {
        this.lang = langNew;
    }

    /**
     * @return EULA content in MD format
     */
    public String getContent() {
        return content;
    }

    /**
     * Set EULA content.
     * @param contentNew EULA content in MD formatted text
     */
    public void setContent(String contentNew) {
        this.content = contentNew;
    }
       
}
