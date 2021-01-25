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
 * Unit-tests for restform.headers.* functions.
 */
restform.test.register("restform.headers.parseSubheader", function() {
	restform.test.msg("Test parseSubheader()");
	
	var text = "attachment;part=prop;filename=myfile.txt";
	restform.test.msg("Testing simple input: '" + text + "'");
	var subheaders = restform.headers.parseSubheaders(text);
	restform.test.eq(subheaders[0].name, "attachment");
	restform.test.eq(subheaders[1].name, "part");
	restform.test.eq(subheaders[1].value, "prop");
	restform.test.eq(subheaders[2].name, "filename");
	restform.test.eq(subheaders[2].value, "myfile.txt");
	
	var text = "attachment; part=\"prop\"; filename='myfile.txt'";
	restform.test.msg("Testing quoted values: '" + text + "'");
	var subheaders = restform.headers.parseSubheaders(text);
	restform.test.eq(subheaders[0].name, "attachment");
	restform.test.eq(subheaders[1].name, "part");
	restform.test.eq(subheaders[1].value, "prop");
	restform.test.eq(subheaders[2].name, "filename");
	restform.test.eq(subheaders[2].value, "myfile.txt");
	
	var text = "ab=\"a\\\\b\";cd=\"c\\\"d\";ef=\"e'f\";gh='g\\'h';ij='i\"j';kl=\"\";mn=\"mn\\\"\";filename='filename=.txt'";
	restform.test.msg("Testing quoting: '" + text + "'");
	var subheaders = restform.headers.parseSubheaders(text);
	console.log (subheaders);
	restform.test.eq(subheaders[0].name, "ab");
	restform.test.eq(subheaders[0].value, "a\\b");
	restform.test.eq(subheaders[1].name, "cd");
	restform.test.eq(subheaders[1].value, "c\"d");
	restform.test.eq(subheaders[2].name, "ef");
	restform.test.eq(subheaders[2].value, "e'f");
	restform.test.eq(subheaders[3].name, "gh");
	restform.test.eq(subheaders[3].value, "g'h");
	restform.test.eq(subheaders[4].name, "ij");
	restform.test.eq(subheaders[4].value, "i\"j");
	restform.test.eq(subheaders[5].name, "kl");
	restform.test.eq(subheaders[5].value, "");
	restform.test.eq(subheaders[6].name, "mn");
	restform.test.eq(subheaders[6].value, "mn\"");
	restform.test.eq(subheaders[7].name, "filename");
	restform.test.eq(subheaders[7].value, "filename=.txt");
	
	
	var text = "filename*=UTF-8''Na%C3%AFve%20file.txt; filename=Naïve file.txt; ";
	restform.test.msg("Testing non-ASCII names '" + text + "'");
	var subheaders = restform.headers.parseSubheaders(text);
	restform.test.eq(subheaders[0].name, "filename*");
	restform.test.eq(subheaders[0].unescapedValue, "UTF-8''Na%C3%AFve%20file.txt",
			"Make sure the unescaped version has single quotes preserved");
	restform.test.eq(subheaders[1].name, "filename");
	restform.test.eq(subheaders[1].value, "Naïve file.txt");
	
});
