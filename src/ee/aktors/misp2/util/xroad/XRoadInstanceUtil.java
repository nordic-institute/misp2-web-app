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

package ee.aktors.misp2.util.xroad;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;

import ee.aktors.misp2.provider.ConfigurationProvider;
import ee.aktors.misp2.util.xroad.exception.DataExchangeException;

/**
 * Util to download and extract federated instances from
 * X-Road v6 security server
 * @author sander
 */
public final class XRoadInstanceUtil {
    protected static Logger log = LogManager.getLogger(XRoadInstanceUtil.class);
    private XRoadInstanceUtil() { } // utility class does not have a constructor

    /**
     * Download and extract federated instances from X-Road v6 security server.
     * @param url Security server URL, e.g. http://SECSERVER:8080
     * @return list of XRoad v6 instances from security server
     *      main instance is the first element
     * @throws DataExchangeException on downloading or ZIP extraction failure
     */
    public static List<String> getFederatedInstances(String url) throws DataExchangeException {
        String verificationConfUrl = url;
        final String contextPath = "verificationconf";
        if (!verificationConfUrl.endsWith(contextPath)) {
            if (!verificationConfUrl.endsWith("/")) {
                verificationConfUrl = verificationConfUrl + "/";
            }
            verificationConfUrl = verificationConfUrl + contextPath;
        }
        File zipFile = downloadFile(verificationConfUrl);
        return extractFederatedInstances(zipFile);
    }

    /**
     * @return list of default X-Road v6 instance options from conf
     */
    public static List<String> getDefaultInstances() {
        String[] instances = ConfigurationProvider.getConfig().getStringArray("xrd.v6.instances");
        return Arrays.asList(instances);
    }

    /**
     * @return list of default X-Road v6 instance options from conf
     */
    public static String getDefaultInstancesAsJson() {
        List<String> instances = getDefaultInstances();
        ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
        StringWriter sw = new StringWriter();
        try {
            ow.writeValue(sw, instances);
        } catch (IOException e) {
            log.error("Could now write default X-Road instances to JSON string", e);
        }
        return sw.toString();
    }
    
    /**
     * Downloads a file from a URL to temporary file
     * http://www.codejava.net/java-se/networking/use-httpurlconnection-to-download-file-from-an-http-url
     * @param downloadUrl HTTP URL of the file to be downloaded
     * @return temporary file with downloaded data
     * @throws IOException on failure
     */
    private static File downloadFile(String downloadUrl) throws DataExchangeException {
        URL url;
        try {
            url = XRoadUtil.getMetaServiceEndpointUrlWithTimeouts(downloadUrl);
        } catch (DataExchangeException e) {
            if (e.getType() == DataExchangeException.Type.XROAD_SECURITY_SERVER_URL_MALFORMED) {
                throw new DataExchangeException(
                    DataExchangeException.Type.XROAD_INSTANCE_QUERY_MALFORMED_URL,
                    "Malformed URL '" + downloadUrl + "'", e,
                    // message parameters:
                    downloadUrl);
            } else {
                throw e;
            }
        }
        HttpURLConnection httpConn = null;
        try {
            httpConn = (HttpURLConnection) url.openConnection();
            int responseCode = httpConn.getResponseCode();
     
            // always check HTTP response code first
            if (responseCode == HttpURLConnection.HTTP_OK) {
                File tmpFile = File.createTempFile("download", null);
                log.info("Downloading file from " + downloadUrl + " to " + tmpFile.getName());
                String disposition = httpConn.getHeaderField("Content-Disposition");
                String contentType = httpConn.getContentType();
                int contentLength = httpConn.getContentLength();
     
                log.debug("Content-Type: " + contentType + ", "
                        + "Content-Disposition: " + disposition + ", "
                        + "Content-Length = " + contentLength);
     
                // opens input stream from the HTTP connection
                InputStream inputStream = httpConn.getInputStream();
                 
                // opens an output stream to save into file
                FileOutputStream outputStream = new FileOutputStream(tmpFile);
     
                int bytesRead = -1;
                final int bufferSize = 4096;
                byte[] buffer = new byte[bufferSize];
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, bytesRead);
                }
     
                outputStream.close();
                inputStream.close();
     
                log.debug("File downloaded");
                return tmpFile;
            } else {
                throw new DataExchangeException(
                        DataExchangeException.Type.XROAD_INSTANCE_QUERY_HTTP_ERROR,
                        "Failed to download file from '" + downloadUrl
                        + "'. Server replied HTTP status " + responseCode, null,
                        // message parameters:
                        downloadUrl, "" + responseCode);
            }
        } catch (IOException e) {
            throw new DataExchangeException(
                    DataExchangeException.Type.XROAD_INSTANCE_QUERY_CONNECTION_FAILED,
                    "Failed to download file to URL '" + downloadUrl + "'", e,
                    // message parameters:
                    downloadUrl);
        } finally {
            if (httpConn != null) {
                httpConn.disconnect();
            }
        }
    }
    
    static final Pattern SHARED_PARAMS_PATTERN =
            Pattern.compile("^verificationconf/([^/]+)/shared-params.xml$");
    static final Pattern INSTANCE_IDENTIFIER_PATTERN =
            Pattern.compile("^verificationconf/instance-identifier$");

    private static List<String> extractFederatedInstances(File zipFile) throws DataExchangeException {
        List<String> federatedInstances = new ArrayList<String>();
        String instanceIdentifier = null;
        try (ZipInputStream zipInputStream = new ZipInputStream(
                new BufferedInputStream(new FileInputStream(zipFile)))) {
            
            ZipEntry entry;
            while ((entry = zipInputStream.getNextEntry()) != null) {
                String path = entry.getName();
                log.debug("New entry: " + path);
                
                Matcher sharedParamsMatcher = SHARED_PARAMS_PATTERN.matcher(path);
                if (sharedParamsMatcher.find()) { // is shared-params.xml file; second path is X-Road instance
                    log.debug("Found instance from " + path);
                    federatedInstances.add(sharedParamsMatcher.group(1));
                } else if (INSTANCE_IDENTIFIER_PATTERN.matcher(path).find()) { // is instance-identifier file
                    // file 'instance-identifier' ends gathering configurations
                    instanceIdentifier = IOUtils.toString(zipInputStream, StandardCharsets.UTF_8);
                    log.debug("instance-identifier file found: " + instanceIdentifier);
                    break;
                }
            }
        } catch (FileNotFoundException e) {
            throw new DataExchangeException(
                    DataExchangeException.Type.XROAD_INSTANCE_QUERY_ZIP_MISSING,
                    "Downloaded ZIP file not found.", e);
        } catch (IOException e) {
            throw new DataExchangeException(
                    DataExchangeException.Type.XROAD_INSTANCE_QUERY_ZIP_READING_FAILED,
                    "Extracting federated instances from ZIP file failed.", e);
        }
        if (instanceIdentifier != null) {
            // Add instanceIdentifier as a first element
            log.debug("Adding identifer '" + instanceIdentifier + "' as first.");
            federatedInstances.remove(instanceIdentifier);
            federatedInstances.add(0, instanceIdentifier);
        } else {
            throw new DataExchangeException(
                    DataExchangeException.Type.XROAD_INSTANCE_QUERY_ZIP_IDENTIFIER_MISSING,
                    "Instance identifier is missing from ZIP.", null);
        }
        return federatedInstances;
    }
    
    /**
     * Check if ordered set contains keys of ordered subset in original order.
     * @param keySet1 first ordered set of strings
     * @param keySet2 first ordered set of strings
     * @return true if keySet1 contains ordered subset of keySet1 elements, false otherwise
     * For example:
     * <pre>
     * containsOrderedSubset({"A", "B", "C"}, {"A", "B"}) -> true
     * containsOrderedSubset({"A", "B", "C"}, {"A", "C"}) -> true
     * </pre>
     * but
     *  <pre>
     *  containsOrderedSubset({"A", "B", "C"}, {"A", "D"}) -> false
     *  containsOrderedSubset({"A", "B", "C"}, {"B", "A"}) -> false
     *  </pre>
     *  Last example is false, because item order is taken into account during comparison.
     */
    public static boolean containsOrderedSubset(Set<String> keySet1, Set<String> keySet2) {
        Iterator<String> it1 = keySet1.iterator();
        String key1 = null;
        int index1 = -1;
        
        if (keySet2.isEmpty()) {
            return true;
        }
        Iterator<String> it2 = keySet2.iterator();
        String key2 = it2.next();
        int index2 = 0;
        
        while (true) {
            if (it1.hasNext()) {
                key1 = it1.next();
                index1++;

                if (areEqual(key1, key2)) {
                    if (it2.hasNext()) {
                        index2++;
                        key2 = it2.next();
                    } else {
                        return true;
                    }
                }
                if (keySet2.size() - index2 > keySet1.size() - index1) {
                    return false;
                }
            } else {
                return false;
            }
        }
    }

    /**
     * Null-safe string comparison
     * @param str1 first string
     * @param str2 second string
     * @return true if both strings are null or
     *          if both strings are not null and are equal;
     *         false otherwise
     */
    private static boolean areEqual(String str1, String str2) {
        return str1 == null && str2 == null
                || str1 != null && str2 != null && str1.equals(str2);
    }
}
