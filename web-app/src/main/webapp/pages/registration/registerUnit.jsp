<%@page pageEncoding="UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags"%>


<%--
  ~ The MIT License
  ~ Copyright (c) 2020- Nordic Institute for Interoperability Solutions (NIIS)
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

<s:if test="%{allowedOrgList.size == 0 && unknownOrgList.size == 0}">
    <div class="contentbox">
        <h3><s:text name="units.none_registered"/></h3>
    </div>
</s:if>
<s:else>
    <s:if test="allowedOrgList!=null && allowedOrgList.size > 0">
        <div class="contentbox">
            <h3 class="toggle">
                <s:a href="#">
                    <s:text name="units.representative_rights"/>
                </s:a>
            </h3>
            <div class="togglewrap">
                <ul>
                    <s:iterator value="allowedOrgList" status="rowstatus">
                        <li>
                            <s:url var="registerUnit_link" action="registerUnit" >
                                <s:param name="orgCode" value="code" />
                            </s:url>

                            <s:a href="%{registerUnit_link}" data-confirmable-post-link=""><s:property value="getFullName(locale.language)" /></s:a>
                        </li>
                    </s:iterator>
                </ul>
            </div>
        </div>
    </s:if>

    <s:if test="unknownOrgList!=null && unknownOrgList.size > 0">
        <div class="contentbox">
            <h3 class="toggle">
                <s:a href="#">
                    <s:text name="units.representative_unknown"/>
                </s:a>
            </h3>
            <div class="togglewrap">
                <ul>
                    <s:iterator value="unknownOrgList" status="rowstat">
                        <li>
                            <s:url var="registerUnit_link" action="registerUnknownUnit">
                                <s:param name="orgCode" value="code" />
                            </s:url>
                            <s:a href="%{registerUnit_link}" data-confirmable-post-link=""><s:property value="getFullName(locale.language)" /></s:a>
                        </li>
                    </s:iterator>
                </ul>
            </div>
        </div>
    </s:if>
</s:else>
