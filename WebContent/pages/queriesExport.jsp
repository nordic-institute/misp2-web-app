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

<link rel="stylesheet" type="text/css" href="resources/EE/css/categorized-table.css" />
<script type="text/javascript" src="resources/jscript/categorized-table.js"></script>
<script type="text/javascript" src="resources/jscript/queries-import_export.js"></script>

<div class="contentbox">
    <table class="list categorized">
    	<tr>
    		<th><s:text name="label.description"/></th>
    		<th><s:text name="label.name"/></th>
    		<th><s:text name="label.chosen"/></th>
    	</tr>
    	<tr>
 	    	<td colspan="3">
    			<h3><s:text name="label.activeProducers"/>: </h3>
    		</td>
    	</tr>
    	<s:iterator value="activeProducersXforms" var="activeProducerXform">
    		<tr>
    			<td class="header" colspan="2" id="activeProducerId_${activeProducerXform.key.id}">
    				<s:property value="#activeProducerXform.key.getActiveName(locale.language).description"/>
    				<s:if test="%{#activeProducerXform.key.portal.v6 && #activeProducerXform.key.subsystemCode != null}">
						<i>(<s:property value="#activeProducerXform.key.subsystemCode"/>)</i>
					</s:if>
					<s:else>
						<i>(<s:property value="#activeProducerXform.key.shortName"/>)</i>
					</s:else>
    			</td>
    			<td>
    				<input type="checkbox" class="header activeProducer" value="${activeProducerXform.key.id}" id="activeProducerCheckboxId_${activeProducerXform.key.id}">
    			</td>
    		</tr>
    		<s:iterator value="#activeProducerXform.value" var="xForms">
    			<tr class="activeProducerId_${activeProducerXform.key.id}">
    				<td>
    					<s:property value="#xForms.query.getActiveName(locale.language).description"/>
    				</td>
    				<td>
    					<s:property value="#xForms.query.getFullIdentifierByPortal(portal)"/>
    				</td>
	    			<td>
	    				<input type="checkbox" class="activeProducer activeProducerCheckboxId_${activeProducerXform.key.id}" value="${xForms.id}">
	    			</td>
    			</tr>
    		</s:iterator>
    	</s:iterator>
    	<tr>
    		<td colspan="3">
    			<h3><s:text name="label.complexProducers"/>: </h3>
    		</td>
    	</tr>
    	<s:iterator value="complexProducersXforms" var="complexProducerXform">
    		<tr>
    			<td class="header" colspan="2" id="complexProducerId_${complexProducerXform.key.id}">
    				<s:property value="#complexProducerXform.key.getActiveName(locale.language).description"/> (<s:property value="#complexProducerXform.key.shortName"/>)
    			</td>
    			<td>
    				<input type="checkbox" class="header complexProducer" value="${complexProducerXform.key.id}" id="complexProducerCheckboxId_${complexProducerXform.key.id}">
    			</td>
    		</tr>
    		<s:iterator value="#complexProducerXform.value" var="xForms">
    			<tr class="complexProducerId_${complexProducerXform.key.id}">
    				<td>
    					<s:property value="#xForms.query.getActiveName(locale.language).description"/>
    				</td>
    				<td>
    					<s:property value="#complexProducerXform.key.shortName"/>.<s:property value="#xForms.query.name"/>
    				</td>
	    			<td>
	    				<input type="checkbox" class="complexProducer complexProducerCheckboxId_${complexProducerXform.key.id}" value="${xForms.id}">
	    			</td>
    			</tr>
    		</s:iterator>
    	</s:iterator>
   	</table>
	<form name="queriesExport" action="queriesExportReceiveFile.action" method="POST">
		<input type="hidden" name="data" value="" />
		<input type="hidden" name="confirmMessage" value="<s:text name="producer.queries.export.confirmMessage"/>" />
		<input type="submit" name="queriesExport" value="<s:text name="producer.queries.export.label.button"/>" class="button regular_btn" />
	</form>
</div>