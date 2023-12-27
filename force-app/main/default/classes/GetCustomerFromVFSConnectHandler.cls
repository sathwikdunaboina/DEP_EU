/*
* Subject: Get the customer from VFS for the Contract is not in active or contract ended.
* Created by : Aswin balaji
* Date : 07/09/2023
* Description : Get relevent customer based on the CMS ID and return back the data from VFS.
* Test class :
* Coverage : 
*/   
public class GetCustomerFromVFSConnectHandler {
    
    public List <String> returnValue;
    public List <Account> accountList;
    
    @InvocableMethod (label='Get customer' description='This fetches customer from backend CMS')
    public static List<ReturnVariables> fetchCustomerFromCMS( List <InputVariables> CMSID){
        System.debug(CMSID);
        List <String> CMS_ID = CMSID[0].CMSID;
        System.debug(CMS_ID);
        List<String> returnValue = new List<String>();
        Id recordTypeId = [Select Id,Name,DeveloperName From RecordType WHERE DeveloperName = 'Customer_Account'].Id;
        List <Account> accExist = [SELECT Id,Name,Customer_Number__c FROM Account 
                                   WHERE Customer_Number__c IN:CMS_ID AND RecordTypeId =: recordTypeId LIMIT 1];
        System.debug(accExist);
        if(accExist.isEmpty()) {
            try{
                String CMSIDRequest;
                CMSAPI1__c settings = CMSAPI1__c.getOrgDefaults();
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:VFS_Global_APIs'+settings.Endpoint_QA__c);
                request.setMethod('POST');
                //request.setHeader( 'X-Ibm-Client-Id',settings.X_Ibm_Client_Id__c);
                //request.setHeader('X-Ibm-Client-Secret' , settings.X_Ibm_Client_Secret__c);
                request.setHeader('Content-Type', 'application/json; charset=utf-8');
                request.setHeader('Service-Id', 'SRV25720');
                //CMSIDRequest = CMS_ID;
                String sendJSON=json.serialize(CMSIDRequest);
                request.setBody(sendJSON);
                request.setTimeout(100000);
                HttpResponse response = http.send(request);
            }
            catch(exception ex){
                
            }
            System.debug('Empty');
			List<ReturnVariables> returnVarsList = new List<ReturnVariables>();
            ReturnVariables returnVars = new ReturnVariables();
            returnVars.returnValue = new List<String>();
            returnVars.accountIds = new List<String>();
            returnVars.returnValue.add('Failure');//Adding Output value
            returnVars.returnValue.add('The CMS System is currently not available. Please try later!');//Adding Output value
            //returnVars.accountIds.add(accExist[0].Id);//Adding Output value
            returnVarsList.add(returnVars);
            return returnVarsList;
        }
        else {
            List<ReturnVariables> returnVarsList = new List<ReturnVariables>();
            ReturnVariables returnVars = new ReturnVariables();
            returnVars.returnValue = new List<String>();
            returnVars.accountIds = new List<String>();
            returnVars.returnValue.add('Exist');//Adding Output value
            returnVars.accountIds.add(accExist[0].Id);//Adding Output value
            returnVarsList.add(returnVars);
            System.debug(returnVars);
            System.debug(CMSID);
            System.debug(accExist);
            return returnVarsList;
        }
        
    }
    //Getting CMS ID from screen flow to check
    public class InputVariables {
        @InvocableVariable
        public List <String> CMSID;
    }
    //Sending return values to flow 
    public class ReturnVariables {
        @InvocableVariable
        public List <String> returnValue;
        
        @InvocableVariable
        public List <String> accountIds;
    }
}