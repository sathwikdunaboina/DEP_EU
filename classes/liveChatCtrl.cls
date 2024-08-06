public without sharing class liveChatCtrl {
     @AuraEnabled
    public static User getContactDetail() {

        Id userId = UserInfo.getUserId();
        
        User user = [
            SELECT Id,
            ContactId,
            Contact.Name,
            Contact.Email,
            Contact.Phone,
            Contact.MailingCountry,
            Country
            FROM User
            WHERE Id = :userId
        ];
        
        return user;
        
    }

}