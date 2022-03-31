<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" 
      xmlns:oxf="http://www.orbeon.com/oxf/processors" 
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xforms="http://www.w3.org/2002/xforms"
      xmlns:pipe="java:org.orbeon.oxf.processor.pipeline.PipelineFunctionLibrary"
      xmlns:ev="http://www.w3.org/2001/xml-events"
      xmlns:xxforms="http://orbeon.org/oxf/xml/xforms">
  <p:param type="input" name="data"/>
  <p:param type="output" name="data"/>
  <p:processor name="oxf:request">
    <p:input name="config">
      <config>
      <include>/request/*</include>
      </config>
    </p:input>
    <p:output name="data" id="request"/>
  </p:processor>
  
    <!-- Add xs namespace to XFORMS -->
	<p:processor name="oxf:xslt">
		<p:input name="data" href="#data"/>
        <p:input name="config">
            <xsl:transform version="2.0"
				xmlns:xhtml="http://www.w3.org/1999/xhtml">
				<!-- Test if templates are applied (changes first h1 it finds)
				<xsl:template match="xhtml:body[1]/xhtml:h1[1]">TEST</xsl:template>
				-->
				
				<!-- Copy all nodes and add xs namespace to them -->
				<xsl:template match="node()|@*">
					<xsl:copy>
						<xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
						<xsl:apply-templates select="node()|@*"/>
					</xsl:copy>
				</xsl:template> 
				
            </xsl:transform>
        </p:input>
		<!-- to debug output add attribute:  debug="xs-namespace-to-xforms" -->
	   <p:output name="data" id="data-xs-ns" ref="data"/>
    </p:processor>
  
  <p:choose href="#request">   
	<p:when test="/request/parameters/parameter[name = 'pdf']/value = 'true'"> 
		  <p:processor name="oxf:xslt">
			<p:input name="config">
			  <xsl:stylesheet version="2.0">
				<xsl:import href="oxf:/oxf/xslt/utils/copy.xsl"/>
				<xsl:import href="pdf.xsl"/>
				<xsl:param name="case" select="doc('input:request')/request/parameters/parameter[name='case']/value"/>
			  </xsl:stylesheet>
			</p:input>
			<p:input name="request" href="#request"/>
			<p:input name="data" href="#data-xs-ns"/>
			<p:output name="data" ref="data"/>
		  </p:processor>
	</p:when>
	<p:otherwise>
	 <p:processor name="oxf:identity">
	   <p:input name="data" href="#data-xs-ns"/>
	   <p:output name="data" ref="data"/>
	 </p:processor>
	</p:otherwise>
  </p:choose>

</p:config>