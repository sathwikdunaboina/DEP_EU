public class Test {
    @AuraEnabled public String v {get; set;}
    @AuraEnabled public String Quote_ID {get; set;}
    @AuraEnabled public List<hits> hits {get; set;}
    
    public class hits {
    @AuraEnabled public String type {get; set;}
    @AuraEnabled public data data {get; set;}
    }
    
    public class data {
    @AuraEnabled public String QuoteID {get; set;}
    @AuraEnabled public String Account_Name {get; set;}
    @AuraEnabled public String BusinessArea {get; set;}
    @AuraEnabled public String FactoryOrderOpprotunity {get; set;}
    @AuraEnabled public String DealerName {get; set;}
    @AuraEnabled public Double QouteAmount {get; set;}
    @AuraEnabled public Double QuoteStatus {get; set;}
    @AuraEnabled public String CreationDate {get; set;}
    }
    }