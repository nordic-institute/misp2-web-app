package ee.aktors.misp2;

import org.junit.Test;
import org.openqa.selenium.By;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

public class MobileIdIT extends BaseUITest {


    @Test
    public void mobileIdLoginSucceeds() throws Exception {

        mobileIDLogin();

    }
}
