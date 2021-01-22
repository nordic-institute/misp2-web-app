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
package ee.aktors.misp2.util.openapi;

import java.util.Set;
import java.util.LinkedHashSet;

import org.apache.commons.lang.StringUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import ee.aktors.misp2.util.Const;

public class RestFormParser {

    private String xformsStr;
    public RestFormParser(String xformsStr) {
        this.xformsStr = xformsStr;
    }

    public String findSubQueryNames() {
        Document doc = Jsoup.parse(xformsStr, "UTF-8");
        Elements forms = doc.getElementsByTag("form");

        Set<String> subQueryNames = new  LinkedHashSet<String>();
        for (Element form : forms) {
            String action = form.attr("action");
            String method = form.attr("method");
            subQueryNames.add(method + " " + action);
        }
        return StringUtils.join(subQueryNames, Const.SUB_QUERY_NAME_SEPARATOR);
    }

}
