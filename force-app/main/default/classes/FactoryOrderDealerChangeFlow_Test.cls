/**
* Name of the class    FactoryOrderDealerChangeFlow_Test
* Author               Sugapriya Vanjiyappan
* Create Date  		   26-06-2024
* Used by 			   Trigger Flow - Factory Order Dealer Change
* SystemLayer		   Test class
* Description          When a Factory Order is updated with new Dealer Id, associated opportunity will be updated with new Dealer Id and Account and 
                       notifications will be sent to Old and New Opportunity Owners stating the same
* Classes covered	   N/A
*/

@isTest(SeeAllData=false)
public class FactoryOrderDealerChangeFlow_Test {
    private static String SalesPersonFirstname = 'Tim';
    private static String SalesPersonLastname = 'Hook';
    
    @testSetup static void setupmethod(){
        Id iProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
        Id iRoleId = [SELECT Id,DeveloperName FROM UserRole WHERE DeveloperName = 'IT_Territory_Manager' LIMIT 1][0].Id;
        String sUniqueUserName = 'TestCaseAssigment' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tstcs', Email='testcaseassignment@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestCaseAsgMent', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        
        System.runAs(oTestUser){
            // Add a dealer account
            Id accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Dealer Account').getRecordTypeId();
            Account oDealerAccount = new Account (Name='TestDealerAccount', RecordTypeId = accountRecordType, CustomerID__c='1234', 
                                                  OwnerId=oTestUser.Id, BillingCountry='Italy');
            insert oDealerAccount;
            
            Account oDealerAccountDealerChange = new Account (Name='TestDealerAccountDealerChange', RecordTypeId = accountRecordType, CustomerID__c='5555', 
                                                              OwnerId=oTestUser.Id, BillingCountry='Italy');
            insert oDealerAccountDealerChange;
            
            //Add a Contact
            String cEmail = 'test@contact1.org' + System.currentTimeMillis();
            Contact c = new Contact(FirstName=SalesPersonFirstname,LastName=SalesPersonLastname,Email=cEmail,OwnerId=oTestUser.Id);//, AccountId=dTestAcc.Id);
            insert c;
            
            // Add a customer account
            accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            Account cTestAcc = new Account (Name='TestCustomerAccount', RecordTypeId = accountRecordType, OwnerId=oTestUser.Id, 
                                            BillingCountry='Italy');
            insert cTestAcc;
            
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     opportunityNotQuoted
* @description     To cover Opportunity without Quote Created through Factory Order
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @isTest
    static void opportunityNotQuoted(){
        Account oDealerAccounts = [SELECT Id,CustomerID__c FROM Account WHERE Name = 'TestDealerAccount' LIMIT 1];
        oDealerAccounts.Check_on_dealer_sales_person__c = true;
        update oDealerAccounts;
        Account oDealerAccountChange = [SELECT Id,Name FROM Account WHERE CustomerID__c='5555' LIMIT 1];
        
        Factory_Order__c foWithSalesPerson = new Factory_Order__c(Dealer_Id__c='1234', Account__c=oDealerAccounts.Id, Main_Dealer_Name__c='Test Dealer',
                                                                  End_Customer_Name__c='Test Customer', Order_Id__c='1234',
                                                                  Sales_Person_Name__c=SalesPersonFirstname + ' ' + SalesPersonLastname);
        insert foWithSalesPerson;
        
        // Pause to allow flow to work
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWait = 3000; // vary this depending on your "sleep" needs
        while (finalTime - startTime < millisecondsToWait) {
            finalTime = DateTime.now().getTime();
        }
        Factory_Order__c fo = [SELECT Finance_Opportunity__c, Finance_Opportunity__r.Quote_Id__c,OwnerId FROM Factory_order__c WHERE Id =: foWithSalesPerson.Id LIMIT 1];
        
        Test.startTest();
        fo.Dealer_Id__c = '5555';
        update fo;
        Test.stopTest();
        
        Factory_Order__c facOrder = [SELECT Account__r.Name FROM Factory_Order__c WHERE Id =: fo.Id LIMIT 1];
        Assert.areEqual(facOrder.Account__r.Name, oDealerAccountChange.Name, 'Factory Order Account is same as Updated Dealer Account');
        
    }
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     opportunityQuoted
* @description     To cover Opportunity with Quote Created through Factory Order
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
    @isTest
    static void opportunityQuoted(){
        Account oDealerAccounts = [SELECT Id,CustomerID__c FROM Account WHERE Name = 'TestDealerAccount' LIMIT 1];
        oDealerAccounts.Check_on_dealer_sales_person__c = true;
        update oDealerAccounts;
        Account oDealerAccountChange = [SELECT Id,Name FROM Account WHERE CustomerID__c='5555' LIMIT 1];
        
        Factory_Order__c foWithSalesPerson = new Factory_Order__c(Dealer_Id__c='1234', Account__c=oDealerAccounts.Id, Main_Dealer_Name__c='Test Dealer',
                                                                  End_Customer_Name__c='Test Customer', Order_Id__c='1234',
                                                                  Sales_Person_Name__c=SalesPersonFirstname + ' ' + SalesPersonLastname);
        insert foWithSalesPerson;
        
        // Pause to allow flow to work
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWait = 3000; // vary this depending on your "sleep" needs
        while (finalTime - startTime < millisecondsToWait) {
            finalTime = DateTime.now().getTime();
        }
        Factory_Order__c fo = [SELECT Finance_Opportunity__c, Finance_Opportunity__r.Quote_Id__c,Finance_Opportunity__r.StageName,OwnerId FROM Factory_order__c 
                               WHERE Id =: foWithSalesPerson.Id LIMIT 1];
        
        Opportunity updateOpp = [SELECT id,Quote_Id__c FROM Opportunity WHERE Id=:fo.Finance_Opportunity__c];
        updateOpp.Quote_Id__c = '6666';
        update updateOpp;
        System.debug(fo.Finance_Opportunity__r.Quote_Id__c);
        
        Test.startTest();
        fo.Dealer_Id__c = '5555';
        update fo;
        Test.stopTest();
        
        Factory_Order__c facOrder = [SELECT Account__r.Name FROM Factory_Order__c WHERE Id =: fo.Id LIMIT 1];
        Assert.areEqual(facOrder.Account__r.Name, oDealerAccountChange.Name, 'Factory Order Account is same as Updated Dealer Account');
    }
    
}