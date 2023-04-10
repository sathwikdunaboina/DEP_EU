/*
* Subject: Wrapper class
* Created by: Aswin balaji
* Date: 20/09/2022, 15:39
* Description: Wrapper class for the quote json structure
* */ 
public with sharing class quoteWrapperClass {
    public class wrapperClass {
        public String externalId;	//uniqueid
        public String countryCode;	//oppList[0].Account.BillingCountryCode
        public String brand;	//foList[0].Brand__c
        public String owner;	//ownerObj[0].FederationIdentifier__c
        public String requestedBy;	//userFederationID
        public String source;	//Sales Connect
        public String version;
        public dealer dealer;
        public customer customer;
        public List<order> order;
    }
    public class asset {
        public String axleArrangement;	//foList[0].Axle_Arrangement__c
        public String chassisType;	//foList[0].Chassis_Type__c
        public String engineVersion;	//foList[0].Engine_Version__c
        public String VINNumber;	//foList[0].VIN_Number__c
        public String tChassis;	//foList[0].T_Chassis__c
        public String marketType;	//foList[0].Market_Type_1_5__c
        public String assemblyFactoryCode;	//foList[0].Assembly_Factory_Code__c
        public String assemblyFactoryName;	//foList[0].Assembly_Factory_Name__c
        public String id;	//foList[0].Dealer_Id__c
    }
    	public class order {
		public String OpportunityId;	//0065r000005L8x3AAC
		public String Orderid;	//VT_OM-20145660
		public String orderNumber;	//22452019698
		public String statusDescription;	//Confirmed
		public String registrationDate;	//2021-04-27 00:00:00
		public String cddDate;	//2021-12-15 00:00:00
		public String disStatusCode;	//ORDERED
        public financials financials;
        public asset asset;
	}
		public class financials {
		public String currencyCode;	//EUR
		public String amount;	//12333
	}
        public class dealer {
        public String id;	//foList[0].Dealer_Id__c
        public String dealerNumber;	//foList[0].Dealer_Number__c
        public String mainDealerName;	//foList[0].Main_Dealer_Name__c
        public String salesPersonName;	//foList[0].Sales_Person_Name__c
    }
    public class customer {
        public String name;	//foList[0].End_Customer_Name__c
        public String address;	//foList[0].End_Customer_Address1__c
        public String phone;	//foList[0].End_Customer_Phone__c
        public String city;	//foList[0].End_Customer_City__c
        public String postalCode;	//foList[0].End_Customer_Postal_Code__c
        public String countryCode;	//oppList[0].Account.BillingCountryCode
        public String CMS_ID;	//customerCmsId
    }
    public static quoteWrapperClass parse(String json) {
    return (quoteWrapperClass) System.JSON.deserialize(json, quoteWrapperClass.class);
	}
}