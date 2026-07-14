/**
* @author Hari
* @date 
* @description Controller for visuaforce page C3S_VFP08_EmailPDF
* @group Visualforce
*/
public with sharing class C3S_VFP08_EmailPDFController {

    public EmailMessage email;

    public C3S_VFP08_EmailPDFController() {
        if(ApexPages.currentPage().getParameters().get('id') != null)
        {
            email = [SELECT Id, FromAddress, ToAddress, CcAddress, Subject, MessageDate, HtmlBody FROM EmailMessage 
                       WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        }
    }

    public EmailMessage getEmailMessage() {
        return email;
    }

    public String getMessageDate() {
        //if(email != null) {
        	return email.MessageDate.format('HH:mm | dd MMM YYYY', UserInfo.getTimeZone().getID());
        //} 
        //else {
          //  return '';
       // }
    }
    
}