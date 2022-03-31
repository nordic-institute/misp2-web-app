<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" 
      xmlns:oxf="http://www.orbeon.com/oxf/processors" 
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xforms="http://www.w3.org/2002/xforms"
      xmlns:pipe="java:org.orbeon.oxf.processor.pipeline.PipelineFunctionLibrary"
      xmlns:ev="http://www.w3.org/2001/xml-events"
      xmlns:xxforms="http://orbeon.org/oxf/xml/xforms">
	<p:param type="input" name="data"/>
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request/parameters/parameter</include>
            </config>
        </p:input>
        <p:output name="data" id="request"/>
    </p:processor>

	<p:processor name="oxf:scope-generator"> 
		<p:input name="config" transform="oxf:xslt" href="#request"> 
			<config xsl:version="2.0"> 
				 <key><xsl:value-of select="/request/parameters/parameter[name = 'instance']/value"/></key>
				 <scope>session</scope>
			</config> 
		</p:input> 
		<p:output name="data" id="xml-from-session"/>
	</p:processor> 

	<p:processor name="oxf:xml-converter">
		<p:input name="config">
			<config>
				<content-type>application/xml</content-type>
				<encoding>UTF-8</encoding>
				<version>1.0</version>
			</config>
		</p:input>
		<p:input name="data" href="#xml-from-session"/>
		<p:output name="data" id="xml-for-download"/>
	</p:processor>

	<p:processor name="oxf:http-serializer">
		<p:input name="config" transform="oxf:xslt" href="#request">
			<config xsl:version="2.0">
				<header>
					<name>Content-Disposition</name>
					<value>attachment; filename=<xsl:value-of select="/request/parameters/parameter[name = 'filename']/value"/></value>
                </header>
                <header>
					<name>Cache-Control</name>
                    <value>no-cache</value>
                </header>
                <cache-control>
					<use-local-cache>false</use-local-cache>
                </cache-control>
				<content-type>text/xml</content-type>
				<force-content-type>true</force-content-type>
				<encoding>utf-8</encoding>
				<force-encoding>true</force-encoding>
			</config>
		</p:input>
		<p:input name="data" href="#xml-for-download"/>
	</p:processor>
</p:config>

