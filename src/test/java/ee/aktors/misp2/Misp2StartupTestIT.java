package ee.aktors.misp2;

import org.junit.Test;
import org.springframework.http.HttpStatus;

import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Objects;

import static org.junit.Assert.assertEquals;


public class Misp2StartupTestIT {
    private String misp2Port = Objects.requireNonNull(
            System.getProperty("misp2.it-test.jetty_port"),
            "misp2.it-test.jetty_port systemproperty needs to be defined"
    );
    final String baseUrlString = "http://localhost:"+ misp2Port +"/misp2";


    @Test
    public void serviceResponds200() throws Exception {

        URL url = new URL(baseUrlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        assertEquals("misp2 endpoint should reply status 200",
                HttpStatus.OK.value(), connection.getResponseCode()
        );
        url = new URL(baseUrlString + "misp/admin");
        connection = (HttpURLConnection) url.openConnection();
        assertEquals("admin endpoint should reply with status 200",
                HttpStatus.OK.value(), connection.getResponseCode()
        );
    }
    @Test
    public void serviceAdminEndpointResponds200() throws Exception {

        URL url = new URL( baseUrlString +"/admin");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        assertEquals("admin endpoint should reply with status 200",
                HttpStatus.OK.value(), connection.getResponseCode()
        );
    }

}
