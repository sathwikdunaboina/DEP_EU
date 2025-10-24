/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     UpdateOppStage_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       15-10-2025 
* @Used By            Update Opp Stage Flow
* ------------------------------------------------------------------------------------------
* @description        This class is used to test Update Opp Stage Flow.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class UpdateOppStage_Test {
    
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
        Id iProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales' LIMIT 1][0].Id;
        String sUniqueUserName = 'TestOppUpdate' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tstopp', Email='testoppupdate@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestOppsUpdate', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = 'United Kingdom',UserName=sUniqueUserName);
        insert oTestUser;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='Custom_notification_permission'];
        insert new PermissionSetAssignment(AssigneeId = oTestUser.Id,
                                           PermissionSetId = ps.Id);
        
        CustomNotificationType notifyType = [SELECT Id,CustomNotifTypeName FROM CustomNotificationType WHERE DeveloperName ='Opportunity_Notification'];
        oTestUser.Enable_Bell_Notification__c = notifyType.CustomNotifTypeName;
        update oTestUser;
        
        System.runAs(oTestUser){
            Id accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Dealer Account').getRecordTypeId();
            Account testAccount = new Account();
            testAccount.Name = 'Test Dealer';
            testAccount.RecordTypeId = accountRecordType;
            testAccount.CurrencyISOCode = 'GBP';
            testAccount.BillingCountry = 'United Kingdom';
            testAccount.CustomerID__c = 'GB-5467';
            insert testAccount;
            
            Factory_Order__c testFactoryOrder = new Factory_Order__C();
            testFactoryOrder.Name ='Test Finance Factory Order';
            testFactoryOrder.Country__c = 'UK';
            testFactoryOrder.Dealer_Id__c = 'GB-5467';
            Insert testFactoryOrder;
            
            Opportunity testOpportunity = new Opportunity();
            testOpportunity.Name = 'Test Finance Opportunity';
            testOpportunity.StageName = 'Needs Analysis';
            testOpportunity.Factory_Order__c = testFactoryOrder.Id;
            insert testOpportunity;
        } 
    }
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     updateFactoryOrder
* @description     To cover the flow elements which Updates Factory Order Status to Cancelled
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void updateFactoryOrder(){
        Factory_Order__c createdFactoryorder = [SELECT Id FROM Factory_Order__c WHERE Name='Test Finance Factory Order'];
        createdFactoryOrder.Order_Status_Description__c ='Cancelled';
        Test.StartTest();
        update createdFactoryOrder;
        Test.StopTest();
    }
    
}