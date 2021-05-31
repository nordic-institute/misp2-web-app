/*
 * The MIT License
 * Copyright (c) 2020- Nordic Institute for Interoperability Solutions (NIIS)
 * Copyright (c) 2019 Estonian Information System Authority (RIA)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

package ee.aktors.misp2.action;

import java.io.ByteArrayInputStream;
import java.io.InputStream;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.logging.log4j.LogManager;
import org.apache.struts2.StrutsStatics;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.util.Const;

/**
 */
public class TimeoutAction extends SessionPreparedBaseAction implements StrutsStatics {
    private static final int MILLISECONDS = 1000;
    private static final double MINUTES = 60.0;
    private static final long serialVersionUID = 1L;
    private InputStream inputStream;
    private final long configGiveWarningBeaforeXMinutes = CONFIG.getLong("sessionTimeoutWarnTime");
    private long lastAccessedTimeXSeconds;
    private long currentTimeXSeconds;
    private long inactiveXSeconds;
    private Integer timeoutInXMinutes;
    private String result = "{\"result\" : \"false\", \"message\" : \"\"}";

    /**
     */
    public TimeoutAction() {
    }

    /**
     * @return SUCCESS
     * @throws Exception can throw
     */
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String checkTimeout() throws Exception {
        HttpServletRequest req = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
        HttpSession session = req.getSession(false);
        lastAccessedTimeXSeconds = (Long) session.getAttribute(Const.SESSION_LAST_ACCESS_TIME) / MILLISECONDS;
        currentTimeXSeconds = System.currentTimeMillis() / MILLISECONDS;
        inactiveXSeconds = currentTimeXSeconds - lastAccessedTimeXSeconds;
        timeoutInXMinutes = (int) Math.ceil((session.getMaxInactiveInterval() - (int) (inactiveXSeconds)) / MINUTES);
        boolean hasInactiveTimePassedWarningTime = timeoutInXMinutes <= configGiveWarningBeaforeXMinutes;
        LogManager.getLogger(this.getClass()).debug(" Timeout warning: " + hasInactiveTimePassedWarningTime + " " 
                + " timeout from now: " +  timeoutInXMinutes + "  conf warning: " + configGiveWarningBeaforeXMinutes
                + " session timeout: " + session.getMaxInactiveInterval() );
        boolean sessionExpired = timeoutInXMinutes <= 0;
        if (sessionExpired) {
            session.invalidate();
            return "session_expired";
        }
        if (hasInactiveTimePassedWarningTime) {
            setWarningMessage();
        }
        LogManager.getLogger(this.getClass()).debug("message: " + result);
        inputStream = new ByteArrayInputStream(result.getBytes("UTF-8"));
        return SUCCESS;
    }

    /**
     * @return the inputStream
     */
    public InputStream getInputStream() {
        return inputStream;
    }

    private void setWarningMessage() {
        result = "{\"result\" : \"true\", \"message\" : \""
                + getText("text.timeoutWarnMessage", new String[] {timeoutInXMinutes.toString() }) + "\"}";
    }
}
