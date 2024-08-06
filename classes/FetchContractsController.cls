public class FetchContractsController {
	@AuraEnabled
    public static void fetchContractsFromAPI(Id id, String sObjectName){
        if('Account'.equalsIgnoreCase(sObjectName)){
            
        } else if ('Case'.equalsIgnoreCase(sObjectName)){
            
        }
    }
}