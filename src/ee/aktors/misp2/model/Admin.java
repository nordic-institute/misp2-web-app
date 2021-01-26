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
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import ee.aktors.misp2.util.Const;

/**
 * 
 * @author siim.kinks
 *
 */
@Entity
@Table(name = "admin")
public class Admin extends GeneralBean {
    
    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "admin_id_seq")
    @SequenceGenerator(name = "admin_id_seq", sequenceName = "admin_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false)
    private Integer id;
    @Basic(optional = false)
    @Column(name = "password", nullable = false, length = Const.LENGTH_50, unique = true)
    private String password;
    @Basic(optional = false)
    @Column(name = "login_username", nullable = false, length = Const.LENGTH_50, unique = true)
    private String loginUsername;
    @Basic(optional = false)
    @Column(name = "salt", nullable = false, length = Const.LENGTH_50)
    private String salt;


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
     * @return the password
     */
    public String getPassword() {
        return password;
    }

    /**
     * @param passwordNew the password to set
     */
    public void setPassword(String passwordNew) {
        this.password = passwordNew;
    }

    /**
     * @return the loginUsername
     */
    public String getLoginUsername() {
        return loginUsername;
    }

    /**
     * @param loginUsernameNew the loginUsername to set
     */
    public void setLoginUsername(String loginUsernameNew) {
        this.loginUsername = loginUsernameNew;
    }

    /**
     * @return the salt
     */
    public String getSalt() {
        return salt;
    }

    /**
     * @param saltNew the salt to set
     */
    public void setSalt(String saltNew) {
        this.salt = saltNew;
    }

    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof Admin)) {
            return false;
        }

        final Admin other = (Admin) obj;

        return hashCode() == other.hashCode();
    }

    @Override
    public int hashCode() {
        int hash = Const.PRIME_7;

        hash = Const.PRIME_17 * hash + (this.getLoginUsername() != null ? this.getLoginUsername().hashCode() : 0);
        return hash;
    }

    @Override
    public String toString() {
        return "ee.aktors.misp2.model.Admin[id=" + getId() + "]";
    }

}
