/*
 * The MIT License
 * Copyright (c) 2020- Nordic Institute for Interoperability Solutions (NIIS)
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
 * This file makes links with "confirmablePostLink" data attribute act as POST form submitters instead of performing GET request
 */

/**
 * Disable context menu on all links with "confirmablePostLink" data attribute.
 * It is done because it is not possible to bind events to "Open link in new ..." operations in context menu.
 */
$(document).ready(function(){
	$("a[data-confirmable-post-link]").bind("contextmenu", function(){
        return false;
    });
});

/**
 * Bind click event handler on link with "confirmablePostLink" data attribute,
 * which when that attribute has non-undefined and non-empty value, displays confirmation dialog with that value which allows user to cancel event processing.
 * If beforementioned data attribute is undefined or empty or user agrees in confirmation dialog, then link is submitted as POST form.
 * Normal link behaviour of performing GET request is always denied.
 */
$(document).on("click", "a[data-confirmable-post-link]", function(e){	
	var confirmMessage = $(this).data("confirmablePostLink");
	if(confirmMessage!=undefined && confirmMessage!=""){
		if(confirm(confirmMessage)==false){
			return false;
		}
	}
	
	Utils.postURL($(this).prop("href"));
	
	e.preventDefault();
});