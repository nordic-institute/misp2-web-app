<%@page  pageEncoding="UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags"%>
<%--
  ~ The MIT License
  ~ Copyright (c) 2020 NIIS
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

<s:head/>

<link rel="stylesheet" type="text/css" href="resources/EE/css/categorized-table.css" />
<script type="text/javascript" src="resources/jscript/categorized-table.js"></script>

<style type="text/css">
    .multipleBtn {
        width: 50px
    }

</style>
<s:url action="topicDelete" var="delUrl" escapeAmp="false">
    <s:param name="topicId" value="%{topicId}"/>
</s:url>

<script type="text/javascript">
    $(document).ready(function( ){        
        $('[id^="checks"]').click(function() {
	    	checkUncheckAll(this.id.substring("checks".length), 'show_topic');
	    });
        
        $('[id^="group_check"]').click(function() {
	    	checkUncheckAll(this.id.substring("group_check".length), 'show_topic');
	    })
    })
</script>

<s:if test="!#session.SESSION_PORTAL.useTopics">
    <div class="contentbox warning">
        <h3><s:text name="topic.warning.not_in_use"/></h3>
    </div>
</s:if>

<div class="contentbox">
<s:url var="listTopics" action="topicsFilter"/>
<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toTopics')}"  href="%{listTopics}"><s:text name="help.back.label"/></s:a>

    <s:form action="topicSubmit" theme="simple" id="show_topic">
        <s:hidden name="topicId"/>
        <fieldset>
            <h3><s:text name="topics.show.general_header"/></h3>
            <ul class="form">
             	<li>
                    <s:label key="topics.show.name"/> 
                    <s:textfield name="topic.name"/>
                    <s:fielderror fieldName="topic.name"/>
                </li>
                
				<s:iterator status="stat" value="(#attr['languages'].size()).{ #this }" >
	                <li>
                		<s:set var="language" value = "#attr['languages'].get(#stat.index)"/>
	                    <label><s:property value="getText('topics.show.desc')+' ('+#language.toUpperCase()+')'"/></label>
	                    <s:textfield name="topicNames[%{#stat.index}].description"/>
	                    <s:hidden name="topicNames[%{#stat.index}].id"/>
						<s:fielderror>
						     <s:param><s:property value="'topicNames['+#stat.index+'].description'"/></s:param>
						</s:fielderror>
	                </li>
				</s:iterator>                
                
                <li>
                    <s:label key="topics.show.priority"/>
                    <s:textfield name="topic.priority" cssClass="numberField" />
                    <s:fielderror fieldName="topic.priority"/>
                </li>
            </ul>
        </fieldset>
        <hr />
        <fieldset>
            <h3><s:text name="topics.show.query_topic_header"/>:</h3>
            
            
            <table class="list selection categorized">
            	<tr>
	                <th>
	                    <s:text name="topics.show.is_connected" />
	                </th>
	                <th>
	                    <s:text name="topics.show.query_description" />
	                </th>
	                <th>
	                    <s:text name="topics.show.query_short_name" />
	                </th>
	            </tr>
	            
                <s:set var="groupCounter" value="1" />
                <s:iterator value="allowedProducersWithQueries" var="producerWithQueries">
                    <s:iterator value="producerWithQueries" var="producer">
                        <tr>
                            <td class="header" colspan="3" id="producerId_<s:property value="#producer.key.id"/>" >
                            	<a>
                                   <s:property value="%{#producer.key.getActiveName(locale.language).description}"/>
									 	(<s:property value="%{#producer.key.getXroadIdentifier()}"/>)

                                </a>
                            </td>
                        </tr>
                            <s:iterator value="%{#producer.value}">
                                <tr class="producerId_<s:property value="#producer.key.id"/>" >
                                    <td class="modify center_middle">
                                        <s:if test="%{groupAllowedQueryIdList.contains(id)}">
                                            <s:set var="is_query_connected" value="true" />
                                        </s:if>
                                        <s:else>
                                            <s:set var="is_query_connected" value="false" />
                                        </s:else>
                                        <s:checkbox id="%{id}_%{#groupCounter}_all" name="groupAllowedQueryIdList" value="%{is_query_connected}" fieldValue="%{id}" cssClass="styled"/>
                                    </td>
                                    <td class="inactive">
                                        <s:iterator value="%{queryNameList}">
                                            <s:if test="%{locale.language.equals(lang)}">
                                                <s:property value="%{description}"/>
                                            </s:if>
                                        </s:iterator>
                                    </td>
                                    <td class="inactive">
                                        <s:property value="%{fullIdentifier}"/>
                                    </td>
                                </tr>
                            </s:iterator>
                        <tr class="producerId_<s:property value="#producer.key.id"/>" >
                            <td class="modify center_middle" id="checktd_allowed">
                                <span id="group_check_<s:property value="%{#groupCounter}"/>_all"><input type="checkbox"  value="checkall_<s:property value="%{#groupCounter}"/>_all" name="checkall_<s:property value="%{#groupCounter}"/>_all" id="checkall_<s:property value="%{#groupCounter}"/>_all" class="styled"/></span>
                            </td>
                            <td class="inactive" colspan="2" style="text-align:left; padding-left:5px;">
                                <strong><s:text name="check.group_all" /></strong>
                            </td>
                        </tr>
                        <s:set var="groupCounter" value="%{#groupCounter + 1}" />
                    </s:iterator>
                </s:iterator>
				<tr>
					<td class="modify center_middle" id="checktd_all">
                        <span id="checks_all">
                        	<input type="checkbox"  value="checkall_all" name="checkall_all" id="checkall_all" class="styled"/>
                        </span>
                    </td>
					<td class="inactive" colspan="2" style="text-align:left; padding-left:5px;">
                        <strong><s:text name="check.all" /></strong>
                    </td>
				</tr>
			</table>
        </fieldset>
        <s:submit key="label.button.save" name="btnSave" id="btnSave" cssClass="button regular_btn"/>
        <s:if test="topicId!=null">
            <s:a id="btnDel" name="btnDelete" href="%{delUrl}" data-confirmable-post-link="%{getText('text.confirm.delete')}" cssClass="button delete_btn">
            	<s:text name="label.button.delete"/>
            </s:a>
        </s:if>

    </s:form>
</div>