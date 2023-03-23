public class searchQuotewrapper {
    @AuraEnabled public String v {get; set;}
    @AuraEnabled public String quote_ID {get; set;}
    @AuraEnabled public List<hits> hits {get; set;}
    
    public class hits {
    @AuraEnabled public String type {get; set;}
    @AuraEnabled public data data {get; set;}
    }
    
    public class data {
    @AuraEnabled public String quoteID {get; set;}
    @AuraEnabled public String accountName {get; set;}
    @AuraEnabled public String businessArea {get; set;}
    @AuraEnabled public String factoryOrderOpprotunity {get; set;}
    @AuraEnabled public String dealerName {get; set;}
    @AuraEnabled public Double qouteAmount {get; set;}
    @AuraEnabled public Double quoteStatus {get; set;}
    @AuraEnabled public String creationDate {get; set;}
    }
    }