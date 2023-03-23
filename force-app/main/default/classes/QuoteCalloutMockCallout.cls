@isTest
global class QuoteCalloutMockCallout implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        System.assertEquals('callout:VFS_Global_APIs', request.getEndpoint());
        System.assertEquals('POST', request.getMethod());
        response.setHeader('contentType', 'application/json');
        response.setBody('{"example":"test"}');
        response.setStatusCode(200);
        return response;
    }
}