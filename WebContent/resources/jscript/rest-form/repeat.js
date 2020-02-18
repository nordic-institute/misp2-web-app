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
 * Adding and deleting repeat-elements.
 * Also contains functions to automatically expand repeat outputs
 * (those use the same mechanism).
 */
restform.repeat = new function() {
	this.templateSelector = "[data-rf-repeat-template-path]"
	/**
	 * Add new repeat-block to repeat-container based on template block.
	 * Name attributes within newly created block will contain absolute JSONPaths including array indexes.
	 * @param jqRepeatTemplate repeat-block template element wrapped in jQuery container.
	 *                         Template element has the 'data-rf-repeat-block-path' attribute.
	 */
	this.addBlockFromRepeatTemplate = function(jqRepeatTemplate) {
		var index = jqRepeatTemplate.parent().children(".repeat-block").length;
		
		var jqRepeatContainer = jqRepeatTemplate.closest(".repeat-container");
		var maxItemsStr = jqRepeatContainer.attr("data-rf-validate-max-items");
		if (maxItemsStr) {
			var maxItems = parseInt(maxItemsStr);
			if (!isNaN(maxItems) && index >= maxItems) {
				restform.util.warn("restform.error.validate.array.max_items_reached", maxItems);
				return;
			}
		}
		
		var jqRepeatBlock = jqRepeatTemplate.clone();
		var jsonPathPrefix = jqRepeatBlock.attr("data-rf-repeat-template-path");
		
		jqRepeatBlock.removeAttr("data-rf-repeat-template-path");
		jqRepeatBlock.addClass("repeat-block");
	
		var jsonPathPrefix = jsonPathPrefix + "[" + index + "]";
		
		// If repeat is not for JSON, but is multipart repeat, do not add anything to JSON paths
		if (jqRepeatBlock.hasClass("multipart-repeat-template")) {
			jsonPathPrefix = "";
		}
		jqRepeatBlock.attr("data-rf-repeat-block-path", jsonPathPrefix);
		
		// Override immediate child repeat templates and input form element name attributes
		jqRepeatBlock.find("[data-rf-repeat-template-path], [name], [data-rf-path]").each(function() {
			var jqEl = jQuery(this);
			if (jqEl.parents("[data-rf-repeat-template-path]").length == 0) {
				var attr;
				if (jqEl.attr("data-rf-repeat-template-path") || jqEl.attr("data-rf-repeat-template-path ") == "") {
					attr = "data-rf-repeat-template-path";
				} else if (jqEl.attr("data-rf-path") || jqEl.attr("data-rf-path") == "") {
					attr = "data-rf-path";
				} else {
					attr = "name";
				}
				var path = restform.json.concatJsonPaths(jsonPathPrefix, jqEl.attr(attr));
				jqEl.attr(attr, path);
			}
		});
		
		// Insert cloned block as one before last element (last one is the template)
		jqRepeatTemplate.last().before(jqRepeatBlock);
		
		// In case our newly created block is multipart repeat, rename multipart id,
		// so it would remain unique per multipart block (delegate to restform.multipart to do that)
		var multipartId = jqRepeatBlock.attr("data-rf-multipart-id");
		if (multipartId) { // repeat only has this attribute, if multipart section is cloned
			restform.multipart.handleMultipartCloned(jqRepeatBlock, multipartId, index);
		}
		// Javascript event-listeners are not cloned so these need to be reinited
		restform.init.initFormElements(jqRepeatBlock);
		
		return jqRepeatBlock;
	}

	/**
	 * Delete repeat-block and correct indexes of JSONPaths in name and data-rf-repeat-template-path attributes.
	 * @param jqRepeatBlock repeat-block jQuery element that is being deleted
	 */
	this.deleteRepeatBlock = function(jqRepeatBlock) {
		// Rename all relevant subpaths where index is greater than index of deleted repeat block
		var deletedPath = jqRepeatBlock.attr("data-rf-repeat-block-path");
		var deletedPathTokens = deletedPath.match(/(.*)\[([0-9]+)\]$/);
		if (deletedPathTokens && deletedPathTokens.length == 3) {
			var deletedPathPrefix = deletedPathTokens[1];
			jqRepeatBlock.nextAll(".repeat-block").each(function() {
				var jqRepeatBlock = jQuery(this);
				var attr = "data-rf-repeat-block-path";
				var path = jqRepeatBlock.attr(attr);
				var newPath = restform.json.addToPathIndex(path, deletedPathPrefix, -1);
				jqRepeatBlock.attr(attr, newPath);
			
				jqRepeatBlock.find("[data-rf-repeat-template-path], [name]").each(function() {
					var jqEl = jQuery(this);
					var attr = jqEl.attr("data-rf-repeat-template-path") ? "data-rf-repeat-template-path" : "name";
					jqEl.attr(attr, restform.json.addToPathIndex(jqEl.attr(attr), deletedPathPrefix, -1));
				});
				
				// In case our newly created block is multipart repeat, delegate delete info to it
				var multipartId = jqRepeatBlock.attr("data-rf-multipart-id");
				if (multipartId) {
					restform.multipart.handleMultipartDeleted(jqRepeatBlock, multipartId, newPath);
				}
			});
		}
		// remove the block
		jqRepeatBlock.remove();
	}

	/**
	 * Parse metainfo on the template element structure from output block jQuery element.
	 * @param jqOutputBlock
	 * 				output form container jQuery element
	 * @return map containing templates structure metainfo in the form of 
	 * [
	 * 		{
	 * 			'templatePath': 'test.templ1[].bla.templ2[].b', // JSONPath without indexes in repeated arrays
	 * 			'templateIdentifiers': [0, 1],                  // data-rf-template-identifier attribute values for given templates
	 *  		'jqRootTemplate': jQuery element for template DIV block
	 * 		},
	 * 		...
	 * ]
	 */
	this.parseTemplateStructure = function(jqOutputBlock) {
		var templateStructure = [];
		var templateIdentifierSeq = 0;
		jqOutputBlock.find("[data-rf-repeat-template-path] [name], [data-rf-repeat-template-path] [data-rf-path]").each(function() {
			var jqEl = jQuery(this);
			var elPath = jqEl.attr("name");
			if (elPath == null) {
				elPath = jqEl.attr("data-rf-path");
			}
			var jqRootTemplate = null;
			var templateIdentifiers = [];
			var templatePath = "";
			jqEl.parents("[data-rf-repeat-template-path]").each(function() {
				var jqTemplate = jQuery(this);
				jqRootTemplate = jqTemplate;
			
				// If repeat is not for JSON, but is multipart repeat, do not add anything to JSON paths
				// otherwise concat
				if (!jqTemplate.hasClass("multipart-repeat-template")) {
					var tmpPath = restform.json.concatJsonPaths(jqTemplate.attr("data-rf-repeat-template-path"), "[]");
					templatePath = restform.json.concatJsonPaths(tmpPath, templatePath);
				}
				var templateIdentifier = jqTemplate.attr("data-rf-template-identifier");
				if (!templateIdentifier) {
					templateIdentifier = templateIdentifierSeq++;
					jqTemplate.attr("data-rf-template-identifier", templateIdentifier);
				} else {
					templateIdentifier = parseInt(templateIdentifier);
				}
				templateIdentifiers[templateIdentifiers.length] = templateIdentifier;
			});
		
			templatePath = restform.json.concatJsonPaths(templatePath, elPath);
			templateStructure[templateStructure.length] = {
				"templatePath": templatePath,
				"jqRootTemplate": jqRootTemplate,
				"templateIdentifiers": templateIdentifiers.reverse()
			};
		});
		// console.log("Output template structure", templateStructure);
		return templateStructure;
	}

	/**
	 * Find array of indexes specified by '[]' in JSONPath template.
	 * E.g.
	 * > restform.repeat.getPathIndexes("test[23].bla[34].ble[6].b", "test[].bla[].ble[].b")
	 * [23, 34, 6]
	 * > restform.repeat.getPathIndexes("test[23].bla[34].ble[6].b", "test[].bla[].ble[].b.nomatch")
	 * null
	 * > restform.repeat.getPathIndexes("test[23].bla[34].ble[6].b", "test[].bla[34].ble[].b")
	 * [23, 6]
	 * @param jsonPath
	 * 				JSONPath string from which indexes are extracted
	 * @param templatePath
	 * 				JSONPath template describing extracted indexes that are marked by '[]'.
	 * @return array of indexes (non-negative integers) extracted from JSONPath or
	 * 			null,  if JSONPath did not match with template
	 */
	this.getPathIndexes = function(jsonPath, templatePath) {
		var templatePathParts = templatePath.split("[]");
		var jsonPathIndex = 0;
		var indexes = [];
		for (var i = 0; i < templatePathParts.length; i++) {
			var templatePathPart = templatePathParts[i];
			var jsonPathNameEndIndex = jsonPathIndex + templatePathPart.length;
			var jsonPathPart = jsonPath.substring(jsonPathIndex, jsonPathNameEndIndex);
			if (templatePathPart != jsonPathPart) {
				return null;
			}
			if (i < templatePathParts.length - 1) { // in this case compare indexes
				if (jsonPath[jsonPathNameEndIndex] != '[') {
					return null;
				}
				var jsonPathEndIndex = jsonPath.substring(jsonPathNameEndIndex, jsonPath.length).indexOf(']');
				if (jsonPathEndIndex == -1) {
					return null;
				}
				jsonPathEndIndex += jsonPathNameEndIndex;
			
				indexes[indexes.length] = parseInt(jsonPath.substring(jsonPathNameEndIndex + 1, jsonPathEndIndex));
			
				jsonPathIndex = jsonPathEndIndex + 1;
			} else {
				var jsonPathPart = jsonPath.substring(jsonPathIndex, jsonPath.length);
				if (templatePathPart != jsonPathPart) {
					return null;
				}
			}
		}
	
		return indexes;
	}

	/**
	 * Expand expandable output lists. Automatically add sublists from template,
	 * if element with given JSONPath is not there, but could be created by expanding repeat template.
	 * Used for populating output repeats.
	 * @param jqOutputBlock
	 * 		output form jQuery element
	 * @param templateStructure
	 * 		metainfo about template structure in given output block
	 * @param jsonPath
	 * 		JSONPath of assigned element in JSONResponse.
	 * 		Respective input element with given path should be created with template expansion, if possible.
	 * @param filterSelector
	 * 		jQuery selector to avoid processing entry from another multipart
	 * @return true if output element for jsonPath was created, false if not 
	 */
	this.expandTemplates = function(jqOutputBlock, templateStructure, jsonPath, filterSelector) {
		// Try to find existing repeat-block with matching data-rf-repeat-block-path
		var jqRepeatBlock = null;
		var expanded = false;
		// find suitable entry from template structure
		for (var k = 0; k < templateStructure.length; k++) {
			var templateInfo = templateStructure[k];
			var templatePath = templateInfo.templatePath;
			var jsonPathIndexes = restform.repeat.getPathIndexes(jsonPath, templatePath);
			if (jsonPathIndexes != null) { // if path matches to template path
				var jqTemplate = null;
				var jqRepeatBlock = templateInfo.jqRootTemplate.closest(".repeat-container");
				var templateIdentifiers = templateInfo.templateIdentifiers;
				for (var i = 0; i < templateIdentifiers.length; i++) {
					jqTemplate = jqRepeatBlock.find("[data-rf-repeat-template-path][data-rf-template-identifier='" + templateIdentifiers[i] + "']");
					var jqParent = jqTemplate.parent();
					var jsonPathIndex = jsonPathIndexes[i];
					// TODO allow non-continuous blocks
					var maxExistingIndex = jqParent.children(".repeat-block").length - 1;
					if (maxExistingIndex < jsonPathIndex) {
						// Call esisting repeat block creation function until we have an element with desired index
						for (var j = 0; j < jsonPathIndex - maxExistingIndex; j++) {
							restform.repeat.addBlockFromRepeatTemplate(jqTemplate);
							expanded = true;
						}
					}

					jqRepeatBlock = jqParent.children(".repeat-block[data-rf-repeat-block-path$='[" + jsonPathIndex + "]']");
				}
			}
		}
		return expanded;
	};
	
	/**
	 * Validate repeat inputs (item counts and uniqueness in repeat element).
	 * @param jqRepeatTemplate repeat element template - serves as a reference to find repeat block elements of given repeat
	 * @return true if valid, false if not valid
	 */
	this.validate = function(jqRepeatTemplate) {
		var jqRepeatBlocks = jqRepeatTemplate.parent().children(".repeat-block");
		var itemCount = jqRepeatBlocks.length;
		var jqRepeatContainer = jqRepeatTemplate.closest(".repeat-container");
		// invalidation message will be added next to jqEl
		var jqEl = jqRepeatTemplate.parent().children(".repeat-error-anchor");
		if (jqEl.length == 0) {
			// create new element to assign not-valid to
			jqEl = jQuery("<span>", {"class": "repeat-error-anchor"});
			jqRepeatTemplate.parent().append(jqEl);
		}
		var valid = true;
		
		// Check that maximum number of items is not exceeded
		var maxItemsStr = jqRepeatContainer.attr("data-rf-validate-max-items");
		if (maxItemsStr) {
			var maxItems = parseInt(maxItemsStr);
			if (!isNaN(maxItems) && itemCount > maxItems) {
				restform.input.invalidate(jqEl, "restform.error.validate.array.max_items_exceeded",
						itemCount, maxItems);
				valid = false;
			}
		}
		
		// Check minimum number of items exists
		var minItemsStr = jqRepeatContainer.attr("data-rf-validate-min-items");
		if (minItemsStr) {
			var minItems = parseInt(minItemsStr);
			if (!isNaN(minItems) && itemCount < minItems) {
				restform.input.invalidate(jqEl, "restform.error.validate.array.min_items_missing",
						itemCount, minItems);
				valid = false;
			}
		}
		
		// jQuery input selector (excludes checkboxes, radios, passwords and files)
		var inputSelector = 
			 "input[type=hidden]," +
				" input[type=text]," +
				" input[type=number]," +
				" select," +
				" textarea";
		// Check uniqueness on single-element arrays
		var uniqueItemsStr = jqRepeatContainer.attr("data-rf-validate-unique-items");
		if (uniqueItemsStr && uniqueItemsStr == "true") {
			if (jqRepeatTemplate.children(".field").length == 1) {
				var vals = [];
				var repeatedVals = [];
				jqRepeatBlocks.children(".field").children(inputSelector).each(function () {
					var val = jQuery(this).val();
					if (vals.indexOf(val) == -1) {
						vals[vals.length] = val;
					} else if (repeatedVals.indexOf(val) == -1) {
						repeatedVals[repeatedVals.length] = val;
					}
				});
				if (repeatedVals.length > 0) {
					var repeatedValsStr = "";

					for (var i = 0; i < repeatedVals.length; i++) {
						var val = repeatedVals[i];
						if (i != 0) {
							repeatedValsStr += ", ";
						}
						repeatedValsStr += "'" + val + "'";
					}
					restform.input.invalidate(jqEl, "restform.error.validate.array.contains_non_unique_entries",
						repeatedValsStr);
					valid = false;
				}
			}
		}
		
		
		if (valid) {
			restform.input.markAsValid(jqEl);
			jqRepeatTemplate.parent().children(".repeat-error-anchor").remove();
		}
		return valid;
	};
};
