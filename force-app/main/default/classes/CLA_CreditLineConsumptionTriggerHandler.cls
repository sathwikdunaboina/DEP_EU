/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineConsumptionTriggerHandler
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-20-2024 
* @Used By            CLA_CreditLineConsumptionTrigger 
* @Test Covered By    CLA_CreditLineConsumptionService_Test
* @SystemLayer        Handler
* ------------------------------------------------------------------------------------------
* @description        This class is used for handling business logic for Creditline Consumption Trigger
* ------------------------------------------------------------------------------------------
*/

public with sharing class CLA_CreditLineConsumptionTriggerHandler {

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     handleBeforeInsert
* @description     Handles before insert event for Creditline Consumption Trigger
* ------------------------------------------------------------------------------------------------------
* @param          listCreditLineConsumptions     Creditline consumption new records list, List<CLA_Credit_Line_Consumption__c> 
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
public static void handleBeforeInsert(List<CLA_Credit_Line_Consumption__c> listCreditLineConsumptions){
           
    for(CLA_Credit_Line_Consumption__c oCreditLineConsumption : listCreditLineConsumptions){
        oCreditLineConsumption.CLA_Consumption_Identification_Number__c =  CLA_GuidGenerator.generateGUID();
    }
}
    
}