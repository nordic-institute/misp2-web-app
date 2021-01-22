/*
 * The MIT License
 * Copyright (c) 2020 NIIS <info@niis.org>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */
package ee.aktors.misp2.util.xroad.soap.identifier;

import java.io.StringWriter;

import org.apache.commons.lang3.StringUtils;

import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.util.Const;

/**
 * Extract X-Road v6 client and representedParty header field data from 
 * user session portal and organization.
 * Use base class XRoadClientIdentifierData to find main 
 * organization and unit organization entities.
 * Find X-Road client header identifier data from these entities and also portal entity.
 */
public class XRoad6ClientIdentifierData extends XRoadClientIdentifierData {

    private String xRoadInstance;
    private String clientMemberClass;
    private String clientMemberCode;
    private String clientSubsystemCode;
    private String representedPartyClass;
    private String representedPartyCode;

    /**
     * Construct instance with X-Road v6 client identifier data. All data is extracted and assigned
     * to member fields within constructor.
     * @param sessionPortal user session Portal entity
     * @param sessionOrg user session Org entity
     */
    public XRoad6ClientIdentifierData(Portal sessionPortal, Org sessionOrg) {
        super(sessionPortal, sessionOrg);
        clientMemberClass = parentOrg.getMemberClass();
        clientMemberCode = parentOrg.getCode();
        clientSubsystemCode = parentOrg.getSubsystemCode();
        xRoadInstance = sessionPortal.getClientXroadInstance();
        //soapMessageBuilderV6.setServiceXRoadInstance(sessionPortal.getXroadInstance());
        if (unitOrg != null) {
            representedPartyClass = unitOrg.getMemberClass();
            representedPartyCode = unitOrg.getCode();
        } else {
            representedPartyClass = null;
            representedPartyCode = null;
        }
    }

    /**
     * @return client X-Road instance
     */
    public String getXRoadInstance() {
        return xRoadInstance;
    }

    /**
     * @return client member class
     */
    public String getClientMemberClass() {
        return clientMemberClass;
    }

    /**
     * @return client member code
     */
    public String getClientMemberCode() {
        return clientMemberCode;
    }

    /**
     * @return client subsystem code
     */
    public String getClientSubsystemCode() {
        return clientSubsystemCode;
    }

    /**
     * @return represented party class (COM, GOV or NGO)
     */
    public String getRepresentedPartyClass() {
        return representedPartyClass;
    }

    /**
     * @return represented party code (could be 8-digit business registry code: e.g 12345678)
     */
    public String getRepresentedPartyCode() {
        return representedPartyCode;
    }

    /**
     * @return true if representedParty is defined, false otherwise
     */
    public boolean hasRepresentedParty() {
        return representedPartyCode != null;
    }

    /**
     * @return REST X-Road-Client header value in 'INSTANCE/CLASS1/MEMBER1/SUBSYSTEM1' format.
     */
    public String getRestClientIdentifier() {
        return getRestClientIdentifier(Const.XROAD_REST_HEADER_FIELD_SEPARATOR);
    }
    /**
     * @param separator field separator in concatenated string
     * @return REST X-Road-Client header INSTANCE, MEMBER_CLASS, MEMBER_CODE and SUBSYSTEM values separated by #separator
     */
    public String getRestClientIdentifier(String separator) {
        StringWriter sw = new StringWriter();
        sw.append(xRoadInstance).append(separator)
          .append(clientMemberClass).append(separator)
          .append(clientMemberCode);
        if (StringUtils.isNotBlank(clientSubsystemCode)) {
            sw.append(separator).append(clientSubsystemCode);
        }
        return sw.toString();
    }

    /**
     * @return REST X-Road-Represented-Party header value in 'MEMBER_CLASS/MEMBER_CODE' format
     */
    public String getRepresentedPartyIdentifier() {
        return getRepresentedPartyIdentifier(Const.XROAD_REST_HEADER_FIELD_SEPARATOR);
    }

    /**
     * @param separator field separator in concatenated string
     * @return REST X-Road-Represented-Party header MEMBER_CLASS and MEMBER_CODE values separated by #separator
     */
    public String getRepresentedPartyIdentifier(String separator) {
        if (hasRepresentedParty()) {
            return new StringWriter()
                .append(representedPartyClass).append(separator)
                .append(representedPartyCode)
                .toString();
            
        } else {
            return null;
        }
    }

}