package ee.aktors.misp2;

import java.net.MalformedURLException;
import java.net.URL;
import java.time.Duration;
import org.junit.After;
import org.junit.Before;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxOptions;
import org.openqa.selenium.remote.RemoteWebDriver;

public class BaseUITest {

  protected static final String MOBILE_ID_DEMO_NUMBER_1 = "+37200000566";
  protected static final String MODILE_ID_DEMO_SSN_1 = "60001018800";
  protected static final Long defaultImplicitWaitTimeout = 30L;
  protected FirefoxOptions options;
  protected WebDriver driver;
  protected String baseUrl;
  protected String ssUrl;
  protected boolean serverBeforeConfiguration = false;
  protected String username;
  protected String password;
  protected String testSSN = "EE49002124277";

  @Before
  public void setUp() throws MalformedURLException {
    System.setProperty("webdriver.gecko.driver", "/usr/bin/geckodriver");
    options = new FirefoxOptions();
    options.setHeadless(true);
    driver = new RemoteWebDriver(new URL("http://localhost:4444"), options);
    String misp2Port = "9090";
    ssUrl = "http://localhost/";
    baseUrl = "http://localhost:"+ misp2Port +"/misp2";
    username = "misp2";
    password = "secret";
    serverBeforeConfiguration = Boolean
        .parseBoolean(System.getProperty("server.before.configuration"));
    driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(defaultImplicitWaitTimeout));
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

  public void userLogin() {
    driver.get(baseUrl+"/login.action");
    driver.findElement(By.id("formLogin_username")).sendKeys(testSSN);
    driver.findElement(By.id("formLogin_password")).sendKeys(password);
    driver.findElement(By.id("formLogin_submit")).click();
  }

  public void mobileIDLogin() {
    driver.get(baseUrl+"/login.action");
    driver.findElement(By.name("mobileNr")).sendKeys(MOBILE_ID_DEMO_NUMBER_1);
    driver.findElement(By.name("personalCode")).sendKeys(MODILE_ID_DEMO_SSN_1);
    driver.findElement(By.id("mobileIDLoginStart_0")).click();
  }

  public void adminLogin() {
    driver.get(baseUrl+"/admin");
    driver.findElement(By.id("loginAdmin_username")).sendKeys(username);
    driver.findElement(By.id("loginAdmin_password")).sendKeys(password);
    driver.findElement(By.id("loginAdmin_submit")).click();
  }
}
