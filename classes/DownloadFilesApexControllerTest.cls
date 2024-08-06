@IsTest
public class DownloadFilesApexControllerTest
{
    public static testMethod void testMethod1()
    {
        //Setup basic data
        Account a = new Account(Name='Test',CustomerID__c='2132131234',CompanyRegistrationNumber__c='23131',CurrencyIsoCode='EUR');
        insert a;
        Contract__c c = new Contract__c();
        c.Account__c = a.Id;
        c.Contract_Id__c = '123455';
        insert c;
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        
        //Upload document and associate the contract
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;  
        cv.FirstPublishLocationId = c.id;    //This associates the document with contract.    
        insert cv;
        
        //Act
        DownloadFilesApexController d = new DownloadFilesApexController();
        List<DownloadFilesApexController.FileDetail> urlsToDownload = DownloadFilesApexController.getContentDocs(c.Id);
        
        //Assert
        System.assert(urlsToDownload !=null, 'Content Document download links were not returned correctly for the contract.');
        System.assert(urlsToDownload.size() == 1, 'Content Document download links were not returned correctly for the contract.');
    }
}