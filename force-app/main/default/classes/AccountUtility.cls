
// Test 


public with sharing class AccountUtility {

    public static String getAccountCategory(Account acc) {
        if (acc == null || String.isBlank(acc.Name)) {
            return 'UNKNOWN';
        }

        if (acc.Name.startsWith('VIP')) {
            return 'PREMIUM';
        }


        return 'STANDARD';
    }
}