@RestResource(urlMapping='/contracts/*')
global without sharing class VFS_VT_ContractRESTSERVICE {
    
    global class ContractPageResponse {
        public List<Contract__c> records = new List<Contract__c>();
        public Integer pageSize; // requesting size via request
        public Integer recordSize; // to show the current page size
        //public String recordId; // To use in next request
        public Boolean hasMore;
        public String nextRecordsUrl;
        public String errorMessage;
    }
    
    
    
    @httpGet
    global static ContractPageResponse getPaginatedContracts() {
        RestRequest req = RestContext.request;
        String lastNDays = '';
        String limitSize;
        String recordId = '';
        
        lastNDays = req.params.get('last_n_days');
        limitSize = req.params.get('limit') != '' ? req.params.get('limit') : '2000';
        recordId = req.params.get('recordId');
        ContractPageResponse response = new ContractPageResponse();
        
        if(String.isBlank(lastNDays) || lastNDays == 'contracts'){
            RestResponse res = RestContext.response;
            res.statusCode = 400;
            response.errorMessage = 'Missing Arguments. Please check the request';
            ErrorLogUtil.createErrorLog('VFS_VT_ContractRESTSERVICE', String.ValueOf(res), String.ValueOf(res.statusCode), 27, 'ContractPageResponse', null, System.Url.getOrgDomainUrl().toExternalForm()+'/services/apexrest/contracts2?', String.ValueOf(req.params), null);
            return response;
        }
        else{
            try{
                List<Contract__c> contractList = MetadataQueryBuilder.runDynamicQuery(lastNDays,limitSize,recordId);
                
                if(contractList == null){
                    RestResponse res = RestContext.response;
                    res.statusCode = 201;
                    response.errorMessage = 'No Data Found';
                    return response;
                }
                else{
                    RestResponse res = RestContext.response;
                    res.statusCode = 200;
                    response.records = contractList;      
                    response.pageSize = Integer.ValueOf(limitSize);                   
                    response.hasMore = contractList.size() == Integer.ValueOf(limitSize);
                    response.recordSize = contractList.size();
                    String lastRecordId = response.hasMore ? contractList[contractList.size() - 1].Id : null;
                    if(response.hasMore == True){
                        response.nextRecordsUrl = System.Url.getOrgDomainUrl().toExternalForm()+'/services/apexrest/contracts?'+'last_n_days='+lastNDays+'&limit='+limitSize+'&recordId='+lastRecordId;
                    }
                    return response;
                }
                
            }
            catch(exception ex){
                
                RestContext.response.statusCode = 404;
                ErrorLogUtil.logError(ex, String.valueOf(ex.getMessage()), null);
                response.errorMessage = String.valueOf(ex.getMessage());
                return response;
            }
        }
    }
}