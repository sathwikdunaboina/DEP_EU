({
	doInit: function (cmp, event, helper) {
        
        helper.getAccountDetails(cmp);
        
    },
    
    doChangeRequest: function(cmp, evt, helper) {
        var caseType = evt.target.id;
        console.log(caseType);
        //var accountId = cmp.get('v.contract.Account__c');
        //var contractNetInvst = cmp.get("v.contract.Net_Investment__c"); 
        //var standardPayoff = cmp.get('v.contract.Standard_Payoff_Quote__c');
        var modalBody;
        //var p = cmp;
        //var callback = cmp.getReference('c.handleCallback');
       
        $A.createComponent("c:CreateCase", 
                           {
                               'caseType': caseType
                           },
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                    
                                   cmp.find('modal').showCustomModal({
                                       header: "",
                                       body: modalBody,
                                       showCloseButton: true,
                                       closeCallback: function() {
                                       }
                                   })
                               }
                           });
    },
    
})