public with sharing class BulkUpdateOnCase {
    public class CaseUpdateRequest {
        @InvocableVariable(required=true) public List<Id>CaseIds;
        @InvocableVariable public String Type;
        @InvocableVariable public String SubType;
        @InvocableVariable public String Status;
        @InvocableVariable public String StatusReason;
        @InvocableVariable public String Brand;     
        @InvocableVariable public String ErrorMessage; // New field for error messages
        
        
    }
    
    @InvocableMethod(label='Mass Update Cases')
    public static List<CaseUpdateRequest> updateCases(List<CaseUpdateRequest> requests) {        
        List<CaseUpdateRequest> response = new List<CaseUpdateRequest>();
        
        Id systemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        Id currentUserProfileId = UserInfo.getProfileId();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MEDALLIACLF Alert Cases').getRecordTypeId();
        
        system.debug(currentUserProfileId+'currentUserProfileId1');
        system.debug(systemAdminProfileId+'systemAdminProfileId');
        system.debug(recordTypeId+'recordTypeId');
        
        
        
        for (CaseUpdateRequest request : requests) {
            if (request.CaseIds == null || request.CaseIds.isEmpty()) continue;
            
            // Fetch existing Cases with required fields
            Map<Id, Case> existingCases = new Map<Id, Case>(
                [SELECT Id, CaseNumber,ParentId,Type, Sub_Type__c,Status,Status_Reason__c,Brand__c
                 FROM Case
                 WHERE Id IN :request.CaseIds]
            );
            
            List<Case> caseToUpdate = new List<Case>();   
            
            List<String> errorMessages = new List<String>(); // Initialize list to collect error messages
            
            
            String aggregatedErrorMessage = ''; // Initialize aggregated error message
            
            
            for (Id caseId : request.CaseIds) {
                Case existingCase = existingCases.get(caseId);
                if (existingCase == null) continue;
                
                Case updatedCase = new Case(Id = caseId);
                
                String caseErrorMessage = ''; // Initialize case-specific error message
                
                
                // Check if Brand is required for non-System Admin users
                if (currentUserProfileId != systemAdminProfileId && request.Brand == null) {
                    system.debug('currentUserProfileId'+currentUserProfileId);
                    caseErrorMessage +=('Brand is mandatory to update a Case');
                    
                    
                    
                }
                
                if (request.status == null){
                    caseErrorMessage += 'Status is Mandatory to update a case';
                    
                } 
                if (request.Status == 'Closed' && request.Type == null) {
                    caseErrorMessage  += 'Type and SubType is mandatory when Status is Closed';
                }
                if (request.Status == 'Closed' && request.Type != null && request.SubType == null) {
                    caseErrorMessage  += 'SubType is mandatory when Status is Closed';
                }                
                
                if (request.Type != null) {
                    updatedCase.Type = request.Type;
                    system.debug('updatedCase.Type'+updatedCase.Type);
                    if (request.SubType == null) {
                        updatedCase.Sub_Type__c = null;
                    }
                }
                
                if (request.SubType != null) {
                    updatedCase.Sub_Type__c = request.SubType;
                    system.debug('updatedCase.Sub_Type__c'+updatedCase.Sub_Type__c);
                    
                }
                
                if (request.Status != null) {
                    updatedCase.Status = request.Status;
                    // Reset Status Reason if Status is changed and no new Status Reason is provided
                    if (request.StatusReason == null) {
                        updatedCase.Status_Reason__c = null;
                    }
                }
                
                if (request.StatusReason != null) {
                    updatedCase.Status_Reason__c = request.Statusreason;
                    system.debug('updatedCase.Status_Reason__c'+updatedCase.Status_Reason__c);
                    
                    
                }
                if (request.Brand != null) {
                    updatedCase.Brand__c = request.Brand;
                }
                
                
                
                if (request.Status == 'Duplicate') {
                    if (existingCase.ParentId == null) {
                        caseErrorMessage += 'Please fill parent case when status is duplicate.'+ existingCase.CaseNumber+'.';
                    }
                }
                
                
                
                
                
                // Add case-specific error message to aggregated error message
                
                if (!String.isBlank(caseErrorMessage) && !errorMessages.contains(caseErrorMessage)) {
                    errorMessages.add(caseErrorMessage);
                }
                
                
                // Add updated Opp to list
                caseToUpdate.add(updatedCase);
            }
            
            if (!caseToUpdate.isEmpty() && errorMessages.isEmpty()) {
                update caseToUpdate;
                System.debug('Update is done');
            }
            
            
            // Set the aggregated error message for the request
            request.ErrorMessage = String.join(errorMessages, '\n');
            system.debug( request.ErrorMessage+' request.ErrorMessage');
            response.add(request);
            system.debug(response+'response');
            
            
        }
        system.debug('response2'+response);
        
        return response;
    }
    
}