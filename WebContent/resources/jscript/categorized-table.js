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

$(document).ready(function(){
   	$("table.categorized").each(function(){
   		$(this).find("tr:first th").each(function(){
   			$(this).css("width",$(this).width());//All columns are forced to their width when all categories are opened. Otherwise width changes when categories are opened/closed
   		});
   	});
    
    $("td.header").each(function(){
    	var id = $(this).attr('id');
    	$("tr."+id).each(function(){
    		$(this).css("display","none");//All categories are closed at the beginning
    	});
    });
    
    $("td.header").click(function(){
    	$(this).toggleClass("selected");//select/unselect
    	var id = $(this).attr('id');
    	$("tr."+id).each(function(){
    		if($(this).css("display")=="none"){//open or close
    			$(this).css("display","table-row");
    		}else{
    			$(this).css("display","none");
    		}
    	});
    });
});