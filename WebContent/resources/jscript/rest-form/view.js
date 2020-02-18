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
 * Functions switching between views
 */
restform.view = new function() {

	/**
	 * Show respective view (e.g. 'teenus.input') for given element
	 * @param target view block 'id' attribute or view element itself or element within view
	 *        that needs to be displayed
	 */
	this.toggleToView = function(target) {
		// hide all views
		jQuery(".view").hide();
	
		// if target is 'id' attribute value
		if (typeof target === 'string') {
			target = ".view[id='" + target + "']";
		} // else // DOM or jQuery object
	
		// show target view
		var jqTarget = jQuery(target);
		if (jqTarget.hasClass("view")) {
			jqTarget.show();
		} else {
			jqTarget.closest(".view").show();
		}
		var afterToggleFn = restform.event.getHandler(jqTarget, "afterToggle");
		if (afterToggleFn) {
			afterToggleFn(jqTarget);
		}
	};

	/**
	 * Return target view block for given source element.
	 * Source element has data-rf-target attribute is used as target view 'id' if it exists.
	 * Otherwise, determine target view by replacing '.input' with '.output' and '.output' with '.input' in
	 * Else, source view itself is returned.
	 * @param source view block 'id' attribute or toggle/send button DOM element
	 * @return target view jQuery element (or source jQuery element if no target was found)
	 */
	this.getTargetView = function(source) {
		var jqSource = jQuery(source);
		// if data-rf-target attribute exists, read target from there
		var target = jqSource.attr("data-rf-target");
		if (target) {
			return jQuery(".view[id='" + target + "']");
		}
	
		// if data-rf-target attribute is missing, find respective output or input view to given input or output view
		var idSource;
		if (jqSource.hasClass("view")) {
			idSource = jqSource.attr("id");
		} else {
			idSource = jqSource.closest(".view").attr("id");
		}
		if (idSource) {
			var idTarget;
			if (idSource.match(/\.input$/)) {
				idTarget = idSource.replace(/\.input$/, "") + ".output";
			} else if (idSource.match(/\.output$/)) {
				idTarget = idSource.replace(/\.output$/, "") + ".input";
			}
			var jqTarget = jQuery(".view[id='" + idTarget + "']");
			if (jqTarget.length > 0) {
				return jqTarget;
			}
		}
		return jqSource; // no matching view was found, return input view
	};
};
