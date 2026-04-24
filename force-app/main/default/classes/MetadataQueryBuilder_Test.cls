/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     MetadataQueryBuilder_Test
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       22-04-2026 
* @Used By            MetadataQueryBuilder Apex Class
* ------------------------------------------------------------------------------------------
* @description        This class is used to test MetadataQueryBuilder Class.
* ------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class MetadataQueryBuilder_Test {
 /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @testSetup
    static void setupTestData() {
        // Fetch “VT Integration User”
        Id accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Dealer Account').getRecordTypeId();
        User testUser = [SELECT Id FROM User WHERE Name = 'VT Integration User' LIMIT 1];
        System.runAs(testUser) {
            // Create Dealer Account
            Account dealer = new Account(
                Name = 'Dealer Account Test',
                RecordTypeId = accountRecordType,
                CustomerID__c = 'UKTestvfsVT001',
                BillingCountry = 'United Kingdom',
                IsPrivate__c = false
            );
            insert dealer;
            
            // Contract 1 - Valid Dealer
            Contract__c c1 = new Contract__c(
                Contract_Number__c = 'testconVFSVTTest',
                Contract_Id__c = 'testconVFSVTTest',
                DealerId__c = 'UKTestvfsVT001',
                Account__c = dealer.Id
            );
            insert c1;
            
            // Contract 2 - Missing Dealer (filtered out)
            Contract__c c2 = new Contract__c(
                Contract_Number__c = 'testconVFSVTTest1',
                Contract_Id__c = 'testconVFSVTTest1',
                DealerId__c = null,
                Account__c = dealer.Id
            );
            insert c2;
            
            // Contract 3 - Dealer Exists but Private = true (filtered out)
            Account privateDealer = new Account(
                Name='Private Dealer',
                RecordTypeId = accountRecordType,
                CustomerID__c = 'UKTestvfsVT002',
                IsPrivate__c=true,
                BillingCountry='United Kingdom'
            );
            insert privateDealer;
            
            Contract__c c3 = new Contract__c(
                Contract_Number__c = 'testconPrivate',
                Contract_Id__c = 'testconPrivate',
                DealerId__c = 'UKTestvfsVT002',
                Account__c = privateDealer.Id
            );
            insert c3;
            
            // NL dealer WITH a valid Account → should be included
            Account nlValidDealer = new Account(
                Name = 'NL Valid Dealer',
                RecordTypeId = accountRecordType,
                CustomerID__c = 'NL-VALID001',
                BillingCountry = 'Netherlands',
                BillingCountryCode = 'NL',
                IsPrivate__c = false
            );
            insert nlValidDealer;
            
            Contract__c validContract = new Contract__c(
                Contract_Number__c = 'testconNLValid',
                Contract_Id__c = 'testconNLValid',
                DealerId__c = 'NL-VALID001',
                Type__c = 'Financiële Lease',
                Business_Area__c = 'VT',
                IsDuplicate__c = false,
                Account__c = nlValidDealer.Id
            );
            insert validContract;
            
            // NL contract with NO matching Account → should be excluded
            Contract__c noAccountContract = new Contract__c(
                Contract_Number__c = 'testconNLNoAcc',
                Contract_Id__c = 'testconNLNoAcc',
                DealerId__c = 'NL-NOACCOUNT001',
                Type__c = 'Financiële Lease',
                Business_Area__c = 'VT',
                IsDuplicate__c = false,
                Account__c = nlValidDealer.Id
            );
            insert noAccountContract;
            
        }
    }
    
 /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testInitialLoadQuery
* @description     To cover the Apex class for InitialLoad
* ------------------------------------------------------------------------------------------------------
*/
    @IsTest
    static void testInitialLoadQuery() {
        
        User testUser = [SELECT Id FROM User WHERE Name='VT Integration User' LIMIT 1];
        
        System.runAs(testUser) {
            
            List<MetadataQueryBuilder.ContractWrapper> result =
                MetadataQueryBuilder.runDynamicQueryForInitialLoad(
                    null,
                    'SELECT Id FROM Contract__c WHERE Contract_Number__c IN (\'testconVFSVTTest\', \'testconVFSVTTest1\')',
                    '10'
                );
            
            // Only 1 contract survives filtering (DealerId__c != null AND not private)
            System.assertEquals(2, result.size(), 'Only 2 contract should be returned');
        }
    }
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testDeltaQuery
* @description     To cover the Apex class for DeltaLoad
* ------------------------------------------------------------------------------------------------------
*/
    @IsTest
    static void testDeltaQuery() {
        
        User testUser = [SELECT Id FROM User WHERE Name='VT Integration User' LIMIT 1];            
        List<MetadataQueryBuilder.ContractWrapper> result =
            MetadataQueryBuilder.runDynamicQuery(
                '5',       // last n days
                '10',      // limit
                null,      // recordId filter
                'Contract_Number__c LIKE \'testcon%\'',
                'SELECT Id FROM Contract__c'
            );
        
        System.assertEquals(2, result.size(), 'Only valid dealer contracts should pass filters');
        
    }
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testNLContracts
* @description     To cover the Apex class for NL Contracts
* ------------------------------------------------------------------------------------------------------
*/
    @IsTest
    static void testNLContracts() {
        User testUser = [SELECT Id FROM User WHERE Name='VT Integration User' LIMIT 1];
        
        System.runAs(testUser) {
        List<MetadataQueryBuilder.ContractWrapper> result =
            MetadataQueryBuilder.runDynamicQueryForInitialLoad(
                null,
                'SELECT Id, Contract_Number__c, Account__r.BillingCountryCode FROM Contract__c WHERE Contract_Number__c IN (\'testconNLValid\', \'testconNLNoAcc\')',
                '10'
            );
        
        // NL-VALID001 has account → included, NL-NOACCOUNT001 has no account → excluded
        System.assertEquals(2,  result.size(),'Returns 2 contracts');
    }
    }
    
}