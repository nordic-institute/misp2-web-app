<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page pageEncoding="UTF-8"%>
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

<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/util/util.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/util/arrayutil.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/util/headers.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/util/dateutil.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/query.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/input.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/output.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/view.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/repeat.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/event.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/content-type/json.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/content-type/file.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/content-type/multipart.js' encode='false'/>"></script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/content-type/text.js' encode='false'/>"></script>

<s:if test="%{config.getBoolean('restform.tests.enabled', false)}">
	<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/test/test.js' encode='false'/>"></script>
	<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/test/test-arrayutil.js' encode='false'/>"></script>
	<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/test/test-headers.js' encode='false'/>"></script>
	<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/test/test-util.js' encode='false'/>"></script>
	<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/test/test-output.js' encode='false'/>"></script>
</s:if>

<script type="text/javascript">
	restform.input.datepickerLocale = '<s:property value="locale"/>';
</script>
<script type="text/javascript" src="<s:url value='/resources/jscript/rest-form/init.js' encode='false'/>"></script>

<link rel="stylesheet" type="text/css" href="<s:url value='/resources/%{subPortal}/css/rest-form.css' encode='false'/>" media="screen" charset="utf-8" />

<style type="text/css">
	/* Only show blocks of current locale (and undefined locale with no 'data-rf-lang' attribute). */
	.rest-form [data-rf-lang]:not([data-rf-lang='<s:property value="locale"/>']) {
		display: none;
	}
</style>

<div class="contentbox">
	<s:if test="#session.SESSION_USER_ROLE==4 || #session.SESSION_USER_ROLE==8">
		<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toListQueries')}"  href="javascript: history.go(-1)"><s:text name="help.back.label"/></s:a>
	</s:if>
	<s:hidden name="main-query-id" value="%{query.id}" theme="simple"/>
	
	<s:url value="/resources/%{subPortal}/images/calendar.png" var="calImgUrl" escapeAmp="false"/>
	<s:hidden name="calendar-img-url" value="%{calImgUrl}" theme="simple"/>
	
	<s:hidden name="debug-enabled"
		value="%{portal.debug==1 && (#session.SESSION_USER_ROLE==4 || #session.SESSION_USER_ROLE==8)}"
		theme="simple"/>
	

	<div id="rest-form-messages" class="hidden">
		<s:hidden name="text.error.form_fields" value="%{getText('text.error.form_fields')}" theme="simple"/>
		<s:hidden name="label.button.ok" value="%{getText('label.button.ok')}" theme="simple"/>
		<s:hidden name="text.session_expired" value="%{getText('text.session_expired')}" theme="simple"/>
		
		<s:iterator value="getRestFormTranslationCodes()" var="translationCode">
			<s:hidden name="%{#translationCode}" value="%{getText(#translationCode)}" theme="simple"/>
'		</s:iterator>
		
	</div>
	<div id="xformsframe" class="rest-form"><s:property value="getRestForm()" escapeHtml="false"/></div>
</div>

