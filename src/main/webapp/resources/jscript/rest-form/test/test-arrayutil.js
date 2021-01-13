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
 */

/**
 * Unit-tests for restform.arrayutil functions.
 */
restform.test.register("restform.arrayutil.findNext", function() {
	restform.test.msg("Test findNext()");
	restform.test.eq(restform.arrayutil.findNext([1, 2, 3, 4, 5, 6, 7, 3, 4, 1], [3, 4]), 2);
	restform.test.eq(restform.arrayutil.findNext("blatetesttetesatesttset", "test"), 5);


	restform.test.msg("Test findNext() border cases");
	restform.test.eq(restform.arrayutil.findNext("test", "test"), 0);
	restform.test.eq(restform.arrayutil.findNext("test__________", "test"), 0);
	restform.test.eq(restform.arrayutil.findNext("__________test", "test"), 10);
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "this se"), 5);
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "that"), -1);
	
	restform.test.msg("Test findNext() start index");
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "this se", {startIndex: -1}), 5);
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "this se", {startIndex: 4}), 5);
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "this se", {startIndex: 5}), 5);
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "this se", {startIndex: 6}), -1);
	

	restform.test.msg("Test findNext() backward search");
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "est", {backward: true}), 1);
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "not here", {backward: true}), -1);
	
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "this se", {backward: true, startIndex: 33}), 5);
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "this se", {backward: true, startIndex: 5}), 5);
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "this se", {backward: true, startIndex: 4}), -1);

	restform.test.msg("Test findNext() max steps");
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "this se", {maxRangeLength: 6, startIndex: 0}), 5);
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "this se", {maxRangeLength: 5, startIndex: 0}), -1);
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "this se", {backward: true, startIndex: 9, maxRangeLength: 5}), 5);
	restform.test.eq(restform.arrayutil.findNext("test this sentence", "this se", {backward: true, startIndex: 9, maxRangeLength: 4}), -1);
});

restform.test.register("restform.arrayutil.findAll", function() {
	restform.test.msg("Test findAll()");
	restform.test.eq(restform.arrayutil.findAll([1, 2, 3, 4, 5, 6, 7, 3, 4, 1], [3, 4]), [2, 7]);
	restform.test.eq(restform.arrayutil.findAll("blatetesttetesatesttset", "test"), [5, 15]);
	restform.test.eq(restform.arrayutil.findAll("testestest", "test"), [0, 6]);
	restform.test.eq(restform.arrayutil.findAll("testtesttest", "test"), [0, 4, 8]);

	restform.test.msg("Test findAll() (backwards: true)");
	restform.test.eq(restform.arrayutil.findAll("blatetesttetesatesttset", "test"), [5, 15]);
	restform.test.eq(restform.arrayutil.findAll("testestest", "test"), [0, 6]);
	restform.test.eq(restform.arrayutil.findAll("testtesttest", "test"), [0, 4, 8]);

	restform.test.eq(restform.arrayutil.findAll("testtesttest", "test", {startIndex: 7}), [8]);
	restform.test.eq(restform.arrayutil.findAll("testtesttest", "test", {startIndex: 7, backward: true}), [4, 0]);
	restform.test.eq(restform.arrayutil.findAll("testtesttest", "test", {backward: true}),[8, 4, 0]);
	restform.test.eq(restform.arrayutil.findAll("...test.....test.....", "test", {backward: true}),[12, 3]);
	restform.test.eq(restform.arrayutil.findAll("...test.....test.....", "test", {backward: false}),[3, 12]);
	restform.test.eq(restform.arrayutil.findAll("testestabcsttest.....tebla..ble.tes.estt...", "test", {backward: true}),[12, 3]);
	restform.test.eq(restform.arrayutil.findAll("testestestabcsttest.....tebla..ble.tes.estt...", "test", {backward: true}),[15, 6, 0]);
	restform.test.eq(restform.arrayutil.findAll(".test.....test.....", "test", {backward: false}),[1, 10]);
	restform.test.eq(restform.arrayutil.findAll(".test.....test.", "test", {backward: true}),[10, 1]);

	restform.test.msg("Test findAll() (range: true)");
	restform.test.eq(restform.arrayutil.findAll("blatetesttetesatesttset", "test", 
			{range: true}), [5, 15]);
	restform.test.eq(restform.arrayutil.findAll("testestestabcsttest.....tebla..ble.tes.estt...", "test",
			{range:true, backward: true}),[15, 6, 0]);
	restform.test.eq(restform.arrayutil.findAll("test", "test", {range: true}), [0]);
	restform.test.eq(restform.arrayutil.findAll("test", "test", {range:true, backward: true}),[0]);
	restform.test.eq(restform.arrayutil.findAll("testestest", "test", {range: true}), [0, 6]);
	restform.test.eq(restform.arrayutil.findAll("testestest", "test", {range:true, backward: true}),[6, 0]);
	restform.test.eq(restform.arrayutil.findAll("abcdeacd", "c", {range:true, backward: true}),[6, 2]);
});