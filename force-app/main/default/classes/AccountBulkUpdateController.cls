/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     AccountBulkUpdateController
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com> 
* @Created Date       03-10-2025         
* ------------------------------------------------------------------------------------------
* @description        This class is used as controller for accountBulkUpdate LWC Component
* ------------------------------------------------------------------------------------------
*/
public with sharing class AccountBulkUpdateController {
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getAccounts
* @description     This method returns Account field values of the selected Accounts
* ------------------------------------------------------------------------------------------------------
* @param           String Account Id string contains list of selected Account id.     
* @return          Field Values   
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String sSelectedAccountIds) {
        try{
            Integer iLastOccurence = sSelectedAccountIds.lastIndexOf('-');
            String sSelectedAccountIdsSanitized = sSelectedAccountIds.left(iLastOccurence)+sSelectedAccountIds.right(sSelectedAccountIds.length()-iLastOccurence-1);
            List<String> listSelectedAccountIds = sSelectedAccountIdsSanitized.split('-');
            return [SELECT Id, Name,OwnerId,RecordType.Name
                    FROM Account
                    WHERE Id IN :listSelectedAccountIds];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching opportunities: ' + e.getMessage());
        }
    }
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     updateAccounts
* @description     This method updates Accounts with the given field values
* ------------------------------------------------------------------------------------------------------
* @param           List of selected Accounts     
* @return          Updates Account Records   
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @AuraEnabled
    public static String updateAccounts(List<Account> accounts,Boolean transferOpportunities) {
        try {
            if (accounts == null || accounts.isEmpty()) {
                return 'No updates were made.';
            }
            Set<Id> accountIds = new Set<Id>();
            Id newOwnerId = accounts[0].OwnerId;
            for(Account acc: accounts){
                accountIds.add(acc.Id);
            }
            update accounts;
            
            if(transferOpportunities && newOwnerId!= null){
               
                Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
                for(Opportunity opp:[SELECT Id,OwnerId FROM Opportunity WHERE StageName !='Closed Lost' 
                                     AND StageName !='Closed Won' AND (AccountId IN:accountIds)]){
                                         oppMap.put(opp.Id, opp);
                                     }
            
            for(Opportunity opp:oppMap.values()){
                opp.OwnerId = newOwnerId;
            }
            if(!oppMap.isEmpty()){
                update oppMap.values();
            }
            }
            return 'Records updated successfully.';
        } catch (Exception e) {
            throw new AuraHandledException('Error updating records: ' + e.getMessage());
        }
    }
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     searchAccountOwners
* @description     This method displays maximum of 10 users with the search term entered by Users 
* ------------------------------------------------------------------------------------------------------
* @param           String of search term     
* @return          10 User which contains Search term   
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @AuraEnabled(cacheable=true)
    public static List<User> searchAccountOwners(String searchTerm) {
        return [SELECT Id, Name FROM User
                WHERE IsActive = true
                AND Name LIKE :searchTerm
                ORDER BY Name LIMIT 10];
    }
}