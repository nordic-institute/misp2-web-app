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

import static org.junit.Assert.*;

import java.util.List;

import org.junit.Test;

import ee.aktors.misp2.beans.ListClassifierItem;

/**
 * Test classifier parser
 */
public class XmlSimpleClassifierParserTest {

    /**
     * Tests basic usage of XmlSimpleClassifierParser-s parseXml() method
     */
    @Test
    public void testSimpleClassifierParser() {
        String start = "<xtee.riigid>";
        String end = "</xtee.riigid>";
        String xml1 = "<item><name>Afghanistan</name><code>AFG</code></item>";
        String xml2 = "<item><name>Åland Islands</name><code>ALA</code></item>";
        String xml3 = "<item><name>Albania</name><code>ALB</code></item>";
        String xml4 = "<item><name>Algeria</name><code>DZA</code></item>";
        String xml5 = "<item><name>American Samoa</name><code>ASM</code></item>";
        String xml = start + xml1 + xml2 + xml3 + xml4 + xml5 + end;

        XmlSimpleClassifierParser xcp = new XmlSimpleClassifierParser("item", "name", "code");

        List<ListClassifierItem> list = xcp.parseXml(xml);
        assertEquals(list.get(0).getFirst(), "Afghanistan");
        assertEquals(list.get(0).getSecond(), "AFG");
        
        assertEquals(list.get(2).getFirst(), "Albania");
        assertEquals(list.get(2).getSecond(), "ALB");
        
        // RIA checkstyle workaround to be able to use number 4
        final int fourth = 4;
        assertEquals(list.get(fourth).getFirst(), "American Samoa");
        assertEquals(list.get(fourth).getSecond(), "ASM");
    }

}
