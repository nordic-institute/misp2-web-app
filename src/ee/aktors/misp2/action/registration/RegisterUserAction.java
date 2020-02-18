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

package ee.aktors.misp2.action.registration;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.service.ClassifierService;
import ee.aktors.misp2.service.ManagerCandidateService;
import ee.aktors.misp2.service.OrgService;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.util.Roles;

/**
 *
 * @author arnis.rips
 */
public class RegisterUserAction extends RegisterPersonBaseAction {

    private static final long serialVersionUID = 1L;

    /**
     * @param orgService orgService to inject
     * @param uService   uService   to inject
     * @param clService  clService  to inject
     * @param mcService  mcService  to inject
     */
    public RegisterUserAction(OrgService orgService, UserService uService, ClassifierService clService,
                              ManagerCandidateService mcService) {
        super(orgService, uService, clService, mcService);
    }

    @Override
    protected void fillManagerList(Org org) {
        this.managerList = serviceOrg.findOrgPersons(portal, org); // no suborg managers used,  find all org users
    }

    @Override
    @HTTPMethods(methods = {HTTPMethod.POST})
    public String removeUnitPerson() {
        fillCurrentOrgPerson();
        roleIntValue = Roles.removeRoles((currentOrgPerson != null ? currentOrgPerson.getRole() : 0), Roles.DUMBUSER);
        return SUCCESS;
    }

    @Override
    @HTTPMethods(methods = {HTTPMethod.POST})
    public String addUnitPerson() {
        Person subject = serviceUser.findObject(Person.class, userId);
        if (isUserManager(subject)) {
            addActionMessage(getText("units.user_set"));
            return INPUT;
        }

        fillCurrentOrgPerson();
        roleIntValue = Roles.addRoles((currentOrgPerson != null ? currentOrgPerson.getRole() : 0), Roles.DUMBUSER);
        return SUCCESS;
    }

}
