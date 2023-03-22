/**
 * Created on 9/20/18.
 */
({
    doInit: function (cmp, event, helper) {
        var action = cmp.get('c.getContractDetail');
        action.setParams({"recordId":cmp.get('v.recordId')});
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            //alert(response.getState());
            if(response.getState() === 'SUCCESS'){
                console.log('fetched contract detail');
            }else{
                console.log(result.getError());
                this.showToast(cmp, result.getError()[0].message, 'Error', 'error', 'sticky');
            }
        });
        $A.enqueueAction(action);
    },
    navigatecontract: function (cmp, event, helper) {
         var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/contracts"
        });
        urlEvent.fire(); 
    },
    /*toCreateCase: function(cmp, evt, helper) {
        var contractId = '';
        var recordTypeName = '';
        var modalBody;
        $A.createComponent("c:TC_CreateCase", {'contract':contractId, 'recordTypeName':recordTypeName},
                           
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
    addRemoveNotification : function (cmp, event, helper){
        
        var action = cmp.get('c.documentNotification');
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            //alert(response.getState());
            if(response.getState() === 'SUCCESS'){
                 location.reload();
            }else{
                console.log(result.getError());
                this.showToast(cmp, result.getError()[0].message, 'Error', 'error', 'sticky');
            }
        });
        $A.enqueueAction(action);
    },
    afterScriptsLoaded: function (cmp, event, helper) {
        console.log('afterScriptsLoaded');
        //helper.generateChart (cmp);
    },
    doShowPayoff: function(cmp, evt, helper) {

        var contractId = cmp.get('v.contractId');
        var accountId = cmp.get('v.simpleRecord.Account__c');
        var contractName = cmp.get('v.simpleRecord.Name');
        var standardPayoff = cmp.get('v.simpleRecord.Standard_Payoff_Quote__c');
        var modalBody;
        var p = cmp;
        var callback = cmp.getReference('c.handleCallback');
        $A.createComponent("c:TC_PayoffRequest", {'contractId':contractId, 'standardPayoff':standardPayoff, 'accountId':accountId, 'contractName':contractName, 'callback':callback},

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
    handleCallback: function(cmp, evt, helper){
        var data = evt.getParam('data');
        //cmp.find('modal').notifyClose();
        if(data.type == 'ContractPayoff'){
            helper.showPayoff(cmp,data.id);
        }else{
            helper.showCaseResponse(cmp,data.id);
        }
    },
    doAutoPay: function(cmp, evt, helper) {
		
        console.log('doAutoPay');
        var contractId = cmp.get('v.contractId');
        var recordTypeName;
        var cs_team = cmp.get('v.simpleRecord.CS_Team__c')
        if(cs_team == 'CA'){
            recordTypeName = 'Automated Direct Debit/PAP';
        }else if(cs_team == 'US' || cs_team == 'TF'){
            recordTypeName = 'Automated Direct Debit/ACH';
        }else{
            return;
        }
        var modalBody;
        $A.createComponent("c:TC_CreateCase", {'contract':contractId, 'recordTypeName':recordTypeName},

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
    doPaperlessInvoice: function(cmp, evt, helper) {

        console.log('doAutoPay');
        var contractId = cmp.get('v.contractId');
        var recordTypeName = 'E-Billing';
        var modalBody;
        $A.createComponent("c:TC_CreateCase", {'contract':contractId, 'recordTypeName':recordTypeName},

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
    docNotify: function(cmp, evt, helper) {
    },*/
})