public without sharing class EndOfTermController {
    @AuraEnabled
    public static List<Contract__c> getAllContractTimeToTerm() {
        Id accountId = PortalUtility.getAccountId();
        List<Contract__c> contractTimeToTerm=[select id, End_of_Term__c, Name, End_Date__c from Contract__c where Account__c =: accountId order by End_Date__c desc]; // Modified by Sumit. Added accountId filter 21st sept 2019
        return contractTimeToTerm;
    }
}