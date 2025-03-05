/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     AccountMessagingUserController
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       01-20-2025         
* ------------------------------------------------------------------------------------------
* @description        This class is used as controller for AccountMessagingUserDetail LWC Component
* ------------------------------------------------------------------------------------------
*/
public with sharing class AccountMessagingUserController { 
        
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getAccountMessagingUserDetails
* @description     This method returns account wrapper which contains account details along with messaging user information.
*                  Account Wrapper result is displayed in lightning data table.
* ------------------------------------------------------------------------------------------------------
* @param           String Account Id string contains list of selected account id.     
* @return          AccountWrapper   
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @AuraEnabled
    public static List<AccountWrapper> getAccountMessagingUserDetails(String sSelectedAccountIds){
        
        system.debug('getAccountMessagingUserDetails called');
        Integer iLastOccurence = sSelectedAccountIds.lastIndexOf('-');
        String sSelectedAccountIdsSanitized = sSelectedAccountIds.left(iLastOccurence)+sSelectedAccountIds.right(sSelectedAccountIds.length()-iLastOccurence-1);
     
        List<String> listSelectedAccountIds = sSelectedAccountIdsSanitized.split('-');
        Set<Id>setAccountIdsWithMessagingUsers = new Set<Id>();
       
        for(MessagingEndUser msgEndUser : [Select Id ,Name, AccountId , Is_Primary__c , MessageType , MessagingChannelId , MessagingConsentStatus , MessagingPlatformKey
                                                       FROM MessagingEndUser
                                                      WHERE MessagingConsentStatus != 'OptedOut' AND MessageType = 'WhatsApp' AND Is_Primary__c = true AND AccountId =: listSelectedAccountIds
                                                      WITH USER_MODE LIMIT 49999]
        ){
            setAccountIdsWithMessagingUsers.add(msgEndUser.AccountId);
        }
        List<Account> listSelectedAccounts = getSelectedAccounts(listSelectedAccountIds);
        List<AccountWrapper> listAccountWrappers = getAccountWrapperList(listSelectedAccounts,setAccountIdsWithMessagingUsers);
        
        return listAccountWrappers;
    }
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getSelectedAccounts
* @description     Gets list of selected accounts
* ------------------------------------------------------------------------------------------------------
* @param          List<Id>  Account Ids List     
* @return         List<Account>   
* ------------------------------------------------------------------------------------------------------ 
*/ 
    
    private static List<Account> getSelectedAccounts(List<Id> listSelectedAccountIds){
        List<Account> listSelectedAccounts = [Select Id,Name,Phone,Website FROM Account where Id IN : listSelectedAccountIds AND  Phone != null WITH USER_MODE LIMIT 49999];
        return listSelectedAccounts;
    } 
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getAccountWrapperList
* @description     Get Account Wrapper List
* ------------------------------------------------------------------------------------------------------
* @param          List<Account>  List of Selected Account ,   Set<Id> Account Id Set with Messaging User
* @return         List<AccountWrapper> Account Wrapper List
* ------------------------------------------------------------------------------------------------------ 
*/
    private static List<AccountWrapper> getAccountWrapperList(List<Account> listSelectedAccounts , Set<Id> setAccountIdsWithMessagingUsers){
        
         List<AccountWrapper> listAccountWrappers = new List<AccountWrapper>();
         for(Account acc : listSelectedAccounts){
            listAccountWrappers.add(getAccountWrapperInstance(acc,setAccountIdsWithMessagingUsers));
        }
        return listAccountWrappers;
    }
 
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getAccountWrapperInstance
* @description     Prepare Account Wrapper Instance
* ------------------------------------------------------------------------------------------------------
* @param          Account Account Ins ,   Set<Id> Account Id Set with Messaging User
* @return         List<AccountWrapper> Account Wrapper List
* ------------------------------------------------------------------------------------------------------ 
*/
    
    private static AccountWrapper getAccountWrapperInstance(Account oAccount , Set<Id> setAccountIdsWithMessagingUsers){
        
        AccountWrapper accountWrapperInstance = new AccountWrapper();
        
            accountWrapperInstance.sAccId = oAccount.Id;
            accountWrapperInstance.sAccName = oAccount.Name;
            accountWrapperInstance.sAccPhone = oAccount.Phone;
            accountWrapperInstance.sAccWebsite = oAccount.website;
            if(setAccountIdsWithMessagingUsers.contains(oAccount.Id)){
                accountWrapperInstance.bMessagingUserPresent = true;
                accountWrapperInstance.sEnableOrNot = System.Label.EnabledLabel;
            }
            else{
                accountWrapperInstance.bMessagingUserPresent = false;
                 accountWrapperInstance.sEnableOrNot = System.Label.EnableLabel;
            }
        
        return accountWrapperInstance;
        
    }

    public class AccountWrapper{
        @AuraEnabled
        public String sAccId;
        @AuraEnabled
        public String sAccName;
        @AuraEnabled
        public String sAccPhone ;
        @AuraEnabled
        public String sAccWebsite ;
        @AuraEnabled
        public Boolean bMessagingUserPresent ;
        @AuraEnabled
        public String sEnableOrNot ;
    }
    
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createMessagingUser
* @description     This method created messaging user records 
* ------------------------------------------------------------------------------------------------------
* @param          String Account Id ,   String Account Name , String Account Phone
* @return         
* ------------------------------------------------------------------------------------------------------ 
*/
    
    @AuraEnabled
    public static Boolean createMessagingUser(String sAccId, String sAccName ,String sAccPhone){
        
        MessagingEndUser  oMsgUser = new MessagingEndUser();
        oMsgUser.MessagingPlatformKey = sAccPhone;
        oMsgUser.MessageType = 'WhatsApp';
        oMsgUser.MessagingConsentStatus = 'ExplicitlyOptedIn';
        oMsgUser.Name = sAccName;
        oMsgUser.MessagingChannelId = VFSGLB_Messaging_Channel_Setting__mdt.getInstance('VFSBR_Whatsapp_Msg_Chnl').Channel_Id__c;
        oMsgUser.AccountId = sAccId;
        
        Database.SaveResult oSR = Database.insert(oMsgUser , false);
        if (oSR.isSuccess()) {
          return true;
        }
        else {
            return false;
        }
        
    }
 

}