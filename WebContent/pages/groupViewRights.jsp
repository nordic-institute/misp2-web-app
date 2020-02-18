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

<div class="contentbox">
<s:url var="listGroups" action="groupManage"/>
<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toGroups')}"  href="%{listGroups}"><s:text name="help.back.label"/></s:a>

	<h3><s:text name="groups.edit_rights.header" escapeHtml="true"/></h3>
	<s:if test="allowedQueries.size > 0">
	    <table class="list">
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
	                             </a>
                             </td>
                         </tr>
                         <s:iterator value="%{#producer.value}">                 
                             <tr class="producerId_<s:property value="#producer.key.id"/>">
                                 <td class="center_middle">
                                     <s:if test="groupAllowedQueryIdList.contains(id.toString())">
                                         <img src="resources/<s:property value="subPortal"/>/images/accept.png" alt="<s:text name="label.button.query_rights"/>" width="15" height="15"/>
                                     </s:if>
                                 </td>
                                 <td class="center_middle">
                                     <s:if test="groupAllowedQueryIdList.contains(id.toString()+'_hidden')">
                                         <img src="resources/<s:property value="subPortal"/>/images/accept.png" alt="<s:text name="label.button.query_rights"/>" width="15" height="15"/>
                                     </s:if>
                                 </td>
                                 <td class="inactive">
                                     <s:iterator value="%{queryNameList}">
                                         <s:if test="%{locale.language.equals(lang)}">
                                             <s:property value="%{description}"/>
                                         </s:if>
                                     </s:iterator>
                                 </td>
                                 <td class="inactive">
                                     <s:property value="%{producer.shortName}"/>.<s:property value="%{name}"/>
                                 </td>
                             </tr>
                         </s:iterator>
                     </s:if>
                 </s:iterator>
             </s:iterator>
	    </table>
	</s:if>
	<s:else>
        <h5><s:text name="text.search.no_results"/></h5>
    </s:else>
</div>


