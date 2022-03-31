package ee.aktors.misp2.util;

import java.io.File;

public class TestFileUtil {
    /**
     * Get file path from test resource directory NB! Only for use in unit-tests.
     *
     * @param fileName
     *            config file name in test resource folder.
     * @return file path from given directory
     */
    public static String getConfigPathForTest(String fileName) {
        ClassLoader classLoader = TestFileUtil.class.getClassLoader();
        File file = new File(classLoader.getResource(fileName).getFile());
        return file.getAbsolutePath();
    }
}
