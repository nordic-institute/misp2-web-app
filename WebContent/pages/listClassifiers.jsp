<%@page  pageEncoding="UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags"%>

<%--
  ~ The MIT License
  ~ Copyright (c) 2019 Estonian Information System Authority (RIA)
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

<div class="contentbox">
    <h3><s:text name="classifier.list"/></h3>
    <s:if test="systemClassifierList!=null && systemClassifierList.size>0">
        <h5><s:text name="classifier.type.system"/></h5>
        <table class="list selection">
            <s:iterator value="systemClassifierList" status="rowstatus">
                <s:url var="view" value="classifier"><s:param name="name" value="name" /></s:url>
                <tr>
                    <td>
                        <s:a href="%{view}" ><s:property value="name" /> </s:a>
                    </td>
                </tr>
            </s:iterator>
        </table>
    </s:if>
    <h5><s:text name="classifier.type.regular"/></h5>
    <s:if test="classifierList!=null && classifierList.size>0">
        <table class="list selection">
            <s:iterator value="classifierList" status="rowstatus">
                <s:url var="update" action="updateClassifier"><s:param name="classifierName" value="name" /></s:url>
                <s:url var="remove" action="removeClassifier"><s:param name="classifierId" value="id" /></s:url>
                <s:url var="view" value="classifier"><s:param name="name" value="name" /></s:url>
                <tr>
                    <td>
                        <s:a href="%{view}" ><s:property value="name" /> </s:a>
                    </td>
                    <td class="modify">
                        <s:a cssClass="small" href="%{update}" >
                            <img src="resources/<s:property value="subPortal"/>/images/reload.png" alt="<s:text name="label.button.reload"/>" width="20" height="20"/>
                        </s:a>
                    </td>
                    <td class="modify">
                        <s:a cssClass="small" href="%{remove}" data-confirmable-post-link="%{getText('text.confirm.delete')}">
                            <img src="resources/<s:property value="subPortal"/>/images/delete.png" alt="<s:text name="label.button.delete"/>" width="20" height="20"/>
                        </s:a>
                    </td>
                </tr>
            </s:iterator>
        </table>
    </s:if>
    <s:else>
        <h5><s:text name="text.search.no_results"/></h5>
    </s:else>
    <s:url action="listClassifierQuerys" var="add_new"/>
    <s:a cssClass="button regular_btn" href="%{add_new}">
        <s:text name="label.button.add_new_classifier" />
    </s:a>
</div>

