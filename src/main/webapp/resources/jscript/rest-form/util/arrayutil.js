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
 * Array processing utilities
 */
restform.arrayutil = new function() {
	/**
	 * Convert String to ASCII code integer array.
	 * @param string string to be converted
	 * @return array of integers corresponding to ascii codes
	 */
	this.stringToBytes = function (string) {
		return Array.from(string, function(s){return s.charCodeAt(0);});
	};
	
	/**
	 * Find subsequence indexes from a longer sequence. Inputs are arrays of the same type.
	 * 
	 * E.g
	 * restform.multipart.parser.find([1, 2, 3, 4, 5, 6, 7, 3, 4, 1], [3, 4])
	 * [2, 7]
	 * restform.multipart.parser.find("blatetesttetesatesttset", "test")
	 * [6, 15]
	 * 
	 * @param fromBytes long sequence where subsequence indexes are looked up from
	 * @param searchBytes shorter sequence used as subsequence to compare to larger sequence
	 * @param params object with search configuration parameters. Those are:
	 *        <li><b>backward<b> - search in a reverse direction<li>
	 *        <li><b>startIndex<b> - array index where search is started from<li>
	 *        <li><b>maxRangeLength<b> - number of bytes to search from<li>
	 * @return array of indexes in #fromBytes of subsequence matches
	 */
	this.findAll = function(fromBytes, searchBytes, params) {
		var matchIndexes = [];
		if (!params) {
			params = {};
		}
		var index;
		while ((index = this.findNext(fromBytes, searchBytes, params)) != -1) {
			matchIndexes[matchIndexes.length] = index;
			var startIndex = index + (!params.backward ? searchBytes.length : -searchBytes.length);
			if (startIndex >= 0 && startIndex < fromBytes.length) { // start index is within array bounds
				params.startIndex = startIndex;
			} else { // start index is outside of bounds, end search
				break;
			}
			// adjust params for new search
			if (params.maxRangeLength) {
				params.maxRangeLength -= params.rangeLength;
			}
		}
		return matchIndexes;
	};

	/**
	 * indexOf() for array sequences. Also enables to search backwards and from a starting point.
	 * @see #findAll - current function takes in the same parameters.
	 * @return -1 if sequence was not found, sequence start index in original array otherwise.
	 */
	this.findNext = function(fromBytes, searchBytes, params) {
		params = params ? params : {};
		if (!params) {
			params = {};
		}
		if (searchBytes.length == 0) { // similar to indexOf - empty string is always found
			return 0;
		}
		
		// search optimization: stats about search term to move with bigger steps
		 // true/false enables/disables range optimization, default is on
		if (params.range === true || params.range !== false && !params.range) {
			params.range = {};
			// find min and max
			for (var k = 0; k < searchBytes.length; k++) {
				if (typeof params.range.min === 'undefined' || searchBytes[k] < params.range.min) {
					params.range.min = searchBytes[k];
				}
				if (typeof params.range.max === 'undefined' || searchBytes[k] > params.range.max) {
					params.range.max = searchBytes[k];
				}
			}
		}
		
		// default start index is 0 on forward, length - 1 for backward direction
		if (typeof params.startIndex === 'undefined') {
			params.startIndex = !params.backward ? 0 : fromBytes.length - searchBytes.length;
		}
		
		// index range length on searching from original array
		if (!params.backward) {
			params.rangeLength = fromBytes.length - params.startIndex - searchBytes.length + 1;
		} else {
			params.rangeLength = params.startIndex + 1;
		}
		
		// apply maximum limit on iterations if the limit exists
		if (typeof params.maxRangeLength !== 'undefined') {
			params.rangeLength = Math.min(params.maxRangeLength, params.rangeLength);
		}

		// params initialized, go through the array
		var i, j, k, shift;
		for (shift = 0; shift < params.rangeLength; shift++) {
			i = !params.backward ? params.startIndex + shift : params.startIndex - shift;
			
			// search optimization: if the char (search-word-length - 1) steps-away is not in our search word,
			// skip the entire search word. Use simple range comparison. Could implement it with dictionary as well.
			if (params.range) {
				var shiftToNext = searchBytes.length - 1;
				var prevIndex = !params.backward ? i : i - shiftToNext;
				var nextIndex = !params.backward ? i + shiftToNext : i;
				var val = fromBytes[nextIndex];
				if (val < params.range.min || val > params.range.max) {
					// skipping from prevIndex..nextIndex(included)
					shift += shiftToNext;
					continue;
				}
			}
			for (j = 0, k = i; j < searchBytes.length; j++, k++) {
				if (fromBytes[k] != searchBytes[j]) {
					break;
				}
			}
			if (j == searchBytes.length) {
				return i;
			}
		}
		return -1;
	};
	

	/**
	 * @return input arg if arg is not instance of ArrayBuffer;
	 * in case it is ArrayBuffer, convert it to UTF-8 string
	 */
	this.convertArrayBufferToText = function (data) {
		if (data.constructor === ArrayBuffer) {
			return restform.arrayutil.arrayBufferToUtf8String(data);
		} else if (data.constructor === Uint8Array) {
			return restform.arrayutil.arrayToUtf8String(data);
		} else {
			return data;
		}
	}
	
	/**
	 * @see #arrayToUtf8String(data)
	 */
	this.arrayBufferToUtf8String = function(data) {
		return restform.arrayutil.arrayToUtf8String(new Uint8Array(data));
	};
	
	/**
	 * Based on 1999 Masanao Izumo <iz@onicos.co.jp> implementation.
	 * http://www.onicos.com/staff/iz/amuse/javascript/expert/utf.txt 
	 * (Author made it free to use and modify.)
	 */
	this.arrayToUtf8String = function(array) {
		var out = "";
		var len = array.length;
		var i = 0;
		var c = null;
		var char2, char3;

		while (i < len) {
			c = array[i++];
			switch (c >> 4) {
				case 0:
				case 1:
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
					// 0xxxxxxx
					out += String.fromCharCode(c);
					break;
				case 12:
				case 13:
					// 110x xxxx   10xx xxxx
					char2 = array[i++];
					out += String.fromCharCode(((c & 0x1F) << 6) | (char2 & 0x3F));
					break;
				case 14:
					// 1110 xxxx  10xx xxxx  10xx xxxx
					char2 = array[i];
					i++;
					char3 = array[i];
					i++
					out += String.fromCharCode(((c & 0x0F) << 12)
							| ((char2 & 0x3F) << 6) | ((char3 & 0x3F) << 0));
					break;
			}
		}
		return out;
	};
	
	// not used, but kept as reference in case there is a need for faster string converter
	this.arrayBufferToStringAsync = function (buf, callback) {
		var bb = new BlobBuilder();
		bb.append(buf);
		var f = new FileReader();
		f.onload = function(e) {
			callback(e.target.result)
		}
		f.readAsText(bb.getBlob());
	};

};
