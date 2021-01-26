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
 * HTTP header parsing helper functions
 */
restform.headers = new function() {

	/**
	 * Parses MIME headers out of multipart response header section string.
	 */
	this.parseHeaders = function(text) {
		var parsedHeaders = {
				allHeaders: [ /* list of {name: ..., value: ...} objects are put inside here*/ ]
		}; 
		
		// Parse input header text blob
		if (!text) { // avoid error when no arguments are given
			text = "";
		}
		var headerLines = text.split("\r\n");
		for (var i = 0; i < text.length; i++) {
			var headerLine = jQuery.trim(headerLines[i]);
			if (headerLine && headerLine.length > 0) {
				var sepIndex = headerLine.indexOf(":");
				if (sepIndex != -1) {
					var headerName = jQuery.trim(headerLine.substring(0, sepIndex));
					var headerValue = jQuery.trim(headerLine.substring(sepIndex + 1, headerLine.length));
					
					// Put header to list
					parsedHeaders.allHeaders[parsedHeaders.allHeaders.length] ={
							name: headerName,
							value: headerValue
					};
					
					// Assign more common headers to separate variables
					if (headerName.toLowerCase() == "Content-Type".toLowerCase()) {
						parsedHeaders.contentType = headerValue;
					} else if (headerName.toLowerCase() == "Content-Disposition".toLowerCase()) {
						var contentDisposition = {text: headerValue};
						
						// Get various sub-fields from the header
						var subheaders = this.parseSubheaders(headerValue);
						contentDisposition.subheaders = subheaders;
						
						var filenameObj = restform.util.getFirstValueByKey(subheaders, "filename*", "name", null);
						if (!filenameObj) {
							filenameObj = restform.util.getFirstValueByKey(subheaders, "filename", "name", null);
						}
						if (filenameObj) {
							var filename = filenameObj ? filenameObj.value : null;
							
							// Get rid of awkward UTF-8'' legacy syntax if exists
							var filenameUnescaped = jQuery.trim(filenameObj.unescapedValue);
							if (filenameObj.unescapedValue && filenameUnescaped.indexOf("UTF-8''") == 0) {
								filename = filenameUnescaped.substring("UTF-8''".length, filenameUnescaped.length);
							}
							
							// URL-decode if needed
							if (filename.indexOf("%") != -1) { // in case of '%' signs, try to decode URI
								try {
									filename = decodeURI(filename);
								} catch (e) {
									log.warn("Failed to decode URI " + filename + ". Ignoring.", e);
								}
							}
							contentDisposition.filename = filename;	
						}
						
						
						// Get multipart name
						contentDisposition.name = restform.util.getFirstValueByKey(subheaders, "name");
						
						// Check if attachment key exists 
						var attachment = restform.util.getFirstValueByKey(subheaders, "attachment", "name", null);
						 // true if attachment is there, false if not
						contentDisposition.attachment = !!attachment;
						
						// assign parsed values to returned object
						parsedHeaders.contentDisposition = contentDisposition;
						
					} else if (headerName.toLowerCase() == "Content-Length".toLowerCase()) {
						parsedHeaders.contentLength = headerValue;
					} else if (headerName.toLowerCase() == "Content-transfer-encoding".toLowerCase()) {
						parsedHeaders.contentTransferEncoding = headerValue;
					}
				}
			}
		}
		return parsedHeaders;
	};
	this.parseSubheaders = function (headerValue) {
		 // make sure there is ';' line ending for proper parsing. Add it if missing.
		if (!/;\s*$/.test(headerValue)) {
			headerValue = jQuery.trim(headerValue) + ';';
		}
		var readingName = 1; // loop is reading name state
		var readingValue = 2; // loop is reading value
		var quote = null; // null for no quote, otherwise " or '
		var escaped = false; // true if value was previously escaped with '\'
		var text = ""; // accumulate text here (used for both, name and value texts)
		var unescapedValue = ""; // accumulate value also as unescaped string
		var name = null;
		var c; // current char
		var cPrev = null; // previous char
		var headers = [];
		
		var state = readingName;
		for (var i = 0; i < headerValue.length; i++) {
			c = headerValue[i];
			if (state == readingName) {
				if (c == '=') {
					name = jQuery.trim(text);
					text = "";
					state = readingValue;
				} else if (c == ';') {
					name = jQuery.trim(text);
					headers[headers.length] = {name: name};
					text = "";
					state = readingName;
				} else {
					text += c;
				}
			} else if (state == readingValue) {
				if (!quote && c == ';') { // if value ends
					headers[headers.length] = {name: name, value: jQuery.trim(text), unescapedValue: unescapedValue};
					unescapedValue = "";
					text = "";
					state = readingName;
				} else { // else keep reading value
					unescapedValue += c;
					if (!quote && (c == '\'' || c == '"') && !escaped) {
						quote = c;
					} else if (quote && c == quote && !escaped) {
						quote = null;
					} else if (c == '\\' && escaped) {
						text += c;
						escaped = false;
					} else if (c == '\\' && !escaped) {
						escaped = true;
					} else if (escaped){
						escaped = false;
						text += c;
					} else {
						text += c;
					}
				}
			}
			cPrev = c;
		}
		return headers;
	};
};
