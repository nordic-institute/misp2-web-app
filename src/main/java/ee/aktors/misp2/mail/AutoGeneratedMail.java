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

package ee.aktors.misp2.mail;

import static ee.aktors.misp2.ExternallyConfigured.CONFIG;

import java.io.UnsupportedEncodingException;

import javax.mail.internet.InternetAddress;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author arnis.rips
 */
public abstract class AutoGeneratedMail extends MailSender {

    private final String senderEmail = CONFIG.getString("email.sender.email");
    private final String senderName = CONFIG.getString("email.sender.name");
    private final String host = CONFIG.getString("email.host");
    private String subject = DEFAULT_SUBJECT;
    private String receiverEmail;
    private String receiverName;
    private static final Logger LOGGER = LogManager.getLogger(AutoGeneratedMail.class.getName());

    protected String createBody() {
        StringBuilder body = new StringBuilder(getText("message.autogenerated"));

        return body.append(LINEBREAK).toString();
    }

    /**
     * Receiver name is {@code receiverName}.
     * Send email to {@code receiverEmail}.
     * Email title/subject is {@code subject}
     */
    public void send() {
        connect(host);
        if (getReceiverEmail() == null || getReceiverEmail().isEmpty()) {
            throw new IllegalArgumentException("Receiver email not set");
        }
        try {
            sendMail(new InternetAddress(senderEmail, senderName),
                    new InternetAddress(getReceiverEmail(), getReceiverName()),
                    getSubject(), createBody());
        } catch (UnsupportedEncodingException ex) {
            LOGGER.error(ex.getMessage(), ex);
        }
    }

    /**
     * @return the subject
     */
    public String getSubject() {
        return subject;
    }

    /**
     * @param subjectNew the subject to set
     */
    public void setSubject(String subjectNew) {
        this.subject = subjectNew;
    }

    /**
     * @return the receiverEmail
     */
    public String getReceiverEmail() {
        return receiverEmail;
    }

    /**
     * @param receiverEmailNew the receiverEmail to set
     */
    public void setReceiverEmail(String receiverEmailNew) {
        this.receiverEmail = receiverEmailNew;
    }

    /**
     * @return the receiverName
     */
    public String getReceiverName() {
        return receiverName;
    }

    /**
     * @param receiverNameNew the receiverName to set
     */
    public void setReceiverName(String receiverNameNew) {
        this.receiverName = receiverNameNew;
    }


}
