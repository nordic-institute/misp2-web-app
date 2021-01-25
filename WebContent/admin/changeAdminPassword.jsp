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

<script type="text/javascript">
    $(document).ready(function( ){
        $("#btnSubmit").click(function() {
            if ($("#newPassword").val() != $("#retypedPassword").val()) {
                alert("<s:text name='change.password.mismatch'/>");
                return false;
            } else {
                return true;
            }
        });
    })
</script>

<div class="contentbox">
    <s:form action="saveAdminPassword" theme="simple" method="post">
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="change.password.old_password" />
                    <s:password id="oldPassword" required="true" name="oldPassword" />
                    <s:fielderror fieldName="oldPassword" />
                </li>
                <li>
                    <s:label key="change.password.new_password" />
                    <s:password id="newPassword" required="true" name="newPassword" />
                    <s:fielderror fieldName="newPassword" />
                </li>
                <li>
                    <s:label key="change.password.retype_new_password" />
                    <s:password id="retypedPassword" required="true" name="retypedPassword" />
                    <s:fielderror fieldName="retypedPassword" />
                </li>
            </ul>
        </fieldset>
        <s:submit id="btnSubmit" key="label.button.save" method="saveAdminPassword" cssClass="button regular_btn"/>
    </s:form>
</div>