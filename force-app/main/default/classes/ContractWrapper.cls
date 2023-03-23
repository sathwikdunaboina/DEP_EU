/**
 * Wrapper for easy processing.
 * 
 * @author matei.lunca@fluidogroup.com 2022-07-26 creation
 */
public with sharing class ContractWrapper {
    
	private Contract__c contract;
	
	public ContractWrapper(Contract__c contract) {
		this.contract = contract;
    }

	//according to original VFS CMSAPI_ContractHandler
	//TODO use when migrating CMSAPI_ContractHandler to GC
	public boolean isValid(){
		if(contract == null){
			return false;
		}

		//if there is a contract, write any invalid state to ErrorLog
		if(contract.Account__c == null 
			|| String.isBlank(contract.Account__r.CustomerId__c)
			|| String.isBlank(contract.Account__r.BillingCountryCode)
			
			//TODO add field logic when fields migrated to GC
			//|| String.isBlank(contract.ContractId__c)
			//|| String.isBlank(contract.ContractNumber__c
			) {

			GCErrorLogUtil.createErrorLog('Contract__c valid check',
				'Contract does not contain required fields or relations.',
				null,
				null,
				'ContractWrapper.isValid()',
				toPrettyPrintString(),
				null,
				null,
				'' + contract.Id);
			return false;	
		}

		return true;
	}

	public String toPrettyPrintString(){
		if(contract == null){
			return '[Contract__c is null]';
		}

		String result = '[Contract__c: ';
		result += '\n\t Id = ' + contract.Id;
		result += '\n\t Name = ' + contract.Name;
		//result += '\n\t ContractId = ' + contract.ContractId__c;
		//result += '\n\t ContractNumber = ' + contract.Contract_Number__c;
		result += '\n\t Account = ' + contract.Account__c + ' (' + contract.Account__r.Name + ')';
		result += ']';

		return result;
	}

	public static List<Contract__c> getContracts(List<Id> accountIds){
		List<Contract__c> result =
			[SELECT
				Name, 
				Account__c, 
				Type__c

				//TODO add field logic when fields migrated to GC
				/*Amount_Excluding_Tax__c, 
				Amount_Including_Tax__c, 
				Balance__c, 
				Balloon__c, 
				Business_Area__c, 
				Chassis_Number__c, 
				Contract_Id__c, 
				Contract_Number__c, 
				DealerId__c, 
				Dealer__c, 
				Down_Payment__c, 
				Regulated__c, 
				Remaining_Balance__c, 
				Residual__c, 
				TerminationDate__c, 
				Term__c, 
				
				Start_Date__c, 
				Tax_Amount__c, 
				Vehicle_Registration_Number__c, 
				VIN_Number__c,
				End_Date__c, 
				End_of_Term__c, 
				Equipment_Cost__c, 
				Financed_Amount__c, 
				Legal_Status__c, 
				Net_Investment__c, 
				On_Balance_Sheet__c, 

				CreatedById, 
				CreatedDate, 
				CurrencyIsoCode, 
				LastModifiedById, 
				LastModifiedDate, 
				LastReferencedDate, 
				LastViewedDate,
				SystemModstamp*/
			FROM
				Contract__c
			WHERE
				Account__c IN : accountIds];

		return result;
	}
}