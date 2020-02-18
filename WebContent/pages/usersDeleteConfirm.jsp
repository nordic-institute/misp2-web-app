<%@page  pageEncoding="UTF-8" %>
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

<script type="text/javascript">
    $(document).ready(function() {
        $("#btnYes").click(function(){
            Utils.postURL('<s:url escapeAmp="false" action="userDeleteConfirmed" includeParams="all" />');
        });
        $("#btnNo").click(function() {
            document.location = '<s:url escapeAmp="false" action="showUser" includeParams="all"/>';
        });
    })
</script>

<div class="contentbox error">
    <h3>
        <s:text name="users.show.default.item_name_genitive"/>
        &quot;<s:property value="%{person.fullName}"/>&quot;
        <s:text name="users.confirm.text.has_rights"/>
    </h3>
</div>
<div class="contentbox">
    <h3><s:text name="users.confirm.text.question"/></h3>
    <center>
        <s:a id="btnYes" href="" cssClass="button regular_btn"><s:text name="label.button.yes"/></s:a>
        <s:a id="btnNo" href="" cssClass="button delete_btn"><s:text name="label.button.no"/></s:a>
    </center>
</div>