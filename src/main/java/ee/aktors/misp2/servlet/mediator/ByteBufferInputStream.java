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
package ee.aktors.misp2.servlet.mediator;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.bouncycastle.util.encoders.Base64;
import org.jetbrains.annotations.NotNull;

/**
 * Wrapper around {@link InputStream} to place all read InputStream bytes to a buffer.
 * 
 * @author sander.kallo
 */
public class ByteBufferInputStream extends InputStream implements ByteCounter {
    private final Logger logger = LogManager.getLogger(ByteBufferInputStream.class);
    private InputStream in;
    private ByteArrayOutputStream byteBuffer;

    /**
     * Construct new input stream by wrapping around existing input stream.
     * Use ByteArrayOutputStream for buffering input stream bytes.
     * @param in input stream to be wrapped by counter
     */
    public ByteBufferInputStream(InputStream in) {
        this.in = in;
        byteBuffer = new ByteArrayOutputStream();
    }

    /**
     * Reset input stream and byte buffer.
     * @see InputStream#reset()
     */
    @Override
    public void reset() throws IOException {
        in.reset();
        byteBuffer.reset();
        logger.info("RESET byte buffer input stream! ");
    }

    @Override
    public int read(byte[] b) throws IOException {
        int i = in.read(b);
        addToBuffer(b, 0, i);
        //logger.debug(" Read1! " + i + " ");
        return i;

    }

    @Override
    public int read(byte[] b, int off, int len) throws IOException {
        int i = in.read(b, off, len);
        addToBuffer(b, off, i);
        // logger.debug(" Read2! " + i + " ");
        return i;
    }

    @Override
    public int read() throws IOException {
        int i = in.read();
        if (i > 0) { // in case end of stream has been reached, -1 is returned
            this.byteBuffer.write(i);
        }
        // logger.debug(" Read3! " + i + " ");
        return i;
    }

    private void addToBuffer(byte[] b, int off, int len) {
        if (len > 0) { // if bytes were read, add them to buffer
            this.byteBuffer.write(b, off, len);
        }
        // else in case end of stream has been reached and -1 is returned, do not add anything to buffer
    }

    /**
     * @return byte count of input stream that has been processed
     */
    public long getByteCount() {
        long count = this.byteBuffer.size();
        logger.debug("ByteBufferInputStream byte count: " + count + "");
        return count;
    }
    
    /**
     * @return buffered bytes from input stream as UTF-8 string
     */
    public String bufferToString() {
        Charset charset = StandardCharsets.UTF_8;
        CharsetDecoder decoder = charset.newDecoder();
        byte[] byteArray = bufferToByteArray();
        ByteBuffer buf = ByteBuffer.wrap(byteArray);
        // try to decode, return false on failure
        try {
            CharBuffer charBuffer = decoder.decode(buf);
            return charBuffer.toString();
        } catch(CharacterCodingException e){
            return "(binary, logged as BASE64)\n" + Arrays.toString(Base64.encode(byteArray));
        }
    }

    /**
     * @return buffered bytes from input stream
     */
    public byte[] bufferToByteArray() {
        return byteBuffer.toByteArray();
    }

    /**
     * Append buffered bytes form input stream in text form to StringWriter.
     * In case content type is not textual, append BASE64 string.
     * @param sw StringWriter object where the data is added to
     * @param label label displayed for debugging
     */
    public void appendBuffer(StringWriter sw, String label) {
        if (byteBuffer.size() > 0) {
            sw.append("\n " + label + ": \n");
            sw.append(bufferToString());
        }
    }
}
