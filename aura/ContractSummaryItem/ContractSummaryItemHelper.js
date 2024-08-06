({
    /*showPayoff: function(cmp,id) {
        var whatId = id;//'a2g4C000000HJqSQAW';
        var templateName = cmp.get('v.contract.Payoff_Quote_Template__c');//'US_Mack_Truck';
        var modalBody;
        $A.createComponent("c:TemplateOutput", {'whatId':whatId, 'templateName':templateName},
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
    showCaseResponse: function(cmp,id) {
        var whatId = null;
        var templateName = 'Payoff_Quote_Case_Created';
        var modalBody;
        $A.createComponent("c:TemplateOutput", {'whatId':whatId, 'templateName':templateName},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   cmp.find('modal').showCustomModal({
                       header: "Case Created",
                       body: modalBody,
                       showCloseButton: true,
                       closeCallback: function() {
                       }
                   })
               }
           });
    }*/
})