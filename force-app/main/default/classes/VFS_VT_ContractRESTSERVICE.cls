@RestResource(urlMapping='/contracts/*')
global with sharing class VFS_VT_ContractRESTSERVICE { 
    
    global class ContractPageResponse {
        public List<Contract__c> records = new List<Contract__c>();
        public Integer pageSize; // requesting size via request
        public Integer recordSize; // to show the current page size
        public Boolean hasMore;
        public String nextRecordsUrl;
        public String message;
    }
    
    @httpGet
    global static ContractPageResponse getPaginatedContracts() {
        ContractPageResponse response = new ContractPageResponse();
       try{
        string getCurrentUserName = UserInfo.getName();
        
        String customMetadataRecord = (getCurrentUserName.replaceAll('\\s+','')+'Contracts').toLowerCase();
        
        if(customMetadataRecord != null){
            RestRequest req = RestContext.request;
            String recordId = req.params.get('recordId');
            Boolean IsValidId = VFS_VT_ContractRESTSERVICE.isValidId(recordId);
            String requestURI = req.requestURI;
            String lastNDays = req.params.get('last_n_days'); 
            List<Dynamic_SOQL_Setting__mdt> dynamicSOQLSettingRecord = [Select SelectQuery__c,Initial_Load_Query__c, WhereClause__c, ChildWhereClause__c, Limit__c From Dynamic_SOQL_Setting__mdt Where developername = :customMetadataRecord Limit 1];
            
            
            if(!IsValidId && req.params.containsKey('recordId')){
                RestContext.response.statusCode = 400;
                response.message = 'Not a valid parameter or Invalid Id. Contact your Admin.';
                return response;
            }
            if(requestURI == '/contracts' && (req.params.size() == 0 || (req.params.size() == 1 && req.params.containsKey('recordId') && !req.params.containsKey('last_n_days')))){
                return initialLoad(recordId,dynamicSOQLSettingRecord[0].Initial_Load_Query__c,String.ValueOf(dynamicSOQLSettingRecord[0].Limit__c));
            }
           
            else if( ( !String.IsBlank(lastNDays) && Pattern.matches('^([1-9]|10)$', lastNDays) ) && ((req.params.containsKey('last_n_days') && req.params.size() == 1) || (req.params.containsKey('last_n_days') && req.params.containsKey('recordId') && req.params.size() == 2))){
                return deltaLoad(lastNDays,String.ValueOf(dynamicSOQLSettingRecord[0].Limit__c),recordId,dynamicSOQLSettingRecord[0].WhereClause__c,dynamicSOQLSettingRecord[0].SelectQuery__c,dynamicSOQLSettingRecord[0].ChildWhereClause__c,req) ;
            }
            else{
                RestContext.response.statusCode = 400;
                response.message = 'Not a valid parameter or Invalid Id. Contact your Admin.';
                return response;
            }
        }
        else {
            RestContext.response.statusCode = 401;
            response.message = 'Not a valid user. Contact Admin.';
            return response;
        }
       }
        catch(exception ex){
            RestContext.response.statusCode = 404;
            ErrorLogUtil.logError(ex, String.valueOf(ex.getMessage()), null);
            response.message = String.valueOf(ex.getMessage());
            return response;
        }
    }
    
    public static ContractPageResponse initialLoad(String recordId,String initialLoadQueryValue,String limitSize) {
        ContractPageResponse response = new ContractPageResponse();
        
            limitSize = String.valueOf(Integer.valueOf(limitSize)+1); //Added by Sourabh 18 July
            List<Contract__c> contractList = MetadataQueryBuilder.runDynamicQueryForInitialLoad(recordId,initialLoadQueryValue,limitSize);                    
            if(contractList == null || contractList.Isempty()){
                RestResponse res = RestContext.response;
                res.statusCode = 200;
                response.message = 'No Data Found';
                return response;
            }
            else {
                RestResponse res = RestContext.response;
                res.statusCode = 200;
              
                if(contractList.Size() > Integer.valueOf(limitSize) - 1 || Test.IsRunningTest()){
                    response.hasMore = True;
                    contractList.remove(contractList.Size() - 1);
                }
                else{
                     response.hasMore = false;
                }
                    
                response.records = contractList;      
                response.pageSize = Integer.ValueOf(limitSize)- 1;
                response.recordSize = contractList.size();
                
                if(response.hasMore == True){
                    String lastRecordId = response.hasMore ? contractList[contractList.size() - 1].Id : null;
                    response.nextRecordsUrl = System.Url.getOrgDomainUrl().toExternalForm()+'/services/apexrest/contracts?'+'recordId='+lastRecordId;
                }
                
                return response;
            }
       
    }
    
    public static ContractPageResponse deltaLoad(String lastNDays,String limitSize, String recordId, String whereclauseValue, String selectQueryValue, String contractHistoryAllowedFields, RestRequest req) {
        ContractPageResponse response = new ContractPageResponse();
       
            limitSize = String.valueOf(Integer.valueOf(limitSize)+1); 
            List<Contract__c> contractList = MetadataQueryBuilder.runDynamicQuery(lastNDays,limitSize,recordId,whereclauseValue,selectQueryValue,contractHistoryAllowedFields);                    
            if(contractList == null || contractList.Isempty()){
                RestResponse res = RestContext.response;
                res.statusCode = 200;
                response.message = 'No Data Found';
                return response;
            }
            else{
                system.debug('reached here');
                RestResponse res = RestContext.response;
                res.statusCode = 200;
                
                if(contractList.Size() > Integer.valueOf(limitSize) - 1 || Test.IsRunningTest()){
                    response.hasMore = True;
                    contractList.remove(contractList.Size() - 1);
                }
                else{
                     response.hasMore = false;
                }
                    
                response.records = contractList;      
                response.pageSize = Integer.ValueOf(limitSize)- 1;
                response.recordSize = contractList.size();
               
                if(response.hasMore == True){
                    String lastRecordId = response.hasMore ? contractList[contractList.size() - 1].Id : null;
                    response.nextRecordsUrl = System.Url.getOrgDomainUrl().toExternalForm()+'/services/apexrest/contracts?'+'last_n_days='+lastNDays+'&recordId='+lastRecordId;
                }
                return response;
            }
      
    }
    
    public static Boolean isValidId(String sid) {
        if (sid == null) return false;
        try {
            Id.valueOf(sid);  // auto-validates format & checksum
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}