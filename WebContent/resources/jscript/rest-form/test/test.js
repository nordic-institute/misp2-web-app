/*
 * The MIT License
 * Copyright (c) 2020 NIIS
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
 * Unit-test support functionality.
 */
restform.test = new function() {
	this.tests = []; // unit-test function callbacks
	this.init = function() {
		this.passed = 0;
		this.failed = 0;
	};
	this.init();
	/**
	 * Run all registered unit-tests and display output in JavaScript console.
	 * @param nameFilter if given, perform only tests whose names contain that phrase  
	 */
	this.run = function (nameFilter) {
		this.init();
		var infoMsg =  "Unit test is an object with 'name' and 'testFn' properties.";
		for (var i = 0; i < this.tests.length; i++) {
			var test = this.tests[i];
			if (test) {
				var name = test.name;
				if (nameFilter && name.indexOf(nameFilter) == -1) {
					continue;
				}
				var testFn = test.testFn;
				if (testFn && testFn.constructor === Function) {
					if (name) {
						console.log("Running '" + name + "'")
					}
					testFn();
				} else {
					console.warn ("Ignoring unit test '" + name + "':", testFn, ". Not a function.");
				}
				
			} else {
				console.warn ("Encountered unit test object", testFn, ". Cannot run it." + infoMsg);
			}
		}
		this.summary();
	}
	
	/**
	 * Register unit-test so if restform.test.run() is called, this unit test is run.
	 * @param 
	 * @param testFn unit test function callback - restform.test instance
	 * 		  where fields passed and failed can be updated.
	 */
	this.register = function(name, testFn) {
		if (testFn && testFn.constructor === Function) {
			this.tests[this.tests.length] = {name: name, testFn: testFn};
		} else {
			console.error ("Cannot add unit test", testFn, ". Not a function.");
		}
	}
	
	/**
	 * Compare equality of input values and console.log results.
	 * @param actual real result produced by the code
	 * @param expected expected value
	 * @param message additional message
	 */
	this.eq = function(actual, expected, message) {
		var pass = ("" + actual) == ("" + expected);
		var message = message ? ": " + message : "";
		if (pass) {
			console.log("OK: ", actual + " == " + expected);
			this.passed++;
		} else { // failed
			console.log("Fail! " + message, actual + " != " + expected);
			this.failed++;
		}
	};
	
	/**
	 * Log message, simply delegates to console log and prepends spaces to the
	 * message to make the output readable.
	 * @param ... all arguments are delegated to console log
	 */
	this.msg = function () {
		// shift the message to the left so that test results are better visible
		if (arguments[0].constructor === String) {
			arguments[0] = "     " + arguments[0];
		}
		return console.log.apply(console.log, arguments);
	};
	
	/**
	 * Print summary of performed tests to console.
	 */
	this.summary = function () {
		console.log("---------------------------")
		console.log("Summary")
		console.log("  - Passed: " + this.passed);
		console.log("  - Failed: " + this.failed);
	};
};