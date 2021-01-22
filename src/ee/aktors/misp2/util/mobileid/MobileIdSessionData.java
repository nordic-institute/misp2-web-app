/*
 * The MIT License
 * Copyright (c) 2020 NIIS <info@niis.org>
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

package ee.aktors.misp2.util.mobileid;

import ee.sk.mid.MidAuthenticationHashToSign;

public class MobileIdSessionData {
    private String firstName;
    private String lastName;
    private String idCode;
    private String challenge;
    private String sessCode;
    private String phoneNo;
    private MidAuthenticationHashToSign authenticationHash;

    public MobileIdSessionData() {}
    
    public MobileIdSessionData(String firstName, String lastName, String idCode, String challenge, String sessCode) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.idCode = idCode;
        this.challenge = challenge;
        this.sessCode = sessCode;
    }

    public String getFirstName() {
        return firstName;
    }
    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }
    public String getLastName() {
        return lastName;
    }
    public void setLastName(String lastName) {
        this.lastName = lastName;
    }
    public String getPersonalCode() {
        return idCode;
    }
    public void setPersonalCode(String personalCode) {
        this.idCode = personalCode;
    }
    public String getSessCode() {
        return sessCode;
    }
    public void setSessCode(String sessCode) {
        this.sessCode = sessCode;
    }
    public String getChallenge() {
        return challenge;
    }
    public void setChallenge(String challenge) {
        this.challenge = challenge;
    }
    public void setPhoneNo(String phoneNo) {
        this.phoneNo = phoneNo;
    }
    public String getPhoneNo() {
        return phoneNo;
    }
    public void setAuthenticationHash(MidAuthenticationHashToSign authenticationHash) {
        this.authenticationHash = authenticationHash;
    }
    public MidAuthenticationHashToSign getAuthenticationHash() {
        return authenticationHash;
    }
}
