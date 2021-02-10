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
 *
 */

package ee.aktors.misp2.action.crypto;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.opensymphony.xwork2.ActionContext;
import ee.aktors.misp2.action.crypto.dto.DigestResult;
import ee.aktors.misp2.action.crypto.dto.Result;
import ee.aktors.misp2.action.crypto.dto.SignedResult;
import ee.aktors.misp2.action.crypto.dto.TranslationsResult;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.service.crypto.DigitalSigningService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.JsonUtil;
import eu.europa.esig.dss.spi.DSSUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;
import org.digidoc4j.Container;
import org.digidoc4j.DataFile;
import org.digidoc4j.DataToSign;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.bind.DatatypeConverter;
import java.io.IOException;

import static eu.europa.esig.dss.enumerations.DigestAlgorithm.SHA256;


/**
 * Digital signing - sign data with id-card
 */
public class IdCardSigningAction extends DigitalSigningAction implements StrutsStatics {

	private static final long serialVersionUID = 1L;
	private static final Logger LOG = LogManager.getLogger(IdCardSigningAction.class);

	private static final String PARAM_IN_CERT_IN_HEX = "certInHex";
	private static final String PARAM_IN_SIGNATURE_IN_HEX = "signatureInHex";

	public IdCardSigningAction(DigitalSigningService digitalSigningService) {
		super(digitalSigningService);
	}

	@Override
	public void prepare() throws Exception {
		super.prepare();
	}

	/**
	 * <p>Generates hash for the {@link DataFile} stored in session</p>
	 *
	 * <p>
	 * Incomming HttpRequest has to have one parameter:<br>
	 * {@link IdCardSigningAction#PARAM_IN_CERT_IN_HEX} - certificate obtained
	 * from {@code window.hwcrypto.getCertificate()} method
	 * </p>
	 *
	 * @return {@link Result#OK} - and hash in body of Http response message.<br>
	 * {@link Result#ERROR} -  if something goes wrong
	 * {@link IdCardSigningAction#uploadDataToSign}  was not found in session.<br>
	 * @throws IOException if can't get HttpResponse writer object
	 */
	@HTTPMethods(methods = {HTTPMethod.POST})
	public String generateHash() throws IOException {
		HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
		HttpServletResponse response = (HttpServletResponse) ActionContext.getContext().get(HTTP_RESPONSE);
		String certInHex = request.getParameter(PARAM_IN_CERT_IN_HEX);
		DigestResult digest = new DigestResult();

		LOG.debug("Generating hash from cert " + StringUtils.left(certInHex, 10) + "...");

		try {
			Container container = (Container) session.get(Const.SESSION_DIGI_CONTAINER);
			if (container == null) {
				digest.setResult(TranslationsResult.ERROR_SERVER);
			} else {
				DataToSign dataToSign = digitalSigningService.getDataToSign(container, certInHex);
				session.put(Const.SESSION_DATA_TO_SIGN, dataToSign);

				String dataToSignInHex = DatatypeConverter.printHexBinary(
					DSSUtils.digest(SHA256, dataToSign.getDataToSign()));

				digest.setHex(dataToSignInHex);
				digest.setResult(Result.OK);
			}
		} catch (Exception e) {
			digest.setResult(TranslationsResult.ERROR_SERVER);
			LOG.error("Error Calculating data to sign", e);
		}

		response.setContentType(JsonUtil.JSON_CONTENT_TYPE);
		response.setStatus(HttpServletResponse.SC_OK);
		ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
		ow.writeValue(response.getWriter(), digest);
		return null;
	}

	/**
	 * <p>Finalizes signing the {@link Container} that is stored in session</p>
	 *
	 * <p>Incomming HttpRequest has to have one parameter:<br>
	 * {@link IdCardSigningAction#PARAM_IN_SIGNATURE_IN_HEX} - signature obtained
	 * from {@code window.hwcrypto.sign()} method</p>
	 *
	 * @return {@link Result#OK} - if {@link Container} was signed and is ready for download.
	 * Also base64 encoded byte array of bdoc in json.<br>
	 * {@link Result#ERROR} - if something goes wrong
	 * {@link IdCardSigningAction#uploadDataToSign}  was not found in session.<br>
	 * {@link IdCardSigningAction#generateHash} was not found in session.<br>
	 * @throws IOException if can't get HttpResponse writer object
	 */
	@HTTPMethods(methods = {HTTPMethod.POST})
	public String createContainer() throws IOException {
		HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
		HttpServletResponse response = (HttpServletResponse) ActionContext.getContext().get(HTTP_RESPONSE);
		String signatureInHex = request.getParameter(PARAM_IN_SIGNATURE_IN_HEX);
		SignedResult result = new SignedResult();

		LOG.debug("Creating container for signature " + StringUtils.left(signatureInHex, 10) + "...");
		DataToSign dataToSign = (DataToSign) session.get(Const.SESSION_DATA_TO_SIGN);
		try {
			Container container = (Container) session.get(Const.SESSION_DIGI_CONTAINER);
			if (dataToSign == null) {
				LOG.error("DataToSign not found in session.");
				result.setResult(TranslationsResult.ERROR_SERVER);
			} else if (container == null) {
				LOG.error("Container not found in session.");
				result.setResult(TranslationsResult.ERROR_SERVER);
			} else {
				digitalSigningService.signContainer(container, dataToSign, signatureInHex);
				session.put(Const.SESSION_DIGI_CONTAINER, container);
				session.put(Const.SESSION_IS_CONTAINER_SIGNED, true);

				result.setSignedContainer(IOUtils.toByteArray(container.saveAsStream()));
				result.setResult(Result.OK);
			}
		} catch (Exception e) {
			result.setResult(TranslationsResult.ERROR_SERVER);
			LOG.error("Error Signing document", e);
		}
		response.setContentType(JsonUtil.JSON_CONTENT_TYPE);
		response.setStatus(HttpServletResponse.SC_OK);
		ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
		ow.writeValue(response.getWriter(), result);
		return null;
	}
}
