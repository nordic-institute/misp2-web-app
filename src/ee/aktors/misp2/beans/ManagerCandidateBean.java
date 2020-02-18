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
import java.util.LinkedHashSet;
import java.util.Set;

import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.util.Const;

/**
 *
 * @author arnis.rips
 */
public class ManagerCandidateBean implements Serializable {

    private static final long serialVersionUID = 1L;
    private Person candidate;
    private Set<Person> confirmationRequired = new LinkedHashSet<Person>();
    private Set<Person> confirmationGiven = new LinkedHashSet<Person>();

    /**
     * Initializes variables
     * @param candidate candidate to set
     */
    public ManagerCandidateBean(Person candidate) {
        this.candidate = candidate;
    }


    /**
     * @return the candidate
     */
    public Person getCandidate() {
        return candidate;
    }


    /**
     * @param candidateIn the candidate to set
     */
    public void setCandidate(Person candidateIn) {
        this.candidate = candidateIn;
    }


    /**
     * @return the confirmationRequired
     */
    public Set<Person> getConfirmationRequired() {
        return confirmationRequired;
    }


    /**
     * @param confirmationRequiredIn the confirmationRequired to set
     */
    public void setConfirmationRequired(Set<Person> confirmationRequiredIn) {
        this.confirmationRequired = confirmationRequiredIn;
    }


    /**
     * @return the confirmationGiven
     */
    public Set<Person> getConfirmationGiven() {
        return confirmationGiven;
    }


    /**
     * @param confirmationGivenIn the confirmationGiven to set
     */
    public void setConfirmationGiven(Set<Person> confirmationGivenIn) {
        this.confirmationGiven = confirmationGivenIn;
    }


    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof ManagerCandidateBean)) {
            return false;
        }
        final ManagerCandidateBean other = (ManagerCandidateBean) obj;
        return this.hashCode() == other.hashCode();
    }

    @Override
    public int hashCode() {
        int hash = Const.PRIME_7;
        hash = Const.PRIME_17 * hash + (this.getCandidate() != null ? this.getCandidate().getSsn().hashCode() : 0);
        return hash;
    }

}
