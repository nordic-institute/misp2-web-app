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
import ee.aktors.misp2.action.crypto.dto.MobileSignRequestResult;
import ee.aktors.misp2.action.crypto.dto.Result;
import ee.aktors.misp2.action.crypto.dto.SignedResult;
import ee.aktors.misp2.action.crypto.dto.TranslationsResult;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.service.crypto.DigitalSigningService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.JsonUtil;
import ee.sk.mid.MidHashToSign;
import ee.sk.mid.MidInputUtil;
import ee.sk.mid.exception.MidDeliveryException;
import ee.sk.mid.exception.MidInternalErrorException;
import ee.sk.mid.exception.MidInvalidNationalIdentityNumberException;
import ee.sk.mid.exception.MidInvalidPhoneNumberException;
import ee.sk.mid.exception.MidInvalidUserConfigurationException;
import ee.sk.mid.exception.MidMissingOrInvalidParameterException;
import ee.sk.mid.exception.MidNotMidClientException;
import ee.sk.mid.exception.MidPhoneNotAvailableException;
import ee.sk.mid.exception.MidSessionNotFoundException;
import ee.sk.mid.exception.MidSessionTimeoutException;
import ee.sk.mid.exception.MidUnauthorizedException;
import ee.sk.mid.exception.MidUserCancellationException;
import ee.sk.mid.rest.dao.response.MidSignatureResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;
import org.digidoc4j.Container;
import org.digidoc4j.DataToSign;

import java.io.IOException;

/**
 * Digital signing - sign data with mobileId
 */
public class MidSigningAction extends DigitalSigningAction implements StrutsStatics {

	private static final long serialVersionUID = 1L;
	private static final Logger LOG = LogManager.getLogger(MidSigningAction.class);

	private static final String PARAM_IN_PHONE_NUMBER = "phoneNumber";
	private static final String PARAM_IN_IDENTITY_CODE = "identityCode";

	public MidSigningAction(DigitalSigningService digitalSigningService) {
		super(digitalSigningService);
	}

	@Override
	public void prepare() throws Exception {
		super.prepare();
	}

	/**
	 * <p>Starts signing session with mobile id.</p>
	 * <p>
	 * Incomming HttpRequest has to have following parameters:<br>
	 * {@link MidSigningAction#PARAM_IN_PHONE_NUMBER} -
	 * phone number of the user (with region prefix)<br>
	 * {@link MidSigningAction#PARAM_IN_IDENTITY_CODE} -
	 * social security number of the user
	 * </p>
	 * @return verification code that the user has to enter in their phone.
	 * errorCode and errorMessage if something goes wrong
	 * @throws IOException if can't get HttpResponse writer object
	 */
	@HTTPMethods(methods = {HTTPMethod.POST})
	public String sendSignatureRequest() throws IOException {
		HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
		HttpServletResponse response = (HttpServletResponse) ActionContext.getContext().get(HTTP_RESPONSE);
		String phoneNumber = request.getParameter(PARAM_IN_PHONE_NUMBER);
		String identityNumber = request.getParameter(PARAM_IN_IDENTITY_CODE);
		MobileSignRequestResult result = new MobileSignRequestResult();

		Container container = (Container) session.get(Const.SESSION_DIGI_CONTAINER);
		try {
			if (container == null) {
				result.setResult(TranslationsResult.ERROR_SERVER);
			} else {
				identityNumber = MidInputUtil.getValidatedNationalIdentityNumber(identityNumber);
				phoneNumber = MidInputUtil.getValidatedPhoneNumber(phoneNumber);

				DataToSign dataToSignExternally = digitalSigningService.getDataToSign(container, phoneNumber, identityNumber);
				session.put(Const.SESSION_DATA_TO_SIGN, dataToSignExternally);

				MidHashToSign hashToSign = digitalSigningService.getHashToSign(dataToSignExternally);

				MidSignatureResponse midSignatureResponse =
					digitalSigningService.sendSignatureRequest(hashToSign, phoneNumber, identityNumber,
						getLocale().getLanguage(), getText("digiSigning.mid.signingRequest"));

				session.put(Const.SESSION_MID_SESSION_ID, midSignatureResponse.getSessionID());

				String verificationCode = hashToSign.calculateVerificationCode();
				result.setVerificationCode(verificationCode);
				result.setResult(Result.OK);
				result.setMessageCode(TranslationsResult.VERIFICATION_MESSAGE);
			}

		} catch (MidInvalidNationalIdentityNumberException e) {
			LOG.error("User entered invalid national identity number", e);
			result.setResult(TranslationsResult.ERROR_INPUT_SSN);
		} catch (MidInvalidPhoneNumberException e) {
			LOG.error("User entered invalid phone number", e);
			result.setResult(TranslationsResult.ERROR_INPUT_PHONE);
		} catch (MidNotMidClientException e) {
			LOG.error("User is not a MID client or user's certificates are revoked", e);
			result.setResult(TranslationsResult.ERROR_MID_NOT_USER);
		} catch (MidMissingOrInvalidParameterException | MidUnauthorizedException | MidInternalErrorException e) {
			LOG.error("Integrator-side error with MID integration (including insufficient input validation) or configuration. Or mid internal exception.", e);
			result.setResult(TranslationsResult.ERROR_SERVER);
		} catch (Exception e) {
			LOG.error("Creating container failed.", e);
			result.setResult(TranslationsResult.ERROR_SERVER);
		}

		response.setContentType(JsonUtil.JSON_CONTENT_TYPE);
		response.setStatus(HttpServletResponse.SC_OK);
		ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
		ow.writeValue(response.getWriter(), result);
		return null;
	}

	/**
	 * Signs {@link Container} stored in session using mobile-id session {Const#SESSION_MID_SESSION_ID}
	 *
	 * @return result of signing with message if error occurred and base64 encoded bdoc container
	 * @throws IOException if can't get HttpResponse writer object
	 */
	@HTTPMethods(methods = {HTTPMethod.POST})
	public String signMobileContainer() throws IOException {
		HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
		HttpServletResponse response = (HttpServletResponse) ActionContext.getContext().get(HTTP_RESPONSE);
		SignedResult result = new SignedResult();

		Container container = (Container) session.get(Const.SESSION_DIGI_CONTAINER);
		DataToSign dataToSignExternally = (DataToSign) session.get(Const.SESSION_DATA_TO_SIGN);
		String sessionId = (String) session.get(Const.SESSION_MID_SESSION_ID);
		try {
			if (container == null || dataToSignExternally == null || StringUtils.isBlank(sessionId)) {
				result.setResult(TranslationsResult.ERROR_SERVER);
			} else {
				digitalSigningService.signContainerMobile(container, dataToSignExternally, sessionId);

				session.put(Const.SESSION_DIGI_CONTAINER, container);
				session.put(Const.SESSION_IS_CONTAINER_SIGNED, true);

				result.setSignedContainer(IOUtils.toByteArray(container.saveAsStream()));
				result.setResult(Result.OK);
			}
		} catch (MidUserCancellationException e) {
			LOG.error("User cancelled operation from his/her phone.", e);
			result.setResult(TranslationsResult.ERROR_USER_CANCELLED);
		} catch (MidNotMidClientException e) {
			LOG.error("User is not a MID client or user's certificates are revoked", e);
			result.setResult(TranslationsResult.ERROR_MID_NOT_USER);
		} catch (MidSessionTimeoutException e) {
			LOG.error("User did not type in PIN code or communication error.", e);
			result.setResult(TranslationsResult.ERROR_MID_SESSION_TIMEOUT);
		} catch (MidPhoneNotAvailableException e) {
			LOG.error("Unable to reach phone/SIM card. User needs to check if phone has coverage.", e);
			result.setResult(TranslationsResult.ERROR_MID_PHONE_CONNECTION);
		} catch (MidDeliveryException e) {
			LOG.error("Error communicating with the phone/SIM card.", e);
			result.setResult(TranslationsResult.ERROR_MID_PHONE_CONNECTION);
		} catch (MidInvalidUserConfigurationException e) {
			LOG.error("Mobile-ID configuration on user's SIM card differs from what is configured on service provider side. User needs to contact his/her mobile operator.", e);
			result.setResult(TranslationsResult.ERROR_MID_PHONE_CONFIGURATION);
		} catch (MidSessionNotFoundException | MidMissingOrInvalidParameterException | MidUnauthorizedException e) {
			LOG.error("Integrator-side error with MID integration or configuration", e);
			result.setResult(TranslationsResult.ERROR_SERVER);
		} catch (MidInternalErrorException e) {
			LOG.error("MID service returned internal error that cannot be handled locally.", e);
			result.setResult(TranslationsResult.ERROR_SERVER);
		} catch (Exception e) {
			LOG.error("Signing container failed", e);
			result.setResult(TranslationsResult.ERROR_SERVER);
		}
		response.setContentType(JsonUtil.JSON_CONTENT_TYPE);
		response.setStatus(HttpServletResponse.SC_OK);
		ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
		ow.writeValue(response.getWriter(), result);
		return null;
	}
}
