@isTest
private class AccountUpdateUserCountryTriggerTest {
 
    @isTest
    static void testAccountInsert() {
 
        User currentUser = [
            SELECT Id, Country
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
 
        Account acc = new Account(
            Name = 'Test Account'
        );
 
        Test.startTest();
        insert acc;
        Test.stopTest();
 
        Account result = [
            SELECT BillingCountry
            FROM Account
            WHERE Id = :acc.Id
        ];
 
        System.assertEquals(currentUser.Country, result.BillingCountry);
    }
}