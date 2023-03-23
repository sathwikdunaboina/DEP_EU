global with sharing class FrancePaymentCalcServiceHandler implements CalculatorAPI.IPaymentCalculatorServiceHandler{
    global Decimal getInterestRate(CalculatorAPI.PaymentAPIRequestData paymentAPIRequestData){
        setDefaultValues(paymentAPIRequestData);
        String brand = paymentAPIRequestData.brand;
        Integer terms = paymentAPIRequestData.terms;
        String segment = paymentAPIRequestData.segment;
        String customerGrade = paymentAPIRequestData.customerGrade;
        Decimal interestRate = 0;
        String query='select Interest_Rate__c FROM FR_Interest_Rate_Lookup__c WHERE Brand__c = :brand AND Terms__c = :terms';
        query += ' AND Customer_Grade__c = :customerGrade';
        if(String.isNotBlank(segment)){
            query += ' AND Segment__c =:segment';
        }
        List<FR_Interest_Rate_Lookup__c> interestRateLookup = database.query(query);
        if(interestRateLookup.size() > 0){
            interestRate = interestRateLookup[0].Interest_Rate__c;
        }
        return interestRate;
    }

    private void setDefaultValues(CalculatorAPI.PaymentAPIRequestData paymentAPIRequestData){
        String brand = paymentAPIRequestData.brand;
        if(String.isBlank(paymentAPIRequestData.segment)){
            if(System.Label.VCE_Brand == brand){
                paymentAPIRequestData.segment = System.Label.VCEDefaultSegment;
            }else if(System.Label.RT_Brand == brand){
                paymentAPIRequestData.segment = System.Label.RTDefaultSegment;
            }
        }
        if(String.isBlank(paymentAPIRequestData.customerGrade)){
            paymentAPIRequestData.customerGrade = System.Label.FRDefaultCustomerGrade;
        }
    }
}