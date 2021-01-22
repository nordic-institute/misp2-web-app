/*
 * The MIT License
 * Copyright (c) 2020 NIIS <info@niis.org>
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

package ee.aktors.misp2.action;

import java.security.Security;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.struts2.StrutsStatics;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.Preparable;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.CountryUtil;
import ee.aktors.misp2.util.X509CertificateGenerator;

/**
 */
public class CertificateAction extends BaseAction implements Preparable {
    private static final long serialVersionUID = 1L;
    private String commonName;
    private String countryName = CountryUtil.getDefaultCountry().getCountry();
    private String spkac;
    private String csrData;
    private String certificate;
    private String browser;

    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String execute() throws Exception {
        return SUCCESS;
    }

    @Override
    public void prepare() throws Exception {
        HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(StrutsStatics.HTTP_REQUEST);
        Security.addProvider(new BouncyCastleProvider());
        String agent = request.getHeader("User-Agent");
        if (agent.toLowerCase().contains("msie") || agent.toLowerCase().contains("trident")) {
            // IE versions from 11 onwards do not contain "msie", but contain "trident"
            browser = Const.IE;
        } else {
            browser = Const.MOZILLA;
        }
    }
    
    @Override
    public void validate() {
        String action = (String) ActionContext.getContext().get(ActionContext.ACTION_NAME);
        if (getCommonName() != null && getCommonName().equals("")) {
            addActionError(getText("text.label.cert.error_cn"));
        }
        if (action.equals("certGenerate")) {

            if (browser.equals(Const.IE)) {
                if (csrData == null || csrData.isEmpty()) {
                    LogManager.getLogger(CertificateAction.class).error("CSR is missing");
                    addActionError(getText("certificate.generate.fail"));
                }
            } else {
                if (spkac == null || spkac.isEmpty()) {
                    LogManager.getLogger(CertificateAction.class).error(
                            "SPKAC is missing, browser migth not support keygen element");
                    addActionError(getText("certificate.generate.fail"));
                }
            }
        }
    }

    /**
     * @return ERROR if certificate generating fails SUCCESS otherwise
     * @throws Exception if certificate generating fails
     */
    @HTTPMethods(methods = { HTTPMethod.POST })
    public String generate() throws Exception {
        certificate = new String(new X509CertificateGenerator(browser, spkac, csrData).generateCertificate(countryName,
                commonName));
        if (certificate.equals("SPKAC_ERROR")) {
            addActionError(getText("certificate.generate.success"));
            return ERROR;
        }
        addActionMessage(getText("certificate.generate.success"));
        return SUCCESS;
    }


    /**
     * @return the commonName
     */
    public String getCommonName() {
        return commonName;
    }

    /**
     * @param commonNameNew the commonName to set
     */
    public void setCommonName(String commonNameNew) {
        this.commonName = commonNameNew;
    }

    /**
     * @return the countryName
     */
    public String getCountryName() {
        return countryName;
    }

    /**
     * @param countryNameNew the countryName to set
     */
    public void setCountryName(String countryNameNew) {
        this.countryName = countryNameNew;
    }

    /**
     * @return the spkac
     */
    public String getSpkac() {
        return spkac;
    }

    /**
     * @param spkacNew the spkac to set
     */
    public void setSpkac(String spkacNew) {
        this.spkac = spkacNew;
    }

    /**
     * @return the csrData
     */
    public String getCsrData() {
        return csrData;
    }

    /**
     * @param csrDataNew the csrData to set
     */
    public void setCsrData(String csrDataNew) {
        this.csrData = csrDataNew;
    }

    /**
     * @return the certificate
     */
    public String getCertificate() {
        return certificate;
    }

    /**
     * @param certificateNew the certificate to set
     */
    public void setCertificate(String certificateNew) {
        this.certificate = certificateNew;
    }

    /**
     * @return the browser
     */
    public String getBrowser() {
        return browser;
    }

}
