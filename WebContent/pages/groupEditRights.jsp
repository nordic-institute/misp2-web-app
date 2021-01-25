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

<link rel="stylesheet" type="text/css" href="resources/EE/css/categorized-table.css" />
<script type="text/javascript" src="resources/jscript/categorized-table.js"></script>
<style>.contentbox form li.sub-query-name{padding-left: 16px;}</style>
<script type="text/javascript">
	$(document).ready(function(){
	    $('[id^="checks"]').click(function() {
	    	checkUncheckAll(this.id.substring("checks".length));
	    });
	    
	    $('[id^="group_check"]').click(function() {
	    	checkUncheckAll(this.id.substring("group_check".length));
	    });
	});
</script>

<div class="contentbox">
<s:url var="listGroups" action="groupManage"/>
<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toGroups')}"  href="%{listGroups}"><s:text name="help.back.label"/></s:a>
	<h3><s:text name="groups.edit_members.filter.condition"/></h3>
	<s:form id="groupEditRights" action="groupEditRights" theme="simple" method="get">
		<s:hidden name="groupId" />
		<s:hidden name="filter" value="true"/>
		<fieldset>
			<ul class="form">
				<li>
					<s:label key="groups.edit_members.label.producer"/>
                    <s:fielderror fieldName="filterProducer"/>
                    <s:textfield name="filterProducer"/>
				</li>
				<li>
					<s:label key="groups.edit_members.label.short_name"/>
                    <s:fielderror fieldName="filterName"/>
                    <s:textfield name="filterName"/>
				</li>
				<li>
					<s:label key="groups.edit_members.label.description"/>
                    <s:fielderror fieldName="filterDescription"/>
                    <s:textfield name="filterDescription"/>
				</li>
				<li>
					<s:label key="groups.edit_rights.is_allowed"/>
                    <s:fielderror fieldName="filterAllowed"/>
                    <s:select name="filterAllowed" list="#{'0':getText('check.all'),'1':getText('label.button.yes'),'2':getText('label.button.no')}" cssClass="styled"/>
				</li>
				<li>
					<s:label key="groups.edit_rights.is_hidden"/>
                    <s:fielderror fieldName="filterHidden"/>
                    <s:select name="filterHidden" list="#{'0':getText('check.all'),'1':getText('label.button.yes'),'2':getText('label.button.no')}" cssClass="styled"/>
				</li>
			</ul>
		</fieldset>
		<s:submit name="btnSearch" key="label.button.search" cssClass="button regular_btn"/>
	</s:form>
	<hr />
	<h3><s:text name="groups.edit_rights.header" escapeHtml="true"/></h3>
	<s:if test="allowedQueries.size > 0">
	    <s:form id="form_queries" action="groupSaveRights" theme="simple" method="post">
	    	<s:if test="allowedQueries.size > 10">
	    		<s:submit name="btnSubmit" key="label.button.save" cssClass="button regular_btn" cssStyle="margin-top: 0px !important; margin-bottom: 5px;"/>
	    	</s:if>
	        <s:hidden name="group.id" value="%{group.id}" />
	        <table class="list selection categorized">
	            <tr>
	                <th>
	                    <s:text name="groups.edit_rights.is_allowed" />
	                </th>
	                <th>
	                    <s:text name="groups.edit_rights.is_hidden" />
	                </th>
	                <th>
	                    <s:text name="groups.edit_rights.query_description" />
	                </th>
	                <th>
	                    <s:text name="groups.edit_rights.query_short_name" />
	                </th>
	            </tr>
                <s:set var="groupCounter" value="1" />
                
                <s:iterator value="allowedProducersWithQueries" var="producerWithQueries">
                    <s:iterator value="producerWithQueries" var="producer">
                        <s:if test="%{#producer.value != null}">
	                        <tr>
	                            <td class="header" colspan="4" id="producerId_<s:property value="#producer.key.id"/>">
		                            <a>
		                                <s:if test="#producer.key.getActiveName(locale.language).description != ''">
		                                   <s:property value="%{#producer.key.getActiveName(locale.language).description}"/>
		                                </s:if>
		                                <s:else>
		                                   -
		                                </s:else>
		                                <s:if test="%{#producer.key.portal.v6 && #producer.key.subsystemCode != null}">
										 	(<i><s:property value="#producer.key.subsystemCode"/></i>)
										</s:if>
		                                <s:if test="%{#producer.key.protocol == @ee.aktors.misp2.model.Producer$ProtocolType@REST}">
										 	<sub><s:text name="label.rest"/></sub>
										</s:if>
		                                <s:elseif test="%{#producer.key.protocol == @ee.aktors.misp2.model.Producer$ProtocolType@SOAP}">
										 	<sub><s:text name="label.soap"/></sub>
										</s:elseif>
		                            </a>
	                            </td>
	                        </tr>
	                                                    
                            <s:iterator value="%{#producer.value}">                 
                                <tr class="producerId_<s:property value="#producer.key.id"/>">
                                    <s:hidden name="allowedQueryIdList" value="%{id}"/>
	                                <td class="modify center_middle">
	                                    <s:checkbox id="%{id}_%{#groupCounter}_allowed" name="groupAllowedQueryIdList" value="groupAllowedQueryIdList.contains(id.toString())" 
	                                                                        fieldValue="%{id}" cssClass="styled"/>
	                                </td>
	                                <td class="modify center_middle">
	                                    <s:checkbox id="%{id}_%{#groupCounter}_hidden" name="groupAllowedQueryIdList" value="groupAllowedQueryIdList.contains(id.toString()+'_hidden')" 
	                                                                        fieldValue="%{id}_hidden" cssClass="styled"/>
	                                </td>
                                    <td class="inactive">
                                        <s:iterator value="%{queryNameList}">
                                            <s:if test="%{locale.language.equals(lang)}">
                                                <s:property value="%{description}"/>
                                            </s:if>
                                        </s:iterator>
                                    </td>
                                    <td class="inactive">
                                        <s:property value="%{fullIdentifier}"/>
                                    </td>
                                </tr>
                                <s:set var="subQueryNameList" value="%{@ee.aktors.misp2.util.ComplexQueryAnalyzer@subQueryNamesToList(subQueryNames)}" />
                         		<s:if test="%{#subQueryNameList != null && #subQueryNameList.size() > 0}">
									<tr class="producerId_<s:property value="#producer.key.id"/>">
										<td class="inactive" colspan="4">
											<span style="font-weight:bold;"><s:text name="groups.edit_rights.subQueries" /></span> :
											<s:if test="#producer.key.portal.v6">
												<ul>
			                                        <s:iterator value="%{#subQueryNameList}" var="subQueryName">
			                                        	<li class="sub-query-name">
			                                               <s:property value="%{subQueryName}"/>
			                                            </li>
			                                        </s:iterator>
												</ul>
											</s:if>
											<s:else>
												<s:property value="%{subQueryNames}"/>
											</s:else>
										</td>
									</tr>
								</s:if>
                            </s:iterator>
	                        <tr class="producerId_<s:property value="#producer.key.id"/>">
	                                <td class="modify center_middle" id="checktd_allowed">
	                                    <span id="group_check_<s:property value="%{#groupCounter}"/>_allowed"><input type="checkbox"  value="checkall_<s:property value="%{#groupCounter}"/>_allowed" name="checkall_<s:property value="%{#groupCounter}"/>_allowed" id="checkall_<s:property value="%{#groupCounter}"/>_allowed" class="styled"/></span>
	                                </td>
	                                <td class="modify center_middle" id="checktd_hidden">
	                                    <span id="group_check_<s:property value="%{#groupCounter}"/>_hidden"><input type="checkbox"  value="checkall_<s:property value="%{#groupCounter}"/>_hidden" name="checkall_<s:property value="%{#groupCounter}"/>_hidden" id="checkall_<s:property value="%{#groupCounter}"/>_hidden" class="styled"/></span>
	                                </td>
	                                <td class="inactive" colspan="2" style="text-align:left; padding-left:5px;">
	                                    <strong><s:text name="check.group_all" /></strong>
	                                </td>
	                        </tr>	
	                                                
	                        <s:set var="groupCounter" value="%{#groupCounter + 1}" />
	                        
                        </s:if>
                    </s:iterator>
                </s:iterator>
				<tr>
					<td class="modify center_middle" id="checktd_allowed">
                        <span id="checks_allowed"><input type="checkbox"  value="checkall_allowed" name="checkall_allowed" id="checkall_allowed" class="styled"/></span>
                    </td>
					<td class="modify center_middle" id="checktd_hidden">
                        <span id="checks_hidden"><input type="checkbox"  value="checkall_hidden" name="checkall_hidden" id="checkall_hidden" class="styled"/></span>
                    </td>
					<td class="inactive" colspan="2" style="text-align:left; padding-left:5px;">
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
