/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     ContractTriggerHandler
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       18-05-2026
* ------------------------------------------------------------------------------------------
* @description        This Trigger Handler is to find whether a VIN number in any contracts is Valid or NOT with ContractVINValidationService Class
* ------------------------------------------------------------------------------------------
*/
public with sharing class ContractTriggerHandler {
    // BEFORE INSERT
    public static void handleBeforeInsert(List<Contract__c> newContracts) {
       new ContractVINValidationService().validateVIN(newContracts);
    }
    // BEFORE UPDATE
    public static void handleBeforeUpdate(List<Contract__c> newContracts,Map<Id, Contract__c> oldMap) {
        new ContractVINValidationService().validateVIN(newContracts, oldMap);
    }
}