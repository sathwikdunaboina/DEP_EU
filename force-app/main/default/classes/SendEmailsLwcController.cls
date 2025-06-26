/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     SendEmailsLwcController
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       23 May 2025
* @Used By            sendEmailsLwc 
* @Test Covered By    SendEmailsLwcController_Test
* @SystemLayer        Controller
* ------------------------------------------------------------------------------------------
* @description       This class is used for handling business logic for sendEmailsLwc.
* ------------------------------------------------------------------------------------------
*/ 
public with sharing class SendEmailsLwcController {
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     sendEmailsToContacts
* @description     Send emails to Contacts
* ------------------------------------------------------------------------------------------------------
* @param          listContactIds     List of selected contacts Ids
* @param          sBaseEmailBody     Edited Mail body
* @param          sSubject           Edited Mail Subject
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
    @AuraEnabled
    public static void sendEmailsToContacts(List<Id> listContactIds, String sBaseEmailBody ,   String sSubject) {
        List<Messaging.SingleEmailMessage> listEmailMessage = new List<Messaging.SingleEmailMessage>();
        List<Email_Log__c> emailLogs = new List<Email_Log__c>();
        
        
        List<Contact> listcontacts = [SELECT Id, Email, FirstName , lastname FROM Contact WHERE Id IN :listContactIds AND Email != null WITH USER_MODE];
        OrgWideEmailAddress oOwea = new OrgWideEmailAddress();
        oOwea = [Select Id,Address from OrgWideEmailAddress Where Address = 'vfs.support.salesforce@volvo.com'];
        
        for (Contact con : listcontacts) {
             String sPersonalizedEmailBody = System.Label.Hi_Label +' ' + con.FirstName + ' ' +con.lastName +  ',<br/><br/>' + sBaseEmailBody ;
            
            // Create and configure email message
            Messaging.SingleEmailMessage oMail = new Messaging.SingleEmailMessage();
            oMail.setTargetObjectId(con.Id); // Link to Contact
            oMail.setSaveAsActivity(true); // Create EmailMessage record
            oMail.setSubject(sSubject);
            oMail.setHtmlBody(sPersonalizedEmailBody);
            if (oOwea != null) {
                oMail.setOrgWideEmailAddressId(oOwea.Id);
            }
            listEmailMessage.add(oMail);
            
        }
        
        if (!listEmailMessage.isEmpty()) {
            Messaging.sendEmail(listEmailMessage);
        }        
    }
    
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getEmailTemplateDetails
* @description     Get Classic Email Template Details
* ------------------------------------------------------------------------------------------------------
* @param          templateId            Selected Email Template Id from Flow
* @return         EmailTemplateWrapper  Email Template Wrappper 
* ------------------------------------------------------------------------------------------------------ 
*/
    @AuraEnabled(cacheable=true)
    public static EmailTemplateWrapper getEmailTemplateDetails(Id templateId) {
        EmailTemplate oEmailTemplate = [
            SELECT Id, Name, Subject, HtmlValue
            FROM EmailTemplate
            WHERE Id = :templateId WITH USER_MODE
            LIMIT 1
        ];
        
        EmailTemplateWrapper emailTemplateWrap = new EmailTemplateWrapper();
        emailTemplateWrap.sSubject = oEmailTemplate.Subject;
        emailTemplateWrap.sHtmlBody = oEmailTemplate.HtmlValue;
        return emailTemplateWrap;
    }
    
    
    public class EmailTemplateWrapper {
        @AuraEnabled public String sSubject;
        @AuraEnabled public String sHtmlBody;
    }
}