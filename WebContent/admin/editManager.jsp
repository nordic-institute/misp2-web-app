<%@page  pageEncoding="UTF-8"%>
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

<s:url action="userDeleteAdmin" var="delUrl" escapeAmp="false">
    <s:param name="userId" value="%{userId}"/>
    <s:param name="orgId" value="%{org.id}"/>
</s:url>

<s:url action="userGenCodeAdmin" var="genCodeUrl" escapeAmp="false">
    <s:param name="userId" value="%{userId}"/>
</s:url>
<s:url var="showPortal" action="showPortal">
	<s:param name="portalId" value="portal.id"/>
</s:url>

<script type="text/javascript">
    $(document).ready(function( ){
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
    })
</script>
<style type="text/css">
    .contentbox form label {
        width:300px;
    }
</style>
<s:if test="userId==null">
    <div class="contentbox">
	<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toPortalShow')}"  href="%{showPortal}"><s:text name="help.back.label"/></s:a>
        <h3><s:text name="managers_search_all_users"/></h3>
        <s:form id="usersFilter" action="usersFilterAdmin" method="get" theme="simple">

            <ul class="form">
                <li>
                	<s:label key="users.filter.label.country"/>
                    <s:text var="allCtrys" name="countrylist.all"/>
                    <s:select id="ssnCountry" name="filterCountryCode"
                                  cssClass="styled" list="countryList" headerKey="" headerValue="%{#allCtrys}" listValue="ISO3Country" listKey="country" disabled="false"/>
                </li>
                <li>
                	<s:label key="users.filter.label.ssn"/>
                    <s:fielderror fieldName="filterSSN"/>
                    <s:textfield name="filterSSN"/>
                </li>
                <li>
                    <s:label key="users.filter.label.givenname"/>
                    <s:fielderror fieldName="filterGivenName"/>
                    <s:textfield name="filterGivenName"/>
                </li>
                <li>
                    <s:label key="users.filter.label.surname"/>
                    <s:fielderror fieldName="filterSurname"/>
                    <s:textfield name="filterSurname"/>
                </li>

                <li>
                    <s:submit name="submit" key="label.button.search" cssClass="button regular_btn"/>
                </li>
            </ul>
        </s:form>
        <hr />

        <s:if test="searchResults.size > 0">
            <h5><s:text name="users.filter.found"/>:</h5>
            <table class="list selection">
                <s:iterator value="searchResults" var="res">
                    <tr>
                        <td>
                            <s:url var="show_user_link" action="addManager">
                                <s:param name="userId" value="#res.id"/>
                            </s:url>
                            <s:a href="%{show_user_link}"><s:property value="%{#res.fullNameSsnParenthesis}"/></s:a>
                        </td>
                        <td class="modify">
                            <s:url var="show_user_link" action="saveManager">
                                <s:param name="userId" value="#res.id"/>
                            </s:url>
                            <s:a href="%{show_user_link}" data-confirmable-post-link="" cssClass="button regular_btn" cssStyle="margin:2px 2px 2px 2px !important">
                            	<s:text name="managers.add_manager"/>
                            </s:a>
                        </td>
                    </tr>
                </s:iterator>
            </table>
        </s:if>
    </div>
</s:if>

<div class="contentbox">

	<s:if test="userId!=null">
		<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toPortalShow')}"  href="%{showPortal}"><s:text name="help.back.label"/></s:a>
	</s:if>
    <s:if test="userId==null">
        <h3><s:text name="managers.add_new"/></h3>
    </s:if>
    <s:else>
        <h3><s:text name="managers.edit"/></h3>
    </s:else>

    <s:form theme="simple" id="show_user">
        <s:hidden name="userId"/>
        <s:hidden name="orgId" value="%{org.id}"/>
        <ul class="form">
            <li>
                <s:label key="users.filter.label.ssn"/>
                <s:if test="userId==null">
                	<s:select id="ssnCountry" name="countryCode"
                                  cssClass="styled" list="countryList" listValue="ISO3Country" listKey="country" disabled="false"/>
                    <s:textfield name="ssn" />
               	</s:if>
                <s:else>
					<s:select id="ssnCountry" list="countryList"
                                 listValue="ISO3Country" listKey="country"
                                 name="countryCode" cssClass="styled"
                                 disabled="true"/>
                    <span class="styled">
                    	<s:textfield value="%{ssn}" disabled="true"/>
                    </span>
                        
                	<s:hidden name="ssn"/>
                </s:else>
                <s:fielderror fieldName="ssn"/>
            </li>
            <li>
                <s:label key="users.show.label.givenname" for="person.givenname"/>
                <s:textfield name="person.givenname"/>
                <s:fielderror fieldName="person.givenname"/>
            </li>
            <li>
                <s:label key="users.show.label.surname" for="person.surname"/>
                <s:textfield name="person.surname"/>
                <s:fielderror fieldName="person.surname"/>
            </li>
            <li>
                <s:label key="users.show.label.mail" for="personMailOrg.mail"/>
                <s:textfield name="personMailOrg.mail"/>
                <s:fielderror fieldName="personMailOrg.mail"/>
            </li>
            <li>
                <s:label key="users.show.label.profession" for="orgPerson.profession"/>
                <s:textfield name="orgPerson.profession"/>
                <s:fielderror fieldName="orgPerson.profession"/>
            </li>
			<s:if test="%{config.getProperty('auth.password')}">
                <li>
                	<s:if test="%{userId}">
                    	<s:label key="change.password.update" for="updatePassword"/>
                	</s:if>
                	<s:else>
                    	<s:label key="change.password.create" for="updatePassword"/>
                	</s:else>
                    <!-- Should use "style" class on checkbox in order to prettify it, 
                    	but can't, because then "change" event does not work;
                    	By default, checkbox is 
                    	- checked if userId does not exist (user not created yet, password needs to be added),
                    	- unchecked if user has been created already. -->
                    <s:checkbox name="updatePassword" cssClass="updatePasswordField" value="%{updatePassword || !userId}"/>
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
        <s:if test="userId!=null">
            <s:submit action="saveUserAdmin" key="managers.save_person"  cssClass="button regular_btn"/>
        	<s:submit action="saveManager" key="managers.add" cssClass="button regular_btn"/>
        </s:if>
        <s:else>
        	<s:submit action="saveUserAdmin" key="managers.add_person"  cssClass="button regular_btn"/>
        	<s:submit action="saveManager" key="managers.add_person_manager" cssClass="button regular_btn"/>
        </s:else>
        <s:if test="userId!=null">
         	<s:if test="%{config.getProperty('auth.certificate')}">
                <button id="btnGenCode" type="button" name="btnGenerateCode" class="regular_btn"><s:text name="label.button.generateCode"/></button>
            </s:if>
            <s:url var="removeManager" action="managerDelete">
            	<s:param name="userId" value="%{userId}"/>
            </s:url>
            <br/>
            <s:if test="orgPerson.personId != null">
            	<s:a href="%{removeManager}" data-confirmable-post-link="%{getText('text.confirm.delete')}" cssClass="button delete_btn" cssStyle="margin-bottom:0em">
            		<s:text name="managers.remove"/>
            	</s:a>
            </s:if>   
            <s:a id="btnDel" name="btnDelete" href="%{delUrl}" data-confirmable-post-link="%{getText('text.confirm.delete')}" cssClass="button delete_btn">
            	<s:text name="user.remove_data"/>
            </s:a>
        </s:if>       
        
    </s:form>
</div>
<s:if test="generatedOvertakeCode!=null">
    <div class="contentbox">
        <s:text name="text.new_overtake_code"/> &nbsp;<s:property value="generatedOvertakeCode"/>
    </div>
</s:if>