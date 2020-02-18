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

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

import org.apache.commons.codec.binary.Base64;

/**
 * Password utils
 */
/**
 * @author kristjan.kiolein
 *
 */
public final class PasswordUtil {
    private static final int SALT_LENGTH = 20;
    private static final String DGST_ALG = "SHA-1";
    private static final int ITERATIONS = 100;

    private PasswordUtil() {
    }

    /**
     * Hashes password
     * @param password string to encrypt
     * @param salt salt to use for hashing
     * @return hash of password
     * @throws NoSuchAlgorithmException if given algorithm is not found (DGST_ALG9)
     * @throws UnsupportedEncodingException id encoding is not supported (UTF-8)
     */
    public static String encryptPassword(String password, String salt) throws NoSuchAlgorithmException,
            UnsupportedEncodingException {
        return getHash(password, salt, ITERATIONS);
    }

    /**
     * @return random salt using SHA1PRNG rng
     * @throws NoSuchAlgorithmException if SHA1PRNG was not found
     * @throws UnsupportedEncodingException if bad encoding
     */
    public static String getSalt() throws NoSuchAlgorithmException, UnsupportedEncodingException {
        SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
        byte salt[] = new byte[SALT_LENGTH];
        random.nextBytes(salt);
        return getBase64String(salt);
    }

    /**
     * @param input string to hash
     * @param salt salt to use
     * @param iterations how many times to hash
     * @return hash value
     * @throws NoSuchAlgorithmException if given algorithm is not found (DGST_ALG9)
     * @throws UnsupportedEncodingException id encoding is not supported (UTF-8)
     */
    public static String getHash(String input, String salt, int iterations) throws NoSuchAlgorithmException,
            UnsupportedEncodingException {
        MessageDigest digest = MessageDigest.getInstance(DGST_ALG);
        digest.reset();
        digest.update(Base64.decodeBase64(salt));
        byte[] bInput = digest.digest(input.getBytes("UTF-8"));

        for (int i = 0; i < iterations; i++) {
            digest.reset();
            bInput = digest.digest(bInput);
        }

        return getBase64String(bInput);
    }

    /**
     * @param input byte array to turn into string
     * @return string in UTF-8 base 64
     * @throws UnsupportedEncodingException if UTF-8 is not supported
     */
    public static String getBase64String(byte[] input) throws UnsupportedEncodingException {
        return new String(Base64.encodeBase64(input), "UTF-8");
    }
}
