<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page  pageEncoding="UTF-8" %>

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

<script type="text/javascript">
	$(document).ready(function(){
	    $("#checks").click(function() {
	    	checkUncheckAll("_isMember")
	    })
	});
</script>

<div class="contentbox">
<s:url var="listGroups" action="groupManage"/>
<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toGroups')}"  href="%{listGroups}"><s:text name="help.back.label"/></s:a>

	<h3><s:text name="groups.edit_members.header" escapeHtml="true"/></h3>
	<s:if test="persons.size > 0">
	    <s:form id="form_queries" action="groupSaveMembers" theme="simple" method="post">
	    	<s:if test="persons.size > 10"><s:submit name="btnSubmit" key="label.button.save" cssClass="button regular_btn" cssStyle="margin-top: 0px !important; margin-bottom: 5px;"/></s:if>
	        <s:hidden name="group.id" value="%{group.id}" />
	        <table class="list selection">
	            <tr>
	                <th>
	                    <s:text name="groups.edit_members.is_member" />
	                </th>
	                <th>
	                    <s:text name="groups.edit_members.users" />
	                </th>
	            </tr>
	            <s:iterator value="persons">
	                <tr>
	                    <td class="modify center_middle">
	                        <s:checkbox id="%{id}_isMember" name="groupPersonIdList" value="groupPersonIdList.contains(id.toString())" 
	                                    fieldValue="%{id}"  cssClass="styled"/>
	                    </td>
                        <s:if test="#session.SESSION_PORTAL.mispType!=3">
                        	<td>
	                            <s:url var="groupEditUser" action="showUser">
	                                <s:param name="userId" value="id"/>
	                            </s:url>
	                            <s:a href="%{groupEditUser}">
	                                <s:property value="fullNameSsnParenthesis"/>
	                            </s:a>
							</td>
                        </s:if>
                        <s:else>
                        	<td class="inactive">
	                            <span>
	                                <s:property value="fullNameSsnParenthesis"/>
	                            </span>
							</td>
                        </s:else>
	                </tr>
	            </s:iterator>
				<tr>
					<td class="modify center_middle" id="checktd">
                        <span id="checks"><input type="checkbox"  value="checkall_isMember" name="checkall_isMember" id="checkall_isMember"  class="styled"/></span>
                    </td>
					<td class="inactive" style="text-align:left; padding-left:5px;">
                        <strong><s:text name="check.all" /></strong>
                    </td>
				</tr>
	        </table>
	        <s:submit name="btnSubmit" key="label.button.save" cssClass="button regular_btn"/>
	    </s:form>
	</s:if>
	<s:else>
        <h5><s:text name="text.search.no_results"/></h5>
    </s:else>
</div>
