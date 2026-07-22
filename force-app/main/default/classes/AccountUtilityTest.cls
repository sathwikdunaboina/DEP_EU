@IsTest
private class AccountUtilityTest {

    @IsTest
    static void testGetAccountCategory() {

        Account acc = new Account(Name = 'Acme Corp');

        Test.startTest();
        String result = AccountUtility.getAccountCategory(acc);
        Test.stopTest();

        System.assertEquals('STANDARD', result);
    }

    @IsTest
    static void testGetAccountCategoryNull() {

        Test.startTest();
        String result = AccountUtility.getAccountCategory(null);
        Test.stopTest();

        System.assertEquals('UNKNOWN', result);
    }
}