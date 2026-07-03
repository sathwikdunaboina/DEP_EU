@isTest
private class AccountUpdateUserCountryTriggerTest {
    
    @testSetup
    static void setupData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@vfstest.com',
            Username = 'testuser' + Math.random() + '@vfstest.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'Europe/London',
            LocaleSidKey = 'en_GB',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            Country = 'United Kingdom'
        );
        insert testUser;
        
        User integrationUser = new User(
            FirstName = 'Integration',
            LastName = 'User',
            Email = 'integrationuser@vfstest.com',
            Username = 'integrationuser' + Math.random() + '@vfstest.com',
            Alias = 'iuser',
            TimeZoneSidKey = 'Europe/London',
            LocaleSidKey = 'en_GB',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            Country = 'Switzerland'
        );
        insert integrationUser;
    }
    
    @isTest
    static void testBillingCountryAutoPopulated() {
        User testUser = [
            SELECT Id, Country
            FROM User
            WHERE FirstName = 'Test' AND LastName = 'User'
            AND Email = 'testuser@vfstest.com'
            LIMIT 1
        ];
        
        System.runAs(testUser) {
            Account acc = new Account(Name = 'Test Account');
            
            Test.startTest();
            insert acc;
            Test.stopTest();
            
            Account result = [SELECT BillingCountry FROM Account WHERE Id = :acc.Id];
            System.assertEquals(
                testUser.Country,
                result.BillingCountry,
                'BillingCountry should be auto populated from running user country'
            );
        }
    }
    
    @isTest
    static void testBillingCountryNotOverwritten() {
        User testUser = [
            SELECT Id FROM User
            WHERE Email = 'testuser@vfstest.com'
            LIMIT 1
        ];
        
        System.runAs(testUser) {
            Account acc = new Account(
                Name = 'Test Account',
                BillingCountry = 'Germany'
            );
            
            Test.startTest();
            insert acc;
            Test.stopTest();
            
            Account result = [SELECT BillingCountry FROM Account WHERE Id = :acc.Id];
            System.assertEquals(
                'Germany',
                result.BillingCountry,
                'BillingCountry should not be overwritten if already set'
            );
        }
    }
    
    @isTest
    static void testIntegrationUserBypassed() {
        User integrationUser = [
            SELECT Id FROM User
            WHERE Email = 'integrationuser@vfstest.com'
            LIMIT 1
        ];
        
        System.runAs(integrationUser) {
            Account acc = new Account(Name = 'Integration Test Account');
            
            Test.startTest();
            insert acc;
            Test.stopTest();
            
            Account result = [SELECT BillingCountry FROM Account WHERE Id = :acc.Id];
            System.assertEquals(
                null,
                result.BillingCountry,
                'BillingCountry should remain null for Integration User'
            );
        }
    }
}