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

package ee.aktors.misp2.util;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Utility to help with JSON-type actions.
 * @author sander.kallo
 *
 */
public class JsonUtil {

    public static final String JSON_CONTENT_TYPE = "application/json; charset=UTF-8";

    private JsonUtil() {
    }

    public static Map<String, Object> getErrorResponseMap(String code, String message) {
        Map<String, String> errorMap = new LinkedHashMap<String, String>();
        errorMap.put("code", code);
        errorMap.put("message", message);
        Map<String, Object> respMap = new LinkedHashMap<String, Object>();
        respMap.put("error", errorMap);
        return respMap;
    }

}
