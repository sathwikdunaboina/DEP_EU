/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineStatusExpiredSchedule_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       06-21-2024         
* ------------------------------------------------------------------------------------------
* @description        Test class for CLA_CreditLineStatusExpired_Schedule
* ------------------------------------------------------------------------------------------
*/
@isTest
private class CLA_CreditLineStatusExpiredSchedule_Test {

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
    CLA_TestDataFactory.createCreditLine(true,true);
} 

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testCreditLineStatusExpiredSchedule
* @description     Used to test CLA_CreditLineStatusExpired_Schedule 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/

    @isTest static void testCreditLineStatusExpiredSchedule() {

        System.runAs(new User(Id = UserInfo.getUserId())){
        String sCronExp = '0 0 2 * * ? *';
        Test.startTest();
        
        String jobId = System.schedule('Update CreditLine', sCronExp, new CLA_CreditLineStatusExpired_Schedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sCronExp, ct.CronExpression,'Expected Result');
        System.assertEquals(0, ct.TimesTriggered,'Expected Result');
        
        Test.stopTest();
        }
        
    }
    
}