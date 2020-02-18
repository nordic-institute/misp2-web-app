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

<!--error message tooltipping-->

<link rel="stylesheet" type="text/css" href="<s:url value='/resources/jscript/jquery-tooltip/jquery.tooltip.css'  encode='false'/>"/>
<script type="text/javascript" src="<s:url value='/resources/jscript/jquery-tooltip/jquery.tooltip.min.js'  encode='false'/>"></script>


<script type="text/javascript">
    $(document).ready(function() {
        var msgs = $(".errorMessage")
        msgs.css("display", "none");
        var msgLabel=msgs.parent("li").find("label:first");
        msgLabel.css("color", "red");
        msgLabel.tooltip({
            bodyHandler: function() {
                return $(this).parent("li").find(".errorMessage span").text();
            }
        });

    })
</script>