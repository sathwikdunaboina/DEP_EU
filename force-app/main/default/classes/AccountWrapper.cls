/**
 * Wrapper for easy processing.
 * 
 * @author matei.lunca@fluidogroup.com 2022-07-25 creation
 */
public with sharing class AccountWrapper {
    
	private Account acc;

	public AccountWrapper(Account acc) {
		this.acc = acc;
    }

	//AccountSource,AnnualRevenue,BillingAddress,BillingCity,BillingCountry,BillingCountryCode,BillingGeocodeAccuracy,BillingLatitude,BillingLongitude,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Branding__c,CompanyRegistrationNumber__c,Contract_Amendments_In_Progress__c,Contract_API_Last_Called__c,CreatedById,CreatedDate,CurrencyIsoCode,CustomerID__c,Customer_Number__c,Description,FiscalCode__c,Industry,Invoices_Fetched_On__c,IsCustomerPortal,IsDeleted,IsPartner,Latest_Contract_Start_Date__c,MasterRecordId,No_of_contracts__c,NumberOfEmployees,OwnerId,Ownership,ParentId,ShippingAddress,ShippingCity,ShippingCountry,ShippingCountryCode,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStateCode,ShippingStreet,Sic,SicDesc,VATNumber__c
	public String toPrettyPrintString(){
		if(acc == null){
			return '[Account is null]';
		}

		String result = '[Account: ';
		result += '\n\t Id = ' + acc.Id;
		result += '\n\t Name = ' + acc.Name;

		if(String.isNotBlank(acc.Type)){
			result += '\n\t Type = ' + acc.Type;
		}

		if(acc.TerritoryManager__c != null){
			result += '\n\t TerritoryManager = ' + acc.TerritoryManager__c;
				//+ ' (' + acc.TerritoryManager__r.Name + ' with TM User = ' + acc.TerritoryManager__r.User_c.Name + ')';
		}
		
		if(String.isNotBlank(acc.AccountNumber)){
			result += '\n\t AccountNumber = ' + acc.AccountNumber;
		}

		if(acc.RecordTypeId != null){
			result += '\n\t RecordTypeId = ' + acc.RecordTypeId + ' (' + acc.RecordType.Name + ')';
		}
		
		result += ']';

		return result;
	}

	public static void prettyPrintTestData(List<Account> accs){
		if(GCTestUtil.LOG_TESTS){
			for(Account a : accs){
				System.debug( (new AccountWrapper(a)).toPrettyPrintString() );
			}
		}
	}
}