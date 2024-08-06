@isTest
public with sharing class CMSAPI_InvoiceHandlerTest {

@TestSetup
static void makeData(){
    //Create customer account.
    Account acc = new Account();
    acc.BillingCountryCode = 'IE';
    acc.CustomerId__c = 'IE-Z0000000000000000000000514448687';
    acc.Name = 'Test Irish Customer';
    insert acc;
}

@IsTest
static void fetchInvoicesFromAPITest(){

    Account acc = [SELECT Id FROM Account WHERE CustomerId__c = 'IE-Z0000000000000000000000514448687' limit 1];
    Test.setMock(System.HttpCalloutMock.class, new CMSAPI_CalloutMock());
    Test.startTest();
    CMSAPI_InvoiceHandler.fetchInvoicesFromAPI(new List<Id> {acc.Id});    
    Test.stopTest();
    List<Invoice__c> invoices = [SELECT Id from Invoice__c Where Account__c =: acc.Id];
    system.assert(invoices!= null && !invoices.isEmpty()); //invoice call success. found invoices.
    
}

}