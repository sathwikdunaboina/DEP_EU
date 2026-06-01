/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     UpdOppVINOnFactoryOrderVINUpdate_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       26-05-2026 
* @Used By            Update Opportunity VIN On Factory Order VIN Update
* ------------------------------------------------------------------------------------------
* @description        This class is used to test Update Opportunity VIN On Factory Order VIN Update Flow.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class UpdOppVINOnFactoryOrderVINUpdate_Test {
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
    
    @testSetup 
    static void setupmethod(){
        Id iProfileId = [SELECT Id FROM Profile WHERE Name = 'API Only' LIMIT 1][0].Id;
        String sUniqueUserName = 'TestOppAssigment' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tstcs', Email='testOppassignment@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestOppAsgMent', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        System.runAs(oTestUser){
            Account testAccount = new Account();
            testAccount.Name = 'Test Account';
            testAccount.BillingCountry = 'United Kingdom';
            testAccount.CustomerID__c = 'GB-1009401';
            insert testAccount;
            
            Opportunity testOpp = new Opportunity();
            testOpp.Name = 'Test Opportunity';
            testOpp.StageName = 'Need Analysis';
            testOpp.LeadSource = 'Factory Order';
            testOpp.CurrencyIsoCode = 'EUR';
            testOpp.CloseDate = System.today() + 5;
            insert testOpp;
            
            Factory_Order__c testFactoryOrder = new Factory_Order__c();
            testFactoryOrder.Name = 'Test Factory Order';
            testFactoryOrder.Order_Id__c = 'Test Factory Order';
            testFactoryOrder.Account__c = testAccount.Id;
            testFactoryOrder.Dealer_Id__c = 'GB-1009401';
            testFactoryOrder.VIN_Number__c = 'YV2RT60D0RB461503';
            testFactoryOrder.Country__c ='GB';
            testFactoryOrder.Finance_Opportunity__c = testOpp.Id;
            insert testFactoryOrder;
            
            
            
            
        }
    }
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     updateOppVIN
* @description     To cover the flow elements which updates the Opportunity VIN Number Field when Factory Order VIN Number is updated
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void updateOppVIN(){
        Opportunity createdOpportunity = [SELECT Id,VIN_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];
        Factory_Order__c createdFactoryOrder = [SELECT Id,VIN_Number__c FROM Factory_Order__C WHERE Name ='Test Factory Order'];
        createdFactoryOrder.VIN_Number__c = 'YV2RT40A2PA319399';
        Test.StartTest();
        update createdFactoryOrder;
        Test.StopTest();
        Opportunity testCreatedOpportunity = [SELECT Id,VIN_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];
        System.assertEquals('YV2RT40A2PA319399',testCreatedOpportunity.VIN_Number__c);
    }
}