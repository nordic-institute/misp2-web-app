/**
 * Applies CSRF protection to page
 * 1) Attaches submit event to document, which get's called if any form (statically or dynamically added) is submitted and if form has method "post" and does not already have hidden input csrfToken input,
 * then appends hidden csrfToken input to form
 * 2) Attaches ajaxSend event to document, which adds csrfToken parameter to Ajax data, if type is "POST"
 * 3) Attaches ajaxError event to document, which redirects to default page if jqxhr status is 440 (login timeout (expect, that this only happens in case of CSRF error))
 */
$(document).ready(function(){
	var csrfHeaderName = serverData.getCSRFHeaderName();
	var csrfToken = serverData.getCSRFToken();
	
	$(document).on("submit", "form", function(){
		var form$ = $(this);
		if(form$.prop("method")=="post"){//Only POST requests need to be CSRF protected, because it is assumed that GET requests do not modify server data
			var csrfTokenInput$ = form$.find("input[type='hidden'][name='csrfToken']");
			if(csrfTokenInput$.length==0){
				csrfTokenInput$ = $("<input>").attr("type", "hidden").attr("name", "csrfToken").attr("value", csrfToken);
				form$.append(csrfTokenInput$);
			}
		}
	});
	
	$(document).ajaxSend(function(event, jqxhr, settings){
		if(settings["type"] != "GET"){ 
			// For any HTTP action, add CSRF token to request header
			// GET requests are not CSRF protected, because it is assumed that GET requests do not modify server data
			jqxhr.setRequestHeader(csrfHeaderName, csrfToken);
		}
	});
	
	$(document).ajaxError(function(event, jqxhr, settings, exception) {
		if(jqxhr.status == 440){//Login timeout (expect, that only CSRF error may generate this)
			window.location.href = absoluteURL.getURL("login_user.action");
		}
	});
});