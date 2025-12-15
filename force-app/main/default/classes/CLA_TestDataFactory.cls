/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_TestDataFactory
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-14-2024 
* @Used By            CLA_CreditLineConsumptionService_Test,CLA_CreditLineSearchService_Test,CLA_CreditLineControlsService_Test
*                     CLA_CreditLineService_Test,CLA_UtilityService_Test,CLA_ValidateCreditLineCustLwcCont_Test
* ------------------------------------------------------------------------------------------
* @description        This class is used to prepare test data for test classes.
* ------------------------------------------------------------------------------------------
*/
@isTest
public  class CLA_TestDataFactory {  

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createUser
* @description     Handles user creation and permission set assignment 
* ------------------------------------------------------------------------------------------------------
* @param       profile   Profile for user     
* @return      User      Return created user   
* ------------------------------------------------------------------------------------------------------ 
*/

    public static user createUser(String sProfile){

        Profile oProfile = [Select Id from Profile where name =: sProfile  WITH USER_MODE LIMIT 1];
        User oUser = new User(Alias = 'clau', Email='clatestuser@cla.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = oProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='clatestuser@cla.com');

        try {
            insert oUser;
        } catch(DmlException e) {
            System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
        }

        PermissionSet ps = [SELECT Id 
                    FROM PermissionSet 
                    WHERE Name = 'CLA_Credit_Line_Integration_User_PS'  WITH USER_MODE LIMIT 1];

        try {
            insert new PermissionSetAssignment(AssigneeId = oUser.Id, PermissionSetId = ps.Id);
        } catch(DmlException e) {
            System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
        }

        return oUser;
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createCreditLine
* @description     Creates creditline in draft state.
* ------------------------------------------------------------------------------------------------------
* @param       bDoInsert   Boolean , Indicate insert      
* @return      User      Return created user   
* ------------------------------------------------------------------------------------------------------ 
*/

    public static CLA_Credit_Line__c createCreditLine(Boolean bDoInsert){

        CLA_Credit_Line__c oCreditLine = new CLA_Credit_Line__c();
        oCreditLine.CLA_Credit_Line_Description__c = 'test credit line description';
        oCreditLine.CLA_Country__c = 'NL';
        oCreditLine.CLA_Type__c = 'Amortizing';
        oCreditLine.CLA_Currency__c = 'SEK';
        oCreditLine.CLA_Max_Allowed_Group_Exposure__c = 1000;
        oCreditLine.CLA_Approved_Limit__c = 1000;
        oCreditLine.CLA_Expiry_Date__c = Date.today().addDays(7);
        oCreditLine.CLA_Primary_Customer_Name__c = 'test primary customer name';
        oCreditLine.CLA_VFS_Customer_Number__c = '1234567890';
        oCreditLine.CLA_Activation_Date__c = Date.today().addDays(-1);
        oCreditLine.CLA_Company_Identification_Number__c = UUID.randomUUID().toString();

        try {
            insert oCreditLine;
        } catch(DmlException e) {
            System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
        }

        return oCreditLine;
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createCreditLineControls
* @description     Creates creditline controls with credit line.
* ------------------------------------------------------------------------------------------------------
* @param       bDoInsert   Indicate insert, Boolean     
* @return         
* ------------------------------------------------------------------------------------------------------ 
*/

    public static void createCreditLineControls(Boolean bDoInsert ){

        CLA_Credit_Line__c oCreditLine = createCreditLine(true);
        List<CLA_Credit_Line__c> listCreditLines = [SELECT Id,CLA_Credit_Line_identification_number__c
                                                   FROM CLA_Credit_Line__c 
                                                   WHERE Id =: oCreditLine.Id  WITH USER_MODE];

        List<CLA_Credit_Line_Control__c> listCreditLineControls = new List<CLA_Credit_Line_Control__c>();

        CLA_Credit_Line_Control__c oCreditLineControl = getCreditLineControlInstance(listCreditLines[0].Id,'test creditline control description','VT');
        listCreditLineControls.add(oCreditLineControl);

        CLA_Credit_Line_Control__c oCreditLineControl1 = getCreditLineControlInstance(listCreditLines[0].Id,'test creditline control description 1','RT');
        listCreditLineControls.add(oCreditLineControl1);

        CLA_Credit_Line_Control__c oCreditLineControl2 = getCreditLineControlInstance(listCreditLines[0].Id,'test creditline control description 2','VCE');
        listCreditLineControls.add(oCreditLineControl2);

        CLA_Credit_Line_Control__c oCreditLineControl3 = getCreditLineControlInstance(listCreditLines[0].Id,'test creditline control description 3','VCE');
        listCreditLineControls.add(oCreditLineControl3);

        try {
        insert listCreditLineControls;
        } catch(DmlException e) {
            System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
        }

 }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getCreditLineControlInstance
* @description     Creates creditline control instance.
* ------------------------------------------------------------------------------------------------------
* @param       sCreditLineId                 Creditline Id,String 
* @param       sControlDescription           Crediline control description for credit line control,String  
* @param       sBusinessArea                 Business Area for credit line control,String
* @return      CLA_Credit_Line_Control__c    Creditline control instance 
* ------------------------------------------------------------------------------------------------------ 
*/

    private static CLA_Credit_Line_Control__c getCreditLineControlInstance(String sCreditLineId,String sControlDescription , String sBusinessArea){
       
        CLA_Credit_Line_Control__c oCreditLineControl = new CLA_Credit_Line_Control__c();
        oCreditLineControl.CLA_Credit_Line__c = sCreditLineId;
        oCreditLineControl.CLA_Control_Description__c = sControlDescription;
        oCreditLineControl.CLA_Business_Area__c = sBusinessArea;
        oCreditLineControl.CLA_Allow_Non_Standard_Payment__c = 'Yes' ;
        oCreditLineControl.CLA_Allowed_Maximum_RV_Percent__c = 10;
        oCreditLineControl.CLA_Financial_Product_Type__c = 'InstallmentCredit';
        oCreditLineControl.CLA_Asset_Category__c = 'Truck';
        oCreditLineControl.CLA_Asset_Segment__c = 'Heavy';
        oCreditLineControl.CLA_Chassis__c = 'Tractor';
        oCreditLineControl.CLA_Allowed_Minimum_Down_Payment_Percent__c = 20;
        oCreditLineControl.CLA_Max_Unit_Price__c = 200;
        
        	
        
        
        
        
        
        
            
        
        return oCreditLineControl;
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createCreditLineControls
* @description     Creates creditline controls with existing credit line.
* ------------------------------------------------------------------------------------------------------
* @param       bDoInsert       Indicate insert , Boolean
* @param       sCreditLineId   CreditlineId, String        
* @return         
* ------------------------------------------------------------------------------------------------------ 
*/

    public static void createCreditLineControls(Boolean bDoInsert , String sCreditLineId){
        
        List<CLA_Credit_Line_Control__c> listCreditLineControls = new List<CLA_Credit_Line_Control__c>();

        CLA_Credit_Line_Control__c oCreditLineControl = getCreditLineControlInstance(sCreditLineId,'test creditline control description','VT');
        listCreditLineControls.add(oCreditLineControl);

        CLA_Credit_Line_Control__c oCreditLineControl1 = getCreditLineControlInstance(sCreditLineId,'test creditline control description 1','RT');
        listCreditLineControls.add(oCreditLineControl1);

        CLA_Credit_Line_Control__c oCreditLineControl2 = getCreditLineControlInstance(sCreditLineId,'test creditline control description 2','VCE');
        listCreditLineControls.add(oCreditLineControl2);

        CLA_Credit_Line_Control__c oCreditLineControl3 = getCreditLineControlInstance(sCreditLineId,'test creditline control description 3','VCE');
        listCreditLineControls.add(oCreditLineControl3);

        try {
            insert listCreditLineControls; 
        } catch(DmlException e) {
                System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
        }       
}

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createCreditLine
* @description     Creates and update creditline to Approved status,Need to fulfil validations to move 
*                  credit line into approved state.
* ------------------------------------------------------------------------------------------------------
* @param       bDoInsert                   Indicate insert, Boolean 
* @param       bIsApproved                Indicate approved status, Boolean     
* @return      List<CLA_Credit_Line__c>   CreditLine List
* ------------------------------------------------------------------------------------------------------ 
*/

    public static List<CLA_Credit_Line__c> createCreditLine(Boolean bDoInsert,Boolean bIsApproved){
        
        CLA_Credit_Line__c oCreditLine = createCreditLine(true);
        List<CLA_Credit_Line__c> listCreditLines = [SELECT Id,CLA_Credit_Line_identification_number__c
        FROM CLA_Credit_Line__c 
        WHERE Id =: oCreditLine.Id LIMIT 49999];
        
        createCreditLineControls(true,listCreditLines[0].Id);

        List<CLA_Credit_Line_Account__c>listCreditLineCustomers = [SELECT Id, CLA_Credit_Line__c ,CLA_Validation_Type__c 
                                                                  FROM CLA_Credit_Line_Account__c 
                                                                  WHERE  CLA_Credit_Line__c =: listCreditLines[0].Id AND CLA_Is_Primary__c = true  
                                                                  WITH USER_MODE
                                                                  LIMIT 1];

        listCreditLineCustomers[0].CLA_Validation_Type__c = 'Manual';
        try {
            update listCreditLineCustomers; 
        } catch(DmlException e) {
                System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
        }
       
        listCreditLines[0].CLA_Status__c = 'Under Review';
        try {
            update listCreditLines;
        } catch(DmlException e) {
                System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
        }
      
        listCreditLines[0].CLA_Activation_Date__c = Date.today();
        listCreditLines[0].CLA_Country__c = 'NL';
        listCreditLines[0].CLA_Status__c = 'Approved';
        try {
            update listCreditLines;
        } catch(DmlException e) {
                System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
        }

        return listCreditLines;
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     createCreditLineConsumptions
* @description     Creates creditline consumption records
* ------------------------------------------------------------------------------------------------------
* @param       bDoInsert    Indicate insert, Boolean      
* @return         
* ------------------------------------------------------------------------------------------------------ 
*/


    public static void createCreditLineConsumptions(Boolean bDoInsert ){
 
        List<CLA_Credit_Line__c> listCreditLines = createCreditLine(true,true);

        List<CLA_Credit_Line_Consumption__c> listCreditLineConsumptions = new List<CLA_Credit_Line_Consumption__c>();

        CLA_Credit_Line_Consumption__c oCreditLineConsumption = getCreditLineConsumptionInstance(listCreditLines[0].Id);
        listCreditLineConsumptions.add(oCreditLineConsumption);

        CLA_Credit_Line_Consumption__c oCreditLineConsumption1 = getCreditLineConsumptionInstance(listCreditLines[0].Id);
        listCreditLineConsumptions.add(oCreditLineConsumption1);

        CLA_Credit_Line_Consumption__c oCreditLineConsumption2 = getCreditLineConsumptionInstance(listCreditLines[0].Id);
        listCreditLineConsumptions.add(oCreditLineConsumption2);

        CLA_Credit_Line_Consumption__c oCreditLineConsumption3 = getCreditLineConsumptionInstance(listCreditLines[0].Id);
        listCreditLineConsumptions.add(oCreditLineConsumption3);

        try {
            insert listCreditLineConsumptions;
        } catch(DmlException e) {
                System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
        }
       
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getCreditLineConsumptionInstance
* @description     Creates creditline consumption instance.
* ------------------------------------------------------------------------------------------------------
* @param       sCreditLineId                     Creditline Id,String   
* @return      CLA_Credit_Line_Consumption__c   Creditline consumption instance 
* ------------------------------------------------------------------------------------------------------ 
*/

    private static CLA_Credit_Line_Consumption__c getCreditLineConsumptionInstance(String sCreditLineId){
       
        CLA_Credit_Line_Consumption__c oCreditLineConsumption = new CLA_Credit_Line_Consumption__c();
        oCreditLineConsumption.CLA_Company_Identification_Number__c = '123456789';
        oCreditLineConsumption.CLA_Drawn_Date__c = DateTime.newInstance(Date.today()+5, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'); 
        oCreditLineConsumption.CLA_Status__c = 'Confirmed';
        oCreditLineConsumption.CLA_Quote_Market__c = 'market';
        oCreditLineConsumption.CLA_Quote_Number__c = 'test number';
        oCreditLineConsumption.CLA_Quote_Origin__c = 'test origin';
        oCreditLineConsumption.CLA_Drawn_Amount__c = 10;
        oCreditLineConsumption.CLA_Credit_Line__c = sCreditLineId;
        
        return oCreditLineConsumption;
    }     
}