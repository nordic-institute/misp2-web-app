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

package ee.aktors.misp2.action.registration;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.logging.log4j.LogManager;

import ee.aktors.misp2.beans.ManagerCandidateBean;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.ManagerCandidate;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.service.ClassifierService;
import ee.aktors.misp2.service.ManagerCandidateService;
import ee.aktors.misp2.service.OrgService;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
public class RegisterUkManagerAction extends RegisterManagerAction {

    private static final long serialVersionUID = 1L;

    /**
     * @param orgService orgService to inject
     * @param uService   uService   to inject
     * @param clService  clService  to inject
     * @param mcService  mcService  to inject
     */
    public RegisterUkManagerAction(OrgService orgService, UserService uService, ClassifierService clService,
                                   ManagerCandidateService mcService) {
        super(orgService, uService, clService, mcService);
        registerUnknown = true;
    }

    @Override
    @HTTPMethods(methods = {HTTPMethod.GET})
    public String showForm() {
        String res = super.showForm();
        fillManagerCandidates(activeOrg);
        return res;
    }

    private boolean isManagerCandidate(Person user) {
        ManagerCandidate mc = serviceMgrCand.findManagerCandidate(portal, activeOrg, user, activeUser.getSsn());
        return mc != null;
    }

    @Override
    @SuppressWarnings("unchecked")
    @HTTPMethods(methods = {HTTPMethod.POST})
    public String addUnitPerson() {
        LogManager.getLogger(this.getClass()).debug("activeUser = " + activeUser); //TODO  REMOVE - activeUser
        LogManager.getLogger(this.getClass()).debug("userId = " + userId); //TODO  REMOVE - userId
        Person subject = serviceMgrCand.findObject(Person.class, userId);
        if (isUserManager(subject)) {
            addActionMessage(getText("units.manager_set"));
            return INPUT;
        }
        if (isManagerCandidate(subject)) {
            addActionMessage("Kandidaat " + getText("units.manager_set"));
            return INPUT;
        }
        ManagerCandidate mc = new ManagerCandidate();
        mc.setAuthSsn(activeUser.getSsn());
        mc.setPortal(portal);
        mc.setManagerId(subject);
        mc.setOrgId(activeOrg);

        serviceMgrCand.save(mc);


        ManagerCandidateBean mcb1 = new ManagerCandidateBean(subject);
        managerCandidatesList = (List<ManagerCandidateBean>) session.get(Const.SESSION_MANAGER_CANDIDATES);
        LogManager.getLogger(this.getClass()).debug("managerCandidatesList = " + managerCandidatesList);
        //TODO  REMOVE - managerCandidatesList
        if (managerCandidatesList != null) {
            for (ManagerCandidateBean mcb : managerCandidatesList) {
                if (mcb1.getCandidate().getSsn().equals(mcb.getCandidate().getSsn())) {
                    LogManager.getLogger(RegisterUkManagerAction.class)
                        .debug("Found candidate " + mcb1.getCandidate() + " from list");
                    LogManager.getLogger(RegisterUkManagerAction.class)
                        .debug("mcb.getConfirmationRequired() = " + mcb.getConfirmationRequired());
                    LogManager.getLogger(RegisterUkManagerAction.class)
                        .debug("mcb.getConfirmationRequired().iterator().next().getSsn() = "
                    + mcb.getConfirmationRequired().iterator().next().getSsn());
                    LogManager.getLogger(RegisterUkManagerAction.class)
                        .debug("activeUser.getSsn() = " + activeUser.getSsn());
                    if (mcb.getConfirmationRequired().size() == 1
                            && mcb.getConfirmationRequired().iterator().next().getSsn().equals(activeUser.getSsn())) {
                        //check if was last
                        //check if i was the last activeUser
                        super.addUnitPerson();
                        return REDIRECT;
                    }
                }
            }
        }

        return SUCCESS;
    }

//    @Override
//    public String showForm() {
//        String result = super.showForm();
//        fillManagerCandidates((Org) session.get(Const.SESSION_ACTIVE_ORG));
//
//        return result;
//    }
    @Override
    @HTTPMethods(methods = {HTTPMethod.POST})
    public String removeUnitPerson() {
        serviceMgrCand.removeManagerCandidate(portal, activeOrg, userId, activeUser.getSsn());
        return super.removeUnitPerson();
    }

    private void fillManagerCandidates(Org orgE) {
        List<ManagerCandidate> allOrgMgrCands = serviceMgrCand.findOrgSortedMgrCandidates(portal, orgE);
        
        @SuppressWarnings("unchecked")
        Map<Org, List<Person>> boardOfDirectors =
            (Map<Org, List<Person>>) session.get(Const.SESSION_BOARD_OF_DIRECTORS);
        
        for (Org org : boardOfDirectors.keySet()) {
            
            if (org.equals(orgE)) {
                List<Person> directors = boardOfDirectors.get(org);
                ManagerCandidateBean oldMcb = null;
                if (allOrgMgrCands != null) {
                    for (ManagerCandidate mc : allOrgMgrCands) {
                        ManagerCandidateBean mcb = new ManagerCandidateBean(mc.getManagerId());
                        Set<Person> approved = new LinkedHashSet<Person>();
                        Set<Person> disApproved = new LinkedHashSet<Person>();
                        if (mcb.equals(oldMcb)) {
                            approved = oldMcb.getConfirmationGiven();
                            disApproved = oldMcb.getConfirmationRequired();
                        } else {
                            if (oldMcb != null) {
                                managerCandidatesList.add(oldMcb);
                            }
                        }
                        for (Person dir : directors) {
                            if (dir.getSsn().equals(mc.getAuthSsn())) {
                                // has approved
                                approved.add(dir);
                                disApproved.remove(dir);

                            } else {
                                if (!approved.contains(dir)) {
                                    disApproved.add(dir);
                                } else {
                                    disApproved.remove(dir);
                                }
                            }
                        }
                        mcb.setConfirmationGiven(approved);
                        mcb.setConfirmationRequired(disApproved);
                        oldMcb = mcb;
                        LogManager.getLogger(RegisterUkManagerAction.class).debug("approved = " + oldMcb.
                                getConfirmationGiven());
                        LogManager.getLogger(RegisterUkManagerAction.class).debug("disApproved = " + oldMcb.
                                getConfirmationRequired());
                    }
                }
                if (oldMcb != null) {
                    managerCandidatesList.add(oldMcb); // add last one
                }
                LogManager.getLogger(this.getClass()).debug("managerCandidates = " + managerCandidatesList);
                //TODO  REMOVE - managerCandidates
                session.put(Const.SESSION_MANAGER_CANDIDATES, managerCandidatesList);
                break;
            }
        }
    }

}
