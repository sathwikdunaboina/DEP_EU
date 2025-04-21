/* 
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Apex Class Name     CaseBulkUpdateController
* @author             Swami Goskula <swami.goskula@consultant.volvo.com> 
* @Created Date       04-21-2025         
* -----------------------------------------------------------------------------------------------------------------------------------------------
* @description        This class is used to Bulk update on Cases using caseBulkUpdate LWC Component 
* ------------------------------------------------------------------------------------------------------------------------------------------------
*/

public with sharing class CaseBulkUpdateController {
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getSelectedCases(List<Id> caseIds) {
        return [SELECT Id,CaseNumber,RecordTypeId FROM Case WHERE Id IN :caseIds];
    }
        
    @AuraEnabled(cacheable=true)
    public static List<String> validateParentCase(List<Id> caseIds, String status) {
        List<String> casesWithoutParent = new List<String>();
        List<Case> caseRecords = [SELECT Id, ParentId,CaseNumber FROM Case WHERE Id IN :caseIds];
        
        for (Case caseRecord : caseRecords) {
            
            if (caseRecord.ParentId == null) {
                casesWithoutParent.add(caseRecord.CaseNumber);
            }
            
        }
        return casesWithoutParent;
    }
    @AuraEnabled
    public static String validateRecordTypes(List<Id> caseIds) {
        if (caseIds == null || caseIds.isEmpty()) {
            return 'No cases selected.';
        }
        
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, RecordTypeId FROM Case WHERE Id IN :caseIds]);
        Set<Id> recordTypeIds = new Set<Id>();
        
        for (Case caseRecord : caseMap.values()) {
            recordTypeIds.add(caseRecord.RecordTypeId);
        }
        
        if (recordTypeIds.size() > 1) {
            return 'To update multiple records at a time, select records belonging to the same record type.';
        }
        
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static String getCurrentUserProfile() {
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        return currentUser.Profile.Name;
    }
    
}