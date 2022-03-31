<!-- Copyright (C) 2006-2007 Orbeon, Inc. This program is free software; 
	you can redistribute it and/or modify it under the terms of the GNU Lesser 
	General Public License as published by the Free Software Foundation; either 
	version 2.1 of the License, or (at your option) any later version. This program 
	is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
	PURPOSE. See the GNU Lesser General Public License for more details. The 
	full text of the license is available at http://www.gnu.org/copyleft/lesser.html -->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<!-- - - - - - - Themed page template - - - - - - -->
	<xsl:template match="/">
		<div id="orbeon-error-portlet">
				<title>Viga lehe avamisel!</title>
				<style type="text/css">
					.body{margin-top: -4px; font-family: trebuchet ms,sans-serif; font-size: 14px;}
					.alert {font-size: 16px; color: #cc3300; font-weight: bold;}
					div.hr {border-top: 1px solid #cccccc; margin-top: 10px; margin-bottom:
					10px;}
				</style>
				<div class="body">
					<p class="head">
						<span class="alert">Portaali poole pöördumisel tekkis viga</span>
					</p>
					<p class="msg">Proovige laadida lehekülje uuesti. Kui viga kordub,
						palun pöörduge portaali administraatori poole</p>
					<div class="hr"></div>
					<p class="head">
						<span class="alert">During processing your request an error has been
							occurred</span>
					</p>
					<p class="msg">Please reload the page to continue. If the problem
						persists, please contact system administrator.</p>
				</div>
				<xsl:if test="//.[@class='orbeon-error-panel-message']">
					<div class="hr"></div>
					<p class="head">
						<span class="alert">Detailed error message</span>
					</p>
					<!-- Do not print out version, since version is already printed in the original message -->
					<!-- <pre class="orbeon-version">
						<xsl:copy>
							<xsl:apply-templates select="//.[@class='orbeon-version']" />
						</xsl:copy>
					</pre> -->
					<div class="error-message">
						<xsl:copy-of select="//.[name()='head']/*" />
						<xsl:copy-of select="//.[@class='orbeon-error-panel']" />
					</div>
					<script>jQuery(document).ready(function(){
						$(".contentbox").height(""); // need to call it, because javascript load returns 500 status so AJAX fails
						$(".orbeon-error-panel ul:eq(0), .orbeon-error-panel p:eq(0)").remove(); // remove unwanted static instructional text with jQuery, it is simpler that way
					});</script>
				</xsl:if>
			</div>
	</xsl:template>

</xsl:stylesheet>