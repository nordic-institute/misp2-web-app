<%@page pageEncoding="UTF-8"%>
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

<div class="contentbox">
	<h3>
		<s:if test="next=='SS'">
			<s:text name="queries.missing.sec_server" />
		</s:if>
		<s:elseif test="next=='WSDL'">
			<s:text name="queries.missing.%{protocol}" />
		</s:elseif>
	</h3>
	<h3>
		<s:text name="queries.missing.remove" />
	</h3>

	<ul>
		<s:iterator value="missingQueries">
			<li>
				<s:if test="%{protocol == @ee.aktors.misp2.model.Producer$ProtocolType@REST}">
					<s:property value="openapiServiceCode" />:
				</s:if>
				<s:property value="name" />
			</li>
		</s:iterator>
	</ul>
	<s:url action="removeMissingQueries" var="removeQueriesYes" escapeAmp="false">
		<s:param name="id" value="%{producer.id}" />
		<s:param name="protocol" value="protocol"/>
	</s:url>
	<s:url action="listQueries" var="removeQueriesNo" escapeAmp="false">
		<s:param name="id" value="%{producer.id}" />
		<s:param name="protocol" value="protocol"/>
	</s:url>

	<s:a id="btnRemoveQueriesYes" name="btnRemoveQueriesYes"
		href="%{removeQueriesYes}" data-confirmable-post-link="" cssClass="button delete_btn no_margin">
		<s:text name="label.button.yes" />
	</s:a>
	<s:a id="btnRemoveQueriesNo" name="btnRemoveQueriesNo"
		href="%{removeQueriesNo}" cssClass="button regular_btn no_margin">
		<s:text name="label.button.no" />
	</s:a>
</div>