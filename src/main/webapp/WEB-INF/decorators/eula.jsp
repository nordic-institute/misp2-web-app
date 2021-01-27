<%@ taglib prefix="s" uri="/struts-tags"%>
<%@ page language="java" contentType="text/html; " pageEncoding="UTF-8"%>

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

<%-- -- --
  -- JSP fragment to display EULA acceptance dialog (if needed).
  --%>
		<s:set var="eulaFromSession" value="@ee.aktors.misp2.service.EulaService@getEulaContentFromSession(#session, locale.language)"  />
        <s:if test="%{#eulaFromSession != null}">
           
           	<script type="text/javascript">
           	    function scaleEulaOverlay(height) { // called frm main.jsp
           			jQuery("#eula-overlay").css("top", height + "px");
           			jQuery("#eula-dialog").css("top", (height + 8) + "px");
           			jQuery("#eula-content").css("top", (height + 58) + "px");
           			
           			// make sure the buttons would not overlap with content box
           			var minHeight = parseInt(jQuery("#eula-dialog").css("min-height").replace("px", ""));
           			var top       = parseInt(jQuery("#eula-dialog").css("top").replace("px", ""));
           			var bottom    = parseInt(jQuery("#eula-dialog").css("bottom").replace("px", ""));
           			
           			var padding = 10;
           			jQuery("body").append(
           				jQuery("<style>", {"type": "text/css"})
           					.text(
			           			"@media only screen and (max-height: " + (top + minHeight + bottom + padding) + "px) {" +
			      				"  #eula-buttons { " +
			      				"	    /* Fix button box location on extremely small heights */ " +
			      				"	    top: " + (top + minHeight + padding - 40) + "px; " +
			      				"  } " +
			      				"}"
      						)
      				);
           	    	
           	    }
        		jQuery("body").css("overflow", "hidden");
           		jQuery(document).ready(function() {
           			function removeEula() {
		        		jQuery(".eula").remove();
		        		jQuery("body").removeAttr("style"); /* Get rid of overflow */
           			}
		        	jQuery("#eula-reject").click(function() {
		        		removeEula();
		        		Utils.displayLoadingOverlay();
		        		console.log("POST to " + absoluteURL.getURL("rejectEula.action"));
		        		jQuery.ajax({
		        			url: absoluteURL.getURL("rejectEula.action"),
		        			type: "GET",
		        			data: {},
		        			async: true,
		        			cache: false,
		        			dataType: "html",
		        			success: function(data) {
		        				console.log(data);
				        		document.location = jQuery("#exit").attr("href");
		        			},
		        			error: function(xhr, err, errorText) {
		        				if (window.console) {
		        					window.xhr = xhr; // for debugging after error ocurred
		        					console.log(xhr, err, errorText);
		        				}
		        				alert(jQuery("#error-sending-eula-request").text()
		        						+ " " + errorText);
		        			}
		        		});
		        	});
		        	jQuery("#eula-accept").click(function() {
		        		removeEula();
		        		Utils.displayLoadingOverlay();
		        		jQuery.ajax({
		        			url: absoluteURL.getURL("acceptEula.action"),
		        			type: "GET",
		        			data: {},
		        			async: true,
		        			cache: false,
		        			dataType: "html",
		        			success: function(data) {
		        				console.log(data);
				        		Utils.hideLoadingOverlay();
		        			},
		        			error: function(xhr, err, errorText) {
		        				if (window.console) {
		        					window.xhr = xhr; // for debugging after error ocurred
		        					console.log(xhr, err, errorText);
		        				}
		        				alert(jQuery("#error-sending-eula-request").text()
		        						+ " " + errorText);
		        			}
		        		});
		        	});
		         });
           	</script>
           	<style type="text/css">
           	    #eula-overlay {
					position: fixed;
				    text-align: center;
				    width: 100%;
				    height: 100%;
				    background-color: white;
				    top: 0%;
				    left: 0%;
				    z-index: 200;
				    opacity: 0.9;
				    display: none;
           	    }
           		#eula-dialog {      
				    position: inherit;
				    border:1px solid #d9d9d9;
					font-size: 125%;            
				    top: 100px;            
				    left: 40px;
				    bottom: 40px;
				    right: 40px;
				    text-align: center !important;
				  	vertical-align: middle !important;
				  	
				  	background-color: rgba(247, 247, 247, 1.0);
				  	z-index: 210;
				  	position: fixed;
				  	min-height: 200px;
				}
				#eula-dialog h3{
					font-size:1.3em;
					font-weight:bold;
					padding: 20px;
				}
				#eula-content {
				    border:1px solid #d9d9d9;
					font-size: 125%;            
				    top: 150px;            
				    left: 60px;
				    bottom: 100px;
				    right: 60px;
				    padding: 10px;
				    text-align: center !important;
				  	vertical-align: middle !important;
				  	
				  	z-index: 220;
				  	position: fixed;
				    overflow-y: auto;
				  	background-color: rgba(255, 255, 255, 1.0);
				  	min-height: 80px;
				}
				#eula-buttons {
				  	position: fixed;
				    bottom: 50px;
				    right: 60px;
					font-size: 125%;
				  	z-index: 230;
				  	left: 60px;
				  	text-align: right;
				}
				#eula-question {
					line-height: 1.5em;
				}
			</style>
			<link rel="stylesheet" type="text/css" href="<s:url value='/../src/main/webapp/resources/EE/css/eula-markdown.css' encode='false'/>" />
            <div id="eula-overlay" class="eula" style="display:inline;">
                <div id="eula-hidden-vars" class="hidden">
					<span id="error-sending-eula-request"><s:text name="error.dataexchange.UNSPECIFIED" /></span>
	            	<s:a id="accept-eula" action="acceptEula"></s:a>
	            	<s:a id="reject-eula" action="rejectEula"></s:a>
		        </div>
            </div>
           	<div id="eula-dialog" class="eula">
        		<h3><s:text name="eula.heading"/></h3>
	       		<div id="eula-buttons">
	       		    <span id="eula-question"><s:text name="eula.question"/></span>&nbsp;
	       			<span><button id="eula-accept" type="button" class="button regular_btn"><s:text name="eula.label.agree"/></button></span>
	       			<span><button id="eula-reject" type="button" class="button delete_btn"><s:text name="eula.label.disagree"/></button></span>
	       		</div>
        	</div>
        	<div id="eula-content" class="eula"><s:property value="eulaFromSession" escapeHtml="false"/></div>
            
        </s:if>