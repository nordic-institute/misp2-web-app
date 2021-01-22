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

package ee.aktors.misp2.action.admin;

import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.Action;

import ee.aktors.misp2.action.SessionPreparedBaseAction;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Admin;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.PasswordUtil;

/**
 */
public class AdminAction extends SessionPreparedBaseAction {
    private static final long serialVersionUID = 1L;

    private String oldPassword;
    private String newPassword;
    private String retypedPassword;
    private static final Logger LOG = LogManager.getLogger(AdminAction.class);
    private UserService userService;

    /**
     * Initializes class variables
     * @param userService userService to set
     */
    public AdminAction(UserService userService) {
        this.userService = userService;
    }

    /**
     * @return Action.SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String changeAdminPassword() {
        return Action.SUCCESS;
    }

    /**
     * Salts and saves the password
     * @return Action.SUCCESS if saving successful ERROR otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String saveAdminPassword() {
        String username = ((Person) session.get(Const.SESSION_USER_HANDLE)).getGivenname();
        Admin admin = userService.findAdminByLoginUsername(username);
        try {
            if (!PasswordUtil.encryptPassword(username + oldPassword, admin.getSalt()).equals(admin.getPassword())) {
                addActionError(getText("change.password.old_password_incorrect"));
                return Action.ERROR;
            }

            String salt = PasswordUtil.getSalt();
            String password = PasswordUtil.encryptPassword(username + newPassword, salt);
            admin.setPassword(password);
            admin.setSalt(salt);
            userService.save(admin);
        } catch (NoSuchAlgorithmException e) {
            LOG.error("Failed changing admin password.", e);
            addActionError(getText("text.fail.save"));
            return Action.ERROR;
        } catch (UnsupportedEncodingException e) {
            LOG.error("Failed changing admin password.", e);
            addActionError(getText("text.fail.save"));
            return Action.ERROR;
        }

        addActionMessage(getText("text.success.save"));
        return Action.SUCCESS;
    }

    /**
     * @return the oldPassword
     */
    public String getOldPassword() {
        return oldPassword;
    }

    /**
     * @param oldPasswordNew the oldPassword to set
     */
    public void setOldPassword(String oldPasswordNew) {
        this.oldPassword = oldPasswordNew;
    }

    /**
     * @return the newPassword
     */
    public String getNewPassword() {
        return newPassword;
    }

    /**
     * @param newPasswordNew the newPassword to set
     */
    public void setNewPassword(String newPasswordNew) {
        this.newPassword = newPasswordNew;
    }

    /**
     * @return the retypedPassword
     */
    public String getRetypedPassword() {
        return retypedPassword;
    }

    /**
     * @param retypedPasswordNew the retypedPassword to set
     */
    public void setRetypedPassword(String retypedPasswordNew) {
        this.retypedPassword = retypedPasswordNew;
    }

}
