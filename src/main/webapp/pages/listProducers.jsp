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

<s:if test="protocol == null">
    <s:set var="pageProtocol" value="%{@ee.aktors.misp2.model.Producer$ProtocolType@SOAP}"/>
</s:if>
<s:else>
    <s:set var="pageProtocol" value="%{protocol}"/>
</s:else>


<s:url action="producerDelete" var="delUrl" escapeAmp="false">
	<s:param name="id" value="%{producer.id}"/>
	<s:param name="protocol" value="%{pageProtocol}"/>
</s:url>
<head>
	<style type="text/css">
		#content .button-group {
			display: inline-block;
			margin-right: 13px;
			margin-bottom: 0;
		}
		.button {
			line-height: 1.5em;
		}
		/* Fix for  Complex services table gets out of the frame.*/
		table.producers {
			display: table-cell;
		}
		table.producers a {
			width: 100%;
		}
		.contentbox #complex_producers {
			position: relative;
			padding-left: 50px;
		}
	</style>
</head>
<s:set var="lang" value="locale.language"/>
<div class="contentbox">

	<table class="list selection producers">
		<tr>
			<th><s:text name="services.show.list.producer"/></th>
			<th><s:text name="services.show.list.description"/></th>
			<s:if test="%{protocol == @ee.aktors.misp2.model.Producer$ProtocolType@REST}">
				<th></th>
			</s:if>
		</tr>



		<s:if test="activeProducers.size > 0">
			<s:iterator value="activeProducers" var="prods">
				<tr>
					<td>
						<s:url var="listQueries" action="listQueries">
							<s:param name="id" value="#prods.id"/>
							<s:param name="protocol" value="%{pageProtocol}"/>
						</s:url>
						<s:a href="%{listQueries}" cssStyle="display: block; height: 100%; " title="%{getText('producer.edit.hint_services')}">
							<s:property value="#prods.xroadIdentifier"/>
						</s:a>
					</td>
					<td class="inactive">
						<s:property value="#prods.getActiveName(locale.language).description"/>
					</td>
					<s:if test="%{protocol == @ee.aktors.misp2.model.Producer$ProtocolType@REST}">
						<td class="modify">
							<s:url var="producerEdit" action="producerEdit">
								<s:param name="id" value="%{id}" />
								<s:param name="protocol" value="%{pageProtocol}" />
							</s:url>
							<s:a href="%{producerEdit}" theme="xhtml" cssClass="small" title="%{getText('producer.edit.hint_prod')}">
								<img src="resources/<s:property value="subPortal"/>/images/tools.png" alt="" width="20" height="20"/>
							</s:a>
						</td>
					</s:if>
				</tr>
			</s:iterator>
		</s:if>
		<s:else>
			<tr>
				<td colspan="2" class="center_middle"><s:text name="text.search.no_results"/></td>
			</tr>
		</s:else>
	</table>
	<table id="complex_producers" class="list selection producers">
		<tr>
			<th><s:text name="complex.edit.name"/></th>
			<th><s:property value="getText('complex.edit.description')+' ('+#lang.toUpperCase()+')'"/></th>
			<th></th>
		</tr>
		<s:if test="complexProducers.size > 0">
			<s:iterator value="complexProducers">
				<tr>
					<td>
						<s:url var="cProducerQueries" action="listComplexQueries">
							<s:param name="id" value="%{id}" />
							<s:param name="protocol" value="protocol"/>
						</s:url>
						<s:if test="%{shortName!='system'}"><s:a href="%{cProducerQueries}" title="%{getText('complex.edit.hint_services')}"><s:property value="shortName"/></s:a></s:if>
						<s:else><s:property value="shortName"/></s:else>
					</td>
					<td>
						<s:property value="getActiveName(locale.language).description"/>
					</td>
					<td class="modify">
						<s:url var="cProducerEdit" action="complexProducerEdit">
							<s:param name="id" value="%{id}" />
							<s:param name="protocol" value="protocol"/>
						</s:url>
						<s:a href="%{cProducerEdit}" theme="xhtml" cssClass="small" title="%{getText('complex.edit.hint_prod')}">
							<img src="resources/<s:property value="subPortal"/>/images/tools.png" alt="" width="20" height="20"/>
						</s:a>
					</td>
				</tr>
			</s:iterator>
		</s:if>
		<s:else>
			<tr>
				<td colspan="3" class="center_middle"><s:text name="text.search.no_results"/></td>
			</tr>
		</s:else>
	</table>
</div>
<div class="contentbox">
	<s:if test="!all">
		<s:a action="listAllProducers?protocol=%{pageProtocol}" cssClass="button regular_btn no-margin"><s:text name="label.button.allproducers"/></s:a>
		<s:if test="portal.debug==1">
			<s:a action="producerEdit?protocol=%{pageProtocol}" cssClass="button regular_btn no-margin"><s:text name="label.button.add_producer"/></s:a>
		</s:if>
		<s:a action="complexProducerEdit?protocol=%{pageProtocol}" cssClass="button regular_btn no-margin"><s:text name="label.button.add_complex_producer" /></s:a>
		<s:a action="queriesExport?protocol=%{pageProtocol}" cssClass="button regular_btn no-margin"><s:text name="label.button.queries_export" /></s:a>
		<s:a action="queriesImport?protocol=%{pageProtocol}" cssClass="button regular_btn no-margin"><s:text name="label.button.queries_import" /></s:a>
	</s:if>
	<s:else>
		<s:if test="portal.v6">
			<s:form method="post" theme="simple" action="soapRefreshProducers" cssClass="button-group">
				<s:hidden name="protocol"/>
				<s:if  test="serviceXroadInstances.size == 1">
					<s:set var="serviceXroadInstance"
						   value="#attr['serviceXroadInstances'].get(0)" />
					<div>
						<s:text name="producer.th.xroad_instance" />:
						<b><s:property value="#serviceXroadInstance.code" /></b>
						<s:hidden
								name="serviceXroadInstances[0].code"
								value="%{#serviceXroadInstance.code}" />
						<s:hidden
								name="serviceXroadInstances[0].selected"
								value="true" />
					</div>
				</s:if>
				<s:elseif test="serviceXroadInstances.size > 1">
					<table class="list selection" id="service-xroad-instances">
						<tr>
							<th><s:text name="producer.th.xroad_instance" /></th>
							<th></th>
						</tr>
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
										   name="serviceXroadInstances[<s:property value="#stat.index"/>].selected"
										   value="true"
										   <s:if test="#serviceXroadInstance.selected">checked="checked"</s:if> >
								</td>
							</tr>
						</s:iterator>
					</table>
				</s:elseif>
				<%----%>
				<s:submit name="btnSubmit"
						  key="label.button.refreshproducers"
						  cssClass="button regular_btn"
						  title="%{getText('producer.xrd.listClients')}"/>

			</s:form>
		</s:if>
		<s:else> <%-- X-Road v5 portal --%>
			<s:a action="soapRefreshProducers"
				 data-confirmable-post-link=""
				 cssClass="button regular_btn no-margin"
				 title="%{getText('producer.xrd.listProducers')}">
				<s:text name="label.button.refreshproducers"/>
			</s:a>
		</s:else>
		<s:if test="allProducers.size > 0">
			<s:a id="saveProducerStates-top" href="" cssClass="button regular_btn no-margin" ><s:text name="label.button.save_active_producers"/></s:a>
			<script type="text/javascript">
				$(document).ready(function(){
					/**
					 * Producer object containing ID and name. ID is used for server query, name
					 * is displayed to the user in user prompt.
					 */
					function Producer(id, name) {
						this.id = id;
						this.name = name;
						this.toString = function () {
							return "'" + this.name + "'";
						}
					}
					/**
					 * Find active producers from #listProducersTable. Producer is considered active,
					 * if the checkbox in table first column is checked.
					 */
					function getActiveProducers() {
						var activeProducers = [];
						$("#listProducersTable tr.producer").each(function() {
							var jqTr = $(this);
							var jqCheckbox = jqTr.find("input[type=checkbox]");
							if(jqCheckbox.is(':checked') || jqCheckbox.attr("checked") == "checked") {
								var producerId = jqCheckbox.attr("id");
								var producerName = $.trim(jqTr.find("td:eq(1)").text()).replace(/\s+/g, "");
								var producer = new Producer(
										producerId,
										producerName);
								activeProducers[activeProducers.length] = producer;
							}
						});
						return activeProducers;
					}
					/**
					 * Given old and new producer lists, take those producers from old list
					 * that do not exist in new list: they must have been deleted.
					 */
					function getDeletedProducers(originalActiveProducers, newActiveProducers) {
						var deletedProducers = [];
						for (var i = 0; i < originalActiveProducers.length; i++) {
							var originalActiveProducer = originalActiveProducers[i];
							var found = false;
							for (var j = 0; j < newActiveProducers.length; j++) {
								var newActiveProducer = newActiveProducers[j];
								if (newActiveProducer.id == originalActiveProducer.id) {
									found = true;
									break;
								}
							}
							if (!found) {
								deletedProducers[deletedProducers.length] = originalActiveProducer;
							}
						}
						return deletedProducers;
					}
					/**
					 * Concatenate producer ID-s to string where ID-s are separated by comma.
					 */
					function concatIds(producers) {
						var ids = [];
						for (var i = 0; i < producers.length; i++) {
							var producer = producers[i];
							ids[ids.length] = producer.id;
						}
						return ids.join(",");
					}
					var originalActiveProducers = getActiveProducers();
					$("#saveProducerStates-top, #saveProducerStates-bottom").click(function(event) {

						var newActiveProducers = getActiveProducers();
						var deletedProducers = getDeletedProducers(originalActiveProducers, newActiveProducers);
						// Only display user prompt when at least one producer is being deleted
						if (deletedProducers.length > 0) {
							var deletedProducersStr = deletedProducers.join(", ");
							var confirmMessage = '<s:text name="producer.save_active_producers.confirmMessage"/>';
							// In case only one producer is being deleted, correct error message text to singular form.
							if (deletedProducers.length == 1) {
								confirmMessage = confirmMessage.replace("andmekogud", "andmekogu");
								confirmMessage = confirmMessage.replace("producers", "producer");
							}
							// Add producer names to user prompt message before question mark.
							confirmMessage = confirmMessage.replace(
									"?", " " + deletedProducersStr + "?"
							);
							// If user cancels action, return
							if(confirm(confirmMessage) == false) {
								return;
							}
							// Otherwise continue with producer saving procedure
						}

						var url = '<s:url escapeAmp="false" action="addActiveProducer">'
								+ '<s:param name="activeProducersGroup" value="\'dummyValue\'"/>'
								+ '<s:param name="protocol" value="protocol"/></s:url>';
						url = url.replace("dummyValue", concatIds(newActiveProducers));
						event.preventDefault();
						Utils.postURL(url);
					});
					function getWords(text){
						// split text by whitespace and colons and ., then filter out all empty elements: jQuery.grep
						return jQuery.grep(text.toLowerCase().split(/[\s:\.]+/), function(n){ return(n) });
					}
					function textMatches(searchText, datasetText){
						var searchWords = getWords(searchText);
						var datasetWords = getWords(datasetText);

						for(var i = 0; i < datasetWords.length; i++){
							var success = true;
							for(var j = 0; j < searchWords.length; j++){
								// if there are less dataset words left than search words, then no match
								if(datasetWords.length - i < searchWords.length - j) return false;
								var searchWord = searchWords[j];
								var datasetWord = datasetWords[j + i];
								var hasNextSearchWord = j < searchWords.length - 1;
								if(  hasNextSearchWord && datasetWord != searchWord ||
										!hasNextSearchWord && datasetWord.indexOf(searchWord) != 0) {
									success = false;
									break;
								}
							}
							if(success) return true;
						}
						return false;
					}
					$("#searchCriteria").keyup(function(){
						var val = $(this).val();

						$("#listProducersTable tr.producer").each(function(){
							var jqTr = $(this);
							if(val == ""){
								jqTr.show();
							}
							else{

								if(textMatches(val, jqTr.text())){
									jqTr.show();
								}
								else{
									jqTr.hide();
								}
							}
						})
					});
				});
			</script>
			<div class="contentbox">
				<fieldset class="padded">
					<label for="searchCriteria">
						<s:text name="menu.search_criteria"/>
					</label>
					<s:textfield name="searchCriteria"/>
				</fieldset>
			</div>
			<s:form name="listProducersForm" action="saveProducers">
				<s:hidden name="allProducers" />
				<table class="list" id="listProducersTable">
					<tr>
						<td></td>
						<td>
							<b><s:text name="services.show.list.producer"/></b>
						</td>
						<td>
							<b><s:text name="services.show.list.description"/></b>
						</td>
					</tr>
					<s:iterator value="allProducers" var="prodsXml">
						<tr class="producer">
							<td>
								<input
										type="checkbox" class="styled" id="<s:property value="#prodsXml.id"/>"
										name='active<s:property value="#prodsXml.id"/>'
										value='<s:property value="#prodsXml.shortName"/>'
										<s:if test="#prodsXml.inUse">checked="checked"</s:if>
								/>
							</td>
							<td>
								<s:property value="#prodsXml.xroadIdentifier"/>
							</td>
							<td>
								<s:property value="#prodsXml.getActiveName(locale.language).description"/>
							</td>
						</tr>
					</s:iterator>
				</table>
			</s:form>
			<s:a id="saveProducerStates-bottom" href="#" cssClass="button regular_btn"  cssStyle="margin-top:15px"><s:text name="label.button.save_active_producers"/></s:a>
		</s:if>
	</s:else>
</div>