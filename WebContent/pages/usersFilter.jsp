<%@page  pageEncoding="UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags"%>

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

<script type="text/javascript">
    $(document).ready(function() {
        $(".toggleChild").toggle();
        $('.toggle').click(function() {
            var cl = $(this).attr("class").split(" ");
            var output = "";
            if (cl.length > 1) {
                output = cl[1];
            }
            $(".t" + output).toggle();
        });
    });
</script>
<s:if test="#session.SESSION_USER_ROLE != @ee.aktors.misp2.util.Roles@PORTAL_MANAGER">
<script type="text/javascript">
    $(document).ready(function() {
        $("#isAllUsers").mousedown(function() {
            toggleAll();
        });
        $("#isAllUsers").mouseup(function() {
            toggleAll();
        });
        if('<s:if test="filterAllUsers">true</s:if>' == 'true') {
            toggleDisabled();
        };
    });
    
    function toggleAll() {
        var pos = $("#span_true").css("background-position");
        if(pos == "0px 0px") {
            toggleEnabled();
        } else {
            toggleDisabled();
        }
    }
    
    function toggleEnabled() {
        $("#filterGivenName").css("background-color", "");
        $("#filterGivenName").removeAttr("disabled");
        $("#filterSurname").css("background-color", "");
        $("#filterSurname").removeAttr("disabled");
    }
    
    function toggleDisabled() {
        $("#filterGivenName").css("background-color", "#F3F3F3");
        $("#filterGivenName").attr('disabled', 'true');
        $("#filterSurname").css("background-color", "#F3F3F3");
        $("#filterSurname").attr('disabled', 'true');
    }
</script>
</s:if>
<div class="contentbox">
    <h3><s:text name="users.filter.condition"/></h3>
    <s:form id="usersFilter" action="usersFilter" method="get" theme="simple">
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="users.filter.label.ssn"/>
                    <s:text var="allCtrys" name="countrylist.all"/>

                    <s:select id="ssnCountry" list="countryList"
                              listValue="ISO3Country" listKey="country"
                              headerKey="" headerValue="%{#allCtrys}"
                              name="filterCountryCode" cssClass="styled"/>
                    <span class="styled">
                        <s:textfield name="filterSSN" title="%{getText('users.filter.wildcard')}"/>
                    </span>
                    <s:fielderror fieldName="filterSSN"/>
                </li>
                <li>
                    <s:label key="users.filter.label.givenname"/>
                    <s:fielderror fieldName="filterGivenName"/>
                    <s:textfield id="filterGivenName" name="filterGivenName"/>
                </li>
                <li>
                    <s:label key="users.filter.label.surname"/>
                    <s:fielderror fieldName="filterSurname"/>
                    <s:textfield id="filterSurname" name="filterSurname"/>
                </li>
                <li>
                    <s:label key="users.filter.label.all_users"/>
                    <span id="isAllUsers"><s:checkbox name="filterAllUsers" cssClass="styled"/></span>
                </li>
            </ul>
        </fieldset>
        <s:submit name="btnSubmit" id="btnSubmit" key="label.button.search" cssClass="button regular_btn"/>
        
    </s:form>
    <hr />
    <s:if test="searchResults!=null">
        <h3><s:text name="users.filter.found"/></h3>
        <s:if test="searchResults.size > 0">
            <table class="list selection">
                <s:if test="showUserUnits || showUserPortalsOnly || showUserPortalsAll">
                    <thead>
                        <tr>
                            <th><s:text name="label.username" /></th>
                            <s:if test="showUserUnits">
                                        <th><s:text name="menu.item.9" /></th>
                            </s:if>
                            <s:if test="showUserPortalsAll">
                                <th title="<s:text name="label.portals" />"><s:text name="users.filter.label.portal" /></th>
                                <th><span class="main"><s:text name="users.filter.label.org.main" 
                                	/></span>/<s:text name="users.filter.label.org.unit" /></th>
                                <th><s:text name="menu.role" /></th>
                            </s:if>
                        	<s:elseif test="showUserPortalsOnly">
                                <th title="<s:text name="label.portals" />"><s:text name="users.filter.label.portal" /></th>
                        	</s:elseif>
                        </tr>
                    </thead>
                 </s:if>
                <s:iterator value="searchResults" var="res">
                    <tr>
                        <td class="user-info">
                            <s:url var="show_user_link" action="showUser">
                                <s:param name="userId" value="#res.id"/>
                            </s:url>
                            <s:a href="%{show_user_link}"><s:property value="%{#res.fullNameSsnParenthesis}"/></s:a>
                        </td>
                        <s:if test="showUserUnits">
                            <td class="unit-info">
                                <%String semi = ""; %>
                                <s:iterator value="%{#res.orgPersonList}" var="units">
                                    <s:if test="%{#units.portal.id == portalId && activeOrg.id != #units.orgId.id}">
                                        <%=semi%><s:property value="%{#units.orgId.getActiveName(locale.language)}"/>
                                        <%semi = "; "; %>
                                    </s:if>
                                </s:iterator>
                            </td>
                        </s:if>
                        
                        <s:if test="%{showUserPortalsOnly || showUserPortalsAll}">
                        	
                     		 <s:set var="firstUserPortal" value="true"/>
                             <s:iterator value="%{getPortals(#res.orgPersonList)}" var="userPortal">
                     			<s:set var="showPortal" value="true"/>
                             	
                                 <s:iterator value="%{#userPortal.portalOrgs}" var="portalOrg">
                     				<s:set var="showPortalOrg" value="true"/>
                                     <s:iterator value="%{#portalOrg.roles}" var="unitRole">
                                     	
			                        	 <s:if test="%{showUserPortalsAll || showUserPortalsOnly && #showPortal}">
                                         <!-- Create new line and pad up empty colspan for user portal display -->
                                         <s:if test="%{!#firstUserPortal}">
                                         	<s:property value="%{'</tr><tr>'}" escapeHtml="false" />
                                         	<td class="user-portals padding"></td>
                                         	<s:if test="%{showUserUnits}">
                                         		<td class="user-portals padding"></td>
                                         	</s:if>
                                         </s:if>
                                          <s:set var="tdPortalClass" value="%{(#showPortal ? 'show-portal' : '')}"/>
                                          <s:set var="tdUnitClass" value="%{(#showPortalOrg ? 'show-portal-org' : '')}"/>
                                          
                                         <td class="user-portals <s:property value="%{#tdPortalClass}"/>"
                                         	 title="<s:text 
                                         	 name="users.filter.label.portal"/> '<s:property 
                                         	 value="%{#userPortal.portal.getActiveName(locale.language)}"/>'&#xA;<s:text 
                                         	 name="portal.label.short_name"/> '<s:property 
                                         	 value="%{#userPortal.portal.shortName}"/>'"
                                         	>
                                           	<span  class="portal-name" >
                                              
	                                          	  <s:if test="showPortal">
	                                                   <s:property value="%{#userPortal.portal.getActiveName(locale.language)}"/>
	                                                   <s:set var="showPortal" value="false"/>
	                                              </s:if>
                                               </span>
                                          </td>
                                          
			                        	  <s:if test="%{showUserPortalsAll}">
			                        		<td class="user-portals <s:property value="%{#tdPortalClass + ' ' + #tdUnitClass}"/>"
			                                  	title="<s:text name="users.filter.label.org.%{#portalOrg.main ? 'main' : 'unit'}"
			                                          	/> '<s:property value="%{#portalOrg.org.getActiveName(locale.language)}"/>'&#xA;<s:text name="units.show.code"/> '<s:property value="%{#portalOrg.org.code}"/>'">
			                                   	<span class="org-name <s:property value="%{#portalOrg.main ? 'main' : ''}"/>">
			                                  			<s:if test="showPortalOrg">
			                                               <s:property value="%{#portalOrg.org.getActiveName(locale.language)}"/>
			                   							   <s:set var="showPortalOrg" value="false"/>
			                                  			</s:if>
			                                    </span>
			                                  </td>
			                                  <td class="user-portals <s:property value="%{#tdPortalClass + ' ' + #tdUnitClass}"/> roles">
			                                        <span title="<s:text name="menu.role"/> '<s:text name="roles.%{#unitRole}"/>'">
			                                            <s:text name="roles.%{#unitRole}"/>
			                                        </span>
			                                  </td>
			                        	  </s:if>
                                          
                                          </s:if>
                     					  <s:set var="firstUserPortal" value="false"/>
                                     </s:iterator>
                                 </s:iterator>
                             </s:iterator>
                         </s:if>
                    </tr>
                </s:iterator>
                <s:if test="%{(itemCount/pageSize)>0}">
                    <tfoot>
                        <tr>
                            <td colspan="6" style="text-align: center">
                                <s:if test="pageNumber>1">
                                    <s:a action="usersFilter" includeParams="all">
                                        <s:param name="pageNumber" value="%{pageNumber-1}"/>
                                        <img src="resources/<s:property value="subPortal"/>/images/arrow-left-single.png"  alt="" />
                                    </s:a>
                                </s:if>
                                <s:if test="itemCount != pageSize">
                                    <s:property value="%{pageNumber}"/>/<s:property value="%{(itemCount/pageSize)+1}"/>
                                </s:if>
                                <s:if test="itemCount>pageSize">
                                    <s:a action="usersFilter" includeParams="all">
                                        <s:param name="pageNumber" value="%{pageNumber+1}"/>
                                        <s:if test="pageNumber != (itemCount/pageSize)+1">
                                            <img src="resources/<s:property value="subPortal"/>/images/arrow-right-single.png"  alt="" />
                                        </s:if>
                                    </s:a>
                                </s:if>
                            </td>
                        </tr>
                    </tfoot>
                </s:if>
            </table>
            <s:if test="orgUsers != null && orgUsers.size > 0">
                <hr>
                   <h5><s:text name="users.filter.found.units"/></h5>
                <table class="list selection">
                    <s:iterator value="orgUsers" status="stat">
                            <tr>
                                <th style="cursor:pointer;" class="toggle <s:property value='key.id' />"><s:property value="key.getActiveName(locale.language)" /> (<s:property value="key.code" />)</th>
                                <s:iterator value="value">
                                    <tr>
                                        <td class="toggleChild t<s:property value='key.id' />" >
                                            <s:url var="show_user_link" action="showUser">
                                                <s:param name="userId" value="id"/>
                                            </s:url>
                                            <s:a href="%{show_user_link}"><s:property value="%{fullNameSsnParenthesis}"/></s:a>
                                        </td>
                                    <tr>
                                </s:iterator>
                            </tr>
                    </s:iterator>
                </table>
            </s:if>
        </s:if>
        <s:else>
            <div class="" style="text-align: left">
                <h5><s:text name="text.search.no_results"/></h5>
            </div>
        </s:else>

    </s:if>
    <s:a id="btnNew" action="addUser" cssClass="button regular_btn"><s:text name="label.button.add_new_user"/></s:a>
</div>