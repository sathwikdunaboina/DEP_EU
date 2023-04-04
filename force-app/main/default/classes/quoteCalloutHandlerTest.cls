@isTest
private class quoteCalloutHandlerTest {
    @isTest(SeeAllData=true) static void testCallout() {
        // Set mock callout class 
        System.Test.setMock(HttpCalloutMock.class, new QuoteCalloutMockCallout());
        List<String> foOrder=new List<String>();
        List<String> foOrderres=new List<String>();
        List<Opportunity> opList=new List<Opportunity>();
        opList=[Select Id,Amount ,Factory_Order__c,Account.Name ,Account.BillingCountryCode from Opportunity where Factory_Order__c != null AND Amount != null AND Account.Customer_Number__c !=null limit 1];
        List<String> foIds = new List<String>();
        system.debug('This is opplist'+opList);
        foOrder.add(String.valueOf(opList[0].Id));
        quoteCalloutController.getOpportunities(String.valueOf(opList[0].Id));
        quoteCalloutController.getOppIds(foOrder);
    }
    
    @isTest(SeeAllData=true) static void testCalloutElse() {
        // Set mock callout class 
        System.Test.setMock(HttpCalloutMock.class, new QuoteCalloutMockCallout());
        List<String> foOrder=new List<String>();
        List<String> foOrderres=new List<String>();
        List<Opportunity> opList=new List<Opportunity>();
        opList=[Select Id,Amount ,Factory_Order__c,Account.Name ,Account.BillingCountryCode from Opportunity where Factory_Order__c != null AND Amount != null AND Account.Customer_Number__c =null limit 1];
        List<String> foIds = new List<String>();
        system.debug('This is opplist'+opList);
        foOrder.add(String.valueOf(opList[0].Id));
        quoteCalloutController.getOpportunities(String.valueOf(opList[0].Id));
        quoteCalloutController.getOppIds(foOrder);
    }
    
    @isTest(SeeAllData=true) static void testNullData() {
        List<String> foOrderres=new List<String>();
        List<String> foOrder=new List<String>();
        quoteCalloutController.getOppIds(foOrder);
    }
    @isTest static void testParse() {
        String jsonString = '{"source":"Sales Connect","requestedBy":"a434539","owner":"thc0011","externalId":"0065r000005E1rcAAC","dealer":{"salesPersonName":"Test","mainDealerName":"Test","id":"NL-100756","dealerNumber":"12345"},"customer":{"postalCode":"4153 RD","phone":null,"name":"Volvo Financial Services Beesd","countryCode":"DE","CMS_ID":"567400","city":"Beesd","address":"Stationsweg 2"},"countryCode":"DE","brand":"VT","asset":[{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"},{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"},{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"},{"VINNumber":null,"tChassis":null,"statusDescription":"Confirmed","registrationDate":"2021-04-27 00:00:00","orderNumber":null,"OpportunityId":"0065r000005L8x3AAC","marketType":"FH  42T  3A 01","id":null,"engineVersion":"D13K460","disStatusCode":"ORDERED","currencyCode":"EUR","chassisType":"TRACTOR","cddDate":"2021-12-15 00:00:00","axleArrangement":"4*2","assemblyFactoryName":"Volvo Lastvagnar AB Tuve fabriken","assemblyFactoryCode":"1","amount":"12333"}]}';
        String json = json.serialize(jsonString);
        quoteWrapperClass.wrapperClass quotewrap = new quoteWrapperClass.wrapperClass();
        quoteWrapperClass.asset assetwrap = new quoteWrapperClass.asset();
        quoteWrapperClass.dealer dealer = new quoteWrapperClass.dealer();
        quoteWrapperClass.customer customer = new quoteWrapperClass.customer();
        quoteWrapperClass.order order = new quoteWrapperClass.order();
        quoteWrapperClass.financials financials = new quoteWrapperClass.financials();
        quotewrap.countryCode = 'UK';
        quotewrap.externalId = 'j9w1H9IK8D';
        quotewrap.requestedBy = 'h78adf8uhdauhdcau';
        quotewrap.Source = 'Sales Connect';
        quotewrap.brand = 'VT';
        quotewrap.owner = 'H98Inhujnu89332s';
        assetwrap.assemblyFactoryCode = 'sWASjnu89332s';
        assetwrap.assemblyFactoryName = 'fadsCnu89332s';
        assetwrap.axleArrangement = 'ewgvvnu89332s';
        assetwrap.chassisType = 'H9safes9332s';
        assetwrap.engineVersion = 'H98Inhujnu89332s';
        assetwrap.id = 'as9iej3ish2w';
        assetwrap.marketType = 'ot945htbffc';
        assetwrap.tChassis = '02oikj3nwerfv8uj';
        assetwrap.VINNumber = 'k0j9bu7gfdt3w';
        dealer.dealerNumber = 'ot945htbffc';
        dealer.id = '23wewe4erbffc';
        dealer.mainDealerName = '9ije4erbffc';
        dealer.salesPersonName = '7yhgwe4erbffc';
        customer.address = '23wewe4erbffc';
        customer.city = 'qwsdfgubffc';
        customer.CMS_ID = '56yhgbgvbff';
        customer.countryCode = '09oikjkjc';
        customer.name = 'sdcwerbffc';
        customer.phone = '6tbyhfcr erbffc';
        customer.postalCode = '5rffwe4erbffc';
        quoteWrapperClass.parse(jsonString);
    }
    
}