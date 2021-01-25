<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page pageEncoding="UTF-8" %>

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

<s:if test="#session.SESSION_USER_ROLE == @ee.aktors.misp2.util.Roles@PORTAL_MANAGER">
    <style>


        #menu {
            width: 1150px;
            max-width: 1150px;
        }
        #menu li {
            margin-right: 1px;
        }
        #user {
            margin-top: 4px;
        }
        @media (max-width: 1280px) {
            #header {
                background-position: -140px;
                min-width: 960px;
                max-width: 1200px;
                width: 1200px;
            }

            #body .container {
                width: 1180px;
                max-width: 1200px;
            }
        }
    </style>
</s:if>

<s:set var="currentActions" value="#roleActions[#session.SESSION_USER_ROLE]"/>
<ul id="menu">
    <s:iterator value="#currentActions" var="menuAction">
        <s:if test="#menuAction.showAction">
            <li>
                <s:a action="%{menuAction}" cssClass="%{#activeMenuItem==menuItem ? 'active' : ''}">
                    <s:text name="%{'menu.item.'+menuItem}"/>
                </s:a>
            </li>
        </s:if>
    </s:iterator>
</ul>