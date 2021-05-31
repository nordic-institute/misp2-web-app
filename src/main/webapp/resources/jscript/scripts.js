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

// suffix must be added to to all checkboxes, if more than one 'checkall' is used (look in groupEditRights.jsp for an example)
function checkUncheckAll(suffix, form_id) {
	if(!suffix){
		suffix = "";
	}
	var checked = $('#checkall' + suffix).is(':checked');
	if(!form_id){
		form_id = "form_queries";
	}
	if(suffix == "")
		suffix = "]"; // ugly hack for listQueries.jsp
	// check/uncheck all
    $('[id^="'+ form_id +'"]').find("input[type='checkbox'][id$='" + suffix + "']:not([name^='checkall'])").each(function() {
        this.checked = checked;
        // image is used for check mark (adjust background)
        if(checked)
        	$(this).prev().css('backgroundPosition', '0 -32px');
        else
        	$(this).prev().css('backgroundPosition', '0 0px');
    });
}

function showHideLogSearchParams(selObj){
    index = selObj.selectedIndex-1;
    switch(index){
        case -1 :
            setVisibleInvisible(0);
            break;
        case 0 :
            setVisibleInvisible(1, "SsnTo");
            break;
        case 1 :
            setVisibleInvisible(1, "GroupName");
            break;
        case 2 :
            setVisibleInvisible(1, "GroupName", "SsnTo");
            break;
        case 3 :
            setVisibleInvisible(1, "GroupName");
            break;
        case 4 :
            setVisibleInvisible(1, "SsnTo");
            break;
        case 5 :
            setVisibleInvisible(1);
            break;
        case 6 :
            setVisibleInvisible(1, "QueryId");
            break;
        case 7 :
            setVisibleInvisible(1, "QueryId");
            break;
        case 8 :
            setVisibleInvisible(1, "GroupName");
            break;
    }

}
// param = 0 >> set invisible; 
// param = 1 >> set visible;

function setVisibleInvisible(param, visible, visible2){
    //    var divs = document.getElementsByTagName("tr");
    var divs = $("#t3secForm").find("li");
    for (var i=0; i<divs.length; i++)
        if (divs[i].id.indexOf("logSearch") == 0 && param==0)
            divs[i].style.display = "none";
        else{
            if(divs[i].id.indexOf("logSearchDateFrom") == 0 || divs[i].id.indexOf("logSearchDateTo") == 0 || divs[i].id.indexOf("logSearchSsnFrom") == 0 || divs[i].id.indexOf("logSearchOrgCode") == 0 || divs[i].id.indexOf("logSearchSubmit") == 0)
                divs[i].style.display = "";
            else if(divs[i].id.indexOf("logSearch"+visible) == 0 || divs[i].id.indexOf("logSearch"+visible2) == 0)
                divs[i].style.display = "";
            else if(divs[i].id.indexOf("logSearch") == 0)
                divs[i].style.display = "none";
        }
}

/* end of tThreeSec.jsp part */


function checkDate(userDate, errorMessage){
    var RegExPattern = /^((((0?[1-9]|[12]\d|3[01])[\.\-\/](0?[13578]|1[02])[\.\-\/]((1[6-9]|[2-9]\d)?\d{2}))|((0?[1-9]|[12]\d|30)[\.\-\/](0?[13456789]|1[012])[\.\-\/]((1[6-9]|[2-9]\d)?\d{2}))|((0?[1-9]|1\d|2[0-8])[\.\-\/]0?2[\.\-\/]((1[6-9]|[2-9]\d)?\d{2}))|(29[\.\-\/]0?2[\.\-\/]((1[6-9]|[2-9]\d)?(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00)|00)))|(((0[1-9]|[12]\d|3[01])(0[13578]|1[02])((1[6-9]|[2-9]\d)?\d{2}))|((0[1-9]|[12]\d|30)(0[13456789]|1[012])((1[6-9]|[2-9]\d)?\d{2}))|((0[1-9]|1\d|2[0-8])02((1[6-9]|[2-9]\d)?\d{2}))|(2902((1[6-9]|[2-9]\d)?(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00)|00))))$/;
    if ((userDate.val().match(RegExPattern)) && (userDate.val()!='')) {
        return true;
    } else {
        alert(errorMessage);
        userDate.focus();
    } 
    return false;				
}

Date.prototype.setISO8601 = function (string) {
    var regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
        "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
        "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?";
    var d = string.match(new RegExp(regexp));

    var offset = 0;
    var date = new Date(d[1], 0, 1);

    if (d[3]) { date.setMonth(d[3] - 1); }
    if (d[5]) { date.setDate(d[5]); }
    if (d[7]) { date.setHours(d[7]); }
    if (d[8]) { date.setMinutes(d[8]); }
    if (d[10]) { date.setSeconds(d[10]); }
    if (d[12]) { date.setMilliseconds(Number("0." + d[12]) * 1000); }
    if (d[14]) {
        offset = (Number(d[16]) * 60) + Number(d[17]);
        offset *= ((d[15] == '-') ? 1 : -1);
    }

    offset -= date.getTimezoneOffset();
    time = (Number(date) + (offset * 60 * 1000));
    this.setTime(Number(time));
}

/**
* Funktsiooni kasutatakse xbl komponenti tekstide tõlkimiseks
*/
function translateLabels(){
$('.trans_lbl').each(function(){
	var lang = $('html').attr('lang');
	var text = $(this).attr('itemprop').split('|');
	if (lang == 'en') {
				   $(this).text(text[1]);
	} else if (lang == 'ru') {
				   $(this).text(text[2]);
	} else {
				   $(this).text(text[0]);
	}
	});
}
