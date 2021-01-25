<%@ taglib prefix="s" uri="/struts-tags" %>
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

<s:set var="isOpenApi" value="%{protocol == @ee.aktors.misp2.model.Producer$ProtocolType@REST}"/>
<style>
    .inactiveLink {
        pointer-events: none;
        cursor: not-allowed;
    }
    input[type="radio"] {
        vertical-align: middle;
    }
</style>
<script type="text/javascript">
  var isPortalV6 = <s:property value="portal.isV6()"/>;
  var isInDebugMode = <s:property value="portal.debug==1"/>;
  var hasQueries = <s:property value="queries.size > 0"/>;

  function getWsdlSource() {
    return $("input[type=radio][name=wsdlSource]:checked").attr("value");
  }

  $(document).ready(function () {
    var securityHost = '<s:property value="#session.SESSION_PORTAL.securityHost"/>';
    var producer = '<s:property value="producer.shortName"/>';


    $("#generateServicesFormsBtn").on("click", function (e) {
      var Gurl = "";
      if (getWsdlSource() === '<s:property value="@ee.aktors.misp2.action.QueryAction$ServiceDescriptionSource@SERVICE_URLS" />') {
        for (n = 0; n < <s:property value="xformsList.size"/>; n++) {
          if (document.getElementById('updateXforms[' + n + ']').checked == true) {
            Gurl = Gurl + "," + document.getElementById('updateXforms[' + n + ']').value + ',' + document.getElementById('xformsUrl[' + n + ']').value;
          }
        }
      } else {
        for (n = 0; n < <s:property value="xformsList.size"/>; n++) {
          if (document.getElementById('updateXforms[' + n + ']').checked == true) {
            Gurl = Gurl + "," + document.getElementById('updateXforms[' + n + ']').value;
          }
        }
      }

      if (Gurl.substr(1) == "") return !!alert("<s:text name='validation.js.choose_service'/>");

      if (Gurl.charAt(0) === ',') {
        Gurl = Gurl.substr(1);
      }

      $('#form_queries2 > input[name="xformsGroup"]').remove();
      $('<input />')
      .attr('type', 'hidden')
      .attr('name', "xformsGroup")
      .attr('value', Gurl)
      .appendTo('#form_queries2');

      return true;
    });

    $("#form_queries2").on("submit", function (e) {
        Utils.displayLoadingOverlay();
        return true;
       });



    $("#checktd").click(function () {
      checkUncheckAll();
    });
    $("input[type=radio][name=wsdlSource]").on("change", function () {
      updateWsdlSourceOptions();
    });
    updateWsdlSourceOptions();
  });

  function updateWsdlSourceOptions() {
    function setElementEnabledState($el, state) {
      if (!state) {
        $el.addClass("disabled inactiveLink");
        $el.attr('disabled', 'disabled');
      } else {
        $el.removeClass("disabled inactiveLink");
        $el.removeAttr('disabled', 'disabled');
      }

    }

    function setRadioButtonEnabledState(radioButtonValue, state) {
      var $securityServerRadioButton = $("input[type=radio][name=wsdlSource][value=" + radioButtonValue + "]");
      var securityServerButtonId = $securityServerRadioButton.attr("id");
      var $buttonLabel = $("label[for='" + securityServerButtonId +"']");
      setElementEnabledState($securityServerRadioButton, state)
      setElementEnabledState($buttonLabel, state)
    }

    var wsdl_source = getWsdlSource();
    $(".wsdlSourceOptions").addClass("hidden");
    $("#" + wsdl_source).removeClass("hidden");

      let $openapiServiceCodeRow = $("#openapiServiceCodeRow");
      let $openapiServiceCode = $("#openapiServiceCode");
      if('<s:property value="protocol"/>' === '<s:property value="@ee.aktors.misp2.model.Producer$ProtocolType@REST" />'
      && (wsdl_source === '<s:property value="@ee.aktors.misp2.action.QueryAction$ServiceDescriptionSource@WSDL_URL" />'
     || wsdl_source === '<s:property value="@ee.aktors.misp2.action.QueryAction$ServiceDescriptionSource@FILE_UPLOAD" />')) {
        $openapiServiceCodeRow.removeClass("hidden");
        $openapiServiceCode.prop('disabled', false);
    } else {
        $openapiServiceCode.prop('disabled', true);
    }

    var $updateServicesListBtn = $("#updateServicesListBtn");
    if (wsdl_source === '<s:property value="@ee.aktors.misp2.action.QueryAction$ServiceDescriptionSource@SERVICE_URLS" />') {
      setElementEnabledState($updateServicesListBtn, false);
    } else {
      setElementEnabledState($updateServicesListBtn, true);
    }

    var $generateServicesFormsBtn = $("#generateServicesFormsBtn");
    if(wsdl_source === '<s:property value="@ee.aktors.misp2.action.QueryAction$ServiceDescriptionSource@SECURITY_SERVER" />' && !isPortalV6) {
      setElementEnabledState($generateServicesFormsBtn, false);
    } else {
      setElementEnabledState($generateServicesFormsBtn, true);
    }

    var $securityServerAllAllowed = $("#securityServerAllAllowed");
    setElementEnabledState($securityServerAllAllowed, isPortalV6);

    var $generateServicesFormsBtn = $("#generateServicesFormsBtn");
    setElementEnabledState($generateServicesFormsBtn, hasQueries)
    setRadioButtonEnabledState("SERVICE_URLS", hasQueries);

  }
</script>
<div class="contentbox">
    <s:url var="listProducers" action="listProducers">
        <s:param name="protocol" value="protocol"/>
    </s:url>

    <s:a cssClass="back back_btn" title="%{getText('help.tooltip.toListProducers')}" href="%{listProducers}"><s:text name="help.back.label"/></s:a>

    <s:form method="post" name="query_list" id="form_queries2" theme="simple" enctype="multipart/form-data">
        <s:hidden name="id" value="%{producer.id}"/>
        <s:hidden name="protocol"/>
        <table class="list selection" style="width:100%;">
            <s:if test="producer != null">
            <tr>
                <th colspan="5">
                    <b><s:text name="services.show.list.producer"/>: <s:property value="producer.getActiveName(locale.language).description"/></b>
                </th>
            </tr>


            <tr>
                <td class="modify inactive" colspan="5">
                    <table class="no-border" style="width:100%;">
                        <tr>
                            <td class="inactive">
                                <span><s:text name="services.show.source.%{protocol}"/></span>
                            </td>

                            <td class="inactive">
                                <s:radio label="wsdl source" name="wsdlSource" list="wsdlSources" listValueKey="translateKey" value="defaultWsdlSource"/>
                            </td>
                        </tr>
                        <tr id="<s:property value="@ee.aktors.misp2.action.QueryAction$ServiceDescriptionSource@SECURITY_SERVER" />" class="wsdlSourceOptions hidden">
                            <td class="inactive"><s:text name="services.show.Options"/></td>
                            <td class="inactive">
                                <s:checkbox id="securityServerAllAllowed" name="securityServerAllAllowed" value="true" fieldValue="true" cssClass="styled"/>
                                <label for="securityServerAllAllowed" style="width: 145px"><s:text name='label.input.checkbox.allAllowed'/></label>
                            </td>
                        </tr>
                        <tr id="<s:property value="@ee.aktors.misp2.action.QueryAction$ServiceDescriptionSource@FILE_UPLOAD" />" class="wsdlSourceOptions hidden">
                            <td class="inactive"><s:text name="services.show.selectFile.%{protocol}"/></td>
                            <td class="inactive">
                                <s:if test="#session.SESSION_QUERY_SOURCE_FILE!=null">
                                    <p><s:text name="services.sourceFile.SelectedFile"/>&nbsp;<b>${session.SESSION_QUERY_SOURCE_FILE_NAME}</b></p>
                                    <span><s:text name="services.sourceFile.selectNew"/>&nbsp;</span>
                                </s:if>
                                <s:file name="sourceFile" label="File"/>
                            </td>

                        </tr>
                        <tr id="<s:property value="@ee.aktors.misp2.action.QueryAction$ServiceDescriptionSource@WSDL_URL" />" class="wsdlSourceOptions hidden">
                            <td class="inactive"><s:text name="services.show.url.%{protocol}"/></td>
                            <td class="inactive">
                                <s:textfield autocomplete="on" cssClass="long_url" id="wsdlURL" name="wsdlURL" value="%{producer.wsdlURL}"/>
                            </td>
                        </tr>
                        <tr id="<s:property value="@ee.aktors.misp2.action.QueryAction$ServiceDescriptionSource@SERVICE_URLS" />" class="wsdlSourceOptions hidden">
                            <td class="inactive"></td>
                            <td class="inactive"><s:text name="services.show.selectServices"/></td>
                        </tr>

                        <tr id="openapiServiceCodeRow" class="wsdlSourceOptions hidden">
                            <td class="inactive"><s:text name="services.show.serviceCode"/></td>
                            <td class="inactive">
                                <s:textfield required="true" autocomplete="on" cssClass="long_url" id="openapiServiceCode" name="openapiServiceCode"/>
                                <s:if test="hasOpenapiServiceCodeOptions()">
                                	<s:select list="openapiServiceCodeOptions" id="openapiServiceCodeOptions"/>
                                	<script>
                                		jQuery(document).ready(function() {
                                			jQuery("#openapiServiceCodeOptions").change(function () {
                                				var jqSelect = jQuery(this);
                                				var jqInput = jQuery("#openapiServiceCode");
                                				jqInput.val(jqSelect.val());
                                				jqSelect.val("");
                                				Utils.animateNotification(jqInput, '#FFF');
                                			});
                                		});
                                	</script>
                                </s:if>
                            </td>
                        </tr>


                        <tr>
                            <td class="inactive">
<%--                                <span><s:text name="services.show.action"/></span>--%>
                            </td>
                            <td class="inactive">
                                <s:submit id='updateServicesListBtn' type="submit" value="%{getText('label.button.updateServiceList')}" cssClass="button regular_btn no-margin" action="updateServicesList"/>
                                <s:if test="%{!hasQueries()}">
                                    <s:submit id='updateAndGenerateFormsBtn' type="submit" value="%{getText('label.button.updateAndGenerateForms')}" cssClass="button regular_btn no-margin" action="updateAndGenerateForms"/>
                                </s:if>
                                <s:submit id='generateServicesFormsBtn' type="submit" value="%{getText('label.button.updateServiceDescriptions')}" cssClass="button regular_btn no-margin" action="updateServicesXFroms"/>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            </s:if>


            <%--TABLE START--%>
            <s:if test="queries.size > 0">
                <tr>
                    <td colspan="4" class="modify inactive" style="text-align: right; padding-right: 5px;">
                        <strong><s:text name="check.all"/></strong>
                    </td>
                    <td class="modify center_middle" id="checktd">
                        <strong></strong>
                        <input type="checkbox" value="checkall" name="checkall" id="checkall" class="styled"/>
                    </td>
                </tr>


                <s:iterator value="orgQueries" var="oqs">
                    <s:iterator value="xformsList" var="xList" status="rowstatus">
                        <s:if test="#oqs.id == #xList.query.id">
                            <tr>
                                <s:url var="editXforms" action="editXforms" escapeAmp="false">
                                    <s:param name="id" value="id"/>
                                    <s:param name="protocol" value="protocol"/>
                                </s:url>
                                <td>
                                    <s:set value="#oqs.getActiveName(locale.language).description" var="varQueryName"/>
                                    <s:a href="%{editXforms}" id="xforms_link[%{#rowstatus.index}]" title="%{getText('help.tooltip.lastModified') + ' ' + #xList.lastModified}" theme="xhtml" cssStyle="display: block; width: 100%; height: 100%;">
                                        <s:property value="#varQueryName"/>
                                        <s:if test="#varQueryName==null || #varQueryName==''">
                                            <s:text name="menu.no_description"/>
                                        </s:if>
                                    </s:a>
                                </td>
                                <td style="vertical-align: middle">
                                    <s:property value="#oqs.getFullIdentifierByProtocol(protocol)"/>
                                </td>
                                <td class="modify center_middle">
                                    <s:url var="runXforms" action="xforms-query" escapeAmp="false">
                                        <s:param name="id" value="#oqs.id"/>
                                        <s:param name="protocol" value="protocol"/>
                                    </s:url>
                                    <s:a cssClass="small" href="%{runXforms}" id="xforms_run_link">
                                        <img src="resources/<s:property value="subPortal"/>/images/start.png" title="<s:text name="label.execute_query" />" width="20" height="20"/>
                                    </s:a>

                                </td>
                                <td style="vertical-align: middle; padding: 3px">
                                    <input type="text" class="long_url" name="xformUrl" id="xformsUrl[<s:property value="#rowstatus.index"/>]" value='<s:property value="#xList.url"/>'/>
                                </td>
                                <td class="modify center_middle" style="width: 20px;">
                                    <strong></strong>
                                    <input type="checkbox" class="styled" name="updateXforms" id="updateXforms[<s:property value="#rowstatus.index"/>]" value="<s:property value="#oqs.id"/>"/>
                                </td>
                            </tr>
                        </s:if>
                    </s:iterator>
                </s:iterator>
                <s:iterator value="queries" var="qs">
                    <s:iterator value="xformsList" var="xList" status="rowstatus">
                        <s:if test="!(orgQueries.contains(#qs)) and (#qs.id == #xList.query.id)">
                            <tr>
                                <s:url var="editXforms" action="editXforms" escapeAmp="false">
                                    <s:param name="id" value="id"/>
                                    <s:param name="protocol" value="protocol"/>
                                </s:url>
                                <td>
                                    <s:set value="#qs.getActiveName(locale.language).description" var="varQueryName"/>
                                    <s:a href="%{editXforms}" id="xforms_link[%{#rowstatus.index}]" title="%{getText('help.tooltip.lastModified') + ' ' + #xList.lastModified}" theme="xhtml" cssStyle="display: block; width: 100%; height: 100%;">
                                        <s:property value="#varQueryName"/>
                                        <s:if test="#varQueryName==null || #varQueryName==''">
                                            <s:text name="menu.no_description"/>
                                        </s:if>
                                    </s:a>
                                </td>
                                <td class="imported-query-line" style="vertical-align: middle">
                                    <s:property value="#qs.fullIdentifier"/>
                                </td>
                                <td class="modify center_middle">
                                    <s:url var="runXforms" action="xforms-query" escapeAmp="false">
                                        <s:param name="id" value="#qs.id"/>
                                        <s:param name="protocol" value="protocol"/>
                                    </s:url>

                                    <s:a cssClass="small" href="%{runXforms}" id="xforms_run_link">
                                        <img src="resources/<s:property value="subPortal"/>/images/start.png" title="<s:text name="label.execute_query" />" width="20" height="20"/>
                                    </s:a>

                                </td>
                                <td style="vertical-align: middle; padding: 3px">
                                    <input type="text" class="long_url" name="xformUrl" id="xformsUrl[<s:property value="#rowstatus.index"/>]" value='<s:property value="#xList.url"/>'/>
                                </td>
                                <td class="modify center_middle" style="width: 20px;">
                                    <strong></strong>
                                    <input type="checkbox" class="styled" name="updateXforms" id="updateXforms[<s:property value="#rowstatus.index"/>]" value="<s:property value="#qs.id"/>"/>
                                </td>
                            </tr>
                        </s:if>
                    </s:iterator>
                </s:iterator>
            </s:if>
        </table>
        <s:if test="#session.SESSION_PORTAL.mispType==3 and
							#session.SESSION_ACTIVE_ORG.id==#session.SESSION_PORTAL.orgId.id and 
							#session.SESSION_PORTAL.unitIsConsumer==true">
            <hr/>
            <table class="list selection" style="width:100%">
                <thead>
                <tr>
                    <th colspan="3">
                        <h4><s:text name="services.show.list.suborgs"/></h4>
                    </th>
                </tr>
                <tr>
                    <th>
                        <b><s:text name="unit.show.default.item_name"/></b>
                    </th>
                    <th colspan="2">
                        <b><s:text name="xslt_styles.filter.label.query"/></b>
                    </th>
                </tr>
                </thead>
                <s:iterator value="unitsAllowedQueries" var="unitallowed">
                    <tr>
                        <td class="inactive">
                            <span><s:property value="#unitallowed.orgId.getActiveName(locale.language)"/> (<s:property value="#unitallowed.orgId.code"/>)</span>
                        </td>
                        <td class="inactive">
                            <span> <s:property value="#unitallowed.queryId.getActiveName(locale.language).description"/> </span>
                        </td>
                        <td class="inactive">
                            <span> <s:property value="#unitallowed.queryId.name"/> </span>
                        </td>

                    </tr>
                </s:iterator>
            </table>
        </s:if>
    </s:form>
</div>
