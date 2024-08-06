public without sharing class ContracstListCntrlr {
    @AuraEnabled
    public static List<SObject> getContractSummariesByContractId (String order, String ad, Integer offset, Integer max, String search) {
        try {
            Id accountId = PortalUtility.getAccountId();
            String whereClause = 'Account__c = \''+ accountId + '\'';
            
            if (search <> null && search <> '') {
                whereClause += 'AND Name LIKE \'%' + search + '%\' ';
            }
            
            String orderBy;
            if(order == 'Due Date'){
                orderBy = 'End_Date__c';
            }else if(order == 'Maturity Date') {
                orderBy = 'End_Date__c';
            }else{
                orderBy = 'End_Date__c';
            }
            
            String orderNulls = ad == 'ASC' ? 'NULLS FIRST' : 'NULLS LAST';
            List <SObject> obj = DataUtil.queryObjectFields('Contract__c', whereClause, ' ORDER BY '+orderBy+' '+ad+' '+orderNulls+' LIMIT ' + max + ' OFFSET ' + offset);
            return obj;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()+' '+ex.getCause()+' '+ex.getLineNumber()+' '+ex.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static List<SObject> getContractRecords(String order, String ad, String pageNumber,String search) {
        try {
            List<Page_Count__mdt> perPage = [Select Current_Page_Count__c  from Page_Count__mdt LIMIT 1];   
            Decimal currnetPagesCount= perPage[0].Current_Page_Count__c ;
            Id accountId = PortalUtility.getAccountId();
            
            String orderBy;
            if(order == 'Due Date'){
                orderBy = 'End_Date__c';
            }else if(order == 'Maturity Date') {
                orderBy = 'End_Date__c';
            }else if(order == 'Number') {
                orderBy = 'End_Date__c';
            }else{
                orderBy = 'End_Date__c';
            }
            
            String whereClause = 'Account__c = \''+ accountId + '\'';
            if (search <> null && search <> '') {
                whereClause +='AND ';
                whereClause += ' Contract_Id__c LIKE \'%' + search + '%\' ';
            }
            
            String orderNulls = ad == 'ASC' ? 'NULLS FIRST' : 'NULLS LAST';
            String offset='';
            if(String.isBlank(pageNumber) || Integer.valueOf(pageNumber) == 1){
                offset = ' 0';
            }else{
                offset =  String.valueOf((Integer.valueOf(pageNumber)-1)*Integer.valueOf(currnetPagesCount));
            }
            List<SObject> obj = DataUtil.queryObjectFields('Contract__c', whereClause, '  ORDER BY '+orderBy+' '+ad+' '+orderNulls+' LIMIT ' + Integer.valueOf(currnetPagesCount) + ' OFFSET ' + offset);
            return obj;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()+' '+ex.getCause()+' '+ex.getLineNumber()+' '+ex.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static Integer getContractRecordsTotal() {
        try {
            Id accountId = PortalUtility.getAccountId();
            String whereClause = 'Account__c = \''+ accountId + '\'';
            List<SObject> obj = DataUtil.queryObjectFields('Contract__c', whereClause, '');
            return obj.size();
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()+' '+ex.getCause()+' '+ex.getLineNumber()+' '+ex.getStackTraceString());
        }
    }
}