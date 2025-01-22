/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_CreditLineStatusExpired_Batch_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       06-21-2024         
* ------------------------------------------------------------------------------------------
* @description        Test class for CLA_CreditLineStatusExpired_Batch
* ------------------------------------------------------------------------------------------
*/
@isTest
private class CLA_CreditLineStatusExpired_Batch_Test {

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
        PermissionSet ps = [SELECT Id 
                    FROM PermissionSet 
                    WHERE Name = 'CLA_Credit_Manager_PS'];

        try {
            insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
        } catch(DmlException e) {
            System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
        }

        System.runAs(new User(Id = UserInfo.getUserId())){ 
        CLA_TestDataFactory.createCreditLine(true,true);
       }
       
} 

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testCreditLineStatusStatusExpired
* @description     Used to test CLA_CreditLineStatusExpired_Batch 
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 

    @isTest static void testCreditLineStatusStatusExpired() {

        System.runAs(new User(Id = UserInfo.getUserId())){

        Test.startTest();
        Database.executeBatch(new CLA_CreditLineStatusExpired_Batch(), 100);
        Test.stopTest();
       
       List<CLA_Credit_Line__c> listCreditLines = [SELECT Id,CLA_Status__c FROM CLA_Credit_Line__c  LIMIT 49999];
       
       
        Boolean bCheckStatus = false;
        if(!listCreditLines.IsEmpty()){
          for(CLA_Credit_Line__c oCreditLine :  listCreditLines){
              if(oCreditLine.CLA_Status__c != 'Expired'){
                      bCheckStatus = true;
              }
          }
      }
      else{
          bCheckStatus = true;
      }
        
      System.assertEquals(false, bCheckStatus,'Records status updated to expired');
    }
   }
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testCreditLineStatusStatusExpiredError
* @description     Used to test CLA_CreditLineStatusExpired_Batch Error scenario when update fails
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/ 
 
 @isTest static void testCreditLineStatusStatusExpiredError() {
    
    System.runAs(new User(Id = UserInfo.getUserId())){
     
        CLA_TestDataFactory.createCreditLine(true);

        Test.startTest();
        Database.executeBatch(new CLA_CreditLineStatusExpired_Batch(), 100);
        Test.stopTest();
       
        List<CLA_Credit_Line__c> listCreditLines = [SELECT Id,CLA_Status__c FROM CLA_Credit_Line__c  LIMIT 49999];
       
       
        Boolean bCheckStatus = false;
        if(!listCreditLines.IsEmpty()){
          for(CLA_Credit_Line__c oCreditLine :  listCreditLines){
              if(oCreditLine.CLA_Status__c != 'Expired'){
                      bCheckStatus = true;
              }
          }
      }
      else{
          bCheckStatus = true;
      }
        
      System.assertEquals(true, bCheckStatus,'Records status update failed.');
    }
   }
}