trigger MessagingEndUserTrigger on MessagingEndUser (before insert) {
    
   if(Trigger.isInsert && Trigger.isBefore){
        MessagingEndUserTriggerHandler messagingEndUserTriggerHandlerInstance = new MessagingEndUserTriggerHandler();
        messagingEndUserTriggerHandlerInstance.handleBeforeInsert(Trigger.new);
   }

}