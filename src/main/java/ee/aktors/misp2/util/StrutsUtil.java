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

import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.config.entities.ActionConfig;
import org.apache.commons.io.IOUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * Struts util
 */
public final class StrutsUtil {
    
    private StrutsUtil() { }

    /**
     * Get invoked method of Struts 2 action class (represented by actionInvocation)
     * @param actionInvocation action invocation
     * @return action method
     * @throws NoSuchMethodException  if a matching method is not found or if the name is "<init>"or "<clinit>".
     * @throws SecurityException If a security manager, s, is present and the caller's class loader is not the same as
     *  or an ancestor of the class loader for the current class and invocation of s.checkPackageAccess()
     *  denies access to the package of this class.
     */
    public static Method getInvokedActionMethod(ActionInvocation actionInvocation) throws NoSuchMethodException,
            SecurityException {
        Class<?> actionClass = actionInvocation.getAction().getClass();
        ActionConfig actionConfig = actionInvocation.getProxy().getConfig();

        String methodName = actionConfig.getMethodName();
        // If methodName is undefined, then use default method name
        methodName = (methodName != null ? methodName : "execute");
        return actionClass.getMethod(methodName);
    }

    /**
     * Get Struts constant from "struts-constants.xml" file. <br/>
     * If file does not have constant with specified name, then returns null
     * @param name name of constant
     * @return constant with specified name
     */
    public static String getConstant(String name) {
        try {
            InputStream inputStream = StrutsUtil.class.getClassLoader().getResourceAsStream("struts-constants.xml");
            assert inputStream != null;
            String constantsXML = IOUtils.toString(inputStream, StandardCharsets.UTF_8);
            Document constantsDoc = XMLUtil.convertXMLToDocument(constantsXML);
            Element strutsElement = constantsDoc.getDocumentElement();
            List<Element> constantElements = XMLUtil.getChildren(strutsElement, "constant");
            for (Element constantElement : constantElements) {
                if (constantElement.getAttribute("name").equals(name)) {
                    return constantElement.getAttribute("value");
                }
            }
            return null; // Constant with specified name was not found
        } catch (XMLUtilException | IOException e) {
            throw new RuntimeException(e);
        }
    }
}
