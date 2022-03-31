<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xforms="http://www.w3.org/2002/xforms"
    xmlns:events="http://www.w3.org/2001/xml-events"
    xmlns:xxforms="http://orbeon.org/oxf/xml/xforms"
    xmlns:exf="http://www.exforms.org/exf/1-0">
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
<xsl:param name="case"/>

<!-- Default template, that copies node to output and applies templates to all child nodes. -->
<xsl:template match="@*|*|text()" name="copy">
  <!--xsl:message><xsl:value-of select="name()" /></xsl:message-->
  <xsl:copy>
    <xsl:apply-templates select="*|@*|text()"/>
  </xsl:copy>
</xsl:template>

<!-- Set XForms model to noscript mode, otherwise it won't work with XHTMLRenderer.
     Additionally set appearance of readonly fields to static, so they are rendered
     with plain HTML. Together with readonly=true() bindings this provides best input
     for XHTMLRenderer. -->
<xsl:template match="xforms:model">
  <xsl:message><xsl:value-of select="$case"/></xsl:message>
  <xsl:copy>
    <xsl:apply-templates select="@*" />
    <xsl:attribute name="xxforms:readonly-appearance" select="'static'"/>
<!--    <xsl:attribute name="xxforms:noscript" select="'true'"/>-->
    <xsl:apply-templates select="*" />
    <xforms:toggle case="{$case}" events:event="xforms-ready"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="xforms:instance[ends-with(@id, '.output')]">
        <xsl:call-template name="copy"/>
        <xforms:insert nodeset="instance('{@id}')" origin="xxforms:get-session-attribute('{@id}')" events:event="xforms-ready"/>
</xsl:template>

<!-- Set all root level bindings to readonly. -->
<!--
    Commented this out, as it hides links in PDF. But they are hidden anyway,
    because noscript mode outputs minimal triggers as buttons and buttons are
    hidden in _print.css for riigiportaal theme. The solution is to not use
    the noscript mode and use instead custom theme for PDF conversion, which
    removes Javascript checks. This makes also PDF conversion usable in Orbeon CE.
-->
<xsl:template match="xforms:model/xforms:bind">
  <xsl:copy>
    <xsl:apply-templates select="@*" />
    <xsl:attribute name="readonly" select="'true()'"/>
    <xsl:apply-templates select="*" />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
