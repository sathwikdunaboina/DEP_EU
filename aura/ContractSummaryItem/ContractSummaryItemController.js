({	

    viewContract: function (cmp, event, helper) {
        var old=cmp.get('v.contract.Name');
        var name=old.replace(/-/g, "");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            //url: "/contract?contractId="+cmp.get('v.contract').Id
            url: "/contract/" + cmp.get('v.contract').Id + "/" + name
        });
        urlEvent.fire();
   	 },
    
    download: function (cmp, event, helper) {
        
        var ids=cmp.get('v.contract').Id;
        var contractId = cmp.get('v.contract.Id');
        var vAction = cmp.get('c.getContentDocs');
        var Contract_List = $A.get("$Label.c.Contract_List");
        var modalBody;
        vAction.setParams({
            contractID : ids,
        });
        vAction.setCallback(this, function(pResponse) {
            var vState = pResponse.getState();
            if (vState == "SUCCESS") {
                var size=pResponse.getReturnValue().length;
                if(size==null || size==0){
                    //CHECK FOR SIZE AND SHOW TOAST
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Info Message!",
                        "type": 'info',
                        "message": "The contract record has no document."
                    });
                    toastEvent.fire();
                }	
                if(size>0){
                $A.createComponent("c:FilesList", {'contractId':contractId},
                           
                           function(content, status,errorMessage) {
                               //alert(content);
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   cmp.find('modal').showCustomModal({
                                       header: Contract_List,
                                       body: modalBody,
                                       showCloseButton: true,
                                       closeCallback: function() {
                                       }
                                   })
                               }
                               else if (status === "ERROR") {
                                   alert('errorMessage');
                               }
                           });
            }
                
            /*    for(var i=0;i<size;i++){
                    cmp.set("v.Baseurl", pResponse.getReturnValue()[i]);
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": pResponse.getReturnValue()[i]
                    });
                    urlEvent.fire();
                    var toastSuccessEvent = $A.get("e.force:showToast");
                    toastSuccessEvent.setParams({
                        "title": "Success Message",
                        "type": 'success',
                        "message": "The document has been downloaded successfully."
                    });
                    toastSuccessEvent.fire();
                } */
            }
        });
        
        $A.enqueueAction(vAction);
        
    },
    
    /*toCreateCase: function(cmp, evt, helper) {
        var contractId = '';
        var recordTypeName = '';
        var modalBody;
        $A.createComponent("c:CreateCase", {},
                           
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
    },*/
    
    /*navigateToPaymentHistory : function (cmp, event, helper) {
      console.log('navigateToPaymentHistory');
      helper.navigateToPaymentHistory (cmp, cmp.get('v.contract').Id);
  },
  
  navigateToSchedulePayment : function (cmp, event, helper) {
      helper.navigateToSchedulePayment(cmp,  cmp.get('v.contract').Id);
      
  },
  
  navigateToInvoices : function (cmp, event, helper) {
      helper.navigateToInvoices(cmp,  cmp.get('v.contract').Id);
  },
  
  navigateToDocuments : function (cmp, event, helper) {
      helper.navigateToDocuments(cmp, cmp.get('v.contract').Id);
  },
  
  navigateToAssets : function (cmp, event, helper) {
      helper.navigateToAssets(cmp, cmp.get('v.contract').Id);
  },*/
    
    /*doShowPayoff: function(cmp, evt, helper) {
      
      var contractId = cmp.get('v.contract.Id');
      var contractName = cmp.get('v.contract.Name');
      var accountId = cmp.get('v.contract.Account__c');
      var contractNetInvst = cmp.get("v.contract.Net_Investment__c"); 
      var standardPayoff = cmp.get('v.contract.Standard_Payoff_Quote__c');
      
      var modalBody;
      var p = cmp;
      var callback = cmp.getReference('c.handleCallback');
      
      $A.createComponent("c:PayoffRequest", {'contractId':contractId, 'standardPayoff':standardPayoff, 'contractName':contractName, 'accountId':accountId, 'contractNetInvst':contractNetInvst ,'callback':callback}, 
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
  },*/
    
    doContractRequest: function(cmp, evt, helper) {
        var caseType = evt.target.id;
        var contractId = cmp.get('v.contract.Id');
        var contractName = cmp.get('v.contract.Name');
        //var accountId = cmp.get('v.contract.Account__c');
        //var contractNetInvst = cmp.get("v.contract.Net_Investment__c"); 
        //var standardPayoff = cmp.get('v.contract.Standard_Payoff_Quote__c');
        var modalBody;
        //var p = cmp;
        //var callback = cmp.getReference('c.handleCallback');
        
        $A.createComponent("c:CreateCase", {'contractId':contractId, 'contractName':contractName, 'requestContract':true, 'caseType': caseType}, 
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
    
    /*handleCallback: function(cmp, evt, helper){
    
      var data = evt.getParam('data');
      //cmp.find('modal').notifyClose();
      if(data.type == 'ContractPayoff'){
        
          helper.showPayoff(cmp,data.id);
      }else{
          helper.showCaseResponse(cmp,data.id);
      }
  }*/
})