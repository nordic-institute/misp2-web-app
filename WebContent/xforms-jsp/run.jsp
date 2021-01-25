<%--
  ~ The MIT License
  ~ Copyright (c) 2020 NIIS
  ~
  ~ Permission is hereby granted, free of charge, to any person obtaining a copy
  ~ of this software and associated documentation files (the "Software"), to deal
  ~ in the Software without restriction, including without limitation the rights
  ~ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  ~ copies of the Software, and to permit persons to whom the Software is
  ~ furnished to do so, subject to the following conditions:
  ~
  ~ The above copyright notice and this permission notice shall be included in
  ~ all copies or substantial portions of the Software.
  ~
  ~ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  ~ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  ~ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  ~ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  ~ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  ~ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  ~ THE SOFTWARE.
  ~
  --%>

<?xml version="1.0" encoding="US-ASCII"?>
<xhtml:html xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
            xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
            xmlns:xhtml="http://www.w3.org/1999/xhtml"
            xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
            xmlns:xforms="http://www.w3.org/2002/xforms"
            xmlns:xxforms="http://orbeon.org/oxf/xml/xforms"
            xmlns:events="http://www.w3.org/2001/xml-events"
            xmlns:xsd="http://www.w3.org/2001/XMLSchema"
            xmlns:ns4="http://x-tee.riik.ee/xsd/xtee.xsd"
 			xmlns:ns5="http://producers.epost.xtee.riik.ee/producer/epost"
            xmlns:xtee="http://x-tee.riik.ee/xsd/xtee.xsd"
            xmlns:epost="http://producers.epost.xtee.riik.ee/producer/epost">
   <xhtml:head>
      <xhtml:title>Postis&#252;steemis registreeritud kontode loetelu</xhtml:title>
      <xhtml:style type="text/css">
            .xforms-label { font-weight: bold }
            .query-label { display: -moz-inline-box; display: inline-block; width: expression('20em'); min-width: 15em; }
            .xforms-textarea-appearance-xxforms-autosize { width: 20em; margin-bottom: 2px  }
            .xforms-input input { width: 20em; margin-bottom: 2px }
            .xforms-select1 { margin-bottom: 2px }
            .xforms-select1 input { margin-bottom: 2px }
            .query-table { background-color: #fce5b6; width: expression('20em')}
            .query-table .add-td { width: 33em }
            .query-table .form-td { width: 50em; background: white; padding: .5em }
            .xforms-repeat-selected-item-1 .form-td { background: #ffc }
            /*.xforms-repeat-selected-item-1 .form-td .xforms-select1-appearance-minimal { background: white;  }*/
            .query-action-table { margin-bottom: 1em }
            .query-action-table td { white-space: nowrap; vertical-align: middle; padding-right: 1em }
            .query-action-table .xforms-submit img { vertical-align: middle }
            .query-action-table .xforms-trigger-appearance-minimal img { margin-right: 1em; vertical-align: middle }
      
      
      
      </xhtml:style>
      <xforms:model>
         <xforms:instance id="activeaccounts.input">
            <SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
               <SOAP-ENV:Header>
                  <xtee:asutus>11333578</xtee:asutus>
                  <xtee:andmekogu>epost</xtee:andmekogu>
                  <xtee:isikukood>EE38706150225</xtee:isikukood>
                  <xtee:id>5e58d92c2dcd558a7570fac625a8393d8691f427</xtee:id>
                  <xtee:nimi>epost.activeaccounts.v1</xtee:nimi>
                  <xtee:amet/>
                  <xtee:toimik/>
                  <xtee:ametnik/>
               </SOAP-ENV:Header>
               <SOAP-ENV:Body>
                  <ns5:activeaccounts xmlns:ns5="http://producers.epost.xtee.riik.ee/producer/epost">
                     <keha xsi:nil="false">
                        <eesnimi xsi:nil="true" xsi:type="xsd:string" />
                        <perenimi xsi:nil="true" xsi:type="xsd:string" />
                        <isikukood xsi:nil="true" xsi:type="xsd:string">38706150225</isikukood>
                        <postiaadress xsi:nil="true" xsi:type="xsd:string" />
                     </keha>
                  </ns5:activeaccounts>
               </SOAP-ENV:Body>
            </SOAP-ENV:Envelope>
         </xforms:instance>
        <xforms:instance id="activeaccounts.output">
            <SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"/>
         </xforms:instance>
		 <xforms:instance id="temp">
            <temp>
               <relevant xsi:type="boolean">true</relevant>
            </temp>
         </xforms:instance>
         <xforms:instance id="texts">
            <texts>
               <boolean value="true">jah</boolean>
               <boolean value="false">ei</boolean>
               <no_data>Andmeid ei tulnud.</no_data>
            </texts>
         </xforms:instance>
         <xforms:instance id="formatted">
                <formated-instance/>
          </xforms:instance>      
          <xforms:instance id="formatted2">
                <formated-instance/>
          </xforms:instance>  
         <xforms:bind nodeset="instance('activeaccounts.input')/SOAP-ENV:Body/epost:activeaccounts">
            <xforms:bind nodeset="keha">
               <xforms:bind nodeset="eesnimi">
                  <xforms:bind nodeset="@xsi:nil" relevant="false()"/>
               </xforms:bind>
               <xforms:bind nodeset="perenimi">
                  <xforms:bind nodeset="@xsi:nil" relevant="false()"/>
               </xforms:bind>
               <xforms:bind nodeset="isikukood">
                  <xforms:bind nodeset="@xsi:nil" relevant="false()"/>
               </xforms:bind>
               <xforms:bind nodeset="postiaadress">
                  <xforms:bind nodeset="@xsi:nil" relevant="false()"/>
               </xforms:bind>
               <xforms:bind nodeset="@xsi:nil" relevant="false()"/>
            </xforms:bind>
         </xforms:bind>
        
         <xforms:bind nodeset="instance('activeaccounts.output')/soap:Body/epost:activeaccountsResponse">
            <xforms:bind nodeset="keha">
               <xforms:bind nodeset="*">
                  <xforms:bind nodeset="isikukood" type="string"/>
                  <xforms:bind nodeset="eesnimi" type="string"/>
                  <xforms:bind nodeset="perenimi" type="string"/>
                  <xforms:bind nodeset="postiaadress" type="string"/>
                  <xforms:bind nodeset="loodud" type="date"/>
                  <xforms:bind nodeset="muudetud" type="date"/>
                  <xforms:bind nodeset="suunatuid" type="int"/>
               </xforms:bind>
            </xforms:bind>
         </xforms:bind>

         <xforms:submission id="activeaccounts.submission" action="http://192.168.219.27/cgi-bin/consumer_proxy" mediatype="text/xml; charset=UTF-8" 
         					ref="instance('activeaccounts.input')"
         					method="post"  
         					replace="instance"
         					instance="activeaccounts.output">
            <xforms:setvalue ref="instance('temp')/relevant" value="false()" events:event="xforms-submit"/>
            <xforms:setvalue ref="instance('temp')/relevant" value="true()"
                             events:event="xforms-submit-done"/>
            <xforms:setvalue ref="instance('temp')/relevant" value="true()"
                             events:event="xforms-submit-error"/>
            <xforms:toggle case="activeaccounts.response" events:event="xforms-submit-done"/>
            <xforms:message level="modal" events:event="xforms-submit-error">Veendu, et k&#245;ik v&#228;ljad on korrektselt t&#228;idetud!</xforms:message>
         </xforms:submission>
      
         <xforms:bind nodeset="instance('formatted')" 
                calculate="xxforms:serialize(xxforms:call-xpl('oxf:/ops/utils/formatting/format.xpl', 'data', instance('activeaccounts.input'), 'data')/*, 'html')"/>
         <xforms:bind nodeset="instance('formatted2')" 
                calculate="xxforms:serialize(xxforms:call-xpl('oxf:/ops/utils/formatting/format.xpl', 'data', instance('activeaccounts.output'), 'data')/*, 'html')"/>
         <xforms:toggle case="activeaccounts.request" events:event="xforms-ready"/>
      </xforms:model>
   </xhtml:head>
   <xhtml:body>
      <xhtml:h1>Postis&#252;steemis registreeritud kontode loetelu</xhtml:h1>
      
      <xforms:switch>
         <xforms:case id="activeaccounts.request">
            <xforms:group ref="instance('activeaccounts.input')/SOAP-ENV:Body/epost:activeaccounts">
            <xhtml:table class="query-table">
               <xforms:group ref="keha">
               	  <xhtml:tr>
               	  <xhtml:td class="form-td">
                  <xforms:input ref="eesnimi">
                  	<xforms:label class="query-label">Eesnimi</xforms:label>
                  </xforms:input>
                  <br/>
                  <xforms:input ref="perenimi">
                     <xforms:label class="query-label">Perenimi</xforms:label>
                  </xforms:input>
                  <br/>
                  <xforms:input ref="isikukood">
                     <xforms:label class="query-label">Isikukood</xforms:label>
                  </xforms:input>
                  <br/>
                  <xforms:input ref="postiaadress">
                     <xforms:label class="query-label">eesti.ee e-posti aadress</xforms:label>
                  </xforms:input>
                  </xhtml:td>
                  </xhtml:tr>
               </xforms:group>
               </xhtml:table>
            </xforms:group>
                                
           <xforms:group class="actions">
            <xforms:submit submission="activeaccounts.submission">
            	<xforms:label>Esita p&#228;ring</xforms:label>
        	</xforms:submit>
        	</xforms:group>
         </xforms:case>
         <xforms:case id="activeaccounts.response">
         <xforms:group ref="instance('activeaccounts.output')/*">
               <xforms:output ref="xtee:id" class="serviceid">
                  <xforms:label>P&#228;ringu id: </xforms:label>
               </xforms:output>
            </xforms:group>
            <xforms:group ref="instance('activeaccounts.output')/SOAP-ENV:Body/epost:activeaccountsResponse">
               <xforms:group ref="keha">
               	<xhtml:table border="1" >
               	  
               	  <xforms:repeat nodeset="*"
                                 id="instance__activeaccounts_output___SOAP-ENV_Body_epost_activeaccountsResponse_keha">
                   <xhtml:tr>             
                    <xhtml:td class="form-td">
               	  		Konto omanik
               	  	</xhtml:td>
               	  	</xhtml:tr>
                   <xhtml:tr>
               	  	<xhtml:td class="form-td">
                     <xforms:output ref="isikukood">
                        <xforms:label class="query-label">Isikukood</xforms:label>
                     </xforms:output>
                     <br/>
                     <xforms:output ref="eesnimi">
                        <xforms:label class="query-label">Eesnimi</xforms:label>
                     </xforms:output>
                      <br/>
                     <xforms:output ref="perenimi">
                        <xforms:label class="query-label">Perekonnanimi</xforms:label>
                     </xforms:output>
                      <br/>
                     <xforms:output ref="postiaadress">
                        <xforms:label class="query-label">eesti.ee e-posti aadress</xforms:label>
                     </xforms:output>
                      <br/>
                     <xforms:output ref="loodud">
                        <xforms:label class="query-label">Konto loodud</xforms:label>
                     </xforms:output>
                      <br/>
                     <xforms:output ref="muudetud">
                        <xforms:label class="query-label">Viimati muudetud</xforms:label>
                     </xforms:output>
                      <br/>
                     <xforms:output ref="suunatuid">
                        <xforms:label class="query-label">Suunatuid</xforms:label>
                     </xforms:output>
                      <br/>
                    </xhtml:td>
                   </xhtml:tr>
                  </xforms:repeat>
                  
                </xhtml:table>
               </xforms:group>
            </xforms:group>
         	 <xforms:group ref="instance('activeaccounts.output')/SOAP-ENV:Body/epost:activeaccountsResponse[not(keha/*)]"
                          class="info">
               <xforms:output ref="instance('texts')/no_data"/>
            </xforms:group>
            <xforms:group ref="instance('activeaccounts.output')/SOAP-ENV:Body/epost:activeaccountsResponse/keha/faultString"
                          class="info">
               <xforms:output ref="."/>
            </xforms:group>
            <xforms:group ref="instance('activeaccounts.output')/SOAP-ENV:Body/SOAP-ENV:Fault"
                          class="fault">
               <xforms:output ref="faultstring"/>
            </xforms:group>
            <br/>
         	<xforms:group class="actions">
               <xforms:trigger>
                  <xforms:label>Tagasi</xforms:label>
                  <xforms:toggle events:event="DOMActivate" case="activeaccounts.request"/>
               </xforms:trigger>
            </xforms:group>
            
            <br/><br/>
         <xforms:output ref="instance('formatted')" mediatype="text/html"/>
         <xforms:output ref="instance('formatted2')" mediatype="text/html"/>
                       
         </xforms:case>
      </xforms:switch>
   </xhtml:body>
</xhtml:html>
