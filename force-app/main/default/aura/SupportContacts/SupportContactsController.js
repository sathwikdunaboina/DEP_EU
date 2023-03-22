({
    doInit: function (cmp, event, helper) {
        helper.getTerritoryMngrDetails(cmp); 
        
        helper.getSupportContactDetails(cmp); 
 
    },
    
    toCreateCase: function(cmp, evt, helper) {
        var contractId = '';
        var recordTypeName = '';
        var modalBody;
        
        var message=cmp.get("v.createCaseSuccessMessage");
        $A.createComponent("c:CreateCase", {'createCaseSuccessMessage':message},
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
    afterScriptsLoaded: function (cmp, event, helper) {
        console.log('afterScriptsLoaded');
        //helper.generateChart (cmp);
    }
})