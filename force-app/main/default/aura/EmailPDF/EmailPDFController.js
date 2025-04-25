/**
 * @author Hari
 * @date June 2022
 * @description Controller of the Lightning Component Email PDF
 * @group Lightning
 */
({
	doInit : function(component, event, helper) {
        //Variable
        let Domain;
        
		//Call Back
        let getDomain = component.get('c.getURL');
        getDomain.setParams({});
        getDomain.setCallback(this, function(response) {
            let state = response.getState();
            
            if (state === "SUCCESS") {
                Domain = response.getReturnValue();
                
                // Modify Variable
        		component.set('v.Domain', Domain);
            }
        });
        $A.enqueueAction(getDomain);
	}
})