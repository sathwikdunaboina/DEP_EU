/**
* Name of the class    ListService
* Author               Aswin Balaji M
* Create Date  		   03-15-2024
* Used by 			   Handler
* Handler Name		   VFSCORE_ContactChangeEventTriggerHandler, VFSCORE_BnkAccManChngeEvntTriggerHandler, VFSCORE_BnkAccChangeEventTriggerHandler, VFSCORE_AccountChangeEventTriggerHandler
* SystemLayer		   Utility
* Description          This Utility class used to split the records if it more than 100. Ex: If 225 records are there, then this method will send 100,100 and 25 records every time when it invokes.
*/
public class ListService {
    public static List<Id> slice(List<Id> input, Integer ge, Integer l) {
        List<Id> listOutputId = input.clone();
        for (Integer i = 0; i < ge; i++) listOutputId.remove(0);
        Integer elements = l - ge;    while (listOutputId.size() > elements) listOutputId.remove(elements);
        return listOutputId;
    }
}