/**
 * Wrapper for easy processing.
 * 
 * @author matei.lunca@fluidogroup.com 2022-07-29 creation
 */
public with sharing class OpportunityWrapper {
    
	private Opportunity opp;
	
	public OpportunityWrapper(Opportunity opp) {
		this.opp = opp;
    }

	public static List<Opportunity> getOpportunities(List<String> oppIds){
		List<Opportunity> result = [SELECT
			AccountId, 
			Amount, 
			CampaignId, 
			CloseDate, 
			ContactId, 
			ContractId, 
			CurrencyIsoCode, 
			Description, 
			
			FactoryOrderCustomer__c, 
			FactoryOrder__c, 
			Fiscal, 
			FiscalQuarter, 
			FiscalYear, 
			ForecastCategory, 
			ForecastCategoryName, 
			HasOpenActivity, 
			HasOpportunityLineItem, 
			HasOverdueTask, 
			IsClosed,  
			IsWon, 
			LeadSource, 
			Name, 
			NextStep, 
			OwnerId, 
			Pricebook2Id, 
			Probability, 
			PushCount, 
			QuoteId__c, 
			QuoteUrl__c, 
			
			StageName, 
			SyncedQuoteId, 
			SystemModstamp, 
			Type, 

			CreatedById, 
			CreatedDate, 
			LastActivityDate, 
			LastAmountChangedHistoryId, 
			LastCloseDateChangedHistoryId, 
			LastModifiedById, 
			LastModifiedDate, 
			LastReferencedDate, 
			LastStageChangeDate, 
			LastViewedDate

			//TODO migrate to package when used
			/*Axle_Arrangement__c, 
			Budget_Confirmed__c, 
			Chassis_Type__c, 
			Dealer_Delivery_Date__c, 
			Dealer_Name__c, 
			Discovery_Completed__c, 
			Engine_Version__c, 
			Loss_Reason__c, 
			Lost_Reason__c, 
			ROI_Analysis_Completed__c, 
			Sales_Person_Name__c, 
			T_Chassis__c, 
			VFS_Connect_Quote__c*/
		FROM
			Opportunity];

		return result;
	}
}