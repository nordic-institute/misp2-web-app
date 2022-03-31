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

package ee.aktors.misp2.action.crypto.dto;

import com.opensymphony.xwork2.TextProvider;

import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Translations for digital signing
 */
public class TranslationsResult extends Result{

    public static final String ERROR_SERVER = "digiSigning.error.server";
    public static final String ERROR_INPUT_PHONE = "digiSigning.error.input.phoneNr";
    public static final String ERROR_INPUT_SSN = "digiSigning.error.input.ssn";
    public static final String ERROR_MID_NOT_USER = "digiSigning.error.mid.notUser";
    public static final String ERROR_USER_CANCELLED = "digiSigning.error.userCancelled";
    public static final String ERROR_MID_SESSION_TIMEOUT = "digiSigning.error.mid.sessionTimeout";
    public static final String ERROR_MID_PHONE_CONNECTION = "digiSigning.error.mid.phoneConnection";
    public static final String ERROR_MID_PHONE_CONFIGURATION = "digiSigning.error.mid.phoneConfiguration";
    public static final String ERROR_NO_CARD = "digiSigning.error.card.noCard";
    public static final String ERROR_NO_IMPLEMENTATION = "digiSigning.error.card.noImplementation";
    public static final String VERIFICATION_LABEL = "digiSigning.ok.verification.label";
    public static final String VERIFICATION_MESSAGE = "digiSigning.ok.verification.message";
    public static final String TEXT_BUTTON_OK = "label.button.ok";
    public static final String ERROR_LABEL = "digiSigning.error.label";


    private Map<String, String> translations;

    public TranslationsResult(TextProvider textProvider) {
        translations = Stream.of(ERROR_SERVER, ERROR_INPUT_PHONE, ERROR_INPUT_SSN, ERROR_MID_NOT_USER,
                                 ERROR_USER_CANCELLED,ERROR_MID_SESSION_TIMEOUT, ERROR_MID_PHONE_CONNECTION,
                                 ERROR_MID_PHONE_CONFIGURATION, ERROR_NO_CARD, ERROR_NO_IMPLEMENTATION,
                                 VERIFICATION_LABEL, VERIFICATION_MESSAGE, TEXT_BUTTON_OK, ERROR_LABEL)
                             .collect(Collectors.toMap(key -> key, textProvider::getText));

    }

    public Map<String, String> getTranslations() {
        return translations;
    }
}