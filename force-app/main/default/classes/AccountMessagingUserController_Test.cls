/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     AccountMessagingUserController_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       01-20-2025        
* ------------------------------------------------------------------------------------------
* @description        This class is used to test AccountMessagingUserController
* ------------------------------------------------------------------------------------------
*/
@isTest
private class AccountMessagingUserController_Test { 
    
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
* @Method Name     testAccountMessagingUserController
* @description     This method is used to test AccountMessagingUserController class
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
    @isTest
    private static void testAccountMessagingUserController(){
        List<Account> listAccounts = [Select Id , Name FROM Account];
        String sSelectedAccountIds ;
        for(Account acc : listAccounts){
            sSelectedAccountIds = acc.Id + '-';
        }
        
        User oUser = [Select Id FROM user LIMIT 1];

        System.runAs(new User(Id = UserInfo.getUserId())){
            Test.startTest();
            AccountMessagingUserController.getAccountMessagingUserDetails(sSelectedAccountIds);
            Boolean result = AccountMessagingUserController.createMessagingUser(listAccounts[0].Id , 'test account' , '+5541 1234567');
            AccountMessagingUserController.createMessagingUser(listAccounts[0].Id , 'test account' , null);
            
            Test.stopTest();
            System.assertEquals(true , result , 'Success' );
        }        
    }

}