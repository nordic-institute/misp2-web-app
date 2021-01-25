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

<div class="contentbox">
    <h3><s:text name="xslt_styles.filter.condition"/></h3>

    <s:form id="stylesFilter" action="stylesFilter" method="get" theme="simple">
        <fieldset>
            <ul class="form">
                <li>
                    <s:label key="xslt_styles.filter.label.xslt_name"/>
                    <s:textfield name="filterName"/>
                </li>
                <li>
                    <s:label key="xslt_styles.filter.label.producer"/>
                    <s:textfield name="filterProducer"/>
                </li>
                <li>
                    <s:label key="xslt_styles.filter.label.query"/>
                    <s:textfield name="filterQuery"/>
                </li>
                <li>
                    <s:submit cssClass="button regular_btn" name="btnSearch" key="label.button.search"/>
                </li>
            </ul>
        </fieldset>
    </s:form>
    <s:if  test="searchResults!=null">
        <hr />
        <h3><s:text name="xslt_styles.filter.found"/></h3>
        <s:if test="searchResults.size > 0">

            <table class="list selection">
                <thead>
                    <tr>
                        <th><s:text name="xslt_styles.show.label.xslt_name"/></th>
                        <th><s:text name="xslt_styles.show.label.producer"/></th>
                        <th><s:text name="xslt_styles.show.label.query"/></th>
                        <th><s:text name="xslt_styles.show.label.in_use"/></th>
                    </tr>
                </thead>
                <tbody>
                    <s:iterator value="searchResults" var="res">
                        <tr>
                            <s:if test="#res.portal==null && !#session.AUTH_METHOD.admin">
                                <td class="inactive">
                                    <span><s:property value="#res.name"/></span>
                                </td>
                            </s:if>
                            <s:else>
                                <td>
                                    <s:url var="show_style_link" action="showStyle">
                                        <s:param name="styleId" value="#res.id"/>
                                    </s:url>
                                    <s:a href="%{show_style_link}"><s:property value="#res.name"/></s:a>
                                </td>                            
                            </s:else>
                            <td class="inactive">
                                <span>
                                    <s:if test="#res.producerId!=null">
                                        <s:property value="%{producerNames[#res.producerId]}"/>
                                    </s:if>
                                    <s:else>
                                        <s:text name="xslt_styles.show.default.producer"/>
                                    </s:else>
                                </span>
                            </td>
                            <td class="inactive">
                                <span>
                                    <s:if test="#res.queryId!=null">
                                        <s:property value="%{#res.queryId.name}"/>
                                    </s:if>
                                    <s:else>
                                        <s:text name="xslt_styles.show.default.query"/>
                                    </s:else>
                                </span>
                            </td>
                            <td class="inactive center_middle">
                                <span>
                                    <s:if test="#res.inUse">
                                        <img src="<s:url value='/resources/%{subPortal}/images/accept.png'/>" alt="<s:text name="label.button.query_rights"/>" width="15" height="15"/>
                                    </s:if>
                                </span>
                            </td>
                        </tr>
                    </s:iterator>
                </tbody>
                <s:if test="%{(itemCount/pageSize)>0}">
                    <tfoot>
                        <tr>
                            <td class="inactive" colspan="4" style="text-align: center">                 
                                <s:if test="pageNumber>1">
                                    <s:a action="stylesFilter" includeParams="all">
                                        <s:param name="pageNumber" value="%{pageNumber-1}"/>
                                        <img src="<s:url value='/resources/%{subPortal}/images/arrow-left-single.png'/>"  alt="" />
                                    </s:a>
                                </s:if>
                                <s:property value="%{pageNumber}"/>...<s:property value="%{(itemCount/pageSize)+1}"/>
                                <s:if test="searchResults.size>=pageSize">
                                    <s:a action="stylesFilter" includeParams="all">
                                        <s:param name="pageNumber" value="%{pageNumber+1}"/>
                                        <img src="<s:url value='/resources/%{subPortal}/images/arrow-right-single.png'/>"  alt="" />
                                    </s:a>
                                </s:if>
                            </td>
                        </tr>
                    </tfoot>
                </s:if>
            </table>
        </s:if>
        <s:else>
            <h5><s:text name="text.search.no_results"/></h5>
        </s:else>
    </s:if>
    <s:a action="addStyle" id="btnNew" cssClass="button regular_btn"><s:text name="label.button.add_new_xsl"/></s:a>
</div>


