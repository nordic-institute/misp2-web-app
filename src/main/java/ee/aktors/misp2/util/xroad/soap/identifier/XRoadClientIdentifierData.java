/*
 * The MIT License
 * Copyright (c) 2020- Nordic Institute for Interoperability Solutions (NIIS)
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
import ee.aktors.misp2.util.Const;

/** 
 * X-Road request client header data extraction base class.
 * It finds correct main organization and unit organization according to 
 * portal configuration.
 * This class is abstract since it is meant to be extended.
 * Concrete X-Road client data should be extracted in extended classes according
 * to X-Road protocol.
 */
abstract class XRoadClientIdentifierData {
    Org parentOrg;
    Org unitOrg;
    /**
     * Construct instance from user session portal and organization entities.
     * @param sessionPortal user session Portal entity
     * @param sessionOrg user session Org entity
     */
    XRoadClientIdentifierData(Portal sessionPortal, Org sessionOrg) {
        parentOrg = sessionOrg;
        unitOrg = null;
        if ((sessionPortal.getMispType() == Const.MISP_TYPE_UNIVERSAL
                || sessionPortal.getMispType() == Const.MISP_TYPE_ORGANISATION) && sessionOrg.getSupOrgId() != null
                && !sessionOrg.getCode().equals(sessionOrg.getSupOrgId().getCode())) {
            // in universal portal query may be made by unit
            parentOrg = sessionPortal.getUnitIsConsumer() ? sessionOrg : sessionOrg.getSupOrgId();
            unitOrg = sessionOrg;
        }
    }
}