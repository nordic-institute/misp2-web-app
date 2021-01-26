/*
 * The MIT License
 * Copyright (c) 2019 Estonian Information System Authority (RIA)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

var Utils = new function() {
	
	/**
	 * Performs timeout checking request to server.
	 * If it is determined, that timeout has happened, then loads HTML indicating session expiration to page.
	 * Else if timeout warning message is sent from server, then it is displayed to the user.
	 */
	this.checkTimeout = function(){
		$.ajax({
			url: absoluteURL.getURL("checkTimeout.action"),
			data: {},
			type: "GET",
			async: true,
			cache: false,
			dataType: "html",
			success: function(data){
				data = Utils.extractJSON(data);
				if (data) {
					if (data.result=="true"){ //Session timeout warning message has been sent, so display it
						$("#timeoutOverlay").css("display","inline");
						$("#session_timeout_warning div:first").text(data.message);
					}
				}
			}
		});
	}

	/**
	 * Creates and submits HTML POST form dynamically, which is forwarded to URL indicated by url and which has that url parameters as hidden fields.
	 */
	this.postURL = function(url){
		var action = url.split("#")[0].split("?")[0];//First take part before hashtag and then take part before question mark (url without fragment and parameters)
		var params = $.deparam.querystring(url);
		var form$ = $("<form>").attr("action", action).attr("method", "post");
		$("body").append(form$);//Append form to body in order to make it's submit event bubble to document
		for(var key in params) {
			var paramsValue = params[key];
			var valueArray = ($.isArray(paramsValue) ? paramsValue : new Array(paramsValue));//Take params value as array
			for(var i=0; i<valueArray.length; i++){
				var value = valueArray[i];
				var input$ = $("<input>").attr("type", "hidden").attr("name", key).attr("value", value);
				form$.append(input$);
			}
		}
		form$.submit();
	}
	
	/**
	 * Displays loading overlay, which covers whole page, is partially transparent and displays loading indicator
	 */
	this.displayLoadingOverlay = function(){
		$("#loadingOverlay").css("display", "inline");
	}
	
	/**
	 * Hides loading overlay
	 */
	this.hideLoadingOverlay = function(){
		$("#loadingOverlay").css("display", "none");
	}
	
	$(document).ready(function(){//Apply events needed for functions
		$("#session_timeout_warning :button").click(function(){//Hide timeout warning div and send request to default page in order to reset timeout
    		$("#timeoutOverlay").css("display","none");
    		
    		$.ajax({
    			url: absoluteURL.getURL("login_user.action"),
    			type: "GET",
    			async: true,
    			cache: false
    		});
    	});		
	});
	
	/**
	 * Parse response JSON. If data is not JSON, load data as HTML to current page.
	 * @param str data as string, can be a JSON object or HTML
	 * @return false if data was not in JSON format;
	 * 	if data was in JSON format, return parsed JSON object of that data
	 */
	this.extractJSON = function(str) {
	    try {
			return jQuery.parseJSON(str);
	    } catch (e) {
			//if server did not returned correct json then that means that we were timed out and 
			// we got session expired html which we will load to page
			document.open();
			document.write(str);
			document.close();
			return false;
	    }
	}
	
	/**
	 * True if elements in two arrays are pairwise equal and
	 * array lengths match.
	 * @param ar1 first array
	 * @param ar2 second array
	 * @return true if arrays are equal, false if not
	 */
	this.arraysEqual = function(ar1, ar2) {
		if (ar1 === ar2) {
			return true;
		} else if (!ar1 || !ar2 || ar1.length != ar2.length) {
			return false;
		}

		for (var i = 0; i < ar1.length; ++i) {
			if (ar1[i] !== ar2[i]) return false;
		}
		return true;
	}

	/**
	 * Animate color change on jQuery element to direct attention to this element.
	 * @param jqEl jQuery-wrapped DOM element
	 * @param endColor final color of the widget as CSS string, normally the
	 *        initial background color
	 *        e.g '#FFF';
	 */
	this.animateNotification = function (jqEl, endColor) {
		var style = jqEl.attr("style");
		function doneHandler() {
			if (style) {
				jQuery(this).attr("style", style);
			} else {
				jQuery(this).removeAttr("style");
			}
		}
		jqEl.animate({backgroundColor:'#FEA'}, 100)
			.animate({backgroundColor: endColor}, 1500)
			.promise().done(doneHandler);
	}
};