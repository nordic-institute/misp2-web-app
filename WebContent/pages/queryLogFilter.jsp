<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page pageEncoding="UTF-8" %>

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

<s:url value="/resources/%{subPortal}/images/calendar.png" var="calImgUrl" escapeAmp="false"/>
<s:set var="showErrors" value="true"/>
<script type="text/javascript">
    $(document).ready(function() {
        $.datepicker.setDefaults( $.datepicker.regional['<s:property value="locale"/>'] );
        
        $(".datepicker").datepicker({
            showOn: 'button',
            buttonImage: '<s:property value="%{calImgUrl}"/>',
            buttonImageOnly: true
        },$.datepicker.regional['<s:property value="locale"/>']);
        
        $(".slide-toggle").hide();
    	$(".slide-toggle").prev().click(function(){
           	var next = $(this).next();
           	next.toggle();
		});
    	$(".toQuery").click(function(){
    		var next = $(this).parent().next();
    		if (next.hasClass('slide-toggle')) {
	    		next.toggle();
    		}
    	});
    	$("th[title]").tooltip();
    });
</script>

<s:text name="%{'dateformat'}" var="format"/>

<div class="contentbox">
    <s:if test="allowSelectUsers">
        <s:set value="%{'managerQueryLogFilter'}" var="filterAction"/>
    </s:if>
    <s:else>
        <s:set value="%{'queryLogFilter'}" var="filterAction"/>
    </s:else>
    <s:form id="queryLogFilter" action="%{filterAction}" method="get" theme="simple">
        <fieldset>
            <ul class="form">
                <li>
                    <s:date name="filterDateStart" format="%{format}" var="start"  />
                    <s:date name="filterDateEnd" format="%{format}" var="end"/>
                    <s:label key="my_settings.filter.label.datedelta" />
                    <s:fielderror fieldName="filterDateStart"/>
                    <s:fielderror fieldName="filterDateEnd"/>
                    <s:fielderror fieldName="filterTimeStart"/>
                    <s:fielderror fieldName="filterTimeEnd"/>

                    <s:textfield id="dateFieldStart" name="filterDateStart" cssClass="datepicker"
                                 value="%{#start} "  />
                    <s:textfield name="filterTimeStart" style="width: 40px"/>
                    <s:text name="my_settings.filter.label.to" />
                    <s:textfield id="dateFieldEnd" name="filterDateEnd"
                                  cssClass="datepicker" value="%{#end}" />
                    <s:textfield name="filterTimeEnd" style="width: 40px"/>
                </li>
                <li>
                    <s:label key="my_settings.filter.label.filterQueryName" for="filterQueryName"/>
                    <s:textfield name="filterQueryName"/>
                </li>
                <li>
                    <s:label key="my_settings.filter.label.queryDescription" for="filterQueryDescription"/>
                    <s:textfield name="filterQueryDescription"/>
                </li>
                <s:if test="allowSelectUsers">
                    <li>
                        <s:label key="my_settings.filter.label.users"/>
                        <s:select id="userSelect" name="selectedUserId" headerKey="-1" headerValue="%{getText('my_settings.filter.label.allusers')}"
                                  cssClass="styled" list="allUsers" listValue="fullNameSsnParenthesisEscapeHtml" listKey="id"/><s:textfield id="filterPersonSsn" name="filterPersonSsn" cssClass=""/>
                    </li>
                </s:if>
                <s:if test="#session.SESSION_USER_ROLE==8 and (#session.SESSION_PORTAL.mispType==3 or #session.SESSION_PORTAL.mispType==2)">
                <li>
                    <s:label key="my_settings.filter.label.query_unitCode" for="filterUnitCode"/>
                    <s:textfield name="filterUnitCode"/>
                </li>
                </s:if>
				<li>
                    <s:label key="my_settings.filter.label.query_id" for="filterQueryId"/>
                    <s:textfield name="filterQueryId"/>
                </li>
                <li>
                    <s:label for="successful" key="my_settings.filter.label.successful"/>
                    <s:checkbox name="successful" id="successfulQueries" cssClass="styled"/>
                    <s:fielderror fieldName="successful"/>
                </li>
            </ul>
        </fieldset>
        <s:submit name="btnSearch" key="label.button.search" cssClass="button regular_btn"/>
        <s:submit name="btnExportCsv" key="user_query_logs.button.to_csv" cssClass="button regular_btn"
        	title="%{getText('user_query_logs.button.to_csv.description')}"/>
    </s:form>
    <hr />

    <s:if  test="searchResults!=null">
        <s:if test="searchResults.size > 0">
            <table class="list" style="width:100%">
                <thead>
                    <tr>
                        <th><s:text name="services.show.list.description"/></th>
                        <s:if test="allowSelectUsers"> 
                            <th><s:text name="user_query_logs.filter.thead.username"/></th>
                        </s:if>
                        <th><s:text name="user_query_logs.filter.thead.query_time"/></th>
                        <th><s:text name="user_query_logs.filter.thead.id"/></th>
						<th title ="<s:text name="user_query_logs.filter.tooltip.query_time_ms"/>">
							<s:text name="user_query_logs.filter.thead.query_time_ms"/>
						</th>
						<s:if test="#session.SESSION_USER_ROLE==8 or #session.SESSION_USER_ROLE==2 and #showErrors">
							<th title="<s:text name="user_query_logs.filter.tooltip.query_size"/>">
								<s:text name="user_query_logs.filter.thead.query_size"/>
							</th>
						</s:if>									
						<s:if test="#session.SESSION_USER_ROLE!=8 and #session.SESSION_USER_ROLE!=2"><th></th></s:if>
						<s:if test="#session.SESSION_USER_ROLE==8 and #session.SESSION_PORTAL.mispType==3 or #session.SESSION_PORTAL.mispType==2"><th><s:text name="user_query_logs.filter.thead.organisation"/></th></s:if>
                    </tr>
                </thead>
                <tbody>
                    <s:iterator value="searchResults" var="res">
                    <s:if test="%{#res.queryLog.success || !res.queryLog.queryErrorLogId}">
                        <tr id="queryLogTable" class="selection">
                    </s:if>
                    <s:else>
                        <tr id="queryLogTable" class="selection log_error" style="cursor:pointer;">
                    </s:else>
                            <td><s:property value="%{#res.queryLog.description}"/> <s:if test="#session.SESSION_USER_ROLE==8 or #session.SESSION_USER_ROLE==2">(<s:property value="%{#res.queryLog.queryName}"/>)</s:if></td>
                            <s:if test="allowSelectUsers">
                            	<s:if test="%{#res.person.fullNameSsn!=null}">
                            		<s:set value="%{#res.person.fullNameSsn}" var="username"/>
                            	</s:if>
								<s:else>
									<s:set value="%{#res.queryLog.personSsn}" var="username"/>
								</s:else>
                                <td><s:property value="%{username}"/></td>
                            </s:if>
                            <td>
                                <s:date name="%{#res.queryLog.queryTime}" format="%{format} HH:mm:ss.SSS" var="time"/>
                                <s:property value="%{time}"/>
                            </td>
							<td><s:property value="%{#res.queryLog.queryId}"/></td>
							
								<td><s:property value="%{#res.queryLog.queryTimeSec}"/></td>
								<s:if test="#session.SESSION_USER_ROLE==8 or #session.SESSION_USER_ROLE==2 && #showErrors">
									<td>
										<s:property value="%{#res.queryLog.querySize.longValue()!=0 ? (#res.queryLog.querySize.doubleValue() / 1000.0) : '0'}"/>
									</td>
								</s:if>
							<s:if test="#session.SESSION_USER_ROLE!=8 and #session.SESSION_USER_ROLE!=2">
								<td class="toQuery" style="padding: 4px 4px 0px 10px;">
									<s:if test="%{#res.queryId}">
		                        		<s:url var="runXforms" action="xforms-query">
											<s:param name="id" value="%{#res.queryId}"/>
										</s:url>
										<s:a cssClass="small" href="%{runXforms}" id="queryLogBtn">
											<img src="resources/<s:property value="subPortal"/>/images/start.png" title="<s:text name="label.button.repeat"/>" width="20" height="18" />
										</s:a>
									</s:if>
									<s:else>
										<s:text name="user_query_logs.filter.service_not_found"/>
									</s:else>
                   				</td>
							</s:if>
							<s:if test="#session.SESSION_USER_ROLE==8 and #session.SESSION_PORTAL.mispType==3 or #session.SESSION_PORTAL.mispType==2">
                                <td><s:property value="%{#res.queryLog.unitCode}"/></td>
                            </s:if>
							</tr>
						<s:if test="#showErrors && !#res.queryLog.success">
							<tr class="slide-toggle" style="display:none">
                        		<td colspan="6">
                        			<div class="log_error_keys"><s:text name="user_query_logs.error.code"/></div>
                        			<div class="log_error_desc"><s:property value="%{#res.queryLog.queryErrorLogId.code}"/></div>
	                        		<br>
                        			<div class="log_error_keys"><s:text name="user_query_logs.error.description"/></div>
                        			<div class="log_error_desc"><s:property value="%{#res.queryLog.queryErrorLogId.description}"/></div>
                        			<br>
                        			<div class="log_error_keys"><s:text name="user_query_logs.error.detail"/></div>
                        			<div class="log_error_desc"><s:property value="%{#res.queryLog.queryErrorLogId.detail}"/></div>
                        		</td>
                        	</tr>
						</s:if>
                    </s:iterator>
                </tbody>
                <s:if test="%{(itemCount/pageSize)>0}">
                    <tfoot>
                        <tr>
                            <td colspan="6" style="text-align: center">                 
                                <s:if test="pageNumber>1">
                                    <s:a action="%{filterAction}" includeParams="all">
                                        <s:param name="pageNumber" value="%{pageNumber-1}"/>
                                        <img src="resources/<s:property value="subPortal"/>/images/arrow-left-single.png"  alt="" />
                                    </s:a>
                                </s:if>
                                <s:property value="%{pageNumber}"/>/<s:property value="%{(itemCount/pageSize)+1}"/>
                                <s:if test="searchResults.size>=pageSize">
                                    <s:a action="%{filterAction}" includeParams="all">
                                        <s:param name="pageNumber" value="%{pageNumber+1}"/>
                                        <img src="resources/<s:property value="subPortal"/>/images/arrow-right-single.png"  alt="" />
                                    </s:a>
                                </s:if>
                            </td>
                        </tr>
                    </tfoot>
                </s:if>
            </table>
        </s:if>
        <s:else>
            <h5><s:text name="text.search.no_results"/></h5>
        </s:else>

    </s:if>
    <s:else>
    	<span><s:text name="user_query_logs.notice.query_not_executed"/></span>
    </s:else>
</div>