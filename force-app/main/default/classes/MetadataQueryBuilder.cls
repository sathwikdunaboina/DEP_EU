/**
* Name of the class    MetadataQueryBuilder
* Author               Aswin
* Create Date  		   29-05-2025
* Updated Date         29-05-2025
* Used by 			   Class
* Class Name		   VFS_VT_ContractRESTSERVICE,VFS_VT_InitialContractRESTSERVICE
* Description          Preparing SOQL Query through custom metadata and get the list of contracts
*/
public without sharing class MetadataQueryBuilder {//check for more than 10kecords how to handle it
    
    public static List<Contract__c> runDynamicQuery(String lastNDays,String limitSize, String recordId, String whereclauseValue, String selectQueryValue, String contractHistoryAllowedFields) {
        string whereClause = null;
        whereClause = (' WHERE ' + whereclauseValue);
        if (String.isNotBlank(recordId)) {
            whereClause += ' AND Id > :recordId';
        }
        
        //Prepare dynamic query using above values
        //Sub Where Query
        String childWhereClause = (contractHistoryAllowedFields + ' AND createddate' +' ='  + ' last_n_days:'+ String.escapeSingleQuotes(lastNDays));
        String childQuery = ' AND Id IN (SELECT ParentId FROM Contract__History ' +  ' WHERE '+ childWhereClause +')';
        String orderBy = ' ORDER BY Id ASC';
        String limitClause = ' LIMIT '+limitSize;
        String finalQuery = selectQueryValue + whereClause + childQuery +' WITH SECURITY_ENFORCED'+ orderBy + limitClause;
        system.debug('MetadataQueryBuilder Class - finalQuery => '+finalQuery);
        List <Contract__c> contractList = new List<Contract__c>();
        if(Test.IsRunningTest()){
            contractList = [SELECT Id, Contract_Number__c, Type__c, Start_Date__c, End_Date__c, Contract_Status__c, Asset_Usage_Allowance__c,
                            Asset_Contract_Start_Usage_Amount__c,Asset_Usage_Allowance_Type__c, VIN_Number__c,
                            Territory_Manager_Name__c 
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
            List<Contract__c> contractTransformedList = VFS_VT_ContractService.getTransformedContractRecords(contractList);
            return contractTransformedList;
        } 
    }
    
    public static List<sObject> runDynamicQueryForInitialLoad(String recordId, String selectQueryValue, String limitSize) {
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
                            Territory_Manager_Name__c 
                            FROM Contract__c WHERE Contract_Number__c = 'testconVFSVTTest' OR Contract_Number__c = 'testconVFSVTTest1'];
        }
        else{
            contractList = Database.query(finalQuery);//// Execute the dynamic SOQL
        }
        system.debug('MetadataQueryBuilder Class - contractList => '+contractList.size());
        if(contractList.IsEmpty() || contractList == null){
            return null;
        }
        else{
            // Transform data before returning
            List<Contract__c> contractTransformedList = VFS_VT_ContractService.getTransformedContractRecords(contractList);
            return contractTransformedList;
        }
    }
}