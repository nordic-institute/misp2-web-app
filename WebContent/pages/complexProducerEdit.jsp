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

<s:url action="complexProducerDelete" var="delUrl" escapeAmp="false">
    <s:param name="id" value="%{complexProducer.id}"/>
    <s:param name="protocol" value="protocol"/>
</s:url>

<div class="contentbox">
<s:url var="listComplexProducers" action="listProducers">
    <s:param name="protocol" value="protocol"/>
</s:url>
<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toComplex')}"  href="%{listComplexProducers}"><s:text name="help.back.label"/></s:a>

	<h3><s:text name="complex.edit.header"/></h3>
    <s:form action="complexProducerSave?protocol=%{protocol}" theme="simple" method="post">
        <s:hidden name="complexProducer.id" value="%{complexProducer.id}" />
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="complex.edit.protocol" />
                    <s:property value="protocol"/>
                </li>
                <li>
                    <s:label key="complex.edit.name" />                    
                    <s:textfield required="true" name="complexProducer.shortName" placeholder="%{getText('placeholder.producer_name')}" disabled="complexProducer.shortName=='system'"/>
                    <s:fielderror fieldName="complexProducer.shortName" />
                </li>

				<s:iterator status="stat" value="(#attr['languages'].size()).{ #this }" >
	                <li>
                		<s:set var="language" value = "#attr['languages'].get(#stat.index)"/>
	                    <label><s:property value="getText('complex.edit.description')+' ('+#language.toUpperCase()+')'"/></label>
	                    <s:textfield required="true" name="cProducerDescriptions[%{#stat.index}].description" cssClass="long_url" placeholder="%{getText('placeholder.producer_description')}"/>
	                    <s:hidden name="cProducerDescriptions[%{#stat.index}].id"/>
						<s:fielderror>
						     <s:param><s:property value="'cProducerDescriptions['+#stat.index+'].description'"/></s:param>
						</s:fielderror>
	                </li>
				</s:iterator>
                
            </ul>
        </fieldset>
        <s:submit name="btnSubmit" key="label.button.save" method="complexProducerSave" cssClass="button regular_btn"/>
        <s:if test="%{complexProducer.id}">
            <s:a id="btnDel" name="btnDelete" href="%{delUrl}" data-confirmable-post-link="%{getText('text.confirm.delete')}" cssClass="button delete_btn">
            	<s:text name="label.button.delete"/>
            </s:a>
        </s:if>
    </s:form>
</div>
