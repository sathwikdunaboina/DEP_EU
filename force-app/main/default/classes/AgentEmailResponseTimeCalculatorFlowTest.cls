/*
* Subject : Test Class for Agent Email Response Time Calculator flow
* Created by: Hari Vyas 
* Date: 18/03/2026, 
*
 
 */


@IsTest
private class AgentEmailResponseTimeCalculatorFlowTest {

    @IsTest
    static void testEmailMessageFlow() {

        // Create required parent Case
        Case c = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Email'
        );
        insert c;
       //Adding another Email Message 
       EmailMessage email1 = new EmailMessage();
        email1.ParentId = c.Id;
        email1.Subject = 'Test Email';
        email1.TextBody = 'Testing email flow';
        email1.FromAddress = 'test2@test.com';
        email1.ToAddress = 'support@test.com';
        email1.Incoming = true; // matches your flow condition
        email1.Status = '2';
        email1.CreatedDate=System.today().addDays(-1);
        insert email1 ;
        // Create EmailMessage that should trigger the Flow
        EmailMessage email = new EmailMessage();
        email.ParentId = c.Id;
        email.Subject = 'Test Email';
        email.TextBody = 'Testing email flow';
        email.FromAddress = 'test1@test.com';
        email.ToAddress = 'support1@test.com';
        email.Incoming = false; // matches your flow condition
        email.Status = '3';

        Test.startTest();
        insert email;   // Flow triggers here
        Test.stopTest();

        // Query record again if Flow updates something
        EmailMessage insertedEmail = [
            SELECT Id, Incoming, Status
            FROM EmailMessage
            WHERE Id = :email.Id
        ];

        System.assertEquals(false, insertedEmail.Incoming);
        System.assertEquals('3', insertedEmail.Status);
    }
}