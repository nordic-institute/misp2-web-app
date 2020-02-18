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

package ee.aktors.misp2.util.openapi.generator.input.number;

import org.jsoup.nodes.Element;

import ee.aktors.misp2.util.openapi.generator.input.InputGenerator;

public class NumberInputGenerator extends InputGenerator {

	@Override
	protected Element addElementTo(Element fieldNode) {
		Element inputNode = fieldNode.appendElement("input")
			.attr("type", "number")
            .attr("data-rf-type", "number");
		addFormat(inputNode);
		addPattern(inputNode);
		addMinMax(inputNode);
		return inputNode;
	}

    private void addMinMax(Element node) {
        if (schema.getMinimum() != null) {
            Number min = schema.getMinimum();
            node.attr("min", min.toString()); // TODO exclusive min
        }
        if (schema.getMaximum() != null) {
            Number max = schema.getMaximum();
            node.attr("max", max.toString()); // TODO exclusive max
        }
        if (schema.getMultipleOf() != null) {
            node.attr("step", schema.getMultipleOf().toString());
        }
    }
}
