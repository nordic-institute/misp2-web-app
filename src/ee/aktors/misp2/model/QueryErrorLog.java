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

package ee.aktors.misp2.model;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import ee.aktors.misp2.util.Const;

/**
 * query_error_log entity
 */
@Entity
@Table(name = "query_error_log")
public class QueryErrorLog extends GeneralBean {

    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "query_error_log_id_seq")
    @SequenceGenerator(name = "query_error_log_id_seq", sequenceName = "query_error_log_id_seq", allocationSize = 1)
    @Basic(optional = false)
    @Column(name = "id", nullable = false, insertable = false)
    private Integer id;
    @Column(name = "code", length = Const.LENGTH_64)
    private String code;
    @Column(name = "description", length = Const.LENGTH_1042)
    private String description;
    @Column(name = "detail", length = Const.LENGTH_1042)
    private String detail;
    @JoinColumn(name = "query_log_id", referencedColumnName = "id")
    @OneToOne(fetch = FetchType.LAZY)
    private QueryLog queryLog;
   
    /**
     * @return the id
     */
    public Integer getId() {
        return id;
    }
    /**
     * @param idNew the id to set
     */
    public void setId(Integer idNew) {
        this.id = idNew;
    }
    /**
     * @return the code
     */
    public String getCode() {
        return code;
    }
    /**
     * @param codeNew the code to set
     */
    public void setCode(String codeNew) {
        this.code = codeNew;
    }
    /**
     * @return the description
     */
    public String getDescription() {
        return description;
    }
    /**
     * @param descriptionNew the description to set
     */
    public void setDescription(String descriptionNew) {
        this.description = descriptionNew;
    }
    /**
     * @return the detail
     */
    public String getDetail() {
        return detail;
    }
    /**
     * @param detailNew the detail to set
     */
    public void setDetail(String detailNew) {
        this.detail = detailNew;
    }
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
}
