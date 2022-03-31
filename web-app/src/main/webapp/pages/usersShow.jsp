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

<s:url action="userDelete" var="delUrl" escapeAmp="false">
    <s:param name="userId" value="%{userId}"/>
</s:url>

<s:url action="userGenCode" var="genCodeUrl" escapeAmp="false">
    <s:param name="userId" value="%{userId}"/>
</s:url>


<script type="text/javascript">
    $(document).ready(function() {
    	$.datepicker.setDefaults( $.datepicker.regional['<s:property value="locale"/>'] );
        
        $("[id^='userGroups_valid_']").datepicker({
            minDate:0,
            changeMonth: true,
            changeYear: true
        },$.datepicker.regional['<s:property value="locale"/>']);

        $("fieldset.groups span.checkbox[id^='span_']").live('click', function() {           
            var val = $(this).attr("id").substring("span_".length)
            var ob = $("#userGroups_valid_"+val);
            var checked = $("#userGroups_check_"+val).attr("checked")
            if(checked) {
                ob.removeAttr("disabled").focus();
            } else {
                ob.attr("disabled", "disabled");
            }
        });
        
        $("#show_user_orgPerson_role").change(function() {
            if($(this).val()<0) { // no role
                $("#show_user_orgPerson_profession").attr("disabled", "disabled");
                $('#userGroupsTable input').attr("disabled", "disabled");
            }else {
                $("#show_user_orgPerson_profession").removeAttr("disabled")
                $('#userGroupsTable input[id^="userGroups_check_"]').removeAttr("disabled")
                $('#userGroupsTable input[id^="userGroups_check_"]:checked').each(function(){
                    var val = $(this).attr("value");
                    $('#userGroupsTable input[id^="userGroups_valid_'+val+'"]').removeAttr("disabled")
                });
            }
        });
        $("#show_user_orgPerson_role").change();
        
        $("#btnGenCode").click(function() {
            Utils.postURL('<s:property escapeHtml="false" value="genCodeUrl"/>');
        });
        
        //Only apply password updating functionality if appropriate fields exist
        if($("form#show_user input.updatePasswordField").length > 0){
        	showOrHideUpdatePasswordFields();
        	
            $("form#show_user input[type='checkbox'][name='updatePassword']").change(function(){
            	showOrHideUpdatePasswordFields();
            });
            
            function showOrHideUpdatePasswordFields(){
            	var showOrHide = $("form#show_user input[type='checkbox'][name='updatePassword']").prop("checked");
            	
            	$("form#show_user input[type='password'].updatePasswordField").parent("li").each(function(){
            		$(this).css("display", showOrHide ? "list-item" : "none");
            	});
            	
            	if(showOrHide==false){
            		$("form#show_user input[type='password'].updatePasswordField").val("");
            	}
            }
        }
        
        //Position usergroup validDate title into same alignment as validDate field (If they exist in DOM)
        if($("fieldset.groups #usergroupValidDateTitle").length > 0){
        	var usergroupValidDateTitle$ = $("fieldset.groups #usergroupValidDateTitle");
           	var usergroupTextfield$ = $("fieldset.groups ul li:first input[type='text']");
           	var usergroupValidDateTitleOffsetDifference = usergroupTextfield$.offset().left - usergroupValidDateTitle$.offset().left;
           	usergroupValidDateTitleOffsetDifference +=26;//For some mystical reason offset difference is wrong, so must brute force fix it
           	usergroupValidDateTitle$.css({marginLeft : "+="+usergroupValidDateTitleOffsetDifference+"px"});      	
        }
    });
</script>

<div class="contentbox">
	<s:url var="listUsers" action="usersFilter"/>
	<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toUsersList')}"  href="%{listUsers}"><s:text name="help.back.label"/></s:a>

    <s:form action="userSubmit" theme="simple" id="show_user">
        <h3><s:text name="users.show.header"/></h3>
        <s:hidden name="person.id"/>
        <s:hidden name="orgPerson.id"/>
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="users.show.label.ssn" for="ssn"/>
                    <s:if test="countryList!=null && countryList.size>0 && userId==null">
                        <s:select id="ssnCountry" name="countryCode" 
                                  cssClass="styled" list="countryList" listValue="ISO3Country" listKey="country"  />
                    </s:if>
                    <s:if test="userId!=null">
						<s:select id="ssnCountry" list="countryList"
                                  listValue="ISO3Country" listKey="country"
                                  name="countryCode" cssClass="styled"
                                  disabled="true"/>
                        <span class="styled">
                            <s:textfield value="%{ssn}" disabled="true"/>
                        </span>                        
                        <s:hidden name="ssn"/>
                        <s:hidden name="countryCode"/>
                    </s:if>
                    <s:else>
                        <s:textfield name="ssn" placeholder="%{getText('placeholder.person_ssn')}" />
                    </s:else>
                    <s:fielderror fieldName="ssn" id="ssn"/>
                </li>
                <li>
                    <s:label key="users.show.label.givenname" for="person.givenname"/>
                    <s:textfield name="person.givenname" />
                    <s:fielderror fieldName="person.givenname"/>
                </li>
                <li>
                    <s:label key="users.show.label.surname" for="person.surname"/>
                    <s:textfield name="person.surname" />
                    <s:fielderror fieldName="person.surname"/>
                </li>
                <li>
                    <s:label key="users.show.label.mail" for="mail"/>
                    <s:textfield name="mail" placeholder="%{getText('placeholder.person_mail')}"/>
                    <s:fielderror fieldName="mail"/>
                </li>
                <li>
                    <s:label key="users.show.label.roles" for="role"/>
                    <s:fielderror fieldName="permissionRoles"/>

                    <ul class="checkbox_list">
                    	<s:iterator value="allRoles" status="stat">
                            <li>
                                <s:set value="%{permissionRoles.contains(key)}" var="isChecked"/>
                                <s:if test="%{key==8}"><!-- cannot change portal manager role, only administrator can change portal manager -->
                                    <s:if test="%{#isChecked}">
                                        <s:hidden name="permissionRoles" value="%{key}" />
                                        <s:hidden name="__checkbox_permissionRoles" value="%{key}" />
                                    </s:if>
                                    <s:checkbox id="role_%{key}" name="permissionRoles" fieldValue="%{key}" value="%{#isChecked}" disabled="true" cssClass="styled"/>
                                </s:if>
                                <s:else>
                                    <s:checkbox id="role_%{key}" name="permissionRoles" fieldValue="%{key}" value="%{#isChecked}" cssClass="styled"/>
                                </s:else>
                                <s:label value="%{value}" for="role_%{key}"/>
                            </li>
                        </s:iterator>
                    </ul>
                </li>
                <li>
                    <s:label key="users.show.label.profession" for="orgPerson.profession"/>
                    <s:textfield name="orgPerson.profession" cssClass="formField" placeholder="%{getText('placeholder.person_profession')}"/>
                    <s:fielderror fieldName="orgPerson.profession"/>
                </li>
				<s:if test="%{config.getProperty('auth.password')}">
	                <li>
	                    <s:label key="change.password.update" for="updatePassword"/>
	                    <!-- Should use "style" class on checkbox in order to prettify it, but can't, because then "change" event does not work -->
	                    <s:checkbox name="updatePassword" cssClass="updatePasswordField"/>
	                    <s:fielderror fieldName="updatePassword"/>
	                </li>					
					<li>
	                    <s:label key="change.password.new_password" for="newPassword"/>
	                    <s:password name="newPassword" cssClass="updatePasswordField formField"/>
	                    <s:fielderror fieldName="newPassword"/>
					</li>
					<li>
	                    <s:label key="change.password.retype_new_password" for="confirmNewPassword"/>
	                    <s:password name="confirmNewPassword" cssClass="updatePasswordField formField"/>
	                    <s:fielderror fieldName="confirmNewPassword"/>
					</li>
				</s:if>
            </ul>
        </fieldset>

        <hr />
        <fieldset class="groups">
            <s:if test="allGroups.size()>0">
                <h3><s:text name="users.show.label.usergroups"/></h3>
                <s:submit name="btnSubmit" key="label.button.save" cssClass="button regular_btn"/>
                <br/>
                <span id="usergroupValidDateTitle"><s:text name="users.show.label.usergroups.validDate"/></span>
                <ul class="form">
                    <s:iterator value="allGroups" var="g" status="rowstat">
                        <li>
                            <s:label value="%{#g.name}"/>
                            <s:set value="%{userGroups.contains(#g.id)}" var="isChecked"/>
                            <s:checkbox name="userGroups" fieldValue="%{#g.id}" value="%{#isChecked}"
                                        id="userGroups_check_%{#g.id}"  cssClass="styled"/>

                            <s:text name="%{'dateformat'}" var="format"/>

                            <s:if test="%{userGroupsValid[#g.id]!=null}">
                                <s:date name="%{userGroupsValid[#g.id]}" var="validDateId" format="%{#format}"/>
                            </s:if>
                            <s:elseif test="%{userGroupsVret[#g.id]!=null}">
                                <s:date var="validDateId" name="%{userGroupsVret[#g.id]}" format="%{#format}"/>
                            </s:elseif>
                            <s:else>
                                <s:set var="validDateId" value="null"/>
                            </s:else>
                            <s:if test="%{#isChecked}">
                                <s:textfield id="userGroups_valid_%{#g.id}" name="userGroupsVret[%{#g.id}]"
                                             value="%{validDateId}" readonly="true" cssClass="dateField"/>
                            </s:if>
                            <s:else>
                                <s:textfield id="userGroups_valid_%{#g.id}" name="userGroupsVret[%{#g.id}]"
                                             value="%{validDateId}" disabled="true" cssClass="dateField"/>
                            </s:else>
                        </li>
                    </s:iterator>

                </ul>
            </s:if>
        </fieldset>
        <s:submit name="btnSubmit" key="label.button.save" cssClass="button regular_btn"/>
        <s:if test="userId!=null">
            <s:a id="btnDel" name="btnDelete" href="%{delUrl}" data-confirmable-post-link="%{getText('text.confirm.delete')}" cssClass="button delete_btn">
                <s:text name="label.button.delete"/>
            </s:a>
             <s:if test="%{config.getProperty('auth.certificate')}">
            	<button id="btnGenCode" type="button" name="btnGenerateCode"><s:text name="label.button.generateCode"/></button>
            </s:if>
        </s:if>
    </s:form>
</div>

<s:if test="generatedOvertakeCode!=null">
    <div class="contentbox">
        <s:text name="text.new_overtake_code"/> &nbsp;<s:property value="generatedOvertakeCode"/>
    </div>
</s:if>