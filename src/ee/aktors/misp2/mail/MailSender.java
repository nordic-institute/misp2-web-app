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

package ee.aktors.misp2.mail;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.file.Files;
import java.util.Properties;

import javax.activation.MimetypesFileTypeMap;
import javax.mail.Message.RecipientType;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.beans.GetText;

/**
 * Supports SMTP only at the moment.
 * @author arnis.rips
 */
public class MailSender extends GetText {
    private static final Logger LOGGER = LogManager.getLogger(MailSender.class.getName());
    public static final String DEFAULT_PROTOCOL = "smtp";
    public static final String DEFAULT_HOST = "localhost";
    public static final int DEFAULT_PORT = 25;
    public static final String DEFAULT_USER = "";
    public static final String DEFAULT_PASSWORD = "";
    public static final String DEFAULT_SUBJECT = "Päringu PDF (veebirakenduse poolt genereeritud)";
    public static final String DEFAULT_BODY_TEXT = "See on automaatselt genereeritud e-kiri."
                                                   + " Palun ärge vastake sellele.";
    private Session session;
    protected static final String LINEBREAK = "\n";
    protected static final String LINEBREAK_HTML = "<br />";
    protected static final String SPACE = " ";
    protected static final String SEPARATOR = ", ";
    protected static final String TAB = "\t";

// -------------------------------------------------------------------------

    /**
     * Connects with default values: port 25 and no authentication
     * @param host mail server address, default value is localhost
     */
    public void connect(String host) {
        connect(host, -1, null, null);
    }

    /**
     * Connects to given host with specified parameters. If any parameter is null then a default value is for it.
     * If already connected then new connection will not be made.
     * @param host mail server address, default value is localhost
     * @param port port to connect to, default is 25
     * @param user user name
     * @param password password
     */
    public void connect(String host, int port, String user, String password) {

        Properties props = new Properties();
        props.setProperty("mail.transport.protocol", DEFAULT_PROTOCOL);
        props.setProperty("mail.smtp.host", host != null ? host : DEFAULT_HOST);
        props.setProperty("mail.smtp.port", Integer.toString(port > 0 ? port : DEFAULT_PORT));
        props.setProperty("mail.smtp.user", user != null ? user : DEFAULT_USER);
        props.setProperty("mail.smtp.password", password != null ? password : DEFAULT_PASSWORD);

        session = Session.getDefaultInstance(props);
    }
    
    /**
     * Message body and subject are set to default.
     * @param file file to be attached to email
     * @param from who this mail is from
     * @param to who this mail is for
     * @throws MessagingException can throw
     */
    public void sendFile(File file, InternetAddress from, InternetAddress to) throws MessagingException {
        sendFile(file, from, to, null, null);
    }

    /**
     * Sends simple mail filled with default values
     * @param from address from mail is sent
     * @param to address where to the mail will be sent
     */
    public void sendDefaultMail(InternetAddress from, InternetAddress to) {
        sendMail(from, to, null, null);
    }
    
    /**
     * @param file file to be attached to email
     * @param from who this mail is from
     * @param to who this mail is for
     * @param subject title/subject of mail
     * @throws MessagingException can throw
     */
    public void sendPdfByMail(File file, InternetAddress from, InternetAddress to, String subject)
                                                                            throws MessagingException {
        String subj = getText("notify.subject.pdf") + " " + subject;
        String body = getText("message.autogenerated.pdf");
        sendFile(file, from, to, subj, body);
    }

    /**
     * Sends file with given subject and bodyText
     * @param from who this mail is from
     * @param to who this mail is for
     * @param subject title/subject of mail
     * @param bodyText message body of mail
     */
    public void sendMail(InternetAddress from, InternetAddress to, String subject, String bodyText) {
        try {

            LOGGER.debug("Starting mail send");
            MimeMessage msg = new MimeMessage(session);

            MimeMultipart mp = new MimeMultipart();
            MimeBodyPart text = new MimeBodyPart();
            text.setText((bodyText != null ? bodyText : DEFAULT_BODY_TEXT));
            mp.addBodyPart(text);

            msg.setContent(mp);

            msg.setSubject(subject != null ? subject : DEFAULT_SUBJECT);
            msg.setFrom(from);
            msg.addRecipient(RecipientType.TO, to);

            Transport.send(msg, msg.getAllRecipients());

            LOGGER.info("Mail sent to: " + to);
        } catch (MessagingException ex) {
            LOGGER.error(ex.getMessage(), ex);
        }
    }

    /**
     * Sends email with attached file.
     * @param file file to be attached to email
     * @param from who this mail is from
     * @param to who this mail is for
     * @param subject title/subject of mail
     * @param bodyText message body of mail
     * @throws MessagingException if the connection is dead or not in the connected state
     */
    public void sendFile(File file, InternetAddress from, InternetAddress to, String subject, String bodyText)
            throws MessagingException {
        if (file == null) {
            throw new IllegalArgumentException("Required parameter file is null!");
        }
        try {

            LOGGER.debug("Starting mail send");
            MimeMessage msg = new MimeMessage(session);
            MimeMultipart mp = new MimeMultipart();
            MimeBodyPart text = new MimeBodyPart();
            text.setText((bodyText != null ? bodyText : DEFAULT_BODY_TEXT));
            mp.addBodyPart(text);
            MimeBodyPart attachment = new MimeBodyPart();
            String mime = new MimetypesFileTypeMap().getContentType(file);
            attachment.setFileName(file.getName());
            attachment.setContent(Files.readAllBytes(file.toPath()), mime);
            mp.addBodyPart(attachment);
            msg.setContent(mp);
            msg.setSubject(subject != null ? subject : DEFAULT_SUBJECT);
            msg.setFrom(from);
            msg.addRecipient(RecipientType.TO, to);
            Transport.send(msg, msg.getAllRecipients());
            LOGGER.info("Sent mail to: " + to);
        } catch (UnsupportedEncodingException ex) {
            LOGGER.error("MailSender#sendFile() error" + ex.getMessage(), ex);
        } catch (IOException ex) {
            LOGGER.error("MailSender#sendFile() error" + ex.getMessage(), ex);
        } catch (MessagingException ex) {
            // logger.error("MailSender#sendFile() error" + ex.getMessage(), ex);
            throw ex;
        }
    }

    /**
     * @return gets message for "text.send_mail"
     * from {@code TextProvider}
     */
    public String sendMailOk() {
        return getText("text.send_mail");
    }

    /**
     * @return gets message for "text.send_mail_fail"
     * from {@code TextProvider}
     */
    public String sendMailFail() {
        return getText("text.send_mail_fail");
    }
}
