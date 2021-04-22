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

package ee.aktors.misp2.action;

import com.opensymphony.xwork2.ActionContext;
import ee.aktors.misp2.beans.Auth;
import ee.aktors.misp2.beans.Auth.AUTH_TYPE;
import ee.aktors.misp2.configuration.DigiDoc4jConfiguration;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.model.Admin;
import ee.aktors.misp2.model.OrgPerson;
import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.service.PortalService;
import ee.aktors.misp2.service.UserService;
import ee.aktors.misp2.service.crypto.MobileIdService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.CountryUtil;
import ee.aktors.misp2.util.PasswordUtil;
import ee.aktors.misp2.util.Roles;
import ee.aktors.misp2.util.SessionCounter;
import ee.aktors.misp2.util.mobileid.MobileIdSessionData;
import javax.security.auth.x500.X500Principal;
import javax.servlet.http.HttpServletRequest;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.StrutsStatics;
import org.apache.struts2.dispatcher.SessionMap;
import org.bouncycastle.asn1.ASN1ObjectIdentifier;
import org.bouncycastle.asn1.x509.CertificatePolicies;
import org.bouncycastle.asn1.x509.Extension;
import org.bouncycastle.asn1.x509.PolicyInformation;
import org.bouncycastle.cert.jcajce.JcaX509ExtensionUtils;
import org.bouncycastle.util.encoders.Base64;
import org.digidoc4j.CertificateValidator;
import org.digidoc4j.CertificateValidatorBuilder;
import org.digidoc4j.ddoc.SignedDoc;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import static org.apache.logging.log4j.Level.DEBUG;

/**
 *
 */
public class LoginAction extends SecureLoggedAction implements StrutsStatics {

    // OID for extKeyUsage/TLS Web client authentication
    // by PKIX https://tools.ietf.org/html/rfc2459
    static final String CLIENT_AUTHENTICATION_OID = "1.3.6.1.5.5.7.3.2";
    private static final long serialVersionUID = 1L;
    private final DigiDoc4jConfiguration digiDoc4jConfiguration;
    private final UserService serviceUser;
    private final MobileIdService mobileIdService;
    //    private PortalService portalService;
    private String redirectActionName;
    private String actionName;
    // -- Common login
    private String username;
    private String password;
    private String relayState;
//    private String samlResponse;

    private List<Locale> countryList = CountryUtil.getCountries();
    private String countryCode = "";
    private String ssn = "";
    private String overtakeCode;
    private boolean overtakeSbmt;

    private static final Logger LOG = LogManager.getLogger(LoginAction.class);

    /**
     * @param portalService not used
     * @param userService   to inject
     */
    public LoginAction(DigiDoc4jConfiguration digiDoc4jConfiguration, PortalService portalService,
                       UserService userService, MobileIdService mobileIdService) {
        super(portalService);
        this.serviceUser = userService;
        this.digiDoc4jConfiguration = digiDoc4jConfiguration;
        this.mobileIdService = mobileIdService;
    }

    /**
     * @return ERROR if already logged in, SUCCESS otherwise
     */
    @HTTPMethods(methods = {HTTPMethod.GET})
    public String showLogin() {
        if (user != null) {
            String an = (String) session.get(Const.SESSION_PREVIOUS_ACTION);
            LOG.debug("an = " + an);
            actionName = (an != null && !an.equals("login") ? an : "enter");
            addActionMessage(getText("text.already_logged_in"));
            return ERROR;
        } else {
            HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
            request.getSession().invalidate(); // reset session id
            return SUCCESS;
        }
    }

    /**
     * @return ERROR if login fails, SUCCESS otherwise
     */
    @HTTPMethods(methods = {HTTPMethod.POST})
    public String loginAdmin() {
        Admin admin;
        Person user;
        Auth auth = new Auth(AUTH_TYPE.PASSWORD);
        try {
            admin = serviceUser.findAdminByLoginUsername(username);
            if (admin != null
                    && PasswordUtil.encryptPassword(username + password, admin.getSalt()).equals(admin.getPassword())) {
                user = new Person();
                user.setGivenname(username);
                user.setPassword(password);
                auth.setIsAdmin(true);
                session.put(Const.SESSION_USER_ROLE, Roles.PORTAL_ADMIN);
                setUserLoggedIn(auth, user);
            } else {
                addActionError(getText("text.fail.login"));
                return ERROR;
            }
        } catch (NoSuchAlgorithmException | UnsupportedEncodingException e) {
            LOG.error("Failed logging in admin.", e);
            addActionError(getText("text.fail.login"));
            return ERROR;
        }
        return SUCCESS;
    }

    /**
     * @return ERROR if password incorrect or internal error, SUCCESS otherwise
     */
    @HTTPMethods(methods = {HTTPMethod.POST})
    public String loginUsingForm() {
        try {
            if (CONFIG.getBoolean("auth.password")) {
                Person user;
                Auth auth = new Auth(AUTH_TYPE.PASSWORD);
                try {
                    user = serviceUser.findPersonBySSN(username);
                    if (user != null
                            && PasswordUtil.encryptPassword(password, user.getPasswordSalt())
                            .equals(user.getPassword())) {
                        setUserLoggedIn(auth, user);
                        SessionCounter.getInstance().increaseCounter(user.getSsn());
                        return SUCCESS;
                    } else {
                        if (user != null) {
                            LOG.error("Login failed. User '" + username + "' password was incorrect.");
                        } else {
                            LOG.error("Login failed. User '" + username + "' was not found from DB");
                        }
                        addActionError(getText("text.fail.login"));
                        return ERROR;
                    }
                } catch (Exception e) {
                    LOG.error("Login failed. User was not logged in because of internal error", e);
                    addActionError(getText("text.fail.login"));
                    return ERROR;
                }
            }
        } catch (Exception e) {
            LOG.error("Login failed. User was not logged in because of internal error", e);
            e.printStackTrace();
        }
        addActionError(getText("login.errors.form.not_supported"));
        return ERROR;
    }

    private boolean isUserBound(Person user) {
        List<OrgPerson> opl = user.getOrgPersonList();
        return opl == null || opl.isEmpty();
    }

    /**
     * Should be logically only POST, but need to be able to redirect (GET)
     * to it in order to allow cross-site ID-card login
     *
     * @return SUCCESS if logging in is successful, ERROR otherwise
     */
    @HTTPMethods(methods = {HTTPMethod.GET, HTTPMethod.POST})
    public String loginUsingIDCard() {
        try {
            if (CONFIG.getBoolean("auth.IDCard")) {
                HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
                X509Certificate certPrivate = getClientX509Certificate(request);

                if (certPrivate != null) { // if it is not null then login with id
                    if (LOG.isDebugEnabled()) {
                        LOG.debug("Users login certificate: " + certPrivate);
                    }
                    if (!isCertificateValidForIDCardLogin(certPrivate)) {
                        addActionError(getText("text.fail.login") + " " + getText("text.clientCertNotFound"));
                        return ERROR;
                    }
                    boolean checkOCSPNeeded;
                    try {
                        checkOCSPNeeded = CONFIG.getBoolean("auth.IDCard.OCSPCheck");
                    } catch (java.util.NoSuchElementException e) {
                        checkOCSPNeeded = false; // in case configuration parameter is missing, default to false - no
                        // OCSP checking
                    }

                    // if OCSP check is needed, call isValidCertificate() which adds errors if needed and returns false if errors
                    // were found
                    if (checkOCSPNeeded && !isOCSPCheckedOK(certPrivate))
                        return ERROR;

                    // Get the Distinguished Name for the user.
                    Map<String, String> subjectDn = parseSubjectDn(certPrivate.getSubjectDN().getName());
                    if (LOG.isDebugEnabled()) {
                        LOG.debug("Parsed certificate subject DN: " + subjectDn);
                    }
                    String certSsn = subjectDn.get("C") + subjectDn.get("SERIALNUMBER");

                    Person user = serviceUser.findPersonBySSN(certSsn);
                    Auth a = new Auth(AUTH_TYPE.ID_CARD);
                    if (user == null) {
                        user = new Person();
                        user.setSsn(certSsn);
                        LOG.debug("CREATED NEW USER" + user);
                    }

                    user.setGivenname(subjectDn.get("GIVENNAME"));
                    user.setSurname(subjectDn.get("SURNAME"));
                    user.setUsername(certSsn); // set user to this ssn in case of IDCard login
                    serviceUser.save(user);

                    setUserLoggedIn(a, user);
                    SessionCounter.getInstance().increaseCounter(certSsn);
                    return SUCCESS;
                } else {
                    LOG.debug("Cert Object was null.");
                    addActionError(getText("text.fail.login.id"));
                    return ERROR;
                }
            }
        } catch (Exception e) {
            LOG.error(e.getMessage());
            e.printStackTrace();
        }
        addActionError(getText("login.errors.id_card.not_supported"));
        return ERROR;
    }

    /**
     * @return SUCCESS if logging in is successful, ERROR otherwise
     */
    @HTTPMethods(methods = {HTTPMethod.POST})
    public String loginUsingMobileID() {
        HttpServletRequest req = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
        try {
            if (CONFIG.getBoolean("auth.mobileID")) {
                String uuid = req.getParameter("UUID");
                if (CONFIG.containsKey("truststore.isLocal") && CONFIG.getBoolean("truststore.isLocal")) {
                    // if false, then javax.net.ssl.trustStore  system property  must be set to correct trustStore
                    String realPath = ServletActionContext.getServletContext().getRealPath("");
                    System.setProperty("javax.net.ssl.trustStore", realPath + CONFIG.getString("truststore.location"));
                }

                String mobileNr = req.getParameter("mobileNr");
                String personalCode = req.getParameter("personalCode");

                if (uuid == null) { // we came here from login page
                    MobileIdSessionData mobileIdSessionData = mobileIdService.startAuthentication(mobileNr, personalCode);

                    uuid = UUID.randomUUID().toString();
                    req.getSession().setAttribute(uuid, mobileIdSessionData);
                    req.setAttribute("UUID", uuid);
                    req.setAttribute("challengeCode", mobileIdSessionData.getChallenge());
                } else { // this will wait until login is complete. If authentication fails, returns ERROR
                    MobileIdSessionData mobileIdSessionData = (MobileIdSessionData) req.getSession().getAttribute(uuid);
                    session.put(Const.SESSION_MID_USER_DATA, mobileIdSessionData);
                    mobileIdService.sendAuthenticationRequest(mobileIdSessionData,
                            getLocale().getLanguage(), getText("label.signin.mobileID.loginMessage"));

                    Person user;
                    String ssnPrivate = "EE" + mobileIdSessionData.getPersonalCode();
                    // we presuppose that only estonians can use mobile id
                    LOG.debug("Mobile id user's ssn is - " + ssnPrivate);
                    user = serviceUser.findPersonBySSN(ssnPrivate);
                    if (user == null) {
                        user = new Person();
                        user.setSsn(ssnPrivate);
                        user.setGivenname(mobileIdSessionData.getFirstName());
                        user.setSurname(mobileIdSessionData.getLastName());
                        user.setUsername(ssnPrivate);
                        user.setId(null);
                        serviceUser.save(user);
                        LOG.debug("CREATED NEW USER" + user);
                    }
                    Auth auth = new Auth(AUTH_TYPE.MOBILE_ID);
                    setUserLoggedIn(auth, user);
                    SessionCounter.getInstance().increaseCounter(user.getSsn());
                }
                return SUCCESS;
            }
        } catch (Exception e) {
            LOG.error(e.getMessage());
            e.printStackTrace();
            addActionError(getText("text.fail.login"));
        }
        addActionError(getText("text.fail.login"));
        return ERROR;
    }

    /**
     * @return INPUT if user not found, ERROR if login fails, SUCCESS otherwise
     * @throws Exception if encryption fails
     */
    @HTTPMethods(methods = {HTTPMethod.POST})
    public String loginUsingCertificate() throws Exception {
        HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
        X509Certificate cert = getClientX509CertificateFromAttribute(request);
        if (cert != null) { // if it is not null then login with id
            if (LOG.isDebugEnabled()) {
                LOG.debug("Users login certificate: " + cert);
            }

            Person user = serviceUser.findPersonByB64encCert(new String(Base64.encode(cert.getEncoded())));
            LogManager.getLogger(LoginAction.class).debug("Found user: " + user);
            if (user == null) {
                // certificate not registered to any users, ask for ssn and overtake code
                if (overtakeSbmt) {
                    user = serviceUser.findPersonBySSN(countryCode + ssn);
                    if (user != null
                            && PasswordUtil.encryptPassword(overtakeCode, user.getOvertakeCodeSalt()).equals(
                            user.getOvertakeCode())) {
                        String generatedOvertakeCode = serviceUser.generateOvertakeCode();
                        user.setOvertakeCodeSalt(PasswordUtil.getSalt());
                        user.setOvertakeCode(PasswordUtil.encryptPassword(generatedOvertakeCode,
                                user.getOvertakeCodeSalt()));
                        user.setCertificate(new String(Base64.encode(cert.getEncoded())));
                        serviceUser.save(user);
                        addActionMessage(getText("text.new_overtake_code") + " " + generatedOvertakeCode);
                    } else {
                        LogManager.getLogger(LoginAction.class).debug(
                                "User not found for the specified countryCode = " + countryCode + ", ssn = " + ssn
                                        + " and overtake code = " + overtakeCode);
                        addActionError(getText("text.fail.login"));
                        return INPUT;
                    }
                } else {
                    return INPUT;
                }
            }
            Auth a = new Auth(Auth.AUTH_TYPE.CERT);

            setUserLoggedIn(a, user);
        } else {
            LogManager.getLogger(LoginAction.class).debug("Cert Object was null.");
            addActionError(getText("text.fail.login") + " " + getText("text.clientCertNotFound"));
            return ERROR;
        }
        return SUCCESS;
    }

    private X509Certificate getClientX509Certificate(HttpServletRequest req) {
        X509Certificate cert = null;

        String clientCertReqHeader = CONFIG.getString("auth.client_cert_req_header_name");
        if (clientCertReqHeader != null && !clientCertReqHeader.isEmpty()) {
            String b64EncCert = req.getHeader(clientCertReqHeader);
            if (b64EncCert != null) {
                try {
                    cert = (X509Certificate) CertificateFactory.getInstance("X.509").generateCertificate(
                            new ByteArrayInputStream(Base64.decode(b64EncCert)));
                } catch (Exception e) {
                    LOG.warn("Error parsing client certificate: " + b64EncCert);
                    if (LOG.isDebugEnabled()) {
                        LOG.debug(e.getMessage(), e);
                    }

                    return null;
                }
            } else {
                LOG.warn("Couldn't find client cert from request header: " + clientCertReqHeader);
            }
        } else {
            cert = getClientX509CertificateFromAttribute(req);
        }
        return cert;
    }

    private X509Certificate getClientX509CertificateFromAttribute(HttpServletRequest req) {
        X509Certificate certificate = null;
        X509Certificate[] certsAttribute = (X509Certificate[]) req.getAttribute("javax.servlet.request.X509Certificate");
        if (certsAttribute != null) {
            certificate = certsAttribute[0];
        }
        return certificate;
    }

    private Boolean isCertificateValidForIDCardLogin(X509Certificate certificate) {
        String allowedIssuerX500NamePattern = CONFIG.getString(
                "auth.certificate.issuerX500NamePattern",
                "ESTEID"
        );
        try {
            List<String> x509CertificateExtensions = certificate.getExtendedKeyUsage();
            LOG.debug("X509 extensions of the certifcate:{}",
                    (x509CertificateExtensions != null) ? x509CertificateExtensions : "none");
            if (x509CertificateExtensions == null || !(x509CertificateExtensions.contains(CLIENT_AUTHENTICATION_OID))) {
                throw new RuntimeException("Can't find Extended Key Usage field of Client Authentication from ID card login certificate -");
            }
            X500Principal principal = certificate.getIssuerX500Principal();
            if (principal == null) {
                throw new RuntimeException("No issuer found from ID card certificate");
            }
            String issuerX500Name = principal.getName();
            if (issuerX500Name == null) {
                throw new RuntimeException("No Certificate issuer Name found");
            }
            LOG.debug("Certificate issued by:{}", issuerX500Name);
            if (!issuerX500Name.contains(allowedIssuerX500NamePattern)) {
                LOG.debug("No trusted certificate like {} issuer found from:{}",
                        allowedIssuerX500NamePattern,
                        issuerX500Name
                );
                throw new RuntimeException("No trusted issuer in certificate:");
            }
            if (!hasValidIssuancePolicy(certificate)) {
                throw new RuntimeException("No trusted issuance policy found in certificate:");
            }
        } catch (Throwable throwable) {
            LOG.catching(DEBUG, throwable);
            LOG.warn(
                    "Login tried with invalid Authentication ID card! - {} ... because the certificate was {}",
                    throwable.getMessage(),
                    certificate
            );
            return false;
        }
        return true;
    }

    private Boolean hasValidIssuancePolicy( X509Certificate certificate) throws IOException {
        // https://github.com/SK-EID/smart-id-documentation/wiki/Secure-Implementation-Guide#only-accept-certificates-with-trusted-issuance-policy
        final String[] validIssuancePolicyOIDs = {
                "1.3.6.1.4.1.10015.1.1",
                "1.3.6.1.4.1.10015.1.2",
                "1.3.6.1.4.1.51361.1.1.1",
                "1.3.6.1.4.1.51361.1.1.2",
                "1.3.6.1.4.1.51361.1.1.3",
                "1.3.6.1.4.1.51361.1.1.4",
                "1.3.6.1.4.1.51361.1.1.5",
                "1.3.6.1.4.1.51361.1.1.6",
                "1.3.6.1.4.1.51361.1.1.7",
                "1.3.6.1.4.1.51455.1.1.1"
        };
        byte[] extensionValue = certificate.getExtensionValue(
                Extension.certificatePolicies.getId());
        Objects.requireNonNull(extensionValue, "No certificate policy extension found");
        LOG.debug("extensionvalue to parse:{}", extensionValue);
        CertificatePolicies policies = CertificatePolicies.getInstance(
                JcaX509ExtensionUtils.parseExtensionValue(extensionValue)
        );
        Objects.requireNonNull(policies, "Certificate policy extension value was empty");
        LOG.debug("policies found:{}", policies);
        Set<String> policyIds = Arrays.stream(policies.getPolicyInformation())
                .map(PolicyInformation::getPolicyIdentifier)
                .map(ASN1ObjectIdentifier::getId)
                .collect(Collectors.toSet());
        LOG.debug("policy OID's contained:{}", policyIds);
        return Arrays.stream(validIssuancePolicyOIDs)
                .anyMatch(policyIds::contains);
    }

    private Map<String, String> parseSubjectDn(String dn) {
        Map<String, String> tmp = new HashMap<>();

        for (String s : dn.split(", ")) {
            int pos = s.indexOf('=');
            String attribute = s.substring(0, pos);
            String value = s.substring(pos + 1);

            if (attribute.equals("SERIALNUMBER") && value.contains("-")) {
                tmp.put(attribute, value.substring(6));
            } else {
                tmp.put(attribute, value);
            }
        }

        return tmp;
    }

    private void setUserLoggedIn(Auth a, Person user) {
        renewSessionId();

        if (CONFIG.getBoolean("auth.sslid")) {
            HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
            String sslID = (String) request.getAttribute("javax.servlet.request.ssl_session");
            LOG.debug("User sslID: " + sslID);
            session.put(Const.SESSION_SSLID, sslID);
        }
        a.setNewUser(isUserBound(user));
        session.put(Const.SESSION_USER_HANDLE, user);
        session.put(Const.SESSION_AUTH, a);
    }

    /**
     * Change session ID, keeping entries in original session map.
     */
    private void renewSessionId() {
        Map<String, Object> prevSession = new HashMap<>(session);
        if (LOG.isDebugEnabled()) {
            LOG.debug("Changing session ID. Copying keys: " + prevSession);
        }
        ((SessionMap<String, Object>) session).invalidate();
        session = ActionContext.getContext().getSession();
        session.putAll(prevSession);
    }

    /**
     * Perform OCSP verification for given certificate. Uses DigiDoc4j library
     * {@link org.digidoc4j.CertificateValidator#validate(X509Certificate)} method.
     *
     * @param certificate User session certificate that gets validated with OCSP request.
     * @return True if certificate is valid, false if OCSP query failed (certificate is not valid or OCSP verification
     * has a configuration problem).
     */
    public boolean isOCSPCheckedOK(X509Certificate certificate) {
        try {
            String issuerCA = SignedDoc
                    .getCommonName(certificate.getIssuerX500Principal().getName(X500Principal.RFC1779));
            String subjectDN = certificate.getSubjectDN().getName();
            LOG.debug("Performing OCSP verification for issuer CA: {}, subjectDN: {}", issuerCA, subjectDN);

            CertificateValidatorBuilder validatorBuilder = new CertificateValidatorBuilder();
            validatorBuilder.withConfiguration(digiDoc4jConfiguration.getConfiguration());
            CertificateValidator validator = validatorBuilder.build();
            validator.validate(certificate);
            LOG.debug("OCSP verification yielded positive result");
            return true;
        } catch (Exception e) {
            LOG.error("OCSP verification failed", e);
            addActionError(getText("login.errors.id_card.ocsp.check_failed"));
        }

        return false;
    }

    /**
     * Perform OCSP verification check for given certificate. Uses jDigiDoc library
     * method.
     *
     * @param certIn user session certificate that gets validated with OCSP request
     * @return #true if cert is valid, #false if OCSP query failed (cert is not valid or OCSP check has configuration
     * problem
     */

    /**
     * @return the redirectActionName
     */
    public String getRedirectActionName() {
        return redirectActionName;
    }

    /**
     * @param redirectActionNameNew the redirectActionName to set
     */
    public void setRedirectActionName(String redirectActionNameNew) {
        this.redirectActionName = redirectActionNameNew;
    }

    /**
     * @return the username
     */
    public String getUsername() {
        return username;
    }

    /**
     * @param usernameNew the username to set
     */
    public void setUsername(String usernameNew) {
        this.username = usernameNew;
    }

    /**
     * @return the password
     */
    public String getPassword() {
        return password;
    }

    /**
     * @param passwordNew the password to set
     */
    public void setPassword(String passwordNew) {
        this.password = passwordNew;
    }

    /**
     * @return the relayState
     */
    public String getRelayState() {
        return relayState;
    }

    /**
     * @param relayStateNew the relayState to set
     */
    public void setRelayState(String relayStateNew) {
        this.relayState = relayStateNew;
    }

    /**
     * @return the countryList
     */
    public List<Locale> getCountryList() {
        return countryList;
    }

    /**
     * @param countryListNew the countryList to set
     */
    public void setCountryList(List<Locale> countryListNew) {
        this.countryList = countryListNew;
    }

    /**
     * @return the countryCode
     */
    public String getCountryCode() {
        return countryCode;
    }

    /**
     * @param countryCodeNew the countryCode to set
     */
    public void setCountryCode(String countryCodeNew) {
        this.countryCode = countryCodeNew;
    }

    /**
     * @return the ssn
     */
    public String getSsn() {
        return ssn;
    }

    /**
     * @param ssnNew the ssn to set
     */
    public void setSsn(String ssnNew) {
        this.ssn = ssnNew;
    }

    /**
     * @return the overtakeCode
     */
    public String getOvertakeCode() {
        return overtakeCode;
    }

    /**
     * @param overtakeCodeNew the overtakeCode to set
     */
    public void setOvertakeCode(String overtakeCodeNew) {
        this.overtakeCode = overtakeCodeNew;
    }

    /**
     * @return the actionName
     */
    public String getActionName() {
        return actionName;
    }

    /**
     * @param overtakeSbmtNew the overtakeSbmt to set
     */
    public void setOvertakeSbmt(String overtakeSbmtNew) {
        this.overtakeSbmt = overtakeSbmtNew != null && !overtakeSbmtNew.isEmpty();
    }

}
