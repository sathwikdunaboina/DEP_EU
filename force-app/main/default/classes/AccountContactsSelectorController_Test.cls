/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     AccountContactsSelectorController_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       29 May 2025 
* @SystemLayer        Test
* ------------------------------------------------------------------------------------------
* @description       This class is used for testing AccountContactsSelectorController class
* ------------------------------------------------------------------------------------------
*/ 
@isTest
private class AccountContactsSelectorController_Test {
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/   
    @testSetup static void setUpData() {
        
        System.runAs(new User(Id = UserInfo.getUserId())){ 
            List<Account> listAccount = new List<Account>();
            for(integer i = 0 ; i <= 20 ; i++){
                Account acc = new Account();
                acc.Name = 'test account'+ i ;
                acc.BillingCountry = 'Netherlands';
                acc.phone = '+5541 123456789' + i;
                listAccount.add(acc);
            }
            insert listAccount;
        }
    } 
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testAccountContactsSelectorController
* @description     Used to test AccountContactsSelectorController 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/   
    @isTest
    private static void testAccountContactsSelectorController(){
        
        List<Account> listAccounts = [Select Id , Name FROM Account];
        String sAccountIds = '';
        
        for(Account acc : listAccounts){
            sAccountIds += acc.Id + '-';
        }
            
        
         System.runAs(new User(Id = UserInfo.getUserId())){
            Test.startTest();
            List<Account> listacc =  AccountContactsSelectorController.getAccountsWithContacts(sAccountIds);
                                     AccountContactsSelectorController.getAccountsWithContacts('');
            Test.stopTest();
             
            System.assertEquals(21 , listacc.size() , 'Success' );
           
        }  
        
    }

}