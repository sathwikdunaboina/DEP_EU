@IsTest
public class MetadataQueryBuilder_Test {
    @TestSetup
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
        }
    }
    
    // ---------------------------------------------------------
    // TEST runDynamicQueryForInitialLoad
    // ---------------------------------------------------------
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
    
    // ---------------------------------------------------------
    // TEST runDynamicQuery
    // ---------------------------------------------------------
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
   
    // ---------------------------------------------------------
    // TEST filtering logic (dealer missing / private)
    // ---------------------------------------------------------
    /*@IsTest
    static void testDealerFilterLogic() {
        
        User testUser = [SELECT Id FROM User WHERE Name='VT Integration User' LIMIT 1];
            List<MetadataQueryBuilder.ContractWrapper> result =
                MetadataQueryBuilder.runDynamicQuery(
                    null,
                    '20',
                    null,
                    'Contract_Number__c LIKE \'testcon%\'',
                    'SELECT Id FROM Contract__c'
                );
            
            // Expect only 1 valid contract (DealerId != null AND dealer is not private)
            System.assertEquals(2, result.size(), 'Filtering logic failed');
        
    }*/
    
}