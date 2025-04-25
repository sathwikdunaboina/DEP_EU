/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineTriggerHandler
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-20-2024 
* @Used By            CLA_CreditLineTrigger 
* @Test Covered By    CLA_CreditLineService_Test
* @SystemLayer        Handler
* ------------------------------------------------------------------------------------------
* @description        This class is used for handling business logic for Creditline  Trigger
* ------------------------------------------------------------------------------------------
*/

public with sharing class CLA_CreditLineTriggerHandler {

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     handleBeforeInsert
* @description     Handles before insert event for Creditline Trigger
* ------------------------------------------------------------------------------------------------------
* @param          listCreditLines     Creditline new records list, List<CLA_Credit_Line__c> 
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    
    public static void handleBeforeInsert(List<CLA_Credit_Line__c> listCreditLines){
           
        for(CLA_Credit_Line__c oCreditLine : listCreditLines){
            oCreditLine.CLA_Credit_Line_identification_number__c =  CLA_GuidGenerator.generateGUID();
        }
    }
       
}