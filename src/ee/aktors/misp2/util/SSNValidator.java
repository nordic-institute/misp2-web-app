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

import javax.transaction.NotSupportedException;

/**
 *
 * @author arnis.rips
 */
public final class SSNValidator {

    private static final int ELEVEN = 11;
    private static final int NINE = 9;
    private static final int TEN = 10;
    private static final int THREE = 3;
    private static final int ESTONIAN_ID_EXTENSION_LENGTH = 11;

    private SSNValidator() { }
    
    
    /**
     * @param ssn ssn to validate
     * @param countryCode country code to check if is estonia
     * @return true if is calid estonian ssn, false otherwise
     * @throws NotSupportedException if given country ssn is not supported
     */
    public static boolean validateSSN(String ssn, String countryCode) throws NotSupportedException {
        if (countryCode.equalsIgnoreCase("ee")) {
            return estonianSsn(ssn);
        } else {
            throw new NotSupportedException("Country with code " + countryCode + " currently not supported.");
        }
    }

    /**
     * Valideerib Eesti isikukoodi
     * @param ik persons id extension
     * @return  true if is valid estonian id code, false otherwise
     */
    private static boolean estonianSsn(String ik) {
        if (ik == null || ik.length() != ESTONIAN_ID_EXTENSION_LENGTH) {
            return false;
        }
        int check = 0;
        int sum1 = 0;
        int sum2 = 0;
        int k1 = 1;
        int k2 = THREE;
        for (int idx = 0; idx < TEN; idx++) {
            try {
                int nr = Integer.parseInt(ik.substring(idx, idx + 1));
                sum1 += nr * k1;
                sum2 += nr * k2;
                k1 = (k1 == NINE) ? 1 : k1 + 1;
                k2 = (k2 == NINE) ? 1 : k2 + 1;
            } catch (NumberFormatException e) {
                return false;
            }
        }
        if (sum1 % ELEVEN < TEN) {
            check = sum1 % ELEVEN;
        } else {
            if (sum2 % ELEVEN < TEN) {
                check = sum2 % ELEVEN;
            } else {
                check = 0;
            }
        }
        int nr = 0;
        try {
            nr = Integer.parseInt(ik.substring(TEN));
        } catch (NumberFormatException e) {
            return false;
        }
        if (nr == check) {
            return true;
        } else {
            return false;
        }
    }

}
