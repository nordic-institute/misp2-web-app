package ee.aktors.misp2.action;

import com.opensymphony.xwork2.ActionProxy;
import org.apache.struts2.StrutsSpringJUnit4TestCase;
import org.apache.struts2.StrutsSpringTestCase;
import org.junit.Assert;
import org.junit.Test;

import static com.opensymphony.xwork2.Action.ERROR;

public class LoginActionTest extends StrutsSpringJUnit4TestCase<LoginAction> {

    @Test
    public void testCertLoginAction() throws Exception {
        String cert1 = "totally fake";
        request.setAttribute("javax.servlet.request.X509Certificate", cert1);
        ActionProxy proxy = getActionProxy("misp2/certLogin.action");
        Assert.assertNotNull(proxy);
        String result = proxy.execute();
        Assert.assertEquals(result, ERROR);


    }


}
