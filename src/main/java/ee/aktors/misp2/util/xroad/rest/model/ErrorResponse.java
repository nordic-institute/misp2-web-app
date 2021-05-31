package ee.aktors.misp2.util.xroad.rest.model;

public class ErrorResponse {

    private String type;
    private String message;
    private String detail;

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getDetail() {
		return detail;
	}

	public void setDetail(String detail) {
		this.detail = detail;
	}

	@Override
	public String toString() {
		return "ErrorResponse{" +
			"type='" + type + '\'' +
			", message='" + message + '\'' +
			", detail='" + detail + '\'' +
			'}';
	}
}
