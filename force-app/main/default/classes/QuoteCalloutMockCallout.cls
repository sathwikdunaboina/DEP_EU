@isTest
global class QuoteCalloutMockCallout implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        CMSAPI1__c settings = CMSAPI1__c.getOrgDefaults();
        System.assertEquals('callout:VFS_Global_APIs'+settings.Endpoint_QA__c, request.getEndpoint());
        System.assertEquals('POST', request.getMethod());
        response.setHeader('contentType', 'application/json');
        response.setBody('{"example":"test"}');
        response.setStatusCode(200);
        return response;
    }
}