({
    getPageCountAndTotal : function(component,sname,contractId) {
        var action = component.get("c.getPageCountInfo");
        action.setParams({
            "order" : 'Number',
            "sname"	: sname,
            "contId"	: contractId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.pageCounterInfo", response.getReturnValue());                
            }
        });
        $A.enqueueAction(action);
    },
    
    resetCounters : function (component,pNum,totalPage) {
        var action = component.get("c.getPageCountChange");
        action.setParams({
            "pageNumber" : pNum.toString(),
            "totalPages" : totalPage.toString(),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.pageCounterInfo", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})