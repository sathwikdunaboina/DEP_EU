public with sharing class BulkUpdateOnOpportunity {
    
    /*public class OpportunityUpdateRequest {
        @InvocableVariable(required=true) public List<Id> opportunityIds;
        @InvocableVariable public String stageName;
        @InvocableVariable public Id customerAccount;
        @InvocableVariable public Id ownerId;
        @InvocableVariable public String opportunityType;
        @InvocableVariable public Decimal netSalesPrice;
        @InvocableVariable public String lostReason;
        @InvocableVariable public String reason;
        @InvocableVariable public Decimal probability;
        @InvocableVariable public String subStageNeedsAnalysis;
        @InvocableVariable public String subStageQuoted;
        @InvocableVariable public String opportunityTypeLCV;
    }
    
    @InvocableMethod(label='Mass Update Opportunities')
    public static void updateOpportunities(List<OpportunityUpdateRequest> requests) {
        Map<Id, Opportunity> existingOpps = new Map<Id, Opportunity>([SELECT Id, StageName FROM Opportunity]);
        for (OpportunityUpdateRequest request : requests) {
            List<Opportunity> oppsToUpdate = [SELECT Id, StageName, Customer_Account__c, OwnerId,Type,Amount,Lost_Reason__c,Reason__c,Probability,Sub_Stage__c,Opportunity_Type__c FROM Opportunity WHERE Id IN :request.opportunityIds];
            
            for (Opportunity opp : oppsToUpdate) {
                if (request.stageName != null) {
                    opp.StageName = request.stageName;
                }
                if (request.customerAccount != null) {
                    opp.Customer_Account__c = request.customerAccount;
                }
                if (request.ownerId != null) {
                    opp.OwnerId = request.ownerId;
                }
                if (request.opportunityType != null) {
                    opp.Type = request.opportunityType;
                }
                if (request.opportunityTypeLCV != null) {
                    opp.Opportunity_Type__c = request.opportunityTypeLCV;
                }
                if (request.netSalesPrice != null) {
                    opp.Amount = request.netSalesPrice;
                }
                if (request.lostReason != null) {
                    opp.Lost_Reason__c = request.lostReason;
                }
                if (request.reason != null) {
                    opp.Reason__c = request.reason;
                }
                if (request.probability != null) {
                    opp.Probability = request.probability;
                }
                if (request.subStageNeedsAnalysis != null) {
                    opp.Sub_Stage__c = request.subStageNeedsAnalysis;
                }
                if (request.subStageQuoted != null) {
                    opp.Sub_Stage__c = request.subStageQuoted;
                }
            }
            update oppsToUpdate;
        }
    }*/
    public class OpportunityUpdateRequest {
        @InvocableVariable(required=true) public List<Id> opportunityIds;
        @InvocableVariable public String stageName;
        @InvocableVariable public Id customerAccount;
        @InvocableVariable public Id ownerId;
        @InvocableVariable public String opportunityType;
        @InvocableVariable public Decimal netSalesPrice;
        @InvocableVariable public String lostReason;
        @InvocableVariable public String reason;
        @InvocableVariable public Decimal probability;
        @InvocableVariable public String subStageNeedsAnalysis;
        @InvocableVariable public String subStageQuoted;
        @InvocableVariable public String opportunityTypeLCV;
 
        // Add other optional fields here
    }
 
    @InvocableMethod(label='Mass Update Opportunities')
    public static void updateOpportunities(List<OpportunityUpdateRequest> requests) {
        for (OpportunityUpdateRequest request : requests) {
            if (request.opportunityIds == null || request.opportunityIds.isEmpty()) continue;
 
            // Fetch existing Opps with required fields
            Map<Id, Opportunity> existingOpps = new Map<Id, Opportunity>(
                [SELECT Id, StageName, Customer_Account__c, OwnerId,Type,Amount,Lost_Reason__c,Reason__c,Probability,Sub_Stage__c,Opportunity_Type__c
                 FROM Opportunity
                 WHERE Id IN :request.opportunityIds]
            );
 
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
 
            for (Id oppId : request.opportunityIds) {
                Opportunity existingOpp = existingOpps.get(oppId);
                if (existingOpp == null) continue;
 
                Opportunity updatedOpp = new Opportunity(Id = oppId);
 
                // Handle StageName (Required field fallback)
                if (String.isNotBlank(request.stageName)) {
                    updatedOpp.StageName = request.stageName;
                } else {
                    updatedOpp.StageName = existingOpp.StageName;
                }
                /*if (request.stageName != null) {
                    updatedOpp.StageName = request.stageName;
                }*/
                if (request.ownerId != null) {
                    updatedOpp.OwnerId = request.ownerId;
                }
                if (request.probability != null) {
                    updatedOpp.Probability = request.probability;
                }
                if (request.customerAccount != null) {
                    updatedOpp.Customer_Account__c = request.customerAccount;
                }
                if (request.opportunityType != null) {
                    updatedOpp.Type = request.opportunityType;
                }
                if (request.opportunityTypeLCV != null) {
                    updatedOpp.Opportunity_Type__c = request.opportunityTypeLCV;
                }
                if (request.netSalesPrice != null) {
                    updatedOpp.Amount = request.netSalesPrice;
                }
                if (request.lostReason != null) {
                    updatedOpp.Lost_Reason__c = request.lostReason;
                }
                if (request.reason != null) {
                    updatedOpp.Reason__c = request.reason;
                }
                if (request.probability != null) {
                    updatedOpp.Probability = request.probability;
                }
                if (request.subStageNeedsAnalysis != null) {
                    updatedOpp.Sub_Stage__c = request.subStageNeedsAnalysis;
                }
                if (request.subStageQuoted != null) {
                    updatedOpp.Sub_Stage__c = request.subStageQuoted;
                }
 
                // Add updated Opp to list
                oppsToUpdate.add(updatedOpp);
            }
 
            if (!oppsToUpdate.isEmpty()) {
                update oppsToUpdate;
            }
        }
    }
}