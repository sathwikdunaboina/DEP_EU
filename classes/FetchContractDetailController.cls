public class FetchContractDetailController {
	@AuraEnabled
    public static Boolean getContractDetail(Id contractId){
        return CMSAPI_ContractHandler.fetchContractDetail(contractId);
    }
}