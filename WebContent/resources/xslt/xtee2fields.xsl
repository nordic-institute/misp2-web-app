<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
    xmlns:xtee="http://x-tee.riik.ee/xsd/xtee.xsd">
<xsl:import href="schematraverse.xsl"/>
<xsl:import href="wsdltraverse.xsl"/>
<xsl:import href="xteetraverse.xsl"/>
<xsl:output method="text" encoding="UTF-8" /> 

<xsl:template match="/">
  <xsl:apply-templates select="/wsdl:definitions/wsdl:service" mode="fields"/>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:input | wsdl:portType/wsdl:operation/wsdl:output" mode="fields">
  <xsl:param name="producer" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="version" tunnel="yes"/>
  <!-- Default file name is operation.txt, but this can be changed by importing template. -->
  <xsl:variable name="filename" select="concat($producer, '/', $operation, '.', $version, '.', local-name(), '.txt')"/>
  <xsl:if test="$debug"><xsl:message select="concat('fields: ', name(), ', ', @message)"/></xsl:if>
  <xsl:if test="not($operation = ('listMethods', 'loadClassificators', 'getCharge')) and @message != ''">
    <xsl:result-document href="{$filename}">
      <xsl:apply-imports/>
    </xsl:result-document>
  </xsl:if>
</xsl:template>

<xsl:template match="wsdl:part[@name = 'keha']" mode="fields">
  <xsl:param name="path" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('fields: ', name(), ', ', @name)"/></xsl:if>
  <xsl:if test="@type">
    <xsl:value-of select="concat($path, '/', @name)"/>
    <xsl:text>
</xsl:text>
  </xsl:if>
  <xsl:apply-imports>
    <xsl:with-param name="path" select="if (@type) then concat($path, '/', @name) else $path" tunnel="yes"/>
  </xsl:apply-imports>
</xsl:template>

<xsl:template match="wsdl:part[@name != 'keha']" mode="fields"/>

<xsl:template match="xsd:restriction | xsd:extension" mode="fields">
  <xsl:param name="formtype" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('fields: ', name(), ', ', @base)"/></xsl:if>

  <xsl:variable name="qname" select="resolve-QName(@base, .)"/>
  <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
  <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>

  <!-- Resolve type/element/attribute. -->
  <xsl:apply-imports>
    <!-- Array elements can have any name. To cope with that, use * on output forms. -->
    <xsl:with-param name="element" select="if ($localname = 'Array' and $namespace = 'http://schemas.xmlsoap.org/soap/encoding/' and $formtype = 'output') then '*' else ''" tunnel="yes"/>
  </xsl:apply-imports>
</xsl:template>

<xsl:template match="xsd:element" mode="fields">
  <xsl:param name="path" tunnel="yes"/>
  <xsl:param name="element" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('fields: ', name(), ', ', @name)"/></xsl:if>
  <xsl:variable name="name" select="if ($element != '') then $element else @name"/>
  <xsl:value-of select="concat($path, '/', $name)"/>
  <xsl:text>
</xsl:text>
  <xsl:apply-imports>
    <xsl:with-param name="path" select="concat($path, '/', $name)" tunnel="yes"/>
    <xsl:with-param name="element" tunnel="yes"/>
  </xsl:apply-imports>
</xsl:template>

</xsl:stylesheet>
