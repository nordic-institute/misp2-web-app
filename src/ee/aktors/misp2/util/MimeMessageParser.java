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

import static org.apache.commons.lang.CharEncoding.UTF_8;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.Properties;

import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.internet.MimeMessage;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * 
 */
public class MimeMessageParser {

    private static final Logger LOGGER = LogManager.getLogger(MimeMessageParser.class.getName());
    private MimeMessage mimeMessage;

    /**
     * @param mimeMessageAsString used to make {@link MimeMessage}
     */
    public MimeMessageParser(String mimeMessageAsString) {
        try {
            ByteArrayInputStream byteArrayInput = new ByteArrayInputStream(mimeMessageAsString.getBytes(UTF_8));
            mimeMessage = new MimeMessage(Session.getInstance(new Properties()), byteArrayInput);
        } catch (UnsupportedEncodingException e) {
            LOGGER.error(e.getMessage(), e);
        } catch (MessagingException e) {
            LOGGER.error(e.getMessage(), e);
        }
    }

    /**
     * @return mimeMessages content type
     */
    public String getContentType() {
        try {
            return mimeMessage.getContentType().trim();
        } catch (MessagingException e) {
            LOGGER.error(e.getMessage(), e);
        }
        return null;
    }

    /**
     * @return mimeMessages InputStream, if unsuccessful then null instead
     * @throws IOException getting mimeMessage InputStream fails
     */
    public InputStream getContentStream() throws IOException {
        try {
            return mimeMessage.getInputStream();
        } catch (MessagingException e) {
            LOGGER.error(e.getMessage(), e);
        } catch (IOException e) {
            throw new IOException(e.getMessage());
        }
        return null;
    }
}
