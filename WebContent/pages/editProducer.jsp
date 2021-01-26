<%@ taglib prefix="s" uri="/struts-tags"%>
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


<s:url action="producerDelete" var="delUrl" escapeAmp="false">
	<s:param name="id" value="%{producer.id}"/>
	<s:param name="protocol" value="%{protocol}"/>
</s:url>

<s:if test="portal.debug==1">
	<div class="contentbox">
		<s:url var="listProducers" action="listProducers?protocol=%{protocol}"/>
		<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toListProducers')}"  href="%{listProducers}"><s:text name="help.back.label"/></s:a>
		<s:form method="post" action="producerSave?protocol=%{protocol}" theme="simple" >
			<ul class="form">
				<s:if test="portal.v5">
					<li>
						<s:label key="producer.edit.name" />
						<s:textfield required="true" name="producer.shortName" placeholder="%{getText('placeholder.producer_name')}" />
						<s:fielderror fieldName="producer.shortName" />
					</li>
				</s:if>
				<s:if test="portal.v6">

					<li>
						<s:label key="org.label.xroad_protocol" />
						<s:property value="protocol"/>
					</li>
                    <li>
                        <s:label key="org.label.xroad_instance" />
                        <select name="activeInstanceCode" id="activeInstanceCode" class="styled">
                            <s:iterator value="%{activeInstanceCodes}" var="code">
                                <option value="<s:property value="#code"/>" <s:if test='activeInstanceCode.equals(#code)'> selected="selected"</s:if>><s:property value="#code"/></option>
                            </s:iterator>

                        </select>
                    </li>
					<li>
	                    <s:label key="org.label.xroad_member_class" />
	                    <select name="producer.memberClass" id="producerMemberClass" class="styled">
	                    	<s:iterator value="@ee.aktors.misp2.util.xroad.XRoadUtil@getMemberClasses()" var="memberClass">
	                        	<option value="<s:property value="#memberClass"/>" <s:if test='producer.memberClass.equals(#memberClass)'> selected="selected"</s:if>><s:property value="#memberClass"/></option>
	                        </s:iterator>
	                    </select>
	                    <s:fielderror fieldName="producer.memberClass" />
	                </li>
	                <li>
						<s:label key="producer.label.xroad_member_code" />
	                    <s:textfield required="true" name="producer.shortName" placeholder="%{getText('placeholder.portal.org_code')}"/>
	                    <s:fielderror fieldName="producer.shortName" />
	                </li>
	    			<li>
	                    <s:label key="org.label.xroad_subsystem_code" />
	                    <s:textfield name="producer.subsystemCode"/>
	                    <s:fielderror fieldName="producer.subsystemCode"/>
	                </li>
				</s:if>

				<s:if test="producer != null">
					<s:hidden name="producer.id"/>
					<s:iterator status="stat" value="producer.producerNameList" var="pName">
						<li>
							<label><s:property value="getText('producer.edit.description')+' ('+#pName.lang.toUpperCase()+')'"/></label>
							<s:textfield required="true" name="producer.producerNameList[%{#stat.index}].description" cssClass="long_url" placeholder="%{getText('placeholder.producer_description')}"/>
							<s:hidden name="producer.producerNameList[%{#stat.index}].id"/>
							<s:hidden name="producer.producerNameList[%{#stat.index}].lang"/>
							<s:fielderror>
								<s:param><s:property value="'producerNames['+#stat.index+'].description'"/></s:param>
							</s:fielderror>
						</li>
					</s:iterator>
				</s:if>
				<s:else>
					<s:iterator status="stat" value="(#attr['languages'].size()).{ #this }" >
						<li>
							<s:set var="language" value = "#attr['languages'].get(#stat.index)"/>
							<label><s:property value="getText('producer.edit.description')+' ('+#language.toUpperCase()+')'"/></label>
							<s:textfield required="true" name="producerNames[%{#stat.index}].description" cssClass="long_url" placeholder="%{getText('placeholder.producer_description')}"/>
							<s:hidden name="producerNames[%{#stat.index}].id"/>
							<s:fielderror>
								 <s:param><s:property value="'producerNames['+#stat.index+'].description'"/></s:param>
							</s:fielderror>
						</li>
					</s:iterator>
				</s:else>

			</ul>

	        <s:submit name="btnSubmit" key="label.button.save" cssClass="button regular_btn"/>

			<s:if test="producer != null">
				<s:a id="btnDel" name="btnDelete" href="%{delUrl}" data-confirmable-post-link="%{getText('text.confirm.delete')}" cssClass="button delete_btn">
					<s:text name="label.button.delete"/>
				</s:a>
			</s:if>
		</s:form>
	</div>
</s:if>