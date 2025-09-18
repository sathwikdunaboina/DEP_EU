public with sharing class CaseTypeMetadataService {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getTypeSubTypes(String country, String recordTypeDevName) {
        Map<String, List<String>> typeMap = new Map<String, List<String>>();
        system.debug('country'+country);
        system.debug('recordTypeDevName'+recordTypeDevName);
        for (Country_Type_Subtype__mdt record : [
            SELECT Country__c, Type__c, Sub_Type__c, RecordTypes_Allowed__c
            FROM Country_Type_Subtype__mdt
            WHERE Country__c = :country
        ]) {system.debug('record'+record);
            if (String.isBlank(record.RecordTypes_Allowed__c)) continue;
            
            List<String> allowedTypes = new List<String>();
            for (String rt : record.RecordTypes_Allowed__c.split(',')) {
                allowedTypes.add(rt.trim().toLowerCase());
            }
            
            if (allowedTypes.contains(recordTypeDevName.toLowerCase())) {
                if (!typeMap.containsKey(record.Type__c)) {
                    typeMap.put(record.Type__c, new List<String>());
                }
                typeMap.get(record.Type__c).add(record.Sub_Type__c);
            }
           }
        return typeMap;
    }
}