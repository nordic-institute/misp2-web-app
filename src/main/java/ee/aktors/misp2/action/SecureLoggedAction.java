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

package ee.aktors.misp2.action;

import java.net.MalformedURLException;
import java.net.URL;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.beans.T3SecWrapper;
import ee.aktors.misp2.provider.LogQueryProvider;
import ee.aktors.misp2.service.BaseService;
import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
public class SecureLoggedAction extends QuickTipAction {

    private static final long serialVersionUID = 1L;
    public static final String ACTION_TEXT_PREFIX = "t3sec.action.";
//    private BaseService service;
    private static final Logger LOG = LogManager.getLogger(SecureLoggedAction.class);

    /**
     * @param service unused
     */
    public SecureLoggedAction(BaseService service) {
//        this.service = service;
    }

    @Override
    public void prepare() throws Exception {
        super.prepare();
        if (session == null) {
            LOG.error("Session is null");
        }
    }

    protected T3SecWrapper initT3(int action) {
        T3SecWrapper t3 = new T3SecWrapper();
        String orgCode;
        try {
            LOG.debug(session);
            if (session != null) {
                if (user != null) {
                    if (user.getSsn() != null) {
                        t3.getT3sec().setUserFrom(user.getSsn());
                    } else {
                        t3.getT3sec().setUserFrom(user.getFullName());
                        LOG.warn("Person does not have SSN set using name instead");
                    }
                } else {
                    LOG.warn("Person not found in session");
                }

                if (org != null) {
                    orgCode = org.getCode();
                } else {
                    LOG.warn("Org not set in session using portal.getOrg()");
                    orgCode = portal.getOrgId().getCode();
                }
                if (portal != null) {
                    LOG.debug("portal.getOrgId()" + portal.getOrgId());

                    t3.setSuperOrgCode(portal.getOrgId().getCode());
                    t3.getT3sec().setOrgCode(orgCode);
                    t3.setActionName(getText(ACTION_TEXT_PREFIX + action));
                    t3.getT3sec().setActionId(action);
                    t3.getT3sec().setPortalName(portal.getShortName());
                }
            } else {
                LOG.error("Session is null");
            }
        } catch (Exception ex) {
            LOG.error(ex.getMessage(), ex);
        }
        return t3;
    }

    protected boolean log(T3SecWrapper t3) {
        if (session != null) {
            if (portal != null) {

                try {
                    LOG.debug("Logging in secure server: " + portal.getSecurityHost() + Const.SECURITY_URI);
                    return LogQueryProvider.getLogQuery()
                            .log(t3, new URL(portal.getSecurityHost() + Const.SECURITY_URI),
                                    portal.getLogQuery().booleanValue());
                } catch (MalformedURLException ex) {
                    LOG.debug("Faulty message mediator: " + portal.getSecurityHost() + Const.SECURITY_URI);
                    LOG.error(ex.getMessage(), ex);
                    return false;
                } catch (Exception ex) {
                    LOG.error("Unexpected exception: " + ex.getMessage(), ex);
                    return false;
                }

            } else {
                LOG.error("Portal not set in session");
                return false;
            }
        } else {
            LOG.error("Logging failed because session is null");
            return false;
        }
    }

}
