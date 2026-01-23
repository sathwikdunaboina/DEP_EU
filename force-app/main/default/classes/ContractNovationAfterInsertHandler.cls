/*
* Subject: Helper class for Contract Trigger 
* Created by: Hari Vyas
* Date: 21/01/2025, 
*
 * @description
 *  Helper class to handle Contract__c novation scenarios and prevent duplicate contract records.
 *  When a novated contract is inserted (where Contract_Id__c changes), this handler:
 *   1) Re-queries inserted contracts to reliably read the formula key (Country_Code_CMSID__c),
 *   2) Finds the most recently modified existing (“old”) contract that matches the same key,
 *   3) Updates that old contract with the latest values from the newly inserted contract, and
 *   4) Deletes the newly inserted duplicate contract so only one contract remains in Salesforce.
 *
 * @matching
 *  - Matching is done using Country_Code_CMSID__c (formula derived from Contract_Id__c).
 *  - If multiple old contracts match the same key, the handler selects the one with the latest LastModifiedDate.
 *
 * @notes
 *  - Uses a static recursion guard to prevent re-entry within the same transaction.
 *  - Uses Database.update/delete with allOrNone=false to avoid failing the entire chunk due to one bad record.
 */


public with sharing class ContractNovationAfterInsertHandler {
    private static Boolean isRunning = false;

        public static void handleAfterInsert(Map<Id,Contract__c> newContractsById) {

        if (isRunning) return;
        isRunning = true;
        try {            
            
            Set<Id> newContractIds = newContractsById.keySet();
            
            if (newContractIds.isEmpty()) return;

            // 2) Re-query inserted records to reliably read formula field
            List<Contract__c> newContractsCreated = [
                SELECT Id, Name ,Contract_Id__c, Country_Code_CMSID__c,
                       Account__c, Amount_Including_Tax__c, Down_Payment__c,
                       Salesprice_incl_TAX_minus_down_payment__c, Financed_Amount__c,
                       Start_Date__c, End_Date__c, On_Balance_Sheet__c, Regulated__c,
                       Business_Area__c, Asset_Contract_Start_Usage_Amount__c,
                       Asset_Usage_Allowance_Type__c, Asset_Usage_Allowance__c,
                       Territory_Manager_Name__c, Asset_Usage_Amount_Unit_Of_Measure__c,
                       Contract_Territory_Manager_Code__c, DealerId__c, Dealer_City__c,
                       Contract_Number__c, Type__c, VIN_Number__c, Chassis_Number__c,
                       Vehicle_Registration_Number__c, Contract_Status__c, Term__c,
                       Residual__c, Balloon__c, TerminationDate__c, End_of_Term__c
                FROM Contract__c 
                WHERE Id IN:newContractIds
            ];

            // 3) Build key set + key lookup
            Map<String,Id> newContractIdByKey = new Map<String,Id>();
            //Set<String> keys = new Set<String>();

            for (Contract__c newContract : newContractsCreated) {
                if (String.isBlank(newContract.Country_Code_CMSID__c)) continue;
                //String key = newContract.Country_Code_CMSID__c.trim();
                newContractIdByKey.put(newContract.Country_Code_CMSID__c.trim(),newContract.Id);
                //keys.add(key);//Use KeysByNewId.values insted of keys 
            }
            //if (keys.isEmpty()) return;
            if(newContractIdByKey.KeySet().isEmpty()) return;

            // 4) Query "old" duplicate contracts ONLY (exclude newly inserted)
            List<Contract__c> oldSimilarContracts = [
                SELECT Id, Country_Code_CMSID__c
                FROM Contract__c
                //WHERE Country_Code_CMSID__c IN :keys
                WHERE Country_Code_CMSID__c IN :newContractIdByKey.KeySet()
                AND Id NOT IN :newContractIds ORDER BY LastModifiedDate desc
                // FOR UPDATE
            ];

            // 5) Map key -> old contract Id(s)
            Map<String,Id> oldSimilarContractIdByKey = new Map<String,Id>();
            for (Contract__c c : oldSimilarContracts) {
                if (String.isBlank(c.Country_Code_CMSID__c)) continue;
                String key = c.Country_Code_CMSID__c.trim();
                if (!oldSimilarContractIdByKey.containsKey(key)) oldSimilarContractIdByKey.put(key,c.Id);
            }

            // 6) Build updates (old) and deletes (new duplicates)
            List<Contract__c> oldContractsToUpdate = new List<Contract__c>();
            List<Id> newContractIdsToDelete = new List<Id>();

            for (String oldContractKey : oldSimilarContractIdByKey.KeySet()) {

                //get OldContract for Update
                //Contract__c oldContractForUpdate = newContractsById.get(newContractIdByKey.get(oldContractKey));
                Contract__c newContractVersion = newContractsById.get(newContractIdByKey.get(oldContractKey));
                Contract__c oldContract = new Contract__c(Id = oldSimilarContractIdByKey.get(oldContractKey));
                copyFields(newContractVersion,oldContract);
                oldContractsToUpdate.add(oldContract);
                //add 
                newContractIdsToDelete.add(newContractVersion.Id);                
            }
            
            // 7) DML (update first, then delete duplicates)     
                        if (!newContractIdsToDelete.isEmpty()) Database.delete(newContractIdsToDelete, false);
       
            if (!oldContractsToUpdate.isEmpty()) Database.update(oldContractsToUpdate, false);

        }
        catch(Exception e)
        {
            System.debug('This is the exception message'+e.getMessage());
        }
        finally {
            isRunning = false;
        }
    }

    private static void copyFields(Contract__c src, Contract__c dst) {
        dst.Account__c = src.Account__c;
        dst.Amount_Including_Tax__c = src.Amount_Including_Tax__c;
        dst.Down_Payment__c = src.Down_Payment__c;
        dst.Salesprice_incl_TAX_minus_down_payment__c = src.Salesprice_incl_TAX_minus_down_payment__c;
        dst.Financed_Amount__c = src.Financed_Amount__c;
        dst.Start_Date__c = src.Start_Date__c;
        dst.End_Date__c = src.End_Date__c;
        dst.On_Balance_Sheet__c = src.On_Balance_Sheet__c;
        dst.Regulated__c = src.Regulated__c;
        dst.Business_Area__c = src.Business_Area__c;
        dst.Asset_Contract_Start_Usage_Amount__c = src.Asset_Contract_Start_Usage_Amount__c;
        dst.Asset_Usage_Allowance_Type__c = src.Asset_Usage_Allowance_Type__c;
        dst.Asset_Usage_Allowance__c = src.Asset_Usage_Allowance__c;
        dst.Asset_Usage_Amount_Unit_Of_Measure__c = src.Asset_Usage_Amount_Unit_Of_Measure__c;
        dst.Territory_Manager_Name__c = src.Territory_Manager_Name__c;
        dst.Contract_Territory_Manager_Code__c = src.Contract_Territory_Manager_Code__c;
        dst.DealerId__c = src.DealerId__c;
        dst.Dealer_City__c = src.Dealer_City__c;
        dst.Contract_Number__c = src.Contract_Number__c;
        dst.Contract_Id__c=src.Contract_Id__c;
        dst.Type__c = src.Type__c;
        dst.VIN_Number__c = src.VIN_Number__c;
        dst.Chassis_Number__c = src.Chassis_Number__c;
        dst.Vehicle_Registration_Number__c = src.Vehicle_Registration_Number__c;
        dst.Contract_Status__c = src.Contract_Status__c;
        dst.Term__c = src.Term__c;
        dst.Name=src.name;
        dst.Residual__c = src.Residual__c;
        dst.Balloon__c = src.Balloon__c;
        dst.TerminationDate__c = src.TerminationDate__c;
        //dst.End_of_Term__c = src.End_of_Term__c;
    }
}