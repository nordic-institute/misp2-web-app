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
 * Takes a list of widgets (or a single widget) and rescales exterior frame
 * and relocates the widget so that height-wise it will fit into the frame.
 * @param widget JQuery html element or list of those elements
 * @param initializeHeight boolean: before recalculation, let frame height go to default
 * @param frame JQuery HTML element that surrounds the widget
 * @param ignoreHidden boolean: ignore hidden widget
 */
function fitWidget(widgets, initializeHeight, frame, ignoreHidden){
	if(typeof frame == "undefined"){
		frame = $(".maincontent");
	}
	if(typeof widgets == "undefined"){
		widgets = $("#orbeon-calendar-div");
	}
	if(typeof initializeHeight == "undefined"){
		initializeHeight = true;
	}
	if(typeof ignoreHidden == "undefined"){
		ignoreHidden = true;
	}
	//var widget = $("#orbeon-calendar-div");
	if(initializeHeight){
		
		//console.log("//console.log(initializeHeight): " + initializeHeight + " frame: " + frame);
		frame.height("");
	}
	
	function isVisible(widget){
		if (widget && widget.length != 0 &&  widget.css('visibility') != "hidden")
			return true;
		return false;
	}
	
	function scaleDimensions(){
		var widget = $(this);
		//console.log(this);
		//console.log(frame);
		var relevantObject = isVisible(widget);
		//console.log("visible " + relevantObject );
		if(relevantObject){
			var widget_offset = widget.offset();
			var height_widget = widget.height();
			var width_widget = widget.width();

			var frame_offset = frame.offset();
			var height_frame = frame.height();
			var width_frame = frame.width();

			var y_top_widget = widget_offset.top;
			var y_top_frame =  frame_offset.top;
			var y_down_widget = y_top_widget + height_widget;
			var y_down_frame = y_top_frame + height_frame;
			
			
			var x_left_widget = widget_offset.left;
			var x_left_frame =  frame_offset.left;
			var x_right_widget = x_left_widget + width_widget;
			var x_right_frame = x_left_frame + width_frame;

			var y_shift = 0;
			var height_shift = 0;
			
			
			
			
			// if widget is higher than frame
			// shift it down so that its top is exactly as high as frame top
			if (y_top_frame > y_top_widget ){ 
					widget.css("top", widget.position().top + (y_top_frame - y_top_widget));
					
					// since we moved the widget, we'll recalculate its coordinates
					widget_offset = widget.offset();
					y_top_widget = widget_offset.top;
					y_down_widget = y_top_widget + height_widget;
					
			}

			// if widget crosses the frame from bottom
			// increase frame height
			if (y_down_frame < y_down_widget ){ 
					frame.height(frame.height() + (y_down_widget - y_down_frame));
					// since we moved the widget, we'll recalculate its coordinates
					height_frame = frame.height();
					y_down_frame = y_top_frame + height_frame;
			}
			
			// if widget left from the frame
			// shift it riht
			if (x_left_frame > x_left_widget){ 
					widget.css("left", widget.position().left + (x_left_frame - x_left_widget));
					// since we moved the widget, we'll recalculate its coordinates
					widget_offset = widget.offset();
					
					x_left_widget = widget_offset.left;
					x_right_widget = x_left_widget + width_widget;
			}
			
			// if widget left from the frame
			// shift it riht
			else if (x_right_frame < x_right_widget ){
					widget.css("left", widget.position().left - (x_right_widget - x_right_frame));
					// since we moved the widget, we'll recalculate its coordinates
					widget_offset = widget.offset();
					
					x_left_widget = widget_offset.left;
					x_right_widget = x_left_widget + width_widget;

			}
			
			
			//console.log("frame y_top:" + y_top_frame + ", x_left:" + x_left_frame + ", y_bottom:" + y_down_frame + ", x_right:" + x_right_frame);
			//console.log("widget y_top:" + y_top_widget + ", x_left:" + x_left_widget + ", y_bottom:" + y_down_widget + ", x_right:" + x_right_widget);
			
		}
	}
	if(Object.prototype.toString.call( widgets ) === '[object Array]'){ 
		for(var i = 0; i < widgets.length; i++){
			widgets[i].each(scaleDimensions);
		}
	}
	else{
		widgets.each(scaleDimensions);
	}
	//widgets.each(scaleDimensions);
}

/** 
 * In case we want to loop fitWidget forever
 */
function fitWidgetRecursive(){
	fitWidget();
	window.setTimeout('fitWidgetRecursive()', 500);
}
// If calendar is present attach window rescaler to document (
// because click can be outside of orbeon frame)
/*if($("#orbeon-calendar-div").length != 0){
	// functions must be given as callbacks, since in Chrome, that works, but giving fucntion directly
	// or making it a variable does not work.
	$(document).click(function(){window.setTimeout('fitWidget([$("#orbeon-calendar-div")])', 0);});
	$(document).keydown(function(){window.setTimeout('fitWidget([$("#orbeon-calendar-div")])', 0);});
}*/
