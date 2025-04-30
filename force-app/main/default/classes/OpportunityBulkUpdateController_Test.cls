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
            List<Opportunity> listOpportunity = new List<Opportunity>();
            for(integer i = 0 ; i <= 20 ; i++){
                Opportunity opp = new Opportunity();
                opp.Name = 'test opportunity'+ i ;
                opp.StageName = 'Need Analysis';
                listOpportunity.add(opp);
            }
            insert listOpportunity;
            
            Account testCustomerAccount = new Account();
            testCustomerAccount.Name = 'TestAccount';
            testCustomerAccount.BillingCountry = 'United Kingdom';
            insert testCustomerAccount;
            
        }
    } 
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testAccountMessagingUserController
* @description     This method is used to test AccountMessagingUserController class
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
    @isTest
    public static void testOpportunityBulkUpdateController(){
        List<Opportunity> listOpportunities = [Select Id , Name FROM Opportunity];
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
        OpportunityBulkUpdateController.updateOpportunities(listOpportunities);
        Test.stopTest();
    }
}