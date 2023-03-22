@IsTest
public class PortalCampaignCarouselControllerTest {
    
    //Setup
    @TestSetup
    static void setup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User owner = new User(
            ProfileId = profileObj.Id,
            UserRoleId = portalRole.Id,
            Username = 'admin@testclass.org' + System.currentTimeMillis(),
            Alias = 'admin',
            isActive = TRUE,
            Email = 'admin@testclass.org',
            EmailEncodingKey = 'UTF-8',
            Lastname = 'admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );
        insert owner;
        
        System.runAs(owner) 
        {
            insert new VFS_Campaign__c (Name ='Test Campaign', 
                                        Country__c = 'Italy', 
                                        Start_Date__c = System.today()-10, 
                                        End_Date__c = System.today() + 10, 
                                        Active__c = TRUE, 
                                        Brand__c = 'Volvo', 
                                        Description__c ='<b>Sample Text</b>' );
            
            Account accObj = new Account();
            accObj.Name = 'testAcc';
            accObj.CustomerID__c = 'test123'; 
            accObj.Branding__c = 'Volvo';
            insert accObj;
            
            Contact conObj = new Contact();
            conObj.LastName = 'testCon';
            conObj.AccountId = accObj.Id;
            insert conObj;
            
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Self Service Portal User'];
            User portalUser = new User(
                ProfileId = portalProfile.Id,
                LastName = 'last',
                Email = 'PortalCampaignCarouselControllerTest@testclass.org',
                Username = 'PortalCampaignCarouselControllerTest@testclass.org' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'portal',
                ContactId = conObj.Id,
                Country = 'Italy',
                TimeZoneSidKey = 'America/Chicago',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
            insert portalUser;
        } 
    }
    //Do
    public static testMethod void fetchActiveCampaignsTest(){
        User portalUser = [SELECT Id FROM User WHERE Email = 'PortalCampaignCarouselControllerTest@testclass.org' LIMIT 1];
        system.runAs(portalUser){
            VFS_Campaign__c[] camps = PortalCampaignCarouselController.fetchActiveCampaigns();
            //Assert
            system.assert(camps != null && camps.size() == 1, 'Campaigns are not fetched correctly');
        }
    }
    
}