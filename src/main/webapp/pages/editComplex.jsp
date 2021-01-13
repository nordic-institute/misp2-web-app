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

<div class="contentbox">
<s:url var="listComplexQueries" action="listComplexQueries">
	<s:param name="id" value="id"/>
	<s:param name="protocol" value="protocol"/>
</s:url>

<s:url action="deleteComplex" var="delUrl" escapeAmp="false">
    <s:param name="queryId" value="%{queryId}"/>
	<s:param name="protocol" value="protocol"/>
</s:url>

<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toComplex')}"  href="%{listComplexQueries}"><s:text name="help.back.label"/></s:a>
<s:form method="post" action="saveComplexData?protocol=%{protocol}" theme="simple">
	<s:hidden name="queryId" value="%{query.id}" />
	<s:hidden name="id" value="%{id}" />
	<ul class="form">
		<li>
			<s:label key="label.change.name" />
			<s:textfield required="true" name="query.name" placeholder="%{getText('placeholder.query_name')}" />
			<s:fielderror fieldName="query.name" />
		</li>
		
		<s:iterator status="stat" value="(#attr['languages'].size()).{ #this }" >
			<li>
				<s:set var="language" value = "#attr['languages'].get(#stat.index)"/>
				<label><s:property value="getText('label.change.desc')+' ('+#language.toUpperCase()+')'"/></label>
				<s:textfield required="true" name="queryNames[%{#stat.index}].description" cssClass="long_url" placeholder="%{getText('placeholder.query_description')}"/>
				<s:hidden name="queryNames[%{#stat.index}].id"/>
				<s:fielderror>
					<s:param><s:property value="'queryNames['+#stat.index+'].description'"/></s:param>
				</s:fielderror>
			</li>
		</s:iterator>
		
		<li>
			
			<%--Variable is necessary, because label does not accept parameters.
			     The following fails <s:label key="label.change.url.%{protocol}" /> --%>
			<s:set var="urlLabel" value="getText('label.change.url.' + protocol)" />
			<s:label key="#urlLabel" />
			<s:textfield required="true" name="xforms.url" cssClass="long_url" value="%{xforms.url}" />
			<s:fielderror fieldName="xforms.url" />
		</li>
		<li>
           <s:submit cssClass="button regular_btn" name="btnSearch" key="label.button.save"/>
           	<s:if test="%{queryId}">
	            <s:a id="btnDel" name="btnDelete" href="%{delUrl}" data-confirmable-post-link="%{getText('text.confirm.delete')}" cssClass="button delete_btn">
	            	<s:text name="label.button.delete"/>
	            </s:a>
			</s:if>
       </li>			
	</ul>
	
</s:form>
</div>