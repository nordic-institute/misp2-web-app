package ee.aktors.misp2;

import org.apache.commons.io.FileUtils;
import org.junit.Assert;
import org.junit.Ignore;
import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebElement;
import org.springframework.http.HttpStatus;

import java.io.File;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

import static org.junit.Assert.*;


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

    @Test
    public void portalSaveSucceeds() throws Exception {

        URL url = new URL( baseUrl +"/admin");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        assertEquals("admin endpoint should reply with status 200",
                HttpStatus.OK.value(), connection.getResponseCode()
        );

        AdminLogin();

        By addPortalButtonSelector = By.cssSelector("#content > div > span > a");
        assertTrue(
                "Add Portal button is found after portal admin login",
                isElementPresent(addPortalButtonSelector)
        );
        driver.findElement(addPortalButtonSelector).click();

        driver.findElement(By.id("savePortal_portalNames_0__description")).sendKeys("Test Portal(ET)");
        driver.findElement(By.id("savePortal_portalNames_1__description")).sendKeys("Test Portal(EN)");
        driver.findElement(By.id("savePortal_orgNames_0__description")).sendKeys("NIIS");
        driver.findElement(By.id("savePortal_orgNames_1__description")).sendKeys("NIIS");
        driver.findElement(By.id("savePortal_org_code")).sendKeys("1111");
        driver.findElement(By.id("orgMemberClass-button")).click();
        List<WebElement> orgMemberClassElements = driver.findElements(By.cssSelector("#orgMemberClass-menu > li"));
        assertFalse(orgMemberClassElements.isEmpty());
        Optional<WebElement> orgOptionElement = orgMemberClassElements.stream().filter(
                member -> member.getText().contains("ORG")
        ).findFirst();
        orgOptionElement.get().click();



        driver.findElement(By.id("savePortal_org_subsystemCode")).sendKeys("Client");
        driver.findElement(By.id("savePortal_portal_securityHost")).sendKeys(ssUrl);
        driver.findElement(By.id("savePortal_portal_messageMediator")).sendKeys(ssUrl);
        driver.findElement(By.id("service-xroad-instances-restorer")).click();
        driver.findElement(By.id("savePortal_btnSubmit")).click();
        List<WebElement> errorBoxElements = driver.findElements(By.className("error"));
        assertTrue("No Error boxes should be found",errorBoxElements.size() == 0 );
        File screenshot = ((TakesScreenshot) driver).getScreenshotAs(OutputType.FILE);
        FileUtils.copyFile(screenshot, new File("resultScreen.png"));
    }

    public void AdminLogin() {
        driver.get(baseUrl+"/admin");
        driver.findElement(By.id("loginAdmin_username")).sendKeys(username);
        driver.findElement(By.id("loginAdmin_password")).sendKeys(password);
        driver.findElement(By.id("loginAdmin_submit")).click();
    }

}
