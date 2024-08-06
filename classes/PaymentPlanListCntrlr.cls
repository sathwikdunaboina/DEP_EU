public without sharing class PaymentPlanListCntrlr{
    @AuraEnabled
    public static List<sObject> getPaymentsByCheckNumber(String contractId, String order, String ad, String pageNumber, String search, String frm, String to) {
        try {
            List<Page_Count__mdt> perPage = [Select Current_Page_Count__c  from Page_Count__mdt LIMIT 1];   
            Decimal currnetPagesCount= perPage[0].Current_Page_Count__c ;
            Id accountId = PortalUtility.getAccountId();
            /*
            List<Community_Payment_History_Access__mdt> picklistOptionsList = [SELECT Viewable_Picklist_Values__c FROM Community_Payment_History_Access__mdt LIMIT 1];
            String picklistOptions;
            if(picklistOptionsList.size() > 0) {
                picklistOptions = picklistOptionsList[0].Viewable_Picklist_Values__c;
            }
            
            List<String> parseVals = picklistOptions.split(',\r\n');
            
            for(Integer i = 0; i < parseVals.size(); i++) {
            }*/
            
            String whereClause = String.isEmpty(contractId) ? ' Id != null ' : 'Contract__c = \'' + contractId + '\'';
            
            whereClause += ' AND Contract__r.Account__c = \''+ accountId + '\' ';
            
            if (search <> null && search <> '') {
                whereClause += ' AND Name LIKE \'%' + search + '%\' ';
            }
            if (frm <> null && frm <> '' && to <> null && to <> '') {
                whereClause += ' AND Due_Date__c >= ' + frm;
                whereClause += ' AND Due_Date__c <= ' + to;
            }
            /*if (parseVals.size() > 0) {
                
                for(Integer j = 0; j < parseVals.size(); j++) {
                    if(j == 0){
                        whereClause += (' AND (Payment_Type__c = \'' + parseVals[j] + '\'');
                    }else{
                        whereClause += (' OR Payment_Type__c = \'' + parseVals[j] + '\'');
                    }
                }
                
                whereClause += ')';
            }*/
            
            //String orderBy = 'Contract_Sort__c'; commented by Sumit 
            //Sumit Start
            String orderBy;
            if(order == 'Date_Received'){
                orderBy = 'Name';
                ad = 'DESC';
            }else{
                orderBy = 'Name';
            }
            //Sumit End
            
            
            String orderNulls = ad == 'ASC' ? 'NULLS FIRST' : 'NULLS LAST';
            String offset='';
            if(String.isBlank(pageNumber) || Integer.valueOf(pageNumber) == 1){
                offset = ' 0';
            }else{
                offset =  String.valueOf((Integer.valueOf(pageNumber)-1)*Integer.valueOf(currnetPagesCount));
            }
            List <SObject> obj = DataUtil.queryObjectFields('Payment_Plan__c', whereClause, ' ORDER BY ' + orderBy + ' ' + ad + ' ' + orderNulls + ' LIMIT ' + Integer.valueOf(currnetPagesCount) + ' OFFSET ' + offset);
            return obj;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}