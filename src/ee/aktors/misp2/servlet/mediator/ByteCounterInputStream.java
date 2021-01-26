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

package ee.aktors.misp2.servlet.mediator;

import java.io.IOException;
import java.io.InputStream;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Wrapper around {@link InputStream} in to count InputStream bytes.
 * 
 * @author sander.kallo
 */
public class ByteCounterInputStream extends InputStream implements ByteCounter {
    private final Logger logger = LogManager.getLogger(ByteCounterInputStream.class);
    private InputStream in;
    private long count;

    /**
     * Construct new input stream by wrapping a counter around another input stream
     * @param in input stream to be wrapped by counter
     */
    public ByteCounterInputStream(InputStream in) {
        this.in = in;
        this.count = 0;
    }

    /**
     * Reset input stream and byte counter.
     * @see InputStream#reset()
     */
    @Override
    public void reset() throws IOException {
        in.reset();
        count = 0;
        logger.info("RESET counter input stream! " + count + " ");
    }

    @Override
    public int read(byte[] b) throws IOException {
        int i = in.read(b);
        addToCount(i);
        //logger.debug(" Read1! " + i + " ");
        return i;

    }

    @Override
    public int read(byte[] b, int off, int len) throws IOException {
        int i = in.read(b, off, len);
        addToCount(i);
        // logger.debug(" Read2! " + i + " ");
        return i;
    }

    @Override
    public int read() throws IOException {
        int i = in.read();
        addToCount(i);
        // logger.debug(" Read3! " + i + " ");
        return i;
    }

    private void addToCount(int i) {
        if (i > 0) { // in case end of stream has been reached, -1 is returned
            count += i;
        }
    }

    /**
     * @return byte count of input stream that has been processed
     */
    public long getByteCount() {
        logger.debug("CounterInputStream byte count: " + count + "");
        return count;
    }
}
