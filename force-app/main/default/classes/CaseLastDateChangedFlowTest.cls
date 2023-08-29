@isTest
private class CaseLastDateChangedFlowTest {
    
    static testMethod void TestLastDateChangedCase(){
        
        List<Account> acts = new List<Account>();
        Account myAcc = new Account(Name='TestAct', phone='1001231234');
        acts.add(myAcc);
        
        Account busAcc = new Account(Name = 'TestForMS', phone='4567890999');
        acts.add(busAcc);
        insert acts;
        Contact cont = new Contact(FirstName = 'Test', LastName = 'LastName', phone='4567890999', accountid = busAcc.id);
        insert(cont);
        
        Id contactId = cont.Id;
        
        List<Case> cases = new List<Case>{};
            Case c = new Case(Subject = 'Test Case with Entitlement',Status = 'On Hold');
        cases.add(c);
        
        insert cases;
        
        
        EmailMessage newEmailMsg= new EmailMessage();
        
        newEmailMsg.Status='3';
        newEmailMsg.ParentId=c.id;
        
        insert newEmailMsg;
        
        EmailMessage newEmailMsg2= new EmailMessage();
        
        newEmailMsg2.Status='0';
        newEmailMsg2.ParentId=c.id;
        newEmailMsg2.Incoming=true;
        insert newEmailMsg2;
        
        List<Id> caseIds = new List<Id>();
        for (Case cL : cases){
            caseIds.add(cL.Id);
        }
        
        List<Case> updateCaseT = new List<Case>([Select Status,LastModifiedDate,Last_Changed_Date__c from Case where Id In :caseIds]);
        List<EmailMessage> emailMeg= new List<EmailMessage>([Select CreatedDate,Id from EmailMessage where ParentId In :caseIds]);
        
        Assert.areEqual(updateCaseT[0].LastModifiedDate,updateCaseT[0].Last_Changed_Date__c);      
    }
}