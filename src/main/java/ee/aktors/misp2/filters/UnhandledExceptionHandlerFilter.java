package ee.aktors.misp2.filters;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * The filter handles Tomcat servlet errors and
 * redirects to web-app specific error pages instead of default Tomcat error page,
 * because the latter can reveal unwanted system information including stacktraces.
 * 1) Catches and logs unhandled exceptions
 * 2) Redirects to known Struts error pages
 * 3) flushes the response buffer to prevent any
 *    Servlet3-spec error-page redirects by the servlet container
 * <br/>Class has been initially adapted from: https://gist.github.com/eeichinger/4545911
 */
public class UnhandledExceptionHandlerFilter extends OncePerRequestFilter {
    private static final Logger LOGGER = LogManager.getLogger(PDFFilter.class.getName());

    /**
     * Define error handling behavior: delegate request down in filter chain. In case of
     * exception, catch it and delegate to handleException().
     * @param request HTTP request
     * @param response HTTP response (written and flushed on handled error)
     * @param filterChain filter chain called
     */
    @Override
    public void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws IOException,
        ServletException {
        StatusCodeCaptureWrapper responseWrapper = new StatusCodeCaptureWrapper(request, response);
        Throwable exception = null;

        try {
            chain.doFilter(request, responseWrapper);
        } catch (ServletException e) {
            if (e.getRootCause() != null) {
                exception = e.getRootCause();
            } else {
                exception = e;
            }
        } catch (Throwable e) { // NOSONAR this is an UnhandledExceptionHandler - we need to catch this
            exception = e;
        }

        // In case exception is obtained, handle it. (Do not handle when client interrupts.)
        if (exception != null && !"ClientAbortException".equals(exception.getClass().getSimpleName())) {
            ensureErrorStatusCodeSet(responseWrapper);
            response.setStatus(responseWrapper.getStatusCode());
            handleException(request, response, responseWrapper.getStatusCode(), exception);
        }

        // flush to prevent servlet container to add anymore  headers or content
        response.flushBuffer();
    }

    private void ensureErrorStatusCodeSet(StatusCodeCaptureWrapper responseWrapper) {
        if (responseWrapper.getStatusCode() == null) {
            responseWrapper.setStatus(500);
        }
    }

    /**
     * Destroy filter, no operation
     */
    @Override
    public void destroy() {
        // noop
    }
    
    /**
     * Handle received exception. Make log entry and redirect response.
     * @param request HTTP request
     * @param response HTTP response (redirect will be applied)
     * @param statusCode HTTP response status code
     * @param throwable associated Exception to be handled. Assumed to be not null.
     * @throws IOException on redirect failure
     */
    private void handleException(HttpServletRequest request, HttpServletResponse response,
            Integer statusCode, Throwable throwable) throws IOException {
        LOGGER.error(String.format(
                    "Received error status %s for URI %s:",
                    statusCode, request.getRequestURI()),
                    throwable);
        
        if (statusCode != null && statusCode.intValue() == 404) {
            response.sendRedirect(request.getContextPath() + "/error404.action");
            response.setStatus(statusCode);
        } else {
            response.sendRedirect(request.getContextPath() + "/error.action");
        }
    }

    // suppress calls to sendError() and just setStatus() instead
    // do NOT use sendError() otherwise per servlet spec the container will send an html error page
    private class StatusCodeCaptureWrapper extends HttpServletResponseWrapper {

        private Integer statusCode;
        private HttpServletRequest request;
        private HttpServletResponse response;

        /**
         * Constructor
         * @param request HTTP request
         * @param response HTTP response
         */
        public StatusCodeCaptureWrapper(HttpServletRequest request, HttpServletResponse response) {
            super(response);
            this.request = request;
            this.response = response;
        }

        /**
         * @return HTTP status code
         */
        public Integer getStatusCode() {
            return statusCode;
        }

        /**
         * Do not use sendError() method in parent class
         * to avoid Tomcat showing user its default
         * error handling page. Instead delegate to handleException().
         * @param statusCode HTTP response status code corresponding to handled Exception
         */
        @Override
        public void sendError(int statusCode) throws IOException {
            // do NOT use sendError() otherwise per servlet spec the container will send an html error page
            this.setStatus(statusCode);
            handleException(request, response, statusCode,
                    new RuntimeException("Unknown servlet error (status " + statusCode + ")."));
        }

        /**
         * Do not use sendError() method in parent class
         * to avoid Tomcat showing user its default
         * error handling page. Instead delegate to handleException().
         * @param statusCode HTTP response status code corresponding to handled exception
         * @param statusMessage error message corresponding to handled exception
         */
        @Override
        public void sendError(int statusCode, String statusMessage) throws IOException {
            // do NOT use sendError() otherwise per servlet spec the container will send an html error page
            this.setStatus(statusCode, statusMessage);
            handleException(request, response, statusCode, new RuntimeException(statusMessage));
        }

        /**
         * Set status code to given value.
         * @param statusCode HTTP status code to be set
         */
        @Override
        public void setStatus(int statusCode) {
            this.statusCode = statusCode;
            super.setStatus(statusCode);
        }

        /**
         * Set status code to given value along with status message.
         * @param statusCode HTTP status code
         * @param statusMessage HTTP status message
         */
        @Override
        public void setStatus(int statusCode, String statusMessage) {
            this.statusCode = statusCode;
            super.setStatus(statusCode, statusMessage);
        }
    }
}
