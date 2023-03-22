trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
	//Need to extend the contract documents to portal users.
    for (ContentDocumentLink cLink : Trigger.New){
        //If the document is attached to the contract record, 
        //then the external users who has access to the contract record
        //should also have access to the document.
        if('Contract__c'.equalsIgnoreCase(cLink.LinkedEntityId.getSObjectType().getDescribe().getName())){
            cLink.Visibility = 'AllUsers';
            cLink.ShareType = 'I';
        }
    }
}