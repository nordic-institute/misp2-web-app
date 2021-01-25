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
	updateChosenSubOrgIdSelectEnabledness();
	
	$("input[type='checkbox'][name='includeSubOrgsAndGroups']").change(function(){
		updateChosenSubOrgIdSelectEnabledness();
	});
	
	$("button[type='button'][name='exportButton']").click(function(){
        var confirmMessage = $("input[type='hidden'][name='exportConfirmMessage']").val();
		if(confirm(confirmMessage)==false)return;
		
		var form$ = $("form[name='exportImportFile']");
		form$.prop("action", "exportFile.action");
		form$.submit();
	});
	
	$("button[type='button'][name='importButton']").click(function(){
        var confirmMessage = $("input[type='hidden'][name='importConfirmMessage']").val();
		if(confirm(confirmMessage)==false)return;
		
		Utils.displayLoadingOverlay();
		
		var form$ = $("form[name='exportImportFile']");
		form$.prop("action", "importFile.action");
		form$.submit();
	});
	
	/**
	 * Updates chosenSubOrgId select enabledness according to includeSubOrgsAndGroups checkbox state (if that select does not exist, then does nothing)
	 */
	function updateChosenSubOrgIdSelectEnabledness(){
		var checked = $("input[type='checkbox'][name='includeSubOrgsAndGroups']").prop("checked");
		$("select[name='chosenSubOrgId']").prop("disabled", checked==false);
	}
});