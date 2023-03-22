@isTest
private class complianceFooterTest {
    @TestSetup
    static void setup() 
    {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User owner = new User(
            ProfileId = profileObj.Id,
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
        insert owner;
        
        System.runAs(owner) 
        {
            Account accObj = new Account();
            accObj.Name = 'testAcc';
            accObj.CustomerID__c = 'test123';           
            insert accObj;
            
            Contact conObj = new Contact();
            conObj.LastName = 'testCon';
            conObj.AccountId = accObj.Id;
            insert conObj;
            
            ContentVersion contentVersionObj= new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Test Content Data'),
                IsMajorVersion = true
            );
            insert contentVersionObj;
            
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id =: contentVersionObj.Id];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = accObj.id;
            contentlink.ShareType= 'V';
            contentlink.ContentDocumentId = testcontent.ContentDocumentId;
            insert contentlink;
            
            ContentDistribution contDistObj = new ContentDistribution();
            contDistObj.Name = 'Test';
            contDistObj.ContentVersionId = contentVersionObj.id;
            contDistObj.PreferencesAllowViewInBrowser= true;
            contDistObj.PreferencesLinkLatestVersion = true;
            contDistObj.PreferencesNotifyOnVisit = false;
            contDistObj.PreferencesPasswordRequired = false;
            contDistObj.PreferencesAllowOriginalDownload = true;
            insert contDistObj;
            
            Footer_link__c footerLinkObj = new Footer_link__c();
            footerLinkObj.Name = 'footer1';
            footerLinkObj.Country__c = 'Italy';
            footerLinkObj.Language__c = 'it';
            footerLinkObj.Document_Link__c = testContent.ContentDocumentId;
            footerLinkObj.Type__c = 'Local';
            insert footerLinkObj;
            
            Footer_link__c footerLinkGDPRObj = new Footer_link__c();
            footerLinkGDPRObj.Name = 'footer2';
            footerLinkGDPRObj.Country__c = 'Italy';
            footerLinkGDPRObj.Language__c = 'it';
            footerLinkGDPRObj.Document_Link__c = testContent.ContentDocumentId;
            footerLinkGDPRObj.Type__c = 'GDPR';
            insert footerLinkGDPRObj;
            
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name='Self Service Portal User' Limit 1];
            User portalUser = new User(
                ProfileId = portalProfile.Id,
                LastName = 'last',
                Email = 'testuser@testclass.org',
                Username = 'testuser@testclass.org' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Country='Italy',
                Alias = 'portal',
                ContactId = conObj.Id,
                TimeZoneSidKey = 'America/Chicago',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'it',
                LocaleSidKey = 'en_GB'
            );
            insert portalUser;
        }
    }
    
    static testMethod void getPublicLinksTest(){
        User portalUser = [SELECT Id FROM User WHERE Email = 'testuser@testclass.org' LIMIT 1];
        System.runAs(portalUser){
            List<Footer_link__c> footerLinkList = complianceFooter.getPublicLinks();
            System.assert((footerLinkList.size() > 0));
        }
    }
}