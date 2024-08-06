public class MyAccountCntrlr {
    @AuraEnabled
    public static Account getAccount(){
        String userId = UserInfo.getUserId();
        Try{
          
            User userObj = [SELECT Id, AccountId FROM User WHERE Id=: userId ];

            Account acct = [SELECT Id, Name, CompanyRegistrationNumber__c,Phone,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry 
                        FROM Account WHERE Id =: userObj.AccountId ];
            if(userObj.AccountId != null)
            {
                return acct; 
            }
            else 
            {
                return null;
            }
        }catch (Exception ex) {
            
            throw new AuraHandledException(ex.getMessage()+' '+ex.getCause()+' '+ex.getLineNumber()+' '+ex.getStackTraceString());
        }
    }
}