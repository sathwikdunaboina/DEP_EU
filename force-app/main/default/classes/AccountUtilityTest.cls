@IsTest
private class AccountUtilityTest {

    @IsTest

    static void testGetAccountCategory() {

        Account acc = new Account(Name = 'Acme Corp');

        Test.startTest();

    static void testPremiumCategory() {
 
        Account acc = new Account(
            Name = 'VIP Technologies'
        );

        String result = AccountUtility.getAccountCategory(acc);


        Test.stopTest();

        System.assertEquals('STANDARD', result);

 
        System.assertEquals('PREMIUM', result);
    }

    @IsTest


    static void testGetAccountCategoryNull() {

        Test.startTest();
        String result = AccountUtility.getAccountCategory(null);
        Test.stopTest();

        System.assertEquals('UNKNOWN', result);


    static void testStandardCategory() {
 
        Account acc = new Account(
            Name = 'Acme Corp'
        );
 
        String result = AccountUtility.getAccountCategory(acc);
 
        System.assertEquals('STANDARD', result);
    }
}