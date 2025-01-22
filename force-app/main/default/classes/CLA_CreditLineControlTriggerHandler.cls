/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineControlTriggerHandler
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-20-2024 
* @Used By            CLA_CreditLineControlTrigger 
* @Test Covered By     CLA_CreditLineControlsService_Test
* @SystemLayer        Handler
* ------------------------------------------------------------------------------------------
* @description        This class is used for handling business logic for Creditline Control Trigger
* ------------------------------------------------------------------------------------------
*/

public with sharing class CLA_CreditLineControlTriggerHandler {

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     handleBeforeInsert
* @description     Handles before insert event for Creditline Control Trigger
* ------------------------------------------------------------------------------------------------------
* @param          listCreditLineControls     Creditline control new records list, List<CLA_Credit_Line_Control__c> 
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    public static void handleBeforeInsert(List<CLA_Credit_Line_Control__c> listCreditLineControls){
           
        for(CLA_Credit_Line_Control__c oCreditLineControl : listCreditLineControls){
            oCreditLineControl.CLA_CreditLineControlIdentificationNumbe__c =  CLA_GuidGenerator.generateGUID();
        }
    }
    
}