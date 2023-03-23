({
	initialize : function(component, event, helper) {

        // Prepare the action to load account record
        var action = component.get("c.getContractList");
        action.setParams({"accountId": component.get("v.recordId")});

        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                 $A.get('e.force:refreshView').fire();
                 $A.get("e.force:closeQuickAction").fire();
            } else {
                console.log('Problem getting account, response state: ' + state);
                component.set('v.errormessage','Unable to fetch the Contract Details.')
            }
        });
        $A.enqueueAction(action);
    },

})