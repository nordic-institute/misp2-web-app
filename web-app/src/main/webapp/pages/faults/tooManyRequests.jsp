<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="s" uri="/struts-tags" %>
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
<script>
	jQuery(document).ready(function() {
		var startTime = new Date().getTime();
		var jqEl = jQuery("#access-lock-time");
		var startVal = jqEl.text();
		var startSec = parseInt(startVal.split(/\s+/)[0]);
		var jqEnterButton = jQuery("#enter-button");
		jqEnterButton.hide();
		//console.log("Start ", jqEl, startTime, startVal, startSec);
		function updateLockTime() {
			var newTime = new Date().getTime();
			var diffSec = Math.round((newTime - startTime) / 1000.);
			var newSec = startSec - diffSec;
			jqEl.text(newSec + " s");
			if (newSec > 0) {
				var delay = 1000 - newTime % 1000;
				//console.log("New ", newTime, diffSec, newSec, delay);
				window.setTimeout(updateLockTime, delay);
			} else {
				jqEnterButton.show();
				jQuery("#message-container").removeClass("error").addClass("warning");
			}
		}
		updateLockTime();
	});
</script>
<div id="message-container" class="contentbox error">
    <h3>${request.message}</h3>
    <s:a id="enter-button" action="enter" cssClass="button regular_btn">
    	<s:text name="label.button.login"/>
    </s:a>
</div>
<!--  -->
<!-- <meta HTTP-EQUIV="REFRESH" content="3; url=./enter.action"> -->