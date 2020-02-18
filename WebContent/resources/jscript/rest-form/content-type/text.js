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
 * Request building and response handling.of text/* content type
 */
restform.text = new function() {
	/**
	 * Construct plain text request builder object instance (should be called with 'new').
	 * @param contentType request content type
	 */
	this.TextRequestBuilder = function(contentType) {
		this.text = "";
		this.contentType = contentType;
		
		this.appendElement = function (jqEl, name, val, checkbox, checked, include){
			this.text = this.text + val;
		}
		this.getContentType = function () {
			return this.contentType;
		}
		this.getData = function() {
			return this.text;
		}
	};

	/**
	 * Class to handle plain/text response.
	 * Class is initialized with 'new' from query.js.
	 */
	this.TextResponseHandler = function(contentType) {
		this.data = "";
		this.contentType = contentType; // not used, kept just for info
		this.handleResponse = function (jqOutputBlock, data, params) {
			// if response came from array buffer, deal with it
			data = restform.arrayutil.convertArrayBufferToText(data);
			this.data = data;
			var jqOutputNode = jqOutputBlock.find("[data-rf-path]" + params.filterSelector);
			if (jqOutputNode.length == 0) {
				jqOutputNode = jqOutputBlock;
			}
			var jqContentContainer = jqOutputNode.find(".dynamic");
			if (jqContentContainer.length == 0) {
				var jqContentContainer = jQuery("<div>", {"class": "dynamic"});
				jqOutputNode.append(jqContentContainer);
			}
			jqContentContainer.text(data);
		}
		
		this.getProcessedData = function () {
			return this.data;
		}
		
	};
};