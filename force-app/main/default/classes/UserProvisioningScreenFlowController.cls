public with sharing class UserProvisioningScreenFlowController {    

    @invocableMethod public static void provisionUsers(List<UserProvisioningScreenInput> userProvisionReqs) {
    try{
        List<UserProvisionRequest> createUserReqs = new List<UserProvisionRequest>();
        List<UserProvisionRequest> deActivateUserReqs = new List<UserProvisionRequest>();
        Map<String,String> mapOfRoleNameByRoleCode = new Map<String,String>();
        Map<String,String> mapOfCountryCodeByCountryName = new Map<String,String>();
        UserProvisioningService ups = new TemplateBasedUserProvisioningService();

        for(User_Role_Abbreviation__mdt mDTData : [Select Label,DeveloperName,Full_Role_Name__c,Abbreviation__c From User_Role_Abbreviation__mdt]){
            mapOfRoleNameByRoleCode.put(mDTData.Full_Role_Name__c,mDTData.Abbreviation__c);
        }
        for(VFS_Country_Setting__mdt mDTData : [Select Label,DeveloperName From VFS_Country_Setting__mdt]){
            mapOfCountryCodeByCountryName.put(mDTData.Label,mDTData.DeveloperName);
        }
        system.debug(userProvisionReqs);
        for(UserProvisioningScreenInput userReq : userProvisionReqs){
            system.debug(userReq.requestType);
            if(userReq.requestType == 'Revoke'){
                UserProvisionRequest uProvisionReq = new UserProvisionRequest();
                uProvisionReq.federationId = userReq.federationId;
                uProvisionReq.existingUserName = userReq.username;
                deActivateUserReqs.add(uProvisionReq);
            }
            else if(userReq.requestType == 'Add'){
                UserProvisionRequest uProvisionReq = new UserProvisionRequest();
                
                uProvisionReq.firstName = userReq.firstName;
                uProvisionReq.lastName = userReq.lastName;
                uProvisionReq.email = userReq.email;
                uProvisionReq.federationId = userReq.federationId;
                uProvisionReq.roleName = mapOfRoleNameByRoleCode.get(userReq.roleName);
                uProvisionReq.brand = userReq.brand.replace('and','').replace(' ','');
                uProvisionReq.countryCode = userReq.country;
                uProvisionReq.existingUserName = userReq.username;
                uProvisionReq.requestType = userReq.requestType;
                createUserReqs.add(uProvisionReq);
            }
        }
        if(createUserReqs.size()>0){
            system.debug(createUserReqs);
            ups.createUsers(createUserReqs);
        }
        if(deActivateUserReqs.size()>0){
            ups.deActivateUsers(deActivateUserReqs);         	
        }
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
        @invocableVariable public String brand;
        @invocableVariable public String email;
        @invocableVariable public String federationId;
        @invocableVariable public String country;
        @invocableVariable public String roleName;
        @invocableVariable public String requestType;
        @invocableVariable public String countryCode;
        @invocableVariable public String username;
    }


}