/*
 * The MIT License
 * Copyright (c) 2020 NIIS <info@niis.org>
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
package ee.aktors.misp2.util.openapi.generator.input.string;

import org.jsoup.nodes.Element;

import com.networknt.oas.model.Schema;

import ee.aktors.misp2.util.openapi.generator.input.InputGenerator;

/**
 * Add file input.
 */
public class FileInputGenerator extends InputGenerator {

    public static enum Type {
        binary, base64;

        public static Type get(String format) {
            if (format != null && format.equals(Type.base64.name())) {
                return base64;
            } else {
                return binary;
            }
        }
    };
    private Type type;

    public FileInputGenerator(Type type) {
        this.type = type;
    }
    
	public FileInputGenerator(String formatText) {
    }

    public FileInputGenerator(Schema schema) {
        this(FileInputGenerator.Type.get(schema != null ? schema.getFormat() : null));
    }

    @Override
	protected Element addElementTo(Element fieldNode) {
	    Element inputNode = fieldNode.appendElement("input")
	            .attr("type", "file")
                .attr("class", type.name());
        return inputNode;
	}

    @Override
    public InputGenerator setDefault() {
        if (schema != null && schema.getDefault() != null) {
            if (type == Type.base64) {
                inputNode.attr("data-rf-default", schema.getDefault().toString());
            } // else binary default files cannot be set
        }
        return this;
    }
    
    /**
     * Set media type for the 'accept' file input attribute.
     * @param mediaTypeName media type string for the 'accept' attribute
     * @return this instance for chaining
     */
    public FileInputGenerator setAccept(String mediaTypeName) {
        inputNode.attr("accept", mediaTypeName);
        return this;
    }

    /**
     * Set content type attribute for extra information to the form-runner.
     * @param mediaTypeName MIME content type
     * @return this instance for chaining
     */
    public FileInputGenerator setContentType(String mediaTypeName) {
        inputNode.attr("data-rf-content-type", mediaTypeName);
        return this;
    }
}
