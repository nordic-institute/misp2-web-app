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
 * Register event handlers 
 */
restform.event = new function() {
	// list of allowed handler keys
	this.handlerTypes = [
		"assembleRequest",
		"beforeSend",
		"afterReceive",
		"afterResponseDataAdded",
		"processResponse",
		"processResponseError",
		"afterToggle",
		"validateInput"
	];

	
	/**
	 * Add or override JSON request send and receive functionality.
	 * 
	 * Map containing alternative callback functions enabling to adjust/override the following functionality:
	 * - override assembling JSON request
	 * - add additional processing for JSON request before sending the message
	 * - add additional processing for JSON response after receiving JSON response
	 * - override populating output form with JSON response
	 * 
	 * Object structure format added to form element with jQuery(form).data() :
	 * {
	 * 			handlerType: function(...) {...},
	 * 			...
	 * }
	 * 
	 * E.g.
	 * > restform.event.setHandler("teenus.input", "beforeSend", function(builder) {builder.obj.request = "Changed value"; return builder;});
	 * > restform.event.setHandler("teenus.input", "afterResponseDataAdded", function() {restform.view.toggleToView("service2.input");});
	 * 
	 * @param form input form element 'id' as string or DOM element or jQuery wrapper to that DOM element
	 * @param handlerType event name that determines in which stage the callback is called.
	 * 		The following handler types are available:
	 * 			"assembleRequest", "beforeSend", "afterReceive", "afterResponseDataAdded", "processResponse", "processResponseError"
	 * @param callback function to given handler. Arguments and return types depend on 'handlerType' argument value:
	 * 
	 * 		"assembleRequest": function(jqButton) { ... return obj; }, 	            // alternative request assembling override
	 * 		"beforeSend": function(requestBuilder, jqButton) { ... return newRequestBuilder; },    // process request after assembling and return
	 * 		"afterReceive": function(data, xhr, jqButton) { ... return changedData; }, // process response after receiving it
	 *		"afterResponseDataAdded": function(respObj, jqButton, jqOutputBlock) {...},     // callback after data has been added to form
	 * 		"processResponse": function(data, xhr, jqButton) {...},                   // alternative response processing override
	 * 		"processResponseError": function(jqButton, xhr, error, errorText) {...} // alternative response error processing override
	 * 		"afterToggle": function(jqButton) {...} // run after view has been toggled
	 */
	this.setHandler = function(el, handlerType, callback){
		
		if (this.handlerTypes.indexOf(handlerType) == -1) {
			throw "Unexpected handler type '" + handlerType + "'."
				+ " Has to be one of the following: " + handlerTypes;
		}

		var jqEl = restform.event.getDataElement(el, handlerType);
		jqEl.data(handlerType, callback); // attach callback to form
	}
	
	/**
	 * @return event handler function if it is found
	 * @see #setHandler() for handler type details.
	 */
	this.getHandler = function (el, handlerType) {
		var jqEl = restform.event.getDataElement(el, handlerType);
		return jqEl.data(handlerType);
	}
	
	/**
	 * Find DOM node that is used to store event listeners associated with current node.
	 * @param el
	 *         DOM element, jQuery wrapper or ID associated with DOM element.
	 * @return jQuery wrapper referring to DOM node where listener is stored.
	 *         If current node refers to a form element, return it.
	 *         If current node is itself not a form element, try to find a parent or a child form.
	 *         If no form element is found, return jQuery wrapper of input argument.
	 */
	this.getDataElement = function (el, handlerType) {
		var jqEl;
		// if target is 'id' attribute value
		if (typeof el === 'string') {
			jqEl = jQuery("[id='" + el + "']");
		} else { // else DOM or jQuery object
			jqEl = jQuery(el);
		}
		
		// If node is not found, throw an error
		if (jqEl.length == 0) {
			throw "Element '" + el + "' not found for.";
		} // else jqEl exists
		
		// validation function is added to the element itself, not container
		if (handlerType == "validateInput") {
			return jqEl;
		}
		
		// try to find a form element that is a parent or a child - other events are common for the entire form
		if (jqEl.prop("tagName") != "FORM") {
			var jqParentForm = jqEl.closest("form");
			if (jqParentForm.length > 0) {
				jqEl = jqParentForm;
			} else { 
				var jqChildForm = jqEl.find("form:eq(0)");
				if (jqChildForm.length > 0) {
					jqEl = jqChildForm;
				} // else form node was not found, just use el itself as data node
			}
		}
		
		return jqEl;
	}
};
