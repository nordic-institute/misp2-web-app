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

package ee.aktors.misp2.exportImport;

import java.io.File;
import java.util.LinkedHashMap;
import java.util.List;

import ee.aktors.misp2.model.Producer;
import ee.aktors.misp2.model.Xforms;

/**
 */
public class QueryImportData {

    private File tempDir;
    private LinkedHashMap<Producer, List<Xforms>> activeProducersWithXforms;
    private LinkedHashMap<Producer, List<Xforms>> complexProducersWithXforms;

    /**
     * Initializes given values
     * @param tempDir tempDir to set
     * @param activeProducersWithXforms activeProducersWithXforms to set
     * @param complexProducersWithXforms complexProducersWithXforms to set
     */
    public QueryImportData(File tempDir, LinkedHashMap<Producer, List<Xforms>> activeProducersWithXforms,
            LinkedHashMap<Producer, List<Xforms>> complexProducersWithXforms) {
        this.tempDir = tempDir;
        this.activeProducersWithXforms = activeProducersWithXforms;
        this.complexProducersWithXforms = complexProducersWithXforms;
    }

    /**
     * @return tempDir
     */
    public File getTempDir() {
        return tempDir;
    }

    /**
     * @return activeProducersWithXforms
     */
    public LinkedHashMap<Producer, List<Xforms>> getActiveProducersWithXforms() {
        return activeProducersWithXforms;
    }

    /**
     * @return complexProducersWithXforms
     */
    public LinkedHashMap<Producer, List<Xforms>> getComplexProducersWithXforms() {
        return complexProducersWithXforms;
    }
}
