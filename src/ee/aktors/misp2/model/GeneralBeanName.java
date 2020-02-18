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

package ee.aktors.misp2.model;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.MappedSuperclass;

import ee.aktors.misp2.util.Const;

/**
 * 
 * @author siim.kinks
 *
 */
@MappedSuperclass
public abstract class GeneralBeanName extends GeneralBean {

    
    
    private static final long serialVersionUID = 1L;
    
    @Column(name = "lang", length = Const.LENGTH_10)
    private String lang;
    @Basic(optional = false)
    @Column(name = "description", nullable = false, length = Const.LENGTH_256)
    private String description;

    
    /**
     * Empty constructor with no additional actions
     */
    public GeneralBeanName() {
    }

    /**
     * Sets {@code description} and {@code lang}
     * @param generalBeanName from where the data is taken
     */
    public GeneralBeanName(GeneralBeanName generalBeanName) {
        super(generalBeanName);
        this.setDescription(generalBeanName.getDescription());
        this.setLang(generalBeanName.getLang());
    }

    /**
     * @return the lang
     */
    public String getLang() {
        return lang;
    }

    /**
     * @param langNew the lang to set
     */
    public void setLang(String langNew) {
        this.lang = langNew;
    }

    /**
     * @return the description
     */
    public String getDescription() {
        return description;
    }

    /**
     * @param descriptionNew the description to set
     */
    public void setDescription(String descriptionNew) {
        this.description = descriptionNew;
    }


}
