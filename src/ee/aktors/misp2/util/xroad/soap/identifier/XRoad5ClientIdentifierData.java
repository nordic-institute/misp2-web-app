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

import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Portal;

/**
 * Extract X-Road v5 consumer and unit header field data from 
 * user session portal and organization.
 * Use base class XRoadClientIdentifierData to find main 
 * organization and unit organization entities beforehand.
 */
public class XRoad5ClientIdentifierData extends XRoadClientIdentifierData {
    private String orgCode;
    private String unitCode;
    /**
     * Construct instance with X-Road v5 client identifier data instance.
     * Data is extracted from portal and organization entities within constructor.
     * @param sessionPortal user session Portal entity
     * @param sessionOrg user session Org entity
     */
    public XRoad5ClientIdentifierData(Portal sessionPortal, Org sessionOrg) {
        super(sessionPortal, sessionOrg);
        orgCode = parentOrg.getCode();
        if (unitOrg != null) {
            unitCode = unitOrg.getCode();
        } else {
            unitCode = null;
        }
    }

    /**
     * @return X-Road consumer header business-registry code
     */
    public String getOrgCode() {
        return orgCode;
    }

    /**
     * @return X-Road unit organization business-registry code
     */
    public String getUnitCode() {
        return unitCode;
    }

    /**
     * @return true if unit is defined, false otherwise
     */
    public boolean hasUnit() {
        return unitCode != null;
    }
}
