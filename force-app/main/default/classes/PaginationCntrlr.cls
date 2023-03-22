public without sharing class PaginationCntrlr {
    @AuraEnabled
    public static PageInfo getPageCountInfo(String order,String sname, String contId){
        List<Customer_Community_Config__mdt> perPage = [Select Current_Page_Count__c  from Customer_Community_Config__mdt LIMIT 1];   
        Decimal currnetPagesCount= perPage[0].Current_Page_Count__c ;
        Integer currentListCount = String.valueOf(currnetPagesCount) != null && String.valueOf(currnetPagesCount) != '' ? Integer.valueOf(currnetPagesCount) : 5;
        List<SObject> obj=new List<SObject>();
        Integer totalRecordSize;
        if(sname=='contract'){
            Id accountId = PortalUtility.getAccountId();
            String whereClause = 'Account__c = \''+ accountId + '\'';
            if(!(String.isBlank(contId))){
                whereClause = 'Name like \''+ '%'+contId+'%' + '\'';  
            }
            obj = DataUtil.queryObjectFields('Contract__c', whereClause, '');
            totalRecordSize=obj.size();
        }else if(sname=='paymentPlan')
        {
            Id accountId = PortalUtility.getAccountId();
            String whereClause = String.isEmpty(contId) ? ' Id != null ' : 'Contract__c = \''+ contId + '\'';
            whereClause += ' AND Contract__r.Account__c = \''+ accountId + '\' ';
            obj = DataUtil.queryObjectFields('Payment_Plan__c', whereClause, ''); 
            totalRecordSize=obj.size();   
        }
        /*else if(sname=='asset')
{
Id accountId = getAccountId();
String whereClause = String.isEmpty(contId) ? ' Id != null ' : 'Contract__c = \''+ contId + '\'';
whereClause += ' AND Contract__r.Account__c = \''+ accountId + '\' ';
obj = TC_DataUtil.queryObjectFields('Equipment_CS__c', whereClause, ''); 
totalRecordSize=obj.size();   
}
else if(sname=='payment'){
Id accountId = getAccountId();
List<Community_Payment_History_Access__mdt> picklistOptionsList = [SELECT Viewable_Picklist_Values__c FROM Community_Payment_History_Access__mdt LIMIT 1];
String picklistOptions;
if(picklistOptionsList.size() > 0) {
picklistOptions = picklistOptionsList[0].Viewable_Picklist_Values__c;
}
List<String> parseVals = picklistOptions.split(',\r\n');

String whereClause = String.isEmpty(contId) ? ' Id != null ' : 'Contract__c = \'' + contId + '\'';
whereClause += ' AND Account__c = \'' + accountId + '\' ';
if (parseVals.size() > 0) {
for(Integer j = 0; j < parseVals.size(); j++) {
if(j == 0){
whereClause += (' AND (Payment_Type__c = \'' + parseVals[j] + '\'');
}else{
whereClause += (' OR Payment_Type__c = \'' + parseVals[j] + '\'');
}
}
whereClause += ')';
}
obj = TC_DataUtil.queryObjectFields('Payment_History__c', whereClause, ''); 
totalRecordSize=obj.size();
}
else if(sname=='invoice'){
String whereClause = String.isEmpty(contId) ? ' Id != null ' : 'Contract__c = \'' + contId + '\'';
String orderBy = 'Invoice_Date__c';
obj = TC_DataUtil.queryObjectFields('Invoice__c', whereClause, '');
totalRecordSize=obj.size();
}
else if(sname=='document'){
totalRecordSize=integer.valueof(contId);
}
else{
}*/
        PageInfo pgn = new PageInfo();        
        pgn.currentPageNumber = 1;
        List<Integer> cnt = new List<Integer>();
        if(totalRecordSize == currentListCount){
            pgn.totalPages = 1;
            cnt.add(1);
        }
        else{
            if(math.mod(totalRecordSize, currentListCount)!=0)
            {
                pgn.totalPages = (totalRecordSize/(currentListCount))+1;
            }else{
                pgn.totalPages = (totalRecordSize/(currentListCount));
            }
            
            pgn.currentPageNumber = 1;
            if(pgn.totalPages > 0)
                cnt.add(1);
            
            for(Integer loopvar = 1;loopvar < pgn.totalPages;loopvar++){
                cnt.add(loopvar+1);
                if((loopvar+1) == 4)
                    break;
            }
        }
        if(pgn.totalPages > 4)
            cnt.add(pgn.totalPages);
        pgn.pageCounter = cnt;
        return pgn;        
    }
    
    @AuraEnabled
    public static PageInfo getPageCountChange(String pageNumber,String totalPages){
        PageInfo pgn = new PageInfo();
        pgn.currentPageNumber = Integer.valueOf(pageNumber);
        pgn.totalPages = Integer.valueOf(totalPages);
        
        List<Integer> cnt = new List<Integer>();
        Integer nextpage=0;
        if((Integer.valueOf(pageNumber)+2) < Integer.valueOf(totalPages) && Integer.valueOf(pageNumber) != 1){
            if(Integer.valueOf(pageNumber) == 2)
                nextpage = 3;
            else
                nextpage = 2;
            cnt.add(1);
            for(Integer loopvar = (Integer.valueOf(pageNumber)-1);loopvar < (Integer.valueOf(pageNumber)+nextpage);loopvar++){
                if(loopvar!=1)
                    cnt.add(loopvar);
            }
            cnt.add(pgn.totalPages);
        }else if(Integer.valueOf(pageNumber) == 1){
            if(pgn.totalPages<5)
            {
                for(Integer loopvar = 1;loopvar < (pgn.totalPages);loopvar++){
                    cnt.add(loopvar);
                }   
            }else{
                for(Integer loopvar = 1;loopvar < 5;loopvar++){
                    cnt.add(loopvar);
                }}
            cnt.add(pgn.totalPages);
        }else{
            cnt.add(1);
            if(pgn.totalPages<5)
            {
                for(Integer loopvar = 2;loopvar < (pgn.totalPages+1);loopvar++){
                    cnt.add(loopvar);
                }   
            }else{
                for(Integer loopvar = (pgn.totalPages-3);loopvar < (pgn.totalPages+1);loopvar++){
                    cnt.add(loopvar);
                }}
        }
        pgn.pageCounter = cnt;
        return pgn;
    }
}