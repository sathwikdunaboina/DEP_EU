public class accountNotesToAccount{    
   Public Id accID;
   public List<Account_Note__c> accountNotesList{get;set;}
   public String getDemo() {
   accountNotesList = new List<Account_Note__c>();
   accID=  ApexPages.currentPage().getParameters().get('Id');
   accountNotesList =  [SELECT Note_Text__c FROM    Account_Note__c WHERE Account__c=:accID and NOTE_TYPE__c ='PERSON_ORGANIZATION_URGENT_NOTE'];
   if(accountNotesList.size()==1)
   {
       return String.valueOf(accountNotesList.get(0).Note_Text__c);
   }
        else if (accountNotesList.size()==0)
        {
            return 'No Urgent Note On This Account';
      }
        else{
            return 'This Account Has More Than One Urgent Note Pleas see all in below sectoin';
        }
        
    }


  
  

}