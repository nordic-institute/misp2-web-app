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

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.service.QueryLogService;
import ee.aktors.misp2.service.QueryLogService.QueryLogInput;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.FileUtil;

/**
 *
 * @author arnis.rips
 */
public class ManagerQueryLogAction extends QueryLogAction {

    private static final long serialVersionUID = 1L;
    private static final Logger LOG = LogManager.getLogger(ManagerQueryLogAction.class);

    /**
     * @param serviceQuery serviceQuery to inject
     * @param serviceUser serviceUser to inject
     */
    public ManagerQueryLogAction(QueryLogService serviceQuery, UserService serviceUser) {
        super(serviceQuery, serviceUser);
    }

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String filter() throws IOException {
        // no buttons pressed yet, return immediately
        // (so that query would not run on user opening the search page)
        if (!isButtonPressed()) {
            itemCount = 0;
            return SUCCESS;
        }
        Org activeOrg = (Org) session.get(Const.SESSION_ACTIVE_ORG);

        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

        int searchPageNumber, searchPageSize;
        if (isCsvExport()) { // CSV export is performed
            // for CSV, ignore pagination by setting service method pagination arguments to -1
            searchPageNumber = -1;
            searchPageSize = -1;
        } else { // search is performed, not CSV export
            // use the provided pagination parameters
            searchPageNumber = pageNumber;
            searchPageSize = pageSize;
        }


        dateTimeStart = parseTimeString(filterDateStart, filterTimeStart, timeFormat);
        dateTimeEnd = parseTimeString(filterDateEnd, filterTimeEnd, timeFormat);

        if (LOG.isDebugEnabled() && dateTimeStart != null && dateTimeEnd != null) {
            SimpleDateFormat df = new SimpleDateFormat("yyyy.MM.dd HH:mm");
            LOG.debug("Query log start time filter " + df.format(dateTimeStart)
                    + ", end time " + df.format(dateTimeEnd));
        }

        QueryLogInput input = new QueryLogInput();
        input.setPortal(portal);
        input.setActiveOrg(activeOrg);
        input.setPersonSsn(null);
        input.setQueryDescription(filterQueryDescription);
        input.setUnitCode(filterUnitCode);
        input.setQueryName(filterQueryName);
        input.setQueryId(filterQueryId);
        input.setStart(dateTimeStart);
        input.setEnd(dateTimeEnd);
        input.setSuccessful(successful);

        if (selectedUserId != null && selectedUserId != -1 || filterPersonSsn != null && !filterPersonSsn.isEmpty()) {
            Person p = serviceUser.findObject(Person.class, selectedUserId);
            ArrayList<String> filterSsn = new ArrayList<String>();
            if (p != null)
                filterSsn.add(p.getSsn());
            if (filterPersonSsn != null && !filterPersonSsn.isEmpty())
                filterSsn.add(filterPersonSsn);

            input.setPersonSsn(filterSsn);
            itemCount = serviceQuery.countPersonQueryLogs(input);
            if (isCsvExport() && !isCsvItemCountAllowed(itemCount)) {
                return ERROR;
            }
            searchResults = serviceQuery.findPersonQueryLogs(input, searchPageNumber, searchPageSize);
        } else {
            itemCount = serviceQuery.countAllUserQueryLogs(input);
            if (isCsvExport() && !isCsvItemCountAllowed(itemCount)) {
                return ERROR;
            }
            searchResults = serviceQuery.findAllUsersQueryLogs(input, searchPageNumber, searchPageSize);
        }

        if (isCsvExport()) { // CSV export is performed
            csvFileName = FileUtil.getExportFileName("query-log", portal, "csv");
            csvStream = createCsvStream(searchResults, QueryLogType.FULL);
            LOG.info("Generated " + csvFileName + " for download (for manager).");
            return "success_csv"; // return stream result (definded in struts.xml)
        } else { // return HTML web-page with search results rendered by JSP
            return SUCCESS;
        }
    }
}
