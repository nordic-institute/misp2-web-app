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

import java.io.Serializable;
import java.util.Date;
import java.util.Map;

import javax.persistence.Column;
import javax.persistence.MappedSuperclass;
import javax.persistence.PrePersist;
import javax.persistence.PreUpdate;

import org.apache.logging.log4j.LogManager;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.service.BaseService;
import ee.aktors.misp2.util.Const;

/**
 * This model object contains each table's metadata: username, lastModified, created \@PreUpdate and \@PrePersist are
 * used to insert and update metadata
 * 
 * @author arnis.rips, mihhail
 */
@MappedSuperclass
public abstract class GeneralBean implements BeanInterface, Serializable, Cloneable {

    
    private static final long serialVersionUID = 1L;

    @Column(name = "created")
    private Date created;
    @Column(name = "last_modified")
    private Date lastModified;
    @Column(name = "username", length = Const.LENGTH_20)
    private String username;

    /**
     * 
     */
    @PreUpdate
    @PrePersist
    public void updateTimeStamps() {
        setLastModified(new Date());
        if (getCreated() == null) {
            setCreated(new Date());
        }
        Map<String, Object> session = ActionContext.getContext().getSession();
        if (session != null && getUsername() == null) {
            Person p = (Person) session.get(Const.SESSION_USER_HANDLE);
            if (p != null)
                setUsername(p.getSsn() == null ? "admin" : p.getSsn());
        } else if (session == null && getUsername() == null) {
            LogManager.getLogger(BaseService.class).warn("Session is null. Username not set.");
        }
    }

    /**
     * Empty constructor with no additional actions
     */
    public GeneralBean() {
    }

    /**
     * Sets {@code created}, {@code lastModified} and {@code username}
     * @param generalBean generalBean from which data is taken
     */
    public GeneralBean(GeneralBean generalBean) {
        this.setCreated(generalBean.getCreated());
        this.setLastModified(generalBean.getLastModified());
        this.setUsername(generalBean.getUsername());
    }

    @Override
    protected Object clone() throws CloneNotSupportedException {
        GeneralBean clone = (GeneralBean) super.clone();
        clone.created = (Date) created.clone();
        clone.lastModified = (Date) lastModified.clone();
        return clone;
    }

    /**
     * @return the created
     */
    public Date getCreated() {
        return created;
    }

    /**
     * @param createdNew
     *            the created to set
     */
    public void setCreated(Date createdNew) {
        this.created = createdNew;
    }

    /**
     * @return the lastModified
     */
    public Date getLastModified() {
        return lastModified;
    }

    /**
     * @param lastModifiedNew
     *            the lastModified to set
     */
    public void setLastModified(Date lastModifiedNew) {
        this.lastModified = lastModifiedNew;
    }

    /**
     * @return the username
     */
    public String getUsername() {
        return username;
    }

    /**
     * @param usernameNew
     *            the username to set
     */
    public void setUsername(String usernameNew) {
        this.username = usernameNew;
    }

}
