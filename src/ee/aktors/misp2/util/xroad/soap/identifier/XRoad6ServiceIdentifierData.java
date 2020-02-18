/*
 * The MIT License
 * Copyright (c) 2019 Estonian Information System Authority (RIA)
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

import ee.aktors.misp2.util.Const;

public class XRoad6ServiceIdentifierData {

    private String xRoadInstance;
    private String memberClass;
    private String memberCode;
    private String subsystemCode;
    private String serviceCode;
    private String serviceVersion;
    
    /**
     * Construct service identifier container instance from REST service identifier string.
     * @param restServiceIdentifier
     */
    public XRoad6ServiceIdentifierData(String restServiceIdentifier) {
        String[] ar = restServiceIdentifier
                .replaceAll("^" + Const.XROAD_REST_HEADER_FIELD_SEPARATOR, "")
                .split(Const.XROAD_REST_HEADER_FIELD_SEPARATOR);
        xRoadInstance   = ar.length  >= 1 ? ar[0] : null;
        memberClass     = ar.length  >= 2 ? ar[1] : null;
        memberCode      = ar.length  >= 3 ? ar[2] : null;
        subsystemCode   = ar.length  >= 4 ? ar[3] : null;
        serviceCode     = ar.length  >= 5 ? ar[4] : null;
        serviceVersion  = ar.length  >= 6 ? ar[5] : null;
    }
    
    /**
     * @return true if all necessary service fields have been given
     */
    public boolean isValid() {
        return StringUtils.isNotBlank(xRoadInstance)
                && StringUtils.isNotBlank(memberClass)
                && StringUtils.isNotBlank(memberCode)
                && StringUtils.isNotBlank(subsystemCode)
                && StringUtils.isNotBlank(serviceCode);
    }
    
    /**
     * @return X-Road Service fields in the following format: 
     *  INSTANCE/MEMBER_CLASS/MEMBER_CODE/SUBSYSTEM_CODE/SERVICE_CODE/SERVICE_VERSION
     */
    public String getRestServiceIdentifier() {
        return getRestServiceIdentifier(Const.XROAD_REST_HEADER_FIELD_SEPARATOR);
    }
    
    /**
     * @param sep identifier field separator
     * @return service identifier fields separated by #separator
     */
    public String getRestServiceIdentifier(String sep) {
        StringWriter sw = new StringWriter()
                .append("" + xRoadInstance)
                .append(sep + memberClass)
                .append(sep + memberCode)
                .append(sep + subsystemCode)
                .append(sep + serviceCode);
        if (StringUtils.isNotBlank(serviceVersion)) {
            sw.append(serviceVersion);
        }
        return sw.toString();
    }
    
    public String getXRoadInstance() {
        return xRoadInstance;
    }
}
