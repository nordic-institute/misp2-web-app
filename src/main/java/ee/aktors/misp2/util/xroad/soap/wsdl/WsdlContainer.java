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

package ee.aktors.misp2.util.xroad.soap.wsdl;

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

import org.w3c.dom.Document;

import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Query;

/**
 * WSDL document along with associated URL and query entities.
 * @author sander.kallo
 */
public class WsdlContainer {
    
    private String wsdlUrl;
    private List<Query> queries;
    private Document wsdlDocument;
    /**
     * Initialize instance with WSDL document and url this document originated from.
     * wsdlUrl is used for adding it to producer entity.
     * @param wsdlDocument download and parsed WSDL as org.w3c.dom Document
     * @param wsdlUrl web URL the WSDL was downloaded from
     */
    public WsdlContainer(Document wsdlDocument, String wsdlUrl) {
        super();
        this.wsdlUrl = wsdlUrl;
        this.wsdlDocument = wsdlDocument;
        this.queries = new ArrayList<Query>();
    }
    /**
     * @return WSDL download URL as string, normally refers to X-Road v6 security server /wsdl path with arguments
     */
    public String getWsdlUrl() {
        return wsdlUrl;
    }
    /**
     * @return WSDL document
     */
    public Document getWsdlDocument() {
        return wsdlDocument;
    }
    /**
     * Return query entity ID list that for only those queries to which
     * XForms are generated from WSDL.
     * The associated queries are added to WsdlContainer with {@link #addAssociatedQuery(Query)}
     * @return all query ID-s associated with this document
     */
    public String getUpdatedQueryIds() {
        StringWriter sw = new StringWriter();
        for (int i = 0; i < queries.size(); i++) {
            Query query = queries.get(i);
            sw.append((i > 0 ? "," : "") + query.getId());
        }
        return sw.toString();
    }
    
    /**
     * Add current WSDL URL to producer.
     * @param producer entity the URL gets added to
     * @return incoming producer entity
     */
    public Producer addWsdlUrl(Producer producer) {
        producer.setWsdlURL(wsdlUrl);
        return producer;
    }
    
    /**
     * Add query enity associated with the WSDL in current instance.
     * 'Association' here means that XForms is generated from current WSDL to given query.
     * @param query entity XForms is generated for from WSDL
     */
    public void addAssociatedQuery(Query query) {
       this.queries.add(query);
    }
}
