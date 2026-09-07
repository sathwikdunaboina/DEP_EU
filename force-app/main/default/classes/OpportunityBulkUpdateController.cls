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
                    Amount, Probability, Sub_Stage__c,Finance_Houses__c,Additional_Details__c,VFS_Connect_Quote_Ref__c, Quote_Id__c,Factory_Order__r.Name,Dealer_Account_Billing_Country__c,Owner.Country
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
           
            // Check whether Quote Ref is being updated
            Boolean quoteRefUpdated = false;
            Set<Id> opportunityIds = new Set<Id>();
            Set<Id> quoteRefIds = new Set<Id>();
           
            for (Opportunity opp : opportunities) {
               
                opportunityIds.add(opp.Id);
               
                if (opp.VFS_Connect_Quote_Ref__c != null) {
                    quoteRefUpdated = true;
                    quoteRefIds.add(opp.VFS_Connect_Quote_Ref__c);
                }
            }
           
            // Run validation only when Quote Ref is updated
            if (quoteRefUpdated) {
               
                List<Opportunity> existingOpps = [
                    SELECT Id,
                    Name,
                    Amount,
                    StageName,
                    Customer_Account__c,
                    Customer_Account__r.CustomerID__c,
                    Quote_Id__c,
                    VFS_Connect_Quote_Ref__c
                    FROM Opportunity
                    WHERE Id IN :opportunityIds
                ];
               
               
                List<String> validationMessages = new List<String>();
               
                for (Opportunity opp : existingOpps) {
                   
                    List<String> missingFields = new List<String>();
                   
                    if (opp.Amount == null) {
                        missingFields.add('Net Sales Price');
                    }
                   
                    if (opp.Customer_Account__c == null) {
                        missingFields.add('Customer Account');
                    }
                   
                    if (!missingFields.isEmpty()) {
                        validationMessages.add(
                            opp.Name +
                            ' - Missing: ' +
                            String.join(missingFields, ', ')
                        );
                    }
                }
               
                if (!validationMessages.isEmpty()) {
                    throw new AuraHandledException(
                        String.join(validationMessages, '\n')
                    );
                }
               
                // Get Quote Number(s)
                CMSAPI1__c settings = CMSAPI1__c.getOrgDefaults();
               
                Map<Id, VFS_Connect_Quote__c> quoteMap =
                    new Map<Id, VFS_Connect_Quote__c>(
                        [
                            SELECT Id,
                            Quote_Number__c,
                            Account_CMS_Number__c
                            FROM VFS_Connect_Quote__c
                            WHERE Id IN :quoteRefIds
                        ]
                    );
               
                // =============================
                // CMS NUMBER VALIDATION
                // =============================
                List<String> cmsMismatchOpps = new List<String>();
               
                for (Opportunity opp : opportunities) {
                   
                    if (opp.VFS_Connect_Quote_Ref__c != null &&
                        quoteMap.containsKey(opp.VFS_Connect_Quote_Ref__c)) {
                           
                            VFS_Connect_Quote__c quoteRec =
                                quoteMap.get(opp.VFS_Connect_Quote_Ref__c);
                           
                            Opportunity dbOpp;
                           
                            for (Opportunity o : existingOpps) {
                                if (o.Id == opp.Id) {
                                    dbOpp = o;
                                    break;
                                }
                            }
                           
                            if (dbOpp != null &&
                                dbOpp.Customer_Account__r != null &&
                                dbOpp.Customer_Account__r.CustomerID__c != null) {
                                   
                                    String customerId =
                                        dbOpp.Customer_Account__r.CustomerID__c;
                                   
                                    // CH-456789 -> 456789
                                    customerId =
                                        customerId.replaceFirst('^[A-Za-z]{2}-?', '');
                                   
                                    String quoteCms =
                                        String.valueOf(quoteRec.Account_CMS_Number__c);
                                   
                                    if (customerId != quoteCms) {
                                       
                                        
                                        cmsMismatchOpps.add(
                                            'Quote ' + quoteRec.Quote_Number__c + ' cannot be assigned to Opportunity' + dbOpp.Name +
                                            ' since Quote CMS Number does not match with Customer ID'
                                        );
                                    }
                                }
                        }
                }
               
                if (!cmsMismatchOpps.isEmpty()) {
                    throw new AuraHandledException(
                        String.join(cmsMismatchOpps, '\n')
                    );
                }
               
                // =============================
                // POPULATE QUOTE FIELDS
                // =============================
               
                for (Opportunity opp : opportunities) {
                   
                    if (opp.VFS_Connect_Quote_Ref__c != null &&
                        quoteMap.containsKey(opp.VFS_Connect_Quote_Ref__c)) {
                           
                            VFS_Connect_Quote__c quoteRec =
                                quoteMap.get(opp.VFS_Connect_Quote_Ref__c);
                           
                            opp.Quote_Id__c = quoteRec.Quote_Number__c;
                           
                            opp.Quote_Url__c =
                                settings.SearchQuoteEndpoint__c +
                                'QuotationId=' +
                                quoteRec.Quote_Number__c +
                                '&ExternalSystem=SalesConnect';
                           
                            // Move Stage to Quoted only when not already
                            // Quoted, Closed Won, or Closed Lost
                           
                            Opportunity existingOpp = null;
                           
                            for (Opportunity o : existingOpps) {
                                if (o.Id == opp.Id) {
                                    existingOpp = o;
                                    break;
                                }
                            }
                           
                            if (existingOpp != null &&
                                existingOpp.StageName != 'Quoted' &&
                                existingOpp.StageName != 'Closed Won' &&
                                existingOpp.StageName != 'Closed Lost' &&
                                existingOpp.StageName != 'Closed FO Cancelled') {
                                   
                                    opp.StageName = 'Quoted';
                                }
                        }
                }
            }
           
            update opportunities;
           
            return 'Records updated successfully.';
           
        }
        catch (AuraHandledException e) {
            throw e;
        }
        catch (Exception e) {
            throw new AuraHandledException(
                'Error updating records: ' + e.getMessage()
            );
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


/*
 * 
* @Method Name - getMetadataRecords
* @description -This method returns the custom metadata of country values for which the Next Step Date Should be visible
* @return      -Metadata Records
 */

    @AuraEnabled(cacheable=true)
    public static List<Opportunities_Next_Step_Date_Countries__mdt> getMetadataRecords() {
        return [SELECT Country__c FROM Opportunities_Next_Step_Date_Countries__mdt];
    
}
}