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

package ee.aktors.misp2.beans;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.opensymphony.xwork2.ActionContext;

import edu.emory.mathcs.backport.java.util.Collections;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.util.FileUtil;
import ee.aktors.misp2.util.Roles;

/**
 * Container for organizing user rights from OrgPerson entities to a 3-tier tree structure:
 * portal -> portal organizations -> roles in that organization
 * 
 * Container is essentially used to aid rendering user roles in usersFilter.jsp.
 * 
 * @author sander
 *
 */
public class UserPortal implements Comparable<UserPortal> {
    String name;
    Portal portal;
    Map<String, PortalOrg> portalOrgs;
    /**
     * Construct user portal container
     * @param p user portal entity
     */
    UserPortal(Portal p) {
        if (p != null && ActionContext.getContext().getLocale() != null) {
            String lang = ActionContext.getContext().getLocale().getLanguage();
            name = p.getActiveName(lang);
        } else if (p != null) {
            name = p.getShortName();
        } else {
            name = null;
        }
        this.portal = p;
        portalOrgs = new LinkedHashMap<String, PortalOrg>();
    }
    /**
     * @return user portal
     */
    public Portal getPortal() {
        return portal;
    }
    
    /**
     * @return the portalOrgs
     */
    public List<PortalOrg> getPortalOrgs() {
        ArrayList<PortalOrg> l = new ArrayList<PortalOrg>(portalOrgs.values());
        Collections.sort(l);
        return l;
    }

    /**
     * @param op OrgPerson entity containing all necessary portal org information
     */
    public void addPortalOrg(OrgPerson op) {
        if (op != null) {
            Org o = op.getOrgId();
            if (o != null) {
                String portalOrgKey = "" + o.getId() + "_" + o.getCode();
                PortalOrg portalOrg;
                if (portalOrgs.containsKey(portalOrgKey)) {
                    portalOrg = portalOrgs.get(portalOrgKey);
                } else {
                    portalOrg = new PortalOrg(o);
                    portalOrgs.put(portalOrgKey, portalOrg);
                }
                portalOrg.addRole(op.getRole());
                if (portal != null && portal.getOrgId() != null && op.getOrgId() != null
                        && op.getOrgId().equals(portal.getOrgId())) {
                    portalOrg.setMain();
                }
            }
        }
    }
    
    /**
     * @return name for instance sort order comparator
     */
    public String getName() {
        return name;
    }
    @Override
    public int compareTo(UserPortal other) {
        if (this.getName() != null && other != null && other.getName() != null) {
            return FileUtil.compareCaseInsensitiveFirst(this.getName(), other.getName());
        } else {
            return -1;
        }
    }
    
    /**
     * Transform list of orgPersons to list of UserPortals which consists of
     * portal and org containers that a user has certain user roles in.
     * @param orgPersons list of OrgPerson entities associated with given user
     * @return list of UserPortal containers
     */
    public static List<UserPortal> getPortals(List<OrgPerson> orgPersons) {
        // Portal short name to portal object map for given user
        Map<String, UserPortal> userPortals = new LinkedHashMap<String, UserPortal>();
        for (OrgPerson op : orgPersons) {
            Portal p = op.getPortal();
            if (p != null && p.getShortName() != null) {
                String shortName = p.getShortName();
                UserPortal userPortal;
                if (userPortals.containsKey(shortName)) {
                    userPortal = userPortals.get(shortName);
                } else {
                    userPortal = new UserPortal(p);
                    userPortals.put(shortName, userPortal);
                }
                userPortal.addPortalOrg(op);
                //String fullName = p.getActiveName(ActionContext.getContext().getLocale().getLanguage());
            }
        }

        ArrayList<UserPortal> l = new ArrayList<UserPortal>(userPortals.values());
        Collections.sort(l);
        return l;
    }
}

class PortalOrg implements Comparable<PortalOrg> {
    String name;
    Org org;
    Set<Integer> roles;
    boolean main; // true, if current org is main org in portal (it can also be a unit)
    PortalOrg(Org o) {
        if (o != null && ActionContext.getContext().getLocale() != null) {
            String lang = ActionContext.getContext().getLocale().getLanguage();
            name = o.getActiveName(lang);
        } else if (o != null) {
            name = o.getCode();
        } else {
            name = null;
        }
        this.org = o;
        this.roles = new LinkedHashSet<Integer>();
        this.main = false;
    }
    /**
     * @return org entity
     */
    public Org getOrg() {
        return org;
    }
    /**
     * @return user roles in an org
     */
    public List<Integer> getRoles() {
        return new ArrayList<Integer>(roles);
    }
    
    /**
     * Add user role to collection of user roles in an org
     * @param role user role in an org
     */
    public void addRole(Integer role) {
        if (role != null) {
            this.roles.addAll(Roles.getAllRolesSet(role));
        }
    }
    public void setMain() {
        this.main = true;
    }
    /**
     * @return the main
     */
    public boolean isMain() {
        return main;
    }

    /**
     * @return name for instance sort order comparator
     */
    public String getName() {
        return name;
    }
    @Override
    public int compareTo(PortalOrg other) {
        // Bring main organization to front
        if (this.isMain() && !other.isMain()) {
            return -1;
        } else if (!this.isMain() && other.isMain()) {
            return 1;
         // Otherwise compare alphabetically
        } else if (this.getName() != null && other != null && other.getName() != null) {
            return FileUtil.compareCaseInsensitiveFirst(this.getName(), other.getName());
        } else {
            return -1;
        }
    }
}
