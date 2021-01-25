<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="s" uri="/struts-tags"%>


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

<style type="text/css">
    .contentbox form label {
        width: 230px
    }
</style>
<s:if test="%{config.getProperty('auth.certificate')}">

	<s:if test="%{browser=='Microsoft Internet Explorer'}">
	    <object style="display:none" id="objCertEnrollClassFactory" classid="clsid:884e2049-217d-11da-b2a4-000e7bbb2b09"></object>
	    <script type="text/javascript" src="resources/jscript/crosskeygen.js"></script>
	</s:if>

	<div class="contentbox">
	    <h3><s:text name="text.label.cert.welcome"/></h3>
    	<s:if test="certificate==null">
	        <s:form action="certGenerate" method="post" id="generateForm" theme="simple">
	            <ul class="form">
	                <li>
	                    <s:label key="text.label.cert.common_name"/>
	                    <s:textfield name="commonName" id="cn"/>
	                    <s:fielderror name="commonName"/>
	                </li>
	
	                <s:if test="%{browser=='Microsoft Internet Explorer'}">
	                    <s:hidden name="csrData" id="csrData"/>
	
	                    <script type="text/javascript">
	                        $(document).ready(function(){
	                            $("#btnSubmit").click(function() {
	                            	
	                                var csr = createCsr(document.getElementById("objCertEnrollClassFactory"))
	                                $("#csrData").val(csr)
	                                $("#generateForm").submit()
	                            })
	                        })
	                    </script>
	                    <li>
	
	                        <%--<s:select name="keylength" cssClass="styled" id="keylength"
	                                  list="#{1024:'1024 (Medium Grade)',2048:'2048 (High Grade)'}"/>--%>
	                    </li>
	                    <li>
	                        <s:a cssClass="button regular_btn" id="btnSubmit" href="#" cssStyle="margin-top:11px">
	                            <s:text name="label.button.cert.generate"/>
	                        </s:a>
	                    </li>
	                </s:if>
	                <s:else>
	                    <li>
	                    	<keygen name="spkac" lang="%{getLocale()}" xml:lang="%{getLocale()}" class="selectForms" style="display: none"/>
	                    </li>
	                    <li>
	                        <s:submit id="btnSubmit" key="label.button.cert.generate" name="genCert" cssClass="button regular_btn" cssStyle="margin-top:11px"/>
	                    </li>
	                </s:else>
	            </ul>
	        </s:form>	    
	    </s:if>
	    <s:else>
	        <script type="text/javascript">
	            $(document).ready(function() {
	                $("#loadCert").click(function() {
	                    if(!!(navigator.userAgent.match(/Trident/) && !navigator.userAgent.match(/MSIE/))) {// IE detection check from http://stackoverflow.com/a/17447374
	                        var cert = $("#certificate").val()
	                        var enrollObj = createCsrCertEnroll(document.getElementById("objCertEnrollClassFactory"))
	                        try {
	                            enrollObj.InstallResponse(4, cert,1, "");
	                            alert("<s:text name="certificate.load.success"/>");
	                        } catch (e1) {
	                            alert("<s:text name="certificate.generate.fail"/>")
	                            try {
	                                enrollObj.InstallResponse(0,cert, 1, "");
	                                alert("<s:text name="certificate.load.success"/>");
	                            } catch (e2) {
	                                alert("<s:text name="certificate.load.fail.leq_vista_sp1"/>")
	                            }
	                        }
	                    } else {
	                        $("#certload").submit()
	                    }
	                })
	            })
	        </script>
	        <s:form action="certLoad" id="certload" method="get" theme="simple">
	            <ul class="form">
	                <s:hidden name="certificate" id="certificate"/>
	                <li>
	                    <s:a id="loadCert" cssClass="button regular_btn" name="load_cert" href="#">
	                        <s:text name="label.button.cert.load"/>
	                    </s:a>
	                </li>
	            </ul>
	        </s:form>
	 	</s:else>
	</div>
</s:if>