@IsTest
private class AccountUtilityTest {
 
    @IsTest
    static void testPremiumCategory() {
 
        Account acc = new Account(
            Name = 'VIP Technologies'
        );
 
        String result = AccountUtility.getAccountCategory(acc);
 
        System.assertEquals('PREMIUM', result);
    }
 
    @IsTest
    static void testStandardCategory() {
 
        Account acc = new Account(
            Name = 'Acme Corp'
        );
 
        String result = AccountUtility.getAccountCategory(acc);
 
        System.assertEquals('STANDARD', result);
    }
}