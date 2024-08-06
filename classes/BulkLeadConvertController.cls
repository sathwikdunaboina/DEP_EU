public with sharing class BulkLeadConvertController {
    
    //reloads lead list (to avoid dirty data)
    @AuraEnabled (cacheable=true)
    public static List<Lead> getLeadList( List<String> leadIds){
        try {
            return [SELECT Company, Name, Sales_Person_Name__c, Product_Name__c
                        ,Axle_Arrangement__c ,Chassis_Type__c, Dealer_Name__c
                        ,Status, Vehicle_Status__c, Dealer_Delivery_Date__c
                        ,Owner.Name, LeadSource
                FROM Lead
                WHERE Id in :leadIds
                    AND isConverted = false];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //converts lead in bulk. 1 opportunity for 1 lead.
    @AuraEnabled
    public static Boolean convert(List<Id> leadIds, Id accountId, Id contactId){
        try {
            if(leadIds == null || leadIds.isEmpty()){
                throw new AuraException('No leads to convert');
            }
            //Because lookup filters are not supported, 
            //we let users to select any contact and then verify the account id.
            if(accountId != null && contactId != null){
                Contact contact = [SELECT AccountId FROM Contact WHERE Id =:contactId];
                if(accountId != contact.AccountId){
                    throw new AuraException('Contact & Accounts do not match!');
                }
            }
            //Pickup the first converted status. There is only one converted status.
            LeadStatus convertedStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true Limit 1];
            //To avoid creating multiple accounts, we convert the first lead
            //and use the account and contact id from that conversion
            if (accountId == null || contactId == null){
                system.debug(leadIds[0]+ '' + accountId + '' + contactId+ ''+ convertedStatus);
                Database.LeadConvert leadConverter = getLeadConverter(leadIds[0], accountId, contactId, convertedStatus);
                Database.LeadConvertResult firstConvertResult = Database.convertLead(leadConverter);
                if(leadIds.size() == 1 ){
                    return firstConvertResult.isSuccess();
                }
                accountId = firstConvertResult.getAccountId();
                contactId = firstConvertResult.getContactId();
                leadIds.remove(0);//after convertion, remove the first lead id
            }
            //for the rest of leads prepare the lead convert object
            List<Database.LeadConvert> leadConverters = new List<Database.LeadConvert>();
            Boolean success = true;
            for (Id leadId : leadIds){
                leadConverters.add(getLeadConverter(leadId, accountId, contactId, convertedStatus));
            }
            //Boom goes the convert.
            List<Database.LeadConvertResult> results = Database.convertLead(leadConverters);
            //Aggregating the success. Later will be extended to individual results.
            for (Database.LeadConvertResult result : results) {
                success &= result.isSuccess();
            }
            return success;
            
        } catch (Exception e) {
            System.debug(e.getCause());
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    //creates a new account if the user has not selected an existing account.
    private static Database.LeadConvert getLeadConverter(Id leadId, Id accountId, Id contactId, LeadStatus convertedStatus){
        Database.LeadConvert leadConverter = new Database.LeadConvert();
        //Setting the same Account and ContactId for all leads
        if (String.isNotBlank(accountId)) {
            leadConverter.setAccountId(accountId);
        }
        if (String.isNotBlank(contactId)) {
            leadConverter.setContactId(contactId);
        }
        leadConverter.setLeadId(leadId);
        leadConverter.setConvertedStatus(convertedStatus.MasterLabel);
        return leadConverter;
    } 
}