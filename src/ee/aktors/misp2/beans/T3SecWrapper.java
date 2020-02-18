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

package ee.aktors.misp2.beans;

import ee.aktors.misp2.model.T3Sec;
import java.io.Serializable;
import java.util.List;

/**
 *
 * @author arnis.rips
 */
public class T3SecWrapper implements Serializable {

    private static final long serialVersionUID = 1L;
    private T3Sec t3sec = new T3Sec();
    private String actionName = "";
    private String superOrgCode;
    private List<String> usersTo;
    private List<GroupValidPair> groups;
    private List<String> queries;
    /**
     * @return the t3sec
     */
    public T3Sec getT3sec() {
        return t3sec;
    }
    /**
     * @param t3secNew the t3sec to set
     */
    public void setT3sec(T3Sec t3secNew) {
        this.t3sec = t3secNew;
    }
    /**
     * @return the actionName
     */
    public String getActionName() {
        return actionName;
    }
    /**
     * @param actionNameNew the actionName to set
     */
    public void setActionName(String actionNameNew) {
        this.actionName = actionNameNew;
    }
    /**
     * @return the superOrgCode
     */
    public String getSuperOrgCode() {
        return superOrgCode;
    }
    /**
     * @param superOrgCodeNew the superOrgCode to set
     */
    public void setSuperOrgCode(String superOrgCodeNew) {
        this.superOrgCode = superOrgCodeNew;
    }
    /**
     * @return the usersTo
     */
    public List<String> getUsersTo() {
        return usersTo;
    }
    /**
     * @param usersToNew the usersTo to set
     */
    public void setUsersTo(List<String> usersToNew) {
        this.usersTo = usersToNew;
    }
    /**
     * @return the groups
     */
    public List<GroupValidPair> getGroups() {
        return groups;
    }
    /**
     * @param groupsNew the groups to set
     */
    public void setGroups(List<GroupValidPair> groupsNew) {
        this.groups = groupsNew;
    }
    /**
     * @return the queries
     */
    public List<String> getQueries() {
        return queries;
    }
    /**
     * @param queriesNew the queries to set
     */
    public void setQueries(List<String> queriesNew) {
        this.queries = queriesNew;
    }


}
