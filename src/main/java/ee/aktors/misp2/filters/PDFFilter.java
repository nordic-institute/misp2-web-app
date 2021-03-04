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

package ee.aktors.misp2.filters;

import static ee.aktors.misp2.ExternallyConfigured.CONFIG;

import com.lowagie.text.BadElementException;
import com.lowagie.text.Image;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfReader;
import com.opensymphony.xwork2.ActionContext;
import ee.aktors.misp2.beans.GetText;
import ee.aktors.misp2.mail.MailSender;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Const.XROAD_VERSION;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
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
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.text.Normalizer;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import javax.mail.MessagingException;
import javax.mail.internet.InternetAddress;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLSession;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;
import javax.servlet.http.HttpSession;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.docx4j.org.xhtmlrenderer.layout.SharedContext;
import org.docx4j.org.xhtmlrenderer.pdf.ITextFSImage;
import org.docx4j.org.xhtmlrenderer.pdf.ITextOutputDevice;
import org.docx4j.org.xhtmlrenderer.pdf.ITextRenderer;
import org.docx4j.org.xhtmlrenderer.pdf.PDFAsImage;
import org.docx4j.org.xhtmlrenderer.resource.ImageResource;
import org.docx4j.org.xhtmlrenderer.swing.NaiveUserAgent;
import org.htmlcleaner.DomSerializer;
import org.htmlcleaner.HtmlCleaner;
import org.htmlcleaner.TagNode;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.w3c.dom.Document;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSSerializer;

/**
 * filter for preprocessing XHTML with JSoup and generating PDF using XHTMLRenderer library
 * @author mihhail.kornyshev
 */
public class PDFFilter extends GetText implements Filter {
    private static final int SSL_PORT = 443;
    private static final int HTTP_PORT = 80;
    ServletContext sc;
    private static final Logger LOGGER = LogManager.getLogger(PDFFilter.class.getName());
    HashMap<String, String> parameters;

    private MailSender mailSender;

    /**
     */
    public PDFFilter() {
    }

    @Override
    public void destroy() {
    }

    /**
     * @see Filter#doFilter(ServletRequest, ServletResponse, FilterChain)
     */
    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain filterChain) throws IOException,
            ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) resp;
        try {

            // do filtering when URL has log parameter with value "true" and case is not empty
            if ("true".equals(request.getParameter("pdf")) && !request.getParameter("case").equals("")) {
                LOGGER.debug("PDF filter start");
                String basepath = CONFIG.getString("misp2.internal.url");
                String mail = request.getParameter("email");
                String encrypted = request.getParameter("encrypt");
                String signed = request.getParameter("sign");
                String sendPDF = request.getParameter("sendPdfByMail");
                String queryDesc = request.getParameter("description");
                if (queryDesc != null)
                    queryDesc = URLDecoder.decode(queryDesc, "UTF-8");
                else
                    queryDesc = "teenus";
                HttpSession session = request.getSession();
                Person person = (Person) session.getAttribute(Const.SESSION_USER_HANDLE);
                String receiver = person.getFullName();
                // Buffer output of original servlet
                BufferedServletResponse buffer = new BufferedServletResponse(response);
                LOGGER.debug("Request URL: " + getURL(request));

                filterChain.doFilter(request, buffer);

                // If redirect or error occurs in chain, then stop
                if (buffer.isCommitted())
                    return;
                ByteArrayInputStream inputFromOrbeon = new ByteArrayInputStream(buffer.getContent());
                StringWriter writer = new StringWriter();
                IOUtils.copy(inputFromOrbeon, writer, "UTF-8");
                String xhtml = writer.toString();

                LOGGER.trace("PDF creation: user: " + person.getSsn());
                if (xhtml == null || xhtml.trim().isEmpty())
                    throw new IOException("Orbeon returned empty PDF.");
                LOGGER.trace("PDF creation: 1. initial html:" + xhtml);
                org.jsoup.nodes.Document doc = Jsoup.parse(xhtml, "UTF-8");
                Elements children = doc.select("*");
                for (Element child : children) {
                    if (child.id().equals("footer-left")) {
                        Calendar cal = Calendar.getInstance();
                        cal.add(Calendar.DAY_OF_YEAR, 0);
                        Date today = cal.getTime();
                        String todayString = new SimpleDateFormat("dd.MM.yyyy").format(today);
                        child.append(receiver + " " + todayString);
                    }
                    if (child.className().contains("xforms-disabled")
                            || child.className().contains("xforms-repeat-template")
                            // we only want to skip elements with class 'xforms-help', but not with 'xforms-help-*'
                            // e.g. root element has class 'xforms-help-appearance-dialog'
                            || child.className().replace("xforms-help-", "").contains("xforms-help")
                            || child.className().contains("xforms-case-deselected")
                            || child.className().contains("xforms-deselected")
                            || child.className().contains("xforms-login-detected-dialog")) {
                        child.remove();
                    }
                }
                String html = doc.html();
                LOGGER.trace("PDF creation: 2. HTML after jsoup filtering:" + html);

                ByteArrayInputStream input = new ByteArrayInputStream(html.getBytes("UTF-8"));
                ByteArrayOutputStream output = new ByteArrayOutputStream();
                // HTML to proper XHTML (IE innerHTML messes up xhtml)
                HtmlCleaner cleaner = new HtmlCleaner();
                TagNode n = cleaner.clean(input, "UTF-8");
                Document xhtmlContent = new DomSerializer(cleaner.getProperties()).createDOM(n);
                LOGGER.trace("PDF creation: 3. xhtmlContent:" + getStringFromDoc(xhtmlContent));
                ITextRenderer renderer = new ITextRenderer();
                MISPITextUserAgent callback = new MISPITextUserAgent(renderer.getOutputDevice(), request);
                callback.setSharedContext(renderer.getSharedContext());
                renderer.getSharedContext().setUserAgentCallback(callback);
                renderer.setDocument(xhtmlContent, basepath);
                renderer.layout();
                renderer.createPDF(output);

                queryDesc = Normalizer.normalize(queryDesc, Normalizer.Form.NFD).replaceAll("[^\\p{ASCII}]", "");

                String pdfString = new String(output.toByteArray(), Charset.defaultCharset());
                // logger.trace("PDF creation: 4. PDF content:" + pdfString);
                /*
                if (LOGGER.getLevel() == Level.TRACE) {
                    ;
                }
                */
                if (pdfString.contains("<rdf:RDF"))
                    LOGGER.trace("PDF creation: 4.1. <rdf:RDF detected which could be a sign of failure");
                if (!("true".equals(sendPDF))) {
                    // PDF output in browser

                    LOGGER.trace("PDF creation: 5.1. PDF is outputted to browser");
                    response.reset();
                    response.setContentType(Const.MIME_PDF);
                    response.setContentLength(output.size());
                    response.setHeader(Const.CONTENT_DISPOSITION,
                            "attachment;filename=" + URLEncoder.encode(queryDesc, "UTF-8") + ".pdf");
                    OutputStream os = response.getOutputStream();
                    os.write(output.toByteArray());
                } else {
                    // Create temp pdf file and sign, encrypt, send to email

                    LOGGER.trace("PDF creation: 5.2. PDF is outputted to e-mail");
                    File file = File.createTempFile(URLEncoder.encode(queryDesc, "UTF-8"), ".pdf");
                    FileOutputStream fos = new FileOutputStream(file);
                    renderer.createPDF(fos);
                    LOGGER.debug("You can find the pdf file from: " + file.getPath());
                    fos.close();
                    // email encrypted file as attachement
                    if ("true".equals(sendPDF) && !(mail.isEmpty())) {
                        LOGGER.info("sending PDF by mail to " + mail);
                        mailSender = new MailSender();
                        sendFileToMail(file, mail, receiver, queryDesc);
                        response.setContentType("text/plain; charset=utf-8");
                        response.setStatus(HttpServletResponse.SC_OK);
                        PrintWriter success = response.getWriter();
                        success.print(mailSender.sendMailOk() + " " + mail);
                    }
                }
            } else {

                filterChain.doFilter(request, response);
            }
        } catch (Exception ex) {
            LOGGER.error("Error in PDFFilter : " + ex.getMessage(), ex);
            response.reset();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("text/plain; charset=utf-8");
            PrintWriter output = response.getWriter();

            if (mailSender == null)
                output.print(getText("xslt_styles.error.unexpected"));
            else
                output.print(mailSender.sendMailFail());
        }
    }

    /**
     * @param doc document to get as string
     * @return document as string
     */
    public String getStringFromDoc(Document doc) {
        DOMImplementationLS domImplementation = (DOMImplementationLS) doc.getImplementation();
        LSSerializer lsSerializer = domImplementation.createLSSerializer();
        return lsSerializer.writeToString(doc);
    }

    // For debugging
    /**
     * @param req http servlet request
     * @return url
     */
    public static String getURL(HttpServletRequest req) {

        String scheme = req.getScheme(); // http
        String serverName = req.getServerName(); // hostname.com
        int serverPort = req.getServerPort(); // 80
        String contextPath = req.getContextPath(); // /mywebapp
        String servletPath = req.getServletPath(); // /servlet/MyServlet
        String pathInfo = req.getPathInfo(); // /a/b;c=123
        String queryString = req.getQueryString(); // d=789

        // Reconstruct original requesting URL
        StringBuffer url = new StringBuffer();
        url.append(scheme).append("://").append(serverName);

        if (serverPort != HTTP_PORT && serverPort != SSL_PORT) {
            url.append(":").append(serverPort);
        }

        url.append(contextPath).append(servletPath);

        if (pathInfo != null) {
            url.append(pathInfo);
        }
        if (queryString != null) {
            url.append("?").append(queryString);
        }
        return url.toString();
    }


    /**
     * Wrapper method
     * 
     * @author arnis.rips
     * @param file
     * @throws MessagingException
     */
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
            LOGGER.error("UnsupportedEncodingException in PDFFilter#sendFileToMail" + ex.getMessage(), ex);
        }
    }

    /**
     * MISP custom user-agent for PDF generating Resolves resources (ie. images) from Orbeon with provided cookie and
     * scales it to the PDF needs prototype: org.xhtmlrenderer.pdf.ITextUserAgent
     *
     */
    public class MISPITextUserAgent extends NaiveUserAgent {
        HttpServletRequest req;
        private ITextOutputDevice innerOutputDevice;
        private SharedContext innerSharedContext;

        /**
         * @param outputDevice unused
         * @param req request to set
         */
        public MISPITextUserAgent(ITextOutputDevice outputDevice, HttpServletRequest req) {
            this.req = req;
            if (LOGGER.isTraceEnabled()) {
                LOGGER.trace("MISPITextUserAgent initialized with output device " + outputDevice);
            }
        }

        @SuppressWarnings("unchecked")
        @Override
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
                            PdfReader reader = innerOutputDevice.getReader(url);
                            PDFAsImage image = new PDFAsImage(url);
                            Rectangle rect = reader.getPageSizeWithRotation(1);
                            image.setInitialWidth(rect.getWidth() * innerOutputDevice.getDotsPerPoint());
                            image.setInitialHeight(rect.getHeight() * innerOutputDevice.getDotsPerPoint());
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
            LOGGER.debug(uri);
            uri = resolveURI(uri);
            try {
                Map<String, Object> session = ActionContext.getContext().getSession();
                Portal portal = (Portal) session.get(Const.SESSION_PORTAL);
                if (portal.getXroadVersionAsInt() == XROAD_VERSION.V4.getIndex()
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
                LOGGER.error("bad URL given: " + uri);
            } catch (java.io.FileNotFoundException e) {
                LOGGER.error("item at URI " + uri + " not found");
            } catch (IOException e) {
                LOGGER.error("IO problem for " + uri);
            }
            return is;
        }

        private void scaleToOutputResolution(Image image) {
            float factor = innerSharedContext.getDotsPerPixel();
            image.scaleAbsolute(image.getWidth() * factor, image.getHeight() * factor);
        }

        /**
         * @return shared context
         */
        public SharedContext getSharedContext() {
            return innerSharedContext;
        }

        /**
         * @param sharedContext shared context to set
         */
        public void setSharedContext(SharedContext sharedContext) {
            innerSharedContext = sharedContext;
        }

    }

    private static class NullHostnameVerifier implements HostnameVerifier {
        public boolean verify(String hostname, SSLSession session) {
            return true;
        }
    }

    /**
     * Helper classes to wrap any OutputStream as ServletOutputStream and use them as buffers
     * 
     * @author Tambet Matiisen
     */
    private class BufferedServletResponse extends HttpServletResponseWrapper {

        private StreamWrapper output;
        private ByteArrayOutputStream baos;
        private PrintWriter writer;
        private HashMap<String, String> headers;
        private boolean committed;

        public BufferedServletResponse(HttpServletResponse originalResponse) {
            super(originalResponse);
            baos = new ByteArrayOutputStream();
            headers = new HashMap<String, String>();
        }

        public ServletOutputStream getOutputStream() throws IOException {
            if (output == null)
                output = new StreamWrapper(baos);
            return output;
        }

        public PrintWriter getWriter() throws IOException {
            if (writer == null)
                writer = new PrintWriter(getOutputStream());
            return writer;
        }

        public byte[] getContent() {
            if (writer != null)
                writer.flush();
            return baos.toByteArray();
        }

        public void reset() {
            super.reset();
            headers.clear();
            baos.reset();
        }

        public boolean isCommitted() {
            return committed;
        }
    }

    private class StreamWrapper extends ServletOutputStream {
        private OutputStream os;

        StreamWrapper(OutputStream os) {
            this.os = os;
        }

        public void write(int b) throws IOException {
            os.write(b);
        }
         /*
        // @Override
        public boolean isReady() {
            // TODO Auto-generated method stub
            return true;
        }
        */
    }
    @Override
    public void init(FilterConfig arg0) throws ServletException {
    }

}
