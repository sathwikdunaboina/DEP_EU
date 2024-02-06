@isTest
public class FOCurrencyUpdateFlow_Test {

    static testMethod void FOCurrencyUpdate_UK() {
        Factory_Order__c obj = insertFO();
        obj.Country__c = 'UK';
        Insert obj;
    }

    static testMethod void FOCurrencyUpdate_DK() {
        Factory_Order__c obj = insertFO();
        obj.Country__c = 'DK';
        Insert obj;
    }

    static testMethod void FOCurrencyUpdate_Swiss() {
        Factory_Order__c obj = insertFO();
        obj.Country__c = 'CH';
        Insert obj;
    }

    static testMethod void FOCurrencyUpdate_Pol() {
        Factory_Order__c obj = insertFO();
        obj.Country__c = 'PL';
        Insert obj;
    }

    static testMethod void FOCurrencyUpdate_Sweden() {
        Factory_Order__c obj = insertFO();
        obj.Country__c = 'SE';
        Insert obj;
    }

    static testMethod void FOCurrencyUpdate_Norway() {
        Factory_Order__c obj = insertFO();
        obj.Country__c = 'NO';
        Insert obj;
    }


    private static Factory_Order__c insertFO() {

        Factory_Order__c obj = New Factory_Order__c();
        obj.Name = 'Test Factory Order';
        obj.Order_Status_Description__c = 'Confirmed';
        obj.Order_Id__c = '1234';
        // Insert obj;;
        return obj;       
      }
}