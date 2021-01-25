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
 * Request building and response handling.of downloadable/uploadable files (binary or base64)
 */
restform.file = new function() {
	/**
	 * Construct multipart request builder object instance (should be called with 'new').
	 * @param contentType request content type
	 */
	this.FileRequestBuilder = function(contentType) {
		this.contentType = contentType;
		this.files = [];
		
		this.appendElement = function (jqEl, name, val, checkbox, checked, include){
			if (!jqEl.data("base64")) { // binary file (not base64)
				if (jqEl.attr("type") != "file") {
					var fileData = {jqEl: null, file: new Blob([val], {type: this.contentType}), type: "binary"};
					this.files[this.files.length] = fileData;
				} else {
					for (var i = 0; i < jqEl[0].files.length; i++) {
						var fileData = {
							jqEl: null,
							file: jqEl[0].files[i],
							type: "binary",
						};
						fileData["contentDisposition"] =
							"attachment;filename='" + fileData.file.name + "'";
						this.files[this.files.length] = fileData;
					}
				}
				
			} else {
				var fileData = {jqEl: jqEl, file: null, type: "base64"};
				this.files[this.files.length] = fileData;
				console.log("File is base64: " + fileData.jqEl[0]);
			} // else base64 is already converted: file input has a listener that converts it right after upload
		}
		this.getContentType = function () {
			return this.contentType;
		}
		this.getContentDisposition = function () {
			var fileData = this.files[0];
			return fileData.contentDisposition;
		}
		this.getData = function() {
			if (this.files.length != 1) {
				console.warn("Exactly 1 file can be handled. " + this.files.length + " files were given."
						+ " Should use multipart for multiple files.");
			}
			// return first file
			return this.getFileFromFileData(this.files[0]);
		}
		this.getFileFromFileData = function(fileData) {
			if (!fileData) {
				return undefined;
			}
			// return first file
			if (fileData.type == "base64") {
				return fileData.jqEl.data("base64");
			} else {
				return fileData.file;
			}
		}
	};
	
	
	/**
	 * Add base64 encoded file content to file input DOM node property 'base64'.
	 * Add attribute data-rf-convert-status='converting' to file input element while base64 conversion is in progress.
	 * @param el file upload DOM element
	 */
	this.addBase64 = function (el) {
		var file =  el.files[0];
		var jqEl = jQuery(el);
		if (file) {
			jqEl.attr("data-rf-convert-status", "converting");
			var reader = new FileReader();
			reader.readAsDataURL(file); 
			reader.onloadend = function() {
				var base64 = reader.result.replace(/^data:(.*;base64,)?/, '');
				var additional = "";
				while ((base64.length + additional.length) % 4 != 0) {
					additional = additional + "=";
				}
				if (additional) {
					base64 = base64 + additional;
				}
				
				jqEl.data("base64", base64);
				console.log("Base64 data added for file '" + file.name + "' "
						+ "(original file is " + file.size + " bytes, base64 is " + base64.length + " bytes).");
				jqEl.attr("data-rf-convert-status", "ready");
			 }
			
		} else {
			jqEl.removeData("base64");
			console.log("Removed base64 file data for '" + jqEl.attr("name") + "'");
			jqEl.attr("data-rf-convert-status", "empty");
		}
	};

	/**
	 * Class to handle received message displayed as a file attachment. Class is
	 * initialized with 'new' from query.js.
	 */
	this.FileResponseHandler = function() {
		this.handleResponse = function (jqOutputBlock, data, params) {
			this.data = data;
			if (params.contentType ) {
				this.contentType = params.contentType.replace(/;.*$/, "");
			}
			this.filename = null;
			if (!params.filterSelector) {
				params.filterSelector = "";
			}

			// take filename from content disposition if exists
			if (params.contentDisposition && params.contentDisposition.filename) {
				this.filename = params.contentDisposition.filename;
			}
			
			// fall back to generated filename
			if (!this.filename) {
				this.filename = restform.file.generateFileName(jqOutputBlock, this.contentType);
			}
		
			var jqLinkContainer = null;
			if (jqOutputBlock && jqOutputBlock.length != 0) {
				var jqLinkContainer = jqOutputBlock.find(params.filterSelector + " .link-container");

				if (jqLinkContainer.length == 0) {
					jqLinkContainer = jQuery("<div>", {"class": "link-container"});
					var selector = "[data-rf-path]" + params.filterSelector;
					var jqOutputNode = jqOutputBlock.find(selector);
					if (jqOutputNode.length == 0) {
						jqOutputNode = jqOutputBlock;
					}
					jqOutputNode.append(jqLinkContainer);
				}
				
			}

			if (jqLinkContainer && (
					jqLinkContainer.hasClass("base64")
					 || jqLinkContainer.parent().hasClass("base64"))
			) {
				try {
					this.data = restform.file.decodeBase64(this.data);
				} catch (e) {
					console.error("Decoding base64 failed", e);
				}
			}

			// Init blob to be shown from UI
			var blob = new Blob([this.data], {type: this.contentType});
			if (blob.size == 0) {
				restform.file.addFileSize(jqLinkContainer, null);
				restform.util.error(restform.util.getText("restform.error.received_empty_file"));
				"Received empty response. No file was downloaded."
				return;
			}
			
			// Create a download link
			// Note: MS alternative command seems no longer required: window.navigator.msSaveBlob(blob, this.filename);
			var jqLink = jQuery("<a>")
				.attr("href", window.URL.createObjectURL(blob))
				.attr("download", this.filename);
			
			if (jqLinkContainer && jqLinkContainer.length > 0) { // if link container is found, append link inside it
					jqLinkContainer.html(jqLink.text(this.filename));
					// append file size container
					restform.file.addFileSize(jqLinkContainer, blob.size);
			} else {// never actually called, but kept for integrity
				jQuery("body").append(jqLink);
				jqLink[0].click();
				jqLink.remove();
			}
		}
		
		this.getProcessedData = function () {
			return this.data;
		}
		
	};

	/**
	 * Take data as ArrayBuffer, Uint8Array or String and apply base64 decoding.
	 * @param base64data base64 encoded String, ArrayBuffer or Uint8Array
	 * @return base64 decoded Uint8Array
	 */	
	this.decodeBase64 = function(base64data) {
		var base64str = restform.arrayutil.convertArrayBufferToText(base64data);
		var byteString = atob(base64str);
		var byteArray = new Uint8Array(byteString.length);
		for (var i = 0; i < byteString.length; i++) {
			byteArray[i] = byteString.charCodeAt(i);
		}
		return byteArray;
	};
	
	/**
	 * Generate file name from output ID, date and MIME type.
	 * @param jqOutputBlock output element jQuery container.
	 * @param contentType  HTTP Content-Type header value
	 * @return file name string
	 */
	this.generateFileName = function (jqOutputBlock, contentType) {
		// file-name from date
		var dt = new Date();
		var id = "";
		var jqView = null;
		if (jqOutputBlock) {
			if (jqOutputBlock.hasClass("view")) {
				id = jqOutputBlock.attr("id");
			} else {
				jqView = jqOutputBlock.closest(".view");
				if (jqView.length > 0) {
					id = jqView.attr("id");
				}
			}
		}
		
		var pad = function (i) {
			if (i < 10) {
				return "0" + i;
			} else {
				return "" + i;
			}
		}
		var fileNamePrefix = (id ? id + "_" : "")
			    + dt.getFullYear() + "-" + pad(dt.getMonth() + 1) + "-" + pad(dt.getDate()) +
			"_" + pad(dt.getHours()) + "-" + pad(dt.getMinutes()) + "-" + pad(dt.getSeconds());
		
		var fileNameExtension = ".file";
		if (contentType) {
			var ar = contentType.split("/");
			fileNameExtension = "." + ar[ar.length - 1];
		}
		return fileNamePrefix + fileNameExtension;
	};
	
	/**
	 * Convert file size in bytes to more human readable form 
	 * @param size integer; file size in bytes (B)
	 * @param size string; text of file size in B, kB or MB to make it more readable for user
	 */
	this.toHumanReadableSize = function (size) {
		function round(num) {
			return Math.round(num * 10) / 10;
		}
		if (size < 1000) {
			return size + " B";
		} else if (size < 1000000) {
			return round(size/1000) + " kB";
		} else {
			return round(size/1000000) + " MB";
		}
	};
	

	/**
	 * Add base64 encoded file content to file input DOM node property 'base64'.
	 * Add attribute data-rf-convert-status='converting' to file input element while base64 conversion is in progress.
	 * @param el file upload DOM element
	 */
	this.addFileSize = function (el, size) {
		if (el) {
			var jqEl = jQuery(el);
			
			var jqSizeContainer = jqEl.parent().find(".size-container");

			if (jqSizeContainer.length == 0) {
				jqSizeContainer = jQuery("<div>", {"class": "size-container"});
				jqEl.after(jqSizeContainer);
			}
			jqSizeContainer.html("");
			if (size != null) {
				jqSizeContainer.append(jQuery("<i>")
						.text("(" + restform.file.toHumanReadableSize(size) + ")"));
			}
		}
	};
	
	/**
	 * Get file size of file input element.
	 * @param el file input DOM element
	 * @return total file size of file input element files (normally, there is just one file)
	 */
	this.getTotalFileSize = function (el) {
		el = jQuery(el)[0]; // enables accepting also jQuery wrapper
		if (!el.files || el.files.length == 0) {
			return null;
		} else {
			var size = 0;
			for (var i = 0; i < el.files.length; i++) {
				var file = el.files[i];
				size += file.size;
			}
			return size;
		}
	};
};
