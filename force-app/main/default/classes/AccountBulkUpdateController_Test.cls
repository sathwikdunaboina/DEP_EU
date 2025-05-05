/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     AccountBulkUpdateController_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com> 
* @Created Date       01-20-2025        
* ------------------------------------------------------------------------------------------
* @description        This class is used to test AccountBulkUpdateController
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class AccountBulkUpdateController_Test {
    
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
        Id iProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales' LIMIT 1][0].Id;
        String sUniqueUserName = 'TestAccountAssigment' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser = new User(Alias = 'tstcs', Email='testAccount@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestAccountAsgMent', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser;
        
        System.runAs(new User(Id = UserInfo.getUserId())){ 
            List<Account> listAccount = new List<Account>();
            for(integer i = 0 ; i <= 20 ; i++){
                Account acc = new Account();
                acc.Name = 'test account'+ i ;
                acc.BillingCountry = 'United Kingdom';
                listAccount.add(acc);
            }
            insert listAccount;
            
        }
    } 
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testAccountBulkUpdateController
* @description     This method is used to test AccountBulkUpdateController class
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/  
    @isTest
    public static void testAccountBulkUpdateController(){
        List<Account> listAccounts = [Select Id , Name FROM Account];
        List<Account> emptyListToUpdate = new List<Account>();
        String sSelectedAccountIds ;
        Boolean transferOpportunityOwners;
        for(Account acc : listAccounts){
            sSelectedAccountIds = acc.Id + '-';
            
        } 
        User oUser = [Select Id,LastName FROM user WHERE LastName='TestAccountAsgMent'];
        Id accountRecordTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Dealer Account').getRecordTypeId();
        Account oTestAccount = new Account();
        oTestAccount.Name = 'Testing Account';
        oTestAccount.BillingCountry = 'United Kingdom';
        oTestAccount.OwnerId = oUser.Id;
        oTestAccount.RecordTypeId = accountRecordTypeID;
        insert oTestAccount;
        
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test Opportunity';
        testOpportunity.StageName = 'Quoted';
        testOpportunity.AccountId = oTestAccount.Id;
        insert testOpportunity;
        
        
        List <Account> testAccounts = new List<Account>{oTestAccount};
            Test.startTest();
        AccountBulkUpdateController.getAccounts(sSelectedAccountIds);
        try{
            AccountBulkUpdateController.getAccounts(null);
        }
        catch(Exception e){ 
        }
        try{
            AccountBulkUpdateController.updateAccounts(null,null);
            AccountBulkUpdateController.updateAccounts(testAccounts,True);
        }
        catch(Exception e){
        }
        AccountBulkUpdateController.searchAccountOwners(oUser.LastName);
        Test.stopTest();
        
    }
}