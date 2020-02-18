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
 * Methods for REST form actions:
 * - sending query
 * - JSON and JSONPath methods for
 *   - serializing form data to JSON
 *   - parsing JSON to output form
 * - view changing mechanism
 * - registering actions on send events
 * - repeat element handling
 */
if (!window.restform) {
	window.restform = new function() {};
}

/**
 * General utilities
 */
restform.util = new function() {
	/**
	 * @return selected language code in portal
	 *         E.g. 'en'
	 */
	this.getLang = function() {
		return jQuery("#language .active:eq(0)").attr("id").replace(/^lang_/, "");
	};

	/**
	 * Meta-function that counts the number of arguments in a given function
	 * @param fn function to have its arguments counted
	 * @return number of defined function argumetns
	 */
	this.countFunctionArgs = function (fn) {
		var fnStr = fn.toString();
		var fnHeaderStr = fnStr.substring(0, fnStr.indexOf("{"));
		var fnArgsStr = fnHeaderStr.substring(fnHeaderStr.indexOf("(") + 1, fnHeaderStr.indexOf(")"));
		if (jQuery.trim(fnArgsStr) == "") {
			return 0;
		} else {
			return fnArgsStr.split(",").length;
		}
	};
	
	/**
	 * Display alert message based on jQuery UI dialog.
	 * @param code alert content
	 * @param title alert title
	 * @param ... args optional translation arguments
	 */
	this.alert = function(code, title) {
		var alertId = "alert";
		var jqAlert = jQuery("#" + alertId);
		if (jqAlert.length > 0) { // close previously opened alert if needed
			jqAlert.dialog("close");
			jqAlert.remove();
		}
		if (code) {
			var args = restform.util.getArrayOrOptionalArgs(arguments, this._alertFnOptStart);
			var jqDialog = jQuery("<div>", {"id": alertId, "title": title})
				.text(restform.util.getText(code, args));
			restform.jqRestForm.append(jqDialog);
			jqDialog.dialog({
				dialogClass: "no-close",
				minHeight: 35,
				buttons: [
					{
						text: restform.util.getText("label.button.ok"),
						click: function() {
							jQuery(this).dialog("close");
						}
					}
				],
				create: function (event, ui) {
			        jQuery(event.target).parent().css('position', 'fixed');
				}
			});
			return jqDialog;
		}
	};
	
	/**
	 * Alert convenience functions (error, warn and notice)
	 * @param code translation code of the message or text
	 * @param ...args optional translation arguments
	 * */
	this.error = function(code) {
		var args = restform.util.getArrayOrOptionalArgs(arguments, this._errorFnOptStart);
		var title = restform.util.getText("restform.error");
		return restform.util.alert(code, title, args);
	};
	this.warn = function(code) {
		var args = restform.util.getArrayOrOptionalArgs(arguments, this._warnFnOptStart);
		var title = restform.util.getText("restform.warning");
		return restform.util.alert(code, title, args);
	};
	this.notice = function(code) {
		var args = restform.util.getArrayOrOptionalArgs(arguments, this._noticeFnOptStart);
		var title = restform.util.getText("restform.notice");
		return restform.util.alert(code, title, args);
	};
	
	/**
	 * Get translation from translation message container.
	 * @param code translation code
	 * @param ...args optional translation code arguments
	 * @return translated text
	 */
	this.getText = function(code) {
		var val = jQuery("#rest-form-messages input[name='" + code + "']").val();
		if (typeof val === 'undefined') {
			return code.replace(/[^\s][-.][^\s]/, " ");
		} else {
			if (arguments.length > this._getTextFnOptStart) {
				var args = restform.util.getArrayOrOptionalArgs(arguments, this._getTextFnOptStart);
				for (var i = 0; i < args.length; i++) {
					var arg = args[i];
					val = val.replace("{" + i + "}", arg);
				}
			} 
			return val;
		}
	};
	
	/**
	 * @param functionArgs all function arguments where optional arguments are found
	 * @param firstOptArgIndex first optional argument index
	 * @return if first optional argument is an array, return it,
	 * 		otherwise return array of all optional arguments
	 */
	this.getArrayOrOptionalArgs = function(functionArgs, firstOptArgIndex) {
		var firstOptionalArg = functionArgs[firstOptArgIndex];
		var args;
		if (firstOptionalArg && firstOptionalArg.constructor === Array) {
			args = firstOptionalArg;
		} else {
			args = Array.prototype.slice.call(functionArgs).slice(
					firstOptArgIndex, functionArgs.length);
		}
		return args;
	}
	
	/**
	 * Read application specific response custom REST header value.
	 * @param xhr Ajax query object instance
	 * @param headerName header name without custom prefix
	 * @return header value corresponding to given header name or null if header was not found
	 */
	this.getCustomResponseHeader = function (xhr, headerName) {
		var customHeaderName = headerName;
		// if header name does not begin with X-REST prefix, add custom form header prefix
		if (headerName.toLowerCase().indexOf("X-REST-".toLowerCase()) != 0) {
			customHeaderName = "X-REST-Response-Header-" + headerName;
		}
		var headerValue = xhr.getResponseHeader(customHeaderName);
		if (headerValue == null) {
			// this is not really necessary to ask for the original header, but may be useful in a non-XRoad system
			// commented out for now
			// return xhr.getResponseHeader(headerName);
			return null;
		} else {
			return headerValue;
		}
	};
	
	/**
	 * Takes in array of objects, loops through it and searches for an entry with given key property value.
	 * Returns value of value property as a result. Key and value property names are optional.
	 * They default to 'name' and 'value' respectively if omitted.
	 * 
	 * E.g.
	 * > var ar = [{name: 'key1', value: 'val1'}, {name: 'key2', value: 'val2'}];
	 * > restform.util.getFirstValueByKey(ar, 'key2');
	 * 'val2'
	 * > restform.util.getFirstValueByKey(ar, 'val2', 'value', 'name'); // reverse key and value
	 * 'key2'
	 * 
	 * @param ar array of objects with the same properties.
	 * @param keyPropValue property value of key attribute in #ar items
	 * @param keyPropName optional property name of key attribute in #ar items. Defaults to 'name'.
	 * @param valuePropName optional property name of value attribute in #ar items. Defaults to 'value'.
	 * 		In order to return the entire object, set valuePropName to null.
	 * @return value property value from the object in #ar matched by key name;
	 * 		return null if match is not found
	 */
	this.getFirstValueByKey = function (ar, keyPropValue, keyPropName, valuePropName) {
		if (typeof keyPropName === 'undefined') {
			keyPropName = "name";
		}
		if (typeof valuePropName === 'undefined') {
			valuePropName = "value";
		}

		for (var i = 0; i < ar.length; i++) {
			if (ar[i][keyPropName] == keyPropValue) {
				return valuePropName != null ? ar[i][valuePropName] : ar[i];
			}
		}
		return null;
	};
	
	/**
	 * Add padding in front of the string and return it.
	 * @param str string that needs padding
	 * @param ch padding character
	 * @param num integer, how long must the string be after padding
	 * @return padded string
	 */
	this.pad = function (str, ch, num) {
		str = "" + str; // just in case argument type is not string
		var count = num - str.length;
		for (var i = 0; i < count; i++) {
			str = ch + str;
		}
		return str;
	};
	
	/**
	 * Concatinate arguments separated by ', '
	 */
	this.concat = function() {
		var str = "";
		var sep = ", ";
		for (var i = 0; i < arguments.length; i++) {
			var arg = arguments[i];
			if (arg) {
				if (i > 0) {
					str += sep;
				}
				str += arg;
			}
		}
		return str;
	};
	

	// optional argument start in alert() function
	this._alertFnOptStart = this.countFunctionArgs(this.alert);
	// optional argument start in error() function
	this._errorFnOptStart = this.countFunctionArgs(this.error);
	// optional argument start in warn() function
	this._warnFnOptStart = this.countFunctionArgs(this.warn);
	// optional argument start in notice() function
	this._noticeFnOptStart = this.countFunctionArgs(this.notice);
	// optional argument start in invalidate() function - count args in function definition
	this._getTextFnOptStart = this.countFunctionArgs(this.getText);
};
