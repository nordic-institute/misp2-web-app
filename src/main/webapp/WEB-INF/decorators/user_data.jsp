<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page pageEncoding="UTF-8" %>
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

<script type="text/javascript">
    $(document).ready(function() {
        var rsw = $("#roleselect").width()
        var pcw = $("#portalChange").width()
        var max = Math.max(rsw, pcw) + 50; // add nearly 50px to maximum width, because internal select is less that jquery one
        $("#roleselect").selectmenu({
            style:'dropdown',
            maxHeight:150,
            width:max
        })
        $("#portalChange").selectmenu({
            style:'dropdown',
            maxHeight:150,
            width:max
        })
    })
</script>
<s:if test="#session.SESSION_USER_HANDLE != null">
    <s:form id="user" theme="simple">
        <s:if test="!#session.AUTH_METHOD.Admin">
            <h3>
                <span class="highlight">
                    <s:property value="#session.SESSION_USER_HANDLE.fullNameSsn"/>
                </span>
            </h3>

            <s:if test="#allUserPortals==null || #allUserPortals.size<=1">
                <p id="portal">
                    <s:property value="#session.SESSION_PORTAL.getActiveName(locale.language)"/> &#8226;
                    <s:property value="#activeOrgName"/>
                    (<s:property value="#session.SESSION_ACTIVE_ORG.code"/>)
                </p>
            </s:if>
            <s:else>
                <s:select id="portalChange" name="portalName" value="#session.SESSION_PORTAL.shortName" 
                          list="allUserPortals" />
            </s:else>

            <fieldset>
                <s:if test="#session.SESSION_ALL_ROLES!=null && #session.SESSION_ALL_ROLES.size>0">
                    <s:if test="#session.SESSION_USER_ROLE==2">
                        <s:set var="activez"  value="'P'+#session.SESSION_ACTIVE_ORG.id"/>
                    </s:if>
                    <s:elseif test="#session.SESSION_USER_ROLE==4"  >
                        <s:set var="activez"  value="'A'+#session.SESSION_ACTIVE_ORG.id"/>
                    </s:elseif>
                    <s:elseif test="#session.SESSION_USER_ROLE==8"  >
                        <s:set var="activez"  value="'M'+#session.SESSION_ACTIVE_ORG.id"/>
                    </s:elseif>
                    <s:elseif test="#session.SESSION_USER_ROLE==32"  >
                        <s:set var="activez"  value="'E'+#session.SESSION_ACTIVE_ORG.id"/>
                    </s:elseif>
                    <s:elseif test="#session.SESSION_USER_ROLE==128"  >
                        <s:set var="activez"  value="'L'+#session.SESSION_ACTIVE_ORG.id"/>
                    </s:elseif>
                    <s:elseif test="#session.SESSION_USER_ROLE==64"  >
                        <s:set var="activez"  value="'X'"/>
                    </s:elseif>
                    <s:else>
                        <s:set var="activez" value="'U'+#session.SESSION_ACTIVE_ORG.id"/>
                    </s:else>

                    <s:label key="menu.role"/>
                    <s:select id="roleselect" key="menu.role"  name="role_select" value="activez"
                              list="#session.SESSION_ALL_ROLES"/>
                </s:if>
            </fieldset>
            <script type="text/javascript">
                $(document).ready(function() {
                    $("#roleselect").change(function() {
                        var orgId = this.value.substr(1,(this.value.length-1));
                        // prefixes can be found from Const class
                        if(this.value.charAt(0)=="U"){
                            window.location.href='<s:url action="login_user.action" escapeAmp="false"><s:param name="orgId" value="\'dummyValue\'"/></s:url>'.
                            	replace("dummyValue", orgId);
                        }
                        else if(this.value.charAt(0)=="P"){
                            window.location.href='<s:url action="login_perm_manager.action" escapeAmp="false"><s:param name="orgId" value="\'dummyValue\'"/></s:url>'.
                        		replace("dummyValue", orgId);
                        }
                        else if(this.value.charAt(0)=="A"){
                            window.location.href='<s:url action="login_developer.action" escapeAmp="false"><s:param name="orgId" value="\'dummyValue\'"/></s:url>'.
                        		replace("dummyValue", orgId);
                        }
                        else if(this.value.charAt(0)=="M"){
                            window.location.href='<s:url action="login_manager.action" escapeAmp="false"><s:param name="orgId" value="\'dummyValue\'"/></s:url>'.
                        		replace("dummyValue", orgId);
                        }
                        else if(this.value.charAt(0)=="X"){
                            window.location.href='<s:url action="login_unregistered.action" escapeAmp="false"/>';
                        }
                        else if(this.value.charAt(0)=="E"){
                            window.location.href='<s:url action="login_representative.action" escapeAmp="false"><s:param name="orgId" value="\'dummyValue\'"/></s:url>'.
                        		replace("dummyValue", orgId);
                        }
                        else if(this.value.charAt(0)=="L"){
                            window.location.href='<s:url action="login_limited_representative.action" escapeAmp="false"><s:param name="orgId" value="\'dummyValue\'"/></s:url>'.
                        		replace("dummyValue", orgId);
                        }
                    })
                    $("#portalChange").change(function() {
                        document.location = '<s:url action="portalChange" escapeAmp="false"><s:param name="portalName" value="\'dummyValue\'"/></s:url>'.replace("dummyValue", this.value);
                    })
                })
            </script>
        </s:if>
    </s:form>
</s:if>


