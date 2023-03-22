public class PortalCampaignCarouselController {
    @AuraEnabled
    public static VFS_Campaign__c[] fetchActiveCampaigns(){
        //Logged in users country
        User user = [SELECT Country, Account.Branding__c FROM User WHERE Id = :UserInfo.getUserId()][0];
        String brand = user.Account != null ? user.Account.Branding__c : null;
        return [SELECT Name, Description__c, Image_URL__c 
               	FROM VFS_Campaign__c
               	WHERE Active__c = TRUE
                	AND Country__c = :user.Country
               		AND Start_Date__c <= :System.today()
               		AND END_Date__c >= :System.today() 
                	AND Brand__c includes (:brand)
               		];
    }
}