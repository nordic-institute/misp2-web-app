<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" 
    xmlns:xtee="http://x-tee.riik.ee/xsd/xtee.xsd"
    xmlns:xrd="http://x-road.ee/xsd/x-road.xsd">
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

<xsl:template match="wsdl:port" mode="#all">
  <xsl:if test="$debug"><xsl:message select="concat('traverse (xtee): ', name(), ', ', @name)"/></xsl:if>
  <!-- Must use <xsl:next-match> here, not <xsl:apply-imports>, because there are no imports.
       And there are no imports because if we import wsdltraverse.xsl, then only templates
       from that file are applied, and not templates from wsdlxforms.xsl. -->
  <xsl:variable name="tnsprefix" select="(xtee:address | xrd:address)/@producer"/>
  <xsl:next-match>
    <xsl:with-param name="producer" select="if($tnsprefix) then $tnsprefix else 'tns'" tunnel="yes"/>
    <xsl:with-param name="xroad-version" select="$xroad-version" tunnel="yes" />
  </xsl:next-match>
</xsl:template>

<xsl:template match="wsdl:binding/wsdl:operation" mode="#all">
  <xsl:param name="producer" tunnel="yes"/>
  <xsl:param name="operation" select="@name" tunnel="yes"/>
  <xsl:param name="version" select="normalize-space(xtee:version | xrd:version)" tunnel="yes"/>
  <xsl:param name="fullname" select="if($version != '') then  concat($producer, '.', $operation, '.', $version) else concat($producer, '.', $operation)" tunnel="yes"/>
  <xsl:param name="formname" select="$operation" tunnel="yes"/>
  <xsl:param name="filename" select="concat($operation, '.', $version, '.xhtml')" tunnel="yes"/>
  <xsl:if test="$debug"><xsl:message select="concat('traverse (xtee): ', name(), ', ', @name)"/></xsl:if>
  <xsl:if test="@name != 'listMethods' and @name != 'loadClassificators' and @name != 'getCharge'">
    <xsl:next-match>
      <xsl:with-param name="filename" select="$filename" tunnel="yes" />
      <xsl:with-param name="operation" select="$operation" tunnel="yes" />
      <xsl:with-param name="version" select="$version" tunnel="yes" />
      <xsl:with-param name="fullname" select="$fullname" tunnel="yes" />
      <xsl:with-param name="formname" select="$formname" tunnel="yes" />
      <xsl:with-param name="requirecontent" select="normalize-space(xtee:requirecontent | xrd:requireContent)" tunnel="yes" />
      <xsl:with-param name="nocontent" select="normalize-space(xtee:nocontent | xrd:noContent)" tunnel="yes" />
      <xsl:with-param name="default-language" select="'et'" tunnel="yes" />
    </xsl:next-match>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
