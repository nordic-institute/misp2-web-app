<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="s" uri="/struts-tags" %>

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

<!-- ID-card auth -->
<s:if test="%{config.getProperty('auth.IDCard')}">
    <div class="contentbox">
        <h3><s:text name="label.signin.ID"/></h3>
		<s:set var="IDCardLoginURL" value="%{config.getString('IDCard.loginURL')}"/>
		<s:if test="%{#IDCardLoginURL != ''}">
			<s:set var="IDCardLoginURL" value="%{#IDCardLoginURL+'/enter.action?redirectToIDCardLogin=true'}"/>
		</s:if>
		<s:else><!-- If IDCardLoginURL is unspecified, then use default one -->
			<s:url var="IDCardLoginURL" scheme="https" action="enter" encode="false">
				<s:param name="redirectToIDCardLogin">true</s:param>
			</s:url>
        </s:else>
		<s:a href="%{IDCardLoginURL}"><img style="margin-top:11px" alt="auth id" src="resources/<s:property value="subPortal"/>/images/auth_id.gif"/></s:a>
    </div>
</s:if>

<!-- mobile-ID auth -->
<s:if test="%{config.getProperty('auth.mobileID')}">
    <div class="contentbox">
        <h3><s:text name="label.signin.mobileID"/></h3>
        <s:form action="mobileIDLoginStart" method="post" theme="simple">
            <ul class="form">
                <li>
                    <s:label for="mobileNr" key="label.mobileNr"/>
                    <s:textfield name="mobileNr" title="5xxxxxxx"/>
                </li>
                <li>
                    <s:label for="mobileNr" key="label.personalCode"/>
                    <s:textfield name="personalCode" title="39876543210"/>
                </li>
				<li><s:submit type="image" alt="auth mobile" src="resources/EE/images/mobiil_id.gif" /></li>
            </ul>
        </s:form>
    </div>
</s:if>

<!-- certificate authentication -->
<s:if test="%{config.getProperty('auth.certificate')}">
    <div class="contentbox">
        <h3><s:text name="label.signin.certificate"/></h3>
        <s:a scheme="https" action="certLogin" data-confirmable-post-link="" cssClass="button regular_btn"><s:text name="label.certificate"/></s:a>
        <br/>

        <span>
            <s:text name="text.signin.certificate.create"/>
            <s:a id="newcert" action="certCreate" encode="true"><s:text name="text.here"/></s:a>
        </span>
    </div>
</s:if>


<!-- password auth -->
<s:if test="%{config.getProperty('auth.password')}">
    <div class="contentbox">
        <s:form action="formLogin" theme="simple">
            <fieldset>
                <h3><s:text name="label.signin"/></h3>
                <ul class="form">
                    <li>
                        <s:label key="label.username" for="username"/>
                        <s:textfield name="username"/>
                    </li>
                    <li>
                        <s:label key="label.password" for="password"/>
                        <s:password  name="password" />
                    </li>
                </ul>
            </fieldset>
            <s:submit name="submit" key="label.button.login" cssClass="button regular_btn"/>
        </s:form>
    </div>
</s:if>
<script type="text/javascript">
    $( document ).ready(function() {
        $("input[name=mobileNr]").attr("placeholder", "+372 xxxxxxxx");
        $("input[name=personalCode]").attr("placeholder", '<s:text name="placeholder.person_ssn"/>');
    });
</script>
