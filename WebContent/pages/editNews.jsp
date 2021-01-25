<%@page pageEncoding="UTF-8"%>
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

<s:url action="deleteNews" var="delUrl" escapeAmp="false">
    <s:param name="newsId" value="%{newsId}"/>
</s:url>

<div class="content">

	<table class="list selection">
        <s:iterator value="newsList" var="listOfNews">
            <tr>
                <td>
                    <s:date name="#listOfNews.created" format="dd.MM.yyyy"/>
                    <s:url var="change_news" action="editNews">
                        <s:param name="newsId" value="#listOfNews.id"/>
                    </s:url>
                    <s:a href="%{change_news}">
                    	<s:if test="(#listOfNews.news).length() > 50">
                    		<s:property value="(#listOfNews.news).substring(0, 50)"/> ...
                    	</s:if>
                    	<s:else>
                    		<s:property value="(#listOfNews.news)"/>
                    	</s:else>
                    </s:a>
                </td>
            </tr>
        </s:iterator>
    </table>
	
	<s:form action="saveNews" theme="simple">
		<fieldset>
		  	<ul class="form">
				<s:hidden name="news.id" />
				<li>
					<h5><s:label key="news.edit.news"/></h5>
				</li>
				<li>
					<s:textarea name="news.news" value="%{news.news}" cols="80" rows="16" /> 
					<s:fielderror fieldName="news.news" />
				</li>
				<li>
					<s:submit key="label.button.save" cssClass="button regular_btn" name="btnSubmit" id="btnSubmit" />
					<s:if test="newsId!=null">
				        <s:a id="btnDel" name="btnDelete" href="%{delUrl}" data-confirmable-post-link="%{getText('text.confirm.delete')}" cssClass="button delete_btn">
				        	<s:text name="label.button.delete"/>
				        </s:a>
					</s:if>
				</li>
			</ul>
		</fieldset>
	</s:form>
</div>



