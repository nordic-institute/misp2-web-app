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
 */

/**
 * Unit-tests for restform.util.* functions.
 */
restform.test.register("restform.util.getFirstValueByKey", function() {
	var ar = [
		{name: 'name1', value: 'value1'},
		{name: 'name2', value: 'value2'}
	];
	
	restform.test.msg("Test getFirstValueByKey(ar, key)");
	
	restform.test.eq(restform.util.getFirstValueByKey(ar, 'name1'), 'value1');
	restform.test.eq(restform.util.getFirstValueByKey(ar, 'name2'), 'value2');
	restform.test.eq(restform.util.getFirstValueByKey(ar, 'value1'), null);

	restform.test.msg("Test getFirstValueByKey(ar, key, keyPropName, valuePropName)");
	
	restform.test.eq(restform.util.getFirstValueByKey(ar, 'value1', 'value', 'name'), 'name1');
	restform.test.eq(restform.util.getFirstValueByKey(ar, 'value2', 'value', 'name'), 'name2');
	restform.test.eq(restform.util.getFirstValueByKey(ar, 'name1', 'value', 'name'), null);
	
});

restform.test.register("restform.util.countFunctionArgs", function() {
	restform.test.eq(restform.util.countFunctionArgs("function () {}"), 0);
	restform.test.eq(restform.util.countFunctionArgs("function ( ) {}"), 0);
	restform.test.eq(restform.util.countFunctionArgs("function (arg) {}"), 1);
	restform.test.eq(restform.util.countFunctionArgs("function (arg, arg2) {}"), 2);
	restform.test.eq(restform.util.countFunctionArgs("function (arg, arg2, arg3, arg4) {}"), 4);	
});
