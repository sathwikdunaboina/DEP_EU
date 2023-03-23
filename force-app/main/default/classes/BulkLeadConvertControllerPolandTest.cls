@IsTest
public with sharing class BulkLeadConvertControllerPolandTest {
    
    @IsTest
    static void testLeadConvert_happy(){ 
        Test.startTest();
        insertTestFactoryOrders();
        Test.stopTest();
        //Assert
        List<Id> allLeads = new List<Id>(
            new Map<Id, Lead> ([SELECT Id FROM Lead WHERE DealerName__c = 'Bulk X Transport']).keySet()
        );
        Boolean success = BulkLeadConvertControllerPoland.convert(allLeads, null, null);            
        system.assert(success);
    }
    
    @IsTest
    static void testLeadConvert_ExistingAccount(){
        Test.startTest();
        insertTestFactoryOrders();
        Id accountId = insertTestAccount();
        Id contactId = insertTestContact(accountId);
        Test.stopTest();
        //Assert
        List<Id> allLeads = new List<Id>(
            new Map<Id, Lead> ([SELECT Id FROM Lead WHERE DealerName__c = 'Bulk X Transport']).keySet()
        );
        List<Lead> leadList = BulkLeadConvertControllerPoland.getLeadList(allLeads);
        Boolean success = BulkLeadConvertControllerPoland.convert(allLeads, accountId, contactId);
        system.assert(success);
    }
    
    
    @IsTest
    static void testLeadConvert_noLeads(){
        try{
            Boolean success = BulkLeadConvertControllerPoland.convert(null, null, null);   
            system.assert(false);
        }catch(Exception exp){
            system.assert(true);
        }
    }
    
    private static void insertTestFactoryOrders(){
        //Insert Factory Orders. This will create Leads
        FactoryOrder__c fo1 = new FactoryOrder__c (
            Brand__c = 'RT',
            ContactLastName__c = 'John',
            Country__c = 'PL',
            DealerId__c = 'PL-0987654321',
            EndCustomerAddress__c = 'My Street',
            EndCustomerName__c = 'DHL',
            EndCustomerPhone__c = '12345',
            EndCustomerCity__c = 'Utrecht',
            Name = '09876543',
            MainDealerName__c = 'Bulk X Transport',
            OwnerId = UserInfo.getUserId()
        );
        //Insert Factory Orders. This will create Leads
        FactoryOrder__c fo2 = new FactoryOrder__c (
            Brand__c = 'VT',
            ContactLastName__c = 'John2',
            Country__c = 'PL',
            DealerId__c = 'PL-09876543212',
            DealerNumber__c = '09876543212',
            EndCustomerAddress__c = 'My Street',
            EndCustomerName__c = 'DHL',
            EndCustomerPhone__c = '12345',
            EndCustomerCity__c = 'Utrecht',
            Name = '098765432',
            MainDealerName__c = 'Bulk X Transport',
            OwnerId = UserInfo.getUserId()
        );
        insert new List<FactoryOrder__c> {fo1, fo2};
            }
    
    private static Id insertTestAccount(){
        Account act = new Account();
        act.CustomerNumberCMSID__c = '035000';
        act.GCCustomerID__c = 'PL-X035000';
        act.Name = 'Test Account';
        act.BillingCountryCode = 'PL';
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
    
}