<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page  pageEncoding="UTF-8" %>
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

<style type="text/css">
    .contentbox form label {
        width:300px;
    }
    /*Override label inline-block style*/
    .contentbox form label.hidden {
        display:none;
    }
    .eula-content textarea {
    	width: 600px;
    	height: 300px;
    }
    .eula-content label {
    	vertical-align: top;
    }
</style>
<s:url action="removePortal" var="remove" escapeAmp="false">
    <s:param name="portalId" value="%{portalId}" />
</s:url>
<script type="text/javascript">
	/**
	Displaying-hiding priority:
		priority 1: jQuery.hide() or show() ==> adding/removing style="display: none;" inline attribute
		priority 2: 'hidden' class adding and removing from elements
	Both are used in parallel in order to avoid rewriting legacy UI logic in this JSP: 
	jQuery().hide() is used hide elements on portal change (legacy)
	hidden class is used to hide elements on portal X-Road version switch (v6-specific changes).
	*/
    $(document).ready(function() {
        $("#portalType").change(function() {
            $(".universal").hide();
            var portalType = $(this).val();
            var jqEls = jQuery();
            if(portalType == '<s:property value="@ee.aktors.misp2.util.Const@MISP_TYPE_UNIVERSAL"/>'){
            	jqEls = $(".universal").show();
            } else if(portalType == '<s:property value="@ee.aktors.misp2.util.Const@MISP_TYPE_ORGANISATION"/>') {
            	jqEls = $(".org").show();
            }
            // for showing item, jQuery might add inline style to some li-elements which override hidden class, to avoid that, remove 'display:list-item;' - s
            jqEls.each(function(){
            	var styleAttr = jQuery(this).attr("style");
            	if( styleAttr == "display: list-item;"){
            		jQuery(this).removeAttr("style");
            	}
            });
        });
        $("#portalType").change();
        
        function changeLogQuery(el){
        	if($("#portalXroadProtocolVer").val() == "<s:property value="@ee.aktors.misp2.util.Const$XROAD_VERSION@V6.protocolVersion"/>" && $("#portalLogQuery").is(":checked")){
        		$(".xroad-v6-log").removeClass("hidden"); // show
        		$(".xroad-non-v6-log").addClass("hidden"); // hide
        	}
        	else{
        		$(".xroad-v6-log").addClass("hidden"); // hide
        		$(".xroad-non-v6-log").removeClass("hidden"); // show
        	}
        }
        
        function disableBySelector(selector){
    		$(selector).addClass("hidden").find("input, select").attr("disabled", "disabled"); // hide
        }
        function enableBySelector(selector){
        	$(selector).removeClass("hidden").find("input, select").removeAttr("disabled").each(function(){
        		var jqEl = $(this);
        		if(jqEl.attr("style") == "opacity: 0.4;"){
        			jqEl.removeAttr("style");
        		}
        	}); // show
        }
        
        $("#portalXroadProtocolVer").change(function(){
        	if($(this).val() == "<s:property value="@ee.aktors.misp2.util.Const$XROAD_VERSION@V6.protocolVersion"/>"){
        		enableBySelector(".xroad-v6");
        		disableBySelector(".xroad-non-v6");
        	}
        	else{
        		disableBySelector(".xroad-v6");
        		enableBySelector(".xroad-non-v6");
        	}
        	changeLogQuery(this);
        });
        // needed to add disabled and enabled fields
        $("#portalXroadProtocolVer").change();
        
        $("#portalLogQueryLi").click(function(){changeLogQuery(this);});
        
        
        $("input[type='checkbox'][name='useEula']").on("change", function () {
        	if($(this).is(":checked")) {
            	$(".eula-content").show();
        	} else {
            	$(".eula-content").hide();
        	}
        });
    });
</script>
<div class="contentbox">
<s:url var="listPortals" action="listPortals"/>

<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toPortalList')}"  href="%{listPortals}"><s:text name="help.back.label"/></s:a>
    <s:form method="post" theme="simple" action="savePortal">
        <fieldset style="border: 1px">
            <ul class="form">
                <s:hidden name="portalId"/>
                
				<s:iterator status="stat" value="(#attr['languages'].size()).{ #this }" >
	                <li>
                		<s:set var="language" value = "#attr['languages'].get(#stat.index)"/>
                		<label><s:property value="getText('portal.label.name')+' ('+#language.toUpperCase()+')'"/></label>
	                    <s:textfield name="portalNames[%{#stat.index}].description" placeholder="%{getText('placeholder.portal.name')}"/>
	                    <s:hidden name="portalNames[%{#stat.index}].id"/>
						<s:fielderror>
						     <s:param><s:property value="'portalNames['+#stat.index+'].description'"/></s:param>
						</s:fielderror>
	                </li>
				</s:iterator>
				
                <li>
                    <s:label key="portal.label.short_name"/>
                    <s:textfield name="portal.shortName" placeholder="%{getText('placeholder.portal.short_name')}"/>
                    <s:fielderror fieldName="portal.shortName"/>
                </li>
                
                <li>
                    <s:label key="portal.label.type" />
                    <s:if test="portal.id">
                        <span><s:text name="%{'portal.label.types.'+portal.mispType}"/></span>
                        <s:hidden name="portal.mispType" value="%{portal.mispType}"/>
                    </s:if>
                    <s:else>
                        <select name="portal.mispType" id="portalType" class="styled">
                            <option value=0 <s:if test="portal.mispType==0"> selected="selected"</s:if>><s:text name="portal.label.types.0"/></option>
                            <option value=1 <s:if test="portal.mispType==1"> selected="selected"</s:if>><s:text name="portal.label.types.1"/></option>
<%-- 							<option value=2 <s:if test="portal.mispType==2"> selected="selected"</s:if>><s:text name="portal.label.types.2"/></option> --%>
                            <option value=3 <s:if test="portal.mispType==3"> selected="selected"</s:if>><s:text name="portal.label.types.3"/></option>
                        </select>
                    </s:else>
                </li>
                
				<s:iterator status="stat" value="(#attr['languages'].size()).{ #this }" >
	                <li>
                		<s:set var="language" value = "#attr['languages'].get(#stat.index)"/>
                		<label><s:property value="getText('org.label.name')+' ('+#language.toUpperCase()+')'"/></label>
	                    <s:textfield name="orgNames[%{#stat.index}].description" placeholder="%{getText('placeholder.portal.org_name')}"/>
	                    <s:hidden name="orgNames[%{#stat.index}].id"/>
						<s:fielderror>
						     <s:param><s:property value="'orgNames['+#stat.index+'].description'"/></s:param>
						</s:fielderror>
	                </li>
				</s:iterator>
                
                <li>
                	<label>
                		<span class="<s:property value="'xroad-non-v6' + (portal.v6 ? ' hidden' : '')"/>">
                			<s:property value="getText('org.label.code')"/>
                		</span>
                		<span class="<s:property value="'xroad-v6' + (!portal.v6 ? ' hidden' : '')"/>">
                			<s:property value="getText('org.label.xroad_member_code')"/>
                		</span>
                	</label>
                    
                    <s:if test="false && portalId"><%-- Always show editable form --%>
                        <s:property value="%{org.code}"/>
                    </s:if>
                    <s:else>
                        <s:textfield name="org.code" placeholder="%{getText('placeholder.portal.org_code')}"/>
                    </s:else>
                    <s:fielderror fieldName="org.code" />
                </li>
                <li>
                    <s:label key="portal.label.xroad_protocol_ver" />
                    <select name="portal.xroadProtocolVer" id="portalXroadProtocolVer" class="styled">
                     	<option value="<s:property value="@ee.aktors.misp2.util.Const$XROAD_VERSION@V5.protocolVersion"/>" <s:if test='portal.v5'> selected="selected"</s:if>><s:text name="portal.label.xroad_protocol_ver.3.1"/></option>
                        <option value="<s:property value="@ee.aktors.misp2.util.Const$XROAD_VERSION@V6.protocolVersion"/>" <s:if test='portal.v6'> selected="selected"</s:if>><s:text name="portal.label.xroad_protocol_ver.4.0"/></option>
                    </select>
                    <s:fielderror fieldName="portal.xroadProtocolVer" />
                </li>
                
    			<li class="xroad-v6<s:if test='!portal.v6'> hidden</s:if>">
                    <s:label key="org.label.xroad_member_class" />
                    <select name="org.memberClass" id="orgMemberClass" class="styled">
                    	<s:iterator value="@ee.aktors.misp2.util.xroad.XRoadUtil@getMemberClasses()" var="memberClass">
                        	<option value="<s:property value="#memberClass"/>" <s:if test='org.memberClass.equals(#memberClass)'> selected="selected"</s:if>><s:property value="#memberClass"/></option>
                        </s:iterator>
                    </select>
                    <s:fielderror fieldName="org.memberClass" />
                </li>
    			<li class="xroad-v6<s:if test='!portal.v6'> hidden</s:if>">
                    <s:label key="org.label.xroad_subsystem_code" />
                    <s:textfield name="org.subsystemCode" placeholder="%{getText('placeholder.org.subsystem_code')}"/>
                    <s:fielderror fieldName="org.subsystemCode"/>
                </li>
                
                <li>
                    <s:label key="portal.label.security_host" />
                    <s:textfield name="portal.securityHost" value="%{portal.securityHost}" placeholder="%{getText('placeholder.portal.security_uri')}" />
                    <s:fielderror fieldName="portal.securityHost" />
                </li>
                
                <%-- Add service X-Road v6 instances here (federated instances for services)--%> 
                <s:include value="xroadInstances.jsp"/>
                
                <li>
                    <s:label key="portal.label.message_mediator" />
                    <s:textfield name="portal.messageMediator" value="%{portal.messageMediator}" placeholder="%{getText('placeholder.portal.message_mediator')}"
                                 cssClass="long_url"/>
                    <s:fielderror fieldName="portal.messageMediator" />
                </li>
                <li>
                    <s:label key="portal.label.debug" />
                    <select name="portal.debug" class="styled">
                        <option value=0 <s:if test="portal.debug==0"> selected="selected"</s:if>><s:text name="portal.label.debug_types.0"/></option>
                        <option value=1 <s:if test="portal.debug==1"> selected="selected"</s:if>><s:text name="portal.label.debug_types.1"/></option>
                    </select>
                </li>
                <li id="portalLogQueryLi">
                    <s:label key="portal.label.log" />
                    <s:checkbox name="logQuery" cssClass="styled" id="portalLogQuery"/>
                </li>
                <li class="xroad-v6-log<s:if test='!portal.v6 || !portal.logQuery'> hidden</s:if>">
                    <s:label key="portal.label.misp2_xroad_service_member_class" />
                    <select name="portal.misp2XroadServiceMemberClass" id="portalMisp2XroadServiceMemberClass" class="styled">
                    	<s:iterator value="@ee.aktors.misp2.util.xroad.XRoadUtil@getMemberClasses()" var="memberClass">
                        	<option value="<s:property value="#memberClass"/>" <s:if test='portal.misp2XroadServiceMemberClass.equals(#memberClass)'> selected="selected"</s:if>>
                        		<s:property value="#memberClass"/>
                        	</option>
                        </s:iterator>
                    </select>
                    <s:fielderror fieldName="portal.misp2XroadServiceMemberClass" />
                </li>
    			<li class="xroad-v6-log<s:if test='!portal.v6 || !portal.logQuery'> hidden</s:if>">
                    <s:label key="portal.label.misp2_xroad_service_member_code" />
                    <s:textfield name="portal.misp2XroadServiceMemberCode" placeholder="%{getText('placeholder.portal.org_code')}"/>
                    <s:fielderror fieldName="portal.misp2XroadServiceMemberCode"/>
                </li>
    			<li class="xroad-v6-log<s:if test='!portal.v6 || !portal.logQuery'> hidden</s:if>">
                    <s:label key="portal.label.misp2_xroad_service_subsystem_code" />
                    <s:textfield name="portal.misp2XroadServiceSubsystemCode" placeholder="%{getText('placeholder.org.subsystem_code')}"/>
                    <s:fielderror fieldName="portal.misp2XroadServiceSubsystemCode"/>
                </li>
                
                <li>
                    <s:label key="portal.label.use_topics" />
                    <s:checkbox name="useTopics"  cssClass="styled"/>
                </li>
                <li>
                    <s:label key="portal.label.use_xrd_issue" />
                    <s:checkbox name="useXrdIssue"  cssClass="styled"/>
                </li>
                <%-- Auth query for X-Road 4 and 5 --%>
                <li class="universal org xroad-non-v6<s:if test='portal.v6'> hidden</s:if>" <s:if test="portal.mispType!=3 && portal.mispType!=2">style="display:none;"</s:if>>
                    <s:label key="portal.label.universal_auth_query" />
                    <s:textfield name="portal.univAuthQuery"  placeholder="%{getText('placeholder.portal.universal_query')}" value="%{portal.v6 ? '' : portal.univAuthQuery}"/>
                    <s:fielderror fieldName="portal.univAuthQuery" />
                </li>
                <%-- Check query for X-Road 6 --%>
                <li class="universal org xroad-v6<s:if test='!portal.v6'> hidden</s:if>" <s:if test="portal.mispType!=3 && portal.mispType!=2">style="display:none;"</s:if>>
                	<s:label key="portal.label.universal_auth_query" />
                     <select name="portal.univAuthQuery" id="portalUnivAuthQuery" class="styled">
                     	<option value=""> - </option>
                    	<s:iterator value="portal.mispType==2 ? unitQueryConf.orgPortalAuthQueryOptions : unitQueryConf.authQueryOptions" var="authQueryOption">
                        	<option value="<s:property value="#authQueryOption.key"/>" <s:if test='portal.univAuthQuery.equals(#authQueryOption.key)'> selected="selected"</s:if>>
                        		<s:property value="#authQueryOption.value"/>
                        	</option>
                        </s:iterator>
                    </select>
                    <s:fielderror fieldName="portal.univAuthQuery" />
                </li>
                
                <%-- Check query for X-Road 4 and 5 --%>
                <li class="universal xroad-non-v6<s:if test='portal.v6'> hidden</s:if>" <s:if test="portal.mispType!=3">style="display:none;"</s:if>>
                    <s:label key="portal.label.universal_check_query" />
                    <s:textfield name="portal.univCheckQuery"  placeholder="%{getText('placeholder.portal.universal_query')}" value="%{portal.v6 ? '' : portal.univCheckQuery}"/>
                    <s:fielderror fieldName="portal.univCheckQuery" />
                </li>
                <%-- Check query for X-Road 6 --%>
                <li class="universal xroad-v6<s:if test='!portal.v6'> hidden</s:if>" <s:if test="portal.mispType!=3">style="display:none;"</s:if>>
                    <s:label key="portal.label.universal_check_query" />
                     <select name="portal.univCheckQuery" id="portalUnivCheckQuery" class="styled">
                     	<option value=""> - </option>
                    	<s:iterator value="unitQueryConf.checkQueryOptions" var="checkQueryOption">
                        	<option value="<s:property value="#checkQueryOption.key"/>" <s:if test='portal.univCheckQuery.equals(#checkQueryOption.key)'> selected="selected"</s:if>>
                        		<s:property value="#checkQueryOption.value"/>
                        	</option>
                        </s:iterator>
                    </select>
                    <s:fielderror fieldName="portal.univCheckQuery" />
                </li>
                <li class="universal" <s:if test="portal.mispType!=3">style="display:none;"</s:if>>
                    <s:label key="portal.label.universal_check_valid_time" />
                    <s:textfield name="portal.univCheckValidTime" cssClass="numberField"  placeholder="%{getText('placeholder.portal.universal_query_time')}"/>
                    <s:fielderror fieldName="portal.univCheckValidTime" />
                </li>
                <li class="universal" <s:if test="portal.mispType!=3">style="display:none;"</s:if>>
                    <s:label key="portal.label.universal_check_max_valid_time" />
                    <s:textfield name="portal.univCheckMaxValidTime" cssClass="numberField"  placeholder="%{getText('placeholder.portal.universal_query_time')}"/>
                    <s:fielderror fieldName="portal.univCheckMaxValidTime" />
                </li>
                <li class="universal" <s:if test="portal.mispType!=3">style="display:none;"</s:if>>
                    <s:label key="portal.label.unit_is_consumer" />
                    <span id="spanUnitIsConsumer">
	                    <s:if test="portalId"> 
	                        <s:checkbox name="unitIsConsumer" value="unitIsConsumer" id="isConsumer" cssClass="styled" disabled="true"/>
	                        <s:hidden name="unitIsConsumer"/>
	                    </s:if>
	                    <s:else>
	                        <input type="checkbox" name="unitIsConsumer" id="isConsumer"  class="styled" />
	                    </s:else>
                    </span>
                </li>
                <li class="universal" id="liRegUnit" <s:if test="portal.mispType!=3 || portal.unitIsConsumer">style="display:none;"</s:if>>
                    <s:label key="portal.label.register_units" />
                    <s:checkbox name="registerUnits" id="regUnit"  cssClass="styled"/>
                </li>
                <li class="universal org" <s:if test="portal.mispType!=3 && portal.mispType!=2">style="display:none;"</s:if>>
                    <s:label key="portal.label.universal_use_manager" />
                    <s:checkbox name="univUseManger" cssClass="styled"/>
                </li>
                
                <li>
                    <s:label key="portal.label.use_eula" />
                    <s:checkbox name="useEula" cssClass="styled"/>
                </li>
                <s:iterator status="stat" value="(#attr['languages'].size()).{ #this }" >
	                <li class="eula-content" <s:if test="!useEula">style="display:none;"</s:if>>
                		<s:set var="language" value = "#attr['languages'].get(#stat.index)"/>
                		<label><s:property value="getText('portal.label.eula_content')+' ('+#language.toUpperCase()+')'"/></label>
	                    <s:textarea name="portalEulas[%{#stat.index}].content" 
	                    	placeholder="%{getText('portal.placeholder.eula_content')}"
	                    	title="%{getText('portal.title.eula_content')}"/>
	                    <s:hidden name="portalEulas[%{#stat.index}].id"/>
						<s:fielderror>
						     <s:param><s:property value="'portalEulas['+#stat.index+'].content'"/></s:param>
						</s:fielderror>
	                </li>
				</s:iterator>
            </ul>
        </fieldset>
        <s:submit name="btnSubmit" key="label.button.save_portal_conf" cssClass="button regular_btn"/>
        <s:if test="portal.id">
            <s:a id="btnDel" name="btnDelete" href="%{remove}" data-confirmable-post-link="%{getText('text.confirm.delete')}" cssClass="button delete_btn">
            	<s:text name="portals.remove"/>
            </s:a>
        </s:if>
        <hr/>
        <s:if test="portal.id">
            <s:if test="managers.size>0">

                <h3><s:text name="managers.filter.found"/>:</h3>
                <table class="list selection">
                    <s:iterator value="managers" var="res">
                        <tr>
                            <td>
                                <s:url var="show_user_link" action="addManager">
                                    <s:param name="userId" value="#res.id"/>
                                </s:url>
                                <s:a href="%{show_user_link}"><s:property value="%{#res.fullNameSsnParenthesis}"/></s:a>
                            </td>
                            <td class="modify">
                                <s:url var="removeManager" action="managerDelete">
                                    <s:param name="userId" value="#res.id"/>
                                </s:url>
                                <s:a href="%{removeManager}" data-confirmable-post-link="%{getText('text.confirm.delete')}" cssClass="button delete_btn" cssStyle="margin:2px 2px 2px 2px !important">
                                	<s:text name="managers.remove"/>
                                </s:a>
                            </td>
                        </tr>
                    </s:iterator>
                </table>
            </s:if>

            <s:a cssClass="button regular_btn" action="addManager"><s:text name="label.button.add_new_manager"/></s:a>
        </s:if>
    </s:form>
</div>

<script type="text/javascript">
$(document).ready(function() {
	$("#spanUnitIsConsumer").click(function() {
		var c = $('#isConsumer').is(':checked');
		if(c){
			$('#regUnit').val(false);
			$('#liRegUnit').css('display', 'none');
		}
		else{	
			$('#liRegUnit').css('display', '');
		}
		$('#isConsumer').val(c);
	})
})
</script>
