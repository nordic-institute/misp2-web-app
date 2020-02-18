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
 * Output HTML node access and setting its value.
 */
restform.output = new function() {
	this.outputSelector = "[name], [data-rf-path]";

	/**
	 * Get output element value.
	 * @param jqOutputEl
	 *            jQuery output element wrapper
	 * @return output element value
	 */
	this.getOutputElementVal = function(jqOutputEl) {
		if (typeof (jqOutputEl.attr("name")) != 'undefined') {
			return jqOutputEl.val();
		} else if (typeof (jqOutputEl.attr("data-rf-path")) != 'undefined' ) {
			var jqOptions = jqOutputEl.children("[data-rf-option]"); 
			if (jqOptions.length > 0) { // select-output, display suitable option
				var jqOptionSelected = null;
				jqOptions.each(function() {
					var jqOption = jQuery(this);
					if (jqOption.hasClass("selected")) {
						jqOptionSelected = jqOption; 
					}
				});
				if (jqOptionSelected) {
					return jqOptionSelected.attr("data-rf-option");
				} else {
					return null;
				}

			} else { // normal text output; fill output with value
				return jqOutputEl.text();
			}
		}
	};

	/**
	 * Find output element by path and set the element to given value.
	 * @param jqOutputBlock
	 *            jQuery container form output elements
	 * @param outputVal
	 *            value to be given to output element
	 * @param path
	 * 				output element name or data-rf-path attribute value.
	 *				This is used to find output element from the container.
	 *            	In case of JSON, JSONPath of output element in JSON response.
	 * @param filterSelector additional jQuery selector for filtering input elements
	 * @return true, if output value was displayed;
	 *         false, if respective output value element was not found
	 */
	this.setOutputVal = function(jqOutputBlock, outputVal, path, filterSelector) {
		var selector;
		if (filterSelector) {
			selector = "[name='" + path + "']" + filterSelector + ", [data-rf-path='" + path + "']" + filterSelector;
		} else {
			selector = "[name='" + path + "'], [data-rf-path='" + path + "']";
		}
		var jqOutputEl = jqOutputBlock.find(selector);
		return restform.output.setOutputElementVal(jqOutputEl, outputVal);
	};

	/**
	 * Set output element value to given value.
	 * @param jqOutputEl
	 *            jQuery output element wrapper
	 * @param outputVal
	 *            value to be given to output element
	 * @return true, if output value was set, false if not
	 */
	this.setOutputElementVal = function(jqOutputEl, outputVal) {
		if (typeof (jqOutputEl.attr("name")) != 'undefined') {
			jqOutputEl.val(outputVal);
			return true;
		} else if (typeof (jqOutputEl.attr("data-rf-path")) != 'undefined' ) {
			var jqOptions = jqOutputEl.children("[data-rf-option]"); 
			if (jqOptions.length > 0) { // select-output, display suitable option
				jqOptions.removeClass("selected");
				var attributeFound = false;
				jqOptions.each(function() {
					var jqOption = jQuery(this);
					if (jqOption.attr("data-rf-option") == "" + outputVal) {
						jqOption.addClass("selected");
						attributeFound = true;
					}
				});
				// if attribute was not found, search for default and select that
				if (!attributeFound) {
					jqOptions.each(function() {
						var jqOption = jQuery(this);
						if (jqOption.attr("data-rf-option") == "default") {
							jqOption.addClass("selected");
						}
					});
				}
			
			} else { // normal text output; fill output with value
				
				// Convert date to regional format if possible
				outputVal = restform.dateutil.formatDate(outputVal, jqOutputEl);
				
				// set output value
				jqOutputEl.text(outputVal);
			}
			return true;
		}
		return false;
	};

	/**
	 * Find the path of output element.
	 * @param jqOutputEl
	 *            jQuery output element wrapper
	 * @return output element 'name' or 'data-rf-path' attribute value
	 */
	this.getOutputElementName = function(jqOutputEl) {
		var name = jqOutputEl.attr("name");
		var dataName = jqOutputEl.attr("data-rf-path");
		if (typeof dataName != 'undefined') {
			return dataName;
		} else if (typeof name != 'undefined' ) {
			return name;
		}
		return null;
	};

	/**
	 * Find output block from within output view based on response code.
	 * If response code specific block was not found, return default block.
	 * If default block itself is not found, return output view.
	 * @param jqOutputView output view jQuery element where output block is looked up from.
	 *        Output blocks can only be a direct child of given block.
	 * @param responseCode HTTP response code corresponding to output blocks "data-rf-resp-code" attribute value.
	 * @return output block jQuery element.
	 */
	this.getOutputBlock = function(jqOutputView, responseCode) {

		// Hide all response blocks within view
		jqOutputView.children("[data-rf-resp-code]").hide();

		// If response code specific output block exists, pick that as output block
		var jqResponseCodeOutputBlock = jqOutputView.children("[data-rf-resp-code='" + responseCode + "']");

		// If output block was not found, try to find one with matching wildcard code, e.g. 5XX, 41X
		if (!jqResponseCodeOutputBlock || jqResponseCodeOutputBlock.length == 0) {
			var respCodeBlockMap = restform.output.getRespCodeBlockMap(jqOutputView);
			jqResponseCodeOutputBlock =
				restform.output.getBestMatchingOutputBlock(respCodeBlockMap, responseCode);
		}
		
		// If output was still not found, pick default output block
		if (!jqResponseCodeOutputBlock || jqResponseCodeOutputBlock.length == 0) {
			jqResponseCodeOutputBlock = jqOutputView.children("[data-rf-resp-code='default']")
		}
		// If a specific output block was found, show that and only populate that block
		if (jqResponseCodeOutputBlock && jqResponseCodeOutputBlock.length != 0) {
			jqResponseCodeOutputBlock.show();
			return jqResponseCodeOutputBlock; // change output block to response-specific block
		} else {
			return jqOutputView; // if response-specific block was not found, return output view container
		}
	};

	/**
	 * For a given output view return map of response codes (in string form) mapped to
	 * response blocks.
	 * @param jqOutputView output view jQuery element container
	 * @return map of data response codes mapped to response block jQuery elements in output
	 */
	this.getRespCodeBlockMap = function(jqOutputView) {
		var respMap = {};
		jqOutputView.children("[data-rf-resp-code]").each(function () {
			var jqEl = jQuery(this);
			var blockRespCode = jqEl.attr("data-rf-resp-code");
			respMap[blockRespCode] = jqEl;
		});
		return respMap;
	};
	
	/**
	 * Get output block from response map with best matching response code to the actual
	 * received response code.
	 * Function enables matching wildcards in block response codes, e.g. 5XX, 20X.
	 * @param respMap map of data response codes mapped to response block jQuery elements in output
	 * @param receivedRespCode received HTTP response code
	 * @return best matching response code block for received response code
	 */
	this.getBestMatchingOutputBlock = function(respMap, receivedRespCode) {
		var receivedRespCode = "" + receivedRespCode; // convert to string just in case it is numeral
		var matchingRespCode = null;
		var matchingRespCodeScore = null; // the bigger score the more specific selector
										  // E.g. 4XX - score 4, 42X - score 6, 421 - score 7, XX1 - score 1
		for (var blockRespCode in respMap) {
			if (blockRespCode && blockRespCode.length == receivedRespCode.length) {
				var matches = true;
				var respCodeScore = 0;
				for (var i = 0; i < blockRespCode.length; i++) {
					var cBlockRespCode = blockRespCode[i];
					var cReceivedRespCode = receivedRespCode[i];
					if (cBlockRespCode.toUpperCase() == "X") { // wildcard, matches everything
						// wildcard: do not add anything to the score: respCodeScore += 0;
						continue;
					} else if (cBlockRespCode == cReceivedRespCode) { // response code digit matches exactly
						respCodeScore += Math.pow(2, (blockRespCode.length - i - 1));
						continue;
					} else { // response code digit does not match
						matches = false;
						break;
					}
				}
				// if match is found and no prior match exists or the match has better score, update best match
				if (matches && (!matchingRespCode || respCodeScore > matchingRespCodeScore)) {
					matchingRespCode = blockRespCode;
					matchingRespCodeScore = respCodeScore;
				}
			}
		}
		
		if (matchingRespCode) { // if code was found, return respective response block map entry
			return respMap[matchingRespCode];
		} else { // matching code was not found, return null
			return null;
		}
	};
	
	/**
	 * Create output field with label and append it to container element.
	 * @param jqContainer jQuery container element where created field is added
	 * @param outputLabelText text of output label.
	 * @param path field name or path (used as a marker in field container 'data-rf-for' attribute)
	 * @param dataParamLocation optional argument of output field 'data-rf-param-location' attribute
	 */
	this.appendOutputField = function (jqContainer, outputLabelText, path, outputValue, dataParamLocation) {
		if (!dataParamLocation) {
			dataParamLocation = "body";
		}
		jqContainer.append(
			jQuery("<div>", { "class": "field", "data-rf-for": path}).append(
				jQuery("<label>").text(outputLabelText)
			).append(
				jQuery("<span>", {"class": "output-field", "data-rf-param-location": dataParamLocation}).text(outputValue)
			)
		);
	}
};
