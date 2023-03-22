/*
* 
* Created by : Harshit : 8 August 19
* Assigns Footer links for disclaimer from custom setting Footer Link 
* Modified by : Sumit Sharma : 27 August 19
* Modified by : Harshit : 20 December 19 Added null checks and try catch for content distribution
*/
public without sharing class  complianceFooter {
    @AuraEnabled
    public static  List<Footer_link__c> getPublicLinks() 
    {
        User userObj = [SELECT Country, LanguageLocaleKey FROM User WHERE Id =: UserInfo.getUserId()];
        List<Footer_link__c> lstLinkSettings = Footer_link__c.getall().values(); 
        system.debug(lstLinkSettings);
        List<Footer_link__c> links = new List <Footer_link__c>(); 
        String contDocId;
        system.debug(lstLinkSettings.size());
        for (Integer i=0 ; i<lstLinkSettings.size() ; i++)
        {
            system.debug('in For Loop');
            system.debug(lstLinkSettings[i].Country__c);
            system.debug(lstLinkSettings[i].Language__c);
            if(lstLinkSettings[i].Country__c.equalsIgnoreCase(userObj.Country) && 
               lstLinkSettings[i].Language__c.equalsIgnoreCase(userObj.LanguageLocaleKey)
               && lstLinkSettings[i].Type__c.equalsIgnoreCase( 'Local')){
                   system.debug('in Local');
                   contDocId = lstLinkSettings[i].Document_Link__c;
                   lstLinkSettings[i].Document_Link__c = setDocLink(contDocId);
                   links.add(lstLinkSettings[i]);
                   system.debug(lstLinkSettings[i]);
               }
            
            if(lstLinkSettings[i].Country__c.equalsIgnoreCase(userObj.Country) && 
               lstLinkSettings[i].Language__c.equalsIgnoreCase(userObj.LanguageLocaleKey)
               && lstLinkSettings[i].Type__c.equalsIgnoreCase( 'GDPR')){
                   system.debug('GDPR');
                   contDocId = lstLinkSettings[i].Document_Link__c;
                   lstLinkSettings[i].Document_Link__c = setDocLink(contDocId);
                   links.add(lstLinkSettings[i]);
                    system.debug(lstLinkSettings[i]);
               }
        }
        return links;
    }
    
    public static String setDocLink(String contentDocId){
        Try{
            system.debug('in setDocLink ' + contentDocId );
            ContentDistribution contDistObj = [SELECT ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId =: contentDocId AND PreferencesLinkLatestVersion = true LIMIT 1];
             system.debug(contDistObj);
            If (contDistObj.ContentDownloadUrl != NULL){
                 system.debug(contDistObj.ContentDownloadUrl);
                return String.valueOf(contDistObj.ContentDownloadUrl);
                
            }
            else {
                
                return '0';
                
            }  
        }catch (Exception ex) {
            
            throw new AuraHandledException(ex.getMessage()+' '+ex.getCause()+' '+ex.getLineNumber()+' '+ex.getStackTraceString());
        }
    }
}