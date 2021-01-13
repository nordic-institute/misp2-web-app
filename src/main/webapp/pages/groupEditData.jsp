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

<s:url action="groupDelete" var="delUrl" escapeAmp="false">
    <s:param name="groupId" value="%{group.id}"/>
</s:url>

<script type="text/javascript">
    $(document).ready(function( ){
        $("#btnDel").click(function() {
			var del = true;
			var text = "\n";
			
			if (!<s:property value="group.groupItemList.isEmpty()"/>) {
				text += '\n* <s:text name="groups.edit_data.has_rights"/>';
				del = false;
			}
			if (!<s:property value="group.groupPersonList.isEmpty()"/>) {
				text += '\n* <s:text name="groups.edit_data.has_members"/>';
				del = false;
			} 
			if (del == false) {
				del = confirm("<s:text name='text.confirm.delete'/>" + text);
			}
			
            if (del == false) {
                return false;
            }
        });
    })
</script>

<div class="contentbox">
<s:url var="listGroups" action="groupManage"/>
<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toGroups')}"  href="%{listGroups}"><s:text name="help.back.label"/></s:a>

	<h3><s:text name="groups.edit_data.header" escapeHtml="true"/></h3>
    <s:form action="groupSaveData" theme="simple" method="post">
        <s:hidden name="group.id" value="%{group.id}" />
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="groups.edit_data.name" />
                    <s:textfield required="true" name="group.name" />
                    <s:fielderror fieldName="group.name" />
                </li>
            </ul>
        </fieldset>
        <s:submit name="btnSubmit" key="label.button.save" method="groupSaveData" cssClass="button regular_btn"/>
        <s:if test="%{group.id}">
            <s:a id="btnDel" name="btnDelete" href="%{delUrl}" data-confirmable-post-link="" cssClass="button delete_btn">
                <s:text name="label.button.delete"/>
            </s:a>
        </s:if>
    </s:form>
</div>
