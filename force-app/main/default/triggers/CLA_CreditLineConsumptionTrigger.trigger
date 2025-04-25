/*
* -----------------------------------------------------------------------------------------
* Apex Trigger Name     CLA_CreditLineConsumptionTrigger
* @author               Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date         06-05-2024   
* @Test Covered By      CLA_CreditLineConsumptionService_Test             
* ------------------------------------------------------------------------------------------
*/
trigger CLA_CreditLineConsumptionTrigger on CLA_Credit_Line_Consumption__c (before insert) {
      CLA_CreditLineConsumptionTriggerHandler.handleBeforeInsert(trigger.new);
}