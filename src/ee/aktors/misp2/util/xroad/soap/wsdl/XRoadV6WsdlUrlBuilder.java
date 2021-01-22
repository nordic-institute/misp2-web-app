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

package ee.aktors.misp2.util.xroad.soap.wsdl;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.Const.XROAD_VERSION;

/**
 * WSDL URL builder creates URL string from multiple inputs,
 * which points to WSDL in security server.
 * 
 * The class has been created to work around RIA checkstyle 'maximum 7
 * arguments to methods' limitation
 * 
 * @author sander.kallo
 *
 */
public class XRoadV6WsdlUrlBuilder {
    private String securityHost;
    private String xroadProtocolVer;
    private String xroadInstance;
    private String memberClass;
    private String memberCode;
    private String subsystemCode;
    private String serviceCode;
    private String serviceVersion;

    /**
     * Set security host
     * @param s security server hostname
     * @return this instance (itself)
     */
    public XRoadV6WsdlUrlBuilder setSecurityHost(String s) {
        this.securityHost = s;
        return this;
    }

    /**
     * Set X-Road protocol version
     * @param s X-Road protocol version
     * @return this instance (itself)
     */
    public XRoadV6WsdlUrlBuilder setXroadProtocolVer(String s) {
        this.xroadProtocolVer = s;
        return this;
    }

    /**
     * Set X-Road instance
     * @param s X-Road instance
     * @return this instance (itself)
     */
    public XRoadV6WsdlUrlBuilder setXroadInstance(String s) {
        this.xroadInstance = s;
        return this;
    }


    /**
     * Set X-Road member class
     * @param s X-Road member class
     * @return this instance (itself)
     */
    public XRoadV6WsdlUrlBuilder setMemberClass(String s) {
        this.memberClass = s;
        return this;
    }

    /**
     * Set X-Road instance
     * @param s X-Road member code
     * @return this instance (itself)
     */
    public XRoadV6WsdlUrlBuilder setMemberCode(String s) {
        this.memberCode = s;
        return this;
    }

    /**
     * Set X-Road instance
     * @param s X-Road subsystem code
     * @return this instance (itself)
     */
    public XRoadV6WsdlUrlBuilder setSubsystemCode(String s) {
        this.subsystemCode = s;
        return this;
    }

    /**
     * Set X-Road service code
     * @param s X-Road service code
     * @return this instance (itself)
     */
    public XRoadV6WsdlUrlBuilder setServiceCode(String s) {
        this.serviceCode = s;
        return this;
    }

    /**
     * Set X-Road service version
     * @param s X-Road service version
     * @return this instance (itself)
     */
    public XRoadV6WsdlUrlBuilder setServiceVersion(String s) {
        this.serviceVersion = s;
        return this;
    }
    /**
     * @return WSDL URL as string (method applies to X-Road v5 and v6)
     */
    public String toString() {
        try {
            if (xroadProtocolVer != null && xroadProtocolVer.equals(XROAD_VERSION.V6.getProtocolVersion())) {
                // if version is empty, do not even add the parameter, otherwise security server is unable to answer
                String serviceVersionParameter = "";
                if (serviceVersion != null && !serviceVersion.isEmpty()) {
                    serviceVersionParameter = "&" + "version" + "="
                            + URLEncoder.encode(serviceVersion, StandardCharsets.UTF_8.name());
                }
                
                
                return securityHost + Const.XROAD_V6_WSDL + "?" + "xRoadInstance" + "="
                    + URLEncoder.encode(xroadInstance,  StandardCharsets.UTF_8.name()) + "&" + "memberClass"   + "="
                    + URLEncoder.encode(memberClass,    StandardCharsets.UTF_8.name()) + "&" + "memberCode"    + "="
                    + URLEncoder.encode(memberCode,     StandardCharsets.UTF_8.name()) + "&" + "subsystemCode" + "="
                    + URLEncoder.encode(subsystemCode,  StandardCharsets.UTF_8.name()) + "&" + "serviceCode"   + "="
                    + URLEncoder.encode(serviceCode,    StandardCharsets.UTF_8.name())
                    + serviceVersionParameter;
            } else {
                return securityHost + Const.PROXY_URI + "?producer=" + memberCode;
            }
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException("UTF_8 encoding was not recognized, internal error.", e);
        }
    }

    /**
     * @return the xroadProtocolVer
     */
    public String getXroadProtocolVer() {
        return xroadProtocolVer;
    }

    /**
     * @return the xroadInstance
     */
    public String getXroadInstance() {
        return xroadInstance;
    }

    /**
     * @return the memberClass
     */
    public String getMemberClass() {
        return memberClass;
    }

    /**
     * @return the memberCode
     */
    public String getMemberCode() {
        return memberCode;
    }

    /**
     * @return the subsystemCode
     */
    public String getSubsystemCode() {
        return subsystemCode;
    }

    /**
     * @return the serviceCode
     */
    public String getServiceCode() {
        return serviceCode;
    }

    /**
     * @return the serviceVersion
     */
    public String getServiceVersion() {
        return serviceVersion;
    }
    
}
