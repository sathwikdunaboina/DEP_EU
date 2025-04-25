public with sharing class CasePicklistHelper {
    @InvocableMethod(label='Get Dependent Picklist Values' description='Fetches dependent picklist values based on record type')
    public static List<PicklistValuesWrapper> getDependentPicklistValues(List<RecordTypeIdWrapper> recordTypeIdWrappers) {
        List<PicklistValuesWrapper> results = new List<PicklistValuesWrapper>();
        
        for (RecordTypeIdWrapper wrapper : recordTypeIdWrappers) {
            PicklistValuesWrapper resultWrapper = new PicklistValuesWrapper();
            resultWrapper.caseType = getPicklistValues('Case', 'Type', wrapper.recordTypeId);
            resultWrapper.subType = getPicklistValues('Case', 'Sub_Type__c', wrapper.recordTypeId);
            resultWrapper.status = getPicklistValues('Case', 'Status', wrapper.recordTypeId);
            resultWrapper.statusReason = getPicklistValues('Case', 'Status_Reason__c', wrapper.recordTypeId);
            resultWrapper.brand = getPicklistValues('Case', 'Brand__c', wrapper.recordTypeId);
            results.add(resultWrapper);
        }
        
        return results;
    }
    
    private static List<String> getPicklistValues(String objectName, String fieldName, Id recordTypeId) {
        List<String> picklistValues = new List<String>();
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeSObjectResult = sObjectType.getDescribe();
        Schema.RecordTypeInfo recordTypeInfo = describeSObjectResult.getRecordTypeInfosById().get(recordTypeId);
        
        if (recordTypeInfo != null) {
            Schema.DescribeFieldResult fieldResult = describeSObjectResult.fields.getMap().get(fieldName).getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            
            for (Schema.PicklistEntry entry : picklistEntries) {
                if (entry.isActive()) {
                    picklistValues.add(entry.getLabel());
                }
            }
        }
        return picklistValues;
    }
    
    public class RecordTypeIdWrapper {
        @InvocableVariable
        public Id recordTypeId;
    }
    
    public class PicklistValuesWrapper {
        @InvocableVariable
        public List<String> caseType;
        
        @InvocableVariable
        public List<String> subType;
        
        @InvocableVariable
        public List<String> status;
        
        @InvocableVariable
        public List<String> statusReason;
        
        @InvocableVariable
        public List<String> brand;
    }
}