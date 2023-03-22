({
	getAccountDetails: function (cmp) {
        var action = cmp.get('c.getAccount');
        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var acct = result.getReturnValue();
             
                 cmp.set('v.acct', acct);
                
            } else {
                this.showToast('Error', result.getError()[0].message, 'error', 'sticky');
            }
        });
        $A.enqueueAction(action);
    },
})