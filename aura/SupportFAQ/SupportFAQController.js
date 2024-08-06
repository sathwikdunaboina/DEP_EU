({    
    doInit: function(component,event,helper){
        var action = component.get('c.getKnowledge');
        action.setCallback(this, function(response){
            //console.log('123');
            var state = response.getState();
            //console.log('state '+state);
            if(state === 'SUCCESS' && component.isValid()){
                //console.log('response' + response);
                component.set('v.Knowledge', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    handleClick: function(component, event, helper) {
        var elementID = event.currentTarget.id;
        var element = document.getElementById(elementID);
        var lastActive = component.get('v.whichOpen');
        if(!$A.util.isEmpty(lastActive)){
            var lastElement = document.getElementById(lastActive); 
            $A.util.removeClass(lastElement, ' slds-is-open');
        }
        $A.util.addClass(element, ' slds-is-open');
        component.set('v.whichOpen', parseInt(elementID));
    }
})