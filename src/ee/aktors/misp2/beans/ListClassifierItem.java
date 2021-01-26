/*
 * The MIT License
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

import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
public class ListClassifierItem implements Serializable {

    private static final long serialVersionUID = 1L;
    private String first;
    private String second;

    /**
     * Empty
     */
    public ListClassifierItem() {
    }

    
    /**
     * @param first first to set
     * @param second second to set
     */
    public ListClassifierItem(String first, String second) {
        this.first = first;
        this.second = second;
    }
    /**
     * @return the first
     */
    public String getFirst() {
        return first;
    }
    /**
     * @param firstIn the first to set
     */
    public void setFirst(String firstIn) {
        this.first = firstIn;
    }


    /**
     * @return the second
     */
    public String getSecond() {
        return second;
    }


    /**
     * @param secondIn the second to set
     */
    public void setSecond(String secondIn) {
        this.second = secondIn;
    }


    @Override
    public boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final ListClassifierItem other = (ListClassifierItem) obj;
        if ((this.first == null) ? other.first != null : !this.first.equals(other.first)) {
            return false;
        }
        if ((this.second == null) ? other.second != null : !this.second.equals(other.second)) {
            return false;
        }
        return true;
    }

    @Override
    public int hashCode() {
        int hash = Const.PRIME_7;
        hash = Const.PRIME_41 * hash + (this.first != null ? this.first.hashCode() : 0);
        hash = Const.PRIME_41 * hash + (this.second != null ? this.second.hashCode() : 0);
        return hash;
    }

    @Override
    public String toString() {
        return "ListClassifierItem{" + "first=" + first + ", second=" + second + '}';
    }

}
