<%@page pageEncoding="UTF-8" %>
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

<s:if test="!#session.SESSION_PORTAL.useTopics">
    <div class="contentbox warning">
        <h3><s:text name="topic.warning.not_in_use"/></h3>
    </div>
</s:if>
<div class="contentbox">
    <h3><s:text name="topics.filter.condition"/></h3>

    <s:form id="topicsFilter" action="topicsFilter" method="get" theme="simple">
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="topics.filter.label.name"/>
                    <s:fielderror fieldName="filterName"/>
                    <s:textfield name="filterName"/>
                </li>
                <li>
                    <s:submit name="submit" key="label.button.search" cssClass="button regular_btn" />
                </li>
            </ul>
        </fieldset>
    </s:form>
    <hr />
    <h3><s:text name="topics.filter.found"/>:</h3>
    <s:if  test="searchResults!=null">
        <s:if test="searchResults.size > 0">
            <table class="list selection">
                <s:iterator value="searchResults" var="res">
                    <tr>
                        <td>
                            <s:url var="show_topic_link" action="showTopic">
                                <s:param name="topicId" value="#res.topic.id"/>
                            </s:url>
                            <s:a href="%{show_topic_link}"><s:property value="%{#res.description}"/></s:a>
                        </td>
                    </tr>
                </s:iterator>
            </table>

        </s:if>
        <s:else>
            <h5>
                <s:text name="text.search.no_results"/>
            </h5>
        </s:else>

    </s:if>
    <s:a id="btnNew" cssClass="button regular_btn" action="addTopic"><s:text name="label.button.add_new_topic"/></s:a>
</div>