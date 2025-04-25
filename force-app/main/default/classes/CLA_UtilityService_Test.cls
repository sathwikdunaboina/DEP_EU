/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_TestUtility_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       05-20-2024         
* ------------------------------------------------------------------------------------------
* @description        This class is used to test CLA_UtilityService
* ------------------------------------------------------------------------------------------
*/
@isTest
private class CLA_UtilityService_Test {

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     setUpData
* @description     Used to prepare test setup data
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
    @testSetup static void setUpData() {
         CLA_TestDataFactory.createUser('Minimum Access - API Only Integrations');
         System.runAs(new User(Id = UserInfo.getUserId())){ 
            CLA_TestDataFactory.createCreditLine(true);
        }
    } 

    @isTest
    private static void testTransformSObjectToApicFormat(){

      User oIntegrationUser = [Select Id FROM user where Username = 'clatestuser@cla.com' LIMIT 1];
      System.runAs(oIntegrationUser){
      List<CLA_Credit_Line__c>listCreditLineRecords =  [SELECT Id,CLA_Credit_Line_identification_number__c,CLA_Activation_Date__c,CLA_Approval_Date__c, CLA_Approved_Limit__c ,CLA_Country__c,CLA_Credit_Line_Description__c,CLA_Currency__c,CLA_Expiry_Date__c,CLA_Max_Allowed_Group_Exposure__c,CLA_Remaining_Amount__c,CLA_Status__c,CLA_Type__c,
        (SELECT CLA_Company_Identification_Number__c,CLA_Credit_Bureau_Number__c,CLA_Credit_Line__c,CLA_Credit_line_Grade__c,Name,CLA_Use_ACE_Grade__c,CLA_VFS_Customer_Number__c  FROM Credit_Line_Customers__r) 
        FROM CLA_Credit_Line__c  WITH SECURITY_ENFORCED LIMIT 1
        ];

        Set<String> setFields = new Set<String>{
          'Id','CLA_Credit_Line_identification_number__c','CLA_Activation_Date__c','CLA_Approval_Date__c', 'CLA_Approved_Limit__c' ,'CLA_Country__c','CLA_Credit_Line_Description__c',
          'CLA_Currency__c','CLA_Expiry_Date__c','CLA_Max_Allowed_Group_Exposure__c','CLA_Remaining_Amount__c','CLA_Status__c','CLA_Type__c'
      };
  
       Set<String> setRelatedFields = new Set<String>{
          'CLA_Company_Identification_Number__c','CLA_Credit_Bureau_Number__c','CLA_Credit_Line__c','CLA_Credit_line_Grade__c','Name','CLA_Use_ACE_Grade__c',
          'CLA_VFS_Customer_Number__c'
        };
  
      CLA_UtilityService.InputParameters inputParametersInstance = new CLA_UtilityService.InputParameters();
      inputParametersInstance.sObjectName = 'CLA_Credit_Line__c';
      inputParametersInstance.sRelatedObjectName = 'CLA_Credit_Line_Account__c';
      inputParametersInstance.sRelatedRelationshipName = 'Credit_Line_Customers__r'; 
      inputParametersInstance.listSObjects = listCreditLineRecords;
      inputParametersInstance.setFields = setFields;
      inputParametersInstance.setRelatedFields = setRelatedFields;

      Test.startTest();
      List<SObject> listTransformedSObjects= CLA_UtilityService.transformSObjectToApicFormat( inputParametersInstance);
      Test.stopTest();

      System.assert(JSON.serializePretty(listTransformedSObjects).contains('CLA_Credit_Line_identification_number__c'), 'Expected "Keys present" message in response.');
   
      }

    }    
}