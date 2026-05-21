/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     OpportunityBulkUpdateController
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com> 
* @Created Date       03-10-2025         
* ------------------------------------------------------------------------------------------
* @description        This class is used as controller for opportunityBulkUpdate LWC Component
* ------------------------------------------------------------------------------------------
*/
public with sharing class OpportunityBulkUpdateController {
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getOpportunities
* @description     This method returns Opportunity field values of the selected Opportunities
* ------------------------------------------------------------------------------------------------------
* @param           String Opportunity Id string contains list of selected Opportunity id.     
* @return          Field Values   
* ------------------------------------------------------------------------------------------------------ 
*/ 
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(String sSelectedOpportunityIds) {
        System.debug(sSelectedOpportunityIds);
        try{
            Integer iLastOccurence = sSelectedOpportunityIds.lastIndexOf('-');
            String sSelectedOpportunityIdsSanitized = sSelectedOpportunityIds.left(iLastOccurence)+sSelectedOpportunityIds.right(sSelectedOpportunityIds.length()-iLastOccurence-1);
            List<String> listSelectedOpportunityIds = sSelectedOpportunityIdsSanitized.split('-');
            
            return [SELECT Id, Name, StageName, OwnerId, AccountId, RecordType.Name,
                    Lost_Reason__c, Opportunity_Type__c, Reason__c,Country__c,
                    Amount, Probability, Sub_Stage__c,Finance_Houses__c,Additional_Details__c
                    FROM Opportunity
                    WHERE Id IN :listSelectedOpportunityIds];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching opportunities: ' + e.getMessage());
        }
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     updateOpportunities
* @description     This method updates Opportunities with the given field values
* ------------------------------------------------------------------------------------------------------
* @param           List of selected Opportunities     
* @return          Updates Opportunity Records   
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @AuraEnabled
    public static String updateOpportunities(List<Opportunity> opportunities) {
        try {
            if (opportunities == null || opportunities.isEmpty()) {
                return 'No updates were made.';
            }
            
            update opportunities;
            return 'Records updated successfully.';
        } catch (Exception e) {
            throw new AuraHandledException('Error updating records: ' + e.getMessage());
        }
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     searchOpportunityOwners
* @description     This method displays maximum of 10 users with the search term entered by Users 
* ------------------------------------------------------------------------------------------------------
* @param           String of search term     
* @return          10 User which contains Search term   
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @AuraEnabled(cacheable=true)
    public static List<User> searchOpportunityOwners(String searchTerm) {
        return [SELECT Id, Name FROM User
                WHERE IsActive = true
                AND Name LIKE :searchTerm
                ORDER BY Name LIMIT 10];
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     searchCustomerAccounts
* @description     This method displays maximum of 10 Accounts with the search term entered by Users 
* ------------------------------------------------------------------------------------------------------
* @param           String of search term     
* @return          10 Accounts which contains Search term   
* ------------------------------------------------------------------------------------------------------ 
*/
    @AuraEnabled(cacheable=true)
    public static List<Account> searchCustomerAccounts(String searchTerm) {
        return [SELECT Id, Name FROM Account
                WHERE Name LIKE :searchTerm
                ORDER BY Name
                LIMIT 10];
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getStageProbabilities
* @description     This method is to get the Probability of Each stage 
* ------------------------------------------------------------------------------------------------------
* @return          Map of Stage with its corresponding Probability value
* ------------------------------------------------------------------------------------------------------ 
*/
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getStageProbabilities() {
        Map<String, Integer> probMap = new Map<String, Integer>();
        
        for (OpportunityStage stage : [
            SELECT MasterLabel, DefaultProbability
            FROM OpportunityStage
            WHERE IsActive = true
        ]) {
            probMap.put(stage.MasterLabel, Integer.valueOf(stage.DefaultProbability));
        }
        
        return probMap;
    }
}