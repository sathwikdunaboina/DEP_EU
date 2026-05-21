/*
* Subject: Master Trigger on Contract , Currently supports after insert operation focused on Contract Novation, before insert and before update for Contract VIN Validation
* Created by: Hari Vyas,Sugapriya Vanjiyappan
* Date: 21/01/2025, 18/05/2026
* 
* */
trigger ContractTrigger on Contract__c (before insert,before update,after insert) {
    
    // ── BEFORE INSERT ─────────────────────────────
    if (Trigger.isBefore && Trigger.isInsert) {
        ContractTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    
    // ── BEFORE UPDATE ─────────────────────────────
    if (Trigger.isBefore && Trigger.isUpdate) {
        ContractTriggerHandler.handleBeforeUpdate(Trigger.new,Trigger.oldMap);
    }
    
    // ── AFTER INSERT ──────────────────────────────
    if (Trigger.isAfter && Trigger.isInsert) {
        ContractNovationAfterInsertHandler.handleAfterInsert(Trigger.newMap);
    }
}