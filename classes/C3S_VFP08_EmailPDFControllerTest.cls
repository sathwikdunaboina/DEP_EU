/**
* @author hari
* @date June 2022
* @description Test for class  C3S_VFP08_EmailPDFController
* @group Test 
*/
@isTest
public class C3S_VFP08_EmailPDFControllerTest {

    public static testMethod void EmailPDFControllerTest(){
		EmailMessage email = new EmailMessage(
            BccAddress                  = 'test@test.fr',
            CcAddress                   = 'test@test.fr',
            FromAddress                 = 'test@test.fr',
            FromName                    = 'test',
            HtmlBody                    = '<h1>Test</h1>',
            MessageDate                 = system.today(),
            Subject                     = 'Test 123',
            Status                      = '0',
            TextBody                    = 'Test',
            ToAddress                   = 'test@test.fr',
            Incoming					= true
        );
        insert email;
        
		test.startTest();
        C3S_VFP08_EmailPDFController emailController = new C3S_VFP08_EmailPDFController();
        emailController.email = email;
        EmailMessage emailMessage = emailController.getEmailMessage();
        String dateFormat =  emailController.getMessageDate();
        test.stopTest();
        
        system.assert(emailMessage.Id == email.Id && dateFormat == email.MessageDate.format('HH:mm | dd MMM YYYY', UserInfo.getTimeZone().getID()));
    }
    
}