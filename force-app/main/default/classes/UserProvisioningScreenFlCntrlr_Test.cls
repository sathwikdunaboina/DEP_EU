@istest
public class UserProvisioningScreenFlCntrlr_Test {
    static testMethod void userCreationWithPermissionSetAndPublicGroup() {
        List<UserProvisioningScreenFlowController.UserProvisioningScreenInput> listOfInputs = new List <UserProvisioningScreenFlowController.UserProvisioningScreenInput>();
        UserProvisioningScreenFlowController.UserProvisioningScreenInput listOfInput = new UserProvisioningScreenFlowController.UserProvisioningScreenInput();
        listOfInput.firstName = 'testfirstName';
        listOfInput.lastName = 'lastnameTest';
        listOfInput.brand = 'VT';
        listOfInput.roleName = 'Sales Manager';
        listOfInput.requestType = 'Add';
        listOfInput.federationId = 'lastNameTest1';
        listOfInput.country = 'GB';
        listOfInput.countryCode = 'GB';
        listOfInput.email = 'lastname.test@test.com';
        listOfInputs.add(listOfInput);
        UserProvisioningScreenFlowController.provisionUsers(listOfInputs);
    }
    
    static testMethod void userDeActivationUserName() {
        List<UserProvisioningScreenFlowController.UserProvisioningScreenInput> listOfInputs = new List <UserProvisioningScreenFlowController.UserProvisioningScreenInput>();
        UserProvisioningScreenFlowController.UserProvisioningScreenInput listOfInput = new UserProvisioningScreenFlowController.UserProvisioningScreenInput();
        listOfInput.firstName = 'testfirstName';
        listOfInput.lastName = 'lastnameTest';
        listOfInput.brand = 'VT';
        listOfInput.roleName = 'Sales Manager';
        listOfInput.requestType = 'Revoke';
        listOfInput.federationId = '6janTest6';
        listOfInput.country = 'GB';
        listOfInput.countryCode = 'GB';
        listOfInput.email = 'lastname.test@test.com';
        listOfInput.username = 'lastname.test@test.com';
        listOfInputs.add(listOfInput);
        UserProvisioningScreenFlowController.provisionUsers(listOfInputs);
    }
    
    static testMethod void userDeActivationWithFedId() {
        List<UserProvisioningScreenFlowController.UserProvisioningScreenInput> listOfInputs = new List <UserProvisioningScreenFlowController.UserProvisioningScreenInput>();
        UserProvisioningScreenFlowController.UserProvisioningScreenInput listOfInput = new UserProvisioningScreenFlowController.UserProvisioningScreenInput();
        listOfInput.firstName = 'testfirstName';
        listOfInput.lastName = 'lastnameTest';
        listOfInput.brand = 'VT';
        listOfInput.roleName = 'Sales Manager';
        listOfInput.requestType = 'Revoke';
        listOfInput.federationId = '6janTest6';
        listOfInput.country = 'GB';
        listOfInput.countryCode = 'GB';
        listOfInput.email = 'lastname.test@test.com';
        //listOfInput.username = 'lastname.test@test.com';
        listOfInputs.add(listOfInput);
        UserProvisioningScreenFlowController.provisionUsers(listOfInputs);
    }
    
    static testMethod void userCreationWithVirtualMethod() {
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        System.Domain sandboxName = System.DomainParser.parse(URL.getOrgDomainUrl());
        User usr = new User();
        if(runningInASandbox){
            string userName = 'sm_gb_vt@template.user.'+sandboxName.getSandboxName();
            usr = [SELECT FIELDS(STANDARD),(SELECT Id,AssigneeId,PermissionSetId,PermissionSet.IsOwnedByProfile,PermissionSetGroupId FROM PermissionSetAssignments WHERE IsActive = true )FROM User WHERE UserName =: userName LIMIT 1];
        }
        else{
            usr = [SELECT FIELDS(STANDARD),(SELECT Id,AssigneeId,PermissionSetId,PermissionSet.IsOwnedByProfile,PermissionSetGroupId FROM PermissionSetAssignments WHERE IsActive = true )FROM User WHERE UserName = 'sm_gb_vt@template.user' LIMIT 1]; 
        }
        List<UserProvisionRequest> upsList = new List<UserProvisionRequest>();
        UserProvisionRequest upr = new UserProvisionRequest();
        upr.brand = 'VT';
        upr.country = 'GB';
        upr.countryCode = 'GB';
        upr.email = 'testClassFedId.test@test.com';
        upr.existingUserName ='testClassFedId.test@test.com'; 
        upr.federationId = 'testClassFedId';
        upr.firstName ='6janTest6';
        upr.lastName ='testClassFedId';
        upr.requestType ='Add';
        upr.roleName ='Sales Manager';
        upsList.add(upr);
        UserProvisioningServiceTestExtension upst = new UserProvisioningServiceTestExtension();
        upst.createUsers(upsList);
    }
}