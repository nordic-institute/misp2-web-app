<%@ taglib prefix="s" uri="/struts-tags" %>
<%@page  pageEncoding="UTF-8" %>
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

<script type="text/javascript">
    $(document).ready(function() {
        var contentBox = $("#serviceDesc")
        var contentDiv = $("#serviceDescDiv")
		
        $(".vtip").each(function(){
			var title = $(this).attr("title");
			var id = $(this).attr("id");
			var note = $("#"+id+"_note");
			if(note.val() == '') {
				$(this).unbind();
			} else {
				$(this).attr("title", note.val());
			}
			
		});
    })
</script>
<div class="contentbox search">
 
    <s:form theme="simple" action="searchQueries" method="get" id="main-search" >
        <s:hidden value="%{getText('menu.no_description')}" id="queryNoteEmpty"/>
        <fieldset>
            <s:label key="menu.search_criteria"/>
            <s:textfield name="searchCriteria" />
            <s:submit cssClass="button regular_btn" key="label.button.search" name="se"/>
            <s:if test="querySearchResults!=null">
                <s:a cssClass="button secondary" action="login_user"><s:text name="services.search.show_all"/></s:a>
            </s:if>
        </fieldset>
    </s:form>
    <s:if test="querySearchResults!=null">  
        <hr/>
        <s:url var="login" action="login_user"/>
		<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toMain')}"  href="%{login}"><s:text name="help.back.label"/></s:a>
		
        <h3><s:text name="queries.filter.found"/></h3>
        <s:if test="querySearchResults.size > 0">
            <table class="list selection">
                <tr>
                    <th><s:text name="services.show.list.description"/></th>
                    <th><s:text name="services.show.list.producer"/></th>
                    <s:if test="false">
                        <th><s:text name="services.show.list.topic"/></th>
                    </s:if>
                </tr>
                <s:iterator value="querySearchResults" var="res">
                    <tr>
                        <td>
                            <s:url var="runXforms" action="xforms-query">
                                <s:param name="id" value="#res.id"/>
                            </s:url>
                            <s:a href="%{runXforms}" id="query_%{#res.id}" cssClass="vtip">
                            	<s:property value="#res.getActiveName(locale.language).description"/>
                               	<s:hidden value="%{#res.getActiveName(locale.language).queryNote}" id="query_%{#res.id}_note" theme="simple"/>
                                (<s:property value="#res.name"/>)
                            </s:a>
                        </td>
                        <td class="inactive">
                            <span>
                            	<s:property value="#res.producer.getActiveName(locale.language).description"/>
                            	(<s:property value="#res.producer.xroadIdentifier"/>)
                            </span>
                        </td>
                    </tr>
                </s:iterator>
            </table>
        </s:if>
        <s:else>
            <h5><s:text name="text.search.no_results"/></h5>
        </s:else>
    </s:if>
</div>

<s:if test="producers!=null && producers.size > 0 && queries.size > 0"> <!-- show simple queries combined by producers -->
	<s:iterator value="producers" var="ps" status="rowstatus">
    	<div class="contentbox">
			<h3 class="toggle" id="toggle_prod_<s:property value='#ps.id'/>">                     
				<a href="#" onclick="return false"> 	     
					<s:property value="#ps.getActiveName(locale.language).description"/>
					<s:if test="%{#ps.portal.v6 && #ps.subsystemCode != null}">
					 	(<i><s:property value="#ps.subsystemCode"/></i>)
					</s:if>
              	</a>
              </h3>
              <div class="togglewrap" id="tw_prod_<s:property value='#ps.id'/>">
                  <ul>
                     <s:iterator value="queries" var="qs">
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
                               			(<s:property value="#qs.getFullIdentifier()"/>)
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
</s:if>

<s:if test="packages.size==0 && producers.size==0">
    <div class="contentbox warning">
        <h3><s:text name="services.no"/></h3>
    </div>
</s:if>

<s:elseif test="queryTopics!=null">
    <s:if test="queryTopics.size>0">
        <s:iterator value="queryTopics" var="topc" status="rowstatus">
            <div class="contentbox"> 
            	<s:iterator value="topicNames" var="tpcName">    
            		<s:if test="#tpcName.topic.id==key.id">  
	                <h3 class="toggle" id="toggle_topic_<s:property value='#tpcName.topic.id'/>">
	                    	<a href="#" onclick="return false"><s:property value="#tpcName.description"/></a>
	                </h3>
	                </s:if>
                </s:iterator>
                <div id="tw_topic_<s:property value='#topc.key.id'/>" class="togglewrap slvzr-last-child" >
                    <ul>
                        <s:iterator value="value" var="qs">
                            <s:url var="runXforms" action="xforms-query">
                                <s:param name="id" value="#qs.id"/>
                            </s:url>
                            <li>
                                <s:a href="%{runXforms}" id="query_%{#qs.id}" cssClass="vtip">
                                	<s:if test="#qs.getActiveName(locale.language)!=null">
                                		<s:property value="#qs.getActiveName(locale.language).description"/>
                                	</s:if>    
                               	    <s:else>
                               	    	<s:text name="menu.no_description"/>
                               	    </s:else>
                               		<s:if test="%{config.getProperty('ui.show_query_shortname')}">
                               			(<s:property value="#qs.getFullIdentifier()"/>)
                               		</s:if>
                               		<s:hidden value="%{#qs.getActiveName(locale.language).queryNote}" id="query_%{#qs.id}_note" theme="simple"/>
                                </s:a>
                            </li>
                        </s:iterator>
                    </ul>
                </div>
            </div>
        </s:iterator>
    </s:if>
    <s:else>
        <div class="contentbox warning">
            <h3><s:text name="services.no"/></h3>
        </div>
    </s:else>
</s:elseif>
<s:elseif test="tabGroupings!=null "> <!-- show simple queries combined by producers -->
    <jsp:include page='tabGroupings.jsp' />
    
</s:elseif>

