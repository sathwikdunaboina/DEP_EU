public class ClientCallResource {//change the name of the class
    
    public static void dataFetchFromAPI(String userDatas) {
        UserProvisioningService ups = new TemplateBasedUserProvisioningService();
        Map<String,String>mRoleAbbr = new Map<String,String>();
        Map<String,String>mCountryAbbr = new Map<String,String>();
        for(User_Role_Abbreviation__mdt mDTData : [Select Label,DeveloperName,Full_Role_Name__c,Abbreviation__c From User_Role_Abbreviation__mdt]){
            mRoleAbbr.put(mDTData.Full_Role_Name__c,mDTData.Abbreviation__c);
        }
        for(VFS_Country_Setting__mdt mDTData : [Select Label,DeveloperName From VFS_Country_Setting__mdt]){
            mCountryAbbr.put(mDTData.Label,mDTData.DeveloperName);
        }
        try{
            List<UserProvisionRequest> users = (List<UserProvisionRequest>)JSON.deserialize(userDatas, List<UserProvisionRequest>.class);
            List<UserProvisionRequest> userCreationReqs = new List<UserProvisionRequest>();
            List<String> userRevokeReqs = new List<String>();
            for(UserProvisionRequest obj : users) {
                UserProvisionRequest req = new UserProvisionRequest();
                if(obj.requestType == 'Add'){
                    req.firstName = obj.firstName;
                    req.lastName = obj.lastName;
                    req.email = obj.email;
                    req.federationId = obj.federationId;
                    req.roleName = mRoleAbbr.get(obj.roleName);
                    req.brand = obj.brand.replace('and','').replace(' ','');
                    //req.countryCode = mCountryAbbr.get(obj.country);
                    req.countryCode = obj.country.replace('GB','UK');
                    req.requestType = obj.requestType;
                    system.debug(mCountryAbbr.get(obj.country));
                    userCreationReqs.add(req); 
                }
                else if(obj.requestType == 'Revoke'){
                    userRevokeReqs.add(obj.federationId);
                }
            }
            if(userCreationReqs.isEmpty() == false){
                system.debug(userCreationReqs);
                ups.createUsers(userCreationReqs);
            }
            if(userRevokeReqs.isEmpty() == false){
                //ups.DeactiveUsers(userRevokeReqs);
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
    
    //Make another class for screenflow
    // Define the wrapper class with a list to hold multiple Data objects
    public class InputValuesWrapper {
        @invocableVariable public String firstName;
        @invocableVariable public String lastName;
        @invocableVariable public String brand;
        @invocableVariable public String email;
        @invocableVariable public String federationId;
        @invocableVariable public String country;
        @invocableVariable public String roleName;
        @invocableVariable public String requestType;
        @invocableVariable public String countryCode;
    }
    
    @InvocableMethod public static void createUserFromFlow(List<InputValuesWrapper> flowData) {
        try{
            dataFetchFromAPI(String.valueOf(JSON.serialize(flowData)));
            system.debug(String.valueOf(JSON.serialize(flowData)));
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
}