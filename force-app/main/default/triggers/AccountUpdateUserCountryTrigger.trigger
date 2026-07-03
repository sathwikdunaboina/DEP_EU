trigger AccountUpdateUserCountryTrigger on Account (before insert) {
 
   /* User currentUser = [
        SELECT Profile.Name
        FROM User
        WHERE Id = :UserInfo.getUserId()
        LIMIT 1
    ];
 
    // Bypass for Integration User (API Only Profile)
    if (currentUser.Profile.Name == 'API Only') {
        return;
    }
 
    Set<Id> ownerIds = new Set<Id>();
 
    for (Account acc : Trigger.new) {
        if (acc.OwnerId != null) {
            ownerIds.add(acc.OwnerId);
        }
    }
 
    Map<Id, User> userMap = new Map<Id, User>(
        [SELECT Id, Country
         FROM User
         WHERE Id IN :ownerIds]
    );
 
    for (Account acc : Trigger.new) {
        User owner = userMap.get(acc.OwnerId);
 
        if (owner != null) {
            acc.BillingCountry = owner.Country;
        }
    } */
}