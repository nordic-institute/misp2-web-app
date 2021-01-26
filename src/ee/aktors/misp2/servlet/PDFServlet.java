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

package ee.aktors.misp2.servlet;

import com.lowagie.text.BadElementException;
import com.lowagie.text.Image;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfReader;
import ee.aktors.misp2.ExternallyConfigured;
import ee.aktors.misp2.mail.MailSender;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.util.Const;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLConnection;
import javax.mail.MessagingException;
import javax.mail.internet.InternetAddress;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLSession;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.htmlcleaner.DomSerializer;
import org.htmlcleaner.HtmlCleaner;
import org.htmlcleaner.TagNode;
import org.w3c.dom.Document;
import org.xhtmlrenderer.layout.SharedContext;
import org.xhtmlrenderer.pdf.ITextFSImage;
import org.xhtmlrenderer.pdf.ITextOutputDevice;
import org.xhtmlrenderer.pdf.ITextRenderer;
import org.xhtmlrenderer.pdf.PDFAsImage;
import org.xhtmlrenderer.resource.ImageResource;
import org.xhtmlrenderer.swing.NaiveUserAgent;

/**
 * Pdf servlet
 */
public class PDFServlet extends HttpServlet implements ExternallyConfigured {

    private static final long serialVersionUID = 1L;
    private MailSender mailSender;
    //private String PDFCSSPATH = "resources/EE/css/xforms-pdf.css";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException,
            IOException {
        processRequest(request, response);
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException,
            IOException, ClassCastException {
        String filename = request.getParameter("filename");
        if (filename == null || filename != null && filename.isEmpty()) {
            filename = "paring";
        }
        try {
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            StringWriter writer = new StringWriter();
            IOUtils.copy(request.getInputStream(), writer, "UTF-8");
            String escapedHTML = writer.toString();
            String unescapedHTML = StringEscapeUtils.unescapeXml(escapedHTML);
            // HTML to proper XHTML (IE innerHTML messes up xhtml)
            HtmlCleaner cleaner = new HtmlCleaner();
            TagNode n = cleaner.clean(unescapedHTML);
            Document xhtmlContent = new DomSerializer(cleaner.getProperties()).createDOM(n);

            ITextRenderer renderer = new ITextRenderer();
            MISPITextUserAgent callback = new MISPITextUserAgent(request);
            callback.setSharedContext(renderer.getSharedContext());
            renderer.getSharedContext().setUserAgentCallback(callback);
            renderer.setDocument(xhtmlContent, null);
            renderer.layout();
            renderer.createPDF(output);
            response.reset();
            response.setContentType(Const.MIME_PDF);
            response.setContentLength(output.size());
            response.setHeader(Const.CONTENT_DISPOSITION, "attachment;filename=" + filename + ".pdf");
            OutputStream os = response.getOutputStream();
            os.write(output.toByteArray());
        } catch (Exception ex) {
            LogManager.getLogger(this.getClass()).error(ex.getMessage(), ex);
            response.reset();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("text/plain");
            PrintWriter output = response.getWriter();
            output.print(ex.getMessage());
        }
    }

    /**
     * Wrapper method
     *
     * @author arnis.rips
     * @param file
     * @throws MessagingException
     */
    @SuppressWarnings("unused")
    private void sendFileToMail(File file, String receiverEmail, String receiverName, String subject)
            throws MessagingException {
        final String host = CONFIG.getString("email.host");
        final String senderEmail = CONFIG.getString("email.sender.email");
        final String senderName = CONFIG.getString("email.sender.name");

        mailSender.connect(host); // mail server
        try {
            mailSender.sendPdfByMail(file, // attachment
                    new InternetAddress(senderEmail, senderName), // sender address and name
                    new InternetAddress(receiverEmail, receiverName), subject); // receiver address and name
        } catch (UnsupportedEncodingException ex) {
            LogManager.getLogger(this.getClass()).error(ex.getMessage(), ex);
        }
    }

    /**
     * MISP custom user-agent for PDF generating Resolves resources (ie. images) from Orbeon with provided cookie and
     * scales it to the PDF needs prototype: org.xhtmlrenderer.pdf.ITextUserAgent
     *
     */
    public class MISPITextUserAgent extends NaiveUserAgent {
        HttpServletRequest req;
        private ITextOutputDevice textOutputDevice;
        private SharedContext aSharedContext;

        /**
         * @param req sets req
         */
        public MISPITextUserAgent(HttpServletRequest req) {
            this.req = req;
        }

        /**
         *  (non-Javadoc)
         * @see org.xhtmlrenderer.swing.NaiveUserAgent#getImageResource(java.lang.String)
         * @param uri uri
         * @return image resource
         */
        @SuppressWarnings("unchecked")
        public ImageResource getImageResource(String uri) {
            ImageResource resource = null;
            uri = resolveURI(uri);
            resource = (ImageResource) _imageCache.get(uri);
            if (resource == null) {
                InputStream is = resolveAndOpenStream(uri);
                if (is != null) {
                    try {
                        URL url = new URL(uri + "?JSESSIONID=" + req.getSession().getId());
                        if (url.getPath() != null && url.getPath().toLowerCase().endsWith(".pdf")) {
                            PdfReader reader = textOutputDevice.getReader(url);
                            PDFAsImage image = new PDFAsImage(url);
                            Rectangle rect = reader.getPageSizeWithRotation(1);
                            image.setInitialWidth(rect.getWidth() * textOutputDevice.getDotsPerPoint());
                            image.setInitialHeight(rect.getHeight() * textOutputDevice.getDotsPerPoint());
                            resource = new ImageResource(url.getPath(), image);
                        } else {
                            Image image = Image.getInstance(IOUtils.toByteArray(is));
                            scaleToOutputResolution(image);
                            resource = new ImageResource(url.getPath(), new ITextFSImage(image));
                        }
                        _imageCache.put(uri, resource);
                    } catch (IOException e) {
                        e.printStackTrace();
                    } catch (BadElementException e) {
                        e.printStackTrace();
                    } catch (URISyntaxException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                }
            }
            if (resource == null) {
                resource = new ImageResource("", null);
            }
            return resource;
        }

        protected InputStream resolveAndOpenStream(String uri) {
            InputStream is = null;
            uri = resolveURI(uri);
            try {
                HttpSession session = req.getSession();
                Portal portal = (Portal) session.getAttribute(Const.SESSION_PORTAL);

                if (portal.getXroadVersionAsInt() == Const.XROAD_VERSION.V4.getIndex()
                        && new URL(uri).getProtocol().toUpperCase().equals("HTTPS")) {
                    HttpsURLConnection.setDefaultHostnameVerifier(new NullHostnameVerifier());
                }
                URLConnection uc = new URL(uri).openConnection();
                if (uc instanceof HttpURLConnection && uri.startsWith(getBaseURL())) {
                    HttpURLConnection huc = (HttpURLConnection) uc;
                    String cookie = req.getHeader("Cookie");
                    huc.setRequestProperty("Cookie", cookie);
                    huc.connect();
                    is = huc.getInputStream();
                } else {
                    is = uc.getInputStream();
                }
            } catch (java.net.MalformedURLException e) {
                LogManager.getLogger(this.getClass()).error("bad URL given: " + uri);
            } catch (java.io.FileNotFoundException e) {
                LogManager.getLogger(this.getClass()).error("item at URI " + uri + " not found");
            } catch (IOException e) {
                LogManager.getLogger(this.getClass()).error("IO problem for " + uri);
            }
            return is;
        }

        private void scaleToOutputResolution(Image image) {
            float factor = aSharedContext.getDotsPerPixel();
            image.scaleAbsolute(image.getWidth() * factor, image.getHeight() * factor);
        }

        /**
         * @return sharedContext
         */
        public SharedContext getSharedContext() {
            return aSharedContext;
        }

        /**
         * @param sharedContext sharedContext to set
         */
        public void setSharedContext(SharedContext sharedContext) {
            aSharedContext = sharedContext;
        }

    }

    private static class NullHostnameVerifier implements HostnameVerifier {
        public boolean verify(String hostname, SSLSession session) {
            return true;
        }
    }
}
