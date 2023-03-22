({
	openthePage : function(component, event, helper) {
        if(component.get("v.totalpage")!=1)
        {
		var myEvent = $A.get("e.c:PageChangeEvt");
        var pageNumber = component.get("v.pageNumber");
       	myEvent.setParams({
            "pageNumber": pageNumber,
            "currnetPagesCount": component.get("v.currnetPagesCount")
        });
        myEvent.fire();
        }
	}
})