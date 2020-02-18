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

package ee.aktors.misp2.servlet.mediator;

import ee.aktors.misp2.service.QueryLogService;

/**
 * Logger properties container for mediator servlet (to work around RIA checkstyle limitation)
 * @author sander.kallo
 *
 */
public class QueryLogProperties {
    private String mainServiceHumanReadableName;
    private String mainServiceFullIdentifier;
    private QueryLogService queryLogService;
    
    /**
     * Initialize data
     * @param mainServiceHumanReadableName human readable name of service
     * @param mainServiceFullIdentifier full identifier of service
     * @param queryLogService query log service
     */
    public QueryLogProperties(String mainServiceHumanReadableName, String mainServiceFullIdentifier,
            QueryLogService queryLogService) {
        super();
        this.mainServiceHumanReadableName = mainServiceHumanReadableName;
        this.mainServiceFullIdentifier = mainServiceFullIdentifier;
        this.queryLogService = queryLogService;
    }

    /**
     * @return query human readable name
     */
    public String getMainServiceHumanReadableName() {
        return mainServiceHumanReadableName;
    }

    /**
     * @return query identifier
     */
    public String getMainServiceFullIdentifier() {
        return mainServiceFullIdentifier;
    }

    /**
     * @return query log service
     */
    public QueryLogService getQueryLogService() {
        return queryLogService;
    }
}
