<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page pageEncoding="UTF-8"%>
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
<script type="text/javascript" src="<s:url value='/resources/jscript/FitWidget.js' encode='false'/>"></script>

<s:url action="runQuery_%{query.name}_%{queryId}" var="runq" escapeAmp="false"/>
<div class="contentbox">

<s:if test="context.name=='xforms-query'">
	<s:a id="hideHeader" href="#nogo">
		<img id="arrow-up" title="<s:text name='text.header.hide'/>" src="<s:url value='/resources/%{subPortal}/images/arrow-up.png' encode='false'/>"/>
		<img id="arrow-down" title="<s:text name='text.header.show'/>" src="<s:url value='/resources/%{subPortal}/images/arrow-down.png' encode='false'/>"  />
	</s:a>
</s:if>
<s:if test="#session.SESSION_USER_ROLE==4 || #session.SESSION_USER_ROLE==8">
	<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toListQueries')}"  href="javascript: history.go(-1)"><s:text name="help.back.label"/></s:a>
</s:if>
    <span id="loader" class="xforms-loading-loading" style="display: inline; right: auto; left: 45px; top: -51px; z-index: 2;"><s:text name="help.loading.indicator"/></span>
	
	<div id="xformsframe"></div>
	
    <div id="save" style="display:none">    	
    	<s:a id="close" href="#hide" title="%{getText('label.query.layer.close')}"></s:a>
		<div id="pdf">
            <h5><s:text name="label.query.savePDF"/></h5>
            <s:a name="formButton" id="savePDF" cssClass="button regular_btn" href=""><s:text name="label.query.pdf"/></s:a>
        </div>
        <div id="email">
            <h5><s:text name="label.query.send_by_email"/></h5>
            <fieldset>
                <ul class="form" id="email-ul">
                    <li>
                        <label for="email_query"><s:text name="label.query.email"/></label>
                        <input id="email_query" class="vtip" name="email_query" size="30" type="text" value="<s:property value="userMail"/>"/>
                        <input type="hidden" id="receiver_name" name="receiver_name"
                               value="<s:property value="#session.SESSION_USER_HANDLE.fullName"/>"/>
                        <s:a cssClass="button regular_btn" href="" id="sendBtn"><s:text name="label.button.send"/></s:a>
                    </li>
                </ul>
                
            </fieldset>
            <div id="result"></div>
        </div>
        <div id="xml" style="display:none">
            <h5><s:text name="label.query.saveXML"/></h5>
            <s:a name="formButton" id="saveXML" cssClass="button regular_btn" href=""><s:text name="label.query.xml"/></s:a>
        </div>
        <s:form id="pdfSend" action="loadPdf" method="post" theme="simple">
            <input type="hidden" id="formHtml" name="formHtml"/>
            <input type="hidden" id="sendPdfByMail" name="sendPdfByMail" value="false"/>
            <input type="hidden" id="encrypt" name="encrypt" value="false" />
            <input type="hidden" id="sign" name="sign" value="false" />
            <input type="hidden" id="pdfQueryName" name="pdfQueryName" value="<s:property value="query.name"/>"/>
            <input type="hidden" id="pdfQueryDesc" name="pdfQueryDesc" value="<s:property value="queryName.description"/>"/>
            <input type="hidden" id="pdfQueryId" name="pdfQueryId"  value="<s:property value="queryId"/>"/>
            <input type="hidden" id="textmail" value="<s:text name="text.mail.sent"/>"/>
			<s:hidden value="%{getText('validation.email')}" id="queryNoteMailEmpty"/>
			<s:hidden id="queryMailSent" value="%{getText('text.mail.sent', 'dummyValue')}"/>	
			<s:submit id="pdfSendSubmit" key="label.button.save" cssClass="button regular_btn" cssStyle="display:none" name="btnSubmit"/>
        </s:form>
	</div>   
</div>

<script type="text/javascript">
	function hideProgress(){
		$("#loader").hide();
	}
	
	// Added on 26.06.2012
	
	var iFrames = document.getElementsByTagName('iframe');
	// Resize heights.
	function iResize()
	{
		// Iterate through all iframes in the page.
		for (var i = 0, j = iFrames.length; i < j; i++)
		{
			// Set inline style to equal the body height of the iframed content.
			iFrames[i].style.height = iFrames[i].contentWindow.document.body.offsetHeight + 30 + 'px';
			//$("#xformsframe").width ($(iFrames[i].contentWindow.document.body).width() + 3+ + 'px');
		}
		
	}
	// Check if browser is Safari or Opera.
	if ($.browser.safari || $.browser.opera)
	{
		// Start timer when loaded.
		$('iframe').load(function()
			{
				setTimeout(iResize, 0);
			}
		);
		// Safari and Opera need a kick-start.
		for (var i = 0, j = iFrames.length; i < j; i++)
		{
			var iSource = iFrames[i].src;
			iFrames[i].src = '';
			iFrames[i].src = iSource;
		}
	}
	else
	{
		// For other good browsers.
		$('iframe').load(function()
			{
				// Set inline style to equal the body height of the iframed content.
				this.style.height = this.contentWindow.document.body.offsetHeight +20 + 'px';
			}
		);
	}

</script>
<script type="text/javascript">

function sendPDFByMail(form, email, sign, encrypt, description){
    var url = "<s:property value="%{runq}"/>";
    xformsURL = url + (url.indexOf('?') != -1 ? '&' : '?') + 'orbeon-embeddable=true';
    if (email == '') {
    		alert('<s:text name="validation.email.empty"/>');
            return false;
    }

    var emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
    if (!emailPattern.test(email)){
    		alert('<s:text name="validation.email.format"/>');
            return false;
    }
    var $scrollingDiv = $("#loader", window.parent.document);
    $.ajax(
	{
	  url: xformsURL + (xformsURL.indexOf('?') != -1 ? '&' : '?') + 'pdf=true&case=' + form +'&sendPdfByMail=true&email='+email+'&sign='+sign +'&encrypt='+encrypt+'&description='+description,
	  // success event
	  success: function(response, status, xhr)
	    {
	      alert(response);
	      $scrollingDiv.hide();
	    },
	  // error event
	  error: function(xhr, status, error)
	    {
	      if (xhr.status != '200')
	      {
	        if (xhr.responseText != null)
	        {
	          alert(xhr.responseText);
	          $scrollingDiv.hide();
	        }
	        else
	        {
	        	alert('<s:text name="error.email.sending.failed"/>');
	        }
	      }
	    }
	}
	)

 	return true;
}

function xformsShow(url, xformsframe)
	{
	
	  xformsURL = url + (url.indexOf('?') != -1 ? '&' : '?') + 'orbeon-embeddable=true';
	  
	  // make sure loader fits into orbeon window
	  $("#loader").removeClass("xforms-loading-loading").css('background', 'white url("resources/EE/images/loading.gif") no-repeat center').
	  css('color', 'black').css('border', '2px solid #EDF2F9').css('padding', '5px 45px 100px 45px').css('text-align', 'center').
	  css('vertical-align', 'middle').css('margin-left', 'auto').css('margin-right', 'auto').css('display', 'inline').css('position', 'relative').
	  css('left', '35%').css('top', '50%');
	  
	  $(".contentbox").height("155");
	  
	  if(window.console && window.Date && Date.now){
		  window.xformsRenderingStarted = Date.now();
	  }
	  window.afterLoadCallback = function (response, status, xhr){
		  // load replaces xformsframe contents only on success. do the same in case of error.
		  if(window.console && window.Date && Date.now){
			  window.xformsDownloaded = Date.now();
			  console.log("XForms was downloaded with ", window.xformsDownloaded - window.xformsRenderingStarted, " ms");
		  }
		  
		  if (status != "success") {
		      $(this).html(response); 
		  
		  }
		  if (typeof ORBEON != "undefined") {
			 
			  // initialize Orbeon only in Firefox
			  if (!document.all)
			  {
				  ORBEON.xforms.Init.document();
			  }
			  YAHOO.util.Event._load();
			  YAHOO.util.Event._ready();
			  $("#loader").hide();
			  
			  // Footer with that ID already exists in MISP
			  $("#footer-left").parent().attr("id", "footer-orbeon");
			  
			  // So that Help dialogs would not be shown too high
			  //  it is kind of hackish, because the problem is that ORBEON.xforms.Controls.showHelp 
			  //  places the help dialog relative to document body, not the actual .xformsframe div
			  /*var old_help_function = ORBEON.xforms.Controls.showHelp;
			  ORBEON.xforms.Controls.showHelp = function (control){
													old_help_function(control);  
													console.log();
													var container = $(ORBEON.xforms.Globals.formHelpPanelMessageDiv[ORBEON.xforms.Controls.getForm(control).id]).closest(".yui-panel-container");
													
													//console.log($(control).parent().html());
													if (container.css("top")[0] == "-") container.css("top" , 0);
													};*/
						
			   //$(".xforms-dialog").parent().width($(".xforms-dialog").width())
			   $(".contentbox").height("");
			   $(".xforms-dialog").width(400).parent().width(400);
			   $(document).click(function()		{window.setTimeout('fitWidget([$("#orbeon-calendar-div"), $(".xforms-dialog").parent()])', 0);});
			   // delay is needed for dialog windows
			   $(document).click(function()		{window.setTimeout('fitWidget([$("#orbeon-calendar-div"), $(".xforms-dialog").parent()])', 500);});
			   
			   
			   $(document).keydown(function()	{window.setTimeout('fitWidget([$("#orbeon-calendar-div"), $(".xforms-dialog").parent()])', 0);});
			   // delay is needed for dialog windows
			   $(document).keydown(function()		{window.setTimeout('fitWidget([$("#orbeon-calendar-div"), $(".xforms-dialog").parent()])', 500);});
			   
			   // if we have inspector, hide it and make a link to open it (to enable user to test without a huge inspector block)
			   if($(".xbl-fr-xforms-inspector").length >= 1){
				   $(".xbl-fr-xforms-inspector").hide();
				   $(".xbl-fr-xforms-inspector").before("<br/><a id='enable-orbeon-inspector' href='#nogo' onclick='inspectorWrapper.toggle();'>Orbeon Inspector</a>");
			   }
			   
			   // if footer gets hidden, show it
			  window.setTimeout(function(){
				  // show or hide inspector
				  inspectorWrapper.init();
				  $("#footer").show();
			  }, 400);
			   
			  // Yui-monitor to correct place
			  //$("#_yuiResizeMonitor").prependTo("#xformsframe");
			  //$("#_yuiResizeMonitor").css("position", "relative").css("top", "0");
			  
			  // add toggle functionality to help icons
			  //closeHelp();
			  //toggleHelp();
			  // add close functionality to dialog boxes
			  //closeLayer();
			  
			  fixOrbeonLoadingIndicator();
			  
		  }
		  else{ // ORBEON object undefined - must be error
			  // If we have wrong css file, replace it with embedded one - make sure error is ok
		      var wrong_css = $("link").filter(function(){return $(this).attr("href").indexOf("xforms.css") != -1});
		      if(wrong_css.length != 0) wrong_css.attr("href", wrong_css.attr("href").replace("xforms.css", "xforms-embedded.css"));
			  $("#loader").hide();
			// if footer gets hidden, show it
			  window.setTimeout('$("#footer").show()', 400);
		  }
		  if(window.console && window.Date && Date.now){
			  window.xformsReady = Date.now();
			  console.log("XForms rendering took ", window.xformsReady - window.xformsDownloaded, " ms");
		  }
		}

	  	xformsframe.load(xformsURL, afterLoadCallback);
	  	return true;
	}
	
	/**
	 * Hide Orbeon load indicator when requests are not in progress.
	 * NB! Only runs on forms if xforms-upload element is detected after initial load.
	 *
	 * Orbeon file upload widget has a bug in Firefox (Orbeon 4.9) where
	 * load indicator is sometimes not hidden after upload requests.
	 * 
	 * Current function checks indicator visibility and request status periodically and 
	 * hides load indicator if necessary.
	 */
	function fixOrbeonLoadingIndicator() {
		// Only apply the fix when upload element has been loaded
		// When upload element has not been detected, return instantly
		if (jQuery(".xforms-upload").length == 0) {
			return;
		}
		
		// Get formId (first key from Globals.ns)
		for (var formId in ORBEON.xforms.Globals.ns) break;
		// Retrieve load indicator
		var loadingIndicator = ORBEON.xforms.Page.getForm(formId).getLoadingIndicator();
		// Add visibility check method to load indicator prototype
		ORBEON.xforms.LoadingIndicator.prototype.isVisible = function() {
		    return this.loadingOverlay.cfg.getProperty("visible");
		};
	
		// Keep track of last time request was in progress. Track variable ORBEON.xforms.Globals.requestInProgress changes.
		var requestInProgressLastTime = null;
		
		// Function to determine if request is in progress
		// Request is considered to be in progress, if it has been in progress within the last 3 seconds.
		
		function noRequestsLately() {
			var requestInterval = 3000; // ms; interval window from now to past constituting 'lately'
			return !ORBEON.xforms.Globals.requestInProgress && (
				!requestInProgressLastTime || 
				(requestInProgressLastTime.getTime() < new Date().getTime() - requestInterval));
			
		}
	
		// Probe every second
		window.setInterval(
			function() {
				if (window.console && loadingIndicator.isVisible()) {
					console.log("Load indicator is visible ");
				}
				// if request is in progress, update last time it was in progress
				if (ORBEON.xforms.Globals.requestInProgress) {
					requestInProgressLastTime = new Date();
				}
				// since we alter the counter, Orbeon events may set it to negative numbers, correct that
				if (loadingIndicator.shownCounter < 0) {;
					if (window.console) {
						console.log("Resetting loading indicator counter to 0. Was " + 
							loadingIndicator.shownCounter);
					}
					loadingIndicator.shownCounter = 0;
				}
	
				// if indicator is visible, there are no requests in progress or queue, hide load indicator
				if (loadingIndicator.isVisible() &&
				    noRequestsLately() &&
				    ORBEON.xforms.Globals.eventQueue.length == 0) {
					// setting counter to 0 is needed so that next time startEvent runs, indicator is shown again
					loadingIndicator.shownCounter = 0
					loadingIndicator.hide();
					if (window.console) {
						console.log("Hiding load indicator because request was no longer in progress.");
					}
				}
			}, 
		1000);
	};

	$(document).ready( function (){
		xformsShow("<s:property value="%{runq}"/>", $("#xformsframe"));
		
		//Because orbeon queries go to orbeon and MISP does not receive them, these will not reset timeout. 
		//In order to force timeout reset on performing them, we make query to MISP server on clicks on buttons on xforms form.
		$("body").on("click", "form#xforms-form button", function(){
			$.ajax({
				  url: window.location.href,
				  type: "GET",
				  cache: false,
				  timeout: 2000
			});
		});
	});
	
	function InspectorWrapper(){
		this.inspectorOpen = false;
		this.open = function(displayInspector){
			var jqInspector = $(".xbl-fr-xforms-inspector");
			inspectorId = jqInspector.attr("id");
			if(displayInspector){
				jqInspector.show();
		        if(	YAHOO && 
	        		YAHOO.xbl && 
	        		YAHOO.xbl.fr && 
	        		YAHOO.xbl.fr.CodeMirror && 
	        		YAHOO.xbl.fr.CodeMirror._instances){
		        	
	        		for(var key in YAHOO.xbl.fr.CodeMirror._instances){
	        			var codeMirror = YAHOO.xbl.fr.CodeMirror._instances[key];
	        			// Set readOnly to true so that selecting text is possible
	        			codeMirror.editor.options.readOnly = true;
	    				// Refresh CodeMirror window otherwise data does not get rendered
	        			codeMirror.editor.refresh();
	        		}
		        }
		        /* Make sure focus event is not sent from inspector, 
		           otherwise wrong element gets focused and copying text becomes impossible.
		         */
		        if( ORBEON &&
	        		ORBEON.xforms &&
	        		ORBEON.xforms.server &&
	        		ORBEON.xforms.server.AjaxServer && 
	        		ORBEON.xforms.server.AjaxServer.fireEvents &&
	        		!window.AjaxServerFireEventsOriginal){
		        	
		        	// save original event to global namespace in case it needs to be modified further
		        	window.AjaxServerFireEventsOriginal = ORBEON.xforms.server.AjaxServer.fireEvents; 
		        	ORBEON.xforms.server.AjaxServer.fireEvents = function(events, incremental) {
		        		//if(window.console) console.log(events);
		        		// if event is a focus-event on inspector
		        		if(events && events.length >= 1 && 
		        			events[0].eventName == "xforms-focus" && 
		        			events[0].targetId == inspectorId){
		        			
		        			// do not fire the event, just return from current function to avoid AJAX request
		        			// this is required to enable copying XML in orbeon inspector
		        			return;
		        		}
		        		
		        		// else fire the event
		        		AjaxServerFireEventsOriginal(events, incremental);
		        	}
		        }
	        	window.scrollTo(0,document.body.scrollHeight);
	        	this.inspectorOpen = true;
				
			}
			else{
				jqInspector.hide();
	        	this.inspectorOpen = false;
				
			}
		}
		this.toggle = function(){
	        if(this.inspectorOpen){
	        	this.open(false);
	       	}
	        else{
	        	this.open(true);
	        }
		}

		this.init = function(){
			// always start with closed version
        	this.open(false);
        	/*
	        if(this.isOpen()){
	        	this.open(true);
	       	}
	        else{
	        	this.open(false);
	        }*/
		}
	}
	jQuery(document).ready(function(){
		window.inspectorWrapper = new InspectorWrapper();
	});
	

</script>

