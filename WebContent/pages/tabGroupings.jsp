<%@ taglib prefix="s" uri="/struts-tags"%>
<%@ page language="java" contentType="text/html; " pageEncoding="UTF-8"%>
<%--
  ~ The MIT License
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

<%-- This file includes tabs corresponding to topics. Each tab has list of producers with query links. --%>
<s:if test="tabGroupings.size > 0">
    	<style>
    	    .tab-groupings {
    	        margin-top: 12px;
    	    }
    		.tab-grouping-menu {
    			text-align: justify;
    			position: relative;
    			box-sizing : border-box;
    			overflow: hidden;
    		}
    		.tab-grouping-menu .spacer{
    			display: inline-block;
    			background: none;
				box-sizing: border-box;
    			margin-left: -6px; /* enables justify-alignment to align on one line */
    			padding-left: 6px;
    		}
    		
    	    .tab-grouping-menu-item {
    	    	line-height: 37px;
    	    	text-align: center;
    	    	padding: 5px;
    	    	margin: 0;
    			display: inline-block;
    			width: 100%;
    			box-sizing : border-box;
    	    }
    	    
            .tab-grouping-menu:after {
			  content: '';
			  width: 100%; /* Ensures there are at least 2 lines of text, so justification works */
			  display: inline-block;
			}
    	    
    	    .tab-grouping-menu-item img {
    	    	height: 32px;
    	    	display: inline-block;
    	    	vertical-align: middle;
    	    	padding-right: 8px;
    	    }
    	    .tab-grouping-menu-item span {
    	    	display: inline-block;
    	    	vertical-align: middle;
    	    }
    	
	    	.tab-grouping-menu-item:hover {
	    		cursor: pointer;
	    	}
    		.tab-grouping-item:not(.active) {
    			display: none;
    		}
    	    
    	    .tab-grouping-menu-item {
    			border-radius: 5px;
    			font-size: 18px;
    		}
    		.tab-grouping-menu-item:not(.active) {
    			color: #777;	
    			background: linear-gradient(to bottom, #ddd 0%, #c9c9c9 20%, #ccc 33%, #ddd 100%);
    			border: solid #aaa 1px;
    		}
    		.tab-grouping-menu-item.active {
    			color: #5eb3ce;
    			background: linear-gradient(to bottom, rgba(233,233,233,1) 0%, rgba(242,242,242,1) 20%, rgba(255,255,255,1) 33%, rgba(252,252,252,1) 100%);
    			border: solid #e84 1px;
    		}
    	</style>
    	<script>
    		$(document).ready(function() {
    			function setMenuItem (menuItem) {
    				var jqClickedMenuItem = $(menuItem);
    				var jqTabGroupingItem = $("#" + jqClickedMenuItem.attr("id").replace("-menu", ""));
    				jqClickedMenuItem.closest(".tab-groupings").find(".tab-grouping-menu-item.active, .tab-grouping-item.active").removeClass("active");

    				if (jqClickedMenuItem.length == 0) {
        				jqClickedMenuItem = jqClickedMenuItem.closest(".tab-grouping-menu-item");
    				}
    				jqClickedMenuItem.addClass("active");
    				
    				jqClickedMenuItem.closest(".tab-groupings").find(".tab-grouping-item").removeClass("active");
    				jqTabGroupingItem.addClass("active");
    				
    				$.cookie('open-topic-tab', jqClickedMenuItem.attr("id"));
    			};
    			// First try to read open tab from cookie
    			var menuItem = $(".tab-grouping-menu #" + $.cookie('open-topic-tab'));
    			// If open tab is not found from cookie, select first active or existing tab.
    			if (menuItem.length == 0) {
    			    menuItem = $(".tab-grouping-menu-item.active, .tab-grouping-menu-item")[0];
    			}
    			// Open tab and save it to cookie.
    			setMenuItem(menuItem);
    			// Add tab click listener.
    			$(".tab-grouping-menu .tab-grouping-menu-item").click(function() {setMenuItem (this);});
    		});
    	</script>
    	<div class="tab-groupings">
			<%-- Tab menu --%>
	    	<div class="tab-grouping-menu">
		        <s:iterator value="tabGroupings" var="tg" status="rowstatus">
		            <div class="spacer" style="width: <s:property value="%{100./tabGroupings.size + ''}"/>%;">
			        	<div id="tab-grouping-menu-item-<s:property value="%{#tg.id}"/>" class="tab-grouping-menu-item <s:if test="#rowstatus.first"> active</s:if>">
			        		<img src="<s:url value='%{#tg.imagePath}' encode='false'/>" alt="" onerror="this.parentNode.removeChild(this);"/>
			       	    	<span><s:property value="#tg.label" /></span>
			     	    </div>
		     	    </div>
		        </s:iterator>
	        </div>
    
			<%-- Content of tabs --%>
	        <s:iterator value="tabGroupings" var="tg" status="rowstatus">
	        	<div id="tab-grouping-item-<s:property value="%{#tg.id}"/>" class="tab-grouping-item <%--<s:if test="#rowstatus.first"> active</s:if> --%>">
			        <s:iterator value="#tg.producers" var="ps" status="rowstatus">
				    	<div class="contentbox" >
							<h3 class="toggle" id="toggle_prod_<s:property value='#ps.id'/>">                     
								<a href="#" onclick="return false"> 	     
									<s:property value="#ps.getActiveName(locale.language).description"/>
									<s:if test="%{#ps.portal.v6 && #ps.subsystemCode != null}">
									 	<i>(<s:property value="#ps.subsystemCode"/>)</i>
									</s:if>
				              	</a>
				              </h3>
				              <div class="togglewrap" id="tw_prod_<s:property value='#ps.id'/>">
				                  <ul>
				                     <s:iterator value="#tg.queries" var="qs">
				                         <s:if test="#ps.id==producer.id">
				                             <s:url var="runXforms" action="xforms-query">
				                                 <s:param name="id" value="id"/>
				                             </s:url>
				                             <li>
				                                 <s:a href="%{runXforms}" id="query_%{id}" cssClass="vtip" title="">
				                                    
				                                    <s:if test="#qs.getActiveName(locale.language)!=null">
				                                		<s:property value="#qs.getActiveName(locale.language).description"/>
				                                	</s:if>    
				                               	    <s:else>
				                               	    	<s:text name="menu.no_description"/>
				                               	    </s:else>
				                               		<s:if test="%{config.getProperty('ui.show_query_shortname')}">
				                               			<i>(<s:property value="#qs.getFullIdentifier()"/>)</i>
				                               		</s:if>
				                                     <s:hidden value="%{getActiveName(locale.language).queryNote}" id="query_%{id}_note" theme="simple"/>
				                                 </s:a>
				                             </li>
				                         </s:if>
				                     </s:iterator>
				                  </ul>
				              </div>
				    	</div>
					</s:iterator>
				</div>
			</s:iterator>
		</div>
    </s:if>
    <s:else>
        <div class="contentbox warning">
            <h3><s:text name="services.no"/></h3>
        </div>
    </s:else>