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

package ee.aktors.misp2.util;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.model.Person;

/**
 * Session counter
 */
public class SessionCounter implements HttpSessionListener {

    private static final Logger LOG = LogManager.getLogger(SessionCounter.class);
    private static Integer totalActiveSessions;

    /**
     *  Empty constructor
     */
    public SessionCounter() { }

    private SessionCounter(int sessions) {
        totalActiveSessions = new Integer(sessions);
    }

    private static class SingletonHolder {
        public static final SessionCounter INSTANCE = new SessionCounter(0);
    }

    /**
     * @return Instance of SessionCounter
     */
    public static SessionCounter getInstance() {
        return SingletonHolder.INSTANCE;
    }

    /**
     * Increases number of totalActiveSessions
     * @param info information to add to log
     */
    public void increaseCounter(String info) {
        synchronized (totalActiveSessions) {
            totalActiveSessions++;
            LOG.debug(info + " entered; " + totalActiveSessions + " active sessions");
        }
    }

    /**
     * Decreases number of totalActiveSessions
     * @param info information to add to log
     */
    public void decreaseCounter(String info) {
        synchronized (totalActiveSessions) {
            totalActiveSessions--;
            LOG.debug(info + " left; " + totalActiveSessions + " active sessions");
        }
    }

    /** (non-Javadoc)
     * @see javax.servlet.http.HttpSessionListener#sessionCreated(javax.servlet.http.HttpSessionEvent)
     * @param arg0 HttpSessionEvent
     */
    public void sessionCreated(HttpSessionEvent arg0) {
    }

    /** (non-Javadoc)
     * @see javax.servlet.http.HttpSessionListener#sessionDestroyed(javax.servlet.http.HttpSessionEvent)
     * @param event HttpSessionEvent
     */
    public void sessionDestroyed(HttpSessionEvent event) {
        HttpSession session = event.getSession();
        Person user = (Person) session.getAttribute(Const.SESSION_USER_HANDLE);
        if (user != null) {
            SessionCounter.getInstance().decreaseCounter(user.getSsn());
        }
    }

}
