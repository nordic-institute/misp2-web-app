/*
 * The MIT License
 * Copyright (c) 2020- Nordic Institute for Interoperability Solutions (NIIS)
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
 * Multipart (Content-Type: multipart/form-data) request building and response handling.
 */
restform.multipart = new function() {
	/**
	 * Construct multipart request builder object instance (should be called with 'new').
	 * @param contentType request content type
	 */
	this.MultipartRequestBuilder = function() {

		this.multipartIds = []; // use array of multipart ID-s to keep multipart section order
		this.multiparts = {}; // map {multipartId:multipartData}

		this.initializeObject = function (jqForm) {
			var builder = this;
			jqForm.find(".multipart-info:not(.for-multipart-repeat-template)").each(function (){
				var jqEl = jQuery(this);
				var multipartId = jqEl.attr("data-rf-multipart-id");
				if (!multipartId) {
					multipartId = undefined;
				}
				var contentType = jqEl.attr("data-rf-content-type");
				builder.multipartIds[builder.multipartIds.length] = multipartId;
				var requestBuilder = restform.query.getRequestBuilder(contentType);
				var multipartPropertyName = jqEl.attr("data-rf-multipart-property-name");
				var filter = "[data-rf-multipart-id='" + multipartPropertyName + "']";
				var multipartData = {
						requestBuilder: requestBuilder,
						headers: [],
						propertyName: multipartPropertyName,
						multipartId: multipartId,
						filter: filter
				};
				builder.multiparts[multipartId] =  multipartData;
				// In case sub-request-builder has an object initializer, run it
				if (requestBuilder.initializeObject && requestBuilder.initializeObject.constructor === Function) {
					requestBuilder.initializeObject(jqForm, filter);
				}
			});
		};
		this.appendElement = function (jqEl, name, val, checkbox, checked, include){
			var multipartId = jqEl.attr("data-rf-multipart-id");
			
			if (!multipartId) {
				multipartId = undefined;
			}
			// find request builder for current field
			var multipart = this.multiparts[multipartId];
			if (!multipart) {
				console.error("Cannot add data to request. Multipart info was not found for element ", jqEl[0]);
				return;
			}
			var dataParamLocation = jqEl.attr("data-rf-param-location");
			if (dataParamLocation == "uri") { // in case there are multipart-specific URI, ignore it
				console.warn("Cannot add multipart '" + multipartId + "' uri parameter '" + name + "=" + val + "'"
						+ ". Multiparts do not have URI-s. Ignoring.");
			} else if (dataParamLocation == "header") { // in case there are multipart-specific headers
				multipart.headers[multipart.headers.length] = {name: val};
				console.warn("Cannot send multipart '" + multipartId + "' header '" + name + ": " + val + "'"
						+ ". Javascript API limitation.");
			} else { // normal case: otherwise delegate to request builder
				var requestBuilder = multipart.requestBuilder;
				// proxy all function arguments to requstBuilder.appendElement()
				requestBuilder.appendElement.apply(requestBuilder, arguments);
			}
		};
		this.getContentType = function () {
			return false; // if set to false, builds multipart content type with boundary
		};
		this.getData = function() {
			var formData = new FormData();
			for (var i = 0; i != this.multipartIds.length; i++) {
				var multipartId = this.multipartIds[i];
				var multipart = this.multiparts[multipartId];
				
				var data = multipart.requestBuilder.getData();
				
				// Wrap JSON in blob
				if (contentType == "application/json") {
					if (!(data instanceof Blob)) { // if data is plain text, but content type is defined, wrap data to blob
						var contentType = multipart.requestBuilder.getContentType();
						if (contentType) {
							console.log("Wrapping data", data)
							data = new Blob([data], {type: contentType});
						}
					}
				}
				// console.log("Multipart", multipartId, multipart, data);
				formData.append(multipart.propertyName, data);
			}
			return formData;
		};
	};
	

	/**
	 * Handle multipart response by first extracting multipart sections from response along with its MIME headers,
	 * then invoking a suitable response handler for each received multipart section.
	 */
	this.MultipartResponseHandler = function() {
		this.multipartResponse = null;
		this.handleResponse = function (jqOutputBlock, data, params) {
			if (!(data instanceof ArrayBuffer)) {
				restform.util.error("Response expected to be ArrayBuffer for multipart. Received " + data.constructor + ".");
				console.error("Response is not binary", (data ? data.constructor : null), data);
				return;
			}
			
			// Get subheader name-value pairs(like charset=.. and boundary=..) from content type header value
			var contentTypeSubheaders = restform.headers.parseSubheaders(params.contentType);
			var boundary = restform.util.getFirstValueByKey(contentTypeSubheaders, "boundary");
			
			if (boundary.length < 1) {
				restform.util.error("Error receiving multipart/form-data content."
						+ " Did not receive proper boundary. Received '" + boundary + "'. Content-Type: " + params.contentType);
				return;
			}
			var boundaryBytes = restform.arrayutil.stringToBytes(boundary);
			
			var dataBytes = new Uint8Array(data)
			var indexes = restform.arrayutil.findAll(dataBytes, boundaryBytes);
			console.log("Multipart boundary: '" + boundary + "'", "Boundary indexes: "+ indexes, "Size: " + dataBytes.length);
			if (indexes.length < 2) {
				restform.util.error("Error extracting multipart/form-data content."
						+ " Boundary detected " + indexes.length + " times. Minimum 2 boundary entries required.");
				return;
			}

			var crcr = restform.arrayutil.stringToBytes("\r\n\r\n");
			for (var i = 1; i < indexes.length; i++) {
				var startIndex = indexes[i - 1] + boundaryBytes.length;
				var contentStartIndex = restform.arrayutil.findNext(
						dataBytes, crcr, {startIndex: startIndex}) + crcr.length;
				var newBoundStartIndex = indexes[i] - 4; // 4 bytes preceed the bounary: '\r', 'n', '-' and '-'
				console.log ("Header start:", startIndex, "end:", contentStartIndex, "size:", contentStartIndex - startIndex)
				var headerSize = contentStartIndex - startIndex;
				if (headerSize > 10000) { // sanity check for header size: 10kB maximum
					restform.util.error("Error extracting multipart/form-data content."
							+ " Attachment header " + indexes.length + " size was unreasonably large ("
							+ headerSize + "B). Max 10kB allowed. Response is possibly corrupt");
					continue;
				}
				// Slice header data from data array and convert to string form
				var headerData = restform.arrayutil.arrayToUtf8String(dataBytes.slice(startIndex, contentStartIndex));
				var headers = restform.headers.parseHeaders(headerData);

				console.log(i + ".");
				console.log("Content-Type", headers.contentType);
				console.log("Content-Length", headers.contentLength);
				if (!headers.contentDisposition) {
					restform.util.error("Error extracting multipart/form-data content."
							+ " Missing required Content-Disposition header.");
					continue;
				} else if (!headers.contentDisposition.name) {
					restform.util.error("Error extracting multipart/form-data content."
							+ " Attribute 'name' missing from Content-Disposition header. Cannot link response to service output.");
					continue;
				}
				
				var multipartPropertyName = headers.contentDisposition.name;

				var filter = "[data-rf-multipart-id='" + multipartPropertyName + "']";
				var jqMultipartInfo = jqOutputBlock.find(filter + ".multipart-info");
				// Headers extracted, handle response
				var responseHandler = restform.query.getResponseHandler(headers.contentType, jqMultipartInfo);
				var handlerParams =  {};
				handlerParams.contentType = headers.contentType;
				handlerParams.contentDisposition = headers.contentDisposition;
				var jqMultipartFields = jqOutputBlock.find(filter + ":not(.multipart-info)");

				var jqTarget; // block or blocks where output data is inserted to
				if (jqMultipartInfo.hasClass("for-multipart-repeat-template")) {
					// find multipart repeat template
					var jqMultipartRepeatTemplate = jqMultipartFields.filter(function() {
						return jQuery(this).is(filter + ".multipart-repeat-template");
					});
					jqTarget = restform.repeat.addBlockFromRepeatTemplate(jqMultipartRepeatTemplate);
					filter = "[data-rf-multipart-id='" + jqTarget.attr("data-rf-multipart-id") + "']"
				} else {
					jqTarget = jqOutputBlock;
				}
				
				handlerParams.filterSelector = filter;
				console.log("Target for " + filter + " ", jqTarget.length, jqTarget[0])
				// Delegate to content type handler
				responseHandler.handleResponse(jqTarget,
						dataBytes.slice(contentStartIndex, newBoundStartIndex), handlerParams);
			}
			
			/*if (!(data instanceof ArrayBuffer)) {
				restform.util.error("Response not multipart.");
				console.error("Response is not FormData object, cannot disassemble multipart", data);
				return;
			}*/
			
		}
		this.getProcessedData = function () {
			return this.multipartResponse;
		}
	};
	
	/**
	 * Called if multipart block was added (cloned).
	 */
	this.handleMultipartCloned = function (jqRepeatBlock, multipartId, index) {
		if (!this.cloneCount) {
			this.cloneCount = 1;
		} else {
			this.cloneCount += 1;
		}
		var newMultipartId = multipartId + "-" + this.cloneCount
			+ "-" + Math.random().toString(36).substr(2, 5); // add random suffix to avoid duplicates
		
		jqRepeatBlock.attr("data-rf-multipart-id", newMultipartId);
		jqRepeatBlock.find("[data-rf-multipart-id='" + multipartId + "']").each(function() {
			var jqEl = jQuery(this);
			jqEl.attr("data-rf-multipart-id", newMultipartId);
		});
		
		// find existing multipart info block
		var multipartInfoSelector = "[data-rf-multipart-property-name='" + multipartId + "'].multipart-info";
		var jqMultipartInfoNew = jqRepeatBlock.find(multipartInfoSelector);
		if (jqMultipartInfoNew.length == 0) { // if multipart info is not in cloned block, find it in output and clone
			// find first existing block from a list of blocks in the order of priority
			var jqOutputBlock = jQuery(
					jqRepeatBlock.closest("[data-rf-resp-code]")[0]
					|| jqRepeatBlock.closest("form")[0]
					|| jqRepeatBlock.closest(".view")[0]
					|| jqRepeatBlock.parent().parent()[0]
			);
			var jqMultipartInfo = jqOutputBlock.find(multipartInfoSelector);
			// clone multipart info blocks, since it was not cloned with jqRepeatBlock
			jqMultipartInfoNew = jqMultipartInfo.clone();
			// insert before current block
			jqRepeatBlock.prepend(jqMultipartInfoNew);
		}
		
		jqMultipartInfoNew.attr("data-rf-multipart-id", newMultipartId);
		jqMultipartInfoNew.removeClass("for-multipart-repeat-template");
		jqMultipartInfoNew.addClass("from-multipart-repeat-template");
		
		jqRepeatItemCount = jqMultipartInfoNew.children(".repeat-item-count");
		if (jqRepeatItemCount.length) {
			jqRepeatItemCount.text("(" + (index + 1) + ")");
		}
	};

	/**
	 * Called if multipart block was deleted (cloned).
	 */
	this.handleMultipartDeleted = function (jqRepeatBlock, multipartId) {
		var index = jqRepeatBlock.prevAll(".repeat-block").length - 1;
		jqRepeatBlock
			.find(".from-multipart-repeat-template")
			.children(".repeat-item-count")
			.text("(" + (index + 1) + ")");
	};
	
	/**
	 * Filter multipart blocks from output with given filter selector.
	 */
	this.getMultipartOutputBlock = function(jqOutputBlock, params) {
		if (params.filterSelector) {
			var jqOutput = jqOutputBlock.find(filterSelector);
			if (jqOutput.length > 1) {
				if (typeof params.arrayIndex === 'undefined') {
					console.warn("Found attachment array in output, but no index was given.");
					return jqOutputBlock;
				}
				var jqOutputSingle = jqOutput[0];
				jqOutput.each(function(index) {
					if (params.arrayIndex == index) {
						jqOutputSingle = jQuery(this);
					}
				});
				jqOutput = jqOutputSingle;
			}
			if (jqOutput.length == 1) {
				return jqOutput;
			}
		}
		return jqOutputBlock;
	};
	
	/**
	 * Add multipart ID attribute for elements within multipart-info block.
	 * @param jqContainer container block from where to find multipart-info blocks from
	 */
	this.addMultipartIdAttributes = function (jqContainer) {
		jqContainer.find(".multipart-info").each(function() {
			var jqMultipartInfo = jQuery(this);
			var multipartId = jqMultipartInfo.attr("data-rf-multipart-id");
			var selector = restform.util.concat(
					restform.input.inputSelector, restform.repeat.templateSelector, restform.output.outputSelector);
			jqMultipartInfo.find(selector).each(function() {
				jQuery(this).attr("data-rf-multipart-id", multipartId);
			});
			// Add content type to title attribute
			var contentType = jqMultipartInfo.attr("data-rf-content-type");
			if (contentType) {
				jqMultipartInfo.attr("title", contentType);
			}
		});
	};
};
