@isTest
public class contractNotesToContract_Test {
    //Each of the two test methods here gives a 83 test coverage
 @isTest static void testUpdateRecords(){
      
      Contract_Note__c b = new Contract_Note__c(Name= 'CitiyBank', Note_Text__c='Web',NOTE_TYPE__c ='CONTRACT_URGENT_NOTE');  
      insert b;
       
     Test.StartTest();
 
     PageReference pageRef = Page.getContractNotes;
     Test.setCurrentPage(pageRef); 
     ApexPages.currentPage().getParameters().put('id',String.valueOf(b.Id));
      
     contractNotesToContract controller = new contractNotesToContract();
     controller.getDemo();
     String getNoteText = controller.getDemo();
     System.assertEquals('No Urgent Note On This Contract', getNoteText); //assertion
     Test.StopTest();
    }
}