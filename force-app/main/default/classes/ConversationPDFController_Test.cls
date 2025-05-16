/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     ConversationPDFController_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-7-2025 
* @Used By            
* ------------------------------------------------------------------------------------------
* @description        This class is used for testing ConversationPDFController
* ------------------------------------------------------------------------------------------
*/
@isTest
private class ConversationPDFController_Test {
    
    // Mock class for HTTP Callout
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            // Simulate a Connect API response
            res.setBody('{' +
                '"conversationEntries": [' +
                '{' +
                '"messageText": "Hello, how can I help you?",' +
                '"serverReceivedTimestamp": 1699999999999,' +
                '"sender": {"role": "Agent"}' +
                '},' +
                '{' +
                '"messageText": "I need assistance with my booking.",' +
                '"serverReceivedTimestamp": 1700000000000,' +
                '"sender": {"role": "Customer"}' +
                '}' +
                ']' +
                '}');

            return res;
        }
    }

    @isTest
    static void testConversationPDFController() {
        
         User thisUser = [
            SELECT Id 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ];
        
        System.runAs ( thisUser ) {
            
            MessagingChannel objMsgChannel = new MessagingChannel();
            objMsgChannel.MasterLabel = 'TestChannel';
            objMsgChannel.DeveloperName = 'TestChannel';
            objMsgChannel.IsActive = true;
            objMsgChannel.MessageType = 'Text'; 
            objMsgChannel.MessagingPlatformKey = 'TestChannel';
            insert objMsgChannel;
            
            MessagingEndUser objMsgUser = new MessagingEndUser();
            objMsgUser.Name = 'Messaging User';
            objMsgUser.MessagingChannelId = objMsgChannel.Id;
            objMsgUser.MessageType = 'EmbeddedMessaging';
            objMsgUser.MessagingPlatformKey = 'TestChannel';
            insert objMsgUser;
            
            MessagingSession objSession = new MessagingSession();
            objSession.MessagingEndUserId = objMsgUser.Id;
            objSession.MessagingChannelId = objMsgChannel.Id;
            objSession.Status = 'New';
            insert objSession;
            System.debug(
                'Id of the Messaging Session is ' + 
                objSession.Id
            );
            
            
            
        }               
        
         MessagingSession session = [
            SELECT Id,Name  FROM MessagingSession
            LIMIT 1
        ];
        
        system.debug('session ==> '+session);
        
        // Set mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Set the session ID as a parameter (simulate VF call)
        PageReference pageRef = Page.ConversationExportVF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', session.Id);

        // Run constructor
        Test.startTest();
        ConversationPDFController controller = new ConversationPDFController();
        Test.stopTest();
         
    }
    
}