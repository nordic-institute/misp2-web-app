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

package ee.aktors.misp2.action;

import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.PersonMailOrg;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.PasswordUtil;

/**
 *
 * @author arnis.rips
 */
public class UserSettingAction extends QuickTipAction {

    private static final long serialVersionUID = 1L;
    private Person person;
    private Org activeOrg;
    private PersonMailOrg personMailOrg;
    private boolean updatePassword = false;
    private String oldPassword = "";
    private String newPassword = "";
    private String confirmNewPassword = "";
    private String email;
    private boolean notifyChanges;
    private UserService uService;
    private static final Logger LOG = LogManager.getLogger(UserSettingAction.class);

    /**
     * empty constructor
     */
    public UserSettingAction() {
    }

    /**
     * @param uService uService to inject
     */
    public UserSettingAction(UserService uService) {
        this.uService = uService;
    }

    @Override
    public void validate() {
        try {
            if (updatePassword) {
                if (CONFIG.getBoolean("auth.password") == false) {
                    addFieldError("updatePassword", getText("login.errors.form.not_supported"));
                } else {
                    // If inserted oldPassword does not equal person's password (null vs empty means equals) then error
                    if (!(person.getPassword() == null
                            && oldPassword.equals("")
                            || PasswordUtil.encryptPassword(oldPassword, person.getPasswordSalt())
                                .equals(person.getPassword()))) {
                        addFieldError("oldPassword", getText("change.password.old_password_incorrect"));
                    }
                    if (newPassword.equals(confirmNewPassword) == false) {
                        addFieldError("confirmNewPassword", getText("change.password.mismatch"));
                    }
                }
            }

            if (notifyChanges && (email == null || email.isEmpty())) {
                addFieldError("notifyChanges", getText("users.error.text.email"));
            }
            // copy field errors to action errors - some say user might not notice tooltip field errors
            for (List<String> s : getFieldErrors().values()) {
                setActionErrors(s);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public void prepare() throws Exception {
        super.prepare();
        if (user != null) {
            person = uService.reAttach(user, Person.class);
            activeOrg = null;
            if (portal.getMispType() != Const.MISP_TYPE_CITIZEN) {
                activeOrg = org;
            }
            for (PersonMailOrg pmo : person.getPersonMailOrgList()) {
                if (portal.getMispType() == Const.MISP_TYPE_CITIZEN) { // ilma asutuseta
                    if (pmo.getOrgId() == null) {
                        personMailOrg = pmo;
                        break;
                    }
                } else if (activeOrg != null && pmo.getOrgId() != null && activeOrg.equals(pmo.getOrgId())) {
                    personMailOrg = pmo;
                    break;
                }
            }
        }
    }

    /**
     * @return INPUT if exception occurs, SUCCESS otherwise
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String saveUser() {
        try {
            if (updatePassword) {
                person.setPasswordSalt(PasswordUtil.getSalt());
                person.setPassword(PasswordUtil.encryptPassword(newPassword, person.getPasswordSalt()));
            }
            uService.save(person);

            // List<PersonMailOrg> newPmos = new ArrayList<PersonMailOrg>();
            if (personMailOrg != null) {
                for (PersonMailOrg pmo : person.getPersonMailOrgList()) {
                    if (pmo.equals(personMailOrg)) {
                        pmo.setMail(email);
                        pmo.setNotifyChanges(notifyChanges);
                        uService.save(pmo);
                        break;
                    }
                    // newPmos.add(pmo);
                }
                // person.setPersonMailOrgList(newPmos);
            } else {
                PersonMailOrg pm = new PersonMailOrg();
                pm.setMail(email);
                pm.setPersonId(person);
                pm.setOrgId(activeOrg);
                pm.setNotifyChanges(notifyChanges);
                pm.setPersonId(person);
                uService.save(pm);
                // person.getPersonMailOrgList().add(pm);
            }

            ActionContext.getContext().getSession().put(Const.SESSION_USER_HANDLE, person);
            addActionMessage(getText("text.success.save"));
        } catch (Exception e) {
            LOG.warn(e);
            return INPUT;
        }
        LOG.debug("Saved user");
        return SUCCESS;
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String showUser() {
        if (personMailOrg != null) {
            email = personMailOrg.getMail();
            notifyChanges = personMailOrg.getNotifyChanges();
        } else {
            LOG.warn("personMailOrg is not set");
        }
        return SUCCESS;
    }

    /**
     * @return the person
     */
    public Person getPerson() {
        return person;
    }

    /**
     * @param personNew the person to set
     */
    public void setPerson(Person personNew) {
        this.person = personNew;
    }

    /**
     * @return the updatePassword
     */
    public boolean isUpdatePassword() {
        return updatePassword;
    }

    /**
     * @param updatePasswordNew the updatePassword to set
     */
    public void setUpdatePassword(boolean updatePasswordNew) {
        this.updatePassword = updatePasswordNew;
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
     * @return the confirmNewPassword
     */
    public String getConfirmNewPassword() {
        return confirmNewPassword;
    }

    /**
     * @param confirmNewPasswordNew the confirmNewPassword to set
     */
    public void setConfirmNewPassword(String confirmNewPasswordNew) {
        this.confirmNewPassword = confirmNewPasswordNew;
    }

    /**
     * @return the email
     */
    public String getEmail() {
        return email;
    }

    /**
     * @return the notifyChanges
     */
    public boolean isNotifyChanges() {
        return notifyChanges;
    }

    /**
     * @param notifyChangesNew the notifyChanges to set
     */
    public void setNotifyChanges(boolean notifyChangesNew) {
        this.notifyChanges = notifyChangesNew;
    }

    /**
     * @param emailNew email to set
     */
    public void setEmail(String emailNew) {
        this.email = null;
        if (emailNew != null) {
            this.email = emailNew.trim();
        }
    }
}
