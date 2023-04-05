@isTest
private class quoteCalloutHandlerTest {
    @isTest static void testCallout() {
        // Set mock callout class 
        System.Test.setMock(HttpCalloutMock.class, new QuoteCalloutMockCallout(200));
        List<String> foOrder=new List<String>();
        Id FoId = insertTestFactoryOrders();
        Id accountId = insertTestAccount();
        Id contactId = insertTestContact(accountId);
        Id opportunityId = insertTestOpp(accountId,FoId); 
        foOrder.add(String.valueOf(opportunityId));
        System.debug('foOrderTest'+foOrder);
        insertCustomSettingValues();
        System.test.startTest();
        quoteCalloutController.getOpportunities(String.valueOf(opportunityId));
        quoteCalloutController.getOppIds(foOrder);
        System.test.stopTest();
    }
    
        @isTest static void elseTestCallout() {
        // Set mock callout class 
        System.Test.setMock(HttpCalloutMock.class, new QuoteCalloutMockCallout(401));
        List<String> foOrder=new List<String>();
        Id FoId = insertTestFactoryOrders();
        Id accountId = insertTestAccount();
        Id contactId = insertTestContact(accountId);
        Id opportunityId = insertTestOpp(accountId,FoId); 
        foOrder.add(String.valueOf(opportunityId));
        System.debug('foOrderTest'+foOrder);
        insertCustomSettingValues();
        System.test.startTest();
        quoteCalloutController.getOpportunities(String.valueOf(opportunityId));
        quoteCalloutController.getOppIds(foOrder);
        System.test.stopTest();
    }
    @isTest static void testCalloutElse() {
        // Set mock callout class 
        System.Test.setMock(HttpCalloutMock.class, new QuoteCalloutMockCallout(200));
        List<String> foOrder=new List<String>();
        Id FoId = insertTestFactoryOrders();
        Id accountId = insertTestAccountWithoutCMS();
        Id contactId = insertTestContact(accountId);
        Id opportunityId = insertTestOppWithoutCMS(accountId,FoId); 
        foOrder.add(String.valueOf(opportunityId));
        insertCustomSettingValues();
        System.test.startTest();
        quoteCalloutController.getOpportunities(String.valueOf(opportunityId));
        quoteCalloutController.getOppIds(foOrder);
        System.test.stopTest();
    }
    
    @isTest static void testNullData() {
        List<String> foOrderres=new List<String>();
        List<String> foOrder=new List<String>();
        insertCustomSettingValues();
        quoteCalloutController.getOppIds(foOrder);
    }
    @isTest static void testParse() {
        String jsonString = '{"source":"Sales Connect","requestedBy":"a434539","owner":"thc0011","externalId":"0065r000005E1rcAAC","dealer":{"salesPersonName":"Test","mainDealerName":"Test","id":"NL-100756","dealerNumber":"12345"},"customer":{"postalCode":"4153 RD","phone":null,"name":"Volvo Financial Services Beesd","countryCode":"DE","CMS_ID":"567400","city":"Beesd","address":"Stationsweg 2"},"countryCode":"DE","brand":"VT","asset":[{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"},{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"},{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"},{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"}]}';
        quoteWrapperClass.parse(jsonString);
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
        act.Customer_Number__c = '035000';
        act.CustomerId__c = 'NL-X035000';
        act.Name = 'Test Account';
        act.BillingCountryCode = 'NL';
        insert act;
        return act.Id;
    }
    
        private static Id insertTestAccountWithoutCMS(){
        Account act = new Account();
        act.CustomerId__c = 'NL-X035000';
        act.Name = 'Test Account';
        act.BillingCountryCode = 'NL';
        insert act;
        return act.Id;
    }
    
    private static Id insertTestContact(Id actId){
        Contact cont = new Contact();
        cont.AccountId = actId;
        cont.Email = 'testConvert@bulk.com';
        cont.LastName = 'Test Contact';
        insert cont;
        return cont.Id;
    }
    
    private static Id insertTestLead(Id FoId){
        Lead ld = new Lead();
        ld.Factory_Order__c = FoId;
        ld.Company = 'Bulk X Transport';
        ld.LastName = 'John2';
        ld.CurrencyIsoCode = 'EUR';
        insert ld;
        return ld.Id;
    }
    
    private static Id insertTestOpp(Id AccountId,Id FoId){
        Opportunity opp = new Opportunity();
        opp.Factory_Order__c = FoId;
        opp.AccountId = AccountId;
        opp.Amount = 12000;
        opp.CloseDate = System.today() + 3;
        opp.CurrencyIsoCode = 'EUR';
        opp.Name = 'John2';
        opp.StageName = 'New';
        insert opp;
        return opp.Id;
    }
    private static Id insertTestOppWithoutCMS(Id AccountId,Id FoId){
        Opportunity opp = new Opportunity();
        opp.Factory_Order__c = FoId;
        opp.AccountId = AccountId;
        opp.Amount = 12000;
        opp.CloseDate = System.today() + 3;
        opp.CurrencyIsoCode = 'EUR';
        opp.Name = 'John2';
        opp.StageName = 'New';
        insert opp;
        return opp.Id;
    }
    
    private static void insertCustomSettingValues(){
        CMSAPI1__c settings = CMSAPI1__c.getOrgDefaults();
        settings.Endpoint_QA__c = '/vfsconnect/quotation/v1.1/draft';
        settings.X_Ibm_Client_Id__c = '0987654321';
        settings.X_Ibm_Client_Secret__c = '09oi87uy6t';
        insert settings;
    }
}