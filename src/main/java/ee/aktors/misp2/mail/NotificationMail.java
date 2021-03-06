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

package ee.aktors.misp2.mail;

import ee.aktors.misp2.beans.GroupValidPair;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 *
 * @author arnis.rips
 */
public class NotificationMail extends AutoGeneratedMail {

    private List<GroupValidPair> removedGroups;
    private List<GroupValidPair> addedGroups;
    private Set<Integer> addedRoles;
    private Set<Integer> removedRoles;
    private String organizationName;

    protected String createBody() {
        StringBuilder body = new StringBuilder(super.createBody());
        if (organizationName != null && !organizationName.isEmpty()) {
            body.append(LINEBREAK).append(getText("notify.message.org_name")).append(SPACE).append(organizationName)
                    .append(LINEBREAK);
        }
        if (removedGroups != null && !removedGroups.isEmpty()) {
            // message about removed groups
            body.append(getText("notify.message.removed_groups")).append(LINEBREAK).append(TAB);
            Iterator<GroupValidPair> rmgi = removedGroups.iterator();
            while (rmgi.hasNext()) {
                body.append(rmgi.next().getGroupName());
                if (rmgi.hasNext()) {
                    body.append(SEPARATOR);
                }
            }
        }

        if (addedGroups != null && !addedGroups.isEmpty()) {
            body.append(LINEBREAK).append(getText("notify.message.added_groups")).append(LINEBREAK);
            Iterator<GroupValidPair> agi = addedGroups.iterator();
            while (agi.hasNext()) {
                GroupValidPair ag = agi.next();
                // message about group name
                body.append(getText("notify.message.group_name")).append(SPACE).append(ag.getGroupName());
                if (ag.getValidUntil() != null) {
                    // message about expiration date in group
                    body.append(SPACE).append(getText("notify.message.valid_until")).append(ag.getValidUntil());
                }
                body.append(LINEBREAK);
            }
        }

        if (addedRoles != null && !addedRoles.isEmpty()) {
            // message about added roles
            body.append(LINEBREAK).append(getText("notify.message.added_roles")).append(SPACE);
            Iterator<Integer> ri = addedRoles.iterator();
            while (ri.hasNext()) {
                body.append(getText("roles." + ri.next()));
                if (ri.hasNext()) {
                    body.append(SEPARATOR);
                }
            }
        }
        if (removedRoles != null && !removedRoles.isEmpty()) {
            // message about removed roles
            body.append(LINEBREAK).append(getText("notify.message.removed_roles")).append(SPACE);
            Iterator<Integer> ri = removedRoles.iterator();
            while (ri.hasNext()) {
                body.append(getText("roles." + ri.next()));
                if (ri.hasNext()) {
                    body.append(SEPARATOR);
                }
            }
        }
        return body.toString();
    }

    /**
     * @see ee.aktors.misp2.mail.AutoGeneratedMail#getSubject()
     * @return gets message for "notify.subject"
     * from {@code TextProvider}
     */
    public String getSubject() {
        return getText("notify.subject");
    }

    /**
     * @return the addedGroups
     */
    public List<GroupValidPair> getAddedGroups() {
        return addedGroups;
    }

    /**
     * @param addedGroupsNew the addedGroups to set
     */
    public void setAddedGroups(List<GroupValidPair> addedGroupsNew) {
        this.addedGroups = addedGroupsNew;
    }

    /**
     * @return the addedRoles
     */
    public Set<Integer> getAddedRoles() {
        return addedRoles;
    }

    /**
     * @param addedRolesNew the addedRoles to set
     */
    public void setAddedRoles(Set<Integer> addedRolesNew) {
        this.addedRoles = addedRolesNew;
    }

    /**
     * @return the removedRoles
     */
    public Set<Integer> getRemovedRoles() {
        return removedRoles;
    }

    /**
     * @param removedRolesNew the removedRoles to set
     */
    public void setRemovedRoles(Set<Integer> removedRolesNew) {
        this.removedRoles = removedRolesNew;
    }

    /**
     * @param removedGroupsNew the removedGroups to set
     */
    public void setRemovedGroups(List<GroupValidPair> removedGroupsNew) {
        this.removedGroups = removedGroupsNew;
    }

    /**
     * @param organizationNameNew the organizationName to set
     */
    public void setOrganizationName(String organizationNameNew) {
        this.organizationName = organizationNameNew;
    }


}
