/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     UpdateNetSalesPriceOnOpportunity_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       18-12-2024 
* @Used By            Update Net Sales Price(Amount) Field on Opportunity Whenever an Opportunity is created or updated and the values of the fields
                      Number of Assets and Average Value Per Asset are changed
* ------------------------------------------------------------------------------------------
* @description        This class is used to test Update Net Sales Price Field On Opportunity Create/Update Flow.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class UpdNetSalesPriceFieldOnOpp_Test {
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
        String sUniqueUserName = 'TestCaseAssigment' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tstcs', Email='testcaseassignment@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestCaseAsgMent', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        System.runAs(oTestUser){
            Opportunity testOpp = new Opportunity();
            testOpp.Name = 'Test Opportunity';
            testOpp.StageName = 'Need Analysis';
            testOpp.LeadSource = 'Dealer-Stockbook';
            testOpp.CurrencyIsoCode = 'EUR';
            testOpp.CloseDate = System.today() + 5;
            testOpp.Number_of_Assets__c = 10;
            testOpp.Average_Value_Per_Asset__c = 10;
            insert testOpp;
        }
    }
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     updateNetSalesValueOnFieldChange
* @description     To cover the flow elements which changes the Net Sales Price field value on Opportunity based on Number Of Assets and Average Value 
                   Per Asset field values when an opportunity is created or Updated
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void updateNetSalesValueOnFieldChange(){
        Opportunity createdOpportunity = [SELECT Id,Number_of_Assets__c,Average_Value_Per_Asset__c FROM Opportunity WHERE Name = 'Test Opportunity'];
        createdOpportunity.Number_of_Assets__c = 20;
        Test.StartTest();
        update createdOpportunity;
        Test.StopTest();
        Opportunity testCreatedOpportunity = [SELECT Id,Amount,Number_of_Assets__c,Average_Value_Per_Asset__c FROM Opportunity WHERE Name = 'Test Opportunity'];
        System.assertEquals(testCreatedOpportunity.Number_of_Assets__c*testCreatedOpportunity.Average_Value_Per_Asset__c,testCreatedOpportunity.Amount);
    }
}