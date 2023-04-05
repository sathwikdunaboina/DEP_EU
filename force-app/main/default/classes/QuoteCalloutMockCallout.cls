@isTest
global class QuoteCalloutMockCallout implements HttpCalloutMock {
    
    private Integer statusCode;
    
    public QuoteCalloutMockCallout(Integer statusCode){
        this.statusCode = statusCode;
    }
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        CMSAPI1__c settings = CMSAPI1__c.getOrgDefaults();
        System.assertEquals('callout:VFS_Global_APIs'+settings.Endpoint_QA__c, request.getEndpoint());
        System.assertEquals('POST', request.getMethod());
        response.setHeader('contentType', 'application/json');
        response.setBody('{"example":"test"}');
        response.setStatusCode(this.statusCode);
        return response;
    }
}