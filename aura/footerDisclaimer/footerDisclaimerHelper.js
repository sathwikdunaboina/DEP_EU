/*
 * Created by : Harshit : 20 December 19
 * Assigns Footer links for disclaimer from custom setting Footer Link 
*/

({
    publicLinks : function(component) {
        var action   = component.get("c.getPublicLinks");
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS')
            {
                
                var links = response.getReturnValue();
               
                for (var i=0; i<links.length; i++) {
                    
                    if ((links[i].Document_Link__c !== null ) || (typeof links[i].Document_Link__c !== "undefined"))
                    {
                        if(links[i].Type__c == 'Local') {
                            component.set('v.localDisclaimer', links[i].Document_Link__c); 
                        }
                        else if(links[i].Type__c == 'GDPR'){
                            component.set('v.gdprDisclaimer', links[i].Document_Link__c); 
                        }
                    }
                }
            }else  if(response.getState() === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                }
                this.showToast('Error', result.getError()[0].message, 'error', 'sticky');
            }
        });
        $A.enqueueAction(action); 
    }
})