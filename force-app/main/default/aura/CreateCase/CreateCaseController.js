({
    onInit : function (component, event, helper) 
    {
        component.set("v.saveDisabled", false);
       
        if(component.get("v.requestContract") == true){
            component.set("v.caseObj.Type", component.get('v.caseType'));
            component.set("v.caseObj.Contract__c", component.get('v.contractId'));
            component.set("v.showScreen", true);
        }else{
            helper.getCaseTypes(component);
        }
    },
    
    selectCaseType : function (component, event, helper) 
    {
        var obj = component.get('v.caseObj');
        var caseType = obj.Type;
        if(caseType === '' || caseType === null)
            return;
        component.set('v.showSelection', false);
        component.set('v.showScreen', true);
    },
    
    createCase : function (component, event, helper) 
    {
        helper.createCase(component, helper);
    },
    
    closePopup : function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})