public with sharing class UserManagementController {
    
    @AuraEnabled(cacheable=true)
    public static List<User> getUsers(String searchKey) {
        String searchFilter = '%' + searchKey + '%';
        return [
            SELECT Id, Name, Email,Profile.Name, IsActive 
            FROM User 
            WHERE Name LIKE :searchFilter OR Email LIKE :searchFilter OR Profile.Name LIKE : searchFilter
            LIMIT 50
        ];
    }

    @AuraEnabled
    public static void updateUserStatus(List<Id> userIds, Boolean isActive) {
        List<User> usersToUpdate = [SELECT Id, IsActive FROM User WHERE Id IN :userIds];
        for (User u : usersToUpdate) {
            u.IsActive = isActive;
        }
        update usersToUpdate;
    }
}