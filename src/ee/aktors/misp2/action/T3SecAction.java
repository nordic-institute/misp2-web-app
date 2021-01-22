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

import com.opensymphony.xwork2.ActionSupport;
import com.opensymphony.xwork2.Preparable;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.T3Sec;
import ee.aktors.misp2.service.T3SecService;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * T3Sec entity (audit log) related actions
 * @author arnis.rips
 */
public class T3SecAction extends ActionSupport implements Preparable {
    private static final long serialVersionUID = 1L;
    private T3SecService tService;
    private String actionSelect;
    private String ssnFrom;
    private String ssnTo;
    private String orgCode;
    private String queryId;
    private String groupName;
    private Date dateFrom;
    private Date dateTo;
    private int selectedAction;
    private List<T3Sec> searchResults;
    private Map<Integer, String> actions;
    
    /**
     * Init T3SecAction bean
     * @param tService T3SecService instance for DB access
     */
    public T3SecAction(T3SecService tService) {
        this.tService = tService;
    }

    /**
     * Initialize action
     */
    @Override
    public void prepare() throws Exception {
        initActions();
        if (!(getActionSelect() == null))
            setSelectedAction(Integer.parseInt(getActionSelect()));
        else
            setSelectedAction(-1);
    }

    /**
     * Fill audit log action type select options
     */
    public void initActions() {
        this.actions = new HashMap<Integer, String>();
        final int noOfActions = 8;
        for (int i = 0; i < noOfActions; i++) {
            actions.put(i, getText("t3sec.action.select." + i));
        }

    }

    /**
     * Find audit log entries (T3Sec entity list) and fill #seachResults member with them
     * @return status describing if action was successful
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String filter() {
        if (getActionSelect() != null)
            searchResults = tService
                    .findT3Sec(
                        new T3SecService.T3SecParameters()
                        .setAction(T3SecService.T3SecActionType
                                .getT3SecActionTypeByCode(Integer.parseInt(getActionSelect())))
                        .setSsnFrom(ssnFrom)
                        .setSsnTo(ssnTo)
                        .setOrgCode(orgCode)
                        .setQueryId(queryId)
                        .setGroupName(groupName)
                        .setStart(dateFrom)
                        .setEnd(dateTo));
        return SUCCESS;
    }

    /**
     * @return audit log entry list previously filled in {@link #filter()}
     */
    public List<T3Sec> getSearchResults() {
        return searchResults;
    }

    /**
     * @return audit log action types; used for select options
     */
    public Map<Integer, String> getActions() {
        return actions;
    }

    /**
     * Set selected action
     * @param actionSelectNew selected action
     */
    public void setActionSelect(String actionSelectNew) {
        this.actionSelect = actionSelectNew;
    }

    /**
     * @return selected action
     */
    public String getActionSelect() {
        return actionSelect;
    }

    /**
     * Set SSN of action performer.
     * @param ssnFromNew SSN of action performer
     */
    public void setSsnFrom(String ssnFromNew) {
        this.ssnFrom = ssnFromNew;
    }

    /**
     * @return SSN of action performer
     */
    public String getSsnFrom() {
        return ssnFrom;
    }

    /**
     * Get SSN of action target
     * @param ssnToNew SSN of action target
     */
    public void setSsnTo(String ssnToNew) {
        this.ssnTo = ssnToNew;
    }

    /**
     * @return SSN of action target
     */
    public String getSsnTo() {
        return ssnTo;
    }

    /**
     * Set organization code in audit log filter.
     * @param orgCodeNew organization code associated with the action
     */
    public void setOrgCode(String orgCodeNew) {
        this.orgCode = orgCodeNew;
    }

    /**
     * @return organization code in audit log filter
     */
    public String getOrgCode() {
        return orgCode;
    }

    /**
     * Set query entity ID
     * @param queryIdNew query entity ID
     */
    public void setQueryId(String queryIdNew) {
        this.queryId = queryIdNew;
    }

    /**
     * @return query entity ID
     */
    public String getQueryId() {
        return queryId;
    }

    /**
     * Set group name filter parameter
     * @param groupNameNew user group name
     */
    public void setGroupName(String groupNameNew) {
        this.groupName = groupNameNew;
    }

    /**
     * @return user group name
     */
    public String getGroupName() {
        return groupName;
    }

    /**
     * Set selected action type
     * @param selected action type (described in {@link T3SecService.T3SecActionType})
     */
    public void setSelectedAction(int selected) {
        this.selectedAction = selected;
    }

    /**
     * @return selected action type (described in {@link T3SecService.T3SecActionType})
     */
    public int getSelectedAction() {
        return selectedAction;
    }

    /**
     * @return end date filter parameter
     */
    public Date getDateTo() {
        return dateTo;
    }

    /**
     * Set end date filter parameter
     * @param dateToNew end date
     */
    public void setDateTo(Date dateToNew) {
        this.dateTo = dateToNew;
    }

    /**
     * @return start date filter parameter
     */
    public Date getDateFrom() {
        return dateFrom;
    }

    /**
     * Set start date filter parameter
     * @param dateFromNew start date
     */
    public void setDateFrom(Date dateFromNew) {
        this.dateFrom = dateFromNew;
    }
}
