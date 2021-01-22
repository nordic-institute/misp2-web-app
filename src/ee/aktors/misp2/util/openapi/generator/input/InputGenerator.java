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
package ee.aktors.misp2.util.openapi.generator.input;

import org.apache.commons.lang3.StringUtils;
import org.jsoup.nodes.Element;
import com.networknt.oas.model.Schema;

import ee.aktors.misp2.util.openapi.generator.input.bool.BooleanInputGenerator;
import ee.aktors.misp2.util.openapi.generator.input.date.DateInputGenerator;
import ee.aktors.misp2.util.openapi.generator.input.date.DateTimeInputGenerator;
import ee.aktors.misp2.util.openapi.generator.input.number.IntegerInputGenerator;
import ee.aktors.misp2.util.openapi.generator.input.number.NumberInputGenerator;
import ee.aktors.misp2.util.openapi.generator.input.string.EnumInputGenerator;
import ee.aktors.misp2.util.openapi.generator.input.string.FileInputGenerator;
import ee.aktors.misp2.util.openapi.generator.input.string.LongTextInputGenerator;
import ee.aktors.misp2.util.openapi.generator.input.string.PasswordInputGenerator;
import ee.aktors.misp2.util.openapi.generator.input.string.StringInputGenerator;
import ee.aktors.misp2.util.openapi.generator.lang.OpenApiFormTranslations;

/**
 * Base class for REST form HTML input element generation. Contains common methods
 * with other types of input generators. Also contains a builder method that is able
 * to initialize the correct type of input element from OpenAPI schema.
 * Usage:
 * Element inputElement = InputGenerator.build(schema).addNodeTo(nodeContainer);
 */
public abstract class InputGenerator {
	protected Schema schema;
    protected Element inputNode;
    protected OpenApiFormTranslations formTranslations; // may be needed in future
	
	/**
	 * Select and return proper HTML input element generator given OpenAPI schema for the element.
	 * @param schema OpenAPI schema for given input element
	 * @return InputGenerator corresponding to given schema
	 */
	public static InputGenerator build(Schema schema) {
		InputGenerator inputGenerator;
		if (isType(schema, "integer")) {
			inputGenerator = new IntegerInputGenerator();
		} else if (isType(schema, "number")) {
			inputGenerator = new NumberInputGenerator();
		} else if (isType(schema, "string") && isFormat(schema, "date")) {
			inputGenerator = new DateInputGenerator();
		} else if (isType(schema, "string") && isFormat(schema, "date-time")) {
			inputGenerator = new DateTimeInputGenerator();
		} else if (isType(schema, "string") && isFormat(schema, "password")) {
			inputGenerator = new PasswordInputGenerator();
        } else if (isType(schema, "string") && schema.hasEnums()) {
            inputGenerator = new EnumInputGenerator();
		} else if (isType(schema, "boolean")) {
			inputGenerator = new BooleanInputGenerator();
		} else if (isType(schema, "string") && isFormat(schema, "binary")) {
		    inputGenerator = new FileInputGenerator(FileInputGenerator.Type.binary);
		} else if (isType(schema, "string") && isFormat(schema, "base64")) {
            inputGenerator = new FileInputGenerator(FileInputGenerator.Type.base64);
        } else if (isType(schema, "string") && LongTextInputGenerator.isLongText(schema)) {
            inputGenerator = new LongTextInputGenerator();
        } else {
			inputGenerator = new StringInputGenerator();
		}
		inputGenerator.setSchema(schema);
		return inputGenerator;
		
	}
    /**
	 * Generate Jsoup input element and add it to given container element.
	 * <b>Needs to be overridden in child class according to input element type and characteristics.</b>
	 * @param fieldNode input field container where input node is added to
	 * @return added Jsoup element
	 */
	protected abstract Element addElementTo(Element fieldNode);

    public InputGenerator setParentNode(Element fieldNode) {
        this.inputNode = addElementTo(fieldNode);
        this.setDefault();
        return this;
    }
    
    protected InputGenerator setSchema(Schema schemaNew) {
        this.schema = schemaNew;
        return this;
    }
    
    protected static boolean isType(Schema schema, String type) {
        if (schema != null) {
            String schemaType = schema.getType();
            if (schemaType != null && type != null) {
                return schemaType.equals(type);
            }
        }
        return false;
    }
    
    protected static boolean isFormat(Schema schema, String format) {
        if (schema != null) {
            String schemaFormat = schema.getFormat();
            if (schemaFormat != null && format != null) {
                return schemaFormat.equals(format);
            }
        }
        return false;
    }

	protected void addFormat(Element inputNode) {
		if (schema != null && schema.getFormat() != null) {
			appendAttr(inputNode, "data-rf-validate-format", schema.getFormat());
		}
	}
	
	protected void addPattern(Element inputNode) {
		if (schema != null && schema.getPattern() != null) {
			appendAttr(inputNode, "pattern", schema.getPattern());
		}
	}
    
    protected void addLengthLimits(Element inputNode) {
        if (schema != null) {
            if (schema.getMinLength() != null) {
                appendAttr(inputNode, "minlength", "" + schema.getMinLength());
            }
            if (schema.getMaxLength() != null) {
                appendAttr(inputNode, "maxlength", "" + schema.getMaxLength());
            }
        }
    }
	
	protected void appendAttr(Element node, String name, String value) {
		String prevValue = node.attr(name);
		if (StringUtils.isNotBlank(prevValue)) {
			value = prevValue + " " + value;
		}
		node.attr(name, value);
	}

    public InputGenerator setPath(String path) {
        // add name attribute with JSONPath
        inputNode.attr("name", path);
        return this; // for chaining
    }
    public InputGenerator setMultipartId(String multipartProperty) {
        // add multipart ID if exists
        setMultipartId(inputNode, multipartProperty);
        return this;
    }
    public InputGenerator setDataParamLocation(String dataParamLocation) {
        // add data parameter path if exists (e.g. 'url' or 'header')
        if (dataParamLocation != null) {
            inputNode.attr("data-rf-param-location", dataParamLocation);
        }
        return this;
    }
    public InputGenerator setRequired(Boolean required) {
        // add class 'required' if necessary
        if (required) {
            inputNode.addClass("required");
        }
        return this;
    }
    /**
     * Hide and disable input field if it is a read-only field according to the schema.
     * @return this instance for chaining
     */
    public InputGenerator setReadOnly() {
        if (schema != null && schema.isReadOnly()) {
            inputNode
                .attr("disabled", "disabled")
                .addClass("readonly");
            hideNode(inputNode);
        }
        return this;
    }
    
    /**
     * In case schema is write-only, hide the output node.
     * @param outputNode output Jsoup element
     * @param schema OpenAPI schema associated with given output element
     */
    public static void setWriteOnly(Element outputNode, Schema schema) {
        if (schema != null && schema.isReadOnly()) {
            outputNode
                .addClass("writeonly");
            hideNode(outputNode);
        }
    }
    
    /**
     * Hide node if it does not have a container or its container if it exists.
     * Node is hidden by adding class "hidden"
     * @param node
     */
    private static void hideNode(Element node) {
        // If field exists (container of label and input), hide the entire field
        if (node != null) {
            if (node.parent() != null && node.parent().hasClass("field")) {
                node.parent().addClass("hidden");
            } else { // else hide only given input
                node.addClass("hidden");
            }
        }
    }
    
    /**
     * Add default value to input element if it is given in schema.
     * @return this instance for chaining
     */
    public InputGenerator setDefault() {
        if (schema != null && schema.getDefault() != null) {
            inputNode.attr("value", schema.getDefault().toString());
        }
        return this;
    }
    
    public Element getInputNode() {
        return inputNode;
    }
    public InputGenerator addFormat() {
        addFormat(inputNode, schema);
        return this;
    }
    public static void addFormat(Element valueNode, Schema schema) {
        if (schema != null) {
            String format = schema.getFormat();
            if (format != null) {
                valueNode.addClass(format); // adds base64 and binary format classes
            }
        }
    }
    public static void setMultipartId(Element valueNode, String multipartId) {
        if (multipartId != null) {
            valueNode.attr("data-rf-multipart-id", multipartId);
        }
    }
    public InputGenerator setTranslations(OpenApiFormTranslations formTranslations) {
        this.formTranslations = formTranslations;
        return this;
    }
	
	
	// TODO arrays: oneOf, uniqueItems, minItems, maxItems
	// TODO schema.required, readOnly, writeOnly
}
