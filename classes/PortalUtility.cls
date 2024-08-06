public without sharing class PortalUtility {
    @AuraEnabled
    public static Id getAccountId() {
        Contact contact = getContactDetail();
        return contact.AccountId;
    }
    
    @AuraEnabled
    public static Contact getContactDetail() {
        Id userId = UserInfo.getUserId();
        
        User user = [
            SELECT Id,
            ContactId
            FROM User
            WHERE Id = :userId
        ];
        
        Id contactId = user.ContactId;
        
        if(contactId == null){ // Added by Sumit, for portal service development; Kindly delete it before deployment as Code is not needed
            contactId = '0036E00000jq3fGQAQ';
        }        
        
        List<Contact> contact = [
            SELECT
            Id,
            Name,
            Email,
            Phone,
            MailingStreet,
            MailingCity,
            MailingState,
            MailingPostalCode,
            //Document_Notification__c,
            AccountId,
            Account.Name,
            Account.Phone,
            Account.BillingAddress,
            Account.BillingStreet,
            Account.BillingCity,
            Account.BillingState,
            Account.BillingPostalCode,
            //Account.Customer_Community_Access__c,
            //Account.CS_Team__c,
            Account.Branding__c
            FROM Contact
            WHERE Id = :contactId
        ];
        return contact[0];
    }
}