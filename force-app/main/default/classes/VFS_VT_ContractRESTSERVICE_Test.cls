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
            con.Type__c = 'Purchase Plan - fixed rate';//added
            insert con;
        }
    }
    
    @isTest
    static void testDoGetWithLastNDays(){
        // Set up the mock request
        // setup test data
        VFS_VT_ContractRESTSERVICE_Test.testDataSetup();
        User usr = [SELECT Id FROM User WHERE Name = 'VT Integration User'];
        System.runAs(usr) {
            Contract__c contractTestRecord = [SELECT Id,Contract_Number__c FROM Contract__c WHERE Contract_Id__c ='testconVFSVTTest'];
            System.debug(contractTestRecord);
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestUri = '/services/apexrest/contracts';
            req.httpMethod = 'GET';
            req.addParameter('last_n_days', '4');
            req.addParameter('recordId', contractTestRecord.Id);
            RestContext.request = req;
            RestContext.response = res;
            //Calling the Rest Method
            VFS_VT_ContractRESTSERVICE.ContractPageResponse contResp = VFS_VT_ContractRESTSERVICE.getPaginatedContracts();
            System.assertEquals(1,contResp.recordSize , 'Size should match');
        }
    }
    
    @isTest
    static void testDoGetWithOutLastNDays(){
        // Set up the mock request
        // setup test data
        VFS_VT_ContractRESTSERVICE_Test.testDataSetup();
        User usr = [SELECT Id FROM User WHERE Name = 'VT Integration User'];
        System.runAs(usr) {
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestUri = '/services/apexrest/contracts';
            req.httpMethod = 'GET';
            req.addParameter('last_n_days', '');
            RestContext.request = req;
            RestContext.response = res;
            //Calling the Rest Method
            VFS_VT_ContractRESTSERVICE.ContractPageResponse contResp = VFS_VT_ContractRESTSERVICE.getPaginatedContracts();
            System.assertEquals('Missing Arguments. Please check the request',contResp.errorMessage , 'Missing Arguments.');
        }
    }
    
    @isTest
    static void catchBlockWithAnonymousUser(){
        // Set up the mock request
        // setup test data
        User usr = [SELECT Id FROM User WHERE Name = 'Aswin Balaji'];
        System.runAs(usr) {
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestUri = '/services/apexrest/contracts';
            req.httpMethod = 'GET';
            req.addParameter('last_n_days', '10');
            RestContext.request = req;
            RestContext.response = res;
            //Calling the Rest Method
            VFS_VT_ContractRESTSERVICE.ContractPageResponse contResp = VFS_VT_ContractRESTSERVICE.getPaginatedContracts();
            System.assertEquals('Not a valid user. Contact Admin.',contResp.errorMessage , 'No Data Found due to anonymous user');
        }
    }
    
    @isTest
    static void testDoGetWithInvalidFormatRequest(){
        // Set up the mock request
        // setup test data
        User usr = [SELECT Id FROM User WHERE Name = 'VT Integration User'];
        System.runAs(usr) {
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestUri = '/services/apexrest/contracts';
            req.httpMethod = 'GET';
            req.addParameter('last_n_days', 'bsa');
            RestContext.request = req;
            RestContext.response = res;
            //Calling the Rest Method
            VFS_VT_ContractRESTSERVICE.ContractPageResponse contResp = VFS_VT_ContractRESTSERVICE.getPaginatedContracts();
            System.debug(contResp.errorMessage);
        }
    }
}