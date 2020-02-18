<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page  pageEncoding="UTF-8" %>

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

<div class="contentbox">
<s:url var="listComplexProducers" action="listProducers">
    <s:param name="protocol" value="protocol"/>
</s:url>

<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toComplexList')}"  href="%{listComplexProducers}"><s:text name="help.back.label"/></s:a>
    <s:form method="post" name="query_list" id="form_queries" theme="simple">
        <table class="list selection">
            <tr>
                <th colspan="6"><h4><s:text name="services.show.list.complex"/> (<s:property value="%{getProducerDescription()}"/>)</h4></th>
            </tr>
            <s:if test="queries.size > 0">
                <s:iterator value="queries" var="qs">
                    <s:iterator value="xformsList" var="xList" status="rowstatus">
                        <s:if test="#qs.id == #xList.query.id">
                            <tr>
                                <td>
                                    <s:url var="editXforms" action="editXforms">
                                        <s:param name="id" value="id"/>
                                        <s:param name="cProducerId" value="%{complexProducer.id}"/>
                                        <s:param name="protocol" value="protocol"/>
                                    </s:url>
                                    <s:set value="#qs.getActiveName(locale.language).description" var="varQueryName"/>
									<s:a href="%{editXforms}" title="%{getText('help.tooltip.lastModified')} %{#xList.lastModified}" id="xforms_link[%{#rowstatus.index}]" theme="xhtml" cssStyle="display: block; width: 120%; height: 100%;">
										<s:property value="#varQueryName"/>
										<s:if test="#varQueryName==null || #varQueryName==''">
											<s:text name="menu.no_description"/>
										</s:if>
                                    </s:a>
                                </td>
                                <td style="vertical-align: middle">
                                	<s:property value="complexProducer.shortName" />.<s:property value="name" /> 
                                </td>
                                <td class="modify">
                                    <s:url var="runXforms" action="xforms-query">
                                        <s:param name="id" value="#qs.id"/>
                                        <s:param name="protocol" value="protocol"/>
                                    </s:url>
                                    <s:a cssClass="small" href="%{runXforms}" id="xforms_run_link" >
                                        <img src="resources/<s:property value="subPortal"/>/images/start.png" alt="<s:text name="label.execute_query" />" width="20" height="20"/>
                                    </s:a>
                                </td>
                                <td class="modify">
                                    <s:url var="changeDesc" action="changeComplexDesc">
                                        <s:param name="queryId" value="#qs.id"/>
                                        <s:param name="protocol" value="protocol"/>
                                    </s:url>

                                    <s:a href="%{changeDesc}" theme="xhtml" cssClass="small" id="changeComplexDesc_link" title="%{getText('label.change.complex')}" >
                                        <img src="resources/<s:property value="subPortal"/>/images/tools.png" width="20" height="20"/>
                                    </s:a>
                                </td>
                                <td style="vertical-align: middle; padding: 3px">
                                    <input type="text" class="long_url" id="xformsUrl[<s:property value="#rowstatus.index"/>]"  value='<s:property value="#xList.url"/>'>
                                </td>
                                <td class="modify center_middle" style="padding-left:3px; width: 20px;">
                                	<strong></strong>
                                    <input type="checkbox" name="updateXforms" id="updateXforms[<s:property value="#rowstatus.index"/>]" value="<s:property value="#qs.id"/>" class="styled" />
                                </td>
                            </tr>
                        </s:if>

                    </s:iterator>
                </s:iterator>
                <tr>
                    <td colspan="5" class="modify" style="text-align:right; padding-right:5px;">
                        <strong><s:text name="check.all" /></strong>
                    </td>
                    <td class="modify center_middle" id="checks" style="padding-left:3px;">
                    	<strong></strong>
                        <input type="checkbox" value="checkall" name="checkall" id="checkall" class="styled"/>
                    </td>
                </tr>
            </s:if>

            <tr>
                <td class="modify button_bar inactive" colspan="6" style="text-align:right;padding-bottom: 10px">
                    <script type="text/javascript">
                        $(document).ready(function(){
                            $("#addNew").click(function() {
								window.location.href='<s:url action="addComplexQuery" escapeAmp="false"><s:param name="protocol" value="protocol"/><s:param name="id" value="%{complexProducer.id}"/></s:url>';
                            });  
                            
                            $("#refreshBtn").click(function() {
								var Gurl ="";
								for(n = 0; n < <s:property value="xformsList.size"/>; n++){
								    if(document.getElementById('updateXforms['+n+']').checked==true){
								        Gurl = Gurl + ","+document.getElementById('updateXforms['+n+']').value+','+document.getElementById('xformsUrl['+n+']').value;
								    }
								}
								if(Gurl.substr(1)=="") return alert("<s:property value="%{getText('validation.js.choose_service')}"/>");
								
								window.location.href= '<s:url action="listComplexQueries" escapeAmp="false"><s:param name="protocol" value="protocol"/><s:param name="id" value="\'dummyValue\'"/><s:param name="xformsGroup" value="\'dummyValue2\'"/></s:url>'.
									replace("dummyValue", <s:property value="id"/>).
									replace("dummyValue2", Gurl.substr(1));
                            });
                            $("#checks").click(function() {
                            	checkUncheckAll()
                            })
                        });

                         
                    </script>

                    <s:a cssClass="button regular_btn left-margin" id="addNew" href="#">
                        <s:text name="label.button.add_new"/>
                    </s:a>

                    <s:a cssClass="button regular_btn" id="refreshBtn" href="#">
                        <s:text name="label.button.refresh_descriptions.%{protocol}"/>
                    </s:a>
                </td>
            </tr>

        </table>
    </s:form>
</div>
