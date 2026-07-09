/*
 * #Script for sending the monthly deactivation report to the key users
 * Written By Hari Vyas on 31 Oct 2023
 * 
 * 
 * 
 *
*/

public without sharing class DeactivationReportController{
    
    //Generate report Based on parameter
  @future(callout=true)  public Static void generateReport(string reportDevName)
    {
        try
        {
            List <Report> reportList = [SELECT Id,DeveloperName,Name FROM Report where DeveloperName =:reportDevName];
            if(reportList.size()>0)
            {
                String reportId = (String)reportList.get(0).get('Id');
                
                //Get Report Name
                string reportName=(String)reportList.get(0).get('Name');
                
                //get instance Url
               String instanceName = URL.getOrgDomainURL().toExternalForm();

                 
               // String instanceName = URL.getSalesforceBaseUrl().toExternalForm();
                
                string url=instanceName+'/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId='+reportId;
                
                ApexPages.PageReference objPage = new ApexPages.PageReference(url);
                Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
               
                Messaging.EmailFileAttachment objMsgEmailAttach = new Messaging.EmailFileAttachment();
                objMsgEmailAttach.setFileName(reportName+'.csv');
                if(!test.isRunningTest()){
                    objMsgEmailAttach.setBody(objPage.getContent());
                }
                
                objMsgEmailAttach.setContentType('text/csv');
                email.setSubject(reportName);
                
                List<Messaging.EmailFileAttachment> attach=new List<Messaging.EmailFileAttachment>();
                attach.add(objMsgEmailAttach);
                email.setFileAttachments(attach);  
                
               List<Messaging.SingleEmailMessage> mails = 
                 new List<Messaging.SingleEmailMessage>();
                List<String> sendTo = new List<String>();
     
                Map<String, Country_Key_Users__mdt> mapEd = Country_Key_Users__mdt.getAll();

                //System.debug('This is map'+mapEd);
                for(String keyUserNames : mapEd.keySet()){
                System.debug('----->'+mapEd.get(keyUserNames).Key_User_Email__c);
                sendTo.add(mapEd.get(keyUserNames).Key_User_Email__c);

                 }

       
      
      email.setToAddresses(sendTo);
     
      // Step 3: Set who the email is sent from
      email.setReplyTo('vfs.support.salesforce@volvo.com');
      email.setSenderDisplayName('VFS Salesforce Support');
    
      // (Optional) Set list of people who should be CC'ed
      List<String> ccTo = new List<String>();
      email.setSubject('Monthly User Deactivation Report');
      String body = 'Dear Users,<br>';
      body += 'Attached report has users who did not logged ';
      body += 'into sales or service connect since last 90 days.<br>';
      body += 'If you would like this user to be deactivated from sales or service connect, ';
      body += 'we request you to please raise a faros request for the same.<br>';
      body += 'Regards,<br>';
      body += 'VFS Sales & Service Connect Team.';


      email.setHtmlBody(body);
          
      List<String> ccTot = new List<String>();
      //ccTot.add('');
      email.setCcAddresses(ccTot);
      mails.add(email);
      Messaging.sendEmail(mails);

            }
        }
        catch(Exception ex)
        {
           system.debug(ex.getMessage());
        }
    }
  
}