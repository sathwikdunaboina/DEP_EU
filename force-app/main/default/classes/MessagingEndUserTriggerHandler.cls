/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     MessagingEndUserTriggerHandler
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       12 December 2024
* @Used By            MessagingEndUserTrigger
* @Test Covered By    MessagingEndUserTriggerHandler_Test
* @SystemLayer        Handler
* ------------------------------------------------------------------------------------------
* @description       This class is used for handling business logic for MessagingEndUserTrigger.
* ------------------------------------------------------------------------------------------
*/ 
public class MessagingEndUserTriggerHandler { 
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     handleBeforeInsert
* @description     - Handles before insert event for MessagingEndUserTrigger
* ------------------------------------------------------------------------------------------------------
* @param          listMessagingEndUser     MessagingEndUser New List records
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    public  void handleBeforeInsert(List<MessagingEndUser> listMessagingEndUser){
        system.debug('handleBeforeInsert called');
        for(MessagingEndUser messagingEndUser : listMessagingEndUser){
            system.debug('messagingEndUser ==> '+messagingEndUser);
            if(messagingEndUser.MessageType == 'WhatsApp'){
                 messagingEndUser.MessagingPlatformKey = messagingEndUser.MessagingPlatformKey.replaceAll('[^0-9.]', '') ;
            }
        }
    }  
}