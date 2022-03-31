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

package ee.aktors.misp2.interceptor;

import java.io.StringWriter;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.configuration.Configuration;
import org.apache.http.HttpStatus;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.struts2.StrutsStatics;
import com.opensymphony.xwork2.ActionInvocation;

import ee.aktors.misp2.provider.ConfigurationProvider;
import ee.aktors.misp2.util.MISPUtils;

/**
 * <p>
 * This interceptor keeps count of incoming user requests and
 * blocks them if the rate exceeds configured limits, such
 * as during a DoS (denial of service) attack or
 * during repeated authentication attempts.
 * </p>
 */
public class DosProtectionInterceptor extends BaseInterceptor implements StrutsStatics {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LogManager.getLogger(DosProtectionInterceptor.class.getName());

    private static Map<String, RequestCounter> requestCountersConf = null;
    private static Map<String, RequestCounter> requestCounters = null;
    private static boolean enabled = false;
    private static Object requestCountersLock = new Object();
    
    private static Pattern allUrisRegex = null; // all request counter uris merged to one regex
                                                // this is a performance optimization to avoid
                                                // applying filter to irrelevant requests


    /**
     * Initializes interceptor by populating {@link #requestCountersConf}
     * @see com.opensymphony.xwork2.interceptor.Interceptor#destroy()
     */
    @Override
    public void init() {
        synchronized (requestCountersLock) {
            if (requestCounters == null) {
                
                Configuration conf = ConfigurationProvider.getConfig();
                enabled = conf.getBoolean("request_filter_enabled", false);
                if (!enabled) {
                    LOGGER.debug("Not initializing request counters. enable_request_filter = false");
                    return;
                }
                LOGGER.debug("Intialising requestCounters.");
                
                requestCountersConf = new ConcurrentHashMap<String, RequestCounter>();
                requestCounters = new ConcurrentHashMap<String, RequestCounter>();
                
                Iterator<String> it = conf.getKeys();
                while (it.hasNext()) {
                    final String key = it.next();
                    final String prefix = "request.filter";
                    String keypart = key;
                    if (keypart.startsWith(prefix)) {
                        keypart = keypart.substring(prefix.length(), keypart.length());
                        if (keypart.startsWith(".")) {
                            keypart = keypart.substring(1);
                        }
                        int splitIndex = keypart.indexOf(".");
                        String filterId = keypart.substring(0, splitIndex);
                        String filterAction = keypart.substring(splitIndex + 1);
                        RequestCounter requestCounter = requestCountersConf.get(filterId);
                        if (requestCounter == null) {
                            requestCounter = new RequestCounter(filterId);
                            requestCountersConf.put(filterId, requestCounter);
                        }
                        RequestFilter filter = requestCounter.getFilter();
                        String value = conf.getString(key);
                        if (filterAction.equals("rate")) {
                            String[] valueStrParts = value.split("/");
                            if (valueStrParts.length == 2) {
                                String rateStr = valueStrParts[0];
                                int rate = Integer.parseInt(rateStr);
                                String intervalStr = valueStrParts[1];
                                requestCounter.setRateCountLimit(rate);
                                long unitFactor = 1;
                                if (intervalStr.endsWith("s") || intervalStr.endsWith("sec")) {
                                    intervalStr = intervalStr.replaceAll("s$|sec$", "");
                                    unitFactor = 1000; // ms
                                } else if (intervalStr.endsWith("min")) {
                                    intervalStr = intervalStr.replaceAll("min$", "");
                                    unitFactor = 60 * 1000; // ms
                                } else if (intervalStr.endsWith("h")) {
                                    intervalStr = intervalStr.replaceAll("h$", "");
                                    unitFactor = 60 * 60 * 1000; // ms
                                }
                                if (intervalStr.isEmpty()) {
                                    intervalStr = "1";
                                }
                                long interval = Long.parseLong(intervalStr) * unitFactor;
                                requestCounter.setRateInterval(interval);
                            }
                        } else if (filterAction.equals("match.uri")) {
                            filter.setUri(value);
                        } else if (filterAction.equals("match.ip")) {
                            filter.setSourceIp(value);
                        } else if (filterAction.equals("match.session")) {
                            filter.setSessionId(value);
                        } else if (filterAction.equals("match.body")) {
                            filter.setRequestBody(value);
                        } else {
                            LOGGER.error("Unexpected conf parameter '" + filterAction + "'");
                        }
                    }
                    
                }
            }
        }
        boolean hasAllUrisSet = true;
        boolean firstRegex = true;
        StringWriter allUrisRegexSw = new StringWriter();
        for (String key : requestCountersConf.keySet()) {
            RequestCounter counterConf = requestCountersConf.get(key);
            if (hasAllUrisSet) {
                String uriRegex = counterConf.getFilter().getUri();
                if (uriRegex != null) {
                    if (firstRegex) {
                        firstRegex = false;
                    } else {
                        allUrisRegexSw.append("|");
                    }
                    allUrisRegexSw.append("(");
                    allUrisRegexSw.append(preprocessRegex(uriRegex));
                    allUrisRegexSw.append(")");
                    
                } else {
                    LOGGER.warn("Counter conf " + key + " does not have URI."
                            + " Counter conf: " + counterConf + ".");
                    hasAllUrisSet = false;
                }
            }
            LOGGER.info("RequestCounter conf: " + key + ": "
                    + counterConf);
        }
        if (hasAllUrisSet) {
            LOGGER.info("Setting global URI regex: " + allUrisRegexSw.toString() + "");
            allUrisRegex = Pattern.compile(allUrisRegexSw.toString());
        } else {
            LOGGER.warn("Not using global URI regex for performance optimization.");
            allUrisRegex = null;
        }
    }
    
    /**
     * Limits access if request rate exceeds configured limits.
     * @see com.opensymphony.xwork2.interceptor.Interceptor#intercept(com.opensymphony.xwork2.ActionInvocation)
     * @param ai  a action invocation
     * @return invocation return code
     * @throws Exception can throw
     */
    @Override
    public String intercept(ActionInvocation ai) throws Exception {
        if (!enabled) {
            if (LOGGER.isTraceEnabled()) {
                LOGGER.trace("DOS PROTECTION INTERCEPTOR - NOT ENABLED!");
            }
            return ai.invoke();
        }

        HttpServletRequest request = (HttpServletRequest) ai.getInvocationContext().get(HTTP_REQUEST);
        
        if (allUrisRegex != null) {
            String uri = getUri(request);
            Matcher m = allUrisRegex.matcher(uri);
            if (!m.matches()) {
                if (LOGGER.isTraceEnabled()) {
                    LOGGER.trace("DOS PROTECTION INTERCEPTOR - URI not intercepted: '" + uri + "'.");
                }
                return ai.invoke();
            }
        }
        
        if (LOGGER.isTraceEnabled()) {
            LOGGER.trace("DOS PROTECTION INTERCEPTOR");
        }
        
        HttpSession httpSession = request.getSession(false);
        
        // Try to find existing counters
        Map<String, RequestCounter> countersExistingMap = findRequestCounters(request, httpSession);
        // Create new counters to those configurations where existing counters were not found
        List<RequestCounter> counters = createNewCountersFromConf(request, httpSession, countersExistingMap);
        // add existing counters to newly created counters
        counters.addAll(countersExistingMap.values());
        
        logRequestCounters(request, httpSession);
        if (counters.size() > 0) {
            for (RequestCounter counter : counters) {
                counter.registerRequest();
                if (!counter.isRateWithinLimit()) {
                    LOGGER.warn("Request blocked by counter: " + counter.getOriginalKey() + " " + counter);
                    HttpServletResponse response = 
                            (HttpServletResponse)ai.getInvocationContext()
                                .get(StrutsStatics.HTTP_RESPONSE);
                    response.setStatus(HttpStatus.SC_FORBIDDEN);
                    String message = getText("text.error.too_many_requests", counter.getBlockedTimeStr());
                    request.setAttribute("message", message);
                    LOGGER.info("Displaying error: " + message);
                    return "tooManyRequestsError";
                }
            }
        }

        return ai.invoke();
    }
    
    private void logRequestCounters(HttpServletRequest request, HttpSession httpSession) {
        if (LOGGER.isTraceEnabled()) {
            LOGGER.trace("Request counters for given request. "
                    + " Found: " + requestCounters.size() + "."
                    + " URI: " + getUri(request) + "."
                    + " SessionID: " + getSessionId(httpSession) + "."
                    + " IP:" + getSourceIp(request) + "."
            );
            for (String key : requestCounters.keySet()) {
                RequestCounter counter = requestCounters.get(key);
                LOGGER.trace("RequestCounter " + counter.getOriginalKey() + " " + key 
                        + ". Request arrivals (" + counter.requestTimes.size() + ") > " + counter.requestTimes);
            }
        }
    }
    
    private class RequestFilter {
        private String uri;
        private String requestBody;
        private String sourceIp;
        private String sessionId;
        public RequestFilter() {
            uri = null;
            requestBody = null;
            sourceIp = null;
            sessionId = null;
        }

        /**
         * @param uri the uri to set
         */
        public void setUri(String uri) {
            this.uri = uri;
        }

        /**
         * @param sourceIp the sourceIp to set
         */
        public void setSourceIp(String sourceIp) {
            this.sourceIp = sourceIp;
        }

        /**
         * @param sessionId the sessionId to set
         */
        public void setSessionId(String sessionId) {
            this.sessionId = sessionId;
        }

        /**
         * @param requestBody the requestBody to set
         */
        public void setRequestBody(String requestBody) {
            this.requestBody = requestBody;
        }
        
        /**
         * @return summary of given filter
         *         (unique for filter instances with different parameters)
         */
        public String toString() {
            return "uri:" + uri
                 + (sourceIp != null ? " sourceIp:" + sourceIp : "")
                 + (sessionId != null ? " sessionId:" + sessionId : "")
                 + (requestBody != null ? " requestBody:" + requestBody : "");
        }

        /**
         * @return the uri
         */
        public String getUri() {
            return uri;
        }

        /**
         * @return the requestBody
         */
        public String getRequestBody() {
            return requestBody;
        }

        /**
         * @return the sourceIp
         */
        public String getSourceIp() {
            return sourceIp;
        }

        /**
         * @return the sessionId
         */
        public String getSessionId() {
            return sessionId;
        }
    }
    
    /**
     * Class instances with request filter configuration,
     * request rate limit configuration (defining the request rate when to start blocking requests)
     * and the queue with latest request times.
     * 
     * The instances of this class are used both as templates for request blocking configuration
     * and containers of arrival statistics of each type of request.
     */
    private class RequestCounter {
        private final RequestFilter filter;
        // double ended queue for incoming request times.
        // we want to add new ones to the end and remove old ones from the beginning
        private final Deque<Long> requestTimes;
        private long matchCount;
        private long blockCount;
        private int rateCountLimit;
        private long rateInterval; // ms
        private String originalKey; // key in requestCountersConf map
        public RequestCounter(String originalKey) {
            // double ended queue for incoming request times.
            // we want to add new ones to the end and remove old ones from the beginning
            requestTimes = new ArrayDeque<Long>();
            matchCount = 0;
            blockCount = 0;
            rateCountLimit = -1;
            rateInterval = -1; // ms
            filter = new RequestFilter();
            this.originalKey = originalKey;
        }
        
        public String getBlockedTimeStr() {
            if (!this.isRateWithinLimit() && requestTimes.size() > 0) {
                int index = requestTimes.size() - rateCountLimit - 1;
                if (index >= 0 && index < requestTimes.size()) {
                    Iterator<Long> it = requestTimes.iterator();
                    long timeOut = requestTimes.getFirst();
                    while (it.hasNext() && index >= 0) {
                        timeOut = it.next();
                        index--;
                    }
                    long now = System.currentTimeMillis();
                    long timeLeft = rateInterval - (now - timeOut);
                    return (int)Math.ceil(timeLeft / 1000.) + " s";
                }
                
            }
            return "Test";
        }

        public void setRateFrom(RequestCounter other) {
            this.rateCountLimit = other.rateCountLimit;
            this.rateInterval = other.rateInterval;
        }
        
        public void setRateInterval(long interval) {
            this.rateInterval = interval;
        }

        public void setRateCountLimit(int rate) {
            this.rateCountLimit = rate;
        }

        /**
         * @return the originalKey
         */
        public String getOriginalKey() {
            return originalKey;
        }

        public String toString() {
            String rateIntervalStr;
            if (rateInterval % 1000 == 0) {
                rateIntervalStr = (rateInterval/1000) + "s";
            } else {
                rateIntervalStr = rateInterval + "ms";
            }
            String timesStr = "";
            if (requestTimes.size() > 0) {
                timesStr = " times:" + requestTimes;
            }
            return filter.toString() + "  rate:"
                    + rateCountLimit + "/"
                    + rateIntervalStr
                    + timesStr;
        }
        
        /**
         * Register request time by adding current moment to {@link #requestTimes}
         * dequeue and removing all requests that no longer fall within {@link #rateInterval}.
         */
        public void registerRequest() {
            synchronized(requestTimes) {
                matchCount++;
                boolean rateWithinLimitBefore = isRateWithinLimit();
                Long now = System.currentTimeMillis();
                // add new request
                requestTimes.add(now);
                // remove old ones that fall out of the rateInterval window
                Long cutoff = now - rateInterval;
                while (requestTimes.size() > 0 && requestTimes.getFirst() < cutoff) {
                    requestTimes.removeFirst();
                }
                boolean rateWithinLimitAfter = isRateWithinLimit();
                if (rateWithinLimitBefore && !rateWithinLimitAfter) {
                    blockCount++;
                }
            }
        }
        
        /**
         * @return true if request rate is below the rate limit,
         *         false, if request rate is above the limit after registering
         */
        public boolean isRateWithinLimit() {
            return  requestTimes.size() <= rateCountLimit;
        }

        /**
         * @return the filter
         */
        public RequestFilter getFilter() {
            return filter;
        }
        
    }

    private List<RequestCounter> createNewCountersFromConf(
            HttpServletRequest httpRequest, HttpSession httpSession,
            Map<String, RequestCounter> existingCounters) {
        List<RequestCounter> filteredCounters = new ArrayList<RequestCounter>();
        Set<String> skippedKeys = existingCounters.keySet();
        for (RequestCounter requestCounterConf : requestCountersConf.values()) {
            if (skippedKeys.contains(requestCounterConf.getOriginalKey())) {
                continue;
            }
            String uriRegex = requestCounterConf.getFilter().getUri();
            String sessionIdRegex = requestCounterConf.getFilter().getSessionId();
            String sourceIpRegex = requestCounterConf.getFilter().getSourceIp();
            String requestBodyRegex = requestCounterConf.getFilter().getRequestBody();
            
            String uri = getRegexMatch(uriRegex, getUri(httpRequest));
            String sessionId = getRegexMatch(sessionIdRegex, getSessionId(httpSession));
            String sourceIp = getRegexMatch(sourceIpRegex, getSourceIp(httpRequest));
            
            String requestBody;
            if (requestBodyRegex != null) {
                String requestBodyIn = httpRequest != null ? getRequestBody(httpRequest) : null;
                requestBody = getRegexMatch(requestBodyRegex, requestBodyIn);
                LOGGER.debug("Matched body regex '" + requestBodyRegex + "' to '" + requestBodyIn
                        + "'. Result '" + requestBody + "'");
            } else {
                requestBody = null;
            }
            boolean matches = !(uriRegex != null && uri == null
                             || sessionIdRegex != null && sessionId == null
                             || sourceIpRegex != null && sourceIp == null
                             || requestBodyRegex != null && requestBody == null);
            
            // If 
            if (matches) {
                LOGGER.debug("Creating new request counter for " + requestCounterConf);
                RequestCounter requestCounter = new RequestCounter(requestCounterConf.getOriginalKey());
                requestCounter.setRateFrom(requestCounterConf);
                RequestFilter filter = requestCounter.getFilter();
                filter.setUri(uri);
                filter.setSessionId(sessionId);
                filter.setSourceIp(sourceIp);
                filter.setRequestBody(requestBody);
                
                filteredCounters.add(requestCounter);
                synchronized(requestCountersLock) {
                    requestCounters.put(requestCounter.toString(), requestCounter);
                }
            }
        }
        return filteredCounters;
    }

    private String getUri(HttpServletRequest httpRequest) {
        if (httpRequest != null) {
            return httpRequest.getRequestURI();
        } else {
            return null;
        }
    }

    private String getSourceIp(HttpServletRequest httpRequest) {
        if (httpRequest != null) {
            return MISPUtils.getSourceIp(httpRequest);
        } else {
            return null;
        }
    }

    private String getSessionId(HttpSession httpSession) {
        if (httpSession != null) {
            return httpSession.getId();
        } else {
            return null;
        }
    }

    private String getRegexMatch(String regex, String text) {
        if (regex == null || text == null) {
            return null;
        }
        regex = preprocessRegex(regex);
        
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(text);
        if (m.matches()) {
            if (m.groupCount() == 0) {
                return m.group(0);
            } else if (m.groupCount() > 0) {
                return m.group(1);
            }
        }
        return null;
    }

    /**
     * If regex does not have grouping, quote existing regex and add group around it.
     * Make sure the regex matches all containing entries.
     * @param regex
     * @return processed regex or initial regex if regex went undmodified
     */
    private String preprocessRegex(String regex) {
        if (!regex.contains("(")) {
            return ".*(" + Pattern.quote(regex) + ").*";
        } else {
            return regex;
        }
    }

    private Map<String, RequestCounter> findRequestCounters(HttpServletRequest httpRequest,
            HttpSession httpSession) {
        Map<String, RequestCounter> filteredCounters = new HashMap<String, RequestCounter>();
        String requestBodyIn = null;
        for (RequestCounter requestCounter : requestCounters.values()) {
            String uri = requestCounter.getFilter().getUri();
            String sessionId = requestCounter.getFilter().getSessionId();
            String sourceIp = requestCounter.getFilter().getSourceIp();
            String requestBody = requestCounter.getFilter().getRequestBody();
            
            boolean matches = true;
            matches &= uri == null || contains(getUri(httpRequest), uri);
            matches &= sessionId == null || contains(getSessionId(httpSession), sessionId);
            matches &= sourceIp == null || contains(getSourceIp(httpRequest), sourceIp);
            if (matches && requestBody != null) {
                if (requestBodyIn == null && httpRequest != null) {
                    requestBodyIn = getRequestBody(httpRequest);
                }
                if (!contains(requestBodyIn, requestBody)) {
                    LOGGER.debug("Request body '" + requestBodyIn
                            +  "'  does not contain '" + requestBody +  "'");
                    matches = false;
                }
            }
            
            if (matches) {
                LOGGER.debug("Request matched with counter " + requestCounter);
                filteredCounters.put(requestCounter.getOriginalKey(), requestCounter);
            }
        }
        return filteredCounters;
    }

    private String getRequestBody(HttpServletRequest httpRequest) {
        Map<?,?> paramMap = httpRequest.getParameterMap();
        StringWriter sw = new StringWriter();
        boolean first = true;
        for (Object key : paramMap.keySet()) {
            Object value = paramMap.get(key);
            if (value instanceof String[]) {
                String[] ar = (String[]) value;
                for (String arValue : ar) {
                    if (!first) {
                        sw.append("&");
                    } else {
                        first = false;
                    }
                    sw.append(key.toString() + "=" + arValue.toString());
                }
            }
        }
        if (LOGGER.isTraceEnabled()) {
            LOGGER.trace("Request body:" + sw.toString());
        }
        
        return sw.toString();
    }

    private boolean contains(String string, String substring) {
        if (string == null || substring == null) {
            return false;
        } else {
            return string.contains(substring);
        }
    }
}
