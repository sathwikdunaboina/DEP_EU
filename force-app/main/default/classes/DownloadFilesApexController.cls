public class DownloadFilesApexController {
    @AuraEnabled
    public static List<FileDetail> getContentDocs(Id contractID){
        
        List <FileDetail> fileList = new List <FileDetail> ();
        
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm()+'/customer/sfc/servlet.shepherd/document/download/';
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId,  ContentDocument.Title,  ContentDocument.FileExtension 
                                        FROM ContentDocumentLink 
                                        WHERE LinkedEntityId =:contractID]){
         	
         	fileList.add(new FileDetail( cdl.ContentDocument.Title + '.' + cdl.ContentDocument.FileExtension, fullFileURL+cdl.ContentDocumentId));
        }
        System.debug('fileList::'+fileList);
        return fileList;
    }
    
    
    public class FileDetail{
        
        FileDetail(String fileName, String fileUrl){
            this.fileName = fileName;
            this.fileUrl = fileUrl;
        }
        
        @AuraEnabled public String fileName;
        @AuraEnabled public String fileUrl;
    }
}