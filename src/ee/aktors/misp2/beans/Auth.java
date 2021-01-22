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

package ee.aktors.misp2.beans;

import java.io.Serializable;

/**
 * 
 * @author arnis.rips
 */
/**
 * @author kristjan.kiolein
 *
 */
/**
 * @author kristjan.kiolein
 *
 */
public class Auth implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
     * Authentication types
     */
    public enum AUTH_TYPE {
        ID_CARD(0), CERT(1), PASSWORD(2), SAML(3), MOBILE_ID(4);
        private int type;

        AUTH_TYPE(int typeNew) {
            this.type = typeNew;
        }

        /**
         * @param desired what type to find
         * @return type corresponding to given int
         */
        public static String getXrdTypeFor(int desired) {
            try {
                return valueOf(desired).name();
            }catch (IllegalArgumentException e) {
                return "";
            }
        }

        /**
         * @param desired what type to find
         * @return type corresponding to given int
         */
        public static AUTH_TYPE valueOf(int desired) {
            for (AUTH_TYPE status : values()) {
                if (desired == status.type) {
                    return status;
                }
            }
            throw new IllegalArgumentException(String.format("Auth type with value %d does not exist.", desired));
        }

    }

    private int type;
    private boolean isAdmin = false;
    private boolean newUser = false;

    /**
     * Initializes enum
     * @param type sets type
     * @param newUser is newUser
     */
    public Auth(AUTH_TYPE type, boolean newUser) {
        this.type = type.ordinal();
        this.newUser = newUser;
    }

    /**
     * Initializes enum
     * @param type sets type
     */
    public Auth(AUTH_TYPE type) {
        this.type = type.ordinal();
    }

    /**
     * @return if is new user
     */
    public boolean isNewUser() {
        return newUser;
    }

    /**
     * @param newUserIn set if is new user
     */
    public void setNewUser(boolean newUserIn) {
        this.newUser = newUserIn;
    }

    /**
     * @return get integer corresponding to type
     */
    public int getType() {
        return type;
    }

    /**
     * @param typeIn type to set
     */
    public void setType(int typeIn) {
        this.type = typeIn;
    }

    /**
     * @return if is admin
     */
    public boolean isAdmin() {
        return isAdmin;
    }

    /**
     * @param isAdminIn set if is admin
     */
    public void setIsAdmin(boolean isAdminIn) {
        this.isAdmin = isAdminIn;
    }

}
