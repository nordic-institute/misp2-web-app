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

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.w3c.dom.Document;

/**
 */
public class XMLReader {
    private static final Logger LOGGER = LogManager.getLogger(XMLReader.class.getName());

    /**
     * @param fileName file to save to
     * @param doc doc to save
     * @return true if saving was successful, false otherwise
     */
    public boolean saveXMLDocument(String fileName, Document doc) {
        LOGGER.debug("Saving XML file... " + fileName);
        // open output stream where XML Document will be saved
        File xmlOutputFile = new File(fileName);
        FileOutputStream fos;
        Transformer transformer;
        try {
            fos = new FileOutputStream(xmlOutputFile);
        } catch (FileNotFoundException e) {
            LOGGER.error("Error occured: " + e.getMessage());
            return false;
        }
        // Use a Transformer for output
        TransformerFactory transformerFactory = XMLUtil.getTransformerFactory();
        try {
            transformer = transformerFactory.newTransformer();
        } catch (TransformerConfigurationException e) {
            LOGGER.error("Transformer configuration error: " + e.getMessage());
            try {
                fos.close();
            } catch (IOException e1) {
                LOGGER.error("Could not close xml file output stream: " + e1.getMessage());
            }
            return false;
        }
        DOMSource source = new DOMSource(doc);
        StreamResult result = new StreamResult(fos);
        // transform source into result will do save
        try {
            transformer.transform(source, result);
        } catch (TransformerException e) {
            LOGGER.error("Error transform: " + e.getMessage());
        }
        LOGGER.debug("XML file saved.");
        return true;
    }

}
