public virtual class UserProvisioningServiceTestExtension extends UserProvisioningService{
    
    public override List<user> createUsers(List<UserProvisionRequest> userReqs){
        
        return super.createUsers(userReqs);
    }
    
    protected List<user> prepareUserVariables(List<UserProvisionRequest> validUserRequests){
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        System.Domain sandboxName = System.DomainParser.parse(URL.getOrgDomainUrl());
        User usr = new User();
        if(runningInASandbox){
            string userName = 'sm_gb_vt@template.user.'+sandboxName.getSandboxName();
            usr = [SELECT FIELDS(STANDARD),(SELECT Id,AssigneeId,PermissionSetId,PermissionSet.IsOwnedByProfile,PermissionSetGroupId FROM PermissionSetAssignments WHERE IsActive = true )FROM User WHERE UserName =: userName LIMIT 1];
        }
        else{
            usr = [SELECT FIELDS(STANDARD),(SELECT Id,AssigneeId,PermissionSetId,PermissionSet.IsOwnedByProfile,PermissionSetGroupId FROM PermissionSetAssignments WHERE IsActive = true )FROM User WHERE UserName = 'sm_gb_vt@template.user' LIMIT 1]; 
        }        User clonedUser = usr.clone(false,true,false,false); 
        clonedUser.FirstName = validUserRequests[0].firstName;
        clonedUser.LastName = validUserRequests[0].lastName;
        clonedUser.FederationIdentifier = validUserRequests[0].federationId;
        clonedUser.username = validUserRequests[0].email+'.test';
        clonedUser.Email = validUserRequests[0].email+'.invalid';
        clonedUser.Alias = validUserRequests[0].firstName.substring(0, 1) + validUserRequests[0].lastName.substring(0, 1);
        clonedUser.CommunityNickname = validUserRequests[0].email+'_test';
        clonedUser.IsActive = true;
        List<User> usrList = new List <User>();
        usrList.add(clonedUser);
        return usrList;
    }
}