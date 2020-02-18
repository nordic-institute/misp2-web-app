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
 * Unit-tests for restform.output.* functions.
 */
restform.test.register("restform.output.getBestMatchingOutputBlock", function() {
	var blockRespCodes = ["400", "41X", "412", "4XX", "XX2"];
	var respMap = {}; // for testing, create respMap with values the same as keys
	for (var i = 0; i < blockRespCodes.length; i++) {
		var blockRespCode = blockRespCodes[i];
		respMap[blockRespCode] = blockRespCode;
	}

	restform.test.msg("Test getBestMatchingOutputBlock(respMap, receivedRespCode)");
	restform.test.eq(restform.output.getBestMatchingOutputBlock(respMap, "412"), "412");
	restform.test.eq(restform.output.getBestMatchingOutputBlock(respMap, "400"), "400");
	restform.test.eq(restform.output.getBestMatchingOutputBlock(respMap, "414"), "41X");
	restform.test.eq(restform.output.getBestMatchingOutputBlock(respMap, "422"), "4XX");
	restform.test.eq(restform.output.getBestMatchingOutputBlock(respMap, "512"), "XX2");
	restform.test.eq(restform.output.getBestMatchingOutputBlock(respMap, "200"), null);
	restform.test.eq(restform.output.getBestMatchingOutputBlock(respMap, "202"), "XX2");
	
});
