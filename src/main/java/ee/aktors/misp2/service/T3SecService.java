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

package ee.aktors.misp2.service;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.logging.log4j.LogManager;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.model.T3Sec;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.LogQuery;

/**
 * T3Sec (audit log) entity related service methods
 * @author arnis.rips
 */
public class T3SecService extends BaseService {
    

    /**
     * Find T3Sec entity by various search parameters
     * @param t3SecParameters search parameters
     * @return list of found T3Sec entities
     */
    @SuppressWarnings("unchecked")
    public List<T3Sec> findT3Sec(T3SecParameters t3SecParameters) {
        boolean state;
        try {
            LogManager.getLogger(this.getClass()).debug(t3SecParameters.getStart() + "   " + t3SecParameters.getEnd());
            Map<String, Object> parameters = new HashMap<String, Object>();
            Portal portal = (Portal) ActionContext.getContext().getSession().get(Const.SESSION_PORTAL);
            String sql = "select t from T3Sec t ";
            String where = " where t.portalName='" + portal.getShortName() + "' ";
            // check if ssnFrom was asked
            state = t3SecParameters.getSsnFrom() != null && !t3SecParameters.getSsnFrom().isEmpty();
            where += (state ? " and lower(t.userFrom) like :userFrom " : "");
            if (state) parameters.put("userFrom", "%" + t3SecParameters.getSsnFrom().toLowerCase() + "%");
            
            // check if ssnTo was asked
            state = t3SecParameters.getSsnTo() != null && !t3SecParameters.getSsnTo().isEmpty();
            where += (state ? " and lower(t.userTo) like :userTo  " : "");
            if (state) parameters.put("userTo", "%" + t3SecParameters.getSsnTo().toLowerCase() + "%");
            
            // check if orgCode was asked
            state = t3SecParameters.getOrgCode() != null && !t3SecParameters.getOrgCode().isEmpty();
            where += (state ? " and lower(t.orgCode) like :orgCode " : "");
            if (state) parameters.put("orgCode", "%" + t3SecParameters.getOrgCode().toLowerCase() + "%");
            
            // check if queryId was asked
            state = t3SecParameters.getQueryId() != null && !t3SecParameters.getQueryId().isEmpty();
            where += (state ? " and lower(t.queryId) like :queryId " : "");
            if (state) parameters.put("queryId", "%" + t3SecParameters.getQueryId().toLowerCase() + "%");
            
            // check if groupName was asked
            state = t3SecParameters.getGroupName() != null && !t3SecParameters.getGroupName().isEmpty();
            where += (state ? " and lower(t.groupName) like :groupName " : "");
            if (state) parameters.put("groupName", "%" + t3SecParameters.getGroupName().toLowerCase()  + "%");
            
            state = t3SecParameters.getStart() != null;
            where += (state ? " and t.created >=:start" : "");

            state = t3SecParameters.getEnd() != null;
            where += (state ? " and t.created <=:end" : "");
            
            
            switch (t3SecParameters.getAction()) {
            case MANAGER_ACTION:
                where += " and (t.actionId=" + LogQuery.MANAGER_SETTING + " or t.actionId = " + LogQuery.MANAGER_DELETE
                        + ")";
                break; // manager add/delete
            case USERGROUP_ACTION:
                where += " and (t.actionId=" + LogQuery.USERGROUP_ADD + " or t.actionId = " + LogQuery.USERGROUP_DELETE
                        + ")";
                break; // group add/delete
            case USERGROUP_USER_ACTION:
                where += " and (t.actionId=" + LogQuery.USER_ADD_TO_GROUP + " or t.actionId = "
                        + LogQuery.USER_DELETE_FROM_GROUP + ")";
                break; // person_group add/delete
            case QUERY_ACTON:
                where += " and (t.actionId=" + LogQuery.QUERY_RIGHTS_ADD + " or t.actionId = "
                        + LogQuery.QUERY_RIGHTS_DELETE + ")";
                break; // group_item add/delete
            case USER_ACTION:
                where += " and (t.actionId=" + LogQuery.USER_ADD + " or t.actionId = " + LogQuery.USER_DELETE + ")";
                break; // person add/delete
            case PORTAL_ACTION:
                where += " and (t.actionId=" + LogQuery.PORTAL_ADD + " or t.actionId = " + LogQuery.PORTAL_DELETE
                        + " or t.actionId = " + LogQuery.UNIT_ADD + " or t.actionId = " + LogQuery.UNIT_DELETE + " )";
                break; // portal / org add/delete
            case REPRESENTATION_ACTION:
                where += " and t.actionId=" + LogQuery.REPRESENTION_CHECK;
                break; // auth query call
            case VALIDITY_CHECK_ACTION:
                where += " and t.actionId=" + LogQuery.NEGATIVE_RESPONSE_VALIDITY_CHECK;
                break; // check query with negative response
            default:
                // when action is missing, add no additional query parameters
                break;
            }
            
            sql += where;
            sql += " order by t.created ";
            javax.persistence.Query s = getEntityManager().createQuery(sql);
            for (String param : parameters.keySet()) {
                s.setParameter(param, parameters.get(param));
            }
            if (t3SecParameters.getStart() != null)
                s.setParameter("start", t3SecParameters.getStart());
            if (t3SecParameters.getEnd() != null)
                s.setParameter("end", t3SecParameters.getEnd());
            return s.getResultList();
        } catch (Exception e) {
            LogManager.getLogger(T3SecService.class).warn(e.getMessage());
            return null;
        }
    }
    
    /**
     * T3Sec entity action types
     * @author sander.kallo
     */
    public static enum T3SecActionType {
        MANAGER_ACTION(0),
        USERGROUP_ACTION(1),
        USERGROUP_USER_ACTION(2),
        QUERY_ACTON(3),
        USER_ACTION(4),
        PORTAL_ACTION(5),
        REPRESENTATION_ACTION(6),
        VALIDITY_CHECK_ACTION(7);
        
        private int code;
        T3SecActionType(int inputCode) {
            this.code = inputCode;
        }
        /**
         * @return action code as integer
         */
        public int getCode() {
            return code;
        }
        
        /**
         * Find T3SecActionType by corresponding code
         * @param code integer code associated with given action
         * @return matching {@link T3SecActionType} or null, if match was not found
         */
        public static T3SecActionType getT3SecActionTypeByCode(int code) {
            for (T3SecActionType t3SecActionType : T3SecActionType.values()) {
                if (t3SecActionType.getCode() == code) return t3SecActionType;
            }
            return null;
        }
    }
    
    /**
     * T3Sec service parameter container to work around RIA checkstyle limitation
     * @author sander.kallo
     *
     */
    public static final class T3SecParameters {
        private T3SecActionType action;
        private String ssnFrom;
        private String ssnTo;
        private String orgCode;
        private String queryId;
        private String groupName;
        private Date start;
        private Date end;
        /**
         * @return the action that is audit logged
         */
        public T3SecActionType getAction() {
            return action;
        }
        /**
         * @return the action that is audit logged
         */
        public int getActionCode() {
            return action.getCode();
        }
        
        /**
         * @param inputAction the audit log action to set
         * @return current builder instance
         */
        public T3SecParameters setAction(T3SecActionType inputAction) {
            this.action = inputAction;
            return this;
        }
        /**
         * @return the social security number of the action performer
         */
        public String getSsnFrom() {
            return ssnFrom;
        }
        /**
         * @param inputSsnFrom the SSN of the performer to set
         * @return current builder instance
         */
        public T3SecParameters setSsnFrom(String inputSsnFrom) {
            this.ssnFrom = inputSsnFrom;
            return this;
        }
        /**
         * @return the social security number of action target
         */
        public String getSsnTo() {
            return ssnTo;
        }
        /**
         * @param inputSsnTo the SSN of the target to set
         * @return current builder instance
         */
        public T3SecParameters setSsnTo(String inputSsnTo) {
            this.ssnTo = inputSsnTo;
            return this;
        }
        /**
         * @return the organization code
         */
        public String getOrgCode() {
            return orgCode;
        }
        /**
         * @param inputOrgCode the organization code to set
         * @return current builder instance
         */
        public T3SecParameters setOrgCode(String inputOrgCode) {
            this.orgCode = inputOrgCode;
            return this;
        }
        /**
         * @return the query entity ID
         */
        public String getQueryId() {
            return queryId;
        }
        /**
         * @param inputQueryId the query entity ID to set
         * @return current builder instance
         */
        public T3SecParameters setQueryId(String inputQueryId) {
            this.queryId = inputQueryId;
            return this;
        }
        /**
         * @return the groupName
         */
        public String getGroupName() {
            return groupName;
        }
        /**
         * @param inputGroupName the group name to set
         * @return current builder instance
         */
        public T3SecParameters setGroupName(String inputGroupName) {
            this.groupName = inputGroupName;
            return this;
        }
        /**
         * @return the start date
         */
        public Date getStart() {
            return start;
        }
        /**
         * @param inputStart the start date to set
         * @return current builder instance
         */
        public T3SecParameters setStart(Date inputStart) {
            this.start = inputStart;
            return this;
        }
        /**
         * @return the end date
         */
        public Date getEnd() {
            return end;
        }
        /**
         * @param inputEnd the end date to set
         * @return current builder instance
         */
        public T3SecParameters setEnd(Date inputEnd) {
            this.end = inputEnd;
            return this;
        }
    }
}
