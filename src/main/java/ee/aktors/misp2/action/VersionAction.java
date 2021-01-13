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

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.Action;

import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.Properties;
/**
 * Action to display web-app version.
 */
public class VersionAction extends BaseAction {

    private static final long serialVersionUID = 1L;
    private static final Logger LOG = LogManager.getLogger(UserAction.class);
    private String version;
    
    /**
     * Get web-app version number from pom.properties or
     * add error message.
     * @return success status
     */
    @Override
    @HTTPMethods(methods = { HTTPMethod.GET })
    public String execute() {
        try {
            String ver = getPomVersion();
            LOG.info("POM version " + ver);
            setVersion(ver);
        } catch (IOException e) {
            LOG.error("Failed to find version.", e);
            addActionError(getText("text.error.version_not_found"));
            return Action.ERROR; 
        }
        return Action.SUCCESS;
    }
    
    /**
     * @return version property value from pom.properties
     * @throws IOException on failure to read from pom.properties
     */
    private static String getPomVersion() throws IOException {
        Properties props = getPomProperties();
        Object ver = props.get("version");
        if (ver == null) {
            throw new IOException("Could not find 'version' from POM properties."
                    + "Existing keys: " + props.keySet() + ".");
        }
        return (String)ver;
    }

    /**
     * @param str text content to be searched from
     * @param subStr substring to be found from content
     * @return text of str before last subStr; if subStr is not found, the entire str
     */
    private static String getBeforeLast(String str, String subStr) {
        if (str == null || subStr == null) {
            return str;
        }
        int i = str.lastIndexOf(subStr);
        if (i == -1) {
            return str;
        }
        return str.substring(0, i);
    }   

    /**
     * @return configuration properties from pom.properties file
     * @throws IOException when POM properties file is not found
     */
    private static Properties getPomProperties() throws IOException {
        String classPath = VersionAction.class
                .getResource(VersionAction.class.getSimpleName() + ".class")
                .getPath();
        
        String rootPath;
         // in case deployed in external Tomcat server
        if (classPath.contains("/../src/main/webapp/WEB-INF/")) {
            rootPath = getBeforeLast(classPath, "/../src/main/webapp/WEB-INF/") + "/";
        }
        // in case deployed internally in Eclipse
        else if (classPath.contains("/classes/")) {
            rootPath = getBeforeLast(classPath, "/classes/")
                    + "/m2e-wtp/web-resources/";
        } else {
            throw new IOException("Maven POM not found");
        }
        String pomPropertiesPath = rootPath + "META-INF/maven/misp2/misp2/pom.properties";
        URL pomPropertiesUrl = new URL("file", null, pomPropertiesPath);
        InputStream inputStream = pomPropertiesUrl.openStream();
        Properties props = new Properties();
        props.load(inputStream);
        inputStream.close();
        return props;
    }

    /**
     * @return the version
     */
    public String getVersion() {
        return version;
    }

    /**
     * @param versionNew  the version to set
     */
    public void setVersion(String versionNew) {
        this.version = versionNew;
    }
}
