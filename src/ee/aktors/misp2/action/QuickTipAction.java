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

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Roles;

/**
 *
 * @author arnis.rips
 */
public abstract class QuickTipAction extends SessionPreparedBaseAction {

    private static final long serialVersionUID = 1L;
    public final String quicktipPrefix = "quicktip.";
    private String quickTip = null;
    private String currentActionName = null;
    private boolean showSideBox = false;
    private static final Logger LOG = LogManager.getLogger(QuickTipAction.class);
    protected Integer role;

    @Override
    public void prepare() throws Exception {
        super.prepare();
        currentActionName = ActionContext.getContext().getName();
        role = (Integer) session.get(Const.SESSION_USER_ROLE);
        if (role != null) {
            showSideBox = Roles.isAnySet(role, Roles.DUMBUSER, Roles.UNREGISTERED, Roles.PERMISSION_MANAGER)
                    && !currentActionName.toLowerCase().contains("help");
            LOG.debug("Role = " + role + " showSideBox = " + showSideBox);
        } else {
            // user not authenticated
            LOG.debug("User not logged in, allowing side box showing");
            showSideBox = true;
        }
        if (quickTip == null) {
            quickTip = getText(quicktipPrefix + currentActionName);
        }

    }

    /**
     * @return the quickTip
     */
    public String getQuickTip() {
        return quickTip;
    }

    /**
     * @param quickTipNew the quickTip to set
     */
    public void setQuickTip(String quickTipNew) {
        this.quickTip = quickTipNew;
    }

    /**
     * @return the currentActionName
     */
    public String getCurrentActionName() {
        return currentActionName;
    }

    /**
     * @return the showSideBox
     */
    public boolean isShowSideBox() {
        return showSideBox;
    }
}
