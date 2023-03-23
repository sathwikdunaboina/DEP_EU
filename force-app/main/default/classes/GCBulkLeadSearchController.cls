/*Two different funcitons for clarity*/
public with sharing class GCBulkLeadSearchController {
    
    //Fetches all leads 
    @AuraEnabled
    public static List<Lead> fetchAllLeads ( String dealerName, String accountName, Integer rowSize ){
        try {
        
            String dealerParam = '%'+dealerName+'%';
            String accountParam = String.isEmpty(accountName) == true ? '%%' : accountName;

            return [SELECT Company, Name, Sales_Person_Name__c, Product_Name__c
                            ,Axle_Arrangement__c ,Chassis_Type__c, Dealer_Name__c
                            ,Status, Vehicle_Status__c, Dealer_Delivery_Date__c
                            ,Owner.Name, LeadSource
                    FROM Lead
                    WHERE Dealer_Name__c Like :dealerParam 
                        AND isConverted = false
                        AND Company Like :accountParam
                        WITH SECURITY_ENFORCED
                    ORDER BY Dealer_Name__c, Company, Dealer_Delivery_Date__c
                    LIMIT :rowSize];
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
        }
    }

    //Fetches leads where the logged in user is the owner
    @AuraEnabled
    public static List<Lead> fetchMyLeads ( String dealerName, String accountName, Integer rowSize ){
        try {
            String dealerParam = '%'+dealerName+'%';
            String accountParam = String.isEmpty(accountName) == true ? '%%' : accountName;

            return [SELECT Company, Name, Sales_Person_Name__c, Product_Name__c
                            ,Axle_Arrangement__c ,Chassis_Type__c, Dealer_Name__c
                            ,Status, Vehicle_Status__c, Dealer_Delivery_Date__c
                            ,Owner.Name, LeadSource
                    FROM Lead
                    WHERE OwnerId = :UserInfo.getUserId() 
                        AND Dealer_Name__c Like :dealerParam 
                        AND Company Like :accountParam
                        AND isConverted = false
                        WITH SECURITY_ENFORCED
                    ORDER BY Dealer_Name__c, Company, Dealer_Delivery_Date__c
                    LIMIT :rowSize];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> fetchAccountsOfLeads ( String dealerName, Boolean myLeads ) {
        try {
            String dealerParam = '%'+dealerName+'%';
            List<AggregateResult> leads = null;
            
            if (myLeads) {
                leads = [SELECT Company FROM Lead
                         WHERE Dealer_Name__c Like :dealerParam AND isConverted = false AND OwnerId = :UserInfo.getUserId()
                         WITH SECURITY_ENFORCED
                         GROUP BY Company
                         ORDER BY Company
                         LIMIT 1000];
            }
            else {
                leads = [SELECT Company FROM Lead
                         WHERE Dealer_Name__c Like :dealerParam AND isConverted = false
                         WITH SECURITY_ENFORCED
                         GROUP BY Company
                         ORDER BY Company
                         LIMIT 1000];
            }
            
            List<String> accountNames= new List<string>();
            
            if (leads.isEmpty()) {
                return accountNames;
            }
                          
            for(AggregateResult lead: leads){
                String accountName = String.valueOf(lead.get('Company'));
                if (!String.isEmpty(accountName)) {
                    accountNames.add(accountName);
                }      
      }
            
            return accountNames;
        } 
        catch (Exception e) {
              throw new AuraHandledException(e.getMessage());
         }
    }
}