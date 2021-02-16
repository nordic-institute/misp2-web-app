package ee.aktors.misp2;

import java.util.Objects;
import java.util.concurrent.TimeUnit;
import org.junit.After;
import org.junit.Before;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;

public class BaseUITest {

  protected WebDriver driver;
  protected String baseUrl;
  protected String ssUrl;
  protected boolean serverBeforeConfiguration = false;
  protected String username;
  protected String password;
  protected String testSSN = "EE49002124277";

  @Before
  public void setUp() {
    System.setProperty("webdriver.gecko.driver", "/usr/bin/geckodriver");
    driver = new FirefoxDriver();
    String misp2Port = Objects.requireNonNull(
            System.getProperty("misp2.it-test.misp2_port"),
            "misp2.development.misp2_port property needs to be defined"
    );

    ssUrl = Objects.requireNonNull(
            System.getProperty("misp2.it-test.ss_url"),
            "misp2.it-test.ss_url property needs to be defined"
    );
    baseUrl = "http://localhost:"+ misp2Port +"/misp2";
    username = Objects.requireNonNull(System.getProperty("misp2.it-test.username"),"misp2.it-test.username property needed");
    password = Objects.requireNonNull(System.getProperty("misp2.it-test.password"),"misp2.it-test.password property needed");
    serverBeforeConfiguration = Boolean
        .parseBoolean(System.getProperty("server.before.configuration"));
    driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS );
  }

  @After
  public void tearDown() {
    driver.quit();
  }

  protected boolean isTextPresent(String s) {
    WebElement bodyElement = driver.findElement(By.tagName("body"));
    return bodyElement.getText().contains(s);
  }

  protected boolean isElementPresent(By by) {
    try {
      driver.findElement(by);
      return true;
    } catch (NoSuchElementException e) {
      return false;
    }
  }
}
