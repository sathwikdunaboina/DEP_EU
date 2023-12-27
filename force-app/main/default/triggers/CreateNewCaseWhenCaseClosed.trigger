trigger CreateNewCaseWhenCaseClosed on EmailMessage (before insert) {
         set<Id> caseIds = new set<Id>();
    list<EmailMessage> msgList=new List<EmailMessage>();
    map<Id,EmailMessage> parentIdEmailMsgMap = new map<Id,EmailMessage>();
    //map<Id,string> case2CustomValueMap = new map<Id,sting>();
    for(EmailMessage message : trigger.new){
        if(message.Incoming == true){
            string myCustomValue='Test';
            //Some sort of logic that gets the value for this
            //Case cs=[Select Id,Test_Field__C,Status From Case Where Id=: message.ParentId];
            Case cs=[Select Id,Status From Case Where Id=: message.ParentId];

            if(cs.Status=='Closed')
            { caseIds.add(message.ParentId);
              msgList.add(message);
              parentIdEmailMsgMap.put(message.ParentId,message);
           }
                  

           // case2CustomValueMap.put(message.ParentId, myCustomValue)
        }
    }
    System.debug('This is case ids'+caseIds);
  // list<Case> casesToUpdate = [Select Id,Test_Field__C,Status From Case Where Id in: caseIds];

    list<Case> casesToUpdate = [Select Id,Status From Case Where Id in: caseIds];
    
    
    for(Case c : casesToUpdate){
        if(c.Status=='Closed')
        {
            case obj=new case();
            obj.Subject='Test2n';
            //msgList.get(0).ParentId=obj.Id;
           // update msgList;

              insert obj;
           EmailMessage newEmailMsg= new EmailMessage();
           newEmailMsg.Subject= parentIdEmailMsgMap.get(c.id).Subject;
           newEmailMsg.FromAddress= parentIdEmailMsgMap.get(c.id).FromAddress;
           newEmailMsg.ToAddress=parentIdEmailMsgMap.get(c.id).ToAddress;
           newEmailMsg.FromName=parentIdEmailMsgMap.get(c.id).FromName;        
           newEmailMsg.Status='1';
           //newEmailMsg.MessageIdentifier
           // newEmailMsg.Subject='Test Subject 4';
           newEmailMsg.ParentId=obj.Id;
            newEmailMsg.RelatedToId=obj.Id;
            newEmailMsg.HtmlBody=parentIdEmailMsgMap.get(c.id).HtmlBody;
           newEmailMsg.TextBody=parentIdEmailMsgMap.get(c.id).TextBody;
           newEmailMsg.Headers=parentIdEmailMsgMap.get(c.id).Headers;
           newEmailMsg.MessageIdentifier=parentIdEmailMsgMap.get(c.id).MessageIdentifier;
           newEmailMsg.ReplyToEmailMessageId=parentIdEmailMsgMap.get(c.id).ReplyToEmailMessageId;
           newEmailMsg.Incoming=true;
            //newEmailMsg.FromAddress='Test@test.com';
            //newEmailMsg.ToAddress='har@j.ck';
           //newEmailMsg.FromName='Test';          
         insert newEmailMsg; 
            
             //c.Test_Field__c=parentIdEmailMsgMap.get(c.id).FromAddress;
            
        }
       // c. = case2CustomValueMap.get(c.Id);
    }

    update casesToUpdate;


}