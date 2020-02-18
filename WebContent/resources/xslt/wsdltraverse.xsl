<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
    xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
    xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/"
    exclude-result-prefixes="wsdl soap mime">
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" /> 

<!-- Debug flag. -->
<xsl:param name="debug" select="false()"/>

<xsl:template match="/">
  <xsl:if test="$debug"><xsl:message select="'traverse: root'"/></xsl:if>
  <xsl:apply-templates select="/wsdl:definitions/wsdl:service"/>
</xsl:template>

<xsl:template match="wsdl:service" mode="#all">
  <xsl:if test="$debug"><xsl:message select="concat('traverse: ', name(), ', ', @name)"/></xsl:if>
  <xsl:apply-templates mode="#current">
    <xsl:with-param name="service" select="@name" tunnel="yes"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="wsdl:port" mode="#all">
  <xsl:if test="$debug"><xsl:message select="concat('traverse: ', name(), ', ', @name)"/></xsl:if>
  <xsl:variable name="qname" select="resolve-QName(@binding, .)"/>
  <xsl:variable name="binding" select="local-name-from-QName($qname)"/>
  <xsl:apply-templates select="/wsdl:definitions/wsdl:binding[@name = $binding]" mode="#current">
    <xsl:with-param name="binding" select="$binding" tunnel="yes"/>
    <xsl:with-param name="location" select="soap:address/@location" tunnel="yes"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="wsdl:binding" mode="#all">
  <xsl:if test="$debug"><xsl:message select="concat('traverse: ', name(), ', ', @name)"/></xsl:if>
  <xsl:variable name="qname" select="resolve-QName(@type, .)"/>
  <xsl:variable name="portType" select="local-name-from-QName($qname)"/>
  <xsl:apply-templates mode="#current">
    <xsl:with-param name="portType" select="$portType" tunnel="yes"/>
    <xsl:with-param name="style" select="if (soap:binding/@style != '') then soap:binding/@style else 'document'" tunnel="yes"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="wsdl:binding/wsdl:operation" mode="#all">
  <xsl:param name="portType" tunnel="yes" />
  <xsl:param name="style" tunnel="yes" />
  <xsl:if test="$debug"><xsl:message select="concat('traverse: ', name(), ', ', @name)"/></xsl:if>
  <xsl:variable name="operation" select="@name"/>
  <xsl:apply-templates select="/wsdl:definitions/wsdl:portType[@name=$portType]/wsdl:operation[@name=$operation][1]" mode="#current">
    <xsl:with-param name="operation" select="$operation" tunnel="yes"/>
  </xsl:apply-templates>
  <xsl:apply-templates mode="#current">
    <xsl:with-param name="operation" select="$operation" tunnel="yes"/>
    <xsl:with-param name="style" select="if (soap:operation/@style != '') then soap:operation/@style else $style" tunnel="yes"/>
    <xsl:with-param name="soapAction" select="soap:operation/@soapAction" tunnel="yes"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation" mode="#all">
  <xsl:if test="$debug"><xsl:message select="concat('traverse: ', name(), ', ', @name)"/></xsl:if>
  <!-- Only traverse documentation element, input and output will be traversed later. -->
  <xsl:apply-templates select="wsdl:documentation" mode="#current"/>
</xsl:template>

<xsl:template match="wsdl:binding/wsdl:operation/wsdl:input | wsdl:binding/wsdl:operation/wsdl:output" mode="#all">
  <xsl:param name="portType" tunnel="yes" />
  <xsl:param name="operation" tunnel="yes" />
  <xsl:if test="$debug"><xsl:message select="concat('traverse: ', name())"/></xsl:if>
  <xsl:apply-templates select="/wsdl:definitions/wsdl:portType[@name=$portType]/wsdl:operation[@name=$operation][1]/wsdl:*[local-name() = current()/local-name()]" mode="#current">
    <xsl:with-param name="formtype" select="local-name()" tunnel="yes"/>
    <xsl:with-param name="body_parts" select="(. | mime:multipartRelated/mime:part)/soap:body/@part" tunnel="yes"/>
    <xsl:with-param name="mime_parts" select="(. | mime:multipartRelated/mime:part)/mime:content/@part" tunnel="yes"/>
    <xsl:with-param name="namespace" select="((. | mime:multipartRelated/mime:part)/soap:body/@namespace)[1]" tunnel="yes"/>
    <xsl:with-param name="use" select="((. | mime:multipartRelated/mime:part)/soap:body/@use)[1]" tunnel="yes"/>
    <xsl:with-param name="encodingStyle" select="((. | mime:multipartRelated/mime:part)/soap:body/@encodingStyle)[1]" tunnel="yes"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="wsdl:portType/wsdl:operation/wsdl:input | wsdl:portType/wsdl:operation/wsdl:output" mode="#all">
  <xsl:if test="$debug"><xsl:message select="concat('traverse: ', name(), ', ', @message)"/></xsl:if>
  <xsl:variable name="qname" select="resolve-QName(@message, .)"/>
  <xsl:variable name="localname" select="local-name-from-QName($qname)"/>
  <xsl:variable name="namespace" select="namespace-uri-from-QName($qname)"/>
  <xsl:apply-templates select="/wsdl:definitions/wsdl:message[@name = $localname]" mode="#current" />
</xsl:template>

<xsl:template match="wsdl:message" mode="#all">
  <xsl:param name="body_parts" tunnel="yes"/>
  <xsl:param name="mime_parts" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('traverse: ', name(), ', ', @name)"/></xsl:if>
  <!-- NB! $mime_parts could be sequence, that's why not() construct is used instead of !=. -->
  <xsl:apply-templates select="*[(not($body_parts) or $body_parts = '*' or @name = tokenize($body_parts, '\s+')) and not(@name = $mime_parts)]" mode="#current" />
</xsl:template>

<xsl:template match="wsdl:part" mode="#all">
  <xsl:param name="style" tunnel="yes" />
  <xsl:if test="$debug"><xsl:message select="concat('traverse: ', name(), ', ', @name)"/></xsl:if>
  <xsl:choose>
    <xsl:when test="@type">
      <xsl:apply-templates select="/" mode="#current">
        <xsl:with-param name="name" select="@type"/>
        <xsl:with-param name="what" select="'(simple|complex)Type'"/>
        <xsl:with-param name="context" select="."/>
        <xsl:with-param name="usenamespace" select="false()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:when test="@element">
      <xsl:apply-templates select="/" mode="#current">
        <xsl:with-param name="name" select="@element"/>
        <xsl:with-param name="what" select="'element'"/>
        <xsl:with-param name="context" select="."/>
        <xsl:with-param name="usenamespace" select="$style = 'document'" tunnel="yes"/>
        <xsl:with-param name="element" select="if ($style = 'rpc') then @name else ''" tunnel="yes" />
      </xsl:apply-templates>
    </xsl:when>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
