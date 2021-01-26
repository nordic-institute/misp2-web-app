<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page pageEncoding="UTF-8" %>

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
    .small {
        font-size: small
    }
</style>
<script type="text/javascript">
$(document).ready(function() {
	$("#register-me").css({'margin' : '0'});
});
</script>

<div class="contentbox">
    <h3><s:text name="manager.list"/> (<s:property value="activeOrg.getActiveName(locale.language)"/>):</h3>
    <s:if test="%{managerList!=null && managerList.size>0}">
        <table class="list">
            <s:iterator value="managerList" status="rowstatus">
                <tr>
                    <td>
                        <s:property value="fullNameSsnParenthesis"/>
                    </td>
                    <td class="modify">
                        <s:if test="%{!registerUnknown}">
                            <s:url var="url" action="removeUnitManager">
                                <s:param name="userId" value="id" />
                            </s:url>
                            <s:a cssClass="small" href="%{url}" data-confirmable-post-link="">
                            	<img src="resources/<s:property value="subPortal"/>/images/delete.png" alt="<s:text name="manager.remove"/>" width="20" height="20"/>
                            </s:a>
                        </s:if>
                    </td>
                </tr>
            </s:iterator>
        </table>
    </s:if>
    <s:else>
        <h5><s:text name="manager.register.no_managers"/></h5>
    </s:else>
    <hr />
    <s:if test="registerUnknown">
        <h3><s:text name="manager.candidates.list"/> (<s:property value="activeOrg.getActiveName(locale.language)"/>):</h3>
        <s:if test="managerCandidatesList!=null">
            <s:if test="managerCandidatesList.size>0">
                <table class="list small" >
                    <tr>
                        <th><s:text name="manager.candidates.name"/></th>
                        <th><s:text name="manager.candidates.required"/></th>
                        <th><s:text name="manager.candidates.approved"/></th>
                        <th></th>
                        <th></th>
                    </tr>
                    <s:iterator value="managerCandidatesList" var="mgrCand">
                        <tr>
                            <td>
                                <s:property value="%{#mgrCand.candidate.fullNameSsnParenthesis}" />
                            </td>
                            <td>
                                <s:iterator value="%{#mgrCand.confirmationRequired}" var="cfReq">
                                    <s:property value="%{#cfReq.fullNameSsnParenthesis}"/><br />
                                </s:iterator>
                            </td>
                            <td>
                                <s:iterator value="%{#mgrCand.confirmationGiven}" var="cfGvn">
                                    <s:property value="%{#cfGvn.fullNameSsnParenthesis}"/><br />
                                </s:iterator>
                            </td>
                            <td class="modify">
                                <s:url action="addManagerCandidate" var="addMgrCand" >
                                    <s:param name="userId" value="%{#mgrCand.candidate.id}"/>
                                </s:url>
                                <s:a href="%{#addMgrCand}" data-confirmable-post-link=""><s:text name="manager.candidates.approve"/></s:a>
                            </td>
                            <td class="modify">
                                <s:url action="removeManagerCandidate" var="remMgrCand">
                                    <s:param name="userId" value="%{#mgrCand.candidate.id}"/>
                                </s:url>
                                <s:a href="%{#remMgrCand}" data-confirmable-post-link=""><s:text name="manager.candidates.disapprove"/></s:a>
                            </td>
                        </tr>
                    </s:iterator>
                </table>
            </s:if>
        </s:if>
    </s:if>
</div>
<div class="contentbox">
    <h3><s:text name="manager.filter.condition"/>:</h3>

    <s:if test="%{registerUnknown}">
        <s:set var="usersFilterAct" value="%{'managerRegisterUnitUKFilter'}" />
    </s:if>
    <s:else>
        <s:set var="usersFilterAct" value="%{'managerRegisterUnitFilter'}" />
    </s:else>
    <s:form id="usersFilter" action="%{#usersFilterAct}" method="get" theme="simple">
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="users.filter.label.ssn"/>
                    <%--<s:text var="allCtrys" name="countrylist.all"/>
                    <s:select id="ssnCountry1" list="countryList"
                              listValue="ISO3Country" listKey="country" headerKey=""
                              headerValue="%{#allCtrys}" name="filterCountryCode"
                              cssClass="styled"/>
                    --%>
                    <s:iterator value="countryList" var="ci">
                        <s:if test="country==countryCode">
                            <s:textfield value="%{ISO3Country}" disabled="true"/>
                            <s:hidden name="filterCountryCode" value="%{country}"/>
                        </s:if>
                    </s:iterator>
                    <span class="styled">
                        <s:textfield name="filterSSN"/>
                    </span>
                    <s:fielderror fieldName="filterSSN"/>
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
            </ul>
        </fieldset>
        <s:submit name="submit" key="label.button.search" cssClass="button regular_btn"/>
    </s:form>

    <s:if  test="searchResults!=null">
        <hr />
        <s:if test="searchResults.size > 0">
            <h5><s:text name="manager.filter.found"/>:</h5>
            <table class="list selection">
                <s:iterator value="searchResults" var="res">
                    <tr>
                        <td>
                            <s:if test="%{registerUnknown}">
                                <s:url action="addManagerCandidate" var="show_addUnitManager_link" >
                                    <s:param name="userId" value="#res.id"/>
                                </s:url>
                            </s:if>
                            <s:else>
                                <s:url action="addUnitManager" var="show_addUnitManager_link" >
                                    <s:param name="userId" value="#res.id"/>
                                </s:url>
                            </s:else>
                            <s:a href="%{show_addUnitManager_link}" data-confirmable-post-link=""><s:property value="fullNameSsnParenthesis"/></s:a>
                        </td>
                    </tr>
                </s:iterator>
            </table>
        </s:if>
        <s:else>
            <h5><s:text name="text.search.no_results"/></h5>
        </s:else>
    </s:if>
</div>
<div class="contentbox">
    <h3><s:text name="manager.label.add_new"/></h3>
    <fieldset>
        <s:form action="userSubmit" theme="simple" id="show_user">
            <s:if test="%{registerUnknown}">
                <s:hidden name="redirectAction" value="addManagerCandidate"/>
            </s:if>
            <s:else>
                <s:hidden name="permissionRoles" value="2"/>
                <s:hidden name="redirectAction" value="registerManager"/>
                <s:hidden name="resetAllGroups" value="true"/>
            </s:else>

            <ul class="form">
                <li>
                    <s:label key="users.filter.label.ssn"/>
                    <s:iterator value="countryList" var="ci">
                        <s:if test="country==countryCode">
                            <s:textfield value="%{ISO3Country}" disabled="true"/>
                            <s:hidden name="countryCode" value="%{country}"/>
                        </s:if>
                    </s:iterator>
                    <s:textfield name="ssn" />
                    <s:fielderror fieldName="ssn"/>
                </li>
                <li>
                    <s:label key="users.filter.label.givenname"/>
                    <s:textfield name="person.givenname"/>
                    <s:fielderror fieldName="person.givenname"/>
                </li>
                <li>
                    <s:label key="users.filter.label.surname"/>
                    <s:textfield name="person.surname"/>
                    <s:fielderror fieldName="person.surname"/>
                </li>
            </ul>
            <s:submit name="btnSubmit" key="label.button.add_new_manager" cssClass="button regular_btn"/>

            <s:if test="%{registerUnknown}">
                <s:url action="addManagerCandidate" var="addMeUrl">
                    <s:param name="userId" value="#session.SESSION_USER_HANDLE.id"/>
                </s:url>
            </s:if>
            <s:else>
                <s:url action="addUnitManager" var="addMeUrl">
                    <s:param name="userId" value="#session.SESSION_USER_HANDLE.id"/>
                </s:url>
            </s:else>
            <h3 style="padding-top: 30px"><s:text name="user.register_me_header"/></h3>
            <s:a id="register-me" href="%{addMeUrl}" data-confirmable-post-link="" cssClass="button secondary"><s:text name="manager.register_me"/></s:a>
        </s:form>
    </fieldset>
</div>