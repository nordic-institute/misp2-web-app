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

<script src="resources/jscript/syntaxhighlighter/codemirror.js" type="text/javascript"></script>
<style type="text/css">
    .CodeMirror-line-numbers {
        width: 2.2em;
        color: #aaa;
        background-color: #eee;
        text-align: right;
        padding-right: .3em;
        font-size: 10pt;
        font-family: monospace;
        padding-top: .4em;
        line-height: 1.2em;
    }
</style>

<div class="contentbox">
	<s:if test="query.type==2">
		<s:url var="listQueries" action="listComplexQueries">
			<s:param name="id" value="query.producer.id"/>
            <s:param name="protocol" value="protocol"/>
		</s:url>
	</s:if>
	<s:else>
		<s:url var="listQueries" action="listQueries">
			<s:param name="id" value="query.producer.id"/>
            <s:param name="protocol" value="protocol"/>
		</s:url>
	</s:else>

	<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toListQueries')}"  href="%{listQueries}"><s:text name="help.back.label"/></s:a>
    <s:form action="saveXforms?protocol=%{protocol}" theme="simple" >
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="label.xforms.queryNote" for="queryNote"/>
                </li>
                <li>
                    <s:textarea name="queryNote" cols="50" rows="5"/>
                </li>
            </ul>
        </fieldset>
        <hr />
        <fieldset style="border: 1px solid black; padding: 0px; padding-bottom: 10px">
            <s:hidden name="protocol"/>
            <s:hidden name="id"/>
            <s:hidden name="qId" value="%{query.id}"/>
            <s:hidden name="xforms.id" />
            <s:hidden name="xforms.url" />
            <s:hidden name="xforms.query.id" />
            <s:textarea id="xforms_code" name="xforms.form" cols="100" rows="20"/>
            <s:submit key="label.button.save" cssClass="button regular_btn" cssStyle="margin-left:auto; margin-right:auto; margin-top: 0; width:65px; display:block" name="btnSubmit"/>
        </fieldset>
    </s:form>
</div>



<script type="text/javascript">
    var editor = CodeMirror.fromTextArea('xforms_code', {
        height: "490px",
        parserfile: "parsexml.js",
        stylesheet: "resources/jscript/syntaxhighlighter/xmlcolors.css",
        path: "resources/jscript/syntaxhighlighter/",
        continuousScanning: 500,
        lineNumbers: true
	    
    });
</script>