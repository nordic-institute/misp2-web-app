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

package ee.aktors.misp2.saxon;


import ee.aktors.misp2.util.XMLUtil;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;

/**
 * The implementation of exslt node-set() function for Saxon-HE processor.
 * If was needed for certain ETSA XSL transformations (HTML rendering from ClinicalDocument).
 * Usage:
 * final TransformerFactory factory = XMLUtil.getTransformerFactory();
 * ((TransformerFactoryImpl) factory).getConfiguration().registerExtensionFunction(new SaxonNodeSet());
 * Taken from https://code.google.com/p/ad-by-java/source/browse/trunk/src/by/ad/xml/SaxonNodeSet.java
 *
 * @author sander.kallo
 *
 */
@SuppressWarnings("serial")
public class SaxonNodeSet extends ExtensionFunctionDefinition {
    @Override
    public SequenceType[] getArgumentTypes() {
        return new SequenceType[] {SequenceType.NODE_SEQUENCE};
    }

    @Override
    public StructuredQName getFunctionQName() {
        return new StructuredQName("", "http://exslt.org/common", "node-set");
    }

    @Override
    public SequenceType getResultType(final SequenceType[] suppliedArgumentTypes) {
        return SequenceType.NODE_SEQUENCE;
    }

    @Override
    public boolean trustResultType() {
        return true;
    }

    @Override
    public ExtensionFunctionCall makeCallExpression() {
        return new ExtensionFunctionCall() {
            // following part is not used from the original file
            // @SuppressWarnings("rawtypes")
            // @Override
            // public SequenceIterator<? extends Item> call(
            // final SequenceIterator<? extends Item>[] arguments,
            // final XPathContext context) throws XPathException
            // {
            // return arguments[0];
            // }

            public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
                return arguments[0];
            }
        };
    }

}
