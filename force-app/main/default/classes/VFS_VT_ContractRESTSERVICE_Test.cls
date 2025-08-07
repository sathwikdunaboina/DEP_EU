@IsTest
public class VFS_VT_ContractRESTSERVICE_Test {
    
    public static void testDataSetup(){
        Id accountRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        User usr = [SELECT Id FROM User WHERE Name = 'VT Integration User'];
        System.runAs(usr) {
            Account acc = new Account(Name='VFSVT Demo Acc Test', RecordTypeId = accountRecordType,  BillingCountry = 'United Kingdom');
            Insert acc;
            Contract__c con = new Contract__c();
            con.Account__c = acc.Id;
            con.Contract_Id__c = 'testconVFSVTTest';
            con.Contract_Number__c = 'testconVFSVTTest';
            con.Business_Area__c = 'VT';
            con.CreatedDate = Datetime.now().addDays(-1);
            con.End_Date__c = Date.today().addDays(10);
            con.Type__c = 'Purchase Plan - fixed rate';//added
            insert con;
            Contract__c con1 = new Contract__c();
            con1.Account__c = acc.Id;
            con1.Contract_Id__c = 'testconVFSVTTest1';
            con1.Contract_Number__c = 'testconVFSVTTest1';
            con1.Business_Area__c = 'VT';
            con1.CreatedDate = Datetime.now().addDays(-1);
            con1.End_Date__c = Date.today().addDays(10);
            con1.Type__c = 'Purchase Plan - fixed rate';//added
            insert con1;
        }
    }
    
    
    @isTest
    static void testGetInitialContracts(){
        // Set up the mock request
        // setup test data
        VFS_VT_ContractRESTSERVICE_Test.testDataSetup();
        User usr = [SELECT Id FROM User WHERE Name = 'VT Integration User'];
        System.runAs(usr) {
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestUri = '/contracts';
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            //Calling the Rest Method
            VFS_VT_ContractRESTSERVICE.ContractPageResponse contResp = VFS_VT_ContractRESTSERVICE.getPaginatedContracts();
            System.assertEquals(1,contResp.recordSize , 'Size should match');
        }
    }
    
    @isTest
    static void testGetDeltaContracts(){
        // Set up the mock request
        // setup test data
        VFS_VT_ContractRESTSERVICE_Test.testDataSetup();
        User usr = [SELECT Id FROM User WHERE Name = 'VT Integration User'];
        Contract__c contractTestRecord = [SELECT Id,Contract_Number__c FROM Contract__c WHERE Contract_Id__c ='testconVFSVTTest'];
        System.runAs(usr) {
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestUri = '/contracts';
            req.addParameter('last_n_days', '4');
            req.addParameter('recordId', contractTestRecord.Id);
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            //Calling the Rest Method
            VFS_VT_ContractRESTSERVICE.ContractPageResponse contResp = VFS_VT_ContractRESTSERVICE.getPaginatedContracts();
            System.assertEquals(1,contResp.recordSize , 'Size should match');
        }
    }
    
    @isTest
    static void testGetDeltaContractsEmpty(){
        // Set up the mock request
        // setup test data
        User usr = [SELECT Id FROM User WHERE Name = 'VT Integration User'];
        System.runAs(usr) {
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestUri = '/contracts';
            req.addParameter('last_n_days', '4');
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            //Calling the Rest Method
            VFS_VT_ContractRESTSERVICE.ContractPageResponse contResp = VFS_VT_ContractRESTSERVICE.getPaginatedContracts();
            System.assertEquals(null,contResp.recordSize , 'Size should match');
        }
    }
    
    

    
    @isTest
    static void testGetInitialContractsEmpty(){
        // Set up the mock request
        // setup test data
        User usr = [SELECT Id FROM User WHERE Name = 'VT Integration User'];
        System.runAs(usr) {
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestUri = '/contracts';
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            //Calling the Rest Method
            VFS_VT_ContractRESTSERVICE.ContractPageResponse contResp = VFS_VT_ContractRESTSERVICE.getPaginatedContracts();
            System.assertEquals(null,contResp.recordSize , 'Size should match');
        }
    }
    
    @isTest
    static void testGetInitialContractsWithRecordId(){
        // Set up the mock request
        // setup test data
        VFS_VT_ContractRESTSERVICE_Test.testDataSetup();
        User usr = [SELECT Id FROM User WHERE Name = 'VT Integration User'];
        System.runAs(usr) {
            Contract__c contractTestRecord = [SELECT Id,Contract_Number__c FROM Contract__c WHERE Contract_Id__c ='testconVFSVTTest'];
            System.debug(contractTestRecord);
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestUri = '/contracts';
            req.addParameter('recordId', contractTestRecord.Id);
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            //Calling the Rest Method
            VFS_VT_ContractRESTSERVICE.ContractPageResponse contResp = VFS_VT_ContractRESTSERVICE.getPaginatedContracts();
            System.assertEquals(1,contResp.recordSize , 'Size should match');
        }
    }
    
    
    @isTest
    static void testGetContractsWithInvalidRecordId(){
        // Set up the mock request
        // setup test data
        VFS_VT_ContractRESTSERVICE_Test.testDataSetup();
        User usr = [SELECT Id FROM User WHERE Name = 'VT Integration User'];
        System.runAs(usr) {
            Contract__c contractTestRecord = [SELECT Id,Contract_Number__c FROM Contract__c WHERE Contract_Id__c ='testconVFSVTTest'];
            System.debug(contractTestRecord);
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestUri = '/contracts';
            req.addParameter('recordId', contractTestRecord.Id+'a');
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            //Calling the Rest Method
            VFS_VT_ContractRESTSERVICE.ContractPageResponse contResp = VFS_VT_ContractRESTSERVICE.getPaginatedContracts();
            System.assertEquals(null,contResp.recordSize , 'Size should match');
        }
    }    
    
    @isTest
    static void testGetContractsWithInvalidUri(){
        // Set up the mock request
        // setup test data
        VFS_VT_ContractRESTSERVICE_Test.testDataSetup();
        User usr = [SELECT Id FROM User WHERE Name = 'VT Integration User'];
        System.runAs(usr) {
            Contract__c contractTestRecord = [SELECT Id,Contract_Number__c FROM Contract__c WHERE Contract_Id__c ='testconVFSVTTest'];
            System.debug(contractTestRecord);
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestUri = '/contractss';
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            //Calling the Rest Method
            VFS_VT_ContractRESTSERVICE.ContractPageResponse contResp = VFS_VT_ContractRESTSERVICE.getPaginatedContracts();
            System.assertEquals(null,contResp.recordSize , 'Size should match');
        }
    }      
}