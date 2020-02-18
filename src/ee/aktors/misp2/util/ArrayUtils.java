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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.TreeSet;

/**
 *
 * @author arnis.rips
 */
public class ArrayUtils {

    private static final String SEPARATOR = ", ";

    
    
    /**
     * Concatenates given objects toString() values into a single string
     * separated by {@link ArrayUtils#SEPARATOR}
     * @param list values to concatenate into a string
     * @return string of concatenated values
     */
    public static String arrayToCSString(List<? extends Object> list) {
        if (list == null || list.isEmpty()) {
            return null;
        }
        StringBuilder result = new StringBuilder();
        Iterator<? extends Object> ob = list.iterator();

        while (ob.hasNext()) {
            result.append(ob.next().toString());
            if (ob.hasNext()) {
                result.append(SEPARATOR);
            }
        }

        return result.toString();
    }

    /**
     * Inserts elements from given map into linked hash map in sorted order.
     * @param mapToSort map to sort
     * @return LinkedHashMap with elements inserted in sorted order
     */
    public static HashMap<String, String> sortHashMap(HashMap<String, String> mapToSort) {
        HashMap<String, String> sortedMap = new LinkedHashMap<>();

        List<String> unsortedKeys = new ArrayList<>(mapToSort.keySet());
        List<String> unsortedValues = new ArrayList<>(mapToSort.values());
        TreeSet<String> sortedSet = new TreeSet<>(unsortedValues);
        Object[] sortedArray = sortedSet.toArray();
        int size = sortedArray.length;

        for (int i = 0; i < size; i++) {
            sortedMap.put(unsortedKeys.get(unsortedValues.indexOf(sortedArray[i])), (String) sortedArray[i]);
        }
        return sortedMap;
    }

    // eliminate quotes (not used atm)
    /**
     * Removes single quotes and replaces double quotes with its html definition (&quot;)
     * @param input string to remove quotes from
     * @return input string without quotes
     */
    public String eliminateQuotes(String input) {
        String output = "";
        output = input.replaceAll("\"", "&quot;").replaceAll("\'", "");
        return output;
    }
}
