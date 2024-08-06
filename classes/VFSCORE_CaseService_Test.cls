/**
* -------------------------------------------------------------------------------
* @Name            VFSCORE_CaseService_Test
* @Author          Swati <swati.bansal@consultant.volvo.com>
* @CreatedDate     5th April 2024
* @UsedBy          Apex Clas
* @SystemLayer     Service
* ------------------------------------------------------------------------------
* @Description
* This is a test class for VFSCORE_CaseService on Case object to extend the functionaltiies on Case which are
* otherwise not provided as Salesforce standard.
* -------------------------------------------------------------------------------  
*/
@isTest
public class VFSCORE_CaseService_Test {
    /**
* ----------------------------------------------------------------------------
* @Description
* Tests VFSCORE_CaseService class functionality
*  ----------------------------------------------------------------------------    
* @returns     void
* -----------------------------------------------------------------------------
**/
    @isTest
    public static void testCaseAssignment() {
        //Prepare Test User
        String uniqueUserName = 'TestCaseAssigment' + DateTime.now().getTime() + '@testorg.com';        
        Profile p = [SELECT Id FROM Profile WHERE Name='CS Operations'];
        User testUser = new User(Alias = 'tstcs', Email='testcaseassignment@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='TestCaseAsgMent', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',
                                 Country = 'Netherlands',UserName=uniqueUserName);
        
        //Invoke Functionality
        System.runAs(testUser){
            //Prepare Test Data For Functionality
            Case c= new Case();
            c.Subject= 'TestCaseAssignment';             	
            Insert c;  
            c.Country__c = 'Netherlands';
            List<case> casesToUpdate = new List<case>();
            casesToUpdate.add(c);
            VFSCORE_CaseService.ApplyCaseAssignmentRule(casesToUpdate);
        }
        
        //Assert Functionality
        Case NewCaseRec=[Select id,OwnerId,Owner.Name From Case Where Subject = 'TestCaseAssignment'];        
        String ownerId = NewCaseRec.OwnerId;
        Assert.isTrue(ownerId.startsWithIgnoreCase('00G'),'Case not assigned to a queue');		
        Group CaseQueueowner = [Select Name from Group where Id = :ownerId];        
        Assert.areEqual('NL-Collections', CaseQueueowner.Name, 'Case not assigned to NL-Collections queue');
    }
}