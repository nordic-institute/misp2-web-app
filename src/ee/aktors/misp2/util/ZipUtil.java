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

package ee.aktors.misp2.util;

import java.io.Closeable;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Deque;
import java.util.Enumeration;
import java.util.LinkedList;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipOutputStream;

/**
 */
public final class ZipUtil {
    
    private static final int BUFFER_SIZE = 1024;

    private ZipUtil() { }
    
    /**
     * Packs files to zip. Files may be usual files and also directories.
     * 
     * @param files files to zip
     * @param zipfile file to zip to
     * @throws IOException if an I/O error occurs
     */
    public static void zip(ArrayList<File> files, File zipfile) throws IOException {
        OutputStream out = new FileOutputStream(zipfile);
        Closeable res = out;
        try {
            ZipOutputStream zout = new ZipOutputStream(out);
            res = zout;
            for (File file : files) {
                zipIndividual(file, zout);
            }
        } finally {
            res.close();
        }
    }

    /**
     * Packs individual directory or file to zip stream with their subdirectories.
     * 
     * @param file
     * @param zout
     */
    private static void zipIndividual(File file, ZipOutputStream zout) throws IOException {
        String path = file.getCanonicalPath();
        String base = path.substring(0, path.length() - file.getName().length());
        // base path, which will be cut from  each file or directory path.
        Deque<File> queue = new LinkedList<File>();
        queue.push(file);

        while (queue.isEmpty() == false) {
            file = queue.pop();
            String name = file.getCanonicalPath().substring(base.length());

            if (file.isDirectory()) {
                name = name + "/"; // Needed for ZipEntry to recognize directory
                zout.putNextEntry(new ZipEntry(name));
                zout.closeEntry();

                for (File child : file.listFiles()) {
                    queue.push(child);
                }
            } else {
                zout.putNextEntry(new ZipEntry(name));
                copy(file, zout);
                zout.closeEntry();
            }
        }
    }

    /**
     * Unpacks zip file contents to chosen directory
     * @param zipfile file to unzip
     * @param directory where to unzip to
     * @throws IOException if an I/O error occurs
     */
    public static void unzip(File zipfile, File directory) throws IOException {
        ZipFile zfile = new ZipFile(zipfile);
        Enumeration<? extends ZipEntry> entries = zfile.entries();
        while (entries.hasMoreElements()) {
            ZipEntry entry = entries.nextElement();
            File file = new File(directory, entry.getName());
            if (entry.isDirectory()) {
                file.mkdirs();
            } else {
                file.getParentFile().mkdirs();
                InputStream in = zfile.getInputStream(entry);
                try {
                    copy(in, file);
                } finally {
                    in.close();
                }
            }
        }
        zfile.close();
    }

    private static void copy(InputStream in, OutputStream out) throws IOException {
        byte[] buffer = new byte[BUFFER_SIZE];
        while (true) {
            int readCount = in.read(buffer);
            if (readCount < 0) {
                break;
            }
            out.write(buffer, 0, readCount);
        }
    }

    private static void copy(File file, OutputStream out) throws IOException {
        InputStream in = new FileInputStream(file);
        try {
            copy(in, out);
        } finally {
            in.close();
        }
    }

    private static void copy(InputStream in, File file) throws IOException {
        OutputStream out = new FileOutputStream(file);
        try {
            copy(in, out);
        } finally {
            out.close();
        }
    }

}
