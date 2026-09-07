/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     OpportunityBulkUpdateController_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com> 
* @Created Date       01-20-2025        
* ------------------------------------------------------------------------------------------
* @description        This class is used to test OpportunityBulkUpdateController
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class OpportunityBulkUpdateController_Test {
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/   
    @testSetup static void setUpData() {
        Id iProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales' LIMIT 1][0].Id;
        String sUniqueUserName = 'TestOpportunityAssigment' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tstcs', Email='testOpportunity@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestOpportunityAsgMent', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        
        System.runAs(new User(Id = UserInfo.getUserId())){ 
            Account testCustomerAccount = new Account();
            testCustomerAccount.Name = 'TestAccount';
            testCustomerAccount.BillingCountry = 'United Kingdom';
            testCustomerAccount.CustomerID__c = 'GB-12345';
            insert testCustomerAccount;
            
            Factory_Order__c TestFactoryOrder = new Factory_Order__c();
            TestFactoryOrder.Name = 'Test Order';
            TestFactoryOrder.Order_Id__c = 'Test Factory Order';
            insert TestFactoryOrder;
            
            VFS_Connect_Quote__c Quote = new VFS_Connect_Quote__c();
            Quote.Quote_Number__c = '99967';
            Quote.Name = '99967';
            Quote.Account_CMS_Number__c = '12345';
            insert Quote;
            
            List<Opportunity> listOpportunity = new List<Opportunity>();
            for(integer i = 0 ; i <= 20 ; i++){
                Opportunity opp = new Opportunity();
                opp.Name = 'test opportunity'+ i ;
                opp.StageName = 'Need Analysis';
                opp.Amount = 34567;
                opp.Customer_Account__c = testCustomerAccount.Id;
                opp.Factory_Order__c = TestFactoryOrder.Id;
                listOpportunity.add(opp);
            }
            insert listOpportunity;
            
            /*Account testCustomerAccount = new Account();
            testCustomerAccount.Name = 'TestAccount';
            testCustomerAccount.BillingCountry = 'United Kingdom';
            insert testCustomerAccount;*/
            
        }
    } 
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testOpportunityBulkUpdateController
* @description     This method is used to test OpportunityBulkUpdateController class
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
    @isTest
    public static void testOpportunityBulkUpdateController(){
        List<Opportunity> listOpportunities = [Select Id,Name,StageName,Quote_Id__c,Customer_Account__c,Factory_Order__r.Name,Amount FROM Opportunity];
        List<Opportunity> emptyListToUpdate = new List<Opportunity>();
        String sSelectedOpportunityIds ;
        for(Opportunity opp : listOpportunities){
            sSelectedOpportunityIds = opp.Id + '-';
            
        } 
        User oUser = [Select Id,LastName FROM user WHERE LastName='TestOpportunityAsgMent'];
        Account otestAccount = [SELECT Id,Name FROM Account WHERE Name='TestAccount'];
        Opportunity otestOpportunity = new Opportunity();
        otestOpportunity.StageName = 'Need Analysis';
        otestOpportunity.Name = 'Test Opportunity';
        insert otestOpportunity;
        otestOpportunity.Name = null;
        List <Opportunity> testOpportunities = new List<Opportunity>{otestOpportunity};
            Test.startTest();
        OpportunityBulkUpdateController.getOpportunities(sSelectedOpportunityIds);
        try{
            OpportunityBulkUpdateController.getOpportunities(null);
        }
        catch(Exception e){
        }
        try{
            OpportunityBulkUpdateController.updateOpportunities(null);
            OpportunityBulkUpdateController.updateOpportunities(testOpportunities);
            
        }
        catch(Exception e){
        }
        OpportunityBulkUpdateController.searchOpportunityOwners(oUser.LastName);
        OpportunityBulkUpdateController.searchCustomerAccounts(otestAccount.Name);
        try{
            OpportunityBulkUpdateController.updateOpportunities(listOpportunities);
        }
        catch(Exception e){
        }
        
        Test.stopTest();
    }
    
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     OpportunityBulkUpdateControllerTest
* @description     This method is used to test the method to get Opportunity Stage
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
    
   @isTest
    public static void OpportunityBulkUpdateControllerTest(){
        Test.startTest();
        Map<String,Integer> result = OpportunityBulkUpdateController.getStageProbabilities();
        Test.stopTest();
}
    
    
    
  /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testQuoteUpdateSuccess
* @description     This method is used to test the method to update Quote
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @isTest
public static void testQuoteUpdateSuccess() {
Opportunity opp = [SELECT Id,Name,StageName FROM Opportunity LIMIT 1];

    VFS_Connect_Quote__c quote = [SELECT Id FROM VFS_Connect_Quote__c LIMIT 1];

    Opportunity oppToUpdate = new Opportunity(
        Id = opp.Id,
        VFS_Connect_Quote_Ref__c = quote.Id
    );
    Test.startTest();
    OpportunityBulkUpdateController.updateOpportunities(
        new List<Opportunity>{ oppToUpdate }
    );
    Test.stopTest();
    Opportunity updatedOpp = [SELECT Quote_Id__c,Quote_Url__c,StageName FROM Opportunity WHERE Id = :opp.Id];

    System.assertNotEquals(null, updatedOpp.Quote_Id__c);
    System.assertNotEquals(null, updatedOpp.Quote_Url__c);
}
}