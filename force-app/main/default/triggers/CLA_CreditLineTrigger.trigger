/*
* -----------------------------------------------------------------------------------------
* Apex Trigger Name     CLA_CreditLineTrigger
* @author               Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date         06-05-2024  
* @Test Covered By      CLA_CreditLineService_Test       
* ------------------------------------------------------------------------------------------
*/

trigger CLA_CreditLineTrigger on CLA_Credit_Line__c (before insert) {
     CLA_CreditLineTriggerHandler.handleBeforeInsert(trigger.new);
}