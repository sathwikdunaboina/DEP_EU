/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        
        //Fetching the unique customer identifier from Account object
        User u=[SELECT Account.CustomerId__c FROM User WHERE id=:UserInfo.getUserId()];
        if (u.Account != null && ! String.isBlank(u.Account.CustomerId__c)){
        	String customerId = u.Account.CustomerId__c;
        	CMSAPI_ContractHandler.fetchContractList(customerId);
        }        
        return Network.communitiesLanding();
    }
    
    public CommunitiesLandingController() {}
}