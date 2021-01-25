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
 * Date utilities
 */
restform.dateutil = new function() {

	/**
	 * Add datepicker widget to class="date" or class="date-time" inputs within a given jQuery container.
	 * @param jqContainer jQuery element containing date elements
	 */
	this.initDateWidgets = function(jqContainer) {
		var jqDateInputs = jqContainer.find("input[type=text].date, input[type=text].date-time");
		jqDateInputs.each(function (){
			var jqDateInput = jQuery(this);
			if (jqDateInput.closest("[data-rf-repeat-template-path]").length > 0) {
				return; // Do not add any date behavior or date-picker event-listeners to repeat templates
			}
			// Just in case date was already initialized, delete respective elements and initialize again
			jqDateInput.parent().find(".ui-datepicker-trigger, .time").remove();
			jqDateInput.removeClass("hasDatepicker");
			jqDateInput.removeAttr("id");
			// Add date-picker behavior to date-field
			jqDateInput.datepicker({
	            showOn: 'button',
	            buttonImage: jQuery("input[name=calendar-img-url]").val(),
	            buttonImageOnly: true,
		        changeMonth: true,
		        changeYear: true,
		        onSelect: function(dateText, jqDate) {
		            jQuery(this).change(); // Throw change event, otherwise it gets prevented
		            jQuery(this).parent().children(".time").select();
		        }
		    }, restform.dateutil.getRegional());
			// Add date-format as placeholder to date field
			jqDateInput.attr("placeholder", restform.dateutil.getRegional().dateFormat);
			
			// If calendar has default value defined, try initializing it
			var defaultDateStr = jqDateInput.attr("data-rf-default");
			var regionalDefaultTimeStr = null;
			if (defaultDateStr) {
				var regionalDefaultDateStr = restform.dateutil.formatDate(defaultDateStr, jqDateInput);
				if (regionalDefaultDateStr) {
					var ar = regionalDefaultDateStr.split(/\s/);
					jqDateInput.val(ar[0]);
					if (ar.length > 1) {
						regionalDefaultTimeStr = ar[1];
					}
				}
			}
			
			// Find calendar widget or if that does not exist, date field itself
			var jqDateLastEl = jqDateInput.next();
			if (jqDateLastEl.length == 0) {
				jqDateLastEl = jqDateInput;
			}
			
			// If date field is date-time, add time field after calendar button
			if (jqDateInput.hasClass("date-time")) {
				var jqTime = jqDateLastEl.next(); // See if time-field already exists
				if (jqTime.length == 0 || !jqTime.hasClass("time")) {
					// If time field does not exist, add it after date widgets calendar button
					var jqTimeInput = jQuery("<input>", {
						"type": "text",
						"class": "time ignore-on-send", 
						"placeholder": "HH:mm"
					});
					jqDateLastEl.after(jqTimeInput);
					// Prevent keypresses of illegal time characters of going through
					jqTimeInput.keydown(function (event) {
						var c = String.fromCharCode(event.keyCode);
						var allowedKeys = [
								48, 49, 50, 51, 52, 53, 54, 55, 56, 57, // numbers
								96, 97, 98, 99, 100, 101, 102, 103, 104, 105, // numpad numbers
								110, // numpad comma
								190, // colon, point
								188, // comma
								// navigation
								37, 38, 39, 40, // arrows
								46, // delete
								8,  // backspace
								9,  // tab
								16, // shift
								17, // control
								13  // enter
						];
						if (allowedKeys.indexOf(event.keyCode) == -1) {
							event.preventDefault();
						}
					});
					if (regionalDefaultTimeStr) {
						jqTimeInput.val(regionalDefaultTimeStr);
					}
				}
			}
		});
	};
	
	/**
	 * Validate time string and time component of a Date object from string.
	 * @param date Date object instance
	 * @param timeStr in the format HH:mm.
	 *        Can take other separators '.' and ',' also second and millisecond components.
	 * @return success: false if there were time parsing errors, true if time component was successfully set
	 *        or not set at all because of empty input
	 * @throws error in case of time parsing failure
	 */
	this.setTime = function (date, jqTime) {
		timeStr = jqTime ? jqTime.val() : null;
		if (date && date.constructor === Date) {
			var hours = 0;
			var minutes = 0;
			var seconds = 0;
			var milliseconds = 0;
			
			var millisStr = "";
			
			if (timeStr) {
				var ar = timeStr.split(/[\:\.\,]/);
				hours = parseInt(ar[0]);
				if (ar.length > 1 && ar[1]) {
					minutes = parseInt(ar[1]);
				}
				if (ar.length > 2 && ar[2]) {
					seconds = parseInt(ar[2]);
				}
				if (ar.length > 3 && ar[3]) {
					millisStr = (ar[3] + "000").substring(0, 3);
					milliseconds = parseInt(millisStr);
				}
			}
			if (isNaN(hours) || isNaN(minutes) || isNaN(seconds) || isNaN(milliseconds)) {
				throw "Failed to parse some values from time '" + timeStr + "' (hours: "
						+ hours + ", minutes:" + minutes + ", seconds: " + seconds + ", millis:" + milliseconds + ").";
			}

			if (hours < 0 || hours > 23) {
				throw "Time '" + timeStr + "' invalid: hours must be between 0 and 23.";
			}
			if (minutes < 0 || minutes > 59) {
				throw "Time '" + timeStr + "' invalid: minutes must be between 0 and 59.";
			}
			if (seconds < 0 || seconds > 59) {
				throw "Time '" + timeStr + "' invalid: seconds must be between 0 and 59.";
			}
			if (milliseconds < 0 || milliseconds > 999) {
				throw "Time '" + timeStr + "' invalid: milliseconds must be between 0 and 999.";
			}

			// set time fields in Date object
			date.setHours(hours);
			date.setMinutes(minutes);
			date.setSeconds(seconds);
			date.setMilliseconds(milliseconds);
			
			// reset time field to correct formatting
			var outTimeStr = restform.util.pad(hours, "0", 2) + ":" + restform.util.pad(minutes, "0", 2);
			if (seconds != 0 || milliseconds != 0) {
				outTimeStr += ":" + restform.util.pad(seconds, "0", 2);
				if (millisStr) {
					outTimeStr += "." + millisStr;
				}
			}
			if (timeStr != outTimeStr) {
				jqTime.val(outTimeStr);
			}
			return outTimeStr;
		} else if (timeStr) {
			throw "Date is not set ('" + date + "'), cannot set time in date-time component.";
		}
	};
	
	this.getRegional = function () {
		var currentLocale = restform.input.datepickerLocale;
		var regional = jQuery.datepicker.regional[currentLocale];
		if (!regional) {
			regional = jQuery.datepicker.regional[""]; // default
		}
		return regional;
	};

	/**
	 * Convert date string from JSON format to regional format.
	 * @param outputVal JSON string in date or date-time format
	 * @return string of incoming date converted to regional format
	 */
	this.formatDate = function (outputVal, jqEl) {
		if (jqEl && jqEl.attr("data-rf-type") == "date" && outputVal) {
			try {
				var date = new Date(outputVal);
				var dateValue = 
					jQuery.datepicker.formatDate(
							restform.dateutil.getRegional().dateFormat, date);
				if (dateValue.indexOf("NaN") == -1) {
					outputVal = dateValue;
					if (jqEl.hasClass("date-time")) {
						var outTimeStr = 
							restform.util.pad(date.getHours(), "0", 2) 
							+ ":" + restform.util.pad(date.getMinutes(), "0", 2);
						if (date.getSeconds() != 0 || date.getMilliseconds() != 0) {
							outTimeStr += ":" + restform.util.pad(date.getSeconds(), "0", 2);
							if (date.getMilliseconds()) {
								outTimeStr += "." + restform.util.pad(date.getMilliseconds(), "0", 3);
							}
						}
						outputVal += " " + outTimeStr;
					}
				} else {
					console.log("Formatted date value had NaNs: '" + dateValue + "'");
				}
			} catch (e) {
				console.log("Converting date '" + outputVal + "' to regional failed.", e);
			}
		}
		return outputVal;
	};
};
