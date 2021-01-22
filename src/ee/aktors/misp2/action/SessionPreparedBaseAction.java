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

package ee.aktors.misp2.action;

import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.Preparable;

import ee.aktors.misp2.beans.Auth;
import ee.aktors.misp2.model.Org;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.util.Const;

/**
 * super.prepare() has to be the first command in overridden prepare method
 * 
 * @author arnis.rips
 */
public class SessionPreparedBaseAction extends BaseAction implements Preparable {

    private static final long serialVersionUID = 1L;
    protected Map<String, Object> session;
    private static final Logger LOG = LogManager.getLogger(SessionPreparedBaseAction.class);
    protected Portal portal;
    protected Org org;
    protected Person user;
    protected Auth auth;

    /**
     * super.prepare() has to be called first
     * @throws Exception can throw
     */
    public void prepare() throws Exception {
        session = ActionContext.getContext().getSession();

        if (session == null) {
            LOG.error("Session is null");
        } else {
            org = (Org) session.get(Const.SESSION_ACTIVE_ORG);
            user = (Person) session.get(Const.SESSION_USER_HANDLE);
            auth = (Auth) session.get(Const.SESSION_AUTH);
            portal = (Portal) session.get(Const.SESSION_PORTAL);
        }
    }

}
