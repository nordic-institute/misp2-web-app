package ee.aktors.misp2;

import org.junit.Test;
import java.util.concurrent.TimeUnit;
import static junit.framework.TestCase.assertTrue;

public class MobileIdIT extends BaseUITest {

    @Test
    public void mobileIdLoginSucceeds() throws Exception {
        mobileIDLogin();
        driver.manage().timeouts().implicitlyWait( 5, TimeUnit.SECONDS);
        assertTrue(isTextPresent("No portals assigned to you"));
    }
}
