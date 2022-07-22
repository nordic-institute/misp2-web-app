package ee.aktors.misp2;

import org.junit.Test;
import java.time.Duration;
import static junit.framework.TestCase.assertTrue;

public class MobileIdIT extends BaseUITest {

    @Test
    public void mobileIdLoginSucceeds() throws Exception {
        mobileIDLogin();
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(5));
        assertTrue(isTextPresent("No portals assigned to you"));
    }
}
