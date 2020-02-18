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
 * JSON object building, traversal and JSONPath functions.
 */
restform.json = new function() {

	/**
	 * Construct JSON request builder object instance with 'new'.
	 * @param contentType request content type
	 */
	this.JsonRequestBuilder = function(contentType) {
		this.contentType = contentType ? contentType : "application/json; charset=utf-8";
		this.obj = null;

		this.initializeObject = function (jqContainer, filterSelector) {
			var found = false;
			if (this.obj == null && jqContainer != null && jqContainer.length != 0) {
				if (!filterSelector) {
					filterSelector = "";
				}
				var jqEl = jqContainer.find(
						  filterSelector + "[data-rf-repeat-template-path]:eq(0), "
						+ filterSelector + "[name]:eq(0), "
						+ filterSelector + "[data-rf-path]:eq(0)"
				).first();
				if (jqEl.attr("name") || jqEl.attr("data-rf-path") || jqEl.attr("data-rf-repeat-template-path") != "") {
					this.obj = {};
					found = true;
				} else if (jqEl.attr("data-rf-repeat-template-path") == "") {
					this.obj = [];
					found = true;
				}
				found = false;
			} else {
				found = true;
			}

			//console.log("Request object initialized to", this.getData());
			return found;
		};
		
		this.appendElement = function (jqEl, name, val, checkbox, checked, include) {
			// value JSON data type is determined by "data-rf-type" attribute
			// in case the attribute is missing, by default JSON data type is String
			var dataType = jqEl.attr("data-rf-type");
			
			if (jqEl.attr("type") == "file") { // always use base64 content for files in JSON
				val = jqEl.data("base64");
			} else if (dataType) {
				if (dataType == "boolean") { // JSON boolean value conversion
					if (checkbox) {
						val = checked;
						include = true; // always include boolean from checkbox, checked or unchecked
					} else {
						val = val && (val == "true" || val == "1");
					}
				} else if (dataType == "integer") { // integer value conversion
					val = parseInt(val);
				} else if (dataType == "number") { // integer value conversion
					val = parseFloat(val);
				} else if (dataType == "date") { // conversion to standard date value
					if (jqEl.val() && jqEl.hasClass("hasDatepicker") && jqEl.datepicker('getDate')) { // avoid processing empty date
						var date = jqEl.datepicker('getDate');
						var jqTime = jqEl.parent().children(".time");
						if (jqTime.length != 0) {
							var time = jqTime.val();
							try {
								restform.dateutil.setTime(date, jqTime);
							} catch (e) {
								console.error(e);
							}
							val = date.toJSON();
						} else {
							val = jQuery.datepicker.formatDate("yy-mm-dd", date);
						}
						
					} else {
						val = jqEl.val();
					}
				} // else val remains string
			}
			if (include) {
				this.obj = restform.json.assignToObject(this.obj, name, val);
			}
			
		};
		
		this.getContentType = function () {
			return this.contentType;
		};
		
		this.getData = function() {
			if (this.obj == null) {
				this.jqRequestContainer
			}
			return JSON.stringify(this.obj, null, 4);
		};
	};

	this.JsonResponseHandler = function() {
		this.jsonData = null;
		this.handleResponse = function (jqOutputBlock, data, params) {
			data = restform.arrayutil.convertArrayBufferToText(data);
			var jsonData;
			if (typeof data === 'string') {
				jsonData = Utils.extractJSON(data);
			} else {
				jsonData = data;
			}
			this.jsonData = jsonData;
			var jqDynamicContentBlock = jqOutputBlock.find(params.filterSelector + " .dynamic:eq(0)");
			if (jqDynamicContentBlock.length > 0) { // create outputs dynamically from response JSON
				jqDynamicContentBlock.html("");
				// Add output JSON data to output block
				restform.json.traverseObject(jsonData, "", function(outputVal, jsonPath) {
					restform.output.appendOutputField(jqDynamicContentBlock, restform.json.pathToLabel(jsonPath), jsonPath, outputVal);
				});
			} else { // use predefined output structure to build output
				// Extract repeat element data structure from the output block
				var outputTemplateStructure = restform.repeat.parseTemplateStructure(jqOutputBlock);
				
				// Add output JSON data to output block
				restform.json.traverseObject(jsonData, "", function(outputVal, jsonPath) {
				
					var success = restform.output.setOutputVal(jqOutputBlock, outputVal, jsonPath, params.filterSelector);
					if (!success) { // try to expand repeat templates
						var expanded = restform.repeat.expandTemplates(jqOutputBlock, outputTemplateStructure, jsonPath, params.filterSelector);
						// if expanded element was found, set its value re-using restform.output.setOutputVal()
						if (expanded) {
							success = restform.output.setOutputVal(jqOutputBlock, outputVal, jsonPath, params.filterSelector);
						}
					}
				
					// show warning in console, if respective output element was not found
					if (!success) {
						var filterSelectorMsg = params.filterSelector ? "(additional selector " + params.filterSelector + ")" : "";
						console.warn("Form element '" + jsonPath + "' not found" + filterSelectorMsg + "."
								+ " Cannot assign value. Data: ", jsonData);
					}
				});
			}
		}
		this.getProcessedData = function () {
			return this.jsonData;
		}
	};

	/**
	 * Takes existing object, jsonPath and value and populates existing object with that value.
	 * E.g. 
	 * > restform.json.assignToObject({foo: {d: 1}}, "foo.bar[1].coo", 4)
	 * {foo: {d: 1, bar: [null, {coo: 4}]}}
	 * @param obj
	 *        object to be modified or null to create new object
	 * @param jsonPath
	 *        path in JSON object where to assign value;
	 *        if path is empty, respective object nesting will be created
	 * @param value
	 *        value to be assigned to the 
	 * @return modified or created object
	 */
	this.assignToObject = function (obj, jsonPath, value) {
		if (!obj) {
			obj = jsonPath.indexOf("[") == 0 ? [] : {};
		}
		var subPaths = jsonPath.split("."); // e.g 'foo.bar[1].coo' -> ['foo', 'bar[1]', 'coo']
		var subObj = obj;
		for (var i = 0; i < subPaths.length; i++) {
			var subPathFragments = subPaths[i].split("["); // e.g 'bar[1]' -> ['bar', '1]']

			for (var j = 0; j < subPathFragments.length; j++) {
				var pathFragment = subPathFragments[j];
		        if (pathFragment == "") {
		        	continue;
		        }
				if (pathFragment.indexOf(']') == -1) { // path fragment has no array component
					var subObjPath = pathFragment;
					 
					// object with given key exists and object will have other subobjects
					if (i != subPaths.length - 1 && typeof subObj[subObjPath] === 'object') {
						subObj = subObj[subObjPath]; // select it
					} else { // object needs to be created or value assigned
						if (subPathFragments.length == 1) { // Create JSON object only (no array)
							if (i == subPaths.length - 1) { // last element
								subObj[subObjPath] = value; // assign value to object in case no arrays defined
							} else { // object will have other subobjects
								if (typeof subObj[subObjPath] === 'undefined') {
									subObj[subObjPath] = {}; // create new object
								}
								subObj = subObj[subObjPath]; // select it
							}
						} else {
							if (typeof subObj[subObjPath] === 'undefined') {
								subObj[subObjPath] = []; // create new array
							}
							subObj = subObj[subObjPath]; // select it
						}
					}
				} else { // create array subelement
					var arrIndex = parseInt(pathFragment.replace("]", ""));
					if (i == subPaths.length - 1 && j == subPathFragments.length - 1) { // last element
						subObj[arrIndex] = value; // assign value to object
					} else if (typeof subObj[arrIndex] === 'object') { // object with given key exists
						subObj = subObj[arrIndex]; // select it
					} else if (j < subPathFragments.length - 1) { // object does not exist and needs subarray
						if (typeof subObj[arrIndex] === 'undefined') {
							subObj[arrIndex] = []; // create new array
						}
						subObj = subObj[arrIndex]; // select it
					// object does not exist and needs subobject
					} else { // if (i < subPaths.length - 1 && j == subPathFragments.length - 1)
						if (typeof subObj[arrIndex] === 'undefined') {
							subObj[arrIndex] = {}; // create new object
						}
						subObj = subObj[arrIndex]; // select it
					}
				}
			}
		}

		return obj;
	};

	/**
	 * Traverses nested object recursively (arrays and properties) and
	 * calls provided function for each primitive in the object supplying the respective jsonPath
	 * to given property.
	 * E.g.
	 * > restform.json.traverseObject({a: [{b: 1}, 2], c: {d: "3"}}, "", function(obj, jsonPath) {console.log(jsonPath, '=', obj);});
	 * a[0].b = 1
	 * a[1] = 2
	 * c.d = 3
	 * @param obj
	 *        object to be traversed
	 * @param jsonPath
	 *        JSONPath of subobject in original object
	 * @param callback with property value and JSONPath in the form of:
	 *        function(value, jsonPath);
	 */
	this.traverseObject = function(obj, jsonPath, callback) {
		if (obj == null && jsonPath == "") {
			return;
		}
		if (obj && obj.constructor == Object) {
			// traversing object
			for (var prop in obj) {
				var sep = jsonPath != "" ? "." : "";
				restform.json.traverseObject(obj[prop], jsonPath + sep + prop, callback);		
			}
		} else if (obj && obj.constructor == Array) {
			// traversing array
			for (var i = 0; i < obj.length; i++) {
				var subObj = obj[i];
				restform.json.traverseObject(subObj, jsonPath + "[" + i + "]", callback);		
			}
		} else {
			// obj is primitive, delegate to callback
			callback(obj, jsonPath);
		}
	};

	/**
	 * Utility function to increase array index in JSONPath string.
	 * E.g.
	 * restform.json.addToPathIndex('foo[1].bar[2].coo[3]', 'foo[1].bar', 10)
	 * > 'foo[1].bar[12].coo[3]'
	 * @param path JSONPath where index is increased
	 * @param prefix JSONPath fragment in the beginning of path that remains unchanged
	 * @param incr integer to be added to the index that comes right after prefix.
	 * @return JSONPath string with increased index
	 */
	this.addToPathIndex = function(path, prefix, incr) {
		if (path.indexOf(prefix) == 0) {
			var pathWithoutPrefix = path.substring(prefix.length, path.length);
			var pathTokens = pathWithoutPrefix.match(/^\[([0-9]+)\](.*)/);
			if (pathTokens && pathTokens.length >= 2) {
				var pathIndex = parseInt(pathTokens[1]);
				var pathSuffix = pathTokens[2] ? pathTokens[2] : "";
				return prefix + "[" + (pathIndex + incr) + "]" + pathSuffix;
			}
		}
		return path; // by default
	};

	/**
	 * Add together two (relative) JSONPaths using suitable separator.
	 * E.g.
	 * restform.json.concatJsonPaths('foo[1].bar[2]', 'coo[3].doo')
	 * > 'foo[1].bar[2].coo[3].doo'
	 * restform.json.concatJsonPaths('foo[1].bar', '[2].coo')
	 * > 'foo[1].bar[2].coo'
	 * @return concatenated JSONPath
	 * */
	this.concatJsonPaths = function(prefix, suffix) {
		if (!prefix) {
			return suffix;
		} else if (!suffix) {
			return prefix;
		} else if (suffix[0] == "[") {
			return prefix + suffix;
		} else {
			return prefix + "." + suffix;
		}
	};
	
	/**
	 * Convert JSON Path to REST form label text.
	 * Used in case REST response data structure is unknown and response is rendered on the fly based on objet content.
	 * @param jsonPath response field JSON path
	 * @return constructed label text
	 */
	this.pathToLabel = function(jsonPath) {
		var capitalizeFirstLetter =
			   jsonPath
			&& jsonPath.indexOf(".") == -1
			&& jsonPath.indexOf("[") == -1
			&& jsonPath == jsonPath.toLowerCase();
		var labelText;
		if (capitalizeFirstLetter) {
			labelText = jsonPath[0].toUpperCase() + jsonPath.substring(1);
		} else {
			labelText = jsonPath;
		}
		return labelText;
	};
};
