<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" 
    xmlns:xtee="http://x-tee.riik.ee/xsd/xtee.xsd"
    xmlns:xrd="http://x-road.ee/xsd/x-road.xsd">
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

<!-- Directory, where WSDL files are. -->
<xsl:param name="wsdl-prefix"></xsl:param>
<!-- Extension of WSDL files. -->
<xsl:param name="wsdl-suffix">.wsdl</xsl:param>

<!-- Let everybody know, this is complex operation. -->
<xsl:template match="xtee:complex" mode="#all">
  <xsl:next-match>
    <xsl:with-param name="complex" select="." tunnel="yes" />
  </xsl:next-match>
</xsl:template>

<xsl:template match="xtee:suboperation[@*:type='locator']" mode="#all">
  <xsl:if test="$debug"><xsl:message select="concat('model/form: ', name(), ', ', @*:label)"/></xsl:if>
  <xsl:variable name="producer" select="substring-before(@*:href, '.')"/>
  <xsl:variable name="rest" select="substring-after(@*:href, '.')"/>
  <xsl:variable name="operation" select="substring-before($rest, '.')"/>
  <xsl:variable name="version" select="substring-after($rest, '.')"/>
  <!-- Apply templates from the root so the wsdltraverse and xteetraverse templates
       have chance to set various parameters. -->
  <xsl:apply-templates select="document(concat($wsdl-prefix, $producer, $wsdl-suffix))/wsdl:definitions/wsdl:service" mode="#current">
    <xsl:with-param name="producer" select="$producer" tunnel="yes" />
    <xsl:with-param name="operation" select="$operation" tunnel="yes" />
    <xsl:with-param name="version" select="$version" tunnel="yes" />
    <xsl:with-param name="fullname" select="@*:href" tunnel="yes" />
    <xsl:with-param name="formname" select="@*:label" tunnel="yes" />
    <xsl:with-param name="actuate" select="@*:actuate" tunnel="yes" />
    <xsl:with-param name="tnsprefix" select="$producer" tunnel="yes" />
  </xsl:apply-templates>
</xsl:template>

<!-- In case of complex operation match only the suboperation that is in the parameters. -->
<xsl:template match="wsdl:binding/wsdl:operation" mode="#all">
  <xsl:param name="complex" tunnel="yes"/>
  <xsl:param name="operation" tunnel="yes"/>
  <xsl:param name="version" tunnel="yes"/>
  <xsl:choose>
    <xsl:when test="$complex and ($operation != @name or $version != normalize-space(xtee:version | xrd:version))"/>
    <xsl:otherwise>
      <xsl:next-match/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
