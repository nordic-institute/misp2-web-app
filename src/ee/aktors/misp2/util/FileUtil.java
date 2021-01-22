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

package ee.aktors.misp2.util;

import java.io.File;
import java.io.IOException;
import java.io.StringWriter;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.opensymphony.xwork2.ActionContext;

import ee.aktors.misp2.model.Person;
import ee.aktors.misp2.model.Portal;

/**
 *
 */
public final class FileUtil {

    private static final int MAX_TEMP_DIRS = 10000;

    private FileUtil() {
    }
    
    private static final Logger LOGGER = LogManager.getLogger(FileUtil.class);

    /**
     * Calls {@link #getTempDir(Person)} with current user taken from session
     * @return generated dir
     */
    public static File getTempDir() {
        Person user = (Person) ActionContext.getContext().getSession().get(Const.SESSION_USER_HANDLE);
        return getTempDir(user);
    }

    /**
     * Get temporary directory.
     * @param user - Person whose ssn will be used for generating unique name for directory.
     * @return generated dir
     */
    public static File getTempDir(Person user) {
        File baseDir = new File(System.getProperty("java.io.tmpdir"));
        String baseName = System.currentTimeMillis() + "-" + user.getSsn() + "-";
        File tempDir = new File(baseDir, baseName + 0);

        for (int counter = 0; counter < MAX_TEMP_DIRS; counter++) {
            tempDir = new File(baseDir, baseName + counter);
            if (tempDir.mkdir())
                break;
        }

        return tempDir;
    }

    /**
     * @param parent parent folder
     * @param file file
     * @return true if that file is in that folder or in any child folder of that folder,
     * false otherwise
     */
    public static boolean isParent(File parent, File file) {

        File f;
        try {
            parent = parent.getCanonicalFile();

            f = file.getCanonicalFile();
        } catch (IOException e) {
            return false;
        }

        while (f != null) {
            // equals() only works for paths that are normalized, hence the need for
            // getCanonicalFile() above. "a" isn't equal to "./a", for example.
            if (parent.equals(f)) {
                return true;
            }

            f = f.getParentFile();
        }

        return false;
    }

    /**
     * Find webapp root name assuming current class is located in file system
     */
    protected static String getCurrentClassPath() {
        URL url = FileUtil.class.getResource("FileUtil.class");
        String className = url.getFile();
        return className;
    }

    /**
     * Get file input stream from /src/ directory NB! Only for use in unit-tests.
     * 
     * @param fileName
     *            file path from /src/ folder.
     * @return file path from given directory
     */
    public static String getConfigPathForTest(String fileName) {
        String currentPath = getCurrentClassPath();
        String configPath = currentPath.split("target")[0] + "src/" + fileName;
        LOGGER.trace("Config path: " + configPath);
        return configPath;
    }

    /**
     * Get file name with the following format
     * ${prefix}-${portal.shortName}-${currentDate}.${extension}
     * e.g. export-xtee_v6-2018-04-07.zip.
     * @param prefix file name prefix as string
     * @param portal Portal entity for current portal, portal short name is used in file name.
     *      Can be null - in that case, portal name is not read nor added to file name.
     * @param extension file name extension appended with '.' as suffix to file name
     * @return export file name
     */
    public static String getExportFileName(String prefix, Portal portal, String extension) {
        StringWriter fileNameWriter = new StringWriter();
        if (prefix != null) {
            fileNameWriter.append(prefix + "-");
        }
        if (portal != null && portal.getShortName() != null) {
            String portalName = portal.getShortName().replaceAll("[^A-Za-z0-9-_]", "");
            fileNameWriter.append(portalName + "-");
        }
        String date = new SimpleDateFormat("yyy-MM-dd").format(new Date());
        fileNameWriter.append(date).append("." + extension);
        return fileNameWriter.toString();
    }

    /**
     * Compare input strings first case-insensitively. That results in sort order
     * ab Xy xy, not Xy ab xy.
     * @param str1 first input string
     * @param str2 second input string
     * @return negative number if str1 is deemed less than str2, 0 if input strings are equal,
     * positive number if str2 is greater
     */
    public static int compareCaseInsensitiveFirst(String str1, String str2) {
        int result = str1.toLowerCase().compareTo(str2.toLowerCase());
        if (result != 0) {
            return result;
        } else {
            return str1.compareTo(str2);
        }
    }
}
