<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:f="http://orbeon.org/oxf/xml/formatting"
    xmlns:context="java:org.orbeon.oxf.pipeline.StaticExternalContext"
    exclude-result-prefixes="xsl f context">

   <xsl:template match="/">
        <xhtml:div class="orbeon-portlet-div">
            <!-- Styles and scripts -->
                <xhtml:link rel="stylesheet" type="text/css" href="/resources/EE/css/xforms-embedded.css" media="screen"/>
                <xhtml:link rel="stylesheet" type="text/css" href="/resources/EE/css/xforms-pdf.css" media="print"/>
            <!-- Handle head elements except scripts -->
            <xsl:for-each select="/xhtml:html/xhtml:head/(xhtml:meta | xhtml:link | xhtml:style)">
                <xsl:element name="xhtml:{local-name()}" namespace="{namespace-uri()}">
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:for-each>
            <!-- Try to get a title and set it on the portlet -->
            <!--xsl:if test="normalize-space(/xhtml:html/xhtml:head/xhtml:title)">
                <xsl:value-of select="context:setTitle(normalize-space(/xhtml:html/xhtml:head/xhtml:title))"/>
            </xsl:if-->
            <!-- Handle head scripts if present -->
            <xsl:apply-templates select="/xhtml:html/xhtml:head/xhtml:script"/>
            <!-- Body -->
            <xhtml:div id="orbeon" class="orbeon-portlet-content orbeon">
                <xhtml:div class="maincontent">
                    <xsl:apply-templates select="/xhtml:html/xhtml:body/node()"/>
                </xhtml:div>
            </xhtml:div>
            <!-- Handle post-body scripts if present. They can be placed here by oxf:resources-aggregator -->
            <xsl:apply-templates select="/xhtml:html/xhtml:script"/>
        </xhtml:div>
    </xsl:template>
   

    <!-- Remember that we are embeddable -->
    <xsl:template match="xhtml:form">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xhtml:input type="hidden" name="orbeon-embeddable" value="true"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>


    <!-- Simply copy everything that's not matched -->
    <xsl:template match="@*|node()" priority="-2">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>

