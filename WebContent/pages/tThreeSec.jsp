<%@page pageEncoding="UTF-8" %>
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

<s:url value="/resources/%{subPortal}/images/calendar.png" var="calImgUrl" escapeAmp="false"/>
<script type="text/javascript">
    $(document).ready(function() {
       $.datepicker.setDefaults($.datepicker.regional['<s:property value="locale"/>'] );
       $(".datepicker").datepicker({
            showOn: 'button',
            buttonImage: '<s:property value="%{calImgUrl}"/>',
            buttonImageOnly: true
        },$.datepicker.regional['<s:property value="%{locale}"/>']);

        $("#tegevus").change(function(){
            showHideLogSearchParams(this);
        });
        $("#tegevus").change();
        var errorInvalidDate = '<s:text name="validation.date"/>';
        $("#logDateStart").change(function(){
        	checkDate($(this), errorInvalidDate);
        });
        $("#logDateEnd").change(function(){
        	checkDate($(this), errorInvalidDate);
        });
    });
</script>
<s:text name="%{'dateformat'}" var="format"/>

<style type="text/css">
    .contentbox form label{
        min-width: 300px;
    }
    .ui-datepicker-trigger{padding-left: 2px; vertical-align: top;}
</style>

<div class="contentbox">
    <s:form id="t3SecFilter" action="t3SecFilter" method="get" theme="simple">
        <ul class="form" id="t3secForm">
            <li>
                <s:label key="t3sec.filter.label.actionSelect"/>
                <s:select name="actionSelect" list="actions" value="selectedAction" 
                          id="tegevus" headerKey="-1" headerValue="-- %{getText('t3sec.action.select.-1')} --" cssClass="styled"/>
            </li>
            <li id="logSearchSsnFrom" <s:if test="context.name=='t3SecFilterInit.action'">style="display:none;"</s:if>>
                <s:label key="t3sec.filter.label.ssnFrom"/>
                <s:fielderror fieldName="ssnFrom"/>
                <s:textfield name="ssnFrom"/>
            </li>
            <li id="logSearchSsnTo" <s:if test="context.name=='t3SecFilterInit.action' || (selectedAction!=0 && selectedAction!=2 && selectedAction!=4)"> style="display:none;"</s:if>>
                <s:label key="t3sec.filter.label.ssnTo"/>
                <s:fielderror fieldName="ssnTo"/>
                <s:textfield name="ssnTo"/>
            </li>
            <li id="logSearchOrgCode" <s:if test="context.name=='t3SecFilterInit.action'"> style="display:none;"</s:if>>
                <s:label key="t3sec.filter.label.orgCode"/>
                <s:fielderror fieldName="orgCode"/>
                <s:textfield name="orgCode"/>
            </li>
            <li id="logSearchQueryId" <s:if test="context.name=='t3SecFilterInit.action' || (selectedAction!=6 && selectedAction!=7)">style="display:none;"</s:if>>
                <s:label key="t3sec.filter.label.queryId"/>
                <s:fielderror fieldName="queryId"/>
                <s:textfield name="queryId"/>
            </li>
            <li id="logSearchGroupName" <s:if test="context.name=='t3SecFilterInit.action' || (selectedAction!=1 && selectedAction!=2 && selectedAction!=3 && selectedAction!=8) ">style="display:none;"</s:if>>
                <s:label key="t3sec.filter.label.groupName"/>
                <s:fielderror fieldName="groupName"/>
                <s:textfield name="groupName"/>
            </li>
            <li id="logSearchDateFrom" <s:if test="context.name=='t3SecFilterInit.action'"> style="display:none;"</s:if>>
                <s:label key="t3sec.filter.label.dateFrom"/>
                <s:date name="filterDateStart" format="%{format}" var="start"  />
                <s:textfield id="logDateStart" value="%{#start}" name="dateFrom" cssClass="datepicker"/>
            </li>
            <li id="logSearchDateTo" <s:if test="context.name=='t3SecFilterInit.action'"> style="display:none;"</s:if>>
                <s:label key="t3sec.filter.label.dateTo"/>
                <s:date name="filterDateEnd" format="%{format}" var="end"/>
                <s:textfield id="logDateEnd" name="dateTo" value="%{#end}" cssClass="datepicker"/>
            </li>
            <%--<li id="logSearchSubOrg" <s:if test="context.name=='t3SecFilterInit.action'"> style="display:none;"</s:if>>
                 TODO: suborgs to include
            <s:label key="t3sec.filter.label.subOrg"/>
            <s:fielderror fieldName="subOrg"/>
            <s:checkbox name="subOrg"/>
            </li>--%>
            <li id="logSearchSubmit" <s:if test="context.name=='t3SecFilterInit.action'"> style="display:none;"</s:if>>
                <s:submit name="submit" key="label.button.search" cssClass="button regular_btn" />
            </li>
        </ul>
    </s:form>


    <s:if test="searchResults!=null">
        <hr />
        <s:if test="searchResults.size > 0">

            <h3><s:text name="t3sec.filter.found"/>:</h3>
            <table class="list" width="100%" style="font-size: 1.1em">
                <thead>
                    <tr>
                        <th><s:text name="t3sec.filter.thead.action"/></th> <!-- always -->
                        <th><s:text name="t3sec.filter.thead.from"/></th>   <!-- always -->
                        <th><s:text name="t3sec.filter.thead.orgCode"/></th> <!-- always -->

                        <s:if test="selectedAction == 0 ||  selectedAction == 2 || selectedAction == 4">
                            <th><s:text name="t3sec.filter.thead.to"/></th>     <!-- 0, 1, 2, 3, 8, 9 -->
                        </s:if>
                        <s:if test="selectedAction == 1 || selectedAction == 2 || selectedAction == 3 || selectedAction == 8">
                            <th><s:text name="t3sec.filter.thead.groupName"/></th> <!-- 2, 3, 4, 5, 6, 7, 16  -->
                        </s:if>
                        <s:if test="selectedAction == 3 || selectedAction == 6 || selectedAction == 7">
                            <th><s:text name="t3sec.filter.thead.queryName"/></th> <!-- 4, 5, 14, 15 -->
                        </s:if>
                        <s:if test="selectedAction == 5">
                            <th><s:text name="t3sec.filter.thead.portalName"/></th> <!-- 10-13  -->
                        </s:if>

                        <s:if test="selectedAction == 6 || selectedAction == 7"> <!-- 6, 7 in combobox -->
                            <th><s:text name="t3sec.filter.thead.queryId"/></th>
                        </s:if>

                        <s:if test="selectedAction == 8">  <!-- 8 in combobox -->
                            <th><s:text name="t3sec.filter.thead.groupValidUntil"/></th>
                        </s:if>
                        <th><s:text name="t3sec.filter.thead.time"/></th> <!-- always -->


                    </tr>
                </thead>
                <s:iterator value="searchResults" var="res">
                    <tr>
                        <td style="border-style:hidden"><s:text name="t3sec.action.%{#res.actionId}"/></td> <!-- always, from properties file -->
                        <td style="border-style:hidden"><s:property value="%{#res.userFrom}"/></td>  <!-- always -->
                        <td style="border-style:hidden"><s:property value="%{#res.orgCode}"/></td>  <!-- always -->

                        <s:if test="#res.actionId == 0 || #res.actionId == 1 || #res.actionId == 2 || #res.actionId == 3 || #res.actionId == 8 || #res.actionId == 9">
                            <td style="border-style:hidden"><s:property value="%{#res.userTo}"/></td>  <!--  0, 1, 2, 3, 8, 9 -->
                        </s:if>
                        <s:if test="#res.actionId == 2 || #res.actionId == 3 || #res.actionId == 4 || #res.actionId == 5 || #res.actionId == 6 || #res.actionId == 7 || #res.actionId == 16">
                            <td style="border-style:hidden"><s:property value="%{#res.groupName}"/></td>  <!-- 2, 3, 4, 5, 6, 7, 16 -->
                        </s:if>
                        <s:if test="#res.actionId >=10 && #res.actionId <= 13">
                            <td style="border-style:hidden"><s:property value="%{#res.portalName}"/></td>  <!-- 10-13 -->
                        </s:if>
                        <s:if test="#res.actionId == 4 || #res.actionId == 5 || #res.actionId == 14 || #res.actionId == 15">
                            <td style="border-style:hidden"><s:property value="%{#res.query}"/></td>  <!-- 4, 5, 14, 15 -->
                        </s:if>
                        <s:if test="#res.actionId == 14 || #res.actionId == 15">
                            <td style="border-style:hidden"><s:property value="%{#res.queryId}"/></td> <!-- 14, 15 -->
                        </s:if>
                        <s:if test="#res.actionId == 16">
                            <td style="border-style:hidden"><s:property value="%{#res.validParam}"/></td>  <!-- 16 -->
                        </s:if>

                        <td style="border-style:hidden">
                            <s:if test="#res.created==null">
                                <s:set var="date_created" value="-"/>
                            </s:if>
                            <s:else><s:date name="%{#res.created}" format="yyyy-MM-dd HH:mm" var="date_created"/> <!-- always  -->
                            </s:else>
                            <s:property value="%{date_created}"/>
                        </td>
                    </tr>
                </s:iterator>
            </table>
        </s:if>
        <s:else>
            <h3><s:text name="text.search.no_results"/></h3>
        </s:else>

    </s:if>
</div>