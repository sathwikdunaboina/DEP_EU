public class contractNotesToContract{

    public String getDemo() {
    
    contactNotesList = new List<Contract_Note__c>();
   accID=  ApexPages.currentPage().getParameters().get('Id');
   contactNotesList =  [SELECT Note_Text__c FROM    Contract_Note__c WHERE Contract__c=:accID and NOTE_TYPE__c ='CONTRACT_URGENT_NOTE'];
   if(contactNotesList.size()==1)
   {
       String getNote;
       //getNote=contactNotesList.get(0)
       return String.valueOf(contactNotesList.get(0).Note_Text__c);
   }
        else if (contactNotesList.size()==0)
        {
            return 'No Urgent Note On This Contract';
      }
        else{
            return 'This Contract Has More Than One Urgent Note Pleas see all in below sectoin';
        }
        
    }


  
  
    Public Id accID;
    //Public String demo='This is demo';

    public List<Contract_Note__c> contactNotesList{get;set;}
    public contractNotesToContract(){
   contactNotesList = new List<Contract_Note__c>();
   accID=  ApexPages.currentPage().getParameters().get('Id');
   contactNotesList =  [SELECT Note_Text__c FROM Contract_Note__c WHERE Contract__c=:accID and NOTE_TYPE__c ='CONTRACT_URGENT_NOTE'];
   
 }
}