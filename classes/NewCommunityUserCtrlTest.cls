@isTest
public class NewCommunityUserCtrlTest {
    @testSetup
    public static void doSetup(){
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User accountOwner = new User(
            ProfileId = profile1.Id,
            UserRoleId = portalRole.Id,
            Username = 'admin@testclass.org' + System.currentTimeMillis(),
            Alias = 'admin',
            Email = 'admin@testclass.org',
            EmailEncodingKey = 'UTF-8',
            Lastname = 'admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );
        insert accountOwner;
        
        System.runAs(accountOwner)
        {
            Account testAccount = new Account(Name = 'testaccount');
            testAccount.CustomerID__c = '00706260056' ;
            insert testAccount;         
            
            Contact testContact = new Contact(LastName = 'testcontact',
                                              Accountid = testAccount.id);
            insert testContact;
            
            insert new Welcome_Mail_Info__c(Name = 'IT', Country__c = 'Italy', Email__c = 'abc@italy.com', Phone__c = '1234567891');
        }
        
        String testUserProfile = [SELECT id FROM Profile WHERE Name = 'Self Service Portal User' LIMIT 1].id;
        
        User testUser = new User(ProfileId = testUserProfile,
                                 Contactid = [SELECT id FROM Contact WHERE LastName = 'testcontact' LIMIT 1].id,
                                 LastName = 'testuser',
                                 Email = 'testuser@test.com',
                                 Username = 'testuser@test.com',
                                 CompanyName = 'TEST',
                                 Country = 'Italy',
                                 Title = 'title',
                                 Alias = 'alias',
                                 TimeZoneSidKey = 'America/Los_Angeles',
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_US'); 
        insert testUser;
    }
    
    @isTest
    public static void doTest(){
        Test.StartTest();
        NewCommunityUserController contObj = new NewCommunityUserController();
        contObj.newUserId = [SELECT Id FROM User WHERE Lastname = 'testuser' LIMIT 1].Id;
        System.assertEquals(contObj.newUserName,'testuser');
        System.assertEquals(contObj.newUserUsername,'testuser@test.com');
        System.assertEquals(contObj.newUserLanguage,'en_US');
        System.assertEquals(contObj.newUserPhone,'1234567891');
        System.assertEquals(contObj.newUserEmail,'abc@italy.com');
        Test.StopTest();
    }    
}