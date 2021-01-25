<%@page  pageEncoding="UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags"%>

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

<!-- delete button handle -->
<s:url action="styleDelete" var="delUrl" escapeAmp="false">
    <s:param name="styleId" value="%{styleId}"/>
</s:url>

<%-- syntax highlighting --%>
<script src="<s:url value='/resources/jscript/syntaxhighlighter/codemirror.js'/>" type="text/javascript"></script>
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

<script type="text/javascript">
    function resetSelectbox(qObj) {

        var firstItem = qObj.children("option:first");
        qObj.children("option").remove();
        qObj.append(firstItem);
        qObj.val("");

    }

    $(document).ready(function(){
        var editor = CodeMirror.fromTextArea('xslContents', {
            parserfile: "parsexml.js",
            stylesheet: "<s:url value='/resources/jscript/syntaxhighlighter/xmlcolors.css' escapeAmp='false'/>",
            path: "<s:url value='/resources/jscript/syntaxhighlighter/' escapeAmp='false'/>".split(/[\?;]/)[0],	// remove ';jsessionid' and parameters
            continuousScanning: 500,
            lineNumbers: true,
            height:"400px"
        });
                
        var previousURL = $("#show_style_xslt_url").val()
        // all kinds of events handling
            
        $("#update").click(function() {
            if($("#show_style_xslt_url").val().length>0) {
                $.ajax({
                    async:"false",
                    dataType:"text",
                    type:"GET",
                    url: "<s:url escapeAmp='false' action='/ajax/ajaxReadUrl'/>",
                    data: {url: $("#show_style_xslt_url").val()},
                    processData:"false",
                    success: function(data) {
                        $("#xslContents").val(data)
                        editor.reloadContent("xslContents")
                    },
                    error: function() {
                        alert('<s:text name="xslt_styles.error.unexpected"/>')
                    }
                })
            }else {
                $("#xslContents").val("")
            }
        });
    
        $("#andmekogu").change(function() {
            var qs=$("#querySelect");
            qs.children().remove()
            if($(this).val()=="") {
                
                qs.append('<span><s:text name="xslt_styles.show.default.query"/></span>')
                
            }else {
				$.ajax({
					url: "<s:url escapeAmp='false' action='ajax/ajaxProdQuery'/>",
					data: {"producerId":$(this).val()},
					type: "GET",
					async: true,
					cache: false,
					dataType: "html",
					success: function(data){
	                    $("#querySelect").append(data)
	                    $("#queryName").selectmenu({
	                        style:'dropdown',
	                        maxHeight:150
	                    });
					}
				});
            }
            
        })
        //$("#andmekogu").change(); //trigger change event
            
        $("#btnSave").click(function(event) {
        	event.preventDefault();
            $("#hiddenbtnSave").val("Save")
            if(previousURL!=$("#show_style_xslt_url").val()) {
                if($("#show_style_xslt_url").val().length>0) {
                    $.ajax({
                        async:"false",
                        dataType:"text",
                        type:"GET",
                        url: "<s:url escapeAmp='false' action='/ajax/ajaxReadUrl'/>",
                        data: {url: $("#show_style_xslt_url").val()},
                        processData:"false",
                        success: function(data) {
                            $("#xslContents").val(data)
                                    
                            editor.reloadContent("xslContents")
                            $("#show_style").submit();
                        },
                        error: function() {
                            alert('<s:text name="xslt_styles.error.unexpected"/>')
                        }
                    })
                }
            } else {
                $("#show_style").submit();
            }
        })
    })
</script>


<div class="contentbox">
<s:url var="listXsl" action="stylesFilter"/>
<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toXslt')}"  href="%{listXsl}"><s:text name="help.back.label"/></s:a>

    <s:form id="show_style" action="styleSubmit" theme="simple">
        <s:hidden name="xslt.id"/>
        <s:hidden name="styleId"/>
        <s:hidden id="hiddenbtnSave" name="btnSave" value=""/>
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="xslt_styles.show.label.xslt_name"/>
                    <s:textfield name="xslt.name" cssClass="formField"/>
                    <s:fielderror fieldName="xslt.name"/>
                </li>
                <li>
                    <s:label key="xslt_styles.show.label.in_use"/>
                    <s:checkbox name="inUse" value="xslt.inUse" cssClass="styled"/>
                    <s:fielderror fieldName="inUse"/>
                </li>
                <li>
                    <s:text name="xslt_styles.show.default.producer" var="allProducersText"/>
                    <s:label key="xslt_styles.show.label.producer"/>
                    <s:select name="xslt.producerId" list="producers"
                              listKey="id" listValue="xroadIdentifierEscapeHtml" id="andmekogu"
                              headerKey="" headerValue="%{allProducersText}"
                              cssClass="styled"/>
                    <s:fielderror fieldName="xslt.producerId"/>
                </li>

                <li>
                    <s:label key="xslt_styles.show.label.query"/>
                    <span id="querySelect">
                        <s:text name="xslt_styles.show.default.query" var="allQueriesText"/>
                        <s:if test="xslt.producerId!=null">
                            <s:select id="queryName" list="producersQueries" name="queryId"
                                  listKey="id" listValue="name" headerKey="" headerValue="%{allQueriesText}"
                                  cssClass="styled"/>
                        <s:fielderror fieldName="queryId"/>
                        </s:if>
                        <s:else>
                            <span><s:property value="%{allQueriesText}"/></span>
                        </s:else>
                    </span>
                </li>
                <li>
                    <s:label key="xslt_styles.show.label.form_type"/>
                    <s:select name="xslt.formType" list="#{0:'HTML', 1:'PDF'}"
                              cssClass="styled"/>
                    <s:fielderror fieldName="xslt.formType"/>
                </li>
                <li>
                    <s:label key="xslt_styles.show.label.priority"/>
                    <s:textfield name="xslt.priority" cssClass="numberField"/>
                    <s:fielderror fieldName="xslt.priority"/>
                </li>
                <li>
                    <s:label key="xslt_styles.show.label.url"/>
                    <s:textfield name="xslt.url" cssClass="long_url"/>
                    <s:fielderror fieldName="xslt.url"/>

                    <s:a cssClass="button regular_btn" cssStyle="margin:0" id="update" href="#">
                        <s:text name="label.button.refresh_xsl_contents"/>
                    </s:a>
                </li>
            </ul>
        </fieldset>
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="xslt_styles.show.label.xsl"/>
                    <s:fielderror fieldName="xslt.xsl"/>
                    <s:textarea name="xslt.xsl" id="xslContents" rows="25"/>
                </li>
            </ul>
        </fieldset>
        <s:a id="btnSave" href="" cssClass="button regular_btn"><s:text name="label.button.save"/></s:a>

        <s:if test="styleId!=null">
            <s:a id="btnDel" name="btnDelete" href="%{delUrl}" data-confirmable-post-link="%{getText('text.confirm.delete')}" cssClass="button delete_btn">
            	<s:text name="label.button.delete"/>
            </s:a>
        </s:if>
    </s:form>
</div>
