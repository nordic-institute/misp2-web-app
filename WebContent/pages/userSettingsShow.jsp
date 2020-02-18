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

<style type="text/css">
    .contentbox form label {
        width:300px;
    }
</style>
<script type="text/javascript">
    $(document).ready(function(){
        $("#email_setting").mouseout(function(){
            $(this).change();
        })
        $("#email").change(function() {
            if($(this).val()=="") {
                $("#notifyChanges").attr("disabled", "disabled");
            }else {
                $("#notifyChanges").removeAttr("disabled");
            }
        })
        $("#email").change();
        
        //Only apply password updating functionality if appropriate fields exist
        if($("form#show_user_settings input.updatePasswordField").length > 0){
        	showOrHideUpdatePasswordFields();
        	
            $("form#show_user_settings input[type='checkbox'][name='updatePassword']").change(function(){
            	showOrHideUpdatePasswordFields();
            });
            
            function showOrHideUpdatePasswordFields(){
            	var showOrHide = $("form#show_user_settings input[type='checkbox'][name='updatePassword']").prop("checked");
            	
            	$("form#show_user_settings input[type='password'].updatePasswordField").parent("li").each(function(){
            		$(this).css("display", showOrHide ? "list-item" : "none");
            	});
            	
            	if(showOrHide==false){
            		$("form#show_user_settings input[type='password'].updatePasswordField").val("");
            	}
            }
        }
    })
</script>
<div class="contentbox" >
    <s:form action="saveUserAccount" id="show_user_settings" theme="simple">
        <ul class="form">
			<li>
				<s:label key="users.show.label.ssn"/>
				<s:property value="person.ssn"/>
	        </li>
			<li>
	            <s:label key="users.show.label.givenname"/>
	            <s:if test="person.givenname != null">
	            	<s:property value="person.givenname" />
	            </s:if>
	        </li>
	        <li>
	            <s:label key="users.show.label.surname"/>
	            <s:if test="person.surname != null">
	            	<s:property value="person.surname" />
	            </s:if>
	        </li>
			<s:if test="%{config.getProperty('auth.password')}">
                <li>
                    <s:label key="change.password.update" for="updatePassword"/>
                    <!-- Should use "style" class on checkbox in order to prettify it, but can't, because then "change" event does not work -->
                    <s:checkbox name="updatePassword" cssClass="updatePasswordField"/>
                    <s:fielderror fieldName="updatePassword"/>
                </li>
				<li>
                    <s:label key="change.password.old_password" for="oldPassword"/>
                    <s:password name="oldPassword" cssClass="updatePasswordField formField"/>
                    <s:fielderror fieldName="oldPassword"/>
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
            <li>
                <s:label for="email" key="users.show.label.mail"/>
                <s:textfield name="email" id="email_setting" placeholder="%{getText('placeholder.person_mail')}"/>
                <s:fielderror fieldName="email"/>
            </li>			
            <s:if test="#session.SESSION_PORTAL.mispType != 0">
                <li>
                    <s:label for="notifyChanges" key="users.show.label.notify"/>
                    <s:checkbox name="notifyChanges" id="notifyChanges" cssClass="styled"/>
                    <s:fielderror fieldName="notifyChanges"/>
                </li>
            </s:if>
        </ul>
        <s:submit name="btnSubmit" key="label.button.save" cssClass="button regular_btn"/>
    </s:form>
</div>
