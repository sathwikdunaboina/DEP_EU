global with sharing class PDFButlerDocumentGenServiceHandler implements CalculatorAPI.IDocumentGeneratorServiceHandler{
    global String getQuotePDFContent(String oppId, String quoteStatus){
          cadmus_core.ConvertController.ConvertDataModel cdm = new cadmus_core.ConvertController.ConvertDataModel(); 
          cdm.objectId = oppId; //this must be the Id of the record you want to generate from eg an Opportunity Id 
          String brand= getLoggedInUserBrand();
          cadmus_core__Doc_Config__c docConfig=[SELECT Id,Name FROM cadmus_core__Doc_Config__c where Name=:brand+' - '+quoteStatus];
          cdm.docConfigId = docConfig.Id;
          cadmus_core.DocGenerationWrapper wrapper = cadmus_core.ConvertController.convertWithWrapper(cdm); 
          return EncodingUtil.base64Encode(wrapper.response.base64) ;
    }
    @TestVisible
    private static String getLoggedInUserBrand(){
      Id userId=userInfo.getUserId(); //to get current user logged in details
      User u=[Select id,Brand__c from User where Id=:userId];//d
      if(String.isNotBlank(u.Brand__c)){
          Brand__c loggedInUserBrand=[Select id,Name from Brand__c where Name=:u.Brand__c];
          if(loggedInUserBrand != null){
            return loggedInUserBrand.Name;  // return logged in user Brand
          }

      }
      return null;
        
    } 

}