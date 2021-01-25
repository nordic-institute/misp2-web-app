<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page  pageEncoding="UTF-8" %>

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
    <h3><s:text name="users.show.label.usergroups"/></h3>
    <s:if test="groups.size > 0">
        
        <table class="list selection">
            <s:iterator value="groups">
                <tr>
                    <s:if test="#session.SESSION_ACTIVE_ORG.id.equals(orgId.id)">
                    	<td>
							<s:url var="groupEditData" action="groupEditData">
								<s:param name="groupId" value="%{id}" />
							</s:url>
							<s:a href="%{groupEditData}"><s:property value="name"/></s:a>
						</td>
					</s:if>
					<s:else>
						<td class="inactive">
    						<span><s:property value="name"/></span>
    					</td>
					</s:else>
                    <td class="modify">
                        <s:url var="groupEditRights" action="groupEditRights">
                            <s:param name="groupId" value="%{id}" />
                        </s:url>
                        <s:a cssClass="small" href="%{groupEditRights}">
                            <img src="resources/<s:property value="subPortal"/>/images/group-rights.png" alt="<s:text name="label.button.query_rights"/>" width="20" height="20"/>
                        </s:a>
                    </td>
                    <s:if test="%{showEditMembersButton}">
                        <td class="modify">
                            <s:url var="groupEditMembers" action="groupEditMembers">
                                <s:param name="groupId" value="%{id}" />
                            </s:url>
                            <s:a cssClass="small" href="%{groupEditMembers}">
                                <img src="resources/<s:property value="subPortal"/>/images/users.png" alt="<s:text name="label.button.members"/>" width="20" height="20"/>
                            </s:a>
                        </td>
                    </s:if>
                </tr>
            </s:iterator>
        </table>
    </s:if>
    <s:else>
        <h5><s:text name="text.search.no_results"/></h5>
    </s:else>
    <s:form name="newGroup" theme="simple" method="post">
        <s:a action="groupEditData" cssClass="button regular_btn">
            <s:text name="label.button.add_new" />
        </s:a>
    </s:form>
</div>