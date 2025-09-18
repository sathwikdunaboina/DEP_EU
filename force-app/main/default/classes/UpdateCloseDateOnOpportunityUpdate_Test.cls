/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     UpdateCloseDateOnOpportunityUpdate_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       3-9-2025 
* @Used By            Update Close Date On Opportunity Update Flow
* ------------------------------------------------------------------------------------------
* @description        This class is used to test Update Close Date On Opportunity Update Flow.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class UpdateCloseDateOnOpportunityUpdate_Test {
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
        String sUniqueUserName = 'Test' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tsts', Email='test@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestOpp', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        System.runAs(oTestUser){
            //Create an Opportunity
            Opportunity otestOpportunity = new Opportunity();
            otestOpportunity.Name = 'Test Opportunity';
            otestOpportunity.StageName = 'Needs Analysis';
            insert otestOpportunity;
        }
    }
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     updateCloseDateOnOpportunity
* @description     To cover the flow element which Updates the Close Date On Opportunity
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void updateCloseDateOnOpportunity(){
        Opportunity otestOpp = [SELECT Id,Name,CloseDate FROM Opportunity WHERE Name='Test Opportunity'];
        otestOpp.StageName = 'Closed Won';
        Test.StartTest();
        update otestOpp;
        Test.StopTest();
        System.assertEquals(Date.Today(),otestOpp.CloseDate);
    }
}