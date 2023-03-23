@isTest
public class FrancePaymentCalcServiceHandlerTest {
    @TestSetup
    public static void init_data(){
	    FR_Interest_Rate_Lookup__c fr=new FR_Interest_Rate_Lookup__c();
        fr.Brand__c='Renault Trucks';
        fr.Customer_Grade__c='A';
        fr.Segment__c='VI (Heavy)';
        fr.Interest_Rate__c=5.78;
        fr.Terms__c=60;
        insert fr;
    }
     @isTest
    public static void getInterestRate(){
    PaymentAPIRequestData requestData=new PaymentAPIRequestData();
    requestData.assetPrice=250;
    requestData.brand='Renault Trucks';
    requestData.countryCode='FR';
    requestData.customerGrade='A';
    requestData.downPayment=0;
    requestData.interestRate=6.5;
    requestData.residualValue=150;
    requestData.terms=60;
        
    FR_Interest_Rate_Lookup__c rateLookup=[ select Brand__c,Interest_Rate__c,Customer_Grade__c,Segment__c,Terms__c FROM FR_Interest_Rate_Lookup__c WHERE Brand__c =:requestData.brand AND Terms__c=:requestData.terms  AND Customer_Grade__c=:requestData.customerGrade];    
    FrancePaymentCalcServiceHandler calcHandler=new FrancePaymentCalcServiceHandler();
    calcHandler.getInterestRate(requestData);
    }
}