/**
* Name of the Trigger    VFSCORE_ContactChangeEventTrigger
* Author                 Aswin Balaji M
* Create Date  		     03-15-2024
* Invoked to 			 VFSCORE_ContactChangeEventTriggerHandler
* SystemLayer		     Trigger
* Description            From the contact Change Events trigger we are sending the records to VFSCORE_ContactChangeEventTriggerHandler
*/
trigger VFSCORE_ContactChangeEventTrigger on ContactChangeEvent (after insert) { 
    new VFSCORE_ContactChangeEventTriggerHandler(Trigger.new).logEvents();  
    new VFSCORE_ContactChangeEventTriggerHandler(Trigger.new).SyncCustomersToVFSSystems();  
}