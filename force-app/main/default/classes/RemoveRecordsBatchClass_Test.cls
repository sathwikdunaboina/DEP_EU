/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     RemoveRecordsBatchClass_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       25-11-2025 
* @Used By            RemoveRecordsBatchClass
* ------------------------------------------------------------------------------------------
* @description        This class is used to test RemoveRecordsBatchClass.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class RemoveRecordsBatchClass_Test {
    
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
                                  EmailEncodingKey='UTF-8', LastName='TestLastName', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        System.runAs(oTestUser){
            //Create Error Logs
            List<Error_Log__c> logsCreatedBefore30DaysFromToday = new List<Error_Log__c>();
            for(Integer i=0; i<5;i++){
                logsCreatedBefore30DaysFromToday.add(new Error_Log__c(
                    Type__c ='info',
                    CreatedDate = System.today().addDays(-40)
                ));
            }
            insert logsCreatedBefore30DaysFromToday;
            
            List<Error_Log__c> logsCreatedBetween30DaysFromToday = new List<Error_Log__c>();
            for(Integer i=0; i<5;i++){
                logsCreatedBetween30DaysFromToday.add(new Error_Log__c(
                    Type__c ='info',
                    CreatedDate = System.today().addDays(-5)
                ));
            }
            insert logsCreatedBetween30DaysFromToday;
        }
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     delete30DaysOldInfoErrorLogs
* @description     To cover the delete30DaysOldInfoErrorLogsBatch Class
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void delete30DaysOldInfoErrorLogs(){
        List<Error_Log__c> retrieveCreatedErrorLogs = [SELECT Id FROM Error_Log__c];
        Test.StartTest();
        Database.executeBatch(new RemoveRecordsBatchClass(), 200);
        Test.StopTest();
        Integer remainingErrorLogsAfterDeletion = [SELECT COUNT() FROM Error_Log__c];
        System.assertEquals(5, remainingErrorLogsAfterDeletion);
    }
    
}