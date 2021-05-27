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

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/page"  prefix="pages"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<%@ page language="java" contentType="text/html; " pageEncoding="UTF-8"%>
<html xmlns="http://www.w3.org/1999/xhtml" lang='<s:property value="locale.language"/>'>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
        <%-- IE9 compatibility no longer needed since Orbeon now supports it: <meta http-equiv="X-UA-Compatible" content="IE=9" /> --%>
        <title>
        	<s:text name="app.title"/>
        </title>

		<script type="text/javascript">
			var absoluteURL = new function(){
				this.getURL = function(url){
					return '<s:url value="/"/>'+url;
				}
			};

			var serverData = new function(){
				this.getCSRFHeaderName = function() {
					return 'X-CSRF-Token';
				};

				this.getCSRFToken = function(){
					return '<s:property value="%{#session.SESSION_CSRF_TOKEN}"/>';
				};
			};
		</script>

        <!---->
        <script type="text/javascript" src="<s:url value='/resources/jscript/scripts.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery-1.8.2.min.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery-ui.min.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery-ui-datepicker.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery.ui.datepicker-et.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery.ui.datepicker-ru.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery.ui.selectmenu.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery.ui.core.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery.ui.button.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery.ui.position.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery.ui.widget.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery.ui.dialog.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery.ba-bbq.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/custom-form-elements.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/design.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/utils.js?v=1' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/handleConfirmablePostLinks.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/csrfProtection.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/jquery.cookie.js' encode='false'/>"></script>
		<script type="text/javascript" src="<s:url value='/resources/jscript/jquery.vtip-2.0.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/crypto/hwcrypto.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/crypto/hwcrypto-legacy.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/crypto/hex2base.js' encode='false'/>"></script>
        <script type="text/javascript" src="<s:url value='/resources/jscript/crypto/mispcryto.min.js' encode='false'/>"></script>
		<!-- Add external scripts from conf -->
		<s:iterator var="externalScriptUrl" value="@ee.aktors.misp2.util.ExternalScriptUtil@getExternalScriptUrls()" >
			<script type="text/javascript" src="<s:property value="#externalScriptUrl"/>"></script>
		</s:iterator>
        <link rel="stylesheet" type="text/css" href="<s:url value='/resources/%{subPortal}/css/main.css' encode='false'/>" media="screen" charset="utf-8" />
        <link rel="stylesheet" type="text/css" href="<s:url value='/resources/%{subPortal}/css/theme/jquery-ui-1.8.7.custom.css' encode='false'/>" charset="utf-8" />
        <link rel="stylesheet" type="text/css" href="<s:url value='/resources/%{subPortal}/css/ui.selectmenu.css' encode='false'/>" media="screen" />
        <link rel="stylesheet" type="text/css" href="<s:url value='/resources/%{subPortal}/css/custom.css' encode='false'/>" media="screen" />
        <!---->
        <decorator:head />
    </head>

    <!-- form field error handling -->
    <s:include value="/pages/formError.jsp"/>
    <s:set var="userAuthenticated" value="(#session.SESSION_USER_HANDLE != null || #session.SESSION_CERT != null)"/>

    <body>
    	<jsp:include page='eula.jsp' />
         <script type="text/javascript">
         	jQuery(document).ready(function() {
         		if (window.scaleEulaOverlay) {
    	        	// in case eula exists scale the overlay so that user can change lang and portal
             		scaleEulaOverlay(jQuery("#header").outerHeight() - 40 /* 30px shift to hide menu under overlay */);
         		}
         	});
		</script>
        <div id="header">
            <div class="container">
				<s:if test="#session.SESSION_USER_HANDLE != null && #session.SESSION_USER_ROLE != 16">
	                <script type="text/javascript">
	                    $(function() {
	                        setInterval(Utils.checkTimeout, <s:property value="%{config.getProperty('sessionTimeoutCheckInterval')}"/>*1000);
	                    });
	                </script>
                </s:if>
                <script type="text/javascript">
	            	$(function() {
	                	$("#lang_<s:property value="locale.language"/>").addClass("active");
	            	});
	            </script>

                <ul id="language">
					<s:iterator var="language" value="@ee.aktors.misp2.util.LanguageUtil@getLanguages()" >
		                <li>
			                <s:url var='langURL' action="%{context.name}" includeParams="get" escapeAmp="false"  encode="false">
			                    <s:param name="request_locale"><s:property value="#language"/></s:param> <!-- request_locale set as struts param by i18n interceptor -->
			                </s:url>
			                <a id="lang_<s:property value="#language"/>" href="<s:property value="#langURL"/>">
			                	<s:property value="getText('label.lang_switch.'+#language)"/>
			                </a>
		                </li>
					</s:iterator>

                    <s:if test="#session.SESSION_USER_HANDLE != null">
                    	<s:if test="#session.SESSION_USER_ROLE==null || #session.SESSION_USER_ROLE==1 || #session.SESSION_USER_ROLE==64">
                    		<s:set var="helpAction" value="%{locale.language+'_help'}"/>
                    	</s:if>
                    	<s:else>
                        	<s:set var="helpAction" value="%{locale.language+'_help_manager'}"/>
                    	</s:else>
                    </s:if>
                    <s:else>
                        <s:set var="helpAction" value="%{locale.language+'_help'}"/>
                    </s:else>
                    <li>
                    	<s:url var="helpurl" action="%{#helpAction}" includeParams="get" escapeAmp="false"  encode="false"/>
                        <s:a id="help" action="%{#helpAction}" target="_blank">
                            <s:if test="#subPortal=='AZ'">
                                <img src="resources/<s:property value="subPortal"/>/images/button-help.gif" alt="" />
                            </s:if>
                            <s:text name="label.help"/>
                        </s:a>
                    </li>
                    <s:if test="#session.SESSION_USER_HANDLE != null">
                        <li>
                            <s:a id="exit" action="logout" >
                                <s:if test="#subPortal=='AZ'">
                                    <img src="resources/<s:property value="subPortal"/>/images/button-exit.gif"  alt="" />
                                </s:if>
                                <s:text name="label.signout"/>
                            </s:a>
                        </li>
                    </s:if>
                    <s:else>
                        <li>
	                    	<s:url var="enterurl" action="enter" namespace="" encode="false"/>
                            <s:a href="%{enterurl}">
                                <s:text name="label.signin"/>
                            </s:a>
                        </li>
                    </s:else>
                </ul>
                <s:iterator value="" var="xroadInstance">
                   	<option value="<s:property value="#xroadInstance"/>" <s:if test='portal.clientXroadInstance.equals(#xroadInstance)'> selected="selected"</s:if>><s:property value="#xroadInstance"/></option>
                </s:iterator>

                <img id="logo" src="<s:url value='/resources/%{subPortal}/images/%{locale.language.equals("et") ? "logo.png" : "e-services.png"}' encode='false'/>" alt="" />


                <jsp:include page="user_data.jsp"/>
                <jsp:include page="menu.jsp"/>
            </div>
        </div>
        <div id="body">
            <div class="container">

                <s:set var="showSide" value="%{#userAuthenticated && showSideBox && context.name!='xforms-query'}"/>

                <s:if test="!#showSide">
                    <style type="text/css">
                        .contentbox {
                            margin-right: 0
                        }
                    </style>
                </s:if>

				<div id="content">
					<s:if test='#session.PREVIOUS_ACTION == "enter" &&
						(#session.SESSION_USER_ROLE == @ee.aktors.misp2.util.Roles@DUMBUSER ||
						#session.SESSION_USER_ROLE == @ee.aktors.misp2.util.Roles@UNREGISTERED)'>
						<div class="contentbox ok">
						   	<h3><s:text name="welcome.message.title"/></h3>
						   	<p><s:text name="welcome.message.text"/></p>
						</div>
					</s:if>
                    <s:include value="messages.jsp"/>
                    <decorator:body/>
                </div>
                <s:if test="#showSide">
                    <div id="side">
                        <div class="sidebox">
                            <h3 class="tips"><s:text name="label.quick_tips"/></h3>
                            <p><s:property value="quickTip"/></p>
                            <div id="serviceDescDiv" style="display: none">
                                <hr/>
                                <h5 id="serviceDesc"></h5>
                            </div>
                        </div>
                        <s:if test="news!=null && news.size()>0">
	                        <div class="sidebox">
	                        	<h3 class="tips"><s:text name="news.edit.news"/></h3>
				                <ul>
				                	<s:iterator value="news" var="newsIter" status="rowstatus">
				                    	<s:if test="#rowstatus.index<5">
				                    		<li><s:date name="#newsIter.created" format="dd.MM.yyyy"/></li>
				                    		<li><p><s:property value="#newsIter.news"/></p></li><br/>
				                    	</s:if>
				                    </s:iterator>
								</ul>
							</div>
						</s:if>
                    </div>
                </s:if>
            </div>
        </div>
        <div id="footer">
            <div class="container">
                <s:a href=""><img width="80" height="35" alt="" src="<s:url value='/resources/%{subPortal}/images/erf.gif'  encode='false'/>" id="erf"/></s:a>
                <a rel="noopener" href="https://x-road.global/misp2-licence-info" target="_blank">Licence info</a>

            </div>
        </div>

        <%-- Initially hidden div for displaying session timeout warning. Absolute positioned --%>
        <div id="timeoutOverlay" class="overlay">
	        <div id="session_timeout_warning">
	        	<h3 class="session_warning"><s:text name="text.extendSessionHeader"/></h3>
	        	<div class="session_warning"></div>
	        	<div><button type="button" class="button regular_btn"><s:text name="text.extendSession"/></button></div>
	        </div>
        </div>

		<%-- Initially hidden div for displaying loading overlay. Absolute positioned --%>
		<div id="loadingOverlay" class="overlay">
			<span class="xforms-loading-loading"><s:text name="help.loading.indicator"/></span>
		</div>

        <div class="translations hidden">
        	<input id="validation.service.none.selected" value="<s:text name="validation.service.none.selected"/>" type="hidden"/>
        </div>
    </body>
</html>
