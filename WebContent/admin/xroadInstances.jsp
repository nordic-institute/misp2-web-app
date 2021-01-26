<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page  pageEncoding="UTF-8" %>
<%--
  ~ The MIT License
  ~ Copyright (c) 2020- Nordic Institute for Interoperability Solutions (NIIS)
  ~ Copyright (c) 2019 Estonian Information System Authority (RIA)
  ~
  ~ Permission is hereby granted, free of charge, to any person obtaining a copy
  ~ of this software and associated documentation files (the "Software"), to deal
  ~ in the Software without restriction, including without limitation the rights
  ~ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  ~ copies of the Software, and to permit persons to whom the Software is
  ~ furnished to do so, subject to the following conditions:
  ~
  ~ The above copyright notice and this permission notice shall be included in
  ~ all copies or substantial portions of the Software.
  ~
  ~ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  ~ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  ~ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  ~ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  ~ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  ~ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  ~ THE SOFTWARE.
  ~
  --%>

<%-- This fragment is included by portalShow.jsp and adds service X-Road instance
	table, style and download functionality --%>
 <head>
 	<!-- Style for service X-Road instances in admin interface -->
   	<style type="text/css">
	    #service-xroad-instances-container {
	    	display: inline-block;
	    }
	    #service-xroad-instances-retriever, #service-xroad-instances-restorer {
	    	margin-top: 0px;
	    	margin-bottom: 0px;
	    	/* When added to another button
	    	margin-left: 10px;*/
	    }
	    #service-xroad-instances-retriever.running {
	    	background: #999 !important;
	    }
	    #service-xroad-instances-loading {
	    	display:none;
	    	width:25px;
	    	vertical-align: middle;
	    	/*margin-top:22px;*/
	    }
	</style>

 	<!-- JavaScript for service X-Road instances in admin interface -->
	<script type="text/javascript">
	    $(document).ready(function() {
	    	
	    	function ClientXroadInstances() {
	    		this.getSelect = function() {
	    			return jQuery("#portalXroadInstance");
	    		}
	    		
	    		this.removeInstances = function() {
	    			var jqSel = this.getSelect();
	    			// save previously selected instance code
	    			this.prevCode = jqSel.val();
	    			// remove all select options
	    			jqSel.children().remove();
	    			// remove all the spans added by select-plugin
	    			jqSel.parent().children("span").filter(function() {
	    				var className = jQuery(this).attr("class");
	    				if (className && className.indexOf("select") >= 0) {
	    					return true;
	    				}
	    				className = jQuery(this).children("a").attr("class");
	    				return className && className.indexOf("ui-selectmenu") >= 0;
	    			}).remove();
	    			// assign parent element: new select element will be built inside it
	    			this.parent = jqSel.parent();
	    			// save HTML of select element (without options): this will be used to build new select
	    			this.selHtml = jqSel.clone().wrap('<div>').parent().html();
	    			// finally, remove select element from DOM
	    			jqSel.remove();
	    		}
	    		
	        	this.addInstance = function(code, inUse) {
	        		// create select-element wrapper in case it does not exist
	        		if (this.getSelect().length == 0) {
	        			this.parent.find(".bookmark").before(this.selHtml);
	        		}
	        		// initialize 'value' and 'selected' attributes
	        		var attrs = {"value": code};
	        		if (inUse) {
	        			attrs["selected"] = "selected";
	        		}
	        		// append 'option' element to 'select' wrapper
	    			this.getSelect().append(
							jQuery("<option>", attrs).text(code)
					);
	        	}
	    		
	        	/**
	        	 * @return true if select element has option with given value
	        	 */
	    		this.hasValue = function(val) {
	    			var jqSel = this.getSelect();
	    			var jqOption = jqSel.find("option").filter(function() {
	    				return jQuery(this).val() == val;
	    			});
	    			return jqOption.length > 0;
	    		}
	    		
	        	/**
	        	 * Recover previously saved value if it exists
	        	 */
	    		this.recoverPreviouslySelected = function() {
	    			if (this.prevCode && this.hasValue(this.prevCode)) {
		    			var jqSel = this.getSelect();
		    			jqSel.val(this.prevCode); // change select value
		    			jqSel.click(); // needed to change val in UI
	    			}
	    		}
	    		
	        	/**
	        	 * Recover previous value and
	        	 * initialize 'select' element with jQuery select plugin
	        	 */
	    		this.reinitialize = function(newCodes) {
					// add service instances one by one
    				for (var i = 0; i < newCodes.length; i++) {
						this.addInstance(newCodes[i], i == 0);
    				}
	    			this.recoverPreviouslySelected();
	    			var jqSel = this.getSelect();
	    			jqSel.selectmenu({
	    	            style:'dropdown',
	    	            maxHeight:300
	    	        });
	    			Utils.animateNotification(jQuery("#portalXroadInstance-button span"), '#E6E6E6');
	    		}
	    	}
	    	
	    	
	        function ServiceXroadInstances() {
	        	this.getTable = function() {
	        		return $("#service-xroad-instances");
	        	}
	        	this.getTableRows = function() {
	        		return this.getTable().find("tr").filter(function() {
	        			return jQuery(this).children("th").length == 0;
	        		});
	        	}
	        	this.findInstanceCodeInputs = function(jqEl) {
	        		if (!jqEl) {
	        			jqEl = this.getTableRows();
	        		}
	        		return jqEl.find("input[name$='.code']");
	        	}
	        	this.findInUseInputs = function(jqEl) {
	        		if (!jqEl) {
	        			jqEl = this.getTableRows();
	        		}
	        		return jqEl.find("input[name$='.inUse']");
	        	}
	        	this.findInstanceCodeInput = function(code) {
	        		return this.findInstanceCodeInputs()
		    			.filter(function(){
		    				return $(this).val() == code;
		    			});
	        	}
	        	this.findInstanceRow = function(code) {
	        		return this.findInstanceCodeInput(code).closest("tr");
	        	}
	        	
	        	this.getMaxIndex = function() {
	        		var maxIndex = -1;
	        		this.findInstanceCodeInputs()
		    			.each(function(){
		    				var name = jQuery(this).attr("name");
			    			var indexStr = name.substring(name.indexOf("[") + 1, name.indexOf("]"));
			    			var index = parseInt(indexStr);
			    			if (index > maxIndex) {
			    				maxIndex = index;
			    			}
		    			});
		    		return maxIndex;
	        	}
	
	        	/**
	        	 * Remove row from instance table.
	        	 * @param code X-Road instance code, e.g. ee-dev
	        	 */
	        	this.removeInstance = function(code) {
	        		this.findInstanceRow(code).remove();
	        	}
	        	
	        	
	        	this.getSelectedInstanceCodes = function() {
	        		var instanceCodes = [];
	        		var jqRows = this.getTableRows();
	        		for (var i = 0; i < jqRows.length; i++) {
	        			var jqRow = jQuery(jqRows[i]);
	        			var jqInUseInput = this.findInUseInputs(jqRow);
	        			if (jqInUseInput.is(":checked")) {
		        			var jqCodeInput = this.findInstanceCodeInputs(jqRow);
		        			instanceCodes[instanceCodes.length] = jqCodeInput.val();
	        			}
	        		}
	        		return instanceCodes;
	        	}
	        	
	        	this.getAllCodesFromTable = function() {
	        		var oldCodes = [];
	        		var codeInputs = this.findInstanceCodeInputs();
	        		for (var i = 0; i < codeInputs.length; i++) {
	        			oldCodes[i] = jQuery(codeInputs[i]).val();
	        		}
	        		return oldCodes;
	        	}
	        	
	        	this.removeInstances = function() {
	        		// Save previously selected service instance codes
	        		this.prevCodesSelected = this.getSelectedInstanceCodes();
	        		// Save previously selected service instance codes
	        		this.prevCodesAll = this.getAllCodesFromTable();
	        		// Empty instance table
					this.getTableRows().remove();
	        	}
	        	
	        	/**
	        	 * Add instance to table. If instance exists, overwrite only inUse parameter.
	        	 * @param code X-Road instance code, e.g. ee-dev
	        	 * @param inUse true if instance in in use, false if not
	        	 */
	        	this.addInstance = function(code, inUse) {
	        		var jqRow = this.findInstanceRow(code);
	        		if (jqRow.length > 0) { // instance code already exists
	        			var inUseInput = jqRow.find("input[name$='.inUse']");
	        			if (inUseInput.is(":checked") && !inUse ||
	        				!inUseInput.is(":checked") && inUse) { // change inUse checkbox if needed
	            			jqRow.find("span.checkbox").each(Custom.pushed);
	            			jqRow.find("span.checkbox").each(Custom.check);
	        			}
	        		} else {
		        		var i = this.getMaxIndex() + 1;
		        		var jqCheckbox = jQuery("<input>", {
							type: "checkbox",
							name: "serviceXroadInstances[" + i + "].inUse",
							value: "true",
							"class": "styled"
						});
		        		if (inUse) {
		        			jqCheckbox.attr("checked", "checked");
		        		}
		        		this.getTable().append(
							jQuery("<tr>").append(
								jQuery("<td>").append(
									jQuery("<span>").text(code)
								).append(
									jQuery("<input>", {
										type: "hidden", 
										name: "serviceXroadInstances[" + i + "].code",
										value: code
									})
								)
							).append(
								jQuery("<td>").append(
									jqCheckbox
								)
							)
		        		);
		        		// Add normal checkbox behavior from custom-form-elements
		        		Custom.init(jqCheckbox[0]);
	        		}
	        		// Temporarily highlight updated cells by animating them
	        		Utils.animateNotification(this.findInstanceRow(code).find( "td" ), '#FFF');
	        	}
	        	this.containsInstances = function(newCodes) {
	        		if (this.prevCodesSelected && newCodes) {
	        			for (var i = 0; i < this.prevCodesSelected.length; i++) {
	        				var prevCode = this.prevCodesSelected[i];
	        				if (jQuery.inArray(prevCode, newCodes) != -1) {
	        					return true;
	        				}
	        			}
	        		}
	        		return false;
	        	}
	        	
	        	this.getDefaultCodesAsText = function() {
	        		return jQuery("#default-xroad-instances").text();
	        	}
	        	
	        	/**
	        	 * return true, if user downloaded data from security server
	        	 * 	and previously, old data was also from security server 
	        	 * 	or if user restored from default and previous data was also default
	        	 *  (in that case restore)
	        	 */
	        	this.isSameView = function(newCodes) {
	        		var defaultCodes = Utils.extractJSON(this.getDefaultCodesAsText());
	        		var oldCodes = this.prevCodesAll;
	        		var oldIsDefault = Utils.arraysEqual(oldCodes, defaultCodes);
	        		var newIsDefault = Utils.arraysEqual(newCodes, defaultCodes);
	        		return oldIsDefault && newIsDefault || !oldIsDefault && !newIsDefault;
	        	}
	        	
	        	this.reinitialize = function(newCodes) {
	        		// never restore when view changes from loaded->default or vice versa
	        		var sameView = this.isSameView(newCodes);
					var restorePreviousCodes = sameView && this.containsInstances(newCodes);
	        		if (restorePreviousCodes) {
	        			for (var i = 0; i < newCodes.length; i++) {
	        				var newCode = newCodes[i];
	        				if (jQuery.inArray(newCode, this.prevCodesSelected) != -1) {
	        					this.addInstance(newCode, true);
	        				} else {
		        				this.addInstance(newCode, false);
	        				}
	        			}
	        		} else {
	        			for (var i = 0; i < newCodes.length; i++) {
	        				this.addInstance(newCodes[i], true); // mark every instance inUse
	        			}
	        		}
	        	}
	        	
	        }
	        function XroadInstances() {
		        this.clientXroadInstances = new ClientXroadInstances();
		        this.serviceXroadInstances = new ServiceXroadInstances();
		        this.refreshXroadInstances = function(data){
					data = Utils.extractJSON(data);
					if (data) {
	    				if (data.error) {
	    					alert(data.error.message);
	    					if (data.error.code == "XROAD_INSTANCE_QUERY_URL_MISSING" 		||
	        					data.error.code == "XROAD_INSTANCE_QUERY_MALFORMED_URL" 	||
	        					data.error.code == "XROAD_INSTANCE_QUERY_CONNECTION_FAILED"	||
	        					data.error.code == "XROAD_INSTANCE_QUERY_HTTP_ERROR") {
	    						var jqSecServerInput = jQuery("input[name='portal.securityHost']");
	    						jqSecServerInput.focus();
	    		        		Utils.animateNotification(jqSecServerInput, '#FFF');
	    					}
	    				} else {
	    					if (data.length > 0) {
	    						// delete client instances
	    						this.clientXroadInstances.removeInstances();
	    						
	    						// delete all service instances from table before updating
	    						this.serviceXroadInstances.removeInstances();
	    						
	    						// initialize client instance select-box UI and recover previous value
	    						this.clientXroadInstances.reinitialize(data);
	    						
	    						// recover previously selected values if they exist and rebuild service instance table
	    						this.serviceXroadInstances.reinitialize(data);
	    					}
	    				}
					}
				}
	        }
	        
	        var xroadInstances = new XroadInstances();
	        jQuery("#service-xroad-instances-retriever").click(function(event){
	        	event.preventDefault();
	        	var jqButton = jQuery(this);
	        	if (!jqButton.hasClass("running")) {
	        		jqButton.addClass("running");
	        		var jqLoader = jqButton.closest("li").find("#service-xroad-instances-loading");
	        		jqLoader.show();
	            	jQuery.ajax({
	        			url: absoluteURL.getURL("admin/getXroadInstances.action"),
	        			data: {"secServerUrl": jQuery("input[name='portal.securityHost']").val()},
	        			type: "GET",
	        			async: true,
	        			cache: false,
	        			dataType: "html",
	        			success: function(data) {
	        				xroadInstances.refreshXroadInstances(data);
	        			},
	        			error: function(xhr, err, errorText) {
	        				if (window.console) {
	        					window.xhr = xhr; // for debugging after error ocurred
	        					console.log(xhr, err, errorText);
	        				}
	        				alert(jQuery("#error-sending-request").text()
	        						+ " " + errorText);
	        			},
	        			complete: function() {
	        				jqButton.removeClass("running");
	        				jqLoader.hide();
	        			}
	        		});
	        	}
	        	
	        	return false;
	        });
	        jQuery("#service-xroad-instances-restorer").click(function(event){
	        	event.preventDefault();
	        	xroadInstances.refreshXroadInstances(
	        			xroadInstances.serviceXroadInstances.getDefaultCodesAsText());
	        });
	    });
	</script>
</head>

<!-- HTML-fragment for service X-Road instances in admin interface -->
<li class="xroad-v6<s:if test='!portal.v6'> hidden</s:if>">
    <s:label key="portal.label.xroad_instance" />
    <span class="bookmark"></span>
    <select name="portal.clientXroadInstance" id="portalXroadInstance" class="styled">
    	<s:iterator value="serviceXroadInstances" var="xroadInstance">
        	<option value="<s:property value="#xroadInstance.code"/>" <s:if test='portal.clientXroadInstance.equals(#xroadInstance.code)'> selected="selected"</s:if>><s:property value="#xroadInstance.code"/></option>
    	</s:iterator>
    	<s:if test="serviceXroadInstances == null || serviceXroadInstances.size() == 0">
    		<option selected="selected" value=""><s:text
							name="portal.error.service_xroad_instances_missing" /></option>
    	</s:if>
    </select>
    <s:fielderror fieldName="portal.clientXroadInstance" />
</li>
<li class="xroad-v6<s:if test='!portal.v6'> hidden</s:if>">
	<span id="error-sending-request" class="hidden"><s:text name="error.dataexchange.UNSPECIFIED" /></span>
	<span id="default-xroad-instances" class="hidden"><s:property 
		value="@ee.aktors.misp2.util.xroad.XRoadInstanceUtil@getDefaultInstancesAsJson()" /></span>
	<s:label key="portal.label.service_xroad_instances" style="vertical-align:top;" />
	<s:fielderror fieldName="serviceXroadInstances" />
	<div id="service-xroad-instances-container">
		<table class="list selection" id="service-xroad-instances">
			<tr>
				<th><s:text name="portal.th.xroad_instance_code" /></th>
				<th><s:text name="portal.th.xroad_instance_in_use" /></th>
			</tr>
			<s:if test="serviceXroadInstances.size > 0">
				<s:iterator status="stat"
					value="(#attr['serviceXroadInstances'].size()).{ #this }">
					<s:set var="serviceXroadInstance"
						value="#attr['serviceXroadInstances'].get(#stat.index)" />
					<tr>
						<td>
							<span>
								<s:property value="#serviceXroadInstance.code" />
							</span>
							<s:hidden
								name="serviceXroadInstances[%{#stat.index}].code"
								value="%{#serviceXroadInstance.code}" />
						</td>
						<td>
							<input type="checkbox" class="styled"
								name="serviceXroadInstances[<s:property value="#stat.index"/>].inUse"
								value="true"
								<s:if test="#serviceXroadInstance.inUse">checked="checked"</s:if> >
						</td>
					</tr>
				</s:iterator>
			</s:if>
			<s:else>
				<tr>
					<td colspan="2" class="center_middle"><s:text
							name="portal.error.service_xroad_instances_missing" /></td>
				</tr>
			</s:else>
		</table>
	</div>
</li>
<li class="xroad-v6<s:if test='!portal.v6'> hidden</s:if>">
	<label></label>
	<div style="display:inline;" class="xroad-v6<s:if test='!portal.v6'> hidden</s:if>">
		<s:a cssClass="button regular_btn" id="service-xroad-instances-retriever">
			<s:text name="portal.button.get_xroad_instances_from_sec_server" />
		</s:a>
		<s:a cssClass="button regular_btn" id="service-xroad-instances-restorer">
			<s:text name="portal.button.get_default_xroad_instances" />
		</s:a>
		<img src="<s:url value='/resources/%{subPortal}/images/loading.gif' encode='false'/>"
					alt="Loading..." id="service-xroad-instances-loading" />
	</div>
</li>

