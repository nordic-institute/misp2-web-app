<%@page  pageEncoding="UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags"%>

<%--
  ~ The MIT License
  ~ Copyright (c) 2020 NIIS
  ~
  ~ Permission is hereby granted, free of charge, to any person obtaining a copy
  ~ of this software and associated documentation files (the "Software"), to deal
  ~ in the Software without restriction, including without limitation the rights
  ~ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  ~ copies of the Software, and to permit persons to whom the Software is
  ~ furnished to do so, subject to the following conditions:
  ~
  ~ The above copyright notice and this permission notice shall be included in
  ~ all copies or substantial portions of the Software.
  ~
  ~ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  ~ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  ~ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  ~ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  ~ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  ~ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  ~ THE SOFTWARE.
  ~
  --%>

<s:set var="lang" value="locale.language"/>
<div class="contentbox">
    <h3><s:text name="classifierquerys.list" escapeHtml="false"/></h3>
    <table class="list selection">
        <s:iterator value="queryList" var="query">
            <tr>
                <td>
                    <s:url var="url" action="listQueryClassifiers"><s:param name="queryId" value="id" /></s:url>
                    <s:a href="%{url}" ><s:property value="#query.fullIdentifier" /></s:a>
                </td>
                <s:set var="producerName" value="#query.producer.getActiveName(#lang).description"/>
                <s:if test="#producerName != null">
	                <td>
	                    <s:property value="#producerName" />
	                </td>
                </s:if>
                <s:set var="queryName" value="#query.getActiveName(#lang).description"/>
                <s:if test="#queryName != null">
	                <td>
	                    <s:property value="#queryName" />
	                </td>
                </s:if>
            </tr>
        </s:iterator>
    </table>

</div>
