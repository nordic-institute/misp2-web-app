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

package ee.aktors.misp2.action.crypto;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.opensymphony.xwork2.ActionContext;
import ee.aktors.misp2.action.QuickTipAction;
import ee.aktors.misp2.action.crypto.dto.Result;
import ee.aktors.misp2.action.crypto.dto.SigningMethodResult;
import ee.aktors.misp2.action.crypto.dto.TranslationsResult;
import ee.aktors.misp2.beans.Auth;
import ee.aktors.misp2.beans.Auth.AUTH_TYPE;
import ee.aktors.misp2.httpMethodChecker.HTTPMethod;
import ee.aktors.misp2.httpMethodChecker.HTTPMethods;
import ee.aktors.misp2.service.crypto.DigitalSigningService;
import ee.aktors.misp2.util.Const;
import ee.aktors.misp2.util.JsonUtil;
import ee.aktors.misp2.util.mobileid.MobileIdSessionData;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;
import org.digidoc4j.Container;
import org.digidoc4j.DataFile;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.core.MediaType;
import java.io.IOException;
import java.io.InputStream;
import java.util.Base64;

import static ee.aktors.misp2.action.crypto.dto.SigningMethodResult.SigningType.ID_CARD;
import static ee.aktors.misp2.action.crypto.dto.SigningMethodResult.SigningType.MOBILE_ID;

/**
 * Digital signing - common utility for signing data with id-card or mobileId
 */
public class DigitalSigningAction extends QuickTipAction implements StrutsStatics {

	private static final long serialVersionUID = 1L;
	private static final Logger LOG = LogManager.getLogger(DigitalSigningAction.class);

	private static final String PARAM_IN_DATA_TO_SIGN = "dataToSign";
	private static final String PARAM_IN_FILE_NAME = "fileName";
	private static final String CONTAINER_MIME_TYPE = "application/vnd.etsi.asic-e+zip";

	protected DigitalSigningService digitalSigningService;

	public DigitalSigningAction(DigitalSigningService digitalSigningService) {
		this.digitalSigningService = digitalSigningService;
	}

	@Override
	public void prepare() throws Exception {
		super.prepare();
	}

	@Override
	@HTTPMethods(methods = {HTTPMethod.GET})
	public String execute() {
		return SUCCESS;
	}

	/**
	 * Finds appropriate signing method based on the method user used to log in
	 * @return default signing method
	 * @throws IOException if can't get HttpResponse writer object
	 */
	@HTTPMethods(methods = {HTTPMethod.POST})
	public String getTranslations() throws IOException {
		HttpServletResponse response = (HttpServletResponse) ActionContext.getContext().get(HTTP_RESPONSE);
		TranslationsResult result = new TranslationsResult(getTextProvider());
		result.setResult(Result.OK);

		response.setContentType(JsonUtil.JSON_CONTENT_TYPE);
		response.setStatus(HttpServletResponse.SC_OK);
		ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
		ow.writeValue(response.getWriter(), result);
		return null;
	}

	/**
	 * Finds appropriate signing method based on the method user used to log in
	 * @return default signing method
	 * @throws IOException if can't get HttpResponse writer object
	 */
	@HTTPMethods(methods = {HTTPMethod.POST})
	public String getDefaultSigningMethod() throws IOException {
		HttpServletResponse response = (HttpServletResponse) ActionContext.getContext().get(HTTP_RESPONSE);
		SigningMethodResult result = new SigningMethodResult();
		result.setResult(Result.OK);
		int authType = ((Auth) session.get(Const.SESSION_AUTH)).getType();
		if (AUTH_TYPE.valueOf(authType) == AUTH_TYPE.MOBILE_ID) {
			MobileIdSessionData midData = (MobileIdSessionData) session.get(Const.SESSION_MID_USER_DATA);
			if(midData == null) {
				result.setResult(TranslationsResult.ERROR_SERVER);
				LOG.error("User logged in via mobile-id but mid data sent in session. Unable to continue signing process.");
			} else {
				result.setSigningType(MOBILE_ID);
				result.setPhoneNoNumber(midData.getPhoneNo());
				result.setIdentityCode(midData.getPersonalCode());
			}
		} else {
			result.setSigningType(ID_CARD);
		}

		response.setContentType(JsonUtil.JSON_CONTENT_TYPE);
		response.setStatus(HttpServletResponse.SC_OK);
		ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
		ow.writeValue(response.getWriter(), result);
		return null;
	}

	/**
	 * <p>Stores {@link DataFile} in session containing the data that needs to be signed.<p/>
	 *
	 * <p>Incomming HttpRequest has to have two parameters:<br>
	 * {@link DigitalSigningAction#PARAM_IN_DATA_TO_SIGN} - data that will be signed. Encoded as base64<br>
	 * {@link DigitalSigningAction#PARAM_IN_FILE_NAME} - name of the file the data will be put into.
	 * Filename is important as it becomes part of the signed hash</p>
	 *
	 * @return {@link Result#OK} with default error message translations
	 * @throws IOException if can't get HttpResponse writer object
	 */
	@HTTPMethods(methods = {HTTPMethod.POST})
	public String uploadDataToSign() throws IOException {
		HttpServletRequest request = (HttpServletRequest) ActionContext.getContext().get(HTTP_REQUEST);
		HttpServletResponse response = (HttpServletResponse) ActionContext.getContext().get(HTTP_RESPONSE);
		String dataToSign = request.getParameter(PARAM_IN_DATA_TO_SIGN);
		String fileName = request.getParameter(PARAM_IN_FILE_NAME);
		Result result = new Result();

		LOG.debug("Handling data upload with name " + fileName);
		String decoded = new String(Base64.getDecoder().decode(dataToSign));
		DataFile dataFile = new DataFile(decoded.getBytes(), fileName, MediaType.TEXT_XML);
		Container container = digitalSigningService.createContainer(dataFile);
		session.put(Const.SESSION_DIGI_CONTAINER, container);
		session.put(Const.SESSION_IS_CONTAINER_SIGNED, false);

		result.setResult(Result.OK);
		response.setContentType(JsonUtil.JSON_CONTENT_TYPE);
		response.setStatus(HttpServletResponse.SC_OK);
		ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
		ow.writeValue(response.getWriter(), result);
		return null;
	}

	/**
	 * Uploads signed bdoc {@link Container} that is stored in session
	 *
	 * @return Signed {@link Container} as http response.<br>
	 * {@link HttpServletResponse#SC_NOT_FOUND} response status
	 * if container is not found in session.
	 */
	@HTTPMethods(methods = {HTTPMethod.POST})
	public String downloadContainer() {
		HttpServletResponse response = (HttpServletResponse) ActionContext.getContext().get(HTTP_RESPONSE);

		Boolean isContainerSigned = (Boolean) session.get(Const.SESSION_IS_CONTAINER_SIGNED);
		Container container = (Container) session.get(Const.SESSION_DIGI_CONTAINER);
		if (isContainerSigned == null || !isContainerSigned || container == null) {
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
			return null;
		}
		String fileName = container.getDataFiles().get(0).getName() + ".bdoc";
		response.setStatus(HttpServletResponse.SC_OK);
		response.setContentType(CONTAINER_MIME_TYPE);
		response.setHeader("Content-Disposition", "attachment; filename=" + fileName);
		try {
			InputStream containerStream = container.saveAsStream();
			ServletOutputStream outputStream = response.getOutputStream();
			IOUtils.copy(containerStream, outputStream);
			response.flushBuffer();
		} catch (IOException e) {
			LOG.error("Error Writing file content to output stream", e);
		}
		return null;
	}
}
