({
    getCaseTypes : function (component) {
        var objectName = 'Case';
        var action = component.get('c.getTypeSelectList');
        action.setParams({
            objectName: 'Case',
            fieldName: 'Type'
        });
        action.setCallback(this, function (resp) {
            if (resp.getState() === 'SUCCESS') {
                var result = [];
                result = resp.getReturnValue();
                var options = [];
                for(var i in result){
                    options.push({ label: result[i], value: result[i] });
                }
                component.set('v.optionsList', options);
                component.set('v.showSelection', true);
                component.set('v.showScreen', false);
            } else {
                console.log(result.getError());
                this.showToast(component, result.getError()[0].message, 'Error', 'error', 'sticky');
            }
        });
        $A.enqueueAction(action);
    },
    
    getQuoteTypes : function (component) {
        var objectName = 'Case';
        var action = component.get('c.getTypeSelectList');
        action.setParams({
            objectName: 'Case',
            fieldName: 'Sub_Type__c'
        });
        action.setCallback(this, function (resp) {
            if (resp.getState() === 'SUCCESS') {
                var result = [];
                result = resp.getReturnValue();
                var options = [];
                for(var i in result){
                    options.push({ label: result[i], value: result[i] });
                }
                component.set('v.quoteOptionsList', options);
                component.set('v.showSelection', false);
                component.set('v.showScreen', true);
            } else {
                console.log(result.getError());
                this.showToast(component, result.getError()[0].message, 'Error', 'error', 'sticky');
            }
        });
        $A.enqueueAction(action);
    },
    
    
    /*getCaseScreen : function (component, caseType) {
        var action = component.get('c.fetchCaseScreen');
        action.setParams({
            type: caseType
        });
        action.setCallback(this, function (resp) {
            if (resp.getState() === 'SUCCESS') {
                var itemsList = resp.getReturnValue().split(':');
                if(itemsList.length > 0){
                    component.set('v.itemsList', itemsList);
                    component.set('v.showSelection', false);
                    component.set('v.showScreen', true);
                }
            } else {
                console.log(result.getError());
                this.showToast(component, result.getError()[0].message, 'Error', 'error', 'sticky');
            }
        });
        $A.enqueueAction(action);
    },  */ 
    
    createCase : function (component, helper) {
        var caseObject = component.get('v.caseObj');
        if($A.util.isEmpty(caseObject.Subject)){
            this.showToast(component, 'Please enter a subject', 'Warning', 'warning', 'sticky');
            return;
        }
        
        if($A.util.isEmpty(caseObject.Description)){
            this.showToast(component, 'Please enter the description', 'Warning', 'warning', 'sticky');
            return;
        }
        
        component.set("v.saveDisabled", true);
        var userCountry = component.get('v.currentUser.Country'); 
        caseObject.Country__c = userCountry;
        var action = component.get('c.createUserCase');
        action.setParams({
            caseObj: caseObject
        });
        action.setCallback(this, function (resp) {
            if (resp.getState() === 'SUCCESS') {
                var caseObj = resp.getReturnValue();
                helper.sendCaseResponseEmail(component,caseObj.Id);
                var userObj = component.get('v.currentUser');
                var message=component.get('v.createCaseSuccessMessage');
                
                if(message==''){
                 var thankmessage=$A.get("$Label.c.Thank_You")+' '+userObj.FirstName+' '+$A.get("$Label.c.Create_Case_Success_Message");
                component.set('v.createCaseSuccessMessage',thankmessage);
               // var succesMsg = 'Thank you '+userObj.FirstName+' for contacting the Customer Service department.\n A customer service representative will respond to your request within the next 24 hours.';
               
                }
                
              var succesMsg = component.get('v.createCaseSuccessMessage');
                $A.createComponent("ui:outputText", {"value" :succesMsg},
                                   function(content, status) {
                                       if (status === "SUCCESS") {
                                           var caseDetails = component.find("caseDetails");
                                           caseDetails.set("v.body", content);
                                       }
                                   });
            }else {
                $A.get("e.force:closeQuickAction").fire();
                console.log(result.getError());
                this.showToast(component, result.getError()[0].message, 'Error', 'error', 'sticky');
            }
        });
        $A.enqueueAction(action);
    },
    
    /*showCaseResponse: function(component) {
        var whatId = null;
        var templateName = 'Payoff_Quote_Case_Created';
        var cmpBody;
        $A.createComponent("c:tc_templateOutput", {'whatId':whatId, 'templateName':templateName},
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   cmpBody = content;
                                   var caseDetails = component.find("caseDetails");
                                   var body = cmpBody;
                                   caseDetails.set("v.body", body);
                               }
                           });
    },*/
    
    sendCaseResponseEmail: function(component, cId) {
        var caseId = cId;
        var action1 = component.get('c.caseResponseEmail');
        action1.setParams({
            caseId: caseId
        });
        action1.setCallback(this, function (result) {
            if(result.getState() == 'SUCCESS') {
                console.log('Email success');
            } else {
                console.log(result.getError());
            }
        });
        $A.enqueueAction(action1);
    },
})