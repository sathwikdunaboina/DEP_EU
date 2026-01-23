/*
* Subject: Master Trigger on Contract , Currently supports after insert operation focused on Contract Novation
* Created by: Hari Vyas
* Date: 21/01/2025, 
* 
* */   
trigger ContractTrigger on Contract__c (after insert) {
    ContractNovationAfterInsertHandler.handleAfterInsert(Trigger.newMap);
}