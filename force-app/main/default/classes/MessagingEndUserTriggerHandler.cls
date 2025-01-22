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
        for(MessagingEndUser messagingEndUser : listMessagingEndUser){
            messagingEndUser.MessagingPlatformKey =  isInboundMessagingUserBrazil(messagingEndUser) ? getUpdatedMessagingPlatformKeyForBrazilUser(messagingEndUser.MessagingPlatformKey) : messagingEndUser.MessagingPlatformKey;
        }
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     isInboundMessagingUserBrazil
* @description     Checks if Messaging User is inbound whatsapp from Brazil
* ------------------------------------------------------------------------------------------------------
* @param          MessagingEndUser     MessagingEndUser record
* @return         Boolean
* ------------------------------------------------------------------------------------------------------ 
*/
    private Boolean isInboundMessagingUserBrazil(MessagingEndUser oMessagingUser){
        if(oMessagingUser.MessageType == 'WhatsApp' && oMessagingUser.MessagingPlatformKey.startsWith('55') 
           && oMessagingUser.MessagingPlatformKey.length() == 12 ){
               return true;       
           }
        else{
            return false;
        }
    }  
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getUpdatedMessagingPlatformKeyForBrazilUser
* @description     Update Messagingplayformkey for inbound whatsapp brazil messaging users , append
9 in between the messagingplatformkey to match it with new format on related account
* ------------------------------------------------------------------------------------------------------
* @param          MessagingEndUser     MessagingEndUser record
* @return         Boolean
* ------------------------------------------------------------------------------------------------------ 
*/
    private String getUpdatedMessagingPlatformKeyForBrazilUser(String sMessagtePlatformKey){
        sMessagtePlatformKey = sMessagtePlatformKey.substring(0, 4) + '9' + sMessagtePlatformKey.substring(4);
        return  sMessagtePlatformKey ;  
    }
    
    
    
}