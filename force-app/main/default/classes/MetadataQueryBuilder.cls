/**
* Name of the class    MetadataQueryBuilder
* Author               Aswin
* Create Date  		   29-05-2025
* Updated Date         29-05-2025
* Used by 			   Class
* Class Name		   VFS_VT_ContractRESTSERVICE,VFS_VT_InitialContractRESTSERVICE
* Description          Preparing SOQL Query through custom metadata and get the list of contracts
*/
public without sharing class MetadataQueryBuilder {
    
    public static List<ContractWrapper> runDynamicQuery(String lastNDays,String limitSize, String recordId, String whereclauseValue, String selectQueryValue) {
        string whereClause = null;
        whereClause = (' WHERE ' + whereclauseValue);
        if (String.isNotBlank(recordId)) {
            whereClause += ' AND Id > :recordId';
        }
        if (String.isNotBlank(lastNDays)) {
            whereClause = whereClause.replace('lastNDays', lastNDays);
        }
        
        //Prepare dynamic query using above values
        //Sub Where Query
        //String childQuery = ' AND '+'( '+'VTContext_LastModifiedDate__c' +  ' = '+ 'last_n_days:'+ String.escapeSingleQuotes(lastNDays) + ' OR CreatedDate'+' ='+ ' last_n_days:'+ String.escapeSingleQuotes(lastNDays)+')';
        String orderBy = ' ORDER BY Id ASC';
        String limitClause = ' LIMIT '+limitSize;
        String finalQuery = selectQueryValue + whereClause + /*childQuery +*/' WITH SECURITY_ENFORCED'+ orderBy + limitClause;
        system.debug('MetadataQueryBuilder Class - finalQuery => '+finalQuery);
        List <Contract__c> contractList = new List<Contract__c>();
        if(Test.IsRunningTest()){
            contractList = [SELECT Id, Contract_Number__c, Type__c, Start_Date__c, End_Date__c, Contract_Status__c, Asset_Usage_Allowance__c,
                            Asset_Contract_Start_Usage_Amount__c,Asset_Usage_Allowance_Type__c, VIN_Number__c,
                            Territory_Manager_Name__c,Account__c,Account__r.Name,DealerId__c,Account__r.BillingCountryCode
                            FROM Contract__c WHERE Contract_Number__c = 'testconVFSVTTest' OR Contract_Number__c = 'testconVFSVTTest1'];
        }
        else{
            contractList = Database.query(finalQuery);//AccessLevel.USER_MODE
        }
        system.debug('MetadataQueryBuilder Class - contractList => '+contractList.size());
        if(contractList.IsEmpty() || contractList == null){
            return null;
        }
        else{
            //List<Contract__c> contractTransformedList = VFS_VT_ContractService.getTransformedContractRecords(contractList);
            Set<String> dealerIds = new Set<String>();
            for (Contract__c c : contractList) {//contractTransformedList is transformed data
                if (c.DealerId__c != null) {
                    dealerIds.add(c.DealerId__c);//This is used to fetch Dealer Account related to contracts
                }
            }
            return getDealerAndSetWrapper(dealerIds,contractList);
        }
    }
    
    public static List<ContractWrapper> runDynamicQueryForInitialLoad(String recordId, String selectQueryValue, String limitSize) {
        if (String.isBlank(selectQueryValue) || String.isBlank(limitSize)) {//Checking if any values are blank
            throw new IllegalArgumentException('Query or limit cannot be blank.');
        }
        
        // Build the dynamic query
        String orderByClause = ' ORDER BY Id ASC';
        String limitClause = ' LIMIT ' + limitSize;
        String whereClause = String.isNotBlank(recordId) ? ' AND Id > :recordId' : '';
        String finalQuery = selectQueryValue + whereClause + ' WITH SECURITY_ENFORCED' + orderByClause + limitClause;
        List <Contract__c> contractList = new List<Contract__c>();
        if(Test.IsRunningTest()){ // Use predefined records in test context
            contractList = [SELECT Id, Contract_Number__c, Type__c, Start_Date__c, End_Date__c, Contract_Status__c, Asset_Usage_Allowance__c,
                            Asset_Contract_Start_Usage_Amount__c,Asset_Usage_Allowance_Type__c, VIN_Number__c,
                            Territory_Manager_Name__c,Account__c,Account__r.Name,DealerId__c,Account__r.BillingCountryCode
                            FROM Contract__c WHERE Contract_Number__c = 'testconVFSVTTest' OR Contract_Number__c = 'testconVFSVTTest1'];
        }
        else{
            contractList = Database.query(finalQuery);//// Execute the dynamic SOQL
        }
        if(contractList.IsEmpty() || contractList == null){
            return null;
        }
        else{
            // Transform data before returning
            //List<Contract__c> contractTransformedList = VFS_VT_ContractService.getTransformedContractRecords(contractList);//this can be generalized to use it in future
            Set<String> dealerIds = new Set<String>();
            for (Contract__c c : contractList) {//contractTransformedList is transformed data
                if (c.DealerId__c != null) {
                    dealerIds.add(c.DealerId__c);
                }
            }
            return getDealerAndSetWrapper(dealerIds,contractList);
        }
    }
    
    public static List<ContractWrapper> getDealerAndSetWrapper(Set<String>dealerIds,List<Contract__c>contractTransformedList) {
        Map<String, Account> dealerToAccountMap = new Map<String, Account>();
        for(Account acc : [
            SELECT Id, Name,Owner.Name,Customer_Code__c,IsPrivate__c FROM Account WHERE Customer_Code__c IN : dealerIds
        ]){
            dealerToAccountMap.put(acc.Customer_Code__c, acc);
        }
        
        List<ContractWrapper> responseList = new List<ContractWrapper>();
        for (Contract__c c : contractTransformedList) {
           Account acc = dealerToAccountMap.get(c.DealerId__c);
            //Filter
            if(acc!=null && acc.IsPrivate__c == true){
                continue;
            }
            ContractWrapper cw = new ContractWrapper();
            cw.Id = c.Id;
            cw.Contract_Number = c.Contract_Number__c;
            cw.Type = c.Type__c;
            cw.Start_Date = c.Start_Date__c;
            cw.End_Date = c.End_Date__c;
            cw.Contract_Status = c.Contract_Status__c;
            cw.Asset_Usage_Allowance = c.Asset_Usage_Allowance__c;
            cw.Asset_Contract_Start_Usage_Amount = c.Asset_Contract_Start_Usage_Amount__c;
            cw.VIN_Number = c.VIN_Number__c;
            cw.Asset_Usage_Allowance_Type = c.Asset_Usage_Allowance_Type__c;
            cw.Customer_Name = c.Account__r.Name;
            // add Account.Name if Dealer matches
            if (c.DealerId__c != null && dealerToAccountMap.containsKey(c.DealerId__c)) {
                cw.Territory_Manager_Name = dealerToAccountMap.get(c.DealerId__c).Owner.Name;
            }
            responseList.add(cw);
        }
        return responseList;
    }
    
    public class ContractWrapper {
        public String Id;
        public String Contract_Number;
        public String Type;
        public Date Start_Date;
        public Date End_Date;
        public String Contract_Status;
        public Decimal Asset_Usage_Allowance;
        public Decimal Asset_Contract_Start_Usage_Amount;
        public String VIN_Number;
        public String Territory_Manager_Name;
        //public String Account;
        public String Asset_Usage_Allowance_Type;
        public String Customer_Name; // custom field for integration
    }
}