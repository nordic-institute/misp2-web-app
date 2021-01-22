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

package ee.aktors.misp2.util.mobileid;

import java.util.Iterator;

import javax.xml.namespace.QName;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.Name;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPConnection;
import javax.xml.soap.SOAPConnectionFactory;
import javax.xml.soap.SOAPConstants;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPFactory;
import javax.xml.soap.SOAPMessage;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import ee.aktors.misp2.util.SOAPUtils;


public class MobileIdAuthenticator {

    private String idCode;
    private String serviceName;
    private String messageToDisplay;
    private String digiDocServiceURL;
    
    private final String DIGIDOC_SERVICE_NS_URI = "http://www.sk.ee/DigiDocService/DigiDocService_2_3.wsdl";
    private final String DIGIDOC_SERVICE_NS_PREFIX = "dig";
    private final String DIGIDOC_SERVICE_AUTH_REQUEST = "MobileAuthenticate";
    private final String DIGIDOC_SERVICE_STATUS_REQUEST = "GetMobileAuthenticateStatus";
    private int retryCount = 60;
    private int pollIntervalMs = 3000;
    private final String MESSAGING_MODE = "asynchClientServer";
    private final String RESPONSE_OUTSTANDING_TRANSACTION = "OUTSTANDING_TRANSACTION"; 
    private final String RESPONSE_USER_AUTHENTICATED = "USER_AUTHENTICATED";
   
    private static final Logger LOG = LogManager.getLogger(MobileIdAuthenticator.class);
    
    public MobileIdAuthenticator(String serviceName, String messageToDisplay,
            String digiDocServiceURL) {
        this.serviceName = serviceName;
        this.messageToDisplay = messageToDisplay;
        this.digiDocServiceURL = digiDocServiceURL;
    }

    public MobileIdSessionData startAuthentication(String phoneNo) throws SOAPException{
        if(phoneNo != null && !phoneNo.startsWith("372") && !phoneNo.startsWith("+372"))
            phoneNo = "+372" + phoneNo;        
        SOAPMessage requestMessage = createSOAPRequest(DIGIDOC_SERVICE_AUTH_REQUEST);
        SOAPBody soapBody = requestMessage.getSOAPBody();
        Name elementType = SOAPFactory.newInstance().createName("type", "xsi",  "http://www.w3.org/2001/XMLSchema-instance");
        SOAPElement requestElement = soapBody.addChildElement(DIGIDOC_SERVICE_AUTH_REQUEST, DIGIDOC_SERVICE_NS_PREFIX);
        requestElement.addChildElement("IDCode").addAttribute(elementType, "xsd:string");
        requestElement.addChildElement("CountryCode").addAttribute(elementType, "xsd:string");
        requestElement.addChildElement("PhoneNo").addAttribute(elementType, "xsd:string").addTextNode(phoneNo);
        requestElement.addChildElement("Language").addAttribute(elementType, "xsd:string").addTextNode("EST");
        requestElement.addChildElement("ServiceName").addAttribute(elementType, "xsd:string").addTextNode(serviceName);
        requestElement.addChildElement("MessageToDisplay").addAttribute(elementType, "xsd:string").addTextNode(messageToDisplay);
        requestElement.addChildElement("MessagingMode").addAttribute(elementType, "xsd:string").addTextNode(MESSAGING_MODE);
        requestElement.addChildElement("AsyncConfiguration").addAttribute(elementType, "xsd:int").addTextNode("0");
        requestElement.addChildElement("ReturnCertData").addAttribute(elementType, "xsd:boolean").addTextNode("false");
        requestElement.addChildElement("ReturnRevocationData").addAttribute(elementType, "xsd:boolean").addTextNode("false");
        
        SOAPConnectionFactory soapConnectionFactory = SOAPConnectionFactory.newInstance();
        SOAPConnection soapConnection = soapConnectionFactory.createConnection();
        SOAPUtils.logSOAPMessage(requestMessage);
        SOAPMessage soapResponse = soapConnection.call(requestMessage, digiDocServiceURL);
        SOAPUtils.logSOAPMessage(soapResponse);

        MobileIdSessionData mobileIdSessionData = new MobileIdSessionData();
        mobileIdSessionData.setSessCode(getResponseItemValue(soapResponse, "Sesscode"));
        mobileIdSessionData.setFirstName(getResponseItemValue(soapResponse, "UserGivenname"));
        mobileIdSessionData.setLastName(getResponseItemValue(soapResponse, "UserSurname"));
        mobileIdSessionData.setPersonalCode(getResponseItemValue(soapResponse, "UserIDCode"));
        mobileIdSessionData.setChallenge(getResponseItemValue(soapResponse, "ChallengeID"));
        mobileIdSessionData.setPhoneNo(phoneNo);
        return mobileIdSessionData;
     }

    public boolean finishAuthentication(MobileIdSessionData session) throws SOAPException{
        if(session.getSessCode() == null){
            LOG.error("MobileAuthenticate Session is null");  
            return false;
        }
        SOAPMessage requestMessage = createSOAPRequest(DIGIDOC_SERVICE_AUTH_REQUEST);
        SOAPBody soapBody = requestMessage.getSOAPBody();
        Name elementType = SOAPFactory.newInstance().createName("type", "xsi",  "http://www.w3.org/2001/XMLSchema-instance");
        SOAPElement requestElement = soapBody.addChildElement(DIGIDOC_SERVICE_STATUS_REQUEST, DIGIDOC_SERVICE_NS_PREFIX);
        requestElement.addChildElement("Sesscode").addAttribute(elementType, "xsd:string").addTextNode(session.getSessCode());
        requestElement.addChildElement("WaitSignature").addAttribute(elementType, "xsd:boolean").addTextNode("true");
        
        SOAPConnectionFactory soapConnectionFactory = SOAPConnectionFactory.newInstance();
        SOAPConnection soapConnection = soapConnectionFactory.createConnection();
        SOAPUtils.logSOAPMessage(requestMessage);
        SOAPMessage soapResponse = soapConnection.call(requestMessage, digiDocServiceURL);
        SOAPUtils.logSOAPMessage(soapResponse);

        String status = getResponseItemValue(soapResponse, "Status");
        String signature = getResponseItemValue(soapResponse, "Signature");
        if(status.equals(RESPONSE_USER_AUTHENTICATED))
            return true;
        else{
            LOG.error("status: " + status);  
            return false;
        }
     }
    
    private String getResponseItemValue(SOAPMessage soapResponse, String itemName) throws SOAPException {
        SOAPElement responseNode = null;
        if(soapResponse.getSOAPBody().getChildElements().hasNext())
            responseNode = (SOAPElement) soapResponse.getSOAPBody().getChildElements().next();
        if(responseNode == null){
            LOG.error("Response not found");
            return null;
        }else
            LOG.debug("response:" + responseNode.getLocalName());
        QName qname = new QName(itemName);
        Iterator<?> it = responseNode.getChildElements(qname);
        String value = null;
        if (it.hasNext()) {
            Object childObj = it.next();
            if (childObj instanceof SOAPElement) {
                SOAPElement childNode = (SOAPElement) childObj;
                value = childNode.getValue();
            }
        }
        LOG.debug(itemName + ": "+ value);
        return value;
    }

    private SOAPMessage createSOAPRequest(String request) throws SOAPException {
        SOAPMessage requestMessage = MessageFactory.newInstance(SOAPConstants.SOAP_1_1_PROTOCOL).createMessage();
        requestMessage.getSOAPPart().getEnvelope().addNamespaceDeclaration("xsd", "http://www.w3.org/2001/XMLSchema");;
        requestMessage.getSOAPPart().getEnvelope().addNamespaceDeclaration("xsi", "http://www.w3.org/2001/XMLSchema-instance");;
        requestMessage.getSOAPPart().getEnvelope().addNamespaceDeclaration(DIGIDOC_SERVICE_NS_PREFIX, DIGIDOC_SERVICE_NS_URI);
        Name enc = SOAPFactory.newInstance().createName("encodingStyle", "SOAP-ENV",  "http://schemas.xmlsoap.org/soap/envelope/");
        requestMessage.getSOAPPart().getEnvelope().addAttribute( enc, "http://schemas.xmlsoap.org/soap/encoding/");
        return requestMessage;
    }
}
