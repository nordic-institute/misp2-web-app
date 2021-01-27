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

package ee.aktors.misp2.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.StringReader;
import java.math.BigInteger;
import java.security.GeneralSecurityException;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PrivateKey;
import java.security.Security;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Calendar;
import java.util.Random;

import org.apache.commons.io.FileUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.bouncycastle.jce.PKCS10CertificationRequest;
import org.bouncycastle.jce.X509Principal;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.mozilla.SignedPublicKeyAndChallenge;
import org.bouncycastle.openssl.PEMParser;
import org.bouncycastle.util.encoders.Base64;
import org.bouncycastle.x509.X509V3CertificateGenerator;

/**
 * X509CertificateGenerator
 */
public class X509CertificateGenerator {
    private static Logger logger = LogManager.getLogger(X509CertificateGenerator.class);
    private X509Certificate caCert;
    private PrivateKey pvKey;
    private String browser;
    private String spkac;
    private String csrData;

    private static final String CERT_TYPE = "X.509";
    private static final String PROVIDER = "BC";
    private static final String KEY_ALORITHM = "RSA";
    private static final String SIGNATURE_ALG_NAME = "SHA1withRSA";

    /**
     * @param browser browser to set
     * @param spkac spkac to set
     * @param csrData csrData to set
     * @throws CertificateException if no Provider supports a CertificateFactorySpi
     * implementation for the specified
     * @throws NoSuchAlgorithmException if no Provider supports a KeyFactorySpi
     * implementation for the specified algorithm.
     * @throws IOException if I/O fails
     * @throws InvalidKeySpecException if the given key specification is
     * inappropriate for this key factory to produce a private key.
     */
    public X509CertificateGenerator(String browser, String spkac, String csrData)
            throws CertificateException, NoSuchAlgorithmException, IOException, InvalidKeySpecException {
        this.browser = browser;
        this.spkac = spkac;
        this.csrData = csrData;
        CertificateFactory cf = CertificateFactory.getInstance(CERT_TYPE);
        ClassLoader cl = getClass().getClassLoader();
        File caCertFile = new File(cl.getResource("/certs/MISP2_CA_cert.pem").getFile());
        File caPvKeyFile = new File(cl.getResource("/certs/MISP2_CA_key.der").getFile());
        caCert = (X509Certificate) cf.generateCertificate(new FileInputStream(caCertFile));
        byte[] encodedPrivateKey = FileUtils.readFileToByteArray(caPvKeyFile);
        PKCS8EncodedKeySpec privateKeySpec = new PKCS8EncodedKeySpec(encodedPrivateKey);
        KeyFactory kf = KeyFactory.getInstance(KEY_ALORITHM);
        pvKey = kf.generatePrivate(privateKeySpec);

    }

    /**
     * @param country contry to use
     * @param commonName commonName to use
     * @return encoded certificate
     * @throws GeneralSecurityException if an encoding error occurs.
     * @throws IOException  If an I/O error occurs
     */
    @SuppressWarnings("deprecation")
    public String generateCertificate(String country, String commonName) throws GeneralSecurityException, IOException {
        Security.addProvider(new BouncyCastleProvider());
        X509V3CertificateGenerator certGen = new X509V3CertificateGenerator();
        // cert is valid for 1 year
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.YEAR, cal.get(Calendar.YEAR) + 1);
        // starting from 1 hour ago, to reduce problems introduced from clocks sync
        Calendar hourago = Calendar.getInstance();
        hourago.set(Calendar.HOUR, cal.get(Calendar.HOUR) - 1);
        
        // serial number for certificate
        BigInteger serialNumber = new BigInteger(new Long(new Random().nextLong()).toString().replace("-", ""));
        
        // create subject
        X509Principal subjectDN = new X509Principal("C=" + country + ",CN=" + commonName);
        certGen.setSerialNumber(serialNumber);
        certGen.setIssuerDN(caCert.getSubjectX500Principal());
        certGen.setSubjectDN(subjectDN);
        certGen.setNotBefore(hourago.getTime());
        certGen.setNotAfter(cal.getTime());
        certGen.setSignatureAlgorithm(SIGNATURE_ALG_NAME);

        logger.debug("browser = " + browser);
        if (browser.equals(Const.IE)) {
            PEMParser pemReader = new PEMParser(new StringReader(csrData));
            Object pemObject;
            try {
                pemObject = pemReader.readObject();
                if (pemObject instanceof PKCS10CertificationRequest) {
                    PKCS10CertificationRequest pkcs10Obj = (PKCS10CertificationRequest) pemObject;
                    try {
                        certGen.setPublicKey(pkcs10Obj.getPublicKey());
                    } catch (NoSuchAlgorithmException e) {
                        logger.error("Don't know algorithm required by certification request ", e);
                    } catch (NoSuchProviderException e) {
                        logger.error("Don't have provider for certification request ", e);
                    } catch (InvalidKeyException e) {
                        logger.warn("Invalid key sent in certificate request", e);
                    }
                }
            } catch (IOException e) {
                logger.error("IOException: ", e);
            }
            pemReader.close();
        } else {
            spkac = spkac.replaceAll("\\^M", "").replaceAll("[\n\r]", "").trim();
            SignedPublicKeyAndChallenge spkac1 = new SignedPublicKeyAndChallenge(Base64.decode(spkac));
            if (!spkac1.verify(PROVIDER)) {
                logger.error("SPKAC verification failed");
                return "SPKAC_ERROR";
            }
            certGen.setPublicKey(spkac1.getPublicKey(PROVIDER));
        }
        X509Certificate cert = certGen.generate(pvKey);
        logger.debug("Generated certificate: " + cert);
        byte[] encoded = Base64.encode(cert.getEncoded());
        return new String(encoded);
    }

    /**
     * @param args arguments
     * @throws Exception can throw
     */
    public static void main(String[] args) throws Exception {
        logger.debug(new X509CertificateGenerator("IE", "", "").generateCertificate("EE", "Aktors-CN"));
    }
}
