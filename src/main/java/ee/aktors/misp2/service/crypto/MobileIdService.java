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

package ee.aktors.misp2.service.crypto;

import ee.aktors.misp2.configuration.DigiDoc4jConfiguration;
import ee.aktors.misp2.util.mobileid.MobileIdSessionData;
import ee.sk.mid.MidAuthentication;
import ee.sk.mid.MidAuthenticationHashToSign;
import ee.sk.mid.MidAuthenticationIdentity;
import ee.sk.mid.MidAuthenticationResponseValidator;
import ee.sk.mid.MidAuthenticationResult;
import ee.sk.mid.MidClient;
import ee.sk.mid.MidDisplayTextFormat;
import ee.sk.mid.MidHashToSign;
import ee.sk.mid.MidInputUtil;
import ee.sk.mid.MidLanguage;
import ee.sk.mid.rest.dao.MidSessionStatus;
import ee.sk.mid.rest.dao.request.MidAuthenticationRequest;
import ee.sk.mid.rest.dao.request.MidSignatureRequest;
import ee.sk.mid.rest.dao.response.MidAuthenticationResponse;
import ee.sk.mid.rest.dao.response.MidSignatureResponse;
import javax.security.sasl.AuthenticationException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class MobileIdService {
	private static final Logger LOG = LogManager.getLogger(MobileIdService.class);

	private static final MidDisplayTextFormat MID_DISPLAY_TEXT_FORMAT = MidDisplayTextFormat.GSM7;

	private MidClient midClient;


	public MobileIdService(DigiDoc4jConfiguration digiDoc4jConfiguration) {
		this.midClient = digiDoc4jConfiguration.getMidClient();
	}

	public MobileIdSessionData startAuthentication(String phoneNo, String personalCode) {
		if(phoneNo != null) {
			if(!phoneNo.startsWith("372") && !phoneNo.startsWith("+372")){
				phoneNo = "+372" + phoneNo;
			}
			phoneNo = phoneNo.replaceAll("\\s+","");
		}
		phoneNo = MidInputUtil.getValidatedPhoneNumber(phoneNo);
		personalCode = MidInputUtil.getValidatedNationalIdentityNumber(personalCode);

		MobileIdSessionData sessionData = new MobileIdSessionData();
		sessionData.setPhoneNo(phoneNo);
		sessionData.setPersonalCode(personalCode);

		MidAuthenticationHashToSign authenticationHash = MidAuthenticationHashToSign.generateRandomHashOfDefaultType();
		String verificationCode = authenticationHash.calculateVerificationCode();
		sessionData.setChallenge(verificationCode);
		sessionData.setAuthenticationHash(authenticationHash);

		return sessionData;
	}

	public MobileIdSessionData sendAuthenticationRequest(MobileIdSessionData mobileIdSessionData, String lang, String displayText) throws AuthenticationException {
		MidAuthenticationHashToSign authenticationHash = mobileIdSessionData.getAuthenticationHash();

		MidAuthenticationRequest request = MidAuthenticationRequest.newBuilder()
				.withPhoneNumber(mobileIdSessionData.getPhoneNo())
				.withNationalIdentityNumber(mobileIdSessionData.getPersonalCode())
				.withHashToSign(authenticationHash)
				.withLanguage( getLanguage(lang) )
				.withDisplayText(displayText)
				.withDisplayTextFormat(MID_DISPLAY_TEXT_FORMAT)
				.build();

		MidAuthenticationResult authenticationResult;

		try {
			MidAuthenticationResponse response = midClient.getMobileIdConnector().authenticate(request);
			MidSessionStatus sessionStatus = midClient.getSessionStatusPoller()
					.fetchFinalAuthenticationSessionStatus(response.getSessionID());
			MidAuthentication authentication = midClient.createMobileIdAuthentication(sessionStatus, authenticationHash);

			MidAuthenticationResponseValidator validator = new MidAuthenticationResponseValidator(midClient);
			authenticationResult = validator.validate(authentication);

		}
		catch (Exception e) {
			LOG.warn("Mobile-ID authentication was unsuccessful for phone nr: {} and ssn {}",
					mobileIdSessionData.getPhoneNo(), mobileIdSessionData.getPersonalCode());
			throw new AuthenticationException("Mobile-ID authentication was failed", e);
		}

		if (!authenticationResult.isValid()) {
			LOG.warn("Mobile-ID authentication was unsuccessful for phone nr: {} and ssn {}",
					mobileIdSessionData.getPhoneNo(), mobileIdSessionData.getPersonalCode());
			LOG.debug("Errors reported: {}", authenticationResult.getErrors());
			throw new AuthenticationException("Mobile-ID failed to authenticate. Result is not valid.");
		}

		MidAuthenticationIdentity authenticationIdentity = authenticationResult.getAuthenticationIdentity();

		mobileIdSessionData.setFirstName(authenticationIdentity.getGivenName());
		mobileIdSessionData.setLastName(authenticationIdentity.getSurName());
		mobileIdSessionData.setPersonalCode(authenticationIdentity.getIdentityCode());

		return mobileIdSessionData;
	}


	public MidSignatureResponse sendSignatureRequest(MidHashToSign hashToSign,
													 String phoneNumber, String identityNumber, String lang, String displayText) {
		MidSignatureRequest signatureRequest = MidSignatureRequest.newBuilder()
				.withPhoneNumber(phoneNumber)
				.withNationalIdentityNumber(identityNumber)
				.withHashToSign(hashToSign)
				.withLanguage(getLanguage(lang))
				.withDisplayText(displayText)
				.withDisplayTextFormat(MidDisplayTextFormat.GSM7)
				.build();

		return midClient.getMobileIdConnector().sign(signatureRequest);
	}

	private MidLanguage getLanguage(String lang) {
		MidLanguage midLanguage;
		switch (lang){
			case "et":
				midLanguage = MidLanguage.EST;
				break;
			case "ru":
				midLanguage = MidLanguage.RUS;
				break;
			case "en":
			default:
				midLanguage = MidLanguage.ENG;
		}
		return midLanguage;
	}



}
