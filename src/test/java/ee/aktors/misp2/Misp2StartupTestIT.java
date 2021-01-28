package ee.aktors.misp2;

import org.junit.Test;
import org.springframework.http.HttpStatus;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.util.Scanner;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;


public class Misp2StartupTestIT {

    @Test
    public void serviceResponds200() throws Exception {
        URL url = new URL("http://localhost:8080/misp2");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        assertEquals(HttpStatus.OK.value(), connection.getResponseCode());
    }


}
