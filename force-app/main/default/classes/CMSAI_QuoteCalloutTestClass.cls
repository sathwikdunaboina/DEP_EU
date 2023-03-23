@isTest
private class CMSAI_QuoteCalloutTestClass {
     @isTest(SeeAllData=true) static void testCallout() {
        // Set mock callout class 
        //Test.setMock(HttpCalloutMock.class, new CMSAPI_QuoteCalloutMock());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        List<String> foOrder=new List<String>();
                 List<String> foOrderres=new List<String>();

         //foOrder.add('0065r000005Dw2HAAS');
         List<Opportunity> opList=new List<Opportunity>();
         //opList=[Select Id,Amount ,Factory_Order__c,Account.Name ,Account.BillingCountryCode from Opportunity where Id = '0065r000005Dw2HAAS'];
         opList=[Select Id,Amount ,Factory_Order__c,Account.Name ,Account.BillingCountryCode from Opportunity where Factory_Order__c != null AND Amount != null limit 1];

         system.debug('This is opplist'+opList);
         foOrder.add(opList[0].Id);
         foOrderres=quoteCallout.fetchInvoicesFromAPIForQuote(foOrder);
        //HttpResponse res = quoteCallout.fetchInvoicesFromAPIForQuote(foOrder);
        
        // Verify response received contains fake values
        //String contentType = res.getHeader('Content-Type');
        //System.assert(contentType == 'application/json');
        //String actualValue = res.getBody();
        //String expectedValue = '{"example":"test"}';
        //System.assertEquals(actualValue, expectedValue);
        //System.assertEquals(200, res.getStatusCode());
    }

}