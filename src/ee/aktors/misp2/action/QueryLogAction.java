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

package ee.aktors.misp2.action;

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.Validateable;
import ee.aktors.misp2.beans.QueryLogItem;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.QueryErrorLog;
import ee.aktors.misp2.model.QueryLog;
import ee.aktors.misp2.service.QueryLogService;
import ee.aktors.misp2.service.QueryLogService.QueryLogInput;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.CsvConf;
import ee.aktors.misp2.util.FileUtil;
import ee.aktors.misp2.util.Roles;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.nio.charset.Charset;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

import static org.apache.commons.lang.StringEscapeUtils.escapeCsv;

/**
 *
 * @author arnis.rips
 */
public class QueryLogAction extends QuickTipAction implements Validateable {


    private static final int FILTER_END_5 = 5;
    private static final int MAX_MINUTE = 59;
    private static final int MAX_HOUR = 23;
    private static final int FILTER_START_5 = 5;
    private static final int MINUTES_SUBSTRING_END = 5;
    private static final int MINUTES_SUBSTRING_START = 3;
    private static final int MINUTES = 60;
    private static final int MILLISECONDS = 1000;
    private static final int SECONDS = 60;
    private static final long serialVersionUID = 1L;
    protected QueryLogService serviceQuery;
    protected UserService serviceUser;
    protected Date dayAgo;
    protected Date today = new Date();
    protected ActionContext context;
    protected Date filterDateStart;
    protected Date filterDateEnd;
    protected Date dateTimeStart;
    protected Date dateTimeEnd;
    protected String filterTimeStart;
    protected String filterTimeEnd;
    protected boolean successful = false;
    protected String filterQueryName;
    protected String filterQueryDescription;
    protected String filterQueryId;
    protected String filterPersonSsn;
    protected String filterUnitCode;
    protected Calendar calendar = Calendar.getInstance();
    protected Person person;
    protected Org activeOrg;
    protected List<QueryLogItem> searchResults;
    protected QueryLog queryLog;
    protected Integer selectedUserId;
    protected Set<Person> allUsers;
    protected boolean allowSelectUsers;
    protected int pageNumber;
    protected long itemCount;
    protected final int pageSize = 25;
    protected SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
    protected String btnSearch; // parameter indicating whether search button was pressed
    protected String btnExportCsv; // parameter indicating whether export-to-CSV button was pressed
    protected InputStream csvStream;
    protected String csvFileName;
    private static final Logger LOG = LogManager.getLogger(QueryLogAction.class);

    /**
     * @param serviceQuery serviceQuery to inject
     * @param serviceUser serviceUser to inject
     */
    public QueryLogAction(QueryLogService serviceQuery, UserService serviceUser) {
        this.serviceQuery = serviceQuery;
        this.serviceUser = serviceUser;
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_YEAR, -1);
        this.dayAgo = cal.getTime();
    }

    @Override
    public void prepare() throws Exception {
        super.prepare();
        person = serviceQuery.reAttach(user, Person.class);
        activeOrg = serviceQuery.reAttach(org, Org.class);

        allUsers = serviceUser.findAllPortalUsers(portal);
        if (Roles.PORTAL_MANAGER == role.intValue()) {
            allowSelectUsers = true;

        } else if (Roles.PERMISSION_MANAGER == role.intValue()) {
            allowSelectUsers = true;
        } else {
            allowSelectUsers = false;
        }
        context = ActionContext.getContext();
        if (getFilterDateStart() == null)
            setFilterDateStart(dayAgo);
        if (getFilterDateEnd() == null)
            setFilterDateEnd(today);

        if (getFilterTimeStart() == null)
            setFilterTimeStart("00:00");
        if (getFilterTimeEnd() == null)
            setFilterTimeEnd("23:59");
        setSuccessful(false);
    }

    /**
     * @return SUCCESS
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String showFilter() {
        return SUCCESS;
    }

    /**
     * <h1>Main query-log search action for user</h1>
     * 
     * Perform queryLog search with submitted input parameters.
     * Output HTML with paginated results or CSV if btnExportCsv is set.
     * If btnSearch nor btnExportCsv was pressed, skip search and return page without results.
     * <p>
     * NB! This method applies for "normal user". Manager query logs have a different action
     * {@link ManagerQueryLogAction} (but that action renders view with the <u>same</u> JSP).
     * @return SUCCESS
     * @throws IOException on CSV export failure
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String filter() throws IOException {
        Org activeOrgPrivate = (Org) session.get(Const.SESSION_ACTIVE_ORG);

        ArrayList<String> filterSsn = new ArrayList<>();
        if (getPerson() != null) {
            filterSsn.add(getPerson().getSsn());
        }
        if (filterPersonSsn != null && !filterPersonSsn.isEmpty()) {
            filterSsn.add(filterPersonSsn);
        }

        dateTimeStart = parseTimeString(filterDateEnd, filterTimeStart, timeFormat);
        dateTimeEnd = parseTimeString(filterDateEnd, filterTimeEnd, timeFormat);

        QueryLogInput input = new QueryLogInput();
        input.setPortal(portal);
        input.setActiveOrg(activeOrgPrivate);
        input.setPersonSsn(filterSsn);
        input.setQueryDescription(filterQueryDescription);
        input.setQueryName(filterQueryName);
        input.setUnitCode(filterUnitCode);
        input.setQueryId(filterQueryId);
        input.setStart(dateTimeStart);
        input.setEnd(dateTimeEnd);
        input.setSuccessful(successful);

        
        if (isButtonPressed()) { // search button was pressed - search and display the results
            if (isCsvExport()) { // asseble CSV file for download
                itemCount = serviceQuery.countPersonQueryLogs(input);
                if (!isCsvItemCountAllowed(itemCount)) {
                    return ERROR;
                }
                searchResults = serviceQuery.findPersonQueryLogs(input, -1, -1);
                // create file name presented for the user for download
                csvFileName = FileUtil.getExportFileName("query-log", portal, "csv");
                csvStream = createCsvStream(searchResults, QueryLogType.SHORT);
                LOG.info("Generated " + csvFileName + " for download.");
                return "success_csv"; // redirect to exportToCsv (definded in struts.xml)
            } else {
                itemCount = serviceQuery.countPersonQueryLogs(input);
                searchResults = serviceQuery.findPersonQueryLogs(input, pageNumber, pageSize);
            }
        } else { // page was loaded with no button-press action
            itemCount = 0;
        }
        return SUCCESS;
    }

    protected boolean isCsvItemCountAllowed(long queryResultCount) {
        if (!isCsvExport()) {
            return true;
        }
        String confKey = "querylog.csv.maxItemCount";
        final long maxCsvItemCountDefault = 5000;
        final long maxCsvItemCount = CONFIG.getLong(confKey, maxCsvItemCountDefault);
        if (queryResultCount > maxCsvItemCount) {
            LOG.error("Query log CSV export returned " + queryResultCount + " lines. "
                    + "Up to " + maxCsvItemCount + " lines are allowed.");
            addActionError(getText("user_query_logs.csv.error.max_allowed_line_count_exceeded",
                    new String[]{"" + queryResultCount, "" + maxCsvItemCount}));
            return false;
        } else {
            return true;
        }
    }

    @Override
    public void validate() {
        if (filterTimeStart == null || filterTimeStart.isEmpty() || filterTimeStart.length() != FILTER_START_5) {
            addFieldError("filterDateStart", getText("my_settings.error.datedelta.starttime"));
            for (List<String> s : getFieldErrors().values()) {
                setActionErrors(s);
            }
            return;
        }

        try {
            dateTimeStart = timeFormat.parse(filterTimeStart);
            long hr;
            long min;
            try {
                hr = Long.parseLong(filterTimeStart.substring(0, 2));
                min = Long.parseLong(filterTimeStart.substring(MINUTES_SUBSTRING_START, MINUTES_SUBSTRING_END));

                if (hr < 0 || hr > MAX_HOUR || min < 0 || min > MAX_MINUTE) {
                    addFieldError("filterDateStart", getText("my_settings.error.datedelta.starttime"));
                }
            } catch (NumberFormatException e) {
                addFieldError("filterDateStart", getText("my_settings.error.datedelta.starttime"));
            }
        } catch (ParseException e) {
            addFieldError("filterDateStart", getText("my_settings.error.datedelta.starttime"));
        }

        if (filterTimeEnd == null || filterTimeEnd.isEmpty() || filterTimeEnd.length() != FILTER_END_5) {
            addFieldError("filterDateEnd", getText("my_settings.error.datedelta.endtime"));
            for (List<String> s : getFieldErrors().values()) {
                setActionErrors(s);
            }
            return;
        }

        try {
            dateTimeEnd = timeFormat.parse(filterTimeEnd);
            long hr;
            long min;
            try {
                hr = Long.parseLong(filterTimeEnd.substring(0, 2));
                min = Long.parseLong(filterTimeEnd.substring(MINUTES_SUBSTRING_START, MINUTES_SUBSTRING_END));
                if (hr < 0 || hr > MAX_HOUR || min < 0 || min > MAX_MINUTE) {
                    addFieldError("filterDateEnd", getText("my_settings.error.datedelta.endtime"));
                }
            } catch (NumberFormatException e) {
                addFieldError("filterDateEnd", getText("my_settings.error.datedelta.endtime"));
            }
        } catch (ParseException e) {
            addFieldError("filterDateEnd", getText("my_settings.error.datedelta.endtime"));
        }

        for (List<String> s : getFieldErrors().values()) {
            setActionErrors(s);
        }
    }



    protected enum QueryLogType { SHORT, FULL };
    
    /**
     * Create CSV input stream and set CSV file name so struts.xml can use tham as action response.
     * @param filename CSV file filename presented to user for download
     * @param searchResults list of query log items added to CSV file;
     *      each item corresponds to a row in CSV
     */
    protected InputStream createCsvStream(List<QueryLogItem> searchResultsForCsv, QueryLogType type) {
        CsvConf csvConf = new CsvConf(CONFIG, ActionContext.getContext().getLocale());
        final String sep = csvConf.getSeparator();
        final DateFormat dateFormat = csvConf.getDateFormat();
        final String newline = csvConf.getNewline();
        final Charset encoding = csvConf.getEncoding();
        final StringWriter writer = new StringWriter();
        
        // add header
        writer
            .append(escapeCsv(getText("user_query_logs.csv.header.query_log.query_name")))  /*1*/
            .append(sep)
            .append(escapeCsv(getText("user_query_logs.csv.header.query_log.description"))) /*2*/
            .append(sep)
            .append(escapeCsv(getText("user_query_logs.csv.header.query_log.person_ssn")))  /*3*/
            .append(sep)
            .append(escapeCsv(getText("user_query_logs.csv.header.person.full_name")))      /*4*/
            .append(sep)
            .append(escapeCsv(getText("user_query_logs.csv.header.query_log.query_time")))  /*5*/
            .append(sep)
            .append(escapeCsv(getText("user_query_logs.csv.header.query_log.query_id")))    /*6*/
            .append(sep)
            .append(escapeCsv(getText("user_query_logs.csv.header.query_log.unit_code")))   /*7*/
            .append(sep)
            .append(escapeCsv(getText("user_query_logs.csv.header.error_log.code")))        /*8*/
            .append(sep)
            .append(escapeCsv(getText("user_query_logs.csv.header.error_log.description"))) /*9*/
            .append(sep)
            .append(escapeCsv(getText("user_query_logs.csv.header.error_log.detail")))      /*10*/
            .append(sep)
            .append(escapeCsv(getText("user_query_logs.csv.header.query_log.query_size")))  /*11*/
            .append(sep)
            .append(escapeCsv(getText("user_query_logs.csv.header.query_id")))              /*12*/
            .append(newline);
        
        // add data
        for (QueryLogItem item : searchResultsForCsv) {
            QueryLog qLog = item.getQueryLog();
            Person p = item.getPerson();
            QueryErrorLog errLog = qLog.getQueryErrorLogId();
            
            writer
                .append(escapeCsv(qLog.getQueryName()))                                 /*1*/
                .append(sep)
                .append(escapeCsv(qLog.getDescription()))                               /*2*/
                .append(sep)
                .append(escapeCsv(qLog.getPersonSsn()))                                 /*3*/
                .append(sep)
                .append(escapeCsv(p.getFullName()))                                     /*4*/
                .append(sep)
                .append(escapeCsv(dateFormat.format(qLog.getQueryTime())))              /*5*/
                .append(sep)
                .append(escapeCsv("" + qLog.getQueryId()))                              /*6*/
                .append(sep)
                .append(escapeCsv(qLog.getUnitCode() != null ? qLog.getUnitCode() : ""))/*7*/
                .append(sep)
                .append(escapeCsv(errLog != null ? errLog.getCode() : ""))              /*8*/
                .append(sep)
                .append(escapeCsv(errLog != null ? errLog.getDescription() : ""))       /*9*/
                .append(sep)
                .append(escapeCsv(errLog != null ? errLog.getDetail() : ""))            /*10*/
                .append(sep)
                .append(escapeCsv("" + qLog.getQuerySize()))                            /*11*/
                .append(sep)
                .append(escapeCsv("" + item.getQueryId()))                              /*12*/
                .append(newline);
        }
        if (LOG.isTraceEnabled()) {
            LOG.trace("CSV: " + writer.toString());
        }
        return new ByteArrayInputStream(
                writer.toString().getBytes(encoding));
    }

    protected Date parseTimeString(Date date, String timeString, SimpleDateFormat timeFormat) {
        Date dateTime = null;
        try {
            dateTime = timeFormat.parse(timeString);
            long hr = Long.parseLong(timeString.substring(0, 2));
            long min = Long.parseLong(timeString.substring(MINUTES_SUBSTRING_START, MINUTES_SUBSTRING_END));
            long total = date.getTime() + hr * MINUTES * SECONDS * MILLISECONDS + min * SECONDS * MILLISECONDS;
            dateTime.setTime(total);

        } catch (ParseException e) {
            e.printStackTrace();
        }
        return dateTime;
    }

    /*
     * @HTTPMethods(methods = {HTTPMethod.POST}) public String logQuery() { if (person != null) { if (queryLog != null)
     * { log.debug("Logging query " + queryLog.getQueryId()); queryLog.setQueryTime(new Date());
     * queryLog.setPortal(portal); queryLog.setSuccess(Boolean.TRUE); queryLog.setId(serviceQuery.selectNextId());
     * serviceQuery.save(queryLog); } else { log.error("QueryLog is null"); } } else { log.warn("Person is null"); }
     * 
     * return SUCCESS; }
     * 
     * @HTTPMethods(methods = {HTTPMethod.POST}) public String logQueryResponse() { if (person != null) { if (queryLog
     * != null) { log.debug("Logging query response " + queryLog.getQueryId()); QueryLog ql = null; if((ql =
     * serviceQuery.findByQueryId(queryLog.getQueryId())) != null) { //ql.setResponse(queryLog.getResponse());
     * serviceQuery.save(ql); } else log.error("Could not find corresponding request or " +
     * "found more than one with query id " + queryLog.getQueryId() + " from QueryLog"); } else {
     * log.error("QueryLog is null"); } } else { log.warn("Person is null"); }
     * 
     * return SUCCESS; }
     */

    // -----------------------------------------------------------------------------------------------------------------

    /**
     * @param filterDate filterDateStart to set
     */
    public void setFilterDateStart(String filterDate) {
        try {
            this.filterDateStart = new SimpleDateFormat(getText("dateformat")).parse(filterDate);
        } catch (Exception e) {
            LOG.error("Cannot set the date start");
        }
    }

    /**
     * @param filterDate filterDateEnd to set
     */
    public void setFilterDateEnd(String filterDate) {
        try {
            this.filterDateEnd = new SimpleDateFormat(getText("dateformat")).parse(filterDate);
        } catch (Exception e) {
            LOG.error("Cannot set the date end");
        }
    }

    /**
     * @return the context
     */
    public ActionContext getContext() {
        return context;
    }

    /**
     * @return the filterDateEnd
     */
    public Date getFilterDateEnd() {
        return filterDateEnd;
    }


    /**
     * @return the filterDateStart
     */
    public Date getFilterDateStart() {
        return filterDateStart;
    }

    /**
     * @param filterDateStartNew the filterDateStart to set
     */
    public void setFilterDateStart(Date filterDateStartNew) {
        this.filterDateStart = filterDateStartNew;
    }

    /**
     * @return the filterQueryDescription
     */
    public String getFilterQueryDescription() {
        return filterQueryDescription;
    }

    /**
     * @param filterQueryNameNew the filterQueryDescription to set
     */
    public void setFilterQueryDescription(String filterQueryNameNew) {
        this.filterQueryDescription = filterQueryNameNew;
    }

    /**
     * @return the filterQueryId
     */
    public String getFilterQueryId() {
        return filterQueryId;
    }

    /**
     * @param filterDateEndNew the filterDateEnd to set
     */
    public void setFilterDateEnd(Date filterDateEndNew) {
        this.filterDateEnd = filterDateEndNew;
    }

    /**
     * @return the calendar
     */
    public Calendar getCalendar() {
        return calendar;
    }

    /**
     * @param filterQueryIdNew the filterQueryId to set
     */
    public void setFilterQueryId(String filterQueryIdNew) {
        this.filterQueryId = filterQueryIdNew;
    }

    /**
     * @return the dayAgo
     */
    public Date getDayAgo() {
        return dayAgo;
    }

    /**
     * @return the today
     */
    public Date getToday() {
        return today;
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
     * @return the searchResults
     */
    public List<QueryLogItem> getSearchResults() {
        return searchResults;
    }

    /**
     * @return the queryLog
     */
    public QueryLog getQueryLog() {
        return queryLog;
    }

    /**
     * @return the allUsers
     */
    public Set<Person> getAllUsers() {
        return allUsers;
    }

    /**
     * @param allUsersNew the allUsers to set
     */
    public void setAllUsers(Set<Person> allUsersNew) {
        this.allUsers = allUsersNew;
    }

    /**
     * @param queryLogNew the queryLog to set
     */
    public void setQueryLog(QueryLog queryLogNew) {
        this.queryLog = queryLogNew;
    }

    /**
     * @return the selectedUserId
     */
    public Integer getSelectedUserId() {
        return selectedUserId;
    }

    /**
     * @param selectedUserIdNew the selectedUserId to set
     */
    public void setSelectedUserId(Integer selectedUserIdNew) {
        this.selectedUserId = selectedUserIdNew;
    }

    /**
     * @return the allowSelectUsers
     */
    public boolean isAllowSelectUsers() {
        return allowSelectUsers;
    }

    /**
     * @param allowSelectUsersNew the allowSelectUsers to set
     */
    public void setAllowSelectUsers(boolean allowSelectUsersNew) {
        this.allowSelectUsers = allowSelectUsersNew;
    }

    /**
     * @return the pageNumber
     */
    public int getPageNumber() {
        return pageNumber + 1;
    }

    /**
     * @param pageNumberNew pageNumber to set
     */
    public void setPageNumber(int pageNumberNew) {
        if ((pageNumberNew - 1) > -1) {
            this.pageNumber = pageNumberNew - 1;
        } else {
            this.pageNumber = 0;
        }
    }

    /**
     * @return the filterPersonSsn
     */
    public String getFilterPersonSsn() {
        return filterPersonSsn;
    }

    /**
     * @return the itemCount
     */
    public long getItemCount() {
        return itemCount;
    }

    /**
     * @return the pageSize
     */
    public int getPageSize() {
        return pageSize;
    }

    /**
     * @return the filterTimeStart
     */
    public String getFilterTimeStart() {
        return filterTimeStart;
    }

    /**
     * @param filterTimeStartNew the filterTimeStart to set
     */
    public void setFilterTimeStart(String filterTimeStartNew) {
        this.filterTimeStart = filterTimeStartNew;
    }

    /**
     * @param filterPersonSsnNew the filterPersonSsn to set
     */
    public void setFilterPersonSsn(String filterPersonSsnNew) {
        this.filterPersonSsn = filterPersonSsnNew;
    }

    /**
     * @return the filterTimeEnd
     */
    public String getFilterTimeEnd() {
        return filterTimeEnd;
    }

    /**
     * @param filterTimeEndNew the filterTimeEnd to set
     */
    public void setFilterTimeEnd(String filterTimeEndNew) {
        this.filterTimeEnd = filterTimeEndNew;
    }

    /**
     * @return the successful
     */
    public boolean isSuccessful() {
        return successful;
    }

    /**
     * @param successfulNew the successful to set
     */
    public void setSuccessful(boolean successfulNew) {
        this.successful = successfulNew;
    }

    /**
     * If the value set is not null, then search button must have been pressed.
     * @param btnSearchNew the btnSearch value to set, null if DB query needn't be performed,
     *  any other value to execute DB query in filter() method.
     */
    public void setBtnSearch(String btnSearchNew) {
        this.btnSearch = btnSearchNew;
    }

    /**
     * @return not null, if search button was pressed, not null otherwise
     */
    public String getBtnSearch() {
        return btnSearch;
    }

    /**
     * If the value is not null, export-to-CSV button must have been pressed
     * @param btnExportCsvNew CSV-export button input value, null if another button was pressed
     */
    public void setBtnExportCsv(String btnExportCsvNew) {
        this.btnExportCsv = btnExportCsvNew;
    }

    /**
     * @return not null, if export-to-CSV button was pressed, not null otherwise
     */
    public String getBtnExportCsv() {
        return btnExportCsv;
    }

    /**
     * @return true if any of the form search buttons was pressed, false otherwise
     */
    protected boolean isButtonPressed() {
        return btnSearch != null || btnExportCsv != null;
    }

    /**
     * @return true in case CSV-export is performed, false otherwise
     */
    protected boolean isCsvExport() {
        return btnExportCsv != null;
    }
    
    /**
     * @return input stream to generated CSV file
     */
    public InputStream getCsvStream() {
        return csvStream;
    }

    /**
     * @return the exported CSV file name for struts.xml
     */
    public String getCsvFileName() {
        return csvFileName;
    }

    /**
     * @return queryName selected on filter form
     */
    public String getFilterQueryName() {
        return filterQueryName;
    }

    /**
     * @param filterQueryName filterQueryName to set
     */
    public void setFilterQueryName(String filterQueryName) {
        this.filterQueryName = filterQueryName;
    }

    /**
     * @return unitCode selected on filter form
     */
    public String getFilterUnitCode() {
        return filterUnitCode;
    }

    /**
     * @param filterUnitCode filterUnitCodeto set
     */
    public void setFilterUnitCode(String filterUnitCode) {
        this.filterUnitCode = filterUnitCode;
    }

}
