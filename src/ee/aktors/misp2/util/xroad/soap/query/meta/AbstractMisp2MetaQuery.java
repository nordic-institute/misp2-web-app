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

package ee.aktors.misp2.util.xroad.soap.query.meta;

import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;
import ee.aktors.misp2.util.xroad.soap.query.AbstractMisp2XRoadQuery;

/**
 * Avoid message mediator if that is defined and send request directly to portal
 * security host.
 * 
 * @author sander.kallo
 *
 */
public abstract class AbstractMisp2MetaQuery extends AbstractMisp2XRoadQuery {

    protected AbstractMisp2MetaQuery() throws DataExchangeException {
        super();
        setSecurityServerUrl(portal.getSecurityHost() + Const.SECURITY_URI);
    }

    /**
     * get service member code for X-Road v4 and v5, when current message is of
     * X-Road v6 type
     */
    protected String getMetaServiceMemberCode() {
        if (isV4())
            return "xtee";
        else if (isV5())
            return "xrd";
        // X-Road v6 does not have meta-services, that's why return null
        return null;
    }
}
