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

package ee.aktors.misp2.util.xroad.soap;

import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;

/**
 * Holder for XML namespace with prefix
 * 
 * @author sander.kallo
 */
public class XMLNamespaceContainer {
    String prefix;
    String uri;

    /**
     * Construct container for namespace with prefix
     * @param prefix namespace prefix
     * @param uri namespace URI
     */
    public XMLNamespaceContainer(String prefix, String uri) {
        this.prefix = prefix;
        this.uri = uri;
    }
    
    /**
     * Get namespace prefix
     * @return namespace prefix
     */
    public String getPrefix() {
        return prefix;
    }
    
    /**
     * Get namespace URI
     * @return namespace URI
     */
    public String getUri() {
        return uri;
    }
    
    /**
     * Add namespace to SOAPElement (mostly intended to use for root element)
     * @param envelope SOAP element the namespace declaration gets added to
     * @throws SOAPException when adding namespace declaration fails
     */
    public void addToSOAPElement(SOAPElement envelope) throws SOAPException {
        envelope.addNamespaceDeclaration(this.getPrefix(), this.getUri());
    }
}
