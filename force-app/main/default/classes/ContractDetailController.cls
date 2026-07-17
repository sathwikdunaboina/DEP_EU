public with sharing class ContractDetailController {
    @AuraEnabled
    public static void getContractDetail(Id recordId){
        Object isAlreadyFetchedInCurrentSession = CXPCacheManager.getFromSession(recordId);
        //Make API call only when its not already fetched
        if (isAlreadyFetchedInCurrentSession ==null || ! (Boolean)isAlreadyFetchedInCurrentSession){
            Boolean success = CMSAPI_ContractHandler.fetchContractDetail(recordId);
            CXPCacheManager.putToSession(recordId, success);
        }
    }
}