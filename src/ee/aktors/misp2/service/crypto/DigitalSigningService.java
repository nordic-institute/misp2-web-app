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
 *
 */

package ee.aktors.misp2.service.crypto;

import ee.aktors.misp2.configuration.DigiDoc4jConfiguration;
import ee.sk.mid.MidClient;
import ee.sk.mid.MidDisplayTextFormat;
import ee.sk.mid.MidHashToSign;
import ee.sk.mid.MidHashType;
import ee.sk.mid.MidLanguage;
import ee.sk.mid.MidSignature;
import ee.sk.mid.rest.dao.MidSessionStatus;
import ee.sk.mid.rest.dao.request.MidCertificateRequest;
import ee.sk.mid.rest.dao.request.MidSignatureRequest;
import ee.sk.mid.rest.dao.response.MidCertificateChoiceResponse;
import ee.sk.mid.rest.dao.response.MidSignatureResponse;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import javax.xml.bind.DatatypeConverter;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.digidoc4j.Configuration;
import org.digidoc4j.Container;
import org.digidoc4j.ContainerBuilder;
import org.digidoc4j.DataFile;
import org.digidoc4j.DataToSign;
import org.digidoc4j.DigestAlgorithm;
import org.digidoc4j.Signature;
import org.digidoc4j.SignatureBuilder;

public class DigitalSigningService {
	private static final Logger LOG = LogManager.getLogger(DigitalSigningService.class);

	private static final DigestAlgorithm DIGEST_ALGORITHM = DigestAlgorithm.SHA256;
	private static final MidHashType MID_HASH_TYPE = MidHashType.SHA256;

	private Configuration digiDoc4jConfiguration;
	private MidClient midClient;


	public DigitalSigningService(DigiDoc4jConfiguration digiDoc4jConfiguration) {
		this.digiDoc4jConfiguration = digiDoc4jConfiguration.getConfiguration();
		this.midClient = digiDoc4jConfiguration.getMidClient();
	}

	public Container createContainer(DataFile dataFile) {
		return ContainerBuilder
			.aContainer()
			.withDataFile(dataFile)
			.withConfiguration(digiDoc4jConfiguration)
			.build();
	}

	public DataToSign getDataToSign(Container containerToSign, String certificateInHex) {
		X509Certificate certificate = getCertificate(certificateInHex);
		return getDataToSign(containerToSign, certificate);
	}

	public DataToSign getDataToSign(Container container, String phoneNumber, String identityNumber) {
		MidCertificateRequest midCertificateRequest = MidCertificateRequest.newBuilder()
			.withPhoneNumber(phoneNumber)
			.withNationalIdentityNumber(identityNumber)
			.build();

		MidCertificateChoiceResponse midCertificateChoiceResponse = midClient.getMobileIdConnector().getCertificate(midCertificateRequest);
		X509Certificate signingCert = midClient.createMobileIdCertificate(midCertificateChoiceResponse);

		return getDataToSign(container, signingCert);
	}

	public DataToSign getDataToSign(Container containerToSign, X509Certificate certificate) {
		return SignatureBuilder
			.aSignature(containerToSign)
			.withSigningCertificate(certificate)
			.withSignatureDigestAlgorithm(DIGEST_ALGORITHM)
			.buildDataToSign();
	}

	public void signContainer(Container container, DataToSign dataToSign, String signatureInHex) {
		byte[] signatureBytes = DatatypeConverter.parseHexBinary(signatureInHex);
		Signature signature = dataToSign.finalize(signatureBytes);
		container.addSignature(signature);
	}

	public void signContainerMobile(Container container, DataToSign dataToSignExternally, String sessionId) {
		Signature signature;
		MidSessionStatus sessionStatus = midClient.getSessionStatusPoller()
			.fetchFinalSignatureSessionStatus(sessionId);

		MidSignature mobileIdSignature = midClient.createMobileIdSignature(sessionStatus);
		signature = dataToSignExternally.finalize(mobileIdSignature.getValue());
		container.addSignature(signature);
	}

	private X509Certificate getCertificate(String certificateInHex) {
		byte[] certificateBytes = DatatypeConverter.parseHexBinary(certificateInHex);
		try (InputStream inStream = new ByteArrayInputStream(certificateBytes)) {
			CertificateFactory cf = CertificateFactory.getInstance("X.509");
			X509Certificate certificate = (X509Certificate) cf.generateCertificate(inStream);
			return certificate;
		} catch (CertificateException | IOException e) {
			LOG.error("Error reading certificate: " + e.getMessage());
			throw new RuntimeException(e);
		}
	}

	public MidSignatureResponse sendSignatureRequest(MidHashToSign hashToSign,
		String phoneNumber, String identityNumber, String lang, String displayText) {

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
		MidSignatureRequest signatureRequest = MidSignatureRequest.newBuilder()
			.withPhoneNumber(phoneNumber)
			.withNationalIdentityNumber(identityNumber)
			.withHashToSign(hashToSign)
			.withLanguage(midLanguage)
			.withDisplayText(displayText)
			.withDisplayTextFormat(MidDisplayTextFormat.GSM7)
			.build();

		return midClient.getMobileIdConnector().sign(signatureRequest);
	}

	/**
	 * @param dataToSign for what to calculate the hash for
	 * @return hash to sign by user
	 */
	public MidHashToSign getHashToSign(DataToSign dataToSign) {
		return MidHashToSign.newBuilder()
			.withDataToHash(dataToSign.getDataToSign())
			.withHashType(MID_HASH_TYPE)
			.build();
	}
}
