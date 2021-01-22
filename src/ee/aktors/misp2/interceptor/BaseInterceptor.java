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

package ee.aktors.misp2.interceptor;

import java.util.Locale;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;

import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.Interceptor;
import com.opensymphony.xwork2.interceptor.ValidationAware;

import ee.aktors.misp2.beans.GetText;

/**
 *
 * @author arnis.rips
 */
public abstract class BaseInterceptor extends GetText implements Interceptor, StrutsStatics {
    private static final Logger LOGGER = LogManager.getLogger(BaseInterceptor.class);

    private static final long serialVersionUID = 1L;
    
    protected static final String PAGE_NOT_FOUND = "pageNotFound";
    protected static final String NOT_LOGGED_IN = "not_logged_in";
    protected static final String UNAUTHORIZED = "unauthorized";
    protected static final String USER_DOESNT_EXIST = "user_doesnt_exist";
    protected static final String NO_PORTAL = "no_portal";

    static {
        LOGGER.trace("...BaseInterceptor loaded...");
    }
    
    protected BaseInterceptor() {
        LOGGER.trace("...BaseInterceptor instance created for " + this.getClass().getName() + "...");
    }
    /**
     * Destroys interceptor
     * @see com.opensymphony.xwork2.interceptor.Interceptor#destroy()
     */
    public void destroy() {
    }
    
    /**
     * Initializes interceptor
     * @see com.opensymphony.xwork2.interceptor.Interceptor#destroy()
     */
    @Override
    public void init() {
        LOGGER.trace("Intialising Interceptor " + this.getClass());
        LOGGER.trace("-=-=-=-=-=-=-=-=-=-=-=-=-");

    }

    protected void addActionError(ActionInvocation ai, String errorMsg) {
        if (ai.getAction() instanceof ValidationAware) {
            ((ValidationAware) ai.getAction()).addActionError(errorMsg);
        }
    }

    @Override
    public boolean isValidLocaleString(String paramString) {
        LOGGER.trace("isValidLocaleString() called for " + this.getClass() + " with " + paramString);
        return true;
    }

    @Override
    public boolean isValidLocale(Locale paramLocale) {
        LOGGER.trace("isValidLocale() called for " + this.getClass() + " with " + paramLocale);
        return true;
    }
}
