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

<script type="text/javascript">
$(document).ready(function() {
	$("#register-me").css({'margin' : '0'});
});
</script>

<div class="contentbox">
    <h3><s:text name="manager.user_list"/> (<s:property value="activeOrg.getActiveName(locale.language)"/>):</h3>

    <s:if test="%{managerList!=null && managerList.size>0}">
        <table class="list">
            <s:iterator value="managerList" status="rowstatus">
                <tr>
                    <td>
                        <s:property value="fullNameSsnParenthesis"/>
                    </td>
                    <td class="modify">
                        <s:url var="url" action="removeUnitUser">
                            <s:param name="userId" value="id" />
                        </s:url>
                        <s:a cssClass="small" href="%{url}" data-confirmable-post-link="">
                        	<img src="resources/<s:property value="subPortal"/>/images/delete.png" alt="<s:text name="manager.remove_unit_user"/>" width="20" height="20"/>
                        </s:a>
                    </td>
                </tr>
            </s:iterator>
        </table>
    </s:if>
    <s:else>
        <h5><s:text name="users.register.no_managers"/></h5>
    </s:else>

</div>
<div class="contentbox">

    <h3><s:text name="manager.filter.condition.unit_users"/>:</h3>
    <s:form id="usersFilter" action="userRegisterUnitFilter" method="get" theme="simple">
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="users.filter.label.ssn"/>
                    <%--
                    <s:text var="allCtrys" name="countrylist.all"/>
                    <s:select id="ssnCountry1" list="countryList" listValue="ISO3Country"
                              listKey="country" headerKey="" headerValue="%{#allCtrys}"
                              name="filterCountryCode" cssClass="styled"/>
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
            <h3><s:text name="manager.filter.found_unit_user"/>:</h3>
            <table class="list selection">
                <s:iterator value="searchResults" var="res">
                    <tr>
                        <td>
                            <s:url var="show_addUnitUser_link" action="addUnitUser">
                                <s:param name="userId" value="#res.id"/>
                            </s:url>
                            <s:a href="%{show_addUnitUser_link}" data-confirmable-post-link=""><s:property value="fullNameSsnParenthesis"/></s:a>
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
    <h3><s:text name="manager.label.add_new_unit_user"/></h3>

    <s:form action="userSubmit" theme="simple" id="show_user">
        <s:hidden name="permissionRoles" value="1"/>
        <s:hidden name="redirectAction" value="registerUser"/>
        <s:hidden name="resetAllGroups" value="true"/>
        <fieldset>
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
        </fieldset>
        <s:submit name="btnSubmit" key="label.button.add_new" cssClass="button regular_btn"/>
        <h3 style="padding-top: 30px"><s:text name="user.register_me_header"/></h3>
        <s:a id="register-me" action="addUnitUser" data-confirmable-post-link="" cssClass="button secondary">
            <s:text name="user.register_me"/>
            <s:param name="userId" value="#session.SESSION_USER_HANDLE.id"/>
        </s:a>
    </s:form>
</div>