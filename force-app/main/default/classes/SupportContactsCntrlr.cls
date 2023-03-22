public without sharing class SupportContactsCntrlr {
    @AuraEnabled
    public static Territory_Manager__c getTerritoryMngr(){
        String userId = UserInfo.getUserId();
        try{
            
            User userObj = [SELECT Id, Account.Territory_Manager__c FROM User WHERE Id=: userId ];
            if(userObj.Account.Territory_Manager__c != null)
            {
                return [SELECT Id, Name , Phone__c, Email__c FROM Territory_Manager__c WHERE Id =: userObj.Account.Territory_Manager__c]; 
            }
            else 
            {
                return null;
            }
        }catch (Exception ex) {
            
            throw new AuraHandledException(ex.getMessage()+' '+ex.getCause()+' '+ex.getLineNumber()+' '+ex.getStackTraceString());
        }
    }
    @AuraEnabled
    public static List<Support_Desk__c> getServiceDesk(){
        try{
            String country = [SELECT Country 
                              FROM User 
                              WHERE Id =:UserInfo.getUserId()].Country;	
            List<Support_Desk__c> supportDeskList = [SELECT Address__c, Contact_Number__c, Country__c, E_Mail__c, Support_Hours__c 
                                                     FROM Support_Desk__c 
                                                     WHERE Country__c =:country];
            return supportDeskList;
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()+' '+ex.getCause()+' '+ex.getLineNumber()+' '+ex.getStackTraceString());
        }
        
    }
    
}