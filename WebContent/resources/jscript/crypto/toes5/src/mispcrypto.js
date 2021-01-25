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
 * Async functions to help with signing xml data via id-card or mobile-id
 */
(function (window, jQuery) {

  const ERROR_SERVER = "digiSigning.error.server";
  const ERROR_NO_CARD = "digiSigning.error.card.noCard";
  const ERROR_NO_IMPLEMENTATION = "digiSigning.error.card.noImplementation";
  const ERROR_USER_CANCELLED = "digiSigning.error.userCancelled";
  const VERIFICATION_MESSAGE = "digiSigning.ok.verification.message";
  const VERIFICATION_LABEL = "digiSigning.ok.verification.label";
  const ERROR_LABEL = "digiSigning.error.label";
  const TEXT_BUTTON_OK = "label.button.ok";


  /**
   * Signs given data.
   * Signing method is selected based on how the user logged in:
   * <ul>
   *  <li>Password : the data will be signed using ID-Card.</li>
   *  <li>ID-Card: the data will be signed using ID-Card.</li>
   *  <li>Mobile-ID: the data will be signed using Mobile-ID.
   *      The phone number and ssn for signing will be taken from session.</li>
   *  <li>Any other: the data will be signed using ID-Card</li>
   * </ul>
   * @param dataToSign - data that needs to be signed. Encoded as base64
   * @param fileName - name of file the data will be put into. (with extension)
   * @returns {Promise<void>} base64 encoded signed container passed to promise <br/>
   */
  async function signData(dataToSign, fileName) {
    console.debug("signData: getting default sign method");
    Utils.displayLoadingOverlay();
    let result = {label: "Error", message: "Server error", okButton: "OK"};
    try {
      result = await getDefaultSigningMethod();
    } catch (e) {
      await showErrorMessage(result);
      throw e;
    } finally {
      Utils.hideLoadingOverlay()
    }

    if(result.signingType === "MOBILE_ID") {
      return await signDataMobile(dataToSign, fileName, result.phoneNo, result.identityCode);
    } else {
      return await signDataCard(dataToSign, fileName);
    }
  }


  /**
   * Uploads data to server, calculates hash, signs it.
   * @param dataToSign - data that needs to be signed. Encoded as base64
   * @param fileName - name of file the data will be put into. (with extension)
   * @return Promise - base64 encoded signed container passed to promise <br/>
   */
  async function signDataCard(dataToSign, fileName) {
    console.debug("signDataCard: signing with id card");
    Utils.displayLoadingOverlay();
    let result = {messageCode: ERROR_SERVER};
    try{
      result = await uploadDataToSign(dataToSign, fileName);
      const certificate = await window.hwcrypto.getCertificate({lang: 'en'});
      const digest = await fetchHash(certificate);
      const signature = await window.hwcrypto.sign(certificate, {type: 'SHA-256', hex: digest.hex}, {lang: 'en'});
      const container = await createContainer(signature.hex);
      return container.signedContainer;
    } catch(e) {
      switch (e.message) {
        case "user_cancel":
          result.messageCode = ERROR_USER_CANCELLED;
          break;
        case "no_certificates":
          result.messageCode = ERROR_NO_CARD;
          break;
        case "no_implementation":
          result.messageCode = ERROR_NO_IMPLEMENTATION;
          break;
        default:
          result.messageCode = ERROR_SERVER;

      }
      await showErrorMessage(result);
      throw e;
    } finally {
      Utils.hideLoadingOverlay();
    }
  }

  /**
   * Uploads data to server, calculates hash, intiates mobile signing session.
   * @param dataToSign - data that needs to be signed. Encoded as base64
   * @param fileName - name of file the data will be put into. (with extension)
   * @param phoneNumber - phone number of person (with extension ie. +372 555 555)
   * @param identityCode - country personal identity code (ssn)
   * @return Promise - base64 encoded signed container passed to promise <br/>
   *         (null - if signing data was unsuccessful)
   */
  async function  signDataMobile(dataToSign, fileName, phoneNumber, identityCode) {
    console.debug("signDataMobile: signing with mobile id");
    Utils.displayLoadingOverlay();
    let result = {messageCode: ERROR_SERVER};
    try {
      await uploadDataToSign(dataToSign, fileName);
      result = await createContainerMobile(phoneNumber, identityCode);
      await showVerificationMessage(result);
      const container = await signContainerMobile();
      return container.signedContainer;
    } catch (e) {
      if(e.message === "no_implementation"){
        result.messageCode = ERROR_NO_IMPLEMENTATION;
      } else {
          result.messageCode = e.message;
      }

      await showErrorMessage(result);
      throw e;
    } finally {
      Utils.hideLoadingOverlay();
    }
  }

  function  uploadDataToSign(dataToSign, fileName) {
    const postData = {
      dataToSign: dataToSign,
      fileName: fileName
    };
    return post("uploadDataToSign.action", postData);
  }

  function fetchHash(cert) {
    const postData = {certInHex: cert.hex};
    return post("generateHash.action", postData)
  }

  function createContainer(signatureInHex) {
    const postData = {signatureInHex: signatureInHex};
    return post("createContainer.action", postData);
  }

  function createContainerMobile(phoneNumber, identityCode) {
    const postData = {
      phoneNumber: phoneNumber,
      identityCode: identityCode
    };
    return post("sendSignatureRequest.action", postData);
  }

  function signContainerMobile() {
    return post("signMobileContainer.action", {dummyData: "dummyData"});
  }

  function getDefaultSigningMethod() {
    return post("getDefaultSigningMethod.action", {dummyData: "dummyData"});
  }

  async function getTranslations() {
    const result = await post("getTranslations.action", {dummyData: "dummyData"});
    return result.translations;
  }

  function post(url, data) {
    console.debug("Async request to %s", url);
    return new Promise(function (resolve, reject) {
      $.ajax({
        dataType: "json",
        url: url,
        type: "POST",
        data: data
      }).done(function (data) {
        console.debug("Response for url %s: %s", url, JSON.stringify(data));
        if (!data || data.result !== "ok") {
          reject(Error(data ? data.messageCode : ERROR_SERVER));
        } else {
          resolve(data);
        }
      }).fail(function () {
        reject(Error("Post operation failed"));
      });
    })
  }

  async function showErrorMessage(response) {
    const [title, message] = await Promise.all([getText(ERROR_LABEL), getText(response.messageCode)]);
    const jqDialog = jQuery("<div>", {"id": Date.now(), "title": title}).text(message);
    const dialog = await showDialog(jqDialog, response);
    dialog.parent().addClass("ui-state-error");
  }

  async function showVerificationMessage(response) {
    const [title, message] = await Promise.all([getText(VERIFICATION_LABEL), getText(VERIFICATION_MESSAGE)]);
    const jqDialog = jQuery("<div>", {"id": Date.now(), "title": title}).text(message);
    const verificationTag = jQuery("<p>", {"class": "emphasized"}).text(response.verificationCode);
    jqDialog.append(verificationTag);
    await showDialog(jqDialog, response);
  }

  async function showDialog(jqDialog, response) {
    console.debug("Showing dialog for object: %s", JSON.stringify(response));
    jqDialog.dialog({
      dialogClass: "no-close",
      minHeight: 35,
      buttons: [
        {
          text: await getText(TEXT_BUTTON_OK),
          click: function() {
            jQuery(this).dialog("close");
            $(this).remove();
          }
        }
      ],
    });
    return jqDialog;
  }

  async function getText(key) {
    if(!window.mispcrypto) {
      return "Can't find translations. Mispcrypto object missing."
    }
    if(!window.mispcrypto.translations) {
      window.mispcrypto.translations = await getTranslations();
    }
    if(!window.mispcrypto.translations[key]) {
      console.debug("Translation missing for: " + key);
      return window.mispcrypto.translations[ERROR_SERVER];
    }
    return window.mispcrypto.translations[key];
  }

  window.mispcrypto = {
    signData: signData,
    signDataCard: signDataCard,
    signDataMobile: signDataMobile,
    getText: getText,
  };
})(window, $);
