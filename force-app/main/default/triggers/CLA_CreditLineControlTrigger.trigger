/*
* -----------------------------------------------------------------------------------------
* Apex Trigger Name     CLA_CreditLineControlTrigger
* @author               Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date         06-05-2024    
* @Test Covered By      CLA_CreditLineControlsService_Test       
* ------------------------------------------------------------------------------------------
*/

trigger CLA_CreditLineControlTrigger on CLA_Credit_Line_Control__c (before insert) {
    CLA_CreditLineControlTriggerHandler.handleBeforeInsert(trigger.new);
}