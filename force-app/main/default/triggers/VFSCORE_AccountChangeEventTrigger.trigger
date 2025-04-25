/**
* Name of the Trigger    VFSCORE_AccountChangeEventTrigger
* Author                 Alok Kumar
* Create Date  		     03-14-2024
* Invoked to 			 VFSCORE_AccountChangeEventTriggerHandler
* SystemLayer		     Trigger
* Description            From the bank Account Change Event trigger we are sending the inserted records to VFSCORE_AccountChangeEventTriggerHandler
*/
trigger VFSCORE_AccountChangeEventTrigger on AccountChangeEvent (after insert) { 
VFSCORE_AccountChangeEventTriggerHandler accChgEventTrgHandler = new VFSCORE_AccountChangeEventTriggerHandler(Trigger.new);
accChgEventTrgHandler.logEvents();
accChgEventTrgHandler.SyncCustomersToVFSSystems();  
}