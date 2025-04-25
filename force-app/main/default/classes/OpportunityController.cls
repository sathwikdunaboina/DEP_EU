public with sharing class OpportunityController {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(List<Id> opportunityIds) {
        return [SELECT Id, Name, StageName, Opportunity_Type__c, Lost_Reason__c, 
                       Reason__c, Sub_Stage__c, Probability, NetSalesPrice__c, 
                       RecordType.Name 
                FROM Opportunity 
                WHERE Id IN :opportunityIds];
    }
 
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getAllPicklistValues() {
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        
        picklistMap.put('StageName', getPicklistValues('Opportunity', 'StageName'));
        picklistMap.put('Opportunity_Type__c', getPicklistValues('Opportunity', 'Opportunity_Type__c'));
        picklistMap.put('Lost_Reason__c', getPicklistValues('Opportunity', 'Lost_Reason__c'));
        picklistMap.put('Reason__c', getPicklistValues('Opportunity', 'Reason__c'));
        picklistMap.put('Sub_Stage__c', getPicklistValues('Opportunity', 'Sub_Stage__c'));
 
        return picklistMap;
    }
 
    private static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> values = new List<String>();
        
        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldName).getDescribe();
        
        for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
            values.add(entry.getValue());
        }
        
        return values;
    }
 
    @AuraEnabled
    public static void updateOpportunities(List<Opportunity> opportunities) {
        update opportunities;
    }
}