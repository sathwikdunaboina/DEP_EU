/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineStatusExpired_Schedule
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       06-20-2024 
* @Used By        
* @Test Covered By    CLA_CreditLineStatusExpiredSchedule_Test     
* ------------------------------------------------------------------------------------------
* @description        This class is used to schedule CLA_CreditLineStatusExpired_Batch.
* ------------------------------------------------------------------------------------------
*/
public without sharing class CLA_CreditLineStatusExpired_Schedule implements Schedulable  {

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     execute
* @description     Used to schedule batch class
* ------------------------------------------------------------------------------------------------------
* @param          schedulabeContext          Database.schedulabeContext
* @return         
* ------------------------------------------------------------------------------------------------------ 
*/
    public void execute(SchedulableContext schedulabeContext) {
       Database.executeBatch(new CLA_CreditLineStatusExpired_Batch(), 100);
    }
}