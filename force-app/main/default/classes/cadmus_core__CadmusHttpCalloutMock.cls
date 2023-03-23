/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CadmusHttpCalloutMock implements System.HttpCalloutMock {
    global String body;
    global Integer code;
    global String endpoint;
    global String method;
    global Map<String,String> responseHeaders;
    global String status;
    global CadmusHttpCalloutMock(Integer code, String status, String body, String method, Map<String,String> responseHeaders, String endpoint) {

    }
    global System.HttpResponse respond(System.HttpRequest req) {
        return null;
    }
    global static void setTestCalloutMockSuccess(String targetId) {

    }
    global static void setTestCalloutMock(Integer code, String status, String body, String method, Map<String,String> responseHeaders, String endpoint) {

    }
}
