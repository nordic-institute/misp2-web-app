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

package ee.aktors.misp2.provider;

import java.util.ResourceBundle;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.StrutsTextProviderFactory;
import com.opensymphony.xwork2.TextProvider;

/**
 * This factory overrides StrutsTextProviderFactory and returns 
 * {@link UserInterfaceFacadeTextProvider} as default implementation.
 * 
 * The factory is created in applicationContext.xml and
 * configured in struts.xml as a Struts default text provider factory.
 * 
 * Additional singleton class instance is set so it can later be accessed without
 * Struts or Spring context.
 * 
 * @author sander
 *
 */
public class UserInterfaceFacadeTextProviderFactory extends StrutsTextProviderFactory {
    // Hold initialized instance for easier access to provider factory
    private static UserInterfaceFacadeTextProviderFactory instance;
    private static final Logger LOGGER = LogManager.getLogger(UserInterfaceFacadeTextProviderFactory.class);
    
    public UserInterfaceFacadeTextProviderFactory() {
        // set singleton instance for easier access from GetText class.
        if (instance == null) {
            synchronized (this.getClass()) {
                if (instance == null) {
                    LOGGER.info("Setting provider factory to " + this);
                    instance = this;
                }
            }
        }
    }
    
    /**
     * @return singleton instance
     */
    public static UserInterfaceFacadeTextProviderFactory getInstance() {
        return instance;
    }
    
    @Override
    protected TextProvider getTextProvider(Class clazz) {
        return new UserInterfaceFacadeTextProvider(
                clazz, localeProviderFactory.createLocaleProvider(), localizedTextProvider);
    }

    @Override
    protected TextProvider getTextProvider(ResourceBundle bundle) {
        return new UserInterfaceFacadeTextProvider(
                bundle, localeProviderFactory.createLocaleProvider(), localizedTextProvider);
    }
}
