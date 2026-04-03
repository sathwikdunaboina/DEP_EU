/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     OnAccountNameorOwnerChangeSetFlags_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       21-1-2026 
* @Used By            On Account Name or Owner Change Set Flags Flow
* ------------------------------------------------------------------------------------------
* @description        When Account Name or Owner is changed the corresponding flag fields on account should be set to true
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class OnAccountNameorOwnerChangeSetFlags_Test{
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @testSetup 
    static void setupmethod(){
        Id iProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales' LIMIT 1][0].Id;
        String sUniqueUserName = 'TestAccountAssigment' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser1 = new User(Alias = 'tstcs', Email='testcaseassignment@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestAccountAsgMent', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueUserName);
        insert oTestUser1;
        
        String sUniqueName = 'TestAccountCreation' + DateTime.now().getTime() + '@testorg.com';
        User oTestUser2 = new User(Alias = 'tstcs', Email='testaccountcreation@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='TestAccountCreaTion', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_GB', ProfileId = iProfileId,TimeZoneSidKey='Europe/Paris',
                                  Country = '',UserName=sUniqueName);
        insert oTestUser2;
        
        System.runAs(oTestUser1){
            Account oTestAccount = new Account();
            oTestAccount.Name = 'Test Account';
            oTestAccount.IsNameChanged__c = false;
            oTestAccount.BillingCountry = 'United Kingdom';
            insert oTestAccount;
            
            Account oTestAccountOwnerChange = new Account();
            oTestAccountOwnerChange.Name = 'Owner Test Account';
            oTestAccountOwnerChange.IsOwnerChanged__c = false;
            oTestAccountOwnerChange.BillingCountry = 'United Kingdom';
            oTestAccountOwnerChange.CustomerID__c = 'GB-67890';
            oTestAccountOwnerChange.OwnerId = oTestUser1.Id;
            insert oTestAccountOwnerChange;
            
        }
        
    }
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     updateAccountName
* @description     To cover the flow elements which Updates the IsNameChanged__c field
* ------------------------------------------------------------------------------------------------------
*/
    @isTest
    static void updateAccountName(){
        Account createdAccount = [SELECT Id,Name FROM Account WHERE Name='Test Account'];
        Test.StartTest();
        createdAccount.Name = 'New Test Account';
        update createdAccount;
        Account updatedAccount = [SELECT Id,IsNameChanged__c FROM Account WHERE Name='New Test Account'];
        System.assertEquals(true,updatedAccount.IsNameChanged__c);
        Test.StopTest();
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     updateAccountOwner
* @description     To cover the flow elements which Updates the IsOwnerChanged__c field
* ------------------------------------------------------------------------------------------------------
*/
   @isTest
    static void updateAccountOwner(){
        Account createdAccount = [SELECT Id,Name,OwnerId FROM Account WHERE Name='Owner Test Account'];
        User retrieveUser = [SELECT Id,LastName FROM User WHERE LastName = 'TestAccountCreaTion'];
        Test.StartTest();
        createdAccount.OwnerId = retrieveUser.Id;
        system.debug(retrieveUser.LastName +'NewOwner');
        update createdAccount;
        Account updatedAccount = [SELECT Id,IsOwnerChanged__c FROM Account WHERE Name='Owner Test Account'];
        System.assertEquals(true,updatedAccount.IsOwnerChanged__c);
        Test.StopTest();
    }

}