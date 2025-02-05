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
        
        MessagingChannel messagingChannel = new MessagingChannel();
        messagingChannel.MasterLabel = 'Test Channel';
        messagingChannel.DeveloperName = 'Test_Channel';
        messagingChannel.IsActive = true;
        messagingChannel.MessageType = 'Text'; 
        messagingChannel.MessagingPlatformKey = '71823b51-1111-2222-3333-211e1143ce85';

        insert messagingChannel;
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
          System.runAs(new User(Id = UserInfo.getUserId())){
              Test.startTest();
              MessagingEndUserTriggerHandler messagingEndUserTriggerHandlerInstance = new MessagingEndUserTriggerHandler();
              messagingEndUserTriggerHandlerInstance.handleBeforeInsert(listMessagingEndUser);
              
              List<MessagingEndUser> oMessagingEndUser = [Select Id,MessagingPlatformKey FROM MessagingEndUser LIMIT 1];
              Test.stopTest();
              
              
          }
        
       
        
    }
    
}