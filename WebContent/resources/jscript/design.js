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

(function ($) {
    $(document).ready(function(){
    	$('#hideHeader').click(function(){
    		$("#header").toggle();
    		$("#arrow-up").toggle();
    		$("#arrow-down").toggle();
    	});

        $('#language a, #menu a').each(function(){
            $(this)
            .html('<span class="sliding-door">' + $(this).html() + '</span>')
            .prepend('<span class="sliding-door-left"></span>')
            .append('<span class="sliding-door-right"></span>');
        });
    	
    	$(".numberField").keypress(function(e) {
            if( e.which!=8 && e.which!=0 && (e.which<48 || e.which>57)){
                return false;
            }
        });        
        
            
        $("h3.toggle").each(function(){
        	if($.cookie('show-' + $(this).next().attr("id"))!='expanded'){
        		if($("h3.toggle").attr("id")==$(this).attr("id") && $.cookie('show-' + $(this).next().attr("id"))!='collapsed'){
        			$(this).toggleClass("active");
            		$(this).next().toggle(true);
        		}else{
        			$(this).toggleClass("");
            		$(this).next().toggle(false);
        		}
        	} else{
        		$(this).toggleClass("active");
        		$(this).next().toggle(true);
        	}
        });
        $("h3.toggle").click(function () {
            var tc = $(this).toggleClass("active").next().slideToggle("slow", function() {
                $.cookie('show-' + $(this).attr("id"), $(this).is(":hidden") ? 'collapsed' : 'expanded');
            });
            return false;
        });

        $(window).scroll(function() {
        	var height = 178;
			var scroller_object = $('.scrollable');
			if(document.documentElement.scrollTop >= height || window.pageYOffset >= height) {
				if($.browser.msie && $.browser.version == '6.0') {
					scroller_object.css('top', (document.documentElement.scrollTop + 16) + 'px');
				} else {
					scroller_object.css({'position':'fixed','top':'16px','width':'266px'});
				}
			} else if (document.documentElement.scrollTop < height || window.pageYOffset < height) {
				scroller_object.css({'position':'absolute','top':'196px','width':'266px'});
			}
		});

        $('input:disabled').css('opacity','.4');

        $('select:not([multiple]).styled').selectmenu({
            style:'dropdown',
            maxHeight:300
        });

        $('button, .button').wrap('<span />');

        if (jQuery.browser.msie){
            try{
                document.execCommand("BackgroundImageCache", false, true);
            }catch(err){}
        }
    });
}) (jQuery);

function updateXformUrls(n){
	var changed = false;
	for(var i = 0; i < n; i++) {
		if($('#updateXforms\\['+i+'\\]').attr('checked')=='checked'){
			changed = true;
			var serviceName = $.trim($("#xforms_link\\["+ i +"\\]").parent().next().text());
            $('#xformsUrl\\['+i+'\\]').val($("#repositoryUrl").val() + $.trim(serviceName));
        }
	}
	if(!changed) alert($("#validation.service.none.selected".split(".").join("\\.")).val());
}