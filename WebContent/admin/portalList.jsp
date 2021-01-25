<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="s" uri="/struts-tags" %>

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

<div class="contentbox">
    <h3><s:text name="label.portals"/></h3>
    <s:if test="portals != null && portals.size > 0">
        <table class="list selection">
        	<tr>
            	<th><s:text name="t3sec.filter.thead.portalName"/></th>
            	<th><s:text name="portal.label.type"/></th>
            	<th><s:text name="t3sec.filter.label.orgCode"/></th>
            </tr>
            <s:iterator value="portals">
                <tr>
                    <td>
                        <s:url var="portalEdit" action="showPortal">
                            <s:param name="portalId" value="%{id}" />
                        </s:url>
						<s:set var="portalName" value="%{getActiveName(locale.language)}"/>
						<s:if test="#portalName == null">
							<s:set var="portalName" value="%{getShortName()}"/>
						</s:if>
                        <s:a href="%{portalEdit}">
	                       	<s:property value="%{#portalName}"/>
                        </s:a>
                    </td>
                    <td>
                    	<s:text name="portal.label.types.%{mispType}" />
                    </td>
                    <td>
                    	<s:property value="orgId.code"/>
                    </td>
                </tr>
            </s:iterator>
        </table>
    </s:if>
    <s:else>
        <h5><s:text name="message.no_portal"/></h5>
    </s:else>
    <s:a action="showPortal" cssClass="button regular_btn"><s:text name="label.button.add_new" /></s:a>
</div>