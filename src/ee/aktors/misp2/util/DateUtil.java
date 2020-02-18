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

package ee.aktors.misp2.util;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import javax.xml.bind.DatatypeConverter;

/**
 * Date utils
 */
public final class DateUtil {

    private DateUtil() {
    }
    
    /**
     * @param date a date value
     * @return A string containing a lexical representation of xsd:date
     */
    public static String convertDateToISODate(Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        return DatatypeConverter.printDate(calendar);
    }

    /**
     * @param isoDate A string containing lexical representation of xsd:Date.
     * @return A Date value represented by the string argument.
     */
    public static Date convertISODateToDate(String isoDate) {
        Calendar calendar = DatatypeConverter.parseDate(isoDate);
        return calendar.getTime();
    }

    public static String convertDateToUsDate(Date date) {
        String pattern = "yyyy-MM-dd hh:MM:ss";
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
        return simpleDateFormat.format(date);
    }
    
}
