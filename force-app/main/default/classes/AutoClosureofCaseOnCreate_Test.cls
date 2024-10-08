/**
* -------------------------------------------------------------------------------
* @Name            AutoClosureofCaseOnCreate_Test
* @Author          Aswin Balaji
* @CreatedDate     30/09/2024
* @UsedBy          Trigger Flow
* @Flow Name       Auto Closure of Case OnCreate
* ------------------------------------------------------------------------------
* @Description
* This is a test class for Auto Closure of Case OnCreate flow on Case object to auto close the case when the subject sender and body of the mail
* are similar as we used on metadata
* -------------------------------------------------------------------------------  
*/
@IsTest
public class AutoClosureofCaseOnCreate_Test {
    @TestSetup
    static void setUpCaseData(){
        //Prepare Test User
        String uniqueUserName = 'TestCaseAutoClosureofCaseOnCreate' + DateTime.now().getTime() + '@testorg.com';        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(Alias = 'tstcs', Email='testcaseassignment@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='TestCaseAsgMent', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',
                                 Country = 'Netherlands',UserName=uniqueUserName);
        System.runAs(testUser){
            Id recordTypeId = [Select Id,Name From RecordType Where Name = 'All Case' Limit 1].Id;
            //Create a case
            List<Case> caseList = new List <Case>();
            for(integer i=0; i<=20; i++){
                Case oCase = new Case (Origin='Email', 
                                       Subject ='Fin de Contrat RTFS – Test'+i, 
                                       SuppliedEmail = 'rtfs_services@renault-trucks.com',
                                       Description = 'Nous vous confirmons la bonne fin de votre contrat de financement - Test'+i,
                                       RecordTypeId= recordTypeId);
                caseList.add(oCase);
            }
            
            insert caseList;
            //insert an emailMessage with attachment
            EmailMessage  oEmailMessage = new EmailMessage ();
            oEmailMessage.Subject = 'Fin de Contrat RTFS – Test';
            oEmailMessage.TextBody= 'Nous vous confirmons la bonne fin de votre contrat de financement';
            oEmailMessage.ParentId = caseList[0].Id;
            insert oEmailMessage;
        }
    }
    
    @IsTest
    static void autoCaseClosureMethod(){
        Test.startTest();
        Case oCase = [SELECT Id,SuppliedEmail,Status,Type,Sub_Type__c FROM Case WHERE Subject ='Fin de Contrat RTFS – Test1' Limit 1];
        System.debug(oCase.Type+' pp '+oCase.Sub_Type__c);
        EmailToCaseCloseCriteria__mdt eTCCC = EmailToCaseCloseCriteria__mdt.getInstance('rtfs_services_renault_trucks_com');
        //Assert Functionality
        Assert.areEqual(eTCCC.Label, oCase.SuppliedEmail, 'Expected to get same Subject in the Case'); // Succeeds
        Test.stopTest();
    }
}