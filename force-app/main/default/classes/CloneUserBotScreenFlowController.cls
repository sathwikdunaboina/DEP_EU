public with sharing class CloneUserBotScreenFlowController {  

    @invocableMethod public static List<UserProvisioningResult> provisionUsers(List<UserProvisioningScreenInput> userProvisionReqs) {
    try{
        List<UserProvisionRequest> createUserReqs = new List<UserProvisionRequest>();
        List<user> provisionedUsers = new List<user>();
        UserProvisioningService ups = new UserBasedUserProvisioningService();
        system.debug(userProvisionReqs);
        for(UserProvisioningScreenInput userReq : userProvisionReqs){
                UserProvisionRequest uProvisionReq = new UserProvisionRequest();                
                uProvisionReq.firstName = userReq.firstName;
                uProvisionReq.lastName = userReq.lastName;
                uProvisionReq.email = userReq.email;
                uProvisionReq.federationId = userReq.federationId;
                uProvisionReq.existingUserName = userReq.username;
                uProvisionReq.requestType = 'Add';
                createUserReqs.add(uProvisionReq);            
        }
        if(createUserReqs.size()>0){
            system.debug(createUserReqs);
            provisionedUsers = ups.createUsers(createUserReqs);            
        }
        for (Integer i = 0; i < userProvisionReqs.size(); i++) {   
            userProvisionReqs[i].provisionedUserId = provisionedUsers[i].Id;
		}
        UserProvisioningResult upr = new UserProvisioningResult();
        upr.provisioningResult = JSON.Serialize(userProvisionReqs);
        List<UserProvisioningResult> uprs= new List<UserProvisioningResult>();
        uprs.add(upr);        
        return uprs;
    }
    catch (Exception e) {
        System.debug('Error: ' + e.getMessage());
        ErrorLogUtil.asyncLogError(e, 'UserProvisionRequest', '-');
        throw e;
        }
    }

    public class UserProvisioningScreenInput {
        @invocableVariable public String firstName;
        @invocableVariable public String lastName;        
        @invocableVariable public String email;
        @invocableVariable public String federationId;        
        @invocableVariable public String requestType;
        @invocableVariable public String username;
        @invocableVariable public string provisionedUserId;
    }
    
    public class UserProvisioningResult{
       @invocableVariable public string provisioningResult; 
    }
}