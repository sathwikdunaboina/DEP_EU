/**
* Name of the Trigger    VFSCORE_BankAccountChangeEventTrigger
* Author                 Aswin Balaji M
* Create Date  		     03-15-2024
* Invoked to 			 VFSCORE_BankAccountChangeEventTriggerHandler
* SystemLayer		     Trigger
* Description            From the bank Account Change Event trigger we are sending the inserted records to VFSCORE_BnkAccChangeEventTriggerHandler
*/
trigger VFSCORE_BankAccountChangeEventTrigger on Bank_Account__ChangeEvent (after insert) {
    new VFSCORE_BnkAccChangeEventTriggerHandler(Trigger.new).logEvents();
    new VFSCORE_BnkAccChangeEventTriggerHandler(Trigger.new).SyncCustomersToVFSSystems(); 
}