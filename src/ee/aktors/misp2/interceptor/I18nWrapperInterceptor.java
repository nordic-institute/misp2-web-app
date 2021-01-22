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

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;
import org.apache.struts2.interceptor.I18nInterceptor;

import com.opensymphony.xwork2.ActionInvocation;

import ee.aktors.misp2.util.LanguageUtil;

/**
 * Wraps original {@link I18nInterceptor} and overrides
 * {@link I18nInterceptor#intercept(ActionInvocation)} in order to: <br/>
 * 1) Use application default locale instead of browser locale, because can't expect, that user sets his browsers
 * language settings appropriately <br/>
 * 2) Cancel switch to locale if that locale is unsupported by {@link LanguageUtil#getLanguages()}
 * 
 * @author karol.kartau
 */
public class I18nWrapperInterceptor extends I18nInterceptor {
    private static final long serialVersionUID = -6257443233261901523L;
    private static final Logger LOGGER = LogManager.getLogger(I18nWrapperInterceptor.class.getName());

    @Override
    public String intercept(ActionInvocation ai) throws Exception {
        HttpServletRequest req = (HttpServletRequest) ai.getInvocationContext().get(StrutsStatics.HTTP_REQUEST);

        setActionInvocationLocaleToSystemDefault(ai);

        String requestLocaleParameter = req.getParameter(parameterName);
        // If switch to unsupported locale is requested, then cancel it
        if (requestLocaleParameter != null && LanguageUtil.getLanguages().contains(requestLocaleParameter) == false) {
            LOGGER.debug("Locale was tried to be switched to " + requestLocaleParameter
                    + ", but was cancelled, because that locale is unsupported");
            return ai.invoke();
        }

        return super.intercept(ai);
    }

    /**
     * Set ActionInvocation locale to application default language.<br/>
     * By default this locale it set to browsers "Accept-Language" header, but using application default is better
     * practice, because can't expect user to set his browsers language appropriately
     * 
     * @param actionInvocation actionInvocation
     */
    public static void setActionInvocationLocaleToSystemDefault(ActionInvocation actionInvocation) {
        actionInvocation.getInvocationContext().setLocale(new Locale(LanguageUtil.getDefaultLanguage()));
    }

}
