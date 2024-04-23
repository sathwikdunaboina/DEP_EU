/***********************************************************************************************************
 * Test Class Name: CreateANewCaseFromOldCaseFlow_Test
 * Test class for: "Create A New Case From 14 Days Old Closed Case" flow
 * Created Date: 9th April 2024 
 * Code coverage for intended Artifact on 9th April 2024: 100%
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      9th April 2024       Infosys                TASK 628022: Stop old cases reopening, 
                                                                  force a new case to be opened
***********************************************************************************************************/
 @isTest(SeeAllData=true)
public class CreateANewCaseFromOldCaseFlow_Test {
    
    
     
    static void setup() {
               UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User owner = new User(
            ProfileId = profileObj.Id,
            UserRoleId = portalRole.Id,
            Username = 'admin@testclass.org' + System.currentTimeMillis(),
            Alias = 'admin',
            FirstName='Firstname',
            Email = 'admin@testclass.org',
            EmailEncodingKey = 'UTF-8',
            Lastname = 'admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago',
            Country='United Kingdom'
        );
        insert owner;
        System.runAs(owner) 
        {
        
    Case caseObj = new Case(Status='Closed', Subject='TestFor14DaysOld',Country__c='United Kingdom',SuppliedEmail='hariram.vyas@consultant.volvo.com',CreatedDate=system.now()-25,ClosedDate=system.now()-14,Type='Spam/Junk',Sub_Type__c='Spam/Junk');
                //Case caseObj = new Case(Status='New', Subject='TestFor14DaysOld',Country__c='United Kingdom',SuppliedEmail='hariram.vyas@consultant.volvo.com');

  EmailMessage newEmailMsg= new EmailMessage();
           newEmailMsg.Subject= 'TestVFS';
           newEmailMsg.FromAddress= 'hariram.vyas@consultant.volvo.com';
           newEmailMsg.ToAddress='test@testto.com';
           newEmailMsg.FromName='testfromName';    
           newEmailMsg.Status='0';
           newEmailMsg.ActivityId=caseObj.Id;
           newEmailMsg.ClientThreadIdentifier=caseObj.Id;
           newEmailMsg.ThreadIdentifier=caseObj.Id;
            newEmailMsg.MessageDate=System.now();
           newEmailMsg.ParentId=caseObj.Id;
            newEmailMsg.RelatedToId=caseObj.Id;
            newEmailMsg.HtmlBody='Test';
           newEmailMsg.TextBody='Test';
           newEmailMsg.Headers='Test';
           newEmailMsg.MessageIdentifier='Test';
           newEmailMsg.ReplyToEmailMessageId=caseObj.Id;
           newEmailMsg.Incoming=true;
      
             //Insert test case record
        insert caseObj;
                     insert newEmailMsg; 

      
        }
     
    }
    @isTest 
    static void CreateNewCaseFromOldCase_Test() {
                    Test.startTest();
   List <EmailMessage> EmailMessageList=[Select Id,ParentId,Subject from EmailMEssage where Subject='TestVFS'];
       for( EmailMessage ca : EmailMessageList){
        //ca.Status='New';
            System.debug('This is Debug emal message' +ca.ParentId);
                       System.debug('This is Debug emal message' +ca.Subject);


        //updatedCaseList.add(ca);
    }
    List<Case> caseList= [Select Id,Status,Subject,ClosedDate,Country__c from Case where Subject='TestFor14DaysOld'];
    List<Case> updatedCaseList=new List<Case>();
     for( Case ca : caseList){
        ca.Status='New';
            System.debug('This is Debug' +ca.Country__c);

        updatedCaseList.add(ca);
    }
   update updatedCaseList;
                Test.stopTest();

    }

}