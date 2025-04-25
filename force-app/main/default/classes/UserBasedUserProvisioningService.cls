public virtual class UserBasedUserProvisioningService extends UserProvisioningService{
    
    private Map<string,User> mapOfReferenceUsersByUserName;
    private Map<Id,user> mapOfReferenceUsersById;
    
    protected List<user> prepareUserVariables(List<UserProvisionRequest> validUserRequests){
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        System.Domain sandboxName = System.DomainParser.parse(URL.getOrgDomainUrl());
        Set<string> ReferenceUserNames = mapOfReferenceUsersByUserName.keySet();
        this.mapOfReferenceUsersById = new Map<Id,User>([SELECT FIELDS(STANDARD),(SELECT Id,AssigneeId,PermissionSetId,PermissionSet.IsOwnedByProfile,PermissionSetGroupId FROM PermissionSetAssignments WHERE IsActive = true ) FROM User
                                                        WHERE username IN :ReferenceUserNames WITH SYSTEM_MODE]);
        for(User ReferenceUser : mapOfReferenceUsersById.values()){
            mapOfReferenceUsersByUserName.put(ReferenceUser.username, ReferenceUser);
        }                               
        List<user> usersToCreate = new List<user>();
        for(UserProvisionRequest userReq : validUserRequests){
            User ReferenceUser = mapOfReferenceUsersByUserName.get(userReq.existingUserName);
            if(ReferenceUser != null){
                system.debug(ReferenceUser);
                User clonedUser = ReferenceUser.clone(false,true,false,false);            
                clonedUser.FirstName = userReq.firstName;
                clonedUser.LastName = userReq.lastName;    
                clonedUser.FederationIdentifier = userReq.federationId;
                clonedUser.TemplateUserId__c = ReferenceUser.Id;
                clonedUser.Alias = clonedUser.firstName.substring(0, 1) + clonedUser.lastName.substring(0, 1); // Create alias based on first and last name
                clonedUser.CommunityNickname = userReq.email+'_'+clonedUser.Alias;
                clonedUser.IsActive = true;
                if(runningInASandbox){
                    clonedUser.Email = userReq.email+'.invalid';
                    clonedUser.username = userReq.email+'.'+sandboxName.getSandboxName();
                }
                else{
                    clonedUser.Email = userReq.email;
                    clonedUser.username = userReq.email;  
                }
                usersToCreate.add(clonedUser);
            }           
        }
        return usersToCreate;
    }
    
    protected override List<UserProvisionRequest> getValidUserRequests(List<UserProvisionRequest> userReqs){
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        System.Domain sandboxName = System.DomainParser.parse(URL.getOrgDomainUrl());
        System.Debug('Inside child getValidUserRequests');
        this.mapOfReferenceUsersByUserName = new Map<string,User>(); 
        List<UserProvisionRequest> validUserRequests = new List<UserProvisionRequest>();
        for(UserProvisionRequest userReq : userReqs){
            if(userReq.firstName != null 
               && userReq.lastName != null
               && userReq.email != null
               && userReq.federationId != null
               && userReq.existingUserName != null
               && userReq.requestType != null
              ){
                  validUserRequests.add(userReq);                  
                  mapOfReferenceUsersByUserName.put(string.ValueOf(userReq.existingUserName).toLowerCase(),null);            
                  system.debug(mapOfReferenceUsersByUserName);
              }
            else{
                //log error for not a valid user request
                ErrorLogUtil.asyncLogErrorForNonCatch('UserProvisioningService','getValidUserRequests','Missing required Parameter: '+String.valueOf(userReq),'UserProvisionRequest','-',53,'Missing paramter');
            }
        }
        return validUserRequests;
    }
    
    protected override List<user> createValidatedUsers(List<user> usersToProvision){
        return new Users(usersToProvision).Create()
            .AssignPermissionSetsFromTemplate(this.mapOfReferenceUsersById)
            .AssignPublicGroupAndQueueFromTemplate(this.mapOfReferenceUsersById)
            .SaveAssignments()
            .getUsers();  
    }
}