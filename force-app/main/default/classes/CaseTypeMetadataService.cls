public with sharing class CaseTypeMetadataService {
    public class TypeSubTypeWrapper {
        @AuraEnabled public String typeMaster { get; set; }
        @AuraEnabled public String typeLabel { get; set; }
        @AuraEnabled public List<SubTypeWrapper> subTypes { get; set; }
        
        public TypeSubTypeWrapper() {}
        public TypeSubTypeWrapper(String typeMaster, String typeLabel) {
            this.typeMaster = typeMaster;
            this.typeLabel = typeLabel;
            this.subTypes = new List<SubTypeWrapper>();
        }
    }
    
    public class SubTypeWrapper {
        @AuraEnabled public String subTypeMaster { get; set; }
        @AuraEnabled public String subTypeLabel { get; set; }
        
        public SubTypeWrapper() {}
        public SubTypeWrapper(String subTypeMaster, String subTypeLabel) {
            this.subTypeMaster = subTypeMaster;
            this.subTypeLabel = subTypeLabel;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<TypeSubTypeWrapper> getTypeSubTypes(String country, String recordTypeDevName) {
        // map master value -> translated label for Case.Type
        Map<String, String> typeTranslations = new Map<String, String>();
        for (Schema.PicklistEntry entry : Case.Type.getDescribe().getPicklistValues()) {
            typeTranslations.put(entry.getValue(), entry.getLabel());
        }
        System.debug('typeTranslations'+typeTranslations.get('Spam/Junk') );
        // map master value -> translated label for Case.Sub_Type__c
        Map<String, String> subTypeTranslations = new Map<String, String>();
        for (Schema.PicklistEntry entry : Case.Sub_Type__c.getDescribe().getPicklistValues()) {
            subTypeTranslations.put(entry.getValue(), entry.getLabel());
        }
        System.debug('subTypeTranslations'+subTypeTranslations);
        Map<String, TypeSubTypeWrapper> typeMap = new Map<String, TypeSubTypeWrapper>();
        
        for (Country_Type_Subtype__mdt record : [
            SELECT Country__c, Type__c, Sub_Type__c, RecordTypes_Allowed__c
            FROM Country_Type_Subtype__mdt
            WHERE Country__c = :country
        ]) {
            if (String.isBlank(record.RecordTypes_Allowed__c)) continue;
            
            List<String> allowedTypes = new List<String>();
            for (String rt : record.RecordTypes_Allowed__c.split(',')) {
                allowedTypes.add(rt.trim().toLowerCase());
            }
            if (!allowedTypes.contains(recordTypeDevName.toLowerCase())) continue;
            
            // Master value = English/API name, Label = translated
            String typeMaster = record.Type__c;
            String typeLabel = typeTranslations.containsKey(record.Type__c) 
                ? typeTranslations.get(record.Type__c) 
                : record.Type__c;
            System.debug('record.Type__c--->'+record.Type__c);
            System.debug('typeLabel--->'+typeLabel);
            System.debug('typeTranslationstypeLabel--->'+typeTranslations.get(record.Type__c));
            String subTypeMaster = record.Sub_Type__c;
            String subTypeLabel = subTypeTranslations.containsKey(record.Sub_Type__c) 
                ? subTypeTranslations.get(record.Sub_Type__c) 
                : record.Sub_Type__c;
            System.debug('subTypeLabel--->'+subTypeLabel);
            if (!typeMap.containsKey(typeMaster)) {
                typeMap.put(typeMaster, new TypeSubTypeWrapper(typeMaster, typeLabel));
            }
            typeMap.get(typeMaster).subTypes.add(
                new SubTypeWrapper(subTypeMaster, subTypeLabel)
            );
        }
        return typeMap.values();
    }
    
}