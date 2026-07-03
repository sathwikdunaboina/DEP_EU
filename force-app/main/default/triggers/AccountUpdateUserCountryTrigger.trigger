trigger AccountUpdateUserCountryTrigger on Account (before insert) {
    
    // Bypass integration user by Name
    if(UserInfo.getName() == 'Integration User') {
        return;
    }
    
    User currentUser = [
        SELECT Country
        FROM User
        WHERE Id = :UserInfo.getUserId()
        LIMIT 1
    ];
    
    for(Account acc : Trigger.new) {
        if(String.isBlank(acc.BillingCountry)) {
            acc.BillingCountry = currentUser.Country;
        }
    }
}