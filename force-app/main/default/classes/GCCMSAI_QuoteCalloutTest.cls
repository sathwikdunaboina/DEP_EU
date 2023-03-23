/**
 * GC test for CMSAI logic. Uses GCQuoteCallout.
 * 
 * @author matei.lunca@fluidogroup.com 2022-07-29 creation from VFS code
 */
@isTest
public with sharing class GCCMSAI_QuoteCalloutTest {
    @isTest(SeeAllData=true) static void testCallout() {
        Test.setMock(HttpCalloutMock.class, new CMSAPI_QuoteCalloutMock());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        List<String> foOrder = new List<String>();
		List<String> foOrderres = new List<String>();

		List<Opportunity> opList = [SELECT Amount, FactoryOrder__c, Account.Name, Account.BillingCountryCode FROM Opportunity WHERE FactoryOrder__c != null LIMIT 1];

		System.debug('Opportunities: ' + opList);
		foOrder.add(opList[0].Id);
		foOrderres = GCQuoteCallout.fetchInvoicesFromAPIForQuote(foOrder);
        //HttpResponse res = quoteCallout.fetchInvoicesFromAPIForQuote(foOrder);
        
		//TODO add tests (when GC code in GC sandbox)
        // Verify response received contains fake values
        //String contentType = res.getHeader('Content-Type');
        //System.assert(contentType == 'application/json');
        //String actualValue = res.getBody();
        //String expectedValue = '{"example":"test"}';
        //System.assertEquals(actualValue, expectedValue);
        //System.assertEquals(200, res.getStatusCode());
    }
}