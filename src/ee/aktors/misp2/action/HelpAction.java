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

package ee.aktors.misp2.action;

import com.opensymphony.xwork2.ActionSupport;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.ServletContext;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.ServletActionContext;

/**
 * Return user manual as stream
 */
public class HelpAction extends ActionSupport {

    private static final long serialVersionUID = 1L;
    private InputStream userGuideStream;
    private String contentType;
    private static final Logger LOG = LogManager.getLogger(HelpAction.class);
    
    @Override
    public String execute() throws FileNotFoundException {
        contentType = "application/pdf";
        String lang = null;
        String targetDemographic = null;

        String requestPath = ServletActionContext.getRequest().getServletPath();
        LOG.trace(" requestPath = " + requestPath);
        
        Pattern pattern = Pattern.compile("/([a-z]{2})_help(_manager)?\\.action");
        Matcher matcher = pattern.matcher(requestPath);
        if (matcher.find()) {
            lang = matcher.group(1); // language part from regex
            LOG.trace(" lang " + lang);
            String targetPart = matcher.group(2); // optional manager part from regex
            if (targetPart != null) {
                targetDemographic = "manager";
            } else {
                targetDemographic = "user";
            }
            LOG.trace(" targetDemographic " + targetDemographic);
        } else {
            LOG.error("Cannot retrieve user guide: invalid request path " + requestPath);
            return ERROR;
        }
        
        ServletContext servletContext = ServletActionContext.getServletContext();
        String filePath = getUserGuideFilePath(lang, targetDemographic, servletContext);
        
        File file = new File(filePath);
        if (!file.exists()) {
            LOG.error("Cannot retrieve user guide: file not found. " + filePath);
            return ERROR;
        }
        userGuideStream = new FileInputStream(file);
        return SUCCESS;
    }
    
    private String getUserGuideFilePath(String lang, String targetDemographic, ServletContext servletContext) {
        return servletContext.getRealPath(
                "/pages/user_guide/" + targetDemographic + "/" + lang + "/kasutusjuhend.pdf");
    }

    /**
     * @return content type of manual
     */
    public String getContentType() {
        return contentType;
    }
    
    /**
     * @return input stream to user guide file
     */
    public InputStream getUserGuideStream() {
        return userGuideStream;
    }
}
