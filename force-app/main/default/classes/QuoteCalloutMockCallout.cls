@isTest
global class QuoteCalloutMockCallout implements HttpCalloutMock {
    
    private Integer statusCode;
    
    public QuoteCalloutMockCallout(Integer statusCode){
        this.statusCode = statusCode;
    }
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        CMSAPI1__c settings = CMSAPI1__c.getOrgDefaults();
        System.assertEquals('{!Environment.VFS_Global_API Endpoint Named Credentials}'+settings.Endpoint_QA__c, request.getEndpoint());
        System.assertEquals('POST', request.getMethod());
        response.setHeader('contentType', 'application/json');
        response.setBody('{"example":"test","quoteId":"122334","success":"true","errorMessage":"Customer Account Null"}');
        response.setStatusCode(this.statusCode);
        return response;
    }
    @isTest static void testParse() {
        String jsonString = '{"source":"Sales Connect","requestedBy":"a434539","owner":"thc0011","externalId":"0065r000005E1rcAAC","dealer":{"salesPersonName":"Test","mainDealerName":"Test","id":"NL-100756","dealerNumber":"12345"},"customer":{"postalCode":"4153 RD","phone":null,"name":"Volvo Financial Services Beesd","countryCode":"DE","CMS_ID":"567400","city":"Beesd","address":"Stationsweg 2"},"countryCode":"DE","brand":"VT","asset":[{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"},{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"},{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"},{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"}]}';
        quoteWrapperClass.parse(jsonString);
    }
}