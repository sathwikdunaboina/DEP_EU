({
    fetchAllCampaigns : function(cmp) {
        var action = cmp.get('c.fetchActiveCampaigns');
        action.setCallback(this, function(result){
            if (result.getState() === 'SUCCESS') {
                var records = result.getReturnValue();
                cmp.set('v.vfsCampaigns',records);
            } else {
                this.showToast(cmp, result.getError()[0].message, 'Error', 'error', '');                
            }            
        });
        $A.enqueueAction(action);
    }
})