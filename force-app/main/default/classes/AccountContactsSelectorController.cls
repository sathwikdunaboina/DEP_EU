/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     AccountContactsSelectorController
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       24 May 2025
* @Used By            AccountContactsSelector LWC 
* @Test Covered By    AccountContactsSelectorController_Test
* @SystemLayer        Controller
* ------------------------------------------------------------------------------------------
* @description       This class is used for handling business logic for AccountContactsSelector.
* ------------------------------------------------------------------------------------------
*/

public with sharing class AccountContactsSelectorController {
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getAccountsWithContacts
* @description     Gets selected contacts related to accounts
* ------------------------------------------------------------------------------------------------------
* @param          accountIds         List of selected account Ids
* @return         Return list of account with nested contacts
* ------------------------------------------------------------------------------------------------------ 
*/
	 @AuraEnabled(cacheable=true)
  public static List<Account> getAccountsWithContacts(String accountIds) {

	Integer iLastOccurence = accountIds.lastIndexOf('-');
        String sSelectedAccountIdsSanitized = accountIds.left(iLastOccurence)+accountIds.right(accountIds.length()-iLastOccurence-1);
        List<String> listSelectedAccountIds = sSelectedAccountIdsSanitized.split('-');
      
        List<Account> listAccounts =  [ SELECT Id, Name, (SELECT Id, Name, Email FROM Contacts) FROM Account WHERE Id IN :listSelectedAccountIds WITH USER_MODE];
        if(!listAccounts.IsEmpty()){
           return listAccounts;
       }
       else{
           return null;
       }
         
  }
}