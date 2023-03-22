/**
 * Created on 9/20/18.
 */
({
    /*navigateToContractDetail:function(cmp,id){
        var action=cmp.get("c.CallContractDetailAPI");
        action.setParams({"contractId":id});
        action.setCallback(this, function(resp) {
           var state=resp.getState();
         });
           $A.enqueueAction(action);
    },

    generateChart: function (cmp) {
        var contract = cmp.get('v.simpleRecord');
        if (contract && Chart) {
            console.log(JSON.stringify(contract));
            var chartdata = {
                labels: ['Principal Balance', 'Amount Due'],
                datasets: [{
                    data: [contract.Principal_Balance__c, contract.Current_Amount_Due__c],
                    backgroundColor: ["red","#0074D9"]
                }]
            };

            var ctx = cmp.find('linechart').getElement();
            console.log(chartdata);

            try {
                var pieChart = new Chart(ctx, {
                    type: 'pie',
                    data: chartdata,
                    options: {

                    }
                });

                console.log(pieChart);
            } catch (e) {
                console.log(e);
            }
        }

    },
    showPayoff: function(cmp,id) {
        var whatId = id;//'a2g4C000000HJqSQAW';
        var templateName = cmp.get('v.simpleRecord.Payoff_Quote_Template__c');//'US_Mack_Truck';
        var modalBody;
        $A.createComponent("c:tc_templateOutput", {'whatId':whatId, 'templateName':templateName},
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
        $A.createComponent("c:tc_templateOutput", {'whatId':whatId, 'templateName':templateName},
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