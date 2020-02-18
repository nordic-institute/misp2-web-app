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

/**
 * Sending HTTP request and processing response
 */
restform.query = new function() {

	/**
	 * Assembles data from input form to JSON and sends to REST mediator.
	 * @param button send function trigger button
	 */
	this.send = function(button){
		var jqButton, jqForm;
		if (typeof button === 'string') { // if type is string, treat as ID attribute
			jqButton = jQuery("[id='" + button + "']");
		} else { // if type is DOM object, wrap with jQuery
			jqButton = jQuery(button);
		}

		jqForm = jqButton.closest("form");
		if (jqForm.length == 0) {
			jqForm = jqButton.find("form:eq(0)");
		}
	
		var assembleRequestFn = restform.event.getHandler(jqForm, "assembleRequest");
		var requestBuilder;
		if (assembleRequestFn) { // if registered, apply custom request assembling
			requestBuilder = assembleRequestFn(jqButton)
		} else { // else apply default request assembling
			requestBuilder = restform.query.getRequestBuilder(jqForm.attr("data-rf-content-type"), jqForm);
			
			var isInsideRepeatTemplateClass = "repeat-template-form-element";

			// just in case, remove temporary template input access blocking class from form,
			// if for some reason it has remained there
			jqForm.find("." + isInsideRepeatTemplateClass).removeClass(isInsideRepeatTemplateClass);
			
			// temporarily disable repeat template form elements by adding special class to them
			var selector = restform.util.concat(restform.input.inputSelector, restform.repeat.templateSelector);
			var jqRepeatTemplateFormElements = jqForm.find("[data-rf-repeat-template-path]").find(selector);
			jqRepeatTemplateFormElements.addClass(isInsideRepeatTemplateClass);
		
			// by default, if no 'data-rf-param-location' attribute is given for inputs, add attribute with 'body' value
			jqForm.find(restform.input.inputSelector).each(function() {
				var jqEl = jQuery(this);
				if (!jqEl.attr("data-rf-param-location")) {
					jqEl.attr("data-rf-param-location", "body");
				}
			});
		
			var headers = {
				"X-REST-Action": jqForm.attr("action"),
				"X-REST-Method": jqForm.attr("method")
			};
			var mainQueryId = jQuery("#main-query-id").val();
			if (mainQueryId) {
				headers["X-REST-main-query-id"] = mainQueryId;
			}
			var pathParams = {};
			var valid = true; // true all input fields have passed validation
			// assemble message body object from form input elements + populate header and URL parameters
			jqForm.find("input[type=hidden]," +
					" input[type=text]," +
					" input[type=number]," +
					" input[type=password]," +
					" input[type=radio]:checked," +
					" input[type=checkbox],"+
					" input[type=file],"+
					" textarea," +
					" select")
				.each(function() {
					var jqEl = jQuery(this);
					if (!jqEl.is(":disabled") && !jqEl.hasClass(isInsideRepeatTemplateClass) && !jqEl.hasClass("ignore-on-send")) {
						var fieldValid = restform.input.validate(jqEl);
						valid = valid && fieldValid;
						
						var name = jqEl.attr("name");
						var val = jqEl.val();
						if (jqEl.is("input[type=file].base64")) { // in case of base64 file, add base64 content as value
							val = jqEl.data("base64")
						}
						var dataParamLocation = jqEl.attr("data-rf-param-location");
						var checkbox = jqEl.attr("type") == "checkbox";
						var checked = checkbox && jqEl.is(":checked");
						var dataMultipartId = jqEl.attr("data-rf-multipart-id");
					
						// variable tells if value from input should be included into HTTP request body
						// by default include value, except in case of checkbox only include if it is checked
						var include = !checkbox || checkbox && checked;
						
						// process body parameters and all data multipart parameters including multipart headers with request builder
						if (dataParamLocation == "body" || dataMultipartId) {
							requestBuilder.appendElement(jqEl, name, val, checkbox, checked, include);
						
						} else if (dataParamLocation == "header") { // add parameter value to message header
							if (include) {
								headers["X-REST-Form-Header-" + name] = val;
							}
						
						} else if (dataParamLocation == "url") { // add parameter value to message URL parameters
							if (include) {
								pathParams[name] = val;
							}
						} else {
							console.warn("Could not add parameter '" + name + "'. Unknown data parameter class '" + dataParamLocation + "'.");
						}
					}
				});
			
			
			// Validate arrays (minItems, maxItems)
			jqForm.find("[data-rf-repeat-template-path]").each(function() {
				var jqRepeatTemplate = jQuery(this);
				if (!jqRepeatTemplate.hasClass(isInsideRepeatTemplateClass) && !jqRepeatTemplate.hasClass("ignore-on-send")) {
					// ignore if entry itself is within template
					var fieldValid = restform.repeat.validate(jqRepeatTemplate);
					valid = valid && fieldValid;
				}
			});
			
			// Remove temporary class from repeat templates
			jqRepeatTemplateFormElements.removeClass(isInsideRepeatTemplateClass);
			
			if (!valid) {
				//  jQuery bug: cannot refer to 'not-valid' class directly if it just got added to span
				var jqNotValid =  jqForm.find(".not-valid:eq(0), [class*=not-valid]:eq(0)");
				
				// if not valid, display an alert
				restform.util.notice("text.error.form_fields");

				// scroll to first error				
				jQuery('html, body').animate({
					scrollTop: jqNotValid.offset().top - 10
				}, 300 /* ms */);
				return;
			} else {
				jQuery("#alert").dialog("close")
			}

			// option to not send, only display message content (for development)
			if (restform.query.showOnly) {
				var jqMessageContainer = restform.jqRestForm.find("#message-container");
				if (jqMessageContainer.length == 0) { // if container is found, create it
					jqMessageContainer = jQuery("<pre>")
						.attr("id", "message-container");
					restform.jqRestForm.append(jqMessageContainer);
				}
				var contentType = requestBuilder.getContentType();
				if (contentType && (contentType.indexOf("json") || contentType.indexOf("text"))) {
					jqMessageContainer.text(requestBuilder.getData());
				} else {
					jqMessageContainer.text("Binary data (not shown " +  new Date() + ")");
				}
				return;
			}
			
			// Replace path parameters in action URL
			// e.g. '{id}' in action url '/path/{id}' gets replaced with 'id' param value
			for (var attr in pathParams) {
				if (pathParams.hasOwnProperty(attr)) {   
					var attrReplacementTemplate = "{" + attr + "}";
					if (headers["X-REST-Action"].indexOf(attrReplacementTemplate)) {
						headers["X-REST-Action"] =
							headers["X-REST-Action"].replace(attrReplacementTemplate, pathParams[attr]);
						delete pathParams[attr];
					}
				}
			}
			// Add target service URL parameters to mediator 'action' header
			var urlParams = jQuery.param(pathParams);
			if (urlParams) {
				headers["X-REST-Action"] = headers["X-REST-Action"] + "?" + urlParams;
			}
			
			var beforeSendFn = restform.event.getHandler(jqForm, "beforeSend");
			if (beforeSendFn) {
				beforeSendFn(requestBuilder, headers);
			}
		}
	
		// Display loading mask before running query
		Utils.displayLoadingOverlay();
		
		var csrfHeaderName = serverData.getCSRFHeaderName();
		var csrfToken = serverData.getCSRFToken();
		headers[csrfHeaderName] = csrfToken;
		
		var requestContentType = requestBuilder.getContentType();
		if (requestContentType) {
			headers["Content-Type"] = requestContentType;
		}
		
    	// If builder wants to give content disposition, add it to headers
    	if (requestBuilder.getContentDisposition && requestBuilder.getContentDisposition()) {
			headers["X-REST-Form-Header-Content-Disposition"] = requestBuilder.getContentDisposition();
    	}

		var jqOutputView = restform.view.getTargetView(jqButton);

		// Perform AJAX query
		var xhr = new XMLHttpRequest();
		var url = restform.query.mediatorUrl ? restform.query.mediatorUrl : absoluteURL.getURL("restMediator.action");
		var method = restform.query.mediatorMethod ? restform.query.mediatorMethod : "PUT";
		xhr.open(method, url, true);
		
		// In case output is single file, use arraybuffer for binary transmission
		// (this solution is inaccurate if JSON will be returned instead of the file, but there is a fallback mechanism
		// in json.ResponseHandler.handleResponse() - arraybuffer is converted to string)
		if (jqOutputView.children(".single-file").length > 0
				|| jqOutputView.children("[data-rf-content-type='multipart/form-data']")) {
		    xhr.responseType = "arraybuffer";
		}

	    xhr.onload = function(e) {
	    	restform.query.getSuccessHandler(jqForm, jqButton, jqOutputView)(xhr.response, xhr.statusText, xhr);
	    };
	    xhr.onerror = function (e) {
	    	var errorText = e.type;
	    	if (e.statusText) {
	    		errorText = errorText + " " + statusText;
	    	}
	    	restform.query.getFailureHandler(jqForm, jqButton)(xhr, errorText, e);
    	};
		for (var headerName in headers) {
			xhr.setRequestHeader(headerName, headers[headerName]);
		}
    	xhr.send(requestBuilder.getData());
	};

	this.getFailureHandler =  function(jqForm, jqButton) {
		return function (xhr, errorText, err){
			// Apply custom actions after data has been added
			var processResponseErrorFn = restform.event.getHandler(jqForm, "processResponseError");
			if (processResponseErrorFn) {
				data = processResponseErrorFn(jqButton, xhr, errorText, err);
			}
	
			restform.query.xhrError = xhr; // for debugging after error ocurred
			console.log(xhr, errorText, err);
				
			restform.util.error("restform.error.ajax.query.failed", errorText);

			Utils.hideLoadingOverlay();
		};
	};
	 
	
	this.getSuccessHandler =  function(jqForm, jqButton, jqOutputView) {
		return function(data, textStatus, xhr) {
			var processResponseFn = restform.event.getHandler(jqForm, "processResponse");
			if (processResponseFn) { // custom response processing
				obj = processResponseFn(data, xhr, jqButton);
			} else { // default response processing
				
				// Apply custom response post-processing
				var afterReceiveFn = restform.event.getHandler(jqForm, "afterReceive");
				if (afterReceiveFn) {
					data = afterReceiveFn(data, xhr, jqButton);
				}
				
				// Find response code
				var responseCode = xhr.getResponseHeader('X-REST-Response-Code');
				if (!responseCode) {
					restform.util.notice("text.session_expired");
					Utils.hideLoadingOverlay();
					return;
				}
				var responseText = xhr.getResponseHeader('X-REST-Response-Text');
				
				// Pick output block from output view based on status code
				var jqOutputBlock = restform.output.getOutputBlock(jqOutputView, responseCode);
				
				// Delete all previously existing repeat element data
				jqOutputBlock.find(".repeat-block").remove();
				// Reset all output values
				jqOutputBlock.find("[data-rf-path], [name]").each(function() {
					restform.output.setOutputElementVal(jQuery(this), "");
				});
				// Set header values
				jqOutputBlock.find("[data-rf-param-location=header]").each(function() {
					var jqEl = jQuery(this);
					var valueCanBeSet = restform.output.setOutputElementVal(jqEl, "");
					if (valueCanBeSet) {
						var headerName = restform.output.getOutputElementName(jqEl);
						var headerValue = restform.util.getCustomResponseHeader(xhr, headerName);
						
						if (headerValue) {
							restform.output.setOutputElementVal(jqEl, headerValue);
						}
					}
				});
				// Add HTTP status code explanation to header
				jqOutputBlock.find(".resp-code").attr("title", responseText);
				
				// Populate output block with response data
				var responseContentType = restform.util.getCustomResponseHeader(xhr, 'Content-Type');
				var responseContentDisposition = restform.util.getCustomResponseHeader(xhr, 'Content-Disposition');
				var responseHandler = restform.query.getResponseHandler(responseContentType, jqOutputBlock);
				var handlerParams =  {};
				handlerParams.contentType = responseContentType;
				handlerParams.filterSelector = "";
				
				handlerParams.contentDisposition = restform.headers.parseHeaders("Content-Disposition:" + responseContentDisposition).contentDisposition;
				responseHandler.handleResponse(jqOutputBlock, data, handlerParams);
				
				// Hide optional empty fields
				jqOutputBlock.find(".optional").each(function() {
					var jqEl = jQuery(this);
					var value = restform.output.getOutputElementVal(jqEl);
					
					// If parent type is field, hide/show the entire field
					if (jqEl.parent().hasClass("field")) {
						jqEl = jqEl.parent();
					}
					
					// If value is not set, hide field, otherwise show field
					if (!value) {
						jqEl.hide();
					} else {
						jqEl.show();
					}
				});
	
				// Apply custom actions after data has been added
				var afterResponseDataAddedFn = restform.event.getHandler(jqForm, "afterResponseDataAdded");
				if (afterResponseDataAddedFn) {
					afterResponseDataAddedFn(responseHandler.getProcessedData(), jqButton, jqOutputBlock);
				} else {
					// show output
					restform.view.toggleToView(jqOutputBlock);
					// Hide loading overlay
					Utils.hideLoadingOverlay();
				}
			}
		}
	};
	
	/**
	 * Assembles data from input form to HTTP request body to be sent to REST mediator.
	 */
	this.getRequestBuilder = function(contentType, jqRequestContainer){
		var requestBuilder;
		if (!contentType || contentType.indexOf("text/") == 0) {
			requestBuilder = new restform.text.TextRequestBuilder(contentType);
		} else if (contentType.indexOf("json") >= 0) {
			requestBuilder = new restform.json.JsonRequestBuilder(null);
		} else if (contentType.indexOf("multipart/") == 0) {
			requestBuilder = new restform.multipart.MultipartRequestBuilder();
		} else {
			requestBuilder = new restform.file.FileRequestBuilder(contentType);
		}

		// In case we have an object initializer, use it
		if (requestBuilder.initializeObject && requestBuilder.initializeObject.constructor === Function) {
			requestBuilder.initializeObject(jqRequestContainer);
		}
		
		console.log("Returning request builder", requestBuilder);
		return requestBuilder;
	};
	
	/**
	 * Assembles data from input form to JSON and sends to REST mediator.
	 */
	this.getResponseHandler = function(contentTypeFromResponse, jqOutputBlock){
		var responseHandler;
		var contentType = jqOutputBlock.attr("data-rf-content-type");
		if (!contentType) {
			contentType = contentTypeFromResponse;
		}
		if (contentType != null && contentType.indexOf("/json") >= 0) {
			responseHandler = new restform.json.JsonResponseHandler();
		} else if (contentType == null || contentType.indexOf("text/") >= 0) {
			responseHandler = new restform.text.TextResponseHandler(contentType);
		} else if (contentType != null && contentType.indexOf("multipart/form-data") == 0) {
			responseHandler = new restform.multipart.MultipartResponseHandler(contentType);
		} else {
			// TODO handle text/html session ended error
			responseHandler = new restform.file.FileResponseHandler(contentType);
		}
		console.log("Returning response handler", responseHandler);
		return responseHandler;
	};
};


