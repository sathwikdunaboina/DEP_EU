@isTest
public class accountNotesToAccount_Test {
    //Each of the two test methods here gives a 83 test coverage
 @isTest static void testUpdateRecords(){
      
      Account_Note__c b = new Account_Note__c(Name= 'CitiyBank', Note_Text__c='Web',NOTE_TYPE__c ='PERSON_ORGANIZATION_URGENT_NOTE');  
      insert b;
       
     Test.StartTest();
 
     PageReference pageRef = Page.getAccountNotes;
     Test.setCurrentPage(pageRef); 
     ApexPages.currentPage().getParameters().put('id',String.valueOf(b.Id));
      
     accountNotesToAccount controller = new accountNotesToAccount();
     controller.getDemo();
     String getNoteText = controller.getDemo();
     System.assertEquals('No Urgent Note On This Account', getNoteText); //assertion
     Test.StopTest();
    }
}