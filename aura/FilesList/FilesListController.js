({
    init: function (cmp, event, helper) {
        
        var ids=cmp.get('v.contractId');
        var action = cmp.get('c.getContentDocs');
        action.setParams({
            "contractID" : ids
        });
        action.setCallback(this, function(pResponse) {
            var vState = pResponse.getState();
            var size=pResponse.getReturnValue().length;
            if (vState == "SUCCESS") {
            	cmp.set("v.fileList", pResponse.getReturnValue());    
            }
            else
                alert('line 12');
		});
        $A.enqueueAction(action);
    }
})