/**
* Name of the Trigger    VFSCORE_BnkAccManChangeEventTrigger
* Author                 Aswin Balaji M
* Create Date  		     03-15-2024
* Invoked to 			 VFSCORE_BnkAccManChngeEvntTriggerHandler
* SystemLayer		     Trigger
* Description            From the bank Account Mandate Change Event trigger we are sending the inserted records to VFSCORE_BnkAccManChngeEvntTriggerHandler
*/
trigger VFSCORE_BnkAccManChangeEventTrigger on Bank_Account_Mandate__ChangeEvent (after insert) {
    new VFSCORE_BnkAccManChngeEvntTriggerHandler(Trigger.new).logEvents();  
    new VFSCORE_BnkAccManChngeEvntTriggerHandler(Trigger.new).SyncCustomersToVFSSystems();  
}