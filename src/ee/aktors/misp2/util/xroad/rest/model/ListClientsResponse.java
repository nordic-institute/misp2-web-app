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

package ee.aktors.misp2.util.xroad.rest.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public class ListClientsResponse {

	public static class ProducerInfo {

		public static class Id {

			@JsonProperty("member_class")
			private String memberClass;
			@JsonProperty("member_code")
			private String memberCode;
			@JsonProperty("subsystem_code")
			private String subsystemCode;
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

			public String getObjectType() {
				return objectType;
			}

			public String getSubsystemCode() {
				return subsystemCode;
			}

			public void setSubsystemCode(String subsystemCode) {
				this.subsystemCode = subsystemCode;
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

		private Id id;
		private String name;

		public Id getId() {
			return id;
		}

		public void setId(Id id) {
			this.id = id;
		}

		public String getName() {
			return name;
		}

		public void setName(String name) {
			this.name = name;
		}

	}

	private List<ProducerInfo> member;

	public List<ProducerInfo> getMember() {
		return member;
	}

	public void setMember(List<ProducerInfo> member) {
		this.member = member;
	}
}
