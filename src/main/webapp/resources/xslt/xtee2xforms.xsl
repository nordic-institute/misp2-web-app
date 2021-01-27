<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    xmlns:xforms="http://www.w3.org/2002/xforms"
  	xmlns:xxforms="http://orbeon.org/oxf/xml/xforms"
    xmlns:events="http://www.w3.org/2001/xml-events"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" 
    xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
    xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/"
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
    xmlns:xtee="http://x-tee.riik.ee/xsd/xtee.xsd"
    xmlns:xrd="http://x-road.ee/xsd/x-road.xsd"
    xmlns:iden="http://x-road.eu/xsd/identifiers"
    exclude-result-prefixes="wsdl soap mime">
<xsl:import href="wsdl2xforms.xsl"/>
<xsl:import href="xteetraverse.xsl"/>
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" /> 

<!-- Default name of the institution performing the query. -->
<xsl:param name="institution"/>
<!-- Default ID code of the person performing the query. -->
<xsl:param name="idcode"/>
<!-- Default post of the person performing the query. -->
<xsl:param name="post"/>
<!-- Default query ID. -->
<xsl:param name="id"/>
<!-- Default document number. -->
<xsl:param name="document"/>

<!-- Prefix for classifiers. -->
<xsl:param name="classifier-prefix"/>
<!-- Suffix for classifiers. -->
<xsl:param name="classifier-suffix">.xml</xsl:param>

<!-- Debug flag. -->
<xsl:param name="debug" select="false()"/>

<!-- X-Road v6 SOAP request header parameters -->
<!-- Integer marking X-Road version: 6 for v6, 5 for v5, 1 for earlier (v4) -->
<xsl:param name="xroad-version" />
<xsl:param name="xroad6-service-instance" />
<xsl:param name="xroad6-service-member-class" />
<xsl:param name="xroad6-service-member-code" />
<xsl:param name="xroad6-service-subsystem-code" />

<xsl:param name="xroad6-client-xroad-instance" />
<xsl:param name="xroad6-client-member-class" />
<xsl:param name="xroad6-client-member-code" />
<xsl:param name="xroad6-client-subsystem-code" />

<!-- Just to make xtee namespace appear in root element and rename targetnamespace prefix. -->
<xsl:template match="wsdl:binding/wsdl:operation" mode="document">
  <xsl:param name="producer" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('#default(xtee): ', name(), ', ', @name)"/></xsl:if>
  <xhtml:html>
    <xsl:if test="/wsdl:definitions/@targetNamespace or /wsdl:definitions/wsdl:types/xsd:schema/@targetNamespace">
      <xsl:namespace name="{$producer}" select="
      		if(/wsdl:definitions/wsdl:types/xsd:schema[@targetNamespace][1]) 
      		then /wsdl:definitions/wsdl:types/xsd:schema[@targetNamespace][1]/@targetNamespace
     		else /wsdl:definitions/@targetNamespace" />
    </xsl:if>
    <xsl:apply-templates select="." mode="html">
      <xsl:with-param name="tnsprefix" select="$producer" tunnel="yes"/>
    </xsl:apply-templates>
  </xhtml:html>
</xsl:template>

<!-- Instance generation. -->

<!-- Some services rely on fixed namespace prefix. -->
<xsl:template match="wsdl:portType/wsdl:operation/wsdl:input" mode="instance">
  <xsl:apply-imports>
    <xsl:with-param name="tnsprefix" select="'ns5'" tunnel="yes" />
  </xsl:apply-imports>
</xsl:template>

<xsl:template match="/" mode="instance">
  <xsl:param name="name"/>
  <xsl:param name="what"/>
  <xsl:param name="context"/>
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:param name="mime_parts" tunnel="yes"/>
  
  <xsl:if test="$debug"><xsl:message select="concat('instance(xtee): ', $name, ', ', $what, ', ', $context/name())"/></xsl:if>

  <!-- Resolve type name. -->
  <xsl:variable name="qname" select="resolve-QName($name, $context)"/>
  <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
  <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>

  <xsl:choose>
    <!-- If type is ehak, then add three additional attributes. -->
    <xsl:when test="ends-with($what, 'Type') and $localname = 'ehak' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
      <xsl:attribute name="maakond" />
      <xsl:attribute name="vald" />
      <xsl:attribute name="asula" />
    </xsl:when>
    <!-- If type is ArrayOfStrings, then create empty array item. -->
    <!--xsl:when test="ends-with($what, 'Type') and $localname = 'ArrayOfString' and ($namespace = 'http://x-tee.riik.ee/xsd/xtee.xsd' or $namespace = 'http://x-road.ee/xsd/x-road.xsd')"-->
      <!-- Chiba supports by default only XML Schema native types. -->
      <!--xsl:attribute name="type" select="'SOAP-ENC:Array'" namespace="http://www.w3.org/2001/XMLSchema-instance" />
      <xsl:attribute name="arrayType" select="'xsd:string[]'" namespace="http://www.w3.org/2001/XMLSchema-instance" /-->
      <!-- Add initial item to be used for repeat. -->
      <!--item xsi:type="xsd:string"/>
    </xsl:when-->
    <xsl:when test="ends-with($what, 'Type') and $localname = ('base64Binary', 'hexBinary') and $namespace = 'http://www.w3.org/2001/XMLSchema' and $mime_parts">
      <xsl:if test="$formtype = 'input'">
        <xsl:attribute name="href" />
		<xsl:attribute name="filename" />
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <!-- Resolve type/element/attribute. -->
      <xsl:apply-imports>
        <xsl:with-param name="name" select="$name"/>
        <xsl:with-param name="what" select="$what"/>
        <xsl:with-param name="context" select="$context"/>
      </xsl:apply-imports>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Do not attach type to elements with enumeration restriction. -->
<xsl:template match="xsd:restriction" mode="instance">
  <xsl:if test="$debug"><xsl:message select="concat('instance(xtee): ', name(), ', ', @type)"/></xsl:if>
  <xsl:choose>
    <xsl:when test="xsd:enumeration"/>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- SOAP header. -->
<xsl:template match="wsdl:portType/wsdl:operation/wsdl:input" mode="instance-soap-header">
  <xsl:param name="producer" tunnel="yes"/>
  <xsl:param name="fullname" tunnel="yes"/>
  
  <!-- X-Road v6 SOAP request header parameters -->
  <xsl:param name="operation" tunnel="yes" />
  <xsl:param name="version" tunnel="yes"/>

  <xsl:if test="$debug"><xsl:message select="concat('instance-soap-header(xtee): ', name(), ', ', @message)"/></xsl:if>
  <!-- TODO: Take into account soap:header elements. -->
  <xsl:choose>
    <xsl:when test="$xroad-version = 4">
      <xtee:asutus><xsl:value-of select="$institution"/></xtee:asutus>
      <xtee:andmekogu><xsl:value-of select="$producer"/></xtee:andmekogu>
      <xtee:isikukood>EE<xsl:value-of select="$idcode"/></xtee:isikukood>
      <xtee:id><xsl:value-of select="$id"/></xtee:id>
      <xtee:nimi><xsl:value-of select="$fullname"/></xtee:nimi>
      <xtee:amet><xsl:value-of select="$post"/></xtee:amet>
      <xtee:toimik><xsl:value-of select="$document"/></xtee:toimik>
      <xtee:autentija></xtee:autentija>
      <xtee:ametniknimi></xtee:ametniknimi>
    </xsl:when>
    <xsl:when test="$xroad-version = 5">
      <xrd:consumer><xsl:value-of select="$institution"/></xrd:consumer>
      <xrd:producer><xsl:value-of select="$producer"/></xrd:producer>
      <xrd:userId>EE<xsl:value-of select="$idcode"/></xrd:userId>
      <xrd:id><xsl:value-of select="$id"/></xrd:id>
      <xrd:service><xsl:value-of select="$fullname"/></xrd:service>
      <xrd:position><xsl:value-of select="$post"/></xrd:position>
      <xrd:issue><xsl:value-of select="$document"/></xrd:issue>
      <xrd:authenticator></xrd:authenticator>
      <xrd:userName></xrd:userName>
    </xsl:when>
    <xsl:when test="$xroad-version = 6">
      <xrd:protocolVersion>4.0</xrd:protocolVersion>
      <xrd:id><xsl:value-of select="$id"/></xrd:id>
      <xrd:userId>EE</xrd:userId>
      <xrd:issue><xsl:value-of select="$document"/></xrd:issue>
      <xrd:service iden:objectType="SERVICE">
         <iden:xRoadInstance><xsl:value-of select="$xroad6-service-instance"/></iden:xRoadInstance>
         <iden:memberClass><xsl:value-of select="$xroad6-service-member-class"/></iden:memberClass>
         <iden:memberCode><xsl:value-of select="$xroad6-service-member-code"/></iden:memberCode>
         <iden:subsystemCode><xsl:value-of select="$xroad6-service-subsystem-code"/></iden:subsystemCode>
         <iden:serviceCode><xsl:value-of select="$operation"/></iden:serviceCode>
         <xsl:if test="$version"><iden:serviceVersion><xsl:value-of select="$version"/></iden:serviceVersion></xsl:if>
      </xrd:service>
      <xrd:client iden:objectType="SUBSYSTEM">
         <iden:xRoadInstance><xsl:value-of select="$xroad6-client-xroad-instance"/></iden:xRoadInstance>
         <iden:memberClass><xsl:value-of select="$xroad6-client-member-class"/></iden:memberClass>
         <iden:memberCode><xsl:value-of select="$xroad6-client-member-code"/></iden:memberCode>
         <iden:subsystemCode><xsl:value-of select="$xroad6-client-subsystem-code"/></iden:subsystemCode>
      </xrd:client>
    </xsl:when>
  </xsl:choose>
  <xsl:apply-imports />
</xsl:template>

<!-- Ignore "paring" parts. -->
<xsl:template match="wsdl:part[@name = 'paring']" mode="#all"/>

<!-- Ignore "request" element on output form. -->
<!-- NB! Only applies to mode "bind", see template for mode "form" somewhere below. -->
<xsl:template match="xsd:element[@name = 'request']" mode="bind">
  <xsl:param name="formtype" tunnel="yes" />
  <xsl:if test="$formtype = 'input'">
    <xsl:apply-imports/>
  </xsl:if>
</xsl:template>

<!-- Lookup instance generation. -->

<xsl:template match="/" mode="lookup">
  <xsl:param name="name"/>
  <xsl:param name="what"/>
  <xsl:param name="context"/>
  <xsl:if test="$debug"><xsl:message select="concat('lookup: ', $name, ', ', $what)"/></xsl:if>

  <!-- Resolve type name. -->
  <xsl:variable name="qname" select="resolve-QName($name, $context)"/>
  <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
  <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>
  <xsl:if test="$debug"><xsl:message select="concat('namespace-uri-from-QName: ', $namespace)"/></xsl:if>

  <!-- Generate lookup instance for EHAK components. -->
  <xsl:if test="$namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
    <xsl:choose>
      <xsl:when test="$localname = 'ehak'">
        <xforms:instance id="ehak.classifier" src="{$classifier-prefix}ehak{$classifier-suffix}"/>
      </xsl:when>
      <xsl:when test="$localname = 'maakond'">
        <xforms:instance id="maakonnad.classifier" src="{$classifier-prefix}maakonnad{$classifier-suffix}"/>
      </xsl:when>
      <xsl:when test="$localname = 'vald'">
        <xforms:instance id="vallad.classifier" src="{$classifier-prefix}vallad{$classifier-suffix}"/>
      </xsl:when>
      <xsl:when test="$localname = 'asula'">
        <xforms:instance id="asulad.classifier" src="{$classifier-prefix}asulad{$classifier-suffix}"/>
      </xsl:when>
    </xsl:choose>
  </xsl:if>

  <xsl:apply-imports>
    <xsl:with-param name="name" select="$name"/>
    <xsl:with-param name="what" select="$what"/>
    <xsl:with-param name="context" select="$context"/>
  </xsl:apply-imports>
</xsl:template>

<xsl:template match="xsd:annotation/xsd:appinfo/xtee:lookup | xsd:annotation/xsd:appinfo/xrd:lookup" mode="lookup">
  <xforms:instance id="{.}.classifier" src="{$classifier-prefix}{.}{$classifier-suffix}"/>
</xsl:template>

<!-- Bindings -->

<xsl:template match="/" mode="bind">
  <xsl:param name="name"/>
  <xsl:param name="what"/>
  <xsl:param name="context"/>
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('bind(xtee): ', $name, ', ', $what)"/></xsl:if>

  <!-- Resolve type name. -->
  <xsl:variable name="qname" select="resolve-QName($name, $context)"/>
  <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
  <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>

  <xsl:choose>
    <!-- If type is xtee:ehak, then make additional attributes non-relevant. -->
    <xsl:when test="ends-with($what, 'Type') and $localname = 'ehak' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd') and $formtype = 'input'">
      <!-- Use first attribute that is not empty as EHAK value. -->
      <xsl:attribute name="calculate">if (@asula != '') then @asula else if (@vald != '') then @vald else @maakond</xsl:attribute>
      <!-- Calculate makes ehak and it's children automatically readonly. Revert this. -->
      <xsl:attribute name="readonly">false()</xsl:attribute>
      <!-- Don't send additional attributes with submit. -->
      <xforms:bind nodeset="@maakond" relevant="boolean-from-string(instance('temp')/relevant)"/>
      <xforms:bind nodeset="@vald" relevant="boolean-from-string(instance('temp')/relevant)"/>
      <xforms:bind nodeset="@asula" relevant="boolean-from-string(instance('temp')/relevant)"/>
    </xsl:when>
    <!-- If type is xtee:url, then add type xforms:anyURI, to make it link in output. -->
    <xsl:when test="ends-with($what, 'Type') and $localname = 'url' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
      <xsl:attribute name="type" select="'xforms:anyURI'"/>
    </xsl:when>
    <!-- All binary fields are saved as temporary files and replaced with link. -->
    <!--xsl:when test="$formtype = 'output' and $localname = ('base64Binary', 'hexBinary') and $namespace = 'http://www.w3.org/2001/XMLSchema'">
      <xsl:attribute name="type" select="'xforms:anyURI'"/>
    </xsl:when-->
    <xsl:otherwise>
      <!-- Resolve type/element/attribute. -->
      <xsl:apply-imports>
        <xsl:with-param name="name" select="$name"/>
        <xsl:with-param name="what" select="$what"/>
        <xsl:with-param name="context" select="$context"/>
      </xsl:apply-imports>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xsd:element" mode="required">
  <xsl:param name="requirecontent" tunnel="yes"/>
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('required(xtee): ', name(), ', ', @name)"/></xsl:if>
  <xsl:choose>
    <!-- Use schema MIPS on input forms. -->
    <xsl:when test="$formtype = 'input'">
      <xsl:if test="$requirecontent = 'true' and (not(@minOccurs) or @minOccurs &gt; 0)">true()</xsl:if>
      <!--xsl:apply-imports /-->
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xsd:attribute" mode="required">
  <xsl:param name="requirecontent" tunnel="yes"/>
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('required(xtee): ', name(), ', ', @name)"/></xsl:if>
  <xsl:choose>
    <!-- Use schema MIPS on input forms. -->
    <xsl:when test="$formtype = 'input'">
      <xsl:if test="$requirecontent = 'true' and @use='required'">true()</xsl:if>
      <!--xsl:apply-imports /-->
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xsd:element | xsd:attribute | xsd:choice" mode="relevant">
  <xsl:param name="nocontent" tunnel="yes"/>
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('relevant(xtee): ', name(), ', ', @name)"/></xsl:if>
  <xsl:if test="$formtype = 'output'">
    <!-- Suppress empty fields if xtee:nocontent = null. -->
    <xsl:if test="$nocontent = 'null'">. != ''</xsl:if>
  </xsl:if>
  <xsl:apply-imports/>
</xsl:template>

<xsl:template match="xsd:element | xsd:attribute" mode="constraint">
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('constraint(xtee): ', name(), ', ', @name)"/></xsl:if>
  <xsl:choose>
    <xsl:when test="$formtype = 'input'">
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:when test="$formtype = 'output'">
      <!-- Suppress normal constraints on output forms. -->
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- Submission -->

<!-- Set id to random number. -->
<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="submission-actions-submit">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:apply-imports/>
  <xforms:setvalue ref="instance('{$formname}.input')/SOAP-ENV:Header/*:id" value="digest(string(random()), 'SHA-1', 'hex')" events:event="xforms-submit"/>
</xsl:template>

<!-- Submit error message. -->
<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="submission-actions-submit-error-message">
  <xforms:output xml:lang="et" 
    value="if (event('error-type') = 'submission-in-progress') then 'Üks päring juba käib!' 
      else if (event('error-type') = 'no-data') then 'Pole andmeid, mida saata!' 
      else if (event('error-type') = 'validation-error') then 'Valideerimise viga!' 
      else if (event('error-type') = 'parse-error') then 'Viga vastuse töötlemisel!' 
      else if (event('error-type') = 'resource-error') then 'Päringu vastus ei ole XML!' 
      else if (event('error-type') = 'target-error') then 'Sihtkoha viga!' 
      else 'Sisemine viga!'" />
  <xforms:output xml:lang="en" 
    value="if (event('error-type') = 'submission-in-progress') then 'Submission already started!' 
      else if (event('error-type') = 'no-data') then 'No data to submit!' 
      else if (event('error-type') = 'validation-error') then 'Validation error!' 
      else if (event('error-type') = 'parse-error') then 'Error parsing response!' 
      else if (event('error-type') = 'resource-error') then 'Response is not XML!' 
      else if (event('error-type') = 'target-error') then 'Target error!' 
      else 'Internal error!'" />
</xsl:template>

<!-- Forms -->

<xsl:template match="/" mode="form">
  <xsl:param name="name"/>
  <xsl:param name="what"/>
  <xsl:param name="context"/>
  <xsl:param name="node" tunnel="yes"/>
  <xsl:param name="ref" tunnel="yes"/>
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form(xtee): ', $name, ', ', $what)"/></xsl:if>

  <xsl:variable name="qname" select="resolve-QName($name, $context)"/>
  <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
  <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>

  <xsl:choose>
    <xsl:when test="ends-with($what, 'Type')">
      <xsl:choose>
        <xsl:when test="$formtype = 'input'">
          <xsl:choose>
            <!-- Ignore ArrayOfString in input. -->
            <xsl:when test="$localname = 'ArrayOfString' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
            </xsl:when>
            <xsl:when test="$localname = 'maakond' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xforms:select1 ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
                <!-- Add blank item in beginning to accomodate empty value. -->
                <xforms:item>
                  <xforms:label/>
                  <xforms:value/>
                </xforms:item>
                <xforms:itemset nodeset="instance('maakonnad.classifier')/maakond">
                  <xforms:label ref="@nimi"/>
                  <xforms:value ref="@kood"/>
                </xforms:itemset>
              </xforms:select1>
            </xsl:when>
            <xsl:when test="$localname = 'vald' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xforms:select1 ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
                <xsl:variable name="dependref" select="$node/xsd:annotation/xsd:appinfo/(xtee:ref | xrd:ref)"/>
                <!-- Add blank item in beginning to accomodate empty value. -->
                <xforms:item>
                  <xforms:label/>
                  <xforms:value/>
                </xforms:item>
                <xforms:itemset nodeset="instance('vallad.classifier')/maakond{if ($dependref) then concat('[@kood=context()/../', $dependref, ']') else ''}/vald">
                  <xforms:label ref="@nimi"/>
                  <xforms:value ref="@kood"/>
                </xforms:itemset>
              </xforms:select1>
            </xsl:when>
            <xsl:when test="$localname = 'asula' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xforms:select1 ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
                <xsl:variable name="dependref" select="$node/xsd:annotation/xsd:appinfo/(xtee:ref | xrd:ref)"/>
                <!-- Add blank item in beginning to accomodate empty value. -->
                <xforms:item>
                  <xforms:label/>
                  <xforms:value/>
                </xforms:item>
                <xforms:itemset nodeset="instance('asulad.classifier')/maakond/vald{if ($dependref) then concat('[@kood=context()/../', $dependref, ']') else ''}/asula">
                  <xforms:label ref="@nimi"/>
                  <xforms:value ref="@kood"/>
                </xforms:itemset>
              </xforms:select1>
            </xsl:when>
            <xsl:when test="$localname = 'ehak' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xforms:group ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label-only"/>
                <!-- In case of EHAK additional attributes maakond, vald and asula will be added to the element. -->
                <!-- Those attributes are suppressed by non-relevant binding. $ref must be an element. -->
                <xforms:select1 ref="@maakond">
                  <xforms:label xml:lang="et">Maakond</xforms:label>
                  <xforms:label xml:lang="en">County</xforms:label>
                  <!-- Add blank item in beginning to accomodate empty value. -->
                  <xforms:item>
                    <xforms:label/>
                    <xforms:value/>
                  </xforms:item>
                  <xforms:itemset nodeset="instance('ehak.classifier')/maakond">
                    <xforms:label ref="@nimi"/>
                    <xforms:value ref="@kood"/>
                  </xforms:itemset>
                  <!-- Set EHAK and vald empty if new maakond is chosen. -->
                  <xforms:setvalue ref="../@asula" events:event="xforms-select"/>
                  <xforms:setvalue ref="../@vald" events:event="xforms-select"/>
                </xforms:select1>
                <xforms:select1 ref="@vald">
                  <xforms:label xml:lang="et">Vald</xforms:label>
                  <xforms:label xml:lang="en">Parish</xforms:label>
                  <!-- Add blank item in beginning to accomodate empty value. -->
                  <xforms:item>
                    <xforms:label/>
                    <xforms:value/>
                  </xforms:item>
                  <xforms:itemset nodeset="instance('ehak.classifier')/maakond[@kood=context()/../@maakond]/vald">
                    <xforms:label ref="@nimi"/>
                    <xforms:value ref="@kood"/>
                  </xforms:itemset>
                  <!-- Set EHAK empty if new vald is chosen. -->
                  <xforms:setvalue ref="../@asula" events:event="xforms-select"/>
                </xforms:select1>
                <xforms:select1 ref="@asula">
                  <xforms:label xml:lang="et">Asula</xforms:label>
                  <xforms:label xml:lang="en">Settlement</xforms:label>
                  <!-- Add blank item in beginning to accomodate empty value. -->
                  <xforms:item>
                    <xforms:label/>
                    <xforms:value/>
                  </xforms:item>
                  <xforms:itemset nodeset="instance('ehak.classifier')/maakond[@kood=context()/../@maakond]/vald[@kood=context()/../@vald]/asula">
                    <xforms:label ref="@nimi"/>
                    <xforms:value ref="@kood"/>
                  </xforms:itemset>
                </xforms:select1>
              </xforms:group>
            </xsl:when>
            <!-- If there is reference to lookup values, then select1 control. -->
            <xsl:when test="$node/xsd:annotation/xsd:appinfo/(xtee:lookup | xrd:lookup)">
              <xforms:select1 ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
                <xsl:variable name="lookup" select="$node/xsd:annotation/xsd:appinfo/(xtee:lookup | xrd:lookup)"/>
                <xsl:variable name="nodeset" select="$node/xsd:annotation/xsd:appinfo/(xtee:lookup | xrd:lookup)/@nodeset"/>
                <xsl:variable name="labelref" select="$node/xsd:annotation/xsd:appinfo/(xtee:lookup | xrd:lookup)/@labelref"/>
                <xsl:variable name="valueref" select="$node/xsd:annotation/xsd:appinfo/(xtee:lookup | xrd:lookup)/@valueref"/>
                <!-- Add blank item in beginning to accomodate empty value. -->
                <xforms:item>
                  <xforms:label/>
                  <xforms:value/>
                </xforms:item>
                <xforms:itemset nodeset="instance('{$lookup}.classifier')/{if ($nodeset) then $nodeset else 'item'}">
                  <xforms:label ref="{if ($labelref) then $labelref else 'label'}"/>
                  <xforms:value ref="{if ($valueref) then $valueref else 'value'}"/>
                </xforms:itemset>
              </xforms:select1>
            </xsl:when>
            <!-- If xtee:fieldtype = 'textarea' then generate textarea control. -->
            <xsl:when test="$node/xsd:annotation/xsd:appinfo/(xtee:fieldtype | xrd:fieldtype) = 'textarea'">
              <xforms:textarea ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
              </xforms:textarea>
            </xsl:when>
            <!-- If xtee:fieldtype = 'comment' then generate output control. -->
            <xsl:when test="$node/xsd:annotation/xsd:appinfo/(xtee:fieldtype | xrd:fieldtype) = 'comment'">
              <xforms:output ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
              </xforms:output>
            </xsl:when>
            <!-- If is image type, then generate upload control with preview. -->
            <xsl:when test="$localname = ('jpg', 'gif', 'png') and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xforms:upload ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
              </xforms:upload>
              <!-- Preview image. -->
              <xforms:output ref="{$ref}" mediatype="image/*"/>
            </xsl:when>
            <!-- If file type, then generate upload control. -->
            <xsl:when test="$localname = ('xml', 'txt', 'csv') and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xforms:upload ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
              </xforms:upload>
            </xsl:when>
            <!-- If url type, then generate input control. -->
            <xsl:when test="$localname = 'url' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xforms:input ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
              </xforms:input>
            </xsl:when>
            <!-- Otherwise let schema2xforms handle it. -->
            <xsl:otherwise>
              <xsl:apply-imports>
                <xsl:with-param name="name" select="$name"/>
                <xsl:with-param name="what" select="$what"/>
                <xsl:with-param name="context" select="$context"/>
              </xsl:apply-imports>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$formtype = 'output'">
          <xsl:choose>
            <!-- Do not show ID fields on output forms. -->
            <xsl:when test="$localname = 'ID' and $namespace = 'http://www.w3.org/2001/XMLSchema'"/>
            <!-- If is boolean type, then display yes/no, instead of Chiba's default - checkbox. -->
            <xsl:when test="$localname = 'boolean' and $namespace = 'http://www.w3.org/2001/XMLSchema'">
              <xforms:group ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
                <xforms:output value="if (boolean-from-string(current())) then 'Jah' else 'Ei'" xml:lang="et"/>
                <xforms:output value="if (boolean-from-string(current())) then 'Yes' else 'No'" xml:lang="en"/>
              </xforms:group>
            </xsl:when>
            <xsl:when test="$localname = 'maakond' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xforms:group ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
                <xforms:output value="instance('maakonnad.classifier')/maakond[@kood = current()]/@nimi"/>
              </xforms:group>
            </xsl:when>
            <xsl:when test="$localname = 'vald' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xsl:variable name="dependref" select="$node/xsd:annotation/xsd:appinfo/(xtee:ref | xrd:ref)"/>
              <xforms:group ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
                <!-- Filter on maakond first, this makes a lot faster. -->
                <xforms:output value="instance('vallad.classifier')/maakond{if ($dependref) then concat('[@kood=current()/../', $dependref, ']') else ''}/vald[@kood = current()]/@nimi"/>
              </xforms:group>
            </xsl:when>
            <xsl:when test="$localname = 'asula' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xsl:variable name="dependref" select="$node/xsd:annotation/xsd:appinfo/(xtee:ref | xrd:ref)"/>
              <xforms:group ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
                <!-- Filter on vald first, this makes a lot faster. -->
                <xforms:output value="instance('asulad.classifier')/maakond/vald{if ($dependref) then concat('[@kood=current()/../', $dependref, ']') else ''}/asula[@kood = current()]/@nimi"/>
              </xforms:group>
            </xsl:when>
            <xsl:when test="$localname = 'ehak' and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xforms:group ref="{$ref}">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label-only"/>
                <xforms:output value="instance('ehak.classifier')/maakond[@kood = current() or vald/@kood = current() or vald/asula/@kood = current()]/@nimi">
                  <xforms:label xml:lang="et">Maakond</xforms:label>
                  <xforms:label xml:lang="en">County</xforms:label>
                </xforms:output>
                <xforms:output value="instance('ehak.classifier')/maakond/vald[@kood = current() or asula/@kood = current()]/@nimi">
                  <xforms:label xml:lang="et">Vald</xforms:label>
                  <xforms:label xml:lang="en">Parish</xforms:label>
                </xforms:output>
                <xforms:output value="instance('ehak.classifier')/maakond/vald/asula[@kood = current()]/@nimi">
                  <xforms:label xml:lang="et">Asula</xforms:label>
                  <xforms:label xml:lang="en">Settlement</xforms:label>
                </xforms:output>
              </xforms:group>
            </xsl:when>
            <!-- If is image type, then generate image output. -->
            <xsl:when test="$localname = ('jpg', 'gif', 'png') and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xforms:output ref="{$ref}" mediatype="image/*">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
              </xforms:output>
            </xsl:when>
            <!-- If is file or URL type, then generate link. -->
            <xsl:when test="$localname = ('xml', 'txt', 'csv', 'url') and $namespace = ('http://x-tee.riik.ee/xsd/xtee.xsd', 'http://x-road.ee/xsd/x-road.xsd')">
              <xforms:trigger ref="{$ref}" appearance="minimal">
                <!-- Generate labels and hints. -->
                <xsl:apply-templates select="$node" mode="label"/>
                <xforms:load events:event="DOMActivate" ref="." show="new"/>
              </xforms:trigger>
            </xsl:when>
            <!-- Otherwise let schema2xforms handle it. -->
            <xsl:otherwise>
              <xsl:apply-imports>
                <xsl:with-param name="name" select="$name"/>
                <xsl:with-param name="what" select="$what"/>
                <xsl:with-param name="context" select="$context"/>
              </xsl:apply-imports>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
    </xsl:when>
    <!-- Resolve element/attribute/type. -->
    <xsl:otherwise>
      <xsl:apply-imports>
        <xsl:with-param name="name" select="$name"/>
        <xsl:with-param name="what" select="$what"/>
        <xsl:with-param name="context" select="$context"/>
      </xsl:apply-imports>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xsd:element" mode="form">
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form(xtee): ', name(), ', ', @name)"/></xsl:if>
  <xsl:choose>
    <!-- Ignore request element on output form. -->
    <xsl:when test="@name = 'request' and $formtype = 'output'"/>
    <!-- Ignore nonvisible controls on both input and output forms. -->
    <xsl:when test="normalize-space(xsd:annotation/xsd:appinfo/(xtee:visibility | xrd:visibility)) = '0'">
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="form-heading">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="xroad-version" tunnel="yes"/>
  <!-- Show query id from the header on output form. -->
  <xforms:group ref="instance('{$formname}.output')/SOAP-ENV:Header" class="serviceid">
    <xforms:output ref="{if ($xroad-version = 5 or $xroad-version = 6) then 'xrd:id' else 'xtee:id'}">
      <xforms:label xml:lang="et">Päringu id</xforms:label>
      <xforms:label xml:lang="en">Query id</xforms:label>
    </xforms:output>
  </xforms:group>
</xsl:template>

<!-- It is important that this template matches wsdl:message, not wsdl:part,
     which would have made expressions somewhat simpler. The problem is, that
     sometimes wsdl:part does not exist and then it will be never matched.
     But in this case also the query must be submitted immediately. -->
<xsl:template match="wsdl:message" mode="form-heading">
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form(xtee): ', name(), ', ', @name)"/></xsl:if>
  <xsl:choose>
    <xsl:when test="$formtype = 'input'">
      <!-- Check for first wsdl:part, because with document/literal style the name can be anything. -->
      <xsl:variable name="element" select="wsdl:part[1]/@element"/>
      <xsl:variable name="type" select="wsdl:part[1]/@type"/>
      <xsl:variable name="qname" select="resolve-QName($type, .)"/>
      <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
      <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>
      <xsl:choose>
        <!-- Query will be submitted immediately, if keha part is missing, 
             if keha type is missing or if keha type is xsd:string. -->
        <xsl:when test="$formtype = 'input' and not(exists($element)) and (not(exists($type)) or ($namespace = 'http://www.w3.org/2001/XMLSchema' and $localname = 'string'))">
          <xforms:send submission="{$formname}.submission" events:event="xforms-select"/>
        </xsl:when>
        <xsl:otherwise>
        	<xsl:if test="starts-with($operation, 'legacy')">
		      <xhtml:h2>
		          <xhtml:span xml:lang="et">Teenuse kasutamiseks tuleb siseneda välisesse süsteemi.</xhtml:span>
		          <xhtml:span xml:lang="en">In order to carry out the query you must enter an external system!</xhtml:span>
		      </xhtml:h2>
		    </xsl:if>
          <xsl:apply-imports/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$formtype = 'output'">
      <xsl:apply-imports/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- Submit label. -->

<xsl:template match="wsdl:binding/wsdl:operation/wsdl:input" mode="form-submit">
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form-submit(xtee): ', name(), ', ', @message)"/></xsl:if>
  <xsl:variable name="actiontitle">
      <xsl:apply-templates select=".." mode="actiontitle"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$actiontitle/*">
      <xsl:copy-of select="$actiontitle/*"/>
    </xsl:when>
    <xsl:when test="starts-with($operation, 'legacy')">
      <xforms:label xml:lang="et">Sisene</xforms:label>
      <xforms:label xml:lang="en">Enter</xforms:label>      
    </xsl:when>
    <xsl:otherwise>
      <xforms:label xml:lang="et">Esita päring</xforms:label>
      <xforms:label xml:lang="en">Submit</xforms:label>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xtee:actiontitle | xrd:actionTitle" mode="actiontitle">
  <xsl:param name="default-language" tunnel="yes"/>
  <xforms:label xml:lang="{if (@xml:lang) then @xml:lang else $default-language}">
    <xsl:value-of select="normalize-space(text())"/>
  </xforms:label>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="submission-actions-submit-done">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="namespace" tunnel="yes"/>
  <xsl:param name="tnsprefix" tunnel="yes"/>
  <xsl:param name="xroad-version" tunnel="yes"/>
  <xsl:choose>
    <xsl:when test="starts-with($operation, 'legacy')">
     <xsl:variable name="namespace-local" select="if($namespace) then $namespace else /wsdl:definitions/@targetNamespace"/>
      <!--xsl:apply-imports/-->
      <xforms:setvalue ref="instance('temp')/relevant" value="true()" events:event="xforms-submit-done"/>
      <xforms:load ref="instance('{$formname}.output')/SOAP-ENV:Body/{if ($namespace-local) then concat($tnsprefix, ':') else ''}{$operation}Response/{if ($xroad-version = 5 or $xroad-version = 6) then 'response' else 'keha'}/url" show="new" events:event="xforms-submit-done">
        <xsl:if test="$namespace-local">
          <xsl:namespace name="{$tnsprefix}" select="$namespace-local"/>
        </xsl:if>
      </xforms:load>
      <xforms:toggle case="{$formname}.response" events:event="xforms-submit-done" if="instance('{$formname}.output')/SOAP-ENV:Body/SOAP-ENV:Fault"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Back button label. -->
<xsl:template match="wsdl:binding/wsdl:operation/wsdl:output" mode="form-again-label">
  <xsl:if test="$debug"><xsl:message select="concat('form-again(xtee): ', name(), ', ', @message)"/></xsl:if>
  <xforms:label xml:lang="et">Uuesti</xforms:label>
  <xforms:label xml:lang="en">Again</xforms:label>
</xsl:template>

<!-- Label of Insert button for repeats. -->
<xsl:template match="xsd:element" mode="form-repeat-insert-label">
  <xsl:if test="$debug"><xsl:message select="concat('form-repeat-insert-label(xtee): ', name(), ', ', @name)"/></xsl:if>
  <xforms:label xml:lang="et">Lisa</xforms:label>
  <xforms:label xml:lang="en">Insert</xforms:label>
</xsl:template>

<!-- Label of Delete button for repeats. -->
<xsl:template match="xsd:element" mode="form-repeat-delete-label">
  <xsl:if test="$debug"><xsl:message select="concat('form-repeat-insert-label(xtee): ', name(), ', ', @name)"/></xsl:if>
  <xforms:label xml:lang="et">Kustuta</xforms:label>
  <xforms:label xml:lang="en">Delete</xforms:label>
</xsl:template>


<!-- If no data returned, show message. -->
<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="form-fault">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="tnsprefix" tunnel="yes"/>
  <xsl:param name="namespace" tunnel="yes"/>
  <xsl:param name="xroad-version" tunnel="yes"/>
<!--   <xsl:message select="concat('andmeid-ei-tulnud ns:', $namespace, ' xroad-version: ' , $xroad-version, ' tnsprefix: ', $tnsprefix)"/> -->
  
  <!-- Assuming in case document/literal style the wrapped pattern is used. -->
  <xforms:group ref="instance('{$formname}.output')/SOAP-ENV:Body/{if ($tnsprefix) then concat($tnsprefix, ':') else ''}{$operation}Response[{
	  if ($xroad-version = 4) then 'not(keha/*)' 
	   else if ($xroad-version = 5) then 'not(response/*)'
	   else 'if (keha) then not(keha/*) else if (response) then not(response/*) else not(*)'
  }]" class="info">
    <xsl:if test="$namespace">
      <xsl:namespace name="{$tnsprefix}" select="$namespace"/>
    </xsl:if>
    <xhtml:span xml:lang="et">Andmeid ei tulnud.</xhtml:span>
    <xhtml:span xml:lang="en">Service returned no data.</xhtml:span>
  </xforms:group>
  <!-- Print non-technical error message only with old X-tee version. Newer declarations should use document style where error message should be explicitly declared. -->
  <xsl:if test="$xroad-version &lt; 5">
    <xforms:group ref="instance('{$formname}.output')/SOAP-ENV:Body/{if ($namespace) then concat($tnsprefix, ':') else ''}{$operation}Response/{if ($xroad-version = 5 or $xroad-version = 6) then 'response' else 'keha'}/*[local-name() = 'faultString' or local-name() = 'faultstring']" class="info">
      <xsl:if test="$namespace">
        <xsl:namespace name="{$tnsprefix}" select="$namespace"/>
      </xsl:if>
      <xforms:output ref="."/>
    </xforms:group>
  </xsl:if>
  <xsl:apply-imports />
</xsl:template>

<!-- Titles and headings. -->

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:documentation/xtee:title | wsdl:portType/wsdl:operation/wsdl:documentation/xrd:title" mode="title">
  <xsl:param name="default-language" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('title(xtee): ', name())"/></xsl:if>
  <xhtml:title xml:lang="{if (@xml:lang) then @xml:lang else $default-language}">
    <xsl:value-of select="normalize-space(text())"/>
  </xhtml:title>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:documentation/xtee:title | wsdl:portType/wsdl:operation/wsdl:documentation/xrd:title" mode="heading">
  <xsl:param name="default-language" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('heading(xtee): ', name())"/></xsl:if>
  <xhtml:h1 xml:lang="{if (@xml:lang) then @xml:lang else $default-language}">
    <xsl:value-of select="normalize-space(text())"/>
  </xhtml:h1>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:documentation/xtee:notes | wsdl:portType/wsdl:operation/wsdl:documentation/xrd:notes" mode="heading help-only">
  <xsl:param name="default-language" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('heading(xtee): ', name())"/></xsl:if>
  <xforms:group class="help" xml:lang="{if (@xml:lang) then @xml:lang else $default-language}">
    <!-- HACK: disable-output-escaping allows using HTML in xtee:notes content. While there is no guarantee that 
         xtee:notes contains well-formed XML and it's not clear in what namespace those 
         elements are, it seems to work well enough in simple cases. -->
    <xsl:value-of select="replace(normalize-space(text()), '&amp;', '&amp;amp;')" disable-output-escaping="yes" />
  </xforms:group>
</xsl:template>

<!-- Lookup labels. -->

<xsl:template match="xsd:enumeration" mode="lookup-label">
  <xsl:variable name="label">
    <xsl:apply-templates mode="#current"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$label/*">
      <xsl:copy-of select="$label/*"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xtee:title | xrd:title" mode="lookup-label">
  <xsl:param name="default-language" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('lookup-label(xtee): ', name())"/></xsl:if>
  <label xml:lang="{if (@xml:lang) then @xml:lang else $default-language}" xmlns="">
    <xsl:value-of select="normalize-space(text())"/>
  </label>
</xsl:template>

<xsl:template match="xtee:notes | xrd:notes" mode="lookup-label">
  <xsl:param name="default-language" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('lookup-label(xtee): ', name())"/></xsl:if>
  <help xml:lang="{if (@xml:lang) then @xml:lang else $default-language}" xmlns="">
    <xsl:value-of select="normalize-space(text())"/>
  </help>
</xsl:template>

<xsl:template match="xsd:restriction" mode="itemset">
  <xforms:itemset nodeset="instance('lookup-{generate-id()}')/item">
    <xforms:label ref="label"/>
    <xforms:help ref="help"/>
    <xforms:value ref="@value"/>
  </xforms:itemset>
</xsl:template>

<xsl:template match="xsd:restriction" mode="form">
  <xsl:param name="node" tunnel="yes"/>
  <xsl:param name="ref" tunnel="yes"/>
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:choose>
    <!-- If there is enumeration inside then use label instead of value. -->
    <xsl:when test="xsd:enumeration and $formtype = 'output'">
      <xforms:group ref="{$ref}">
        <!-- Generate labels and hints. -->
        <xsl:apply-templates select="$node" mode="label"/>
        <xforms:output value="instance('lookup-{generate-id()}')/item[@value = current()]/label"/>
      </xforms:group>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Labels and hints. -->

<!-- Standard label for binary wsdl:part. -->
<xsl:template match="wsdl:part" mode="label">
  <xsl:variable name="qname" select="resolve-QName(@type, .)"/>
  <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
  <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>
  <xsl:if test="$namespace = 'http://www.w3.org/2001/XMLSchema' and $localname = ('base64Binary', 'hexBinary')">
    <xforms:label xml:lang="et">Lae alla</xforms:label>
    <xforms:label xml:lang="en">Download</xforms:label>
  </xsl:if>
</xsl:template>

<xsl:template match="xtee:title | xrd:title | xforms:label" mode="label label-only">
  <xsl:param name="default-language" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('label: ', name())"/></xsl:if>
  <xforms:label xml:lang="{if (@xml:lang) then @xml:lang else $default-language}">
    <xsl:value-of select="normalize-space(text())"/>
  </xforms:label>
</xsl:template>

<xsl:template match="xtee:notes | xrd:notes | xforms:help" mode="label">
  <xsl:param name="default-language" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('label: ', name())"/></xsl:if>
  <xforms:help xml:lang="{if (@xml:lang) then @xml:lang else $default-language}">
    <xsl:value-of select="normalize-space(text())"/>
  </xforms:help>
</xsl:template>

<xsl:template match="xtee:wildcard | xrd:wildcard" mode="label">
  <xsl:if test="$debug"><xsl:message select="concat('label: ', name())"/></xsl:if>
  <xforms:help xml:lang="et">Saab kasutada metamärke: <xsl:value-of select="normalize-space(text())"/></xforms:help>
  <xforms:help xml:lang="en">You can use wildcards: <xsl:value-of select="normalize-space(text())"/></xforms:help>
</xsl:template>

<xsl:template match="xforms:hint" mode="label">
  <xsl:param name="default-language" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('label: ', name())"/></xsl:if>
  <xforms:hint xml:lang="{if (@xml:lang) then @xml:lang else $default-language}">
    <xsl:value-of select="normalize-space(text())"/>
  </xforms:hint>
</xsl:template>

<xsl:template match="xforms:alert" mode="label">
  <xsl:param name="default-language" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('label: ', name())"/></xsl:if>
  <xforms:alert xml:lang="{if (@xml:lang) then @xml:lang else $default-language}">
    <xsl:value-of select="normalize-space(text())"/>
  </xforms:alert>
</xsl:template>

<xsl:template match="xsd:element | xsd:group | xsd:choice | xsd:sequence" mode="choice">
  <xsl:param name="choiceref" tunnel="yes"/>
  <xsl:param name="parentref" tunnel="yes"/>
  <xsl:param name="ref" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('choice (xtee): ', name(), ', ', @name)"/></xsl:if>
  <xsl:apply-imports>
    <xsl:with-param name="parentref" select="if ($ref = '.') then $parentref else concat($parentref, '/', $ref)" tunnel="yes"/>
    <xsl:with-param name="ref" select="concat($choiceref, '/', generate-id())" tunnel="yes"/>
  </xsl:apply-imports>
</xsl:template>

<xsl:template match="xsd:annotation/xsd:appinfo/xtee:appearance | xsd:annotation/xsd:appinfo/xrd:appearance" mode="appearance">
  <xsl:if test="$debug"><xsl:message select="concat('label(xtee): ', name())"/></xsl:if>
  <xsl:attribute name="appearance"><xsl:value-of select="." /></xsl:attribute>
</xsl:template>

<xsl:template match="xsd:annotation/xsd:appinfo/xtee:inputmode | xsd:annotation/xsd:appinfo/xrd:inputmode" mode="appearance">
  <xsl:if test="$debug"><xsl:message select="concat('label(xtee): ', name())"/></xsl:if>
  <xsl:attribute name="inputmode"><xsl:value-of select="." /></xsl:attribute>
</xsl:template>

<xsl:template match="xsd:annotation/xsd:appinfo/xtee:selection | xsd:annotation/xsd:appinfo/xtee:selection" mode="appearance">
  <xsl:if test="$debug"><xsl:message select="concat('label(xtee): ', name())"/></xsl:if>
  <xsl:attribute name="selection"><xsl:value-of select="." /></xsl:attribute> 
</xsl:template>

<xsl:template match="xsd:annotation/xsd:appinfo" mode="appearance">
  <xsl:if test="$debug"><xsl:message select="concat('label(xtee): ', name())"/></xsl:if>
  <xsl:variable name="style">
    <xsl:apply-templates mode="style"/>
  </xsl:variable>
  <xsl:if test="$style != ''">
    <xsl:attribute name="style" select="$style"/>
  </xsl:if>
  <xsl:apply-imports/>
</xsl:template>

<xsl:template match="xtee:fieldsize | xrd:fieldsize" mode="style">width: <xsl:value-of select="if (. &gt; 10) then . div 2 else ."/>em;</xsl:template>
<xsl:template match="xtee:fieldcols | xrd:fieldcols" mode="style">width: <xsl:value-of select="if (. &gt; 10) then . div 2 else ."/>em;</xsl:template>
<xsl:template match="xtee:fieldrows | xrd:fieldrows" mode="style">height: <xsl:value-of select="."/>em;</xsl:template>

<!-- Ignore xsd:documentation elements that are matched in schema2xforms.xsl. -->
<xsl:template match="xsd:documentation" mode="label label-only title heading"/>

</xsl:stylesheet>
