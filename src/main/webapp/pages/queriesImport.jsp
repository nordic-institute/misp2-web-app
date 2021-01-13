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

<link rel="stylesheet" type="text/css" href="resources/EE/css/categorized-table.css" />
<script type="text/javascript" src="resources/jscript/categorized-table.js"></script>
<script type="text/javascript" src="resources/jscript/queries-import_export.js"></script>

<div class="contentbox">
    <s:if test="%{activeProducersXforms.size>0 || complexProducersXforms.size>0}">
	    <table class="list categorized">
	    	<tr>
	    		<th><s:text name="label.description"/></th>
	    		<th><s:text name="label.name"/></th>
	    		<th><s:text name="label.database.exists"/></th>
	    		<th><s:text name="label.chosen"/></th>
	    	</tr>
	    	<tr>
	 	    	<td colspan="4">
	    			<h3><s:text name="label.activeProducers"/>: </h3>
	    		</td>
	    	</tr>
	    	<s:iterator value="activeProducersXforms" var="activeProducerXform">
	    		<tr>
	    			<td class="header" colspan="2" id="activeProducerId_${activeProducerXform.key.id}">
	    				<s:property value="#activeProducerXform.key.getActiveName(locale.language).description"/>
	    				<s:if test="%{#activeProducerXform.key.subsystemCode != null}">
							<i>(${activeProducerXform.key.subsystemCode})</i>
						</s:if>
						<s:else>
							<i>(${activeProducerXform.key.shortName})</i>
						</s:else>
	    			</td>
	    			<td>
	    				<s:if test="#activeProducerXform.key.id > 0">
	    					<s:text name="label.yes"/>
	    					<s:set var="partially" value="false"/>
	    					<s:iterator value="#activeProducerXform.value" var="xForms">
	    						<s:if test="#xForms.id < 0">
	    							<s:set var="partially" value="true"/>
	    						</s:if>
	    					</s:iterator>
							<s:if test="#partially == true ">
								(<s:text name="label.partially"/>)
							</s:if>
	    				</s:if>
	    				<s:else>
	    					<s:text name="label.no"/>
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
	    					${xForms.query.getFullIdentifierByPortal(portal)}
	    				</td>
		    			<td>
		    				<s:if test="#xForms.id > 0"><s:text name="label.yes"/></s:if>
		    				<s:else><s:text name="label.no"/></s:else>
		    			</td>
		    			<td>
		    				<input type="checkbox" class="activeProducer activeProducerCheckboxId_${activeProducerXform.key.id}" value="${xForms.id}">
		    			</td>
	    			</tr>
	    		</s:iterator>
	    	</s:iterator>
	    	<tr>
	    		<td colspan="4">
	    			<h3><s:text name="label.complexProducers"/>: </h3>
	    		</td>
	    	</tr>
	    	<s:iterator value="complexProducersXforms" var="complexProducerXform">
	    		<tr>
	    			<td class="header" colspan="2" id="complexProducerId_${complexProducerXform.key.id}">
	    				<s:property value="#complexProducerXform.key.getActiveName(locale.language).description"/> (${complexProducerXform.key.shortName})
	    			</td>
	    			<td>
	    				<s:if test="#complexProducerXform.key.id > 0">
	    					<s:text name="label.yes"/>
	    					<s:set var="partially" value="false"/>
	    					<s:iterator value="#complexProducerXform.value" var="xForms">
	    						<s:if test="#xForms.id < 0">
	    							<s:set var="partially" value="true"/>
	    						</s:if>
	    					</s:iterator>
							<s:if test="#partially == true ">
								(<s:text name="label.partially"/>)
							</s:if>
	    				</s:if>
	    				<s:else>
	    					<s:text name="label.no"/>
	    				</s:else>
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
	    					${complexProducerXform.key.shortName}.${xForms.query.name}
	    				</td>
		    			<td>
		    				<s:if test="#xForms.id > 0"><s:text name="label.yes"/></s:if>
		    				<s:else><s:text name="label.no"/></s:else>
		    			</td>
		    			<td>
		    				<input type="checkbox" class="complexProducer complexProducerCheckboxId_${complexProducerXform.key.id}" value="${xForms.id}">
		    			</td>
	    			</tr>
	    		</s:iterator>
	    	</s:iterator>
	   	</table>
		<form name="queriesImport" action="queriesImport.action?protocol=${protocol}" method="POST">
			<input type="hidden" name="uuid" value="<s:property value="%{#attr['uuid']}"/>" />
			<input type="hidden" name="data" value="" />
			<input type="hidden" name="confirmMessage" value="<s:text name="producer.queries.import.confirmMessage"/>" />
			<input type="submit" name="queriesImport" value="<s:text name="producer.queries.import.label.button"/>" class="button regular_btn" />
		</form>
		<br/><br/>
	</s:if>
	<form name="queriesImportSendFile" action="queriesImport.action?protocol=${protocol}" method="POST" enctype="multipart/form-data">
		<input type="file" name="importFile" /> <br/>
		<input type="submit" name="queriesImportSendFile" value="<s:text name="producer.queries.import.label.button.zip"/>" class="button regular_btn" />
	</form>
</div>