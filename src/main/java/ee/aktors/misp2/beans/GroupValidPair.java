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

package ee.aktors.misp2.beans;

import java.io.Serializable;

/**
 *
 * @author arnis.rips
 */
public class GroupValidPair implements Serializable {
    private static final long serialVersionUID = 1L;
    private String groupName;
    private String validUntil;

    /**
     * Initializes variables
     * @param groupName group name to set
     */
    public GroupValidPair(String groupName) {
        this.groupName = groupName;
    }

    /**
     * Initializes variables
     * @param groupName group name to set
     * @param validUntil valid until to set
     */
    public GroupValidPair(String groupName, String validUntil) {
        this.groupName = groupName;
        this.validUntil = validUntil;
    }

    /**
     * @return the groupName
     */
    public String getGroupName() {
        return groupName;
    }

    /**
     * @param groupNameIn the groupName to set
     */
    public void setGroupName(String groupNameIn) {
        this.groupName = groupNameIn;
    }

    /**
     * @return the validUntil
     */
    public String getValidUntil() {
        return validUntil;
    }

    /**
     * @param validUntilIn the validUntil to set
     */
    public void setValidUntil(String validUntilIn) {
        this.validUntil = validUntilIn;
    }



}
