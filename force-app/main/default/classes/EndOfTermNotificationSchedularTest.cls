@isTest
public class EndOfTermNotificationSchedularTest {
    @isTest
    public static void setup(){
        //Create Account
        Account accObj = new Account();
        accObj.Name = 'testAcc';
        accObj.CustomerID__c = 'test123';
        accObj.Billingcountry = 'United Kingdom';
        insert accObj;
        
        //Create Contract
        List<Contract__c> cList = new List<Contract__c>();
        Contract__c contObj = new Contract__c();
        contObj.Account__c = accObj.Id;
        contObj.End_Date__c = System.today() + 90;
        contObj.Contract_Id__c = 'cont1234';
        contObj.Type__c = 'End of term query';
        insert contObj;
        cList.add(contObj);
        
        //Create custom setting
        End_of_Term_Notification_Settings__c eot = new End_of_Term_Notification_Settings__c();
        eot.Number_of_days_for_case_creation__c='90';
        eot.Contract_Types_to_exclude__c= '\''+ 'Finance Lease' + '\'';
        eot.Country_Code__c = 'GB';
        insert eot;

        Test.startTest();
        EndOfTermNotificationSchedular endTerm= new EndOfTermNotificationSchedular();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test', sch, endTerm);
        Test.stopTest(); 
        
        //Assert
        System.assert(cList.size()>0);
        System.assertEquals(contObj.End_Date__c, System.today() + 90);
        
    }
}