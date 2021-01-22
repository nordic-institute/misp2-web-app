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

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.util.ArrayList;

import org.apache.commons.io.IOUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.config.entities.ActionConfig;

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
        Method actionMethod = actionClass.getMethod(methodName);
        return actionMethod;
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
            String constantsXML = IOUtils.toString(inputStream, "UTF-8");
            Document constantsDoc = XMLUtil.convertXMLToDocument(constantsXML);
            Element strutsElement = constantsDoc.getDocumentElement();
            ArrayList<Element> constantElements = XMLUtil.getChildren(strutsElement, "constant");
            for (Element constantElement : constantElements) {
                if (constantElement.getAttribute("name").equals(name)) {
                    return constantElement.getAttribute("value");
                }
            }
            return null; // Constant with specified name was not found
        } catch (XMLUtilException e) {
            throw new RuntimeException(e);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
