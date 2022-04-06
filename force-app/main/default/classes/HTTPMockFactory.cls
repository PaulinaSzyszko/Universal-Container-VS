@IsTest
public with sharing class HTTPMockFactory implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public HTTPMockFactory() {
        this(200, 'OK', '{"example": "test"}', new Map<String, String>{
                'Content-Type' => 'application/json;charset=UTF-8'
        });
    }

    public HTTPMockFactory(Integer code, String status, String body, Map<String, String> responseHeaders) {

        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            response.setHeader(key, this.responseHeaders.get(key));
        }
        response.setBody(this.body);
        response.setStatusCode(this.code);
        response.setStatus(this.status);
        return response;
    }
}
