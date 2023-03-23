public with sharing class wrapperQuoteClass {  
    public class wrapperClass {
        public String externalId{get;set;}
        public String countryCode{get;set;}
        public String brand {get;set;}
        public String owner{get;set;}
        public String requestedBy{get;set;}
        public String Source{get;set;}
        public financials financials{get;set;}
        public asset asset{get;set;}
        public dealer dealer{get;set;}
        public customer customer{get;set;}
        public order order{get;set;}
    }
    public class financials {
        public String amount {get;set;}
        public String currencyCode{get;set;}
    }
    public class asset {
        public String axleArrangement{get;set;}
        public String chassisType{get;set;}
        public String engineVersion{get;set;}
        public String VINNumber{get;set;}
        public String tChassis{get;set;}
        public String marketType{get;set;}
        public String assemblyFactoryCode{get;set;}
        public String assemblyFactoryName{get;set;}
    }
    public class dealer{
        public String id{get;set;}
        public String dealerNumber{get;set;}
        public String mainDealerName{get;set;}
        public String salesPersonName{get;set;}
    }
    
    public class customer{
        public String name{get;set;}
        public String address{get;set;}
        public String phone{get;set;}
        public String city{get;set;}
        public String postalCode{get;set;}
        public String countryCode{get;set;}
        public String CMS_ID{get;set;}
    }
    
    public class order{
        public String id{get;set;}
        public String orderNumber{get;set;}
        public String statusDescription{get;set;}
        public String registrationDate{get;set;}
        public String cddDate{get;set;}
        public String disStatusCode{get;set;}
    }
    
}