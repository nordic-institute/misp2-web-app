package ee.aktors.misp2;

import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.springframework.http.HttpStatus;

import java.net.HttpURLConnection;
import java.net.URL;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

import static org.junit.Assert.*;


public class Misp2StartupTestIT extends BaseUITest {

    String testRunId = String.valueOf(Instant.now().getEpochSecond());

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

        adminLogin();
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

        adminLogin();
        
        createPortal();
        driver.manage().timeouts().implicitlyWait( 5, TimeUnit.SECONDS);
        assertNotNull("Save Successfull -notify should appear", driver.findElement(By.className("ok")));

    }

    private void addManager() {
        driver.findElement(By.partialLinkText("admin/addManager.action")).click();
        driver.findElement(By.id("usersFilter_submit")).click();
        List<WebElement> addExistingManagerButtons = driver.findElements(
                By.partialLinkText("/misp2/admin/saveManager.action?userId=")
        );
        if(addExistingManagerButtons.size()>0){
            addExistingManagerButtons.stream().findFirst().get().click();
        } else {
            assertTrue("TODO: create manager test case", false);
        }
        List<WebElement> removeManagerButtons = driver.findElements(
                By.partialLinkText("/misp2/admin/managerDelete.action")
        );
        assertFalse("No manager found for the new portal!",
                removeManagerButtons.isEmpty()
        );
    }


    
    private void createPortal() {
        By addPortalButtonSelector = By.cssSelector("#content > div > span > a");
        assertTrue(
                "Add Portal button is found after portal admin login",
                isElementPresent(addPortalButtonSelector)
        );
        driver.findElement(addPortalButtonSelector).click();

        driver.findElement(By.id("savePortal_portalNames_0__description")).sendKeys("Test Portal"+ testRunId);
        driver.findElement(By.id("savePortal_orgNames_0__description")).sendKeys("NIIS");
        driver.findElement(By.id("savePortal_portal_shortName")).sendKeys("MISP2_TEST"+testRunId);
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
    }

}
