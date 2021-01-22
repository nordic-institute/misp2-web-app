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

package ee.aktors.misp2.util.xroad.rest.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public class ListMethodsResponse {

	public static class QueryInfo {
        @JsonProperty("member_class")
        private String memberClass;
        @JsonProperty("member_code")
        private String memberCode;
        @JsonProperty("subsystem_code")
        private String subsystemCode;
        @JsonProperty("service_code")
        private String serviceCode;
        @JsonProperty("object_type")
        private String objectType;
        @JsonProperty("xroad_instance")
		private String xroadInstance;

		public String getMemberClass() {
			return memberClass;
		}

		public void setMemberClass(String memberClass) {
			this.memberClass = memberClass;
		}

		public String getMemberCode() {
			return memberCode;
		}

		public void setMemberCode(String memberCode) {
			this.memberCode = memberCode;
		}

		public String getSubsystemCode() {
			return subsystemCode;
		}

		public void setSubsystemCode(String subsystemCode) {
			this.subsystemCode = subsystemCode;
		}

		public String getServiceCode() {
			return serviceCode;
		}

		public void setServiceCode(String serviceCode) {
			this.serviceCode = serviceCode;
		}

		public String getObjectType() {
			return objectType;
		}

		public void setObjectType(String objectType) {
			this.objectType = objectType;
		}

		public String getXroadInstance() {
			return xroadInstance;
		}

		public void setXroadInstance(String xroadInstance) {
			this.xroadInstance = xroadInstance;
		}

	}

	private List<QueryInfo> service;

	public List<QueryInfo> getService() {
		return service;
	}

	public void setService(List<QueryInfo> service) {
		this.service = service;
	}
}
