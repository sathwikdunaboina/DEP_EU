public class loginPage {
    public static void createAccount() {
        Account newAccount = new Account(
            Name = 'My New Account',
            BillingCountry = 'United Kingdom'
        );
        insert newAccount;
    }
}