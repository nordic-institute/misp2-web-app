package ee.aktors.misp2;

import org.apache.commons.io.IOUtils;
import org.junit.Test;
import org.springframework.http.HttpStatus;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Objects;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class Misp2ServletCheckIT extends BaseUITest {

    @Test
    public void classifierCheck() throws Exception {

        userLogin();
        // TODO: What it needs to get SESSION_PORTAL initialized?
        URL url = new URL(baseUrl + "/classifier");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        assertEquals("misp2 /classifier endpoint should reply status 200",
                HttpStatus.OK.value(), connection.getResponseCode()
        );

    }

    @Test
    public void loadCertificationCheck() throws Exception {
        userLogin();
        URL url = new URL(baseUrl + "/loadCertification" + "?certificate=fakecert");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        assertEquals("misp2 /loadCertification endpoint should reply status 200",
                HttpStatus.OK.value(), connection.getResponseCode()
        );

    }

    @Test
    public void ssnValidationCheck() throws Exception {
        userLogin();
        URL url = new URL(baseUrl + "/ssnValidation" + "?ssn=fakessn&countryCode=EE");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        assertEquals("misp2 /loadCertification endpoint should reply status 200",
                HttpStatus.OK.value(), connection.getResponseCode()
        );
        assertEquals("text/xml;charset=UTF-8", connection.getContentType());
    }

    @Test
    public void getXSLTCheck() throws Exception {
        userLogin();
        URL url = new URL(baseUrl + "/getXSLT");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setDoOutput(true);
        connection.setRequestMethod("POST");


        assertEquals("misp2 /getXSLT endpoint should reply status 200",
                HttpStatus.OK.value(), connection.getResponseCode()
        );
        assertEquals("text/xml", connection.getContentType());

    }

    @Test
    public void generatePDFCheck() throws Exception {
        final Integer MINIMUM_ACCEPTABLE_PDF_LENGTH = 2000;
        final String TEST_FILE_PATH = "xforms/aktorstest-complex-xroad-v6.xhtml";
        userLogin();
        StringBuilder urlBuilder = new StringBuilder(baseUrl);
        urlBuilder.append("/generate-pdf");
        URL url = new URL(urlBuilder.toString() );
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestProperty("Content-Type","text/xhtml");
        connection.setDoOutput(true);
        connection.setDoInput(true);
        connection.setRequestMethod("POST");
        try (OutputStream outputStream = connection.getOutputStream();
             InputStream testHtmlFileStream = this.getClass().getResourceAsStream("/"+TEST_FILE_PATH)
        ) {
            Objects.requireNonNull(testHtmlFileStream, TEST_FILE_PATH + " could not be opened!");
            IOUtils.copy(testHtmlFileStream,outputStream);
        }

        assertEquals("misp2 /generate-pdf endpoint should reply status 200",
                HttpStatus.OK.value(), connection.getResponseCode()
        );
        assertEquals("application/pdf", connection.getContentType());
        final Integer pdfLength = connection.getContentLength();
        assertTrue("Too small pdf file generated, only " + pdfLength.toString() + " long",
                pdfLength > MINIMUM_ACCEPTABLE_PDF_LENGTH);

    }

    // TODO: echo
}
