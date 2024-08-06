({
    getTerritoryMngrDetails: function (cmp) {
        var action = cmp.get('c.getTerritoryMngr');
        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var territoryMngr = result.getReturnValue();
                //alert (territoryMngr);
                 cmp.set('v.mngr', territoryMngr);
                
            } else {
                this.showToast('Error', result.getError()[0].message, 'error', 'sticky');
            }
        });
        $A.enqueueAction(action);
    },
    
    getSupportContactDetails: function (cmp) {
     var action = cmp.get("c.getServiceDesk");
        action.setCallback(this, function(response){
            
            if(response.getState() == 'SUCCESS'){
                var rs=response.getReturnValue();
                var rssize = rs.length;
                var obj;
                for(var key in rs){
                    obj = rs[key];
                    for(var option in obj){
                        cmp.set("v.ServiceList", obj);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
})