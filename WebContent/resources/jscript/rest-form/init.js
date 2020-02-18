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
 * REST form initialization functions.
 */
restform.init = new function() {
	/**
	 * Initializes DOM elements that lose their properties after cloning. So method is called during initialization,
	 * but also after repeat block is added.
	 * @param jqContainer jQuery element container - can be either the entire REST form or cloned repeat block.
	 */
	this.initFormElements = function (jqContainer) {
		// Add datepicker widget to class="date" or class="date-time" inputs
		restform.dateutil.initDateWidgets(jqContainer);
		// Add base64 defaults if given
		var jqBase64Inputs = jqContainer.find(".base64[data-rf-default]");
		jqBase64Inputs.each(function (){
			var jqBase64Input = jQuery(this);
			if (jqBase64Input.closest("[data-rf-repeat-template-path]").length > 0) {
				return; // Do not add default to repeat templates
			}
			// assume default value is already in base64 format
			var val = jqBase64Input.attr("data-rf-default");
			jqBase64.removeAttr("data-rf-default");
			jqEl.data("base64", val);
		});
	};
	
	/**
	 * Process language-specific HTML elements so that at least one translation alternative would be visible for each
	 * translation group.
	 */
	this.preprocessLangElements = function(jqRestForm, secondDefaultLang) {
		// For style, buttons are wrapped into spans with JavaScript. In this case move data-rf-lang attribute to the parent span.
		jqRestForm.find("button[data-rf-lang]").each(function() {
			var jqButton = jQuery(this);
			if (jqButton.parent().prop("tagName") == "SPAN" && jqButton.parent().children().length == 1) {
				jqButton.parent().attr("data-rf-lang", jqButton.attr("data-rf-lang"));
				jqButton.removeAttr("data-rf-lang");
			}
			
		});
		
		var langGroup = []; // Group together elements representing various translations of the same node in UI
		var jqPrev = null; // Previous 

		var jqLangElements = jqRestForm.find("[data-rf-lang]");
		var langElementsLength = jqLangElements.length;
		/**
		 * Display an element in a group of elements in case all elements are hidden.
		 * This is necessary
		 * @param langGroup array of jQuery elements considered to
		 *        represent the same item in different languages.
		 */
		function processLangGroup(langGroup) {
			var jqShown = null;			// Priority 1: first already visible element in group
			var jqFirstDefault = null;	// Priority 2: element corresponding to language code 'default'
			var jqSecondDefault = null;	// Priority 3: element corresponding to default language
			var jqFirst = null; 		// Priority 4: first element in group

			for (var i = 0; i < langGroup.length; i++) {
				var jqLangEl = langGroup[i];
				if (jqShown == null && jqLangEl.attr("data-rf-lang") == restform.util.getLang()) {
					jqShown = jqLangEl;
				}
				if (jqFirstDefault == null && jqLangEl.attr("data-rf-lang") == "default") {
					jqFirstDefault = jqLangEl;
				}
				if (jqSecondDefault == null && jqLangEl.attr("data-rf-lang") == secondDefaultLang) {
					jqSecondDefault = jqLangEl;
				}
				if (jqFirst == null) {
					jqFirst = jqLangEl;
				}
			}
			if (jqShown == null) { // If there are no visible elements in the group
				jqShown = jqFirstDefault || jqSecondDefault || jqFirst; // pick first match
				if (jqShown != null) {
					// loop over entries
					for (var i = 0; i < langGroup.length; i++) {
						var jqLangEl = langGroup[i];
						// if entry is not going to be displayed, remove display style property,
						// so that element would not be displayed
						if (jqLangEl[0] != jqShown && jqLangEl.attr("style")) {
							var style = jqLangEl.attr("style");
							// replace display attribute with empty string
							jqLangEl.attr("style", style.replace(/display:[^:]+;/, ""));
							// If style attribute is now empty, remove it entirely
							if (!jQuery.trim(jqLangEl.attr("style"))) {
								jqLangEl.removeAttr("style"); 
							}
						}
					}
					// Display element by getting rid of data-rf-lang attribute
					jqShown.show();
				}
			}
		}
		jqLangElements.each(function() {
			var jqEl = jQuery(this);
			// in case previous element was in the same group, add new element to the group
			if (jqPrev == null || jqEl.prev()[0] == jqPrev[0] && jqEl.prop("tagName") == jqPrev.prop("tagName")) {
				langGroup[langGroup.length] = jqEl;
				jqPrev = jqEl;
			} else { // in case previous element was in a different group
				processLangGroup(langGroup); // process previous group
				langGroup = [jqEl]; // start new group
				jqPrev = null;
			}
		});
		processLangGroup(langGroup); // process the entries in the last group
	};
};

/**
 * Initialize REST form listeners, datepicker and perform necessary DOM changes.
 * Depends on all the other rest-form scripts and assumes those are already loaded. 
 */
jQuery(document).ready(function() {
	// Keep overlay on during initialization
	Utils.displayLoadingOverlay();
	
	// Set constants
	// Show only: if set to true, REST requests are not sent, instead
	restform.query.showOnly = false;
	
	// Find REST form container element - all REST form elements and events are registered within that frame
	var jqRestForm = jQuery("#body .rest-form");
	restform.jqRestForm = jqRestForm;
	
	// Set datepicker default locale (datepickerLocale is defined in runQueryRest.jsp)
	jQuery.datepicker.setDefaults( restform.dateutil.getRegional() );
	
	// Commented out for now: Overwrite labels derived from JSON field names
	/* jQuery("label.property-derived").each(function() {
		var jqEl = jQuery(this);
		jqEl.text(restform.json.pathToLabel(jqEl.text()));
	}); */
	
	// Add validation
	jqRestForm.on("change", restform.input.inputSelector, function() {
		restform.input.validate(this);
	});
	
	// Add file size on selecting a file
	jqRestForm.on("change", "input[type=file]", function() {
		restform.file.addFileSize(this, restform.file.getTotalFileSize(this));
	});
	
	// On file upload, if format is base64, convert content to base64
	jqRestForm.on("change", "input[type=file].base64", function() {
		restform.file.addBase64(this);
	});
	
	// register sending to REST mediator event for send buttons
	jqRestForm.on("click", ".send", function(event) {
		event.preventDefault();
		restform.query.send(this);
	});

	// toggle to first view
	restform.view.toggleToView(jQuery(".view:eq(0)"));
	// register toggling between views forms
	jqRestForm.on("click", ".toggle", function(event) {
		event.preventDefault();
		restform.view.toggleToView(restform.view.getTargetView(this));
	});
	
	// Repeat element handling
	// Add another repeat element from template
	jqRestForm.on("click", ".add", function(event) {
		event.preventDefault();
		restform.repeat.addBlockFromRepeatTemplate(
				jQuery(this).closest(".repeat-container").children("[data-rf-repeat-template-path]"));
	});
	// Add delete button click handler for repeats
	jqRestForm.on("click", ".delete", function(event) {
		event.preventDefault();
		restform.repeat.deleteRepeatBlock(jQuery(this).closest(".repeat-block"));
	});
	// For future reference, a debug flag is implemented
	restform.debugEnabled = jQuery("input[name=debug-enabled]").val() == "true";
	
	// Add colon to labels with jQuery, because 
	// adding text content with CSS results in no separator between labels and data fields
	// when data is copied/pasted from query output view.
	jqRestForm.find(".field > label").each(function() {
		var jqLabel = jQuery(this);
		var text = jQuery.trim(jqLabel.text());
		if (text[text.length - 1] != ":") {
			jqLabel.text(text + ":");
		}
	});
	
	if (!restform.langPreprocessingDisabled) {
		// Show a label in a group without label with current UI language code 
		// (because all labels would be otherwise hidden)
		restform.init.preprocessLangElements(jqRestForm, "en");
	}
	
	// Init elements that need to be reinited after clone
	restform.init.initFormElements(jqRestForm);
	
	// Add asterisk to required fields
	jqRestForm.find(".required").each(function() {
		var jqEl = jQuery(this);
		var jqLastEl = jqEl.parent().children().last();
		if (!jqLastEl.hasClass("required-mark")) {
			jqEl.parent().append(jQuery("<span>", {"class": "red required-mark"}).text("*"));
		}
	});
	
	// Add multipart info attributes
	restform.multipart.addMultipartIdAttributes(jqRestForm);
	
	Utils.hideLoadingOverlay();
	
	// Run unit tests if loaded
	if (restform.test && window.location.href.indexOf("&runTests") != -1) {
		restform.test.run();
	}
});
