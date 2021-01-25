/*
 * The MIT License
 * Copyright (c) 2020 NIIS
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
 * Input HTML node validation
 */
restform.input = new function() {
	this.inputSelector = "input, textarea, select";
	/**
	 * Validate input element value. If validation function has
	 * been registered, delegate to that. Otherwise use default behavior defined
	 * in this method. If validation failed, add 'not-valid' class to input element, otherwise remove it.
	 * @param jqOutputEl jQuery output element wrapper
	 * @return true if valid, false if not
	 */
	this.validate = function(inputEl) {
		var jqInputEl = jQuery(inputEl);
		var valid = true;
		var validateFn = restform.event.getHandler(jqInputEl, "validateInput");
		if (validateFn) {
			return validateFn(jqInputEl);
		} else {
			// Add validation results to the title attribute
			jqInputEl.attr("title", "");
			
			// Make sure required elements have value
			if (jqInputEl.hasClass("required") && jqInputEl.val() == "") {
				restform.input.invalidate(jqInputEl, "restform.error.validate.field.required");
				valid = false;
			}
			
			// Make sure base64 is not still being converted when data send is started
			if (jqInputEl.is("input[type=file].base64")
					&& jqInputEl.attr("data-rf-convert-status") == "converting") {
				restform.input.invalidate(jqInputEl, "restform.error.validate.field.converting_to_base64_in_progress");
				valid = false;
			}
			
			// Number (integer/float) validation
			if (jqInputEl.val() && jqInputEl.is("input[type=number]")) {
				// integer vs float
				var validationFormat = jqInputEl.attr("data-rf-validate-format");
				var num = null;
				// integer validation
				if (validationFormat && (validationFormat.indexOf("int32") != -1 || validationFormat.indexOf("int64") != -1)) {
					if (jqInputEl.val().indexOf(".") != -1) {
						restform.input.invalidate(jqInputEl, "restform.error.validate.field.must_be_integer_not_float",
								jqInputEl.val());
						valid = false;
					} else {
						num = parseInt(jqInputEl.val());
						if (isNaN(num)) {
							restform.input.invalidate(jqInputEl, "restform.error.validate.field.integer_parsing_failed", jqInputEl.val());
							valid = false;
						} else {
							// multipleOf/step
							if (jqInputEl.attr("step")) {
								var step = parseInt(jqInputEl.attr("step"));
								if (!isNaN(step) && num % step != 0) {
									restform.input.invalidate(jqInputEl, "restform.error.validate.field.not_multiple_of", num, step);
									valid = false;
								}
								
							}
							
						}
					}
				} else { // float validation
					num = parseFloat(jqInputEl.val());
					if (isNaN(num)) {
						restform.input.invalidate(jqInputEl, "restform.error.validate.field.float_parsing_failed", jqInputEl.val());
						valid = false;
						num = null;
					}
				}

				// integer/float min-max comparisons
				if (num != null) {
					// if attribute 'min' exists, compare value to it
					var minStr = jqInputEl.attr("min");
					if (minStr) {
						var min = parseFloat(minStr);
						if (!isNaN(min) && num < min) {
							restform.input.invalidate(jqInputEl, "restform.error.validate.field.less_than_min", num, min);
							valid = false;
						}
					}
					// if attribute 'max' exists, compare value to it
					var maxStr = jqInputEl.attr("max");
					if (maxStr) {
						var max = parseFloat(maxStr);
						if (!isNaN(max) && num > max) {
							restform.input.invalidate(jqInputEl, "restform.error.validate.field.greater_than_max", num, max);
							valid = false;
						}
					}
				}
			}
			
			// text length validation
			if (jqInputEl.val() == "" || jqInputEl.val()) {
				var minlengthStr = jqInputEl.attr("minlength");
				if (minlengthStr) {
					var minlength = parseInt(minlengthStr);
					if (!isNaN(minlength) && jqInputEl.val().length < minlength) {
						restform.input.invalidate(jqInputEl, "restform.error.validate.field.shorter_than_minlength", minlength);
						valid = false;
					}
				}
				var maxlengthStr = jqInputEl.attr("maxlength");
				if (maxlengthStr) {
					var maxlength = parseInt(maxlengthStr);
					if (!isNaN(maxlength) && jqInputEl.val().length > maxlength) {
						restform.input.invalidate(jqInputEl, "restform.error.validate.field.longer_than_maxlength", maxlength);
						valid = false;
					}
				}
			}
			
			// regex pattern validation if pattern is given
			var regexStr = jqInputEl.attr("pattern");
			if (regexStr) {
				var regex = new RegExp(regexStr);
				if (!regex.test(jqInputEl.val())) {
					restform.input.invalidate(jqInputEl, "restform.error.validate.field.does_not_match_pattern", regexStr);
					valid = false;
				}
			}
			
			// date validation
			if (jqInputEl.hasClass("date") || jqInputEl.hasClass("date-time") || jqInputEl.hasClass("time")) {
				// pick up both date and time inputs
				var jqDate = jqInputEl.parent().children(".date, .date-time");
				var jqTime = jqInputEl.parent().children(".time");
				
				// validate date
				var dateStr = jqDate.val();
				if (dateStr) {
					var regionalObj = restform.dateutil.getRegional();
					var dateFormat = regionalObj.dateFormat;
					try {
						jQuery.datepicker.parseDate(dateFormat, dateStr);
					} catch (e) {
						console.log("Date '" + dateStr + "' is not valid.", e);
						restform.input.invalidate(jqDate, "restform.error.validate.field.invalid_date");
						valid = false;
					}
				} else {
					restform.input.markAsValid(jqDate);
				}

				// validate time, if exists
				if (jqTime.length != 0) {
					var date = jqDate.datepicker("getDate");
					try {
						restform.dateutil.setTime(date, jqTime);
						if (jqTime.val() && !jqDate.val()) {
							jqTime.val("");
						}
					} catch(e) {
						console.log("Time '" + jqTime.val() + "' is not valid.", e);
						if (e.indexOf("Date is not set") == 0) {
							restform.input.invalidate(jqDate, "restform.error.validate.field.datetime_date_is_not_set");
						} else {
							restform.input.invalidate(jqTime, "");
						}
						valid = false;
					}
				} else {
					restform.input.markAsValid(jqTime);
				}
			}
		}
		if (valid) {
			restform.input.markAsValid(jqInputEl);
		}
		return valid;
	};
	
	/**
	 * Mark input element as not valid: add 'not-valid' class and respective title description.
	 * @param jqEl jQuery input element
	 * @param title error text translation code
	 * @param ...args optional translation code arguments
	 */
	this.invalidate = function(jqEl, translationCode) {
		// Animate from CSS class 'not-valid-start-animation' to 'not-valid'
		var animationDuration = 400; // ms
		jqEl.addClass("not-valid-start-animation");
		jqEl.switchClass("not-valid-start-animation", "not-valid", animationDuration, "easeInOutQuad");

		var args = restform.util.getArrayOrOptionalArgs(arguments, this._invalidateFnOptStart);
		var translation = restform.util.getText(translationCode, args);
		// Set error message to 'title' attribute
		var jqError = jqEl.parent().children(".error");
		if (jqError.length == 0) {
			jqError = jQuery("<div>", {"class": "error"});
			jqEl.parent().append(jqError);
		}
		jqError.text(translation);
	};
	// optional argument start in invalidate() function - count args in function definition
	this._invalidateFnOptStart = restform.util.countFunctionArgs(this.invalidate);
	
	/**
	 * Mark input element as valid (remove error classes and attributes).
	 * @param jqEl jQuery input element
	 */
	this.markAsValid = function(jqEl) {
		jqEl.removeClass("not-valid");
		jqEl.parent().children(".error").remove();
	};

};
