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
package ee.aktors.misp2.util.openapi.generator.lang;

import static ee.aktors.misp2.util.openapi.generator.lang.Lang.*;

import java.util.HashMap;
import java.util.LinkedHashMap;

/**
 * Container for language translations map for OpenApiFormBuilder.
 */
public class OpenApiFormTranslations {
    public static class Translation extends LinkedHashMap<Lang, String> {
        private static final long serialVersionUID = 1L;
    }
    public final Translation submit          = new Translation();
    public final Translation back            = new Translation();
    public final Translation unspecifiedResponse = new Translation();
    public final Translation readonly        = new Translation();
    public final Translation multipartSection = new Translation();
    
    public OpenApiFormTranslations() {
        submit.put(en, "Submit");
        submit.put(et, "Esita päring");
        
        back.put(en, "Back");
        back.put(et, "Tagasi");
        
        unspecifiedResponse.put(en, "Unspecified response");
        unspecifiedResponse.put(et, "Tundmatu vastus");
        
        readonly.put(en, "Read-only");
        readonly.put(et, "Kirjutuskaitstud");
        
        multipartSection.put(en, "Multipart section");
        multipartSection.put(et, "Multipart sektsioon");
    }
}
