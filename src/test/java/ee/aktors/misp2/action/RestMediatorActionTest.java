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

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class RestMediatorActionTest {

    @Test
    public void isUserRequestAllowed() {
        // Allowed:
        assertTrue(RestMediatorAction.isUserRequestAllowed( "PUT test/test, POST test/{id}", "PUT",  "test/test"));
        assertTrue(RestMediatorAction.isUserRequestAllowed("DELETE test/{id}/ma, POST test/{id}/meh", "POST", "test/2/meh"));
        assertTrue(RestMediatorAction.isUserRequestAllowed("DELETE test/{id}/ma", "DELETE", "test/2/ma?test"));
        assertTrue(RestMediatorAction.isUserRequestAllowed("POST /pets/{petId}", "POST", "/pets/2"));
        assertTrue(RestMediatorAction.isUserRequestAllowed("POST ee-dev/COM/11333578/rest-service-01/pets/{petId}/images", 
                "POST", "ee-dev/COM/11333578/rest-service-01/pets/3243/images"));
        
        // Not allowed
        assertFalse(RestMediatorAction.isUserRequestAllowed("POST test/{id}/pic", "POST", "test/test/img"));
        assertFalse(RestMediatorAction.isUserRequestAllowed("POST /petts/{petId}", "POST", "/pets/2"));
        assertFalse(RestMediatorAction.isUserRequestAllowed("DELETE test/{id}/ma", "DELETE", "test/2/me?test=1&bl/d"));
        assertFalse(RestMediatorAction.isUserRequestAllowed("POST ee-dev/COM/11333578/rest-service-01/pets/{petId}/images", 
                "POST", "ee-dev/COM/11333578/rest-service-01/pets/3243/images/df"));
        assertFalse(RestMediatorAction.isUserRequestAllowed("POST ee-dev/COM/11333578/rest-service-01/pets/{petId}/images", 
                "POST", "ee-dev/COM/11333578/rest-service-01/pets/3243"));
        
    }
}
