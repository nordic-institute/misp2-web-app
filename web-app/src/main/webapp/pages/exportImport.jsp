<%@page  pageEncoding="UTF-8" %>
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

<script type="text/javascript" src="resources/jscript/exportImport.js"></script>

<div class="contentbox">
	<h3><s:text name="exportImport.title"/></h3>
	
	<!-- Action will be set to appropriate url in javascript after click on export or import button -->
	<form name="exportImportFile" action="exportImport.action" method="post" enctype="multipart/form-data">
		<fieldset>
			<ul class="form">
				<li>
					<label><s:text name="exportImport.includeSubOrgsAndGroups"/></label>
					<input type="checkbox" name="includeSubOrgsAndGroups" value="true" ${includeSubOrgsAndGroups ? 'checked':''}/>
				</li>
				   
				<li>
					<label><s:text name="exportImport.includeGroupPersons"/></label>
					<input type="checkbox" name="includeGroupPersons" value="true" ${includeGroupPersons ? 'checked':''}/>
				</li>
				   
				<li>
					<label><s:text name="exportImport.includeGroupQueries"/></label>
					<input type="checkbox" name="includeGroupQueries" value="true" ${includeGroupQueries ? 'checked':''}/>
				</li>
				   
				<li>
					<label><s:text name="exportImport.includeTopics"/></label>
					<input type="checkbox" name="includeTopics" value="true" ${includeTopics ? 'checked':''}/>
				</li>
				
				<li>
					<label><s:text name="exportImport.includeQueries"/></label>
					<input type="checkbox" name="includeQueries" value="true" ${includeQueries ? 'checked':''}/>
				</li>
			</ul>
		</fieldset>
	
		<input type="hidden" name="exportConfirmMessage" value="<s:text name="exportImport.export.confirmMessage"/>" />
		<button type="button" name="exportButton" class="button regular_btn"><s:text name="exportImport.export.label.button"/></button>
		<s:if test="universalPortal">
			<label><s:text name="exportImport.export.chooseSubOrg"/></label>
			<select name="chosenSubOrgId">
				<option value="0"><s:text name="label.all"/></option>
				<s:iterator value="subOrgs" var="subOrg">
					<option value="${subOrg.key.id}" ${chosenSubOrgId==subOrg.key.id ? 'selected':''}>${subOrg.value}</option>
				</s:iterator>
			</select>
		</s:if>
		<br/>
		
		<br/>
		
		<input type="hidden" name="importConfirmMessage" value="<s:text name="exportImport.import.confirmMessage"/>" />
		<input type="file" name="importFile"/>
		<button type="button" name="importButton" class="button regular_btn"><s:text name="exportImport.import.label.button"/></button>
	</form>
</div>