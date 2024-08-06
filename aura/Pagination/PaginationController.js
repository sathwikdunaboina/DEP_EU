({
    doInit : function(component, event, helper) {
        var sname = component.get("v.sname");
        if(sname=='document'){
            var contractId = component.get("v.total"); 
        }else{
            var contractId = component.get("v.contractId");
        }
        helper.getPageCountAndTotal(component,sname,contractId);
    },
    
    handle:function(component, event, helper){
        var contractId=event.getParam("contract");
        var sname= component.get("v.sname");
        helper.getPageCountAndTotal(component,sname,contractId);
    },
    
    // Go to previous page
    goPreviousPage : function (component, event, helper) {
        var totalPages = component.get("v.pageCounterInfo.totalPages");
        var pageNumber = component.get("v.pageCounterInfo.currentPageNumber");
        var myEvent = $A.get("e.c:PageChangeEvt");
        myEvent.setParams({
            "pageNumber": (parseInt(pageNumber)-1).toString(),
        });
        myEvent.fire();
    },
    
    // go to next page
    goNextPage : function (component, event, helper) {
        var totalPages = component.get("v.pageCounterInfo.totalPages");
        var pageNumber = component.get("v.pageCounterInfo.currentPageNumber");
        var myEvent = $A.get("e.c:PageChangeEvt");
        myEvent.setParams({
            "pageNumber": (parseInt(pageNumber)+1).toString(),
        });
        myEvent.fire();
    },
    
    pageChange: function (component, event, helper) {
        var pageNumber = event.getParam("pageNumber");
        var totalPages = component.get("v.pageCounterInfo.totalPages");
        helper.resetCounters(component, pageNumber, totalPages);
    }
})