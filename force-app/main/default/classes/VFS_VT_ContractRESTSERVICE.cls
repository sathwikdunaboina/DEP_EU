@RestResource(urlMapping='/contracts/*')
global without sharing class VFS_VT_ContractRESTSERVICE {
    
    global class ContractPageResponse {
        public List<Contract__c> records = new List<Contract__c>();
        public Integer pageSize; // requesting size via request
        public Integer recordSize; // to show the current page size
        public Boolean hasMore;
        public String nextRecordsUrl;
        public String errorMessage;
    }
    
    @httpGet
    global static ContractPageResponse getPaginatedContracts() {
        string getCurrentUserName = UserInfo.getName();
        ContractPageResponse response = new ContractPageResponse();
        String customMetadataRecord;
        SWITCH on getCurrentUserName{
            when 'VT Integration User' {
                customMetadataRecord = 'VTContractRecordSharingCriteria';
            }
            when else {
                customMetadataRecord = null;
            }
        }
        
        if(customMetadataRecord != null){
            RestRequest req = RestContext.request;
            String recordId = req.params.get('recordId');
            String lastNDays = req.params.get('last_n_days');
            List<Dynamic_SOQL_Setting__mdt> dynamicSOQLSettingRecord = [Select SelectQuery__c, WhereClause__c, ChildWhereClause__c, Limit__c From Dynamic_SOQL_Setting__mdt Where developername = :customMetadataRecord Limit 1];
            String limitSize = String.ValueOf(dynamicSOQLSettingRecord[0].Limit__c);
            String whereclauseValue = dynamicSOQLSettingRecord[0].WhereClause__c;
            String selectQueryValue = dynamicSOQLSettingRecord[0].SelectQuery__c;
            String contractHistoryAllowedFields = dynamicSOQLSettingRecord[0].ChildWhereClause__c;
            if(String.isBlank(lastNDays) || lastNDays == 'contracts'){
                RestResponse res = RestContext.response;
                res.statusCode = 400;
                response.errorMessage = 'Missing Arguments. Please check the request';
                ErrorLogUtil.createErrorLog('VFS_VT_ContractRESTSERVICE', String.ValueOf(res), String.ValueOf(res.statusCode), 27, 'ContractPageResponse', null, System.Url.getOrgDomainUrl().toExternalForm()+'/services/apexrest/contracts2?', String.ValueOf(req.params), null);
                return response;
            }
            
            else{
                
                try{
                    
                    List<Contract__c> contractList = MetadataQueryBuilder.runDynamicQuery(lastNDays,limitSize,recordId,whereclauseValue,selectQueryValue,contractHistoryAllowedFields);
                    
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
                            response.nextRecordsUrl = System.Url.getOrgDomainUrl().toExternalForm()+'/services/apexrest/contracts?'+'last_n_days='+lastNDays+'&recordId='+lastRecordId;
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
        else {
            response.errorMessage = 'Not a valid user. Contact Admin.';
            return response;
        }
        
    }
}