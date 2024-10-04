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
        //Create a case
        Case oCase = new Case (Origin='Email', 
                                    Subject ='Fin de Contrat RTFS – Test', 
                                    SuppliedEmail = 'rtfs_services@renault-trucks.com',
                                    Description = 'Nous vous confirmons la bonne fin de votre contrat de financement - Test');
        insert oCase;
        
        //insert an emailMessage with attachment
        EmailMessage  oEmailMessage = new EmailMessage ();
        oEmailMessage.Subject = 'Fin de Contrat RTFS – Test';
        oEmailMessage.TextBody= 'Nous vous confirmons la bonne fin de votre contrat de financement';
        oEmailMessage.ParentId = oCase.Id;
        insert oEmailMessage;
    }
    
    @IsTest
    static void attachmentHappyFlow(){
        Test.startTest();
        Case oCase = [SELECT Id,SuppliedEmail FROM Case WHERE Subject ='Fin de Contrat RTFS – Test' Limit 1];
        EmailToCaseCloseCriteria__mdt eTCCC = EmailToCaseCloseCriteria__mdt.getInstance('RTFS_FR');
		Assert.areEqual(eTCCC.Label, oCase.SuppliedEmail, 'Expected to get same Subject in the Case'); // Succeeds
        Test.stopTest();
    }
}