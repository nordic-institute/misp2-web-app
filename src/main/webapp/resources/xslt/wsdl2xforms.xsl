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
    xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/"
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
    exclude-result-prefixes="wsdl soap mime">
<xsl:import href="schema2xforms.xsl"/>
<xsl:import href="wsdltraverse.xsl"/>
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" /> 

<!-- Integer marking X-Road version: 6 for v6, 5 for v5, 1 for earlier (v4) -->
<xsl:param name="xroad-version"/>

<!-- URL for showing the XML content of request. -->
<xsl:param name="debugurl"/>
<!-- URL for showing the XML content of response. -->
<xsl:param name="urlxml"/>
<!-- Operation names xforms are generated for, other operations should be skipped -->
<xsl:param name="operation-names"/>

<!-- URL for submit. -->
<xsl:param name="url"/>
<!-- Name of the operation in WSDL to generate form for. -->
<xsl:param name="operation"/>

<!-- Debug flag. -->
<xsl:param name="debug" select="false()"/>

<!-- Strict processing flag. -->
<xsl:param name="strict" select="false()"/>

<xsl:template match="wsdl:binding">
  <xsl:if test="$debug"><xsl:message select="concat('binding: ', name(), ', ', @name)"/></xsl:if>
  <xsl:if test="$strict and soap:binding/@transport != 'http://schemas.xmlsoap.org/soap/http'">
    <xsl:message terminate="yes" select="concat('SOAP transport is not HTTP in binding ', @name, '.')" />
  </xsl:if>
  <xsl:apply-imports/>
</xsl:template>

<!-- File generation. -->

<xsl:template match="wsdl:binding/wsdl:operation">
  <!-- Default file name is operation.xhtml, but this can be changed by importing template. -->
  <xsl:param name="filename" select="concat(@name, '.xhtml')" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('binding: ', name(), ', ', @name)"/></xsl:if>
  <!-- While SOAPAction is required for HTTP binding by WSDL specification. -->
  <xsl:if test="$strict and not(soap:operation/@soapAction)">
    <xsl:message terminate="yes" select="concat('SOAPAction not specified for operation ', @name, '.')" />
  </xsl:if>
  <xsl:if test="$debug">
    <xsl:message select="concat('Operation: ', $operation, ' Current operation: ', @name, ' Allowed: ', $operation-names)" />
  </xsl:if>
  <!-- Global parameter $operation allows rendering of just one form. -->
  <xsl:if test="$operation = '' or @name = $operation">
  	<!-- If global parameter $operation-names is given, 
  		 only generate output for operations contained in $operation-names.
  		 $operation-names is a comma-separated list of WSDL operation names.
  		 Test if @name is in $operation-names with XPath functions. -->
    <xsl:if test="$operation-names != '' and
                    ($operation-names = @name or 
                     starts-with (  $operation-names, concat(     @name, ',')) or
                     ends-with   (  $operation-names, concat(',', @name     )) or
                     contains    (  $operation-names, concat(',', @name, ','))
                    )">
      <xsl:if test="$debug">
        <xsl:message select="concat('Generating output file for operation: ', @name, '.')" />
      </xsl:if>
      <xsl:result-document href="{$filename}">
        <xsl:apply-templates select="." mode="document">
          <xsl:with-param name="formname" select="@name" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:result-document>
    </xsl:if>
  </xsl:if>
</xsl:template>

<!-- Document generation. -->

<xsl:template match="wsdl:binding/wsdl:operation" mode="document">
  <xsl:if test="$debug"><xsl:message select="concat('portType: ', name(), ', ', @name)"/></xsl:if>
  <xhtml:html>
    <xsl:namespace name="tns" select="/wsdl:definitions/@targetNamespace" />
    <xsl:apply-templates select="." mode="html">
      <xsl:with-param name="tnsprefix" select="'tns'" tunnel="yes"/>
    </xsl:apply-templates>
  </xhtml:html>
</xsl:template>

<!-- Html generation. -->

<xsl:template match="wsdl:binding/wsdl:operation" mode="html">
  <xsl:if test="$debug"><xsl:message select="concat('html: ', name(), ', ', @name)"/></xsl:if>
  <xhtml:head>
    <xsl:apply-templates select="." mode="head" />
  </xhtml:head>
  <xhtml:body>
    <xsl:apply-templates select="." mode="body" />
  </xhtml:body>
</xsl:template>

<!-- Head generation. -->

<xsl:template match="wsdl:binding/wsdl:operation" mode="head">
  <xsl:if test="$debug"><xsl:message select="concat('head: ', name(), ', ', @name)"/></xsl:if>
  <!-- Allow extensions to set their own title. -->
  <xsl:apply-templates select="." mode="title" />
  <xforms:model>
    <xsl:apply-templates select="." mode="model" />
  </xforms:model>
</xsl:template>

<!-- Body generation. -->

<xsl:template match="wsdl:binding/wsdl:operation" mode="body">
  <xsl:if test="$debug"><xsl:message select="concat('body: ', name(), ', ', @name)"/></xsl:if>
  <!-- Allow extensions to set their own heading. -->
  <xsl:apply-templates select="." mode="heading"/>
  <xforms:switch>
    <xsl:apply-templates select="." mode="form"/>
  </xforms:switch>
</xsl:template>

<!-- Model generation. -->

<xsl:template match="wsdl:binding/wsdl:operation" mode="model">
  <xsl:if test="$debug"><xsl:message select="concat('model: ', name(), ', ', @name)"/></xsl:if>
  <!-- Generate instances. -->
  <xsl:apply-templates select="." mode="instance" />
  <!-- Generate lookup instances. -->
  <xsl:apply-templates select="." mode="lookup" />
  <!-- Generate bindings. -->
  <xsl:apply-templates select="." mode="bind" />
  <!-- Generate submission and events. -->
  <xsl:apply-templates select="." mode="submission" />
  <!-- Generate various helpers. -->
  <xsl:apply-templates select="." mode="helpers" />
  <!-- Generate event to activate first case. -->
  <xsl:apply-templates select="." mode="activate" />
</xsl:template>

<!-- Instance generation. -->

<xsl:template match="wsdl:binding/wsdl:operation" mode="helpers">
  <xsl:if test="$debug"><xsl:message select="concat('instance: ', name(), ', ', @name)"/></xsl:if>
  <xsl:apply-imports/>
  <!-- Generate helper instance. -->
  <xsl:call-template name="createTempInstance"/>
</xsl:template>

<xsl:template match="wsdl:binding/wsdl:operation/wsdl:input" mode="instance">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('instance: ', name(), ', ', @message)"/></xsl:if>
  <xforms:instance id="{$formname}.input">
    <xsl:apply-imports/>
  </xforms:instance>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:input" mode="instance">
  <xsl:param name="style" tunnel="yes"/>
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="tnsprefix" tunnel="yes"/>
  <xsl:param name="namespace" tunnel="yes"/>
  <xsl:param name="use" tunnel="yes"/>
  <xsl:param name="encodingStyle" tunnel="yes"/>
  <SOAP-ENV:Envelope>
    <xsl:if test="$use = 'encoded'">
      <xsl:attribute name="SOAP-ENV:encodingStyle" select="$encodingStyle"/>
    </xsl:if>
    <SOAP-ENV:Header>
      <xsl:apply-templates select="." mode="instance-soap-header"/>
    </SOAP-ENV:Header>
    <SOAP-ENV:Body>
      <xsl:choose>
        <xsl:when test="$style = 'rpc'">
          <xsl:choose>
            <xsl:when test="$namespace">
              <xsl:element name="{$tnsprefix}:{$operation}" namespace="{$namespace}">
                <xsl:apply-imports/>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="{$operation}">
                <xsl:apply-imports/>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$style = 'document'">
          <xsl:apply-imports/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$strict">
            <xsl:message terminate="yes" select="concat('Unknown operation style: ', $style)" />
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </SOAP-ENV:Body>
  </SOAP-ENV:Envelope>
</xsl:template>

<xsl:template match="xsd:element" mode="type">
  <xsl:param name="use" tunnel="yes"/>
  <xsl:param name="tnsprefix" tunnel="yes"/>
  <!-- Add xsi:type attribute element when using encoded style. -->
  <xsl:if test="@type and $use = 'encoded'">
    <!-- Resolve type name. -->
    <xsl:variable name="qname" select="resolve-QName(@type, .)"/>
    <xsl:variable name="typename" select="local-name-from-QName($qname)"/>
    <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>
    <xsl:choose>
      <!-- If schema type, then add xsi:type attribute. -->
      <xsl:when test="$namespace = 'http://www.w3.org/2001/XMLSchema'">
        <xsl:attribute name="type" select="concat('xsd:',$typename)" namespace="http://www.w3.org/2001/XMLSchema-instance" />
      </xsl:when>
      <!-- Otherwise add both type and namespace. -->
      <xsl:otherwise>
        <xsl:namespace name="{$tnsprefix}" select="$namespace"/>
        <xsl:attribute name="type" select="concat($tnsprefix,':',$typename)" namespace="http://www.w3.org/2001/XMLSchema-instance" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="wsdl:binding/wsdl:operation/wsdl:output" mode="instance">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('instance: ', name(), ', ', @message)"/></xsl:if>
  <xforms:instance id="{$formname}.output">
    <xsl:apply-imports/>
  </xforms:instance>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="instance">
  <!-- Response instance is initially empty. -->
  <dummy/>
</xsl:template>

<xsl:template match="wsdl:part" mode="instance">
  <xsl:if test="$debug"><xsl:message select="concat('instance: ', name(), ', ', @name)"/></xsl:if>
  <xsl:choose>
    <xsl:when test="@type">
      <xsl:element name="{@name}" namespace="">
        <xsl:apply-imports/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@element">
      <xsl:apply-imports/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="/" mode="instance">
  <xsl:param name="name" />
  <xsl:param name="what" />
  <xsl:param name="context" />
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('instance: ', $name, ', ', $what)"/></xsl:if>

  <xsl:variable name="qname" select="resolve-QName($name, $context)"/>
  <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
  <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>

	
  <xsl:if test="$debug"><xsl:message select="concat('ends-with($what, Type): ', ends-with($what, 'Type'), ' | ', '$localname = Array', $localname, ' | ' , '$namespace = http://schemas.xmlsoap.org/soap/encoding/', $namespace)"/></xsl:if>

  <xsl:choose>
    <!-- In case of Array type add it directly, don't resolve. -->
    <xsl:when test="ends-with($what, 'Type') and $localname = 'Array' and $namespace = 'http://schemas.xmlsoap.org/soap/encoding/'">
      <xsl:if test="$formtype = 'input'">
	     <!-- legacy services fail with empty SOAP-ENC:arrayType attribute -->
      	<xsl:if test="$localname != 'Array'">
	        <xsl:attribute name="type" select="concat('SOAP-ENC:',$localname)" namespace="http://www.w3.org/2001/XMLSchema-instance" />
	        <!-- The value of arrayType attribute is calculated by binding (actually it is not). -->
	        <xsl:attribute name="arrayType" namespace="http://schemas.xmlsoap.org/soap/encoding/" />
        </xsl:if>
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

<!-- Lookup instance generation. -->

<!-- Additional step to generate only distinct instances. -->
<xsl:template match="wsdl:binding/wsdl:operation" mode="lookup">
  <xsl:variable name="instances">
    <xsl:apply-imports/>
  </xsl:variable>
  <xsl:copy-of select="$instances/xforms:instance[not(@id = preceding-sibling::xforms:instance/@id)]"/>
</xsl:template>

<!-- Submission generation. -->

<!-- Using wsdl:portType/wsdl:operation/wsdl:output for submission generation
     because xtee2xforms and complex2xforms require access to namespace of output
     operation and this is the only place where it is available without a hassle.
     TODO: I don't like that submission is generated in different context than submit button. -->
<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="submission">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="location" tunnel="yes"/>
  <xsl:param name="soapAction" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('submission: ', name(), ', ', @name)"/></xsl:if>
  <xforms:submission id="{$formname}.submission" action="{if ($url) then $url else $location}" mediatype="application/soap+xml; charset=UTF-8{if ($soapAction) then concat('; action=', $soapAction) else ''}" encoding="UTF-8" ref="instance('{$formname}.input')" method="post" replace="instance" instance="{$formname}.output">
    <xsl:apply-templates select="." mode="submission-actions" />
  </xforms:submission>
  <xsl:if test="$debugurl">
    <xforms:submission id="{$formname}.debug" action="{$debugurl}" mediatype="text/xml" ref="instance('{$formname}.input')" method="post" replace="all" validate="false">
      <xsl:apply-templates select="." mode="submission-actions" />
    </xforms:submission>
  </xsl:if>
  <xsl:if test="$urlxml">
    <xforms:submission id="{$formname}.savexml" action="{$urlxml}" mediatype="text/xml" ref="instance('{$formname}.output')" method="post" replace="all"/>
  </xsl:if>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="submission-actions">
  <xsl:if test="$debug"><xsl:message select="concat('submission-actions: ', name(), ', ', @name)"/></xsl:if>
  <xsl:apply-templates select="." mode="submission-actions-submit" />
  <xsl:apply-templates select="." mode="submission-actions-submit-done" />
  <xsl:apply-templates select="." mode="submission-actions-submit-error" />
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="submission-actions-submit">
  <xsl:if test="$debug"><xsl:message select="concat('submission-actions-submit: ', name(), ', ', @name)"/></xsl:if>
  <xforms:setvalue ref="instance('temp')/relevant" value="false()" events:event="xforms-submit"/>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="submission-actions-submit-done">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('submission-actions-submit-done: ', name(), ', ', @name)"/></xsl:if>
  <!-- Must be done at this level, because of deferred updates. -->
  <!-- Otherwise nonrelevant fields are not submitted. -->
  <xforms:toggle case="{$formname}.response" events:event="xforms-submit-done"/>
  <xforms:setvalue ref="instance('temp')/relevant" value="true()" events:event="xforms-submit-done"/>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="submission-actions-submit-error">
  <xsl:if test="$debug"><xsl:message select="concat('submission-actions-submit-error: ', name(), ', ', @name)"/></xsl:if>
  <xforms:setvalue ref="instance('temp')/relevant" value="true()" events:event="xforms-submit-error"/>
  <!-- Must be done at this level, because of deferred updates. -->
  <!-- Otherwise nonrelevant fields are not shown while error message is displayed. -->
  <xforms:message level="modal" events:event="xforms-submit-error">
    <xsl:apply-templates select="." mode="submission-actions-submit-error-message" />
  </xforms:message>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="submission-actions-submit-error-message">Submit error (<xforms:output value="event('error-type')" />).</xsl:template>

<!-- Bindings generation. -->

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:input" mode="bind">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="tnsprefix" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="namespace" tunnel="yes"/>
  <xsl:param name="style" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('bind: ', name(), ', ', @message)"/></xsl:if>
  <xforms:bind nodeset="instance('{$formname}.input')/SOAP-ENV:Body{if ($style = 'rpc') then if ($namespace) then concat('/', $tnsprefix, ':', $operation) else concat('/', $operation) else ''}">
    <xsl:if test="$style = 'rpc' and $namespace">
      <xsl:namespace name="{$tnsprefix}" select="$namespace"/>
    </xsl:if>
    <xsl:apply-imports/>
  </xforms:bind>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="bind">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="tnsprefix" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="namespace" tunnel="yes"/>
  <xsl:param name="style" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('bind: ', name(), ', ', @message)"/></xsl:if>
  <xforms:bind nodeset="instance('{$formname}.output')/SOAP-ENV:Body{if ($style = 'rpc') then if ($namespace) then concat('/', $tnsprefix, ':', $operation, 'Response') else concat('/', $operation, 'Response') else ''}">
    <xsl:if test="$style = 'rpc' and $namespace">
      <xsl:namespace name="{$tnsprefix}" select="$namespace"/>
    </xsl:if>
    <xsl:apply-imports/>
  </xforms:bind>
</xsl:template>

<xsl:template match="wsdl:part" mode="bind">
  <xsl:if test="$debug"><xsl:message select="concat('bind: ', name(), ', ', @name)"/></xsl:if>
  <xsl:choose>
    <xsl:when test="@type">
      <xforms:bind nodeset="{@name}">
        <xsl:apply-imports/>
      </xforms:bind>
    </xsl:when>
    <xsl:when test="@element">
      <xsl:apply-imports/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="/" mode="bind">
  <xsl:param name="name" />
  <xsl:param name="what" />
  <xsl:param name="context" />
  <xsl:param name="formtype" tunnel="yes" />
  <xsl:if test="$debug"><xsl:message select="concat('bind: ', $name, ', ', $what)"/></xsl:if>

  <xsl:variable name="qname" select="resolve-QName($name, $context)"/>
  <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
  <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>

  <xsl:choose>
    <xsl:when test="ends-with($what, 'Type') and $localname = 'Array' and $namespace = 'http://schemas.xmlsoap.org/soap/encoding/'">
      <xsl:if test="$formtype = 'input' and not($context/xsd:sequence/xsd:element)">
      	<xsl:message  select="concat('Element xsd:restriction under complexType ', $context/../../@name, ' does not contain xsd:sequence/xsd:element, but this is assumed for array type. Ignoring xforms bind.')" />
      </xsl:if>
      <xsl:if test="$formtype = 'input' and $context/xsd:sequence/xsd:element">
        <xsl:variable name="qname" select="resolve-QName($context/xsd:sequence/xsd:element/@type, $context/xsd:sequence/xsd:element)"/>
        <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
        <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>

        <!-- Calculate count of nodes into arrayType attribute. -->
        <!-- Subtract 3: insert-trigger, delete-trigger and prototype item. -->
        <xforms:bind nodeset="@SOAP-ENC:arrayType" calculate="concat('{if ($namespace = 'http://www.w3.org/2001/XMLSchema') then concat('xsd:', $localname) else if ($namespace != '') then concat('tns:', $localname) else 'xsd:anyType'}[',count(../*) - 1,']')">
          <xsl:if test="$namespace != 'http://www.w3.org/2001/XMLSchema' and $namespace != ''">
            <xsl:namespace name="tns" select="$namespace" />
          </xsl:if>
        </xforms:bind>
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

<!-- Activation generation. -->

<xsl:template match="wsdl:binding/wsdl:operation" mode="activate">
  <xsl:param name="formname" tunnel="yes"/>
  <!-- Causes xforms-select event, which is not occurring by default. -->
  <xforms:dispatch targetid="{$formname}.request" name="xforms-select" events:event="xforms-ready" />
</xsl:template>

<!-- Form generation. -->

<xsl:template match="wsdl:binding/wsdl:operation/wsdl:input" mode="form">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form: ', name())"/></xsl:if>
  <xforms:case id="{$formname}.request">
    <!-- Hook for complex2xforms.xsl -->
    <xsl:apply-templates select="." mode="form-heading"/>
    <xsl:apply-imports/>
    <xforms:group class="actions">
      <xsl:apply-templates select="." mode="form-actions"/>
    </xforms:group>
  </xforms:case>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:input" mode="form">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="tnsprefix" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="namespace" tunnel="yes"/>
  <xsl:param name="style" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form: ', name(), ', ', @message)"/></xsl:if>
  <xforms:group ref="instance('{$formname}.input')/SOAP-ENV:Body{if ($style = 'rpc') then if ($namespace) then concat('/', $tnsprefix, ':', $operation) else concat('/', $operation) else ''}">
    <xsl:if test="$style = 'rpc' and $namespace">
      <xsl:namespace name="{$tnsprefix}" select="$namespace"/>
    </xsl:if>
    <xsl:apply-imports>
      <xsl:with-param name="parentref" tunnel="yes"/>
      <xsl:with-param name="ref" select="'.'" tunnel="yes"/>
    </xsl:apply-imports>
  </xforms:group>
</xsl:template>

<xsl:template match="wsdl:binding/wsdl:operation/wsdl:input" mode="form-actions">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form-actions: ', name())"/></xsl:if>
  <xforms:submit submission="{$formname}.submission">
    <xsl:apply-templates select="." mode="form-submit"/>
  </xforms:submit>
  <xsl:if test="$debugurl">
    <xforms:submit submission="{$formname}.debug">
      <xforms:label>Debug</xforms:label>
    </xforms:submit>
  </xsl:if>
</xsl:template>

<xsl:template match="wsdl:binding/wsdl:operation/wsdl:input" mode="form-submit">
  <xsl:if test="$debug"><xsl:message select="concat('form-submit: ', name())"/></xsl:if>
  <xforms:label>
    <xsl:apply-templates select="." mode="form-submit-label"/>
  </xforms:label>
</xsl:template>

<xsl:template match="wsdl:binding/wsdl:operation/wsdl:input" mode="form-submit-label">Submit</xsl:template>

<xsl:template match="wsdl:binding/wsdl:operation/wsdl:output" mode="form">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form: ', name())"/></xsl:if>
  <xforms:case id="{$formname}.response">
    <!-- Hook for xtee2xforms.xsl -->
    <xsl:apply-templates select="." mode="form-heading"/>
    <xsl:apply-imports/>
    <xsl:apply-templates select="." mode="form-fault"/>
    <xforms:group class="actions">
      <xsl:apply-templates select="." mode="form-actions"/>
    </xforms:group>
  </xforms:case>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="form">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:param name="tnsprefix" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="namespace" tunnel="yes"/>
  <xsl:param name="style" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form: ', name(), ', ', @message)"/></xsl:if>
  <xforms:group ref="instance('{$formname}.output')/SOAP-ENV:Body{if ($style = 'rpc') then if ($namespace) then concat('/', $tnsprefix, ':', $operation, 'Response') else concat('/', $operation, 'Response') else ''}">
    <xsl:if test="$style = 'rpc' and $namespace">
      <xsl:namespace name="{$tnsprefix}" select="$namespace"/>
    </xsl:if>
    <xsl:apply-imports>
      <xsl:with-param name="parentref" tunnel="yes"/>
      <xsl:with-param name="ref" select="'.'" tunnel="yes"/>
    </xsl:apply-imports>
  </xforms:group>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:output" mode="form-fault">
  <xsl:param name="formname" tunnel="yes" />
  <xforms:group ref="{concat('instance(''', $formname, '.output'')')}/SOAP-ENV:Body/SOAP-ENV:Fault" class="fault">
    <xforms:output ref="faultstring"/>
  </xforms:group>
</xsl:template>

<xsl:template match="wsdl:binding/wsdl:operation/wsdl:output" mode="form-actions">
  <xsl:param name="formname" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form-actions: ', name(), ', ', @message)"/></xsl:if>
  <xforms:trigger>
    <xsl:apply-templates select="." mode="form-again-label"/>
    <xforms:toggle events:event="DOMActivate" case="{$formname}.request"/>
  </xforms:trigger>
  <xsl:if test="$urlxml">
    <xforms:submit submission="{$formname}.savexml">
      <xforms:label>Show XML</xforms:label>
    </xforms:submit>
  </xsl:if>
</xsl:template>

<xsl:template match="wsdl:binding/wsdl:operation/wsdl:output" mode="form-again-label">
  <xsl:if test="$debug"><xsl:message select="concat('form-again: ', name(), ', ', @message)"/></xsl:if>
  <xforms:label>Back</xforms:label>
</xsl:template>

<xsl:template match="wsdl:part" mode="form">
  <xsl:if test="$debug"><xsl:message select="concat('form: ', name(), ', ', @name)"/></xsl:if>
  <xsl:choose>
    <xsl:when test="@type">
      <xsl:apply-imports>
        <xsl:with-param name="node" select="." tunnel="yes"/>
        <xsl:with-param name="ref" select="@name" tunnel="yes"/>
      </xsl:apply-imports>
    </xsl:when>
    <xsl:when test="@element">
      <xsl:apply-imports>
        <xsl:with-param name="node" select="." tunnel="yes"/>
      </xsl:apply-imports>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="xsd:restriction | xsd:extension" mode="form bind">
  <xsl:param name="element" tunnel="yes"/>
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('form: ', name(), ', ', @base)"/></xsl:if>

  <xsl:variable name="qname" select="resolve-QName(@base, .)"/>
  <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
  <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>

  <!-- Resolve type/element/attribute. -->
  <xsl:apply-imports>
    <!-- Array elements can have any name. To cope with that, use * on output forms. -->
    <!-- Input forms must use element name, otherwise insert-trigger and delete-trigger
         elements would be considered rows too. -->
    <xsl:with-param name="element" select="if ($localname = 'Array' and $namespace = 'http://schemas.xmlsoap.org/soap/encoding/' and $formtype = 'output') then '*' else $element" tunnel="yes"/>
  </xsl:apply-imports>
</xsl:template>

<xsl:template match="/" mode="form">
  <xsl:param name="name" />
  <xsl:param name="what" />
  <xsl:param name="context" />
  <xsl:if test="$debug"><xsl:message select="concat('form: ', $name, ', ', $what)"/></xsl:if>

  <xsl:variable name="qname" select="resolve-QName($name, $context)"/>
  <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
  <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>

  <xsl:choose>
    <xsl:when test="ends-with($what, 'Type') and $localname = 'Array' and $namespace = 'http://schemas.xmlsoap.org/soap/encoding/'">
      <!-- Ignore Array type. -->      
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

<!-- Only take heading and title from  operation's description, not anywhere else. -->
<xsl:template match="xsd:element | xsd:attribute | xsd:group | xsd:enumeration | xsd:simpleType | xsd:complexType" mode="title heading" />

</xsl:stylesheet>
