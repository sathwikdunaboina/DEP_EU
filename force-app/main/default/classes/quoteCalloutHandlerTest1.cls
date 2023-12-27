@isTest
public class quoteCalloutHandlerTest1 {
	@testSetup
    static void setup() {
        Id foId = insertTestFactoryOrders();
        Id accountId = insertTestAccount();
        Id opportunityId = insertTestOpp(accountId,FoId);
        insertCustomSettingValues();
    }
    
    @isTest
    static void fetchFromAPIForQuote_Success() {
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<String> oppIdList = new List<String>();
        for (Opportunity opp : oppList) {
            oppIdList.add(opp.Id);
        }
        
		System.test.startTest();
        System.test.setMock(HttpCalloutMock.class, new QuoteCalloutMockCallout(200, '{"example":"test","quoteId":"122334","success":"true"}'));
        List<string> results = quoteCalloutHandler.fetchFromAPIForQuote(oppIdList);
        quoteCalloutController.getOpportunities(oppIdList[0]);
        quoteCalloutController.getOppIds(oppIdList);
        System.debug(results);
        for (String result : results) {
            Assert.areEqual(result, 'Quote created successfully');
        }
        System.test.stopTest();
    }
    
    @isTest
    static void fetchFromAPIForQuote_SuccessWithErrorMessage() {
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<String> oppIdList = new List<String>();
        for (Opportunity opp : oppList) {
            oppIdList.add(opp.Id);
        }
        
		System.test.startTest();
        System.test.setMock(HttpCalloutMock.class, new QuoteCalloutMockCallout(200, '{"example":"test","quoteId":"122334","success":"true","errorMessage":"Customer Account Null"}'));
        List<string> results = quoteCalloutHandler.fetchFromAPIForQuote(oppIdList);
        System.debug(results);
        for (String result : results) {
            Assert.areEqual(result, 'Error: Customer Account Null');
        }
        System.test.stopTest();
    }
    
    @isTest
    static void FIXFORMATTING_fetchFromAPIForQuote_ServerError() {
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<String> oppIdList = new List<String>();
        for (Opportunity opp : oppList) {
            oppIdList.add(opp.Id);
        }
        
		System.test.startTest();
        System.test.setMock(HttpCalloutMock.class, new QuoteCalloutMockCallout(404, '{"example":"test","quoteId":"122334","success":"false","errorMessage":"Server issue", "message":"Something went wrong on the server"}'));
        List<string> results = quoteCalloutHandler.fetchFromAPIForQuote(oppIdList);
        System.debug(results);
        for (String result : results) {
            Assert.areEqual(result, 'Error: Server issueSomething went wrong on the server');
        }
        System.test.stopTest();
    }
    
    @isTest
    static void FIXFORMATTING_fetchFromAPIForQuote_ServerErrorWitMissingAttribute() {
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<String> oppIdList = new List<String>();
        for (Opportunity opp : oppList) {
            oppIdList.add(opp.Id);
        }
        
		System.test.startTest();
        System.test.setMock(HttpCalloutMock.class, new QuoteCalloutMockCallout(404, '{"example":"test","quoteId":"122334","success":"false", "message":"Something went wrong on the server"}'));
        List<string> results = quoteCalloutHandler.fetchFromAPIForQuote(oppIdList);
        System.debug(results);
        for (String result : results) {
            Assert.areEqual(result, 'Error: nullSomething went wrong on the server');
        }
        System.test.stopTest();
    }
    
    @isTest
    static void FIXFORMATTING_fetchFromAPIForQuote_ServerErrorWithError() {
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<String> oppIdList = new List<String>();
        for (Opportunity opp : oppList) {
            oppIdList.add(opp.Id);
        }
        
		System.test.startTest();
        System.test.setMock(HttpCalloutMock.class, new QuoteCalloutMockCallout(404, '{"example":"test","quoteId":"122334","success":"false","errorMessage":"Error on server", "message":"Something went wrong on the server"}'));
        List<string> results = quoteCalloutHandler.fetchFromAPIForQuote(oppIdList);
        System.debug(results);
        for (String result : results) {
            Assert.areEqual(result, 'Error on serverSomething went wrong on the server');
        }
        System.test.stopTest();
    }
    
    @isTest
    static void fetchFromAPIForQuote_ErrorBadMessage() {
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<String> oppIdList = new List<String>();
        for (Opportunity opp : oppList) {
            oppIdList.add(opp.Id);
        }
        
		System.test.startTest();
        System.test.setMock(HttpCalloutMock.class, new QuoteCalloutMockCallout(404, 'qqqqqqqqqqqqqqqqqqqqq'));
        List<string> results = quoteCalloutHandler.fetchFromAPIForQuote(oppIdList);
        System.debug(results);
        for (String result : results) {
            Assert.areEqual(result, 'Cannot pass the security checks that are required by the target API or operation. Please try again later!');
        }
        System.test.stopTest();
    }
    
    private static Id insertTestFactoryOrders(){
        //Insert Factory Orders. This will create Leads
        Factory_Order__c fo1 = new Factory_Order__c (
            Brand__c = 'VT',
            Contact_Last_Name__c = 'John',
            Country__c = 'NL',
            Dealer_Id__c = 'NL-X035000',
            End_Customer_Address1__c = 'My Street',
            End_Customer_Name__c = 'DHL',
            End_Customer_Phone__c = '12345',
            End_Customer_City__c = 'Utrecht',
            Name = '09876543',
            Main_Dealer_Name__c = 'Bulk X Transport'
        );
        //Insert Factory Orders. This will create Leads
        Factory_Order__c fo2 = new Factory_Order__c (
            Brand__c = 'VT',
            Contact_Last_Name__c = 'John2',
            Country__c = 'NL',
            Dealer_Id__c = 'NL-X035000',
            Dealer_Number__c = '09876543212',
            End_Customer_Address1__c = 'My Street',
            End_Customer_Name__c = 'DHL',
            End_Customer_Phone__c = '12345',
            End_Customer_City__c = 'Utrecht',
            Name = '098765432',
            Main_Dealer_Name__c = 'Bulk X Transport'
        );
        insert new List<Factory_Order__c> {fo1, fo2};
            return fo1.Id;
    }
    
    private static Id insertTestAccount(){
        Account act = new Account();
        act.Customer_Number__c = '0635000';
        act.CustomerId__c = 'NL-X035000';
        act.Name = 'Test Account';
        act.BillingCountryCode = 'NL';
        insert act;
        return act.Id;
    }
      
    private static Id insertTestOpp(Id AccountId,Id FoId){
        Opportunity opp = new Opportunity();
        opp.Factory_Order__c = FoId;
        opp.AccountId = AccountId;
        opp.Amount = 12000;
        opp.CloseDate = System.today() + 3;
        opp.CurrencyIsoCode = 'EUR';
        opp.Name = 'John2';
        opp.Customer_Account__c = AccountId;
        opp.StageName = 'New';
        opp.Quote_Id__c = '3110472';
        opp.Quote_Url__c = 'https://test-wlc.global.volvo.net/PM/Landingpage.aspx';
        insert opp;
        return opp.Id;
    }
    
    private static void insertCustomSettingValues() {
        CMSAPI1__c settings = CMSAPI1__c.getOrgDefaults();
        settings.Endpoint_QA__c = '/vfsconnect/quotation/v1.2/draft';
        settings.X_Ibm_Client_Id__c = '0987654321';
        settings.X_Ibm_Client_Secret__c = '09oi87uy6t';
        insert settings;
    }
    
    @isTest static void testParse() {
        String jsonString = '{"source":"Sales Connect","requestedBy":"a434539","owner":"thc0011","externalId":"0065r000005E1rcAAC","dealer":{"salesPersonName":"Test","mainDealerName":"Test","id":"NL-100756","dealerNumber":"12345"},"customer":{"postalCode":"4153 RD","phone":null,"name":"Volvo Financial Services Beesd","countryCode":"DE","CMS_ID":"567400","city":"Beesd","address":"Stationsweg 2"},"countryCode":"DE","brand":"VT","asset":[{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"},{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"},{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"},{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"}]}';
        quoteWrapperClass.parse(jsonString);
    }
}