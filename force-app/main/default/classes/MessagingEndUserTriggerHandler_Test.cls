/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     MessagingEndUserTriggerHandler_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       12 December 2024        
* ------------------------------------------------------------------------------------------
* @description        This class is used to test MessagingEndUserTriggerHandler
* ------------------------------------------------------------------------------------------
*/
@isTest
private class MessagingEndUserTriggerHandler_Test {
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @testSetup static void setUpData() {
        
        MessagingEndUser  oMsgUser = new MessagingEndUser();
        oMsgUser.MessagingPlatformKey = '554112345679';
        oMsgUser.MessageType = 'WhatsApp';
        oMsgUser.MessagingConsentStatus = 'ExplicitlyOptedIn';
        oMsgUser.Name = 'test user';
        
        try{
            insert oMsgUser;
        }
        catch(exception e){
        }
    }
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testMessagingEndUserHandler
* @description     This method test MessagingEndUserTriggerHandler 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/   
    @isTest
    private static void testMessagingEndUserHandler(){
        
        List<MessagingEndUser> listMessagingEndUser = new List<MessagingEndUser>();
        
        MessagingEndUser  oMsgUser = new MessagingEndUser();
        oMsgUser.MessagingPlatformKey = '554112345679';
        oMsgUser.MessageType = 'WhatsApp';
        oMsgUser.MessagingConsentStatus = 'ExplicitlyOptedIn';
        oMsgUser.Name = 'test user';
        
        listMessagingEndUser.add(oMsgUser);
        
        Test.startTest();
        MessagingEndUserTriggerHandler messagingEndUserTriggerHandlerInstance = new MessagingEndUserTriggerHandler();
        messagingEndUserTriggerHandlerInstance.handleBeforeInsert(listMessagingEndUser);
        Test.stopTest();
        
    }
    
}