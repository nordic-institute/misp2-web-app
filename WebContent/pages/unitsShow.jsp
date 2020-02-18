<%@page  pageEncoding="UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags"%>

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

<s:url action="unitDelete" var="delUrl" escapeAmp="false">
    <s:param name="unitId" value="%{unitId}"/>
</s:url>

<div class="contentbox" >
<s:url var="listUnits" action="unitsFilter"/>
<s:a cssClass="back back_btn" title="%{getText('help.tooltip.toUnitsList')}"  href="%{listUnits}"><s:text name="help.back.label"/></s:a>

    <s:form action="unitSubmit" theme="simple" id="show_unit">
        <s:hidden name="unitId"/>
        <fieldset>
            <ul class="form">
				<s:iterator status="stat" value="(#attr['languages'].size()).{ #this }" >
	                <li>
                		<s:set var="language" value = "#attr['languages'].get(#stat.index)"/>
	                    <label><s:property value="getText('units.show.name')+' ('+#language.toUpperCase()+')'"/></label>
	                    <s:textfield name="unitNames[%{#stat.index}].description"/>
	                    <s:hidden name="unitNames[%{#stat.index}].id"/>
						<s:fielderror>
						     <s:param><s:property value="'unitNames['+#stat.index+'].description'"/></s:param>
						</s:fielderror>
	                </li>
				</s:iterator>
                
                <s:if test="portal.v6">
                	<li>
                    	<s:label key="org.label.xroad_member_class" />
                    	
                    	<s:if test="unitId==null">
	                    	<select name="unit.memberClass" id="unit.memberClass" class="styled">
		                    	<s:iterator value="@ee.aktors.misp2.util.xroad.XRoadUtil@getMemberClasses()" var="partyClass">
		                        	<option value="<s:property value="#partyClass"/>" <s:if test='unit.memberClass.equals(#partyClass)'> selected="selected"</s:if>><s:property value="#partyClass"/></option>
		                        </s:iterator>
		                    </select>
	                    </s:if>
	                    <s:else>
	                        <span><s:property value="unit.memberClass" /></span>
	                        <s:hidden name="unit.memberClass"/>
	                    </s:else>
	                    
	                    <s:fielderror fieldName="filterPartyClass"/>
                	</li>
                </s:if>
                
                <li>
                    <s:label key="units.show.code"/>
                    <s:if test="unitId==null">
                        <s:textfield name="unit.code" />
                    </s:if>
                    <s:else>
                        <span><s:property value="unit.code" /></span>
                        <s:hidden name="unit.code"/>
                    </s:else>
                    <s:fielderror fieldName="unit.code"/>
                </li>
            </ul>
        </fieldset>
        <s:submit type="button" key="label.button.save" name="btnSave" id="btnSave" cssClass="button regular_btn"/>
        <s:submit type="button" key="units.show.save_and_set" name="btnSaveAndRegister" id="btnSave" cssClass="button regular_btn"/>

        <s:if test="unitId!=null">
            <s:a id="btnDel" name="btnDelete" href="%{delUrl}" data-confirmable-post-link="%{getText('text.confirm.delete')}" cssClass="button delete_btn">
            	<s:text name="label.button.delete"/>
            </s:a>
        </s:if>
    </s:form>
</div>