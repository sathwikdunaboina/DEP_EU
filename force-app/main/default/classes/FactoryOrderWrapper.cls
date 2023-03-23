/**
 * Wrapper for easy processing.
 * 
 * @author matei.lunca@fluidogroup.com 2022-07-26 creation
 */
public with sharing class FactoryOrderWrapper {
    
	private FactoryOrder__c fo;

    public FactoryOrderWrapper(FactoryOrder__c fo) {
		this.fo = fo;
    }

	public static List<FactoryOrderWrapper> wrapList(List<FactoryOrder__c> foList){
		List<FactoryOrderWrapper> foObjs = new List<FactoryOrderWrapper>();
		for(FactoryOrder__c fo : foList){
			foObjs.add(new FactoryOrderWrapper(fo));
		}

		return foObjs;
	}

	public String toPrettyPrintString(){
		if(fo == null){
			return '[FactoryOrder is null]';
		}

		String result = '[FactoryOrder: ';
		result += '\n\t Id = ' + fo.Id;
		result += '\n\t Name = ' + fo.Name;
		result += '\n\t Brand = ' + fo.Brand__c;
		result += '\n\t DealerId = ' + fo.DealerId__c;
		result += '\n\t MainDealerName = ' + fo.MainDealerName__c;
		result += ']';

		return result;
	}

	public static List<FactoryOrder__c> getOrdersByOpportunity(List<Opportunity> opps){
		if(opps == null || opps.isEmpty()){
			return new List<FactoryOrder__c>();
		}

		List<Id> orderIdsFromOpps = new List<Id>();
		for(Opportunity o : opps){
			if(o.FactoryOrder__c != null){
				orderIdsFromOpps.add(o.FactoryOrder__c);
			}
		}

		List<FactoryOrder__c> result =
		[SELECT
			Name, 
			OrderId__c, 
			OrderStatusDescription__c, 
			Country__c, 

			DealerId__c, 
			DealerNumber__c, 
			MainDealerName__c, 
			SalesPersonName__c, 

			Brand__c, 
			
			AssemblyFactoryCode__c, 
			AssemblyFactoryName__c, 
			AxleArrangement__c, 
			CDDDate__c, 
			ChassisType__c, 
			ContactLastName__c, 
			DisStatusCode__c, 
			EndCustomerAddress1__c, 
			EndCustomerCity__c, 
			EndCustomerName__c, 
			EndCustomerPhone__c, 
			EndCustomerPostalCode__c, 
			EngineVersion__c, 
			FORegistrationDate__c, 
			HP__c, 
			MarketType15__c, 
			Serial__c, 
			TChassis__c, 
			VehicleStatus__c, 
			VINNumber__c,

			CreatedById, 
			CurrencyIsoCode
		FROM
			FactoryOrder__c
		WHERE Id IN : orderIdsFromOpps];

		return result;
	}
	
}