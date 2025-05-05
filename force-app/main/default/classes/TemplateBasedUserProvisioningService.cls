public virtual class TemplateBasedUserProvisioningService extends UserProvisioningService{
    
    private Map<string,User> mapOfTemplateUsersByUserName;
    private Map<Id,user> mapOfTemplateUsersById;
    
    protected List<user> prepareUserVariables(List<UserProvisionRequest> validUserRequests){
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        System.Domain sandboxName = System.DomainParser.parse(URL.getOrgDomainUrl());
        Set<string> templateUserNames = mapOfTemplateUsersByUserName.keySet();
        this.mapOfTemplateUsersById = new Map<Id,User>([SELECT FIELDS(STANDARD),(SELECT Id,AssigneeId,PermissionSetId,PermissionSet.IsOwnedByProfile,PermissionSetGroupId FROM PermissionSetAssignments WHERE IsActive = true ) FROM User
                                                        WHERE username IN :templateUserNames WITH SYSTEM_MODE]);
        for(User templateUser : mapOfTemplateUsersById.values()){
            mapOfTemplateUsersByUserName.put(templateUser.username, templateUser);
        }                               
        List<user> usersToCreate = new List<user>();
        for(UserProvisionRequest userReq : validUserRequests){
            string userRequestUserName;
            if(runningInASandbox){
                userRequestUserName = string.ValueOf(userReq.roleName+'_'+userReq.countryCode+'_'+userReq.brand+'@template.user.'+sandboxName.getSandboxName()).toLowerCase(); 
            }
            else{
                userRequestUserName = string.ValueOf(userReq.roleName+'_'+userReq.countryCode+'_'+userReq.brand+'@template.user').toLowerCase();   
            }
            User templateUser = mapOfTemplateUsersByUserName.get(userRequestUserName);
            if(templateUser != null){
                system.debug(templateUser);
                User clonedUser = templateUser.clone(false,true,false,false);            
                clonedUser.FirstName = userReq.firstName;
                clonedUser.LastName = userReq.lastName;    
                clonedUser.FederationIdentifier = userReq.federationId;
                clonedUser.templateUserId__c = templateUser.Id;
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
        this.mapOfTemplateUsersByUserName = new Map<string,User>(); 
        List<UserProvisionRequest> validUserRequests = new List<UserProvisionRequest>();
        for(UserProvisionRequest userReq : userReqs){
            if(userReq.firstName != null 
               && userReq.lastName != null
               && userReq.email != null
               && userReq.federationId != null
               && userReq.roleName != null
               && userReq.brand != null
               && userReq.countryCode != null
               && userReq.requestType != null
              ){
                  validUserRequests.add(userReq);
                  if(runningInASandbox){
                      mapOfTemplateUsersByUserName.put(string.ValueOf(userReq.roleName+'_'+userReq.countryCode+'_'+userReq.brand+'@template.user.'+sandboxName.getSandboxName()).toLowerCase(),null);
                  }
                  else{
                      mapOfTemplateUsersByUserName.put(string.ValueOf(userReq.roleName+'_'+userReq.countryCode+'_'+userReq.brand+'@template.user').toLowerCase(),null);
                  }
                  system.debug(mapOfTemplateUsersByUserName);
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
            .AssignPermissionSetsFromTemplate(this.mapOfTemplateUsersById)
            .AssignPublicGroupAndQueueFromTemplate(this.mapOfTemplateUsersById)
            .SaveAssignments()
            .getUsers();  
    }
}