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

package ee.aktors.misp2.beans;

import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.QueryLog;
import java.io.Serializable;

/**
 *
 * @author arnis.rips
 */
public class QueryLogItem implements Serializable {

    private static final long serialVersionUID = 1L;
    private QueryLog queryLog;
    private Person person;
    private Integer queryId;
    /**
     * @return the queryLog
     */
    public QueryLog getQueryLog() {
        return queryLog;
    }
    /**
     * @param queryLogNew the queryLog to set
     */
    public void setQueryLog(QueryLog queryLogNew) {
        this.queryLog = queryLogNew;
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
     * @return the queryId
     */
    public Integer getQueryId() {
        return queryId;
    }
    /**
     * @param queryIdNew the queryId to set
     */
    public void setQueryId(Integer queryIdNew) {
        this.queryId = queryIdNew;
    }

}
