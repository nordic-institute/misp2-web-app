<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    xmlns:xforms="http://www.w3.org/2002/xforms"
    xmlns:events="http://www.w3.org/2001/xml-events"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" 
    xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
    xmlns:xtee="http://x-tee.riik.ee/xsd/xtee.xsd"
    xmlns:xrd="http://x-road.ee/xsd/x-road.xsd"
    xmlns:tm="tambet.matiisen@gmail.com"
    exclude-result-prefixes="wsdl soap tm">
<xsl:import href="xtee2xforms.xsl"/>
<xsl:import href="complextraverse.xsl"/>
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" /> 

<!-- Add namespaces of suboperations when complex operation. -->
<xsl:template match="wsdl:binding/wsdl:operation" mode="html">
  <xsl:if test="xtee:complex">
    <xsl:apply-templates mode="namespace"/>
  </xsl:if>
  <xsl:apply-imports/>
</xsl:template>

<xsl:template match="xtee:suboperation[@*:type='locator']" mode="namespace">
  <xsl:variable name="producer" select="substring-before(@*:href, '.')"/>
  <!-- TODO: Should use target namespace from WSDL, but this is easier and quicker. -->
  <xsl:namespace name="{$producer}" select="concat('http://producers.', $producer, '.xtee.riik.ee/producer/', $producer)"/>
</xsl:template>

<!-- Don't descend certain modes to suboperations. -->
<xsl:template match="xtee:complex" mode="title heading helpers activate"/>

<!-- Toggle subform 'this' to be active. It contains event that transfers to first actual form and sets substitutions. -->
<xsl:template match="wsdl:binding/wsdl:operation" mode="activate">
  <xsl:choose>
    <xsl:when test="xtee:complex">
      <xforms:dispatch targetid="this.request" name="xforms-select" events:event="xforms-ready"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Dummy case for 'this'. -->
<xsl:template match="xtee:suboperation[@*:label = 'this' and @*:type = 'resource']" mode="form">
  <xsl:param name="complex" tunnel="yes"/>
  <xforms:case id="{@*:label}.request">
    <!-- Generate automatic transition to first form, with substitutions when = 'this' and everything. -->
    <xsl:apply-templates select="$complex/xtee:arc[@*:from = current()/@*:label and @*:actuate = 'onLoad'][1]" mode="link"/>
  </xforms:case>
</xsl:template>

<!-- Generate suboperations help -->
<xsl:template match="wsdl:portType/wsdl:operation/wsdl:input" mode="form-heading">
  <xsl:param name="complex" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form-heading: ', name(), ', ', @message)"/></xsl:if>
  <xsl:if test="$complex">
    <xsl:apply-templates select=".." mode="help-only"/>
  </xsl:if>
  <xsl:apply-imports/>
</xsl:template>

<!-- Automatic submit when actuate=onLoad. -->
<xsl:template match="wsdl:portType/wsdl:operation/wsdl:input" mode="form">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="actuate" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form-heading(complex): ', name(), ', ', @name)"/></xsl:if>
  <xsl:choose>
    <xsl:when test="$actuate = 'onLoad'">
      <!-- Do submit when input form is activated. -->
      <xforms:send submission="{$formname}.submission" events:event="xforms-select"/>
      <!-- Suppress normal form, as it is not needed anyway. -->
    </xsl:when>
    <xsl:otherwise>
      <!-- Process as usual. -->
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Supress default automatic submit generation logic when suboperation. -->
<xsl:template match="wsdl:message" mode="form-heading">
  <xsl:param name="complex" tunnel="yes"/>
  <xsl:choose>
    <xsl:when test="$complex">
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Unconditional arcs (without arcrole) from suboperation are at the end of response form. -->
<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="form">
  <xsl:param name="complex" tunnel="yes"/>
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:apply-imports/>
  <xsl:if test="$complex">
    <!-- There could be several links which need to be activated after submit, depending on XPath condition. -->
    <xsl:apply-templates select="$complex/xtee:arc[@*:from = $formname and @*:actuate = 'onLoad']" mode="link"/>
    <!-- Add buttons to navigate to other forms. -->
    <xsl:apply-templates select="$complex/xtee:arc[@*:from = $formname and @*:actuate = 'onRequest' and not(exists(@*:arcrole))]" mode="link"/>
  </xsl:if>
</xsl:template>

<xsl:function name="tm:extract-label">
  <xsl:param name="link" />
  <xsl:if test="$debug"><xsl:message select="concat('extract-label: ', $link)"/></xsl:if>
  <xsl:value-of select="substring-before($link, '#xpointer(')"/>
</xsl:function>

<xsl:function name="tm:extract-producer">
  <xsl:param name="fullname" />
  <xsl:if test="$debug"><xsl:message select="concat('extract-producer: ', $fullname)"/></xsl:if>
  <xsl:value-of select="substring-before($fullname, '.')"/>
</xsl:function>

<xsl:function name="tm:extract-operation">
  <xsl:param name="fullname" />
  <xsl:if test="$debug"><xsl:message select="concat('extract-operation: ', $fullname)"/></xsl:if>
  <xsl:value-of select="substring-before(substring-after($fullname, '.'), '.')"/>
</xsl:function>

<!-- Extracts path from xlink reference. -->
<xsl:function name="tm:extract-path">
  <xsl:param name="link" />
  <xsl:if test="$debug"><xsl:message select="concat('extract-path: ', $link)"/></xsl:if>
  <xsl:value-of select="replace($link, '[^#]*#xpointer\(([^\[]*)(\[.*\].*)?\)', '$1')"/>
  <!--xsl:message select="concat('link: ', $link, ', path: ', replace($link, '[^#]*#xpointer\(([^\[]*)(\[.*\])?\)', '$1'))"/-->
</xsl:function>

<!-- Extracts condition from xlink reference. -->
<xsl:function name="tm:extract-condition">
  <xsl:param name="link" />
  <xsl:if test="$debug"><xsl:message select="concat('extract-condition: ', $link)"/></xsl:if>
  <xsl:value-of select="replace($link, '[^#]*#xpointer\(([^\[]*)(\[.*\].*)?\)', '$2')"/>
  <!--xsl:message select="concat('link: ', $link, ', condition: ', replace($link, '[^#]*#xpointer\(([^\[]*)(\[.*\])?\)', '$2'))"/-->
</xsl:function>

<xsl:template match="xsd:element | wsdl:part[@name = 'keha']" mode="form">
  <xsl:param name="complex" tunnel="yes"/>
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="parentref" tunnel="yes"/>
  <xsl:param name="ref" tunnel="yes"/>
  <xsl:param name="element" tunnel="yes"/>
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:param name="actuate" tunnel="yes"/>
  <xsl:param name="tnsprefix" tunnel="yes"/>
  <xsl:choose>
    <!-- Do not generate input form, when it will be submitted automatically. -->
    <xsl:when test="$formtype = 'input' and $actuate = 'onLoad'"/>
    <!-- When part of complex form, then check if need to include link. -->
    <xsl:when test="$complex">
      <!-- TODO: Duplicated code from schema2xforms.xsl. -->
      <!-- Absolute reference to parent element. May be empty. -->
      <xsl:variable name="parentref" select="if ($ref = '.') then $parentref else if ($parentref = '') then $ref else concat($parentref, '/', $ref)"/>
      <!-- Relative reference to this element. -->
      <xsl:variable name="ref" select="normalize-space(if ($element) then $element else @name)"/>
      <!-- Absolute reference to this element. -->
      <xsl:variable name="fullref" select="concat($parentref, '/', $ref)"/>
      <!-- If arcrole starts with /paring, it refers to input form instead of output form. -->
      <xsl:variable name="arcroleref" select="if ($formtype = 'input') then replace($fullref, '^/keha', '/paring') else $fullref"/>
      <!--xsl:message select="concat('parentref: ', $parentref, ', ref: ', $ref)"/>
      <xsl:message select="concat('fullref: ', $fullref, ', arcroleref: ', $arcroleref)"/-->
      <!-- Look for enumerations for this control. -->
      <xsl:variable name="enumeration">
        <xsl:apply-templates select="$complex/xtee:substitution[tm:extract-label(@*:to) = $formname and replace(tm:extract-path(@*:to), '^/paring', '/keha') = $fullref and tm:extract-condition(@*:to) = '[@enumeration]']" mode="enumeration">
          <xsl:with-param name="ref" select="$ref" tunnel="yes"/>
          <xsl:with-param name="node" select="." tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:variable>
      <!-- Apply templates to all arcs with link in arcrole equal to current path. -->
      <!-- Arcs with @title = '_DATA' first. -->
      <xsl:variable name="control">
        <xsl:apply-templates select="$complex/xtee:arc[@*:from = $formname and $arcroleref = tm:extract-path(@*:arcrole) and @*:title = '_DATA']" mode="link">
          <xsl:with-param name="ref" select="$ref" tunnel="yes"/>
          <xsl:with-param name="node" select="." tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="exists($enumeration/*)">
          <xsl:copy-of select="$enumeration"/>
        </xsl:when>
        <!-- Arcs with @title = '_DATA' replace control itself. -->
        <xsl:when test="exists($control/*)">
          <xsl:copy-of select="$control"/>
          <!-- Add links with @title != '_DATA' after the main link. -->
          <xsl:apply-templates select="$complex/xtee:arc[@*:from = $formname and $arcroleref = tm:extract-path(@*:arcrole) and not(@*:title = '_DATA') and @*:actuate = 'onRequest']" mode="link">
            <xsl:with-param name="ref" select="$ref" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <!-- Generate control as usual. -->
          <xsl:variable name="control">
            <xsl:apply-imports/>
          </xsl:variable>
          <!-- If control is repeat or group, then put link inside. -->
          <xsl:choose>
            <xsl:when test="$control/xforms:repeat">
              <xforms:repeat>
                <xsl:copy-of select="$control/xforms:repeat/@*"/>
                <xsl:copy-of select="$control/xforms:repeat/*"/>
                <!-- Use . as ref. -->
                <xsl:apply-templates select="$complex/xtee:arc[@*:from = $formname and $arcroleref = tm:extract-path(@*:arcrole) and not(@*:title = '_DATA') and @*:actuate = 'onRequest']" mode="link">
                  <xsl:with-param name="ref" select="'.'" tunnel="yes"/>
                </xsl:apply-templates>
              </xforms:repeat>
              <!-- Copy also triggers on input form. -->
              <xsl:copy-of select="$control/xforms:trigger"/>
            </xsl:when>
            <xsl:when test="$control/xforms:group">
              <xforms:group>
                <xsl:copy-of select="$control/xforms:group/@*"/>
                <xsl:copy-of select="$control/xforms:group/xforms:label"/>
                <!-- Use . as ref. -->
                <xsl:apply-templates select="$complex/xtee:arc[@*:from = $formname and $arcroleref = tm:extract-path(@*:arcrole) and not(@*:title = '_DATA') and @*:actuate = 'onRequest']" mode="link">
                  <xsl:with-param name="ref" select="'.'" tunnel="yes"/>
                </xsl:apply-templates>
                <xsl:copy-of select="$control/xforms:group/* except $control/xforms:group/xforms:label"/>
              </xforms:group>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$control"/>
              <xsl:apply-templates select="$complex/xtee:arc[@*:from = $formname and $arcroleref = tm:extract-path(@*:arcrole) and not(@*:title = '_DATA') and @*:actuate = 'onRequest']" mode="link">
                <xsl:with-param name="ref" select="$ref" tunnel="yes"/>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Add <url> element to instance, if it contains substitutions with url destination. -->
<xsl:template match="wsdl:part[@name='keha']" mode="instance">
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:param name="complex" tunnel="yes"/>
  <xsl:apply-imports/>
  <xsl:if test="starts-with($operation, 'legacy') and $complex and $formtype='input'">
    <url>
      <xsl:apply-templates select="$complex/xtee:substitution[starts-with(@*:to, concat($formname, '#xpointer(/url/'))]" mode="instance-url"/>
    </url>
  </xsl:if>
</xsl:template>

<!-- Generate subelements to <url>. -->
<xsl:template match="xtee:substitution" mode="instance-url">
  <xsl:element name="{substring-before(substring-after(@*:to, '#xpointer(/url/'), ')')}"/>
</xsl:template>

<!-- Make <url> element non-relevant, so it is not sent with query. -->
<xsl:template match="wsdl:part[@name='keha']" mode="bind">
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:param name="complex" tunnel="yes"/>
  <xsl:apply-imports/>
  <xsl:if test="starts-with($operation, 'legacy') and $complex and $formtype='input'">
    <xforms:bind nodeset="url" relevant="false()"/>
  </xsl:if>
</xsl:template>

<!-- If legacy query finishes, immediately open legacy url. -->
<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="submission-actions-submit-done">
  <xsl:param name="complex" tunnel="yes"/>
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:choose>
    <xsl:when test="$complex and starts-with($operation, 'legacy')">
      <xsl:apply-templates select="$complex/xtee:substitution[starts-with(@*:to, concat($formname, '#xpointer(/url/'))]" mode="submission-actions-submit-done-url"/>
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Generate setvalue elements to add parameters to url. -->
<xsl:template match="xtee:substitution" mode="submission-actions-submit-done-url">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="namespace" tunnel="yes"/>
  <xsl:param name="tnsprefix" tunnel="yes"/>
  <xsl:param name="xroad-version" tunnel="yes"/>
  <xforms:setvalue ref="instance('{$formname}.output')/SOAP-ENV:Body/{if ($namespace) then concat($tnsprefix, ':') else ''}{$operation}Response/{if ($xroad-version = 5  or $xroad-version = 6) then 'response' else 'keha'}/url" value="concat(instance('{$formname}.output')/SOAP-ENV:Body/{if ($namespace) then concat($tnsprefix, ':') else ''}{$operation}Response/{if ($xroad-version = 5 or $xroad-version = 6) then 'response' else 'keha'}/url, '&amp;{substring-before(substring-after(@*:to, '#xpointer(/url/'), ')')}=', instance('{$formname}.input')/SOAP-ENV:Body/{if ($namespace) then concat($tnsprefix, ':') else ''}{$operation}/url/{substring-before(substring-after(@*:to, '#xpointer(/url/'), ')')})" events:event="xforms-submit-done">
    <xsl:if test="$namespace">
      <xsl:namespace name="{$tnsprefix}" select="$namespace"/>
    </xsl:if>
  </xforms:setvalue>
</xsl:template>

<xsl:template match="xtee:arc[@*:actuate = 'onRequest' and @*:to != '']" mode="link">
  <xsl:param name="complex" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="ref" tunnel="yes"/>
  <xsl:param name="node" tunnel="yes"/>
  <xsl:param name="default-language" tunnel="yes"/>
  <!--xsl:message select="concat('arcrole: ', @*:arcrole)"/-->
  <!-- Must use relative ref instead of full ref from arcrole, 
       because otherwise it wouldn't work with repeating elements. 
       Add condition from arcrole manually. -->
  <xforms:group>
    <!-- Make group visible only when element referenced by arcrole exists. -->
    <xsl:if test="@*:arcrole">
      <xsl:attribute name="ref" select="concat($ref, tm:extract-condition(@*:arcrole))"/>
    </xsl:if>
    <!-- In case of @title = '_DATA' add label to group, because link title is taken from data. -->
    <!-- When repeat with appearance=compact is used, this way the column gets normal heading. -->
    <xsl:if test="upper-case(@*:title) = '_DATA'">
      <xsl:apply-templates select="$node" mode="label-only"/>
    </xsl:if>
    <xforms:trigger appearance="minimal">
      <xsl:variable name="title" select="../xtee:suboperation[@*:label = current()/@*:to]/@*:title"/>
      <xsl:choose>
        <!-- In case of @title = '_DATA' actual data is used as link title. -->
        <xsl:when test="upper-case(@*:title) = '_DATA'">
          <xforms:label ref="."/>
        </xsl:when>
        <!-- If referenced suboperation has title, then use it. -->
        <xsl:when test="$title != ''">
          <xforms:label xml:lang="{$default-language}">
            <xsl:value-of select="$title"/>
          </xforms:label>
          <xsl:if test="@*:title != ''">
            <xforms:hint xml:lang="{$default-language}">
              <xsl:value-of select="@*:title"/>
            </xforms:hint>
          </xsl:if>
        </xsl:when>
        <!-- If arc has title, then use it. -->
        <xsl:when test="@*:title != ''">
          <xforms:label xml:lang="{$default-language}">
            <xsl:value-of select="@*:title"/>
          </xforms:label>
        </xsl:when>
        <!-- Otherwise fixed title. -->
        <xsl:otherwise>
          <xforms:label xml:lang="et">Edasi</xforms:label>
          <xforms:label xml:lang="en">Next</xforms:label>
        </xsl:otherwise>
      </xsl:choose>
      <!-- To force updates to model first, the substitution and main action are in separate upper level blocks. -->
      <xforms:action events:event="DOMActivate">
        <xsl:apply-templates select="." mode="substitutions"/>
      </xforms:action>
      <xsl:choose>
        <!-- If arc points to legacy query then do submit immediately, which opens new window in xforms-submit-done. -->
        <xsl:when test="starts-with(substring-after($complex/xtee:suboperation[@*:label = current()/@*:to]/@*:href, '.'), 'legacy')">
          <xforms:send submission="{@*:to}.submission" events:event="DOMActivate"/>
        </xsl:when>
        <!-- Change to request form of target query. -->
        <xsl:otherwise>
          <xforms:toggle case="{@*:to}.request" events:event="DOMActivate"/>
        </xsl:otherwise>
      </xsl:choose>
    </xforms:trigger>
  </xforms:group>
</xsl:template>

<xsl:template match="xtee:arc[@*:actuate = 'onLoad' and @*:to != '']" mode="link">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="namespace" tunnel="yes"/>
  <xsl:param name="tnsprefix" tunnel="yes"/>
  <xsl:choose>
    <xsl:when test="exists(@*:arcrole)">
      <xforms:action events:event="xforms-select" if="boolean(instance('{$formname}.output')/SOAP-ENV:Body/{if ($namespace) then concat($tnsprefix, ':') else ''}{$operation}Response{concat(tm:extract-path(@*:arcrole), tm:extract-condition(@*:arcrole))})">
        <xsl:if test="$namespace">
          <xsl:namespace name="{$tnsprefix}" select="$namespace"/>
        </xsl:if>
        <xsl:apply-templates select="." mode="substitutions"/>
      </xforms:action>
      <!-- Toggle must be separate action, this way it is executed _after_ substitutions. -->
      <xforms:toggle case="{@*:to}.request" events:event="xforms-select" if="boolean(instance('{$formname}.output')/SOAP-ENV:Body/{if ($namespace) then concat($tnsprefix, ':') else ''}{$operation}Response{concat(tm:extract-path(@*:arcrole), tm:extract-condition(@*:arcrole))})">
        <xsl:if test="$namespace">
          <xsl:namespace name="{$tnsprefix}" select="$namespace"/>
        </xsl:if>
      </xforms:toggle>
    </xsl:when>
    <xsl:otherwise>
      <xforms:action events:event="xforms-select">
        <xsl:apply-templates select="." mode="substitutions"/>
      </xforms:action>
      <!-- Toggle must be separate action, this way it is executed _after_ substitutions. -->
      <xforms:toggle case="{@*:to}.request" events:event="xforms-select"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xtee:arc" mode="substitutions">
  <xsl:param name="complex" tunnel="yes"/>
  <xsl:apply-templates select="$complex/xtee:substitution[tm:extract-label(@*:to) = current()/@*:to and (not(exists(@*:when)) or @*:when = current()/@*:from) and tm:extract-condition(@*:to) != '[@enumeration]']" mode="#current"/>
</xsl:template>

<xsl:template match="xtee:substitution" mode="substitutions">
  <xsl:param name="complex" tunnel="yes"/>
  <!-- HACK: Use the same namespace parameter for both to and from. This solves very narrow case with KPR, 
       when both operations are from the same producer and are defined without soap namespace attribute. -->
  <xsl:param name="namespace" tunnel="yes"/>
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:variable name="from-form" select="tm:extract-label(@*:from)"/>
  <xsl:variable name="from-fullname" select="$complex/xtee:suboperation[@*:label = $from-form]/@*:href"/>
  <xsl:variable name="from-producer" select="tm:extract-producer($from-fullname)"/>
  <xsl:variable name="from-operation" select="tm:extract-operation($from-fullname)"/>
  <xsl:variable name="from-path" select="concat(tm:extract-path(@*:from), tm:extract-condition(@*:from))"/>
  <!--xsl:message select="concat('from-operation: ', $from-operation)"/>
  <xsl:message select="concat('from-form: ', $from-form)"/>
  <xsl:message select="concat('from-path: ', $from-path)"/-->
  <xsl:variable name="to-form" select="tm:extract-label(@*:to)"/>
  <xsl:variable name="to-fullname" select="$complex/xtee:suboperation[@*:label = $to-form]/@*:href"/>
  <xsl:variable name="to-producer" select="tm:extract-producer($to-fullname)"/>
  <xsl:variable name="to-operation" select="tm:extract-operation($to-fullname)"/>
  <xsl:variable name="to-path" select="replace(tm:extract-path(@*:to), '^/paring', '/keha')"/>
  <xsl:choose>
    <!-- If from value is constant. -->
    <xsl:when test="$from-form = ''">
      <xforms:setvalue ref="instance('{$to-form}.input')/SOAP-ENV:Body/{if ($namespace) then concat($to-producer, ':') else ''}{$to-operation}{$to-path}" value="'{@*:from}'"/>
    </xsl:when>
    <!-- If can use relative path. -->
    <xsl:when test="$from-form = $formname and not(starts-with($from-path, '/'))">
      <xforms:setvalue ref="instance('{$to-form}.input')/SOAP-ENV:Body/{if ($namespace) then concat($to-producer, ':') else ''}{$to-operation}{$to-path}" value="context()/{$from-path}"/>
    </xsl:when>
    <!-- HACK: When path ends with /ehak then copy value to maakond, vald and asula attributes. 
         Otherwise ehak would be empty, as it is calculated from subfields. -->
    <xsl:when test="ends-with($to-path, '/ehak') or ends-with($from-path, '/ehak')">
      <xforms:setvalue ref="instance('{$to-form}.input')/SOAP-ENV:Body/{if ($namespace) then concat($to-producer, ':') else ''}{$to-operation}{$to-path}/@maakond" value="instance('{$from-form}.output')/SOAP-ENV:Body/{if ($namespace) then concat($from-producer, ':') else ''}{$from-operation}Response{$from-path}"/>
      <xforms:setvalue ref="instance('{$to-form}.input')/SOAP-ENV:Body/{if ($namespace) then concat($to-producer, ':') else ''}{$to-operation}{$to-path}/@vald" value="instance('{$from-form}.output')/SOAP-ENV:Body/{if ($namespace) then concat($from-producer, ':') else ''}{$from-operation}Response{$from-path}"/>
      <xforms:setvalue ref="instance('{$to-form}.input')/SOAP-ENV:Body/{if ($namespace) then concat($to-producer, ':') else ''}{$to-operation}{$to-path}/@asula" value="instance('{$from-form}.output')/SOAP-ENV:Body/{if ($namespace) then concat($from-producer, ':') else ''}{$from-operation}Response{$from-path}"/>
    </xsl:when>
    <!-- When attribute deepcopy="true", then make deep copy with descendants. -->
    <xsl:when test="@deepcopy = 'true'">
      <xforms:insert nodeset="instance('{$to-form}.input')/SOAP-ENV:Body/{if ($namespace) then concat($to-producer, ':') else ''}{$to-operation}{$to-path}" origin="instance('{$from-form}.output')/SOAP-ENV:Body/{if ($namespace) then concat($from-producer, ':') else ''}{$from-operation}Response{$from-path}"/>
      <xforms:delete nodeset="instance('{$to-form}.input')/SOAP-ENV:Body/{if ($namespace) then concat($to-producer, ':') else ''}{$to-operation}{$to-path}[1]"/>
    </xsl:when>
    <!-- Must use absolute path. -->
    <xsl:otherwise>
      <xforms:setvalue ref="instance('{$to-form}.input')/SOAP-ENV:Body/{if ($namespace) then concat($to-producer, ':') else ''}{$to-operation}{$to-path}" value="instance('{$from-form}.output')/SOAP-ENV:Body/{if ($namespace) then concat($from-producer, ':') else ''}{$from-operation}Response{$from-path}"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xtee:substitution" mode="enumeration">
  <xsl:param name="complex" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="namespace" tunnel="yes"/>
  <xsl:param name="ref" tunnel="yes"/>
  <xsl:param name="node" tunnel="yes"/>
  <xsl:variable name="from-form" select="tm:extract-label(@*:from)"/>
  <xsl:variable name="from-fullname" select="$complex/xtee:suboperation[@*:label = $from-form]/@*:href"/>
  <xsl:variable name="from-producer" select="tm:extract-producer($from-fullname)"/>
  <xsl:variable name="from-operation" select="tm:extract-operation($from-fullname)"/>
  <xsl:variable name="from-path" select="concat(tm:extract-path(@*:from), tm:extract-condition(@*:from))"/>
  <xforms:select1 ref="{$ref}">
    <!-- Generate labels and hints. -->
    <xsl:apply-templates select="$node" mode="label"/>
    <xforms:itemset nodeset="instance('{$from-form}.output')/SOAP-ENV:Body/{if ($namespace) then concat($from-producer, ':') else ''}{$from-operation}Response{$from-path}">
      <xsl:choose>
        <xsl:when test="@labelref">
          <xforms:label ref="{@labelref}"/>
        </xsl:when>
        <xsl:otherwise>
          <xforms:label ref="substring-after(text(), ':')"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@valueref">
          <xforms:value ref="{@valueref}"/>
        </xsl:when>
        <xsl:otherwise>
          <xforms:value ref="substring-before(text(), ':')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xforms:itemset>
  </xforms:select1>
</xsl:template>

</xsl:stylesheet>
