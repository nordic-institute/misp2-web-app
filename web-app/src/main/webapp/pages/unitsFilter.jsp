<%@page pageEncoding="UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags"%>

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

<s:url action="addUnit" var="newUrl" escapeAmp="false"/>
<script type="text/javascript">
    $(document).ready(function() {
        $("#btnNew").click(function() {
            document.location = '<s:property escapeHtml="false" value="newUrl"/>'
        })
    })

</script>

<div class="contentbox">
    <h3><s:text name="units.filter.condition"/></h3>
    <s:form id="unitsFilter" action="unitsFilter" method="get" theme="simple">
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="units.filter.label.name"/>
                    <s:fielderror fieldName="filterName"/>
                    <s:textfield name="filterName"/>
                </li>
                <s:if test="portal.v6">
                	<li>
                    	<s:label key="org.label.xroad_member_class" />
                    	<select name="filterPartyClass" id="filterPartyClass" class="styled">
                    		<option value=""> - </option>
	                    	<s:iterator value="@ee.aktors.misp2.util.xroad.XRoadUtil@getMemberClasses()" var="partyClass">
	                        	<option value="<s:property value="#partyClass"/>" <s:if test='filterPartyClass.equals(#partyClass)'> selected="selected"</s:if>><s:property value="#partyClass"/></option>
	                        </s:iterator>
	                    </select>
	                    <s:fielderror fieldName="filterPartyClass"/>
                	</li>
                </s:if>
                <li>
                    <s:label key="units.filter.label.code"/>
                    <s:fielderror fieldName="filterCode"/>
                    <s:textfield name="filterCode"/>
                </li>
                <li>
                    <s:submit name="submit" key="label.button.search" cssClass="button regular_btn"/>
                </li>
            </ul>
        </fieldset>
    </s:form>
    <hr />
    <s:if  test="searchResults!=null">
        <h3><s:text name="units.filter.found" />:</h3>
        <s:if test="searchResults.size > 0">
            <table class="list selection">
                <s:iterator value="searchResults" var="res">
                    <tr>
                        <td>
                            <s:url var="show_unit_link" action="showUnit">
                                <s:param name="unitId" value="#res.id"/>
                            </s:url>
                            <s:a href="%{show_unit_link}">
                                <s:property value="%{#res.getActiveName(locale.language)}"/>
                                (<s:property value="%{portal.v6 ? #res.memberClass + ':' + #res.code : #res.code}"/>)
                            </s:a>
                        </td>
                    </tr>
                </s:iterator>
            </table>
        </s:if>
        <s:else>
            <h5><s:text name="text.search.no_results"/></h5>
        </s:else>
    </s:if>
    <s:a id="btnNew" cssClass="button regular_btn" href="#" ><s:text name="label.button.add_new_unit"/></s:a>
</div>
