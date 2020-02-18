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

import com.opensymphony.xwork2.LocaleProvider;
import com.opensymphony.xwork2.LocalizedTextProvider;
import com.opensymphony.xwork2.TextProviderSupport;
import java.util.ResourceBundle;

/**
 * Provide UI-facade-specific translations.
 * <p>
 * For instance, webapp title is set by 'app.title' translation property.
 * Let's say translation file (e.g. package_en.properties) have the following property:
 * <pre>app.title=MISP2</pre>
 * @author sander
 */
public class UserInterfaceFacadeTextProvider extends TextProviderSupport {

    /**
     * Initialize text provider for user interface facades
     * @param clazz provider class
     * @param provider locale provider instance
     * @param localizedTextProvider localized text provider instance
     */
    public UserInterfaceFacadeTextProvider(Class<?> clazz, LocaleProvider provider,
            LocalizedTextProvider localizedTextProvider) {
        super(clazz, provider, localizedTextProvider);
    }
    /**
     * Initialize text provider for user interface facades
     * @param provider locale provider instance
     * @param localizedTextProvider localized text provider instance
     */
    public UserInterfaceFacadeTextProvider(ResourceBundle bundle, LocaleProvider provider,
            LocalizedTextProvider localizedTextProvider) {
        super(bundle, provider, localizedTextProvider);
    }

}
