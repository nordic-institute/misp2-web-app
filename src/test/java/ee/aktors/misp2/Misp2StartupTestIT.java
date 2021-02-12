package ee.aktors.misp2;

import org.junit.Assert;
import org.junit.Ignore;
import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.springframework.http.HttpStatus;

import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Objects;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;


public class Misp2StartupTestIT extends BaseUITest {

    @Test
    public void serviceResponds200() throws Exception {

        URL url = new URL(baseUrl);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        assertEquals("misp2 endpoint should reply status 200",
                HttpStatus.OK.value(), connection.getResponseCode()
        );

    }
    @Test
    public void serviceAdminEndpointResponds200() throws Exception {

        URL url = new URL( baseUrl +"/admin");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        assertEquals("admin endpoint should reply with status 200",
                HttpStatus.OK.value(), connection.getResponseCode()
        );

        AdminLogin();
        assertTrue(
                "Add Portal button is found after portal admin login",
                isElementPresent(By.cssSelector("#content > div > span > a"))
        );

    }

    public void AdminLogin() {
        driver.get(baseUrl+"/admin");
        driver.findElement(By.id("loginAdmin_username")).sendKeys(username);
        driver.findElement(By.id("loginAdmin_password")).sendKeys(password);
        driver.findElement(By.id("loginAdmin_submit")).click();
    }

}
