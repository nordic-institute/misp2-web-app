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

package ee.aktors.misp2.beans;

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.LocaleProvider;
import com.opensymphony.xwork2.TextProvider;
import com.opensymphony.xwork2.TextProviderFactory;

import ee.aktors.misp2.provider.UserInterfaceFacadeTextProviderFactory;

import java.util.Locale;

/**
 * 
 * @author arnis.rips
 */
public abstract class GetText implements LocaleProvider {
    private transient TextProvider tp = null;
    
    @Override
    public Locale getLocale() {
        return ActionContext.getContext().getLocale();
    }
    
    @Override
    public boolean isValidLocaleString(String paramString) {
        return true;
    }

    @Override
    public boolean isValidLocale(Locale paramLocale) {
        return true;
    }
    
    // This method can be changed to 'protected' type, 
    // however, currently text provider is not used directly
    private TextProvider getTextProvider() {
        if (tp == null) { // lazy initialization, since factory instance may not be created 
                          // by the time current object is constructed
            TextProviderFactory tpf = UserInterfaceFacadeTextProviderFactory.getInstance();
            tp = tpf.createInstance(this.getClass());
        }
        return tp;
    }

    protected String getText(String param) {
        return getTextProvider().getText(param);
    }

    protected String getText(String param, String... args) {
        return getTextProvider().getText(param, args);
    }
}
