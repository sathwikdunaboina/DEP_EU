public inherited sharing abstract class UserProvisioningService {
    
    public virtual List<user> createUsers(List<UserProvisionRequest> userReqs){
        //validate user requests
        List<UserProvisionRequest> validUserReqs = this.getValidUserRequests(userReqs);        
        //check license availability
        Integer availableUserLicenseCount = this.getAvailableLicenses('Salesforce');        
        if(validUserReqs != null && validUserReqs.size() < availableUserLicenseCount){
            //prepare user variables
            List<user> usersToProvision = this.prepareUserVariables(validUserReqs);        
            //insert users
            return this.createValidatedUsers(usersToProvision);
        }
        else{
            //log error that not enough license or no valid requests
            System.Debug('No Valid Requests OR No Available Licenses');
            ErrorLogUtil.asyncLogErrorForNonCatch('UserProvisioningService','createUsers','No enough license or No valid requests','UserProvisionRequest','-',8,'Insufficient License or No valid request');
            return null;
        } 
    }
    
    protected virtual List<UserProvisionRequest> getValidUserRequests(List<UserProvisionRequest> userReqs){
        System.Debug('Inside parent getValidUserRequests');
        List<UserProvisionRequest> validUserRequests = new List<UserProvisionRequest>();
        for(UserProvisionRequest userReq : userReqs){
            if(userReq.firstName != null 
               && userReq.lastName != null
               && userReq.email != null
               && userReq.federationId != null
               && userReq.brand != null
               && userReq.roleName != null
               && userReq.requestType != null
               && userReq.countryCode != null){
                   validUserRequests.add(userReq);
               }
            else{
                //log error for not a valid user request
                ErrorLogUtil.asyncLogErrorForNonCatch('UserProvisioningService','getValidUserRequests','Missing required Parameter: '+String.valueOf(userReq),'UserProvisionRequest','-',25,'Missing paramter');
            }
        }
        return validUserRequests;
    }
    
    public Integer getAvailableLicenses(string userLicenseName){
        UserLicense userLic = [SELECT Id, TotalLicenses, UsedLicenses, Name FROM UserLicense where Name = :userLicenseName WITH SYSTEM_MODE LIMIT 1];
        return userLic.TotalLicenses - userLic.UsedLicenses;
    }
    
    abstract List<user> prepareUserVariables(List<UserProvisionRequest> userRequests);
    
    protected virtual List<user> createValidatedUsers(List<user> usersToProvision){
        Users usersObj = new Users(usersToProvision).Create();
        return usersObj.getUsers();        
    }
    
    public virtual void deActivateUsers(List<UserProvisionRequest> userDeactivationReqs){
        //validate user deactivation requests
        Set<String> userNames = new Set<String>();
        Set<String> federationIds = new Set<String>();
        for(UserProvisionRequest userDeactivationReq : userDeactivationReqs){
            if(!String.isEmpty(userDeactivationReq.existingUserName)){
                system.debug(userDeactivationReq.existingUserName);
                userNames.add(String.escapeSingleQuotes(userDeactivationReq.existingUserName));
            }
            else if(userDeactivationReq.federationId != null){
                system.debug(userDeactivationReq.federationId);
                federationIds.add(String.escapeSingleQuotes(userDeactivationReq.federationId));
            }
            else{
                //log error
                ErrorLogUtil.asyncLogErrorForNonCatch('UserProvisioningService','deActivateUsers','Missing required Parameter: '+String.valueOf(userDeactivationReq),'UserProvisionRequest','-',60,'Missing paramter');
            }
        }
        Map<String, Object> userBinds = new Map<String, Object>{'userNames' => userNames,'fedIds' => federationIds};
        string query = 'Select Id From User where username IN :userNames OR federationidentifier IN :fedIds' ;        
        List<user> usersToDeactivate = Database.queryWithBinds(query,userBinds,AccessLevel.USER_MODE);
        Users usersObj = new Users(usersToDeactivate).DeActivate();
    }
}