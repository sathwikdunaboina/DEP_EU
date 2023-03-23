/**
 * Wrapper for easy processing.
 * 
 * @author matei.lunca@fluidogroup.com 2022-07-29 creation
 */
public class InvoiceWrapper {

	private Invoice__c inv;

    public InvoiceWrapper(Invoice__c inv) {
		this.inv = inv;
    }

	//TODO enable when Invoice__c is moved to GC
	/*public static List<Invoice__c> getInvoices(List<String> invIds){
		List<Invoice__c> result = [SELECT
			Name, 	
			Account__c, 
			Cleared_Amount__c, 

			Status__c, 
			Type__c
			SubType__c, 
			Reference__c, 

			DueDate__c, 
			FetchedOn__c, 
			InvoiceAmount__c, 
			InvoiceDate__c, 
			InvoiceId__c, 
			
			CurrencyIsoCode, 
			CreatedById, 
			CreatedDate, 
			LastModifiedById, 
			LastModifiedDate, 
			SystemModstamp, 
		FROM
			Invoice__c];

			return result;
		}
	}*/
}