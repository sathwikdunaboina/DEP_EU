({
    doInit: function (cmp, event, helper) {
        helper.toggleAD(cmp, 'Number');
        helper.getTotalRecords(cmp);
        helper.getContracts(cmp, 'Number',cmp.get("v.pageNumber")); 
    },
    
    handleClick:function(cmp,event,helper){
        var search=cmp.get("v.searchKeyword");
        helper.getContracts(cmp, 'Number', cmp.get("v.pageNumber"),cmp.get("v.searchKeyword"));
        var appEvent=$A.get("e.c:PaginationEvt");
        appEvent.setParams({
            "contract" : search});
        appEvent.fire();
    },
    
    handleEnterClick:function(cmp,event,helper){
        if(event.getParams().keyCode === 13){
            var search=cmp.get("v.searchKeyword");
            helper.getContracts(cmp, 'Number', cmp.get("v.pageNumber"),cmp.get("v.searchKeyword"));
            var appEvent=$A.get("e.c:PaginationEvt");
            appEvent.setParams({
                "contract" : search});
            appEvent.fire();
        }
    },
    
    pageChange: function(cmp, event, helper) {
        var pageNumber = event.getParam("pageNumber");
        var order=cmp.get("v.order");
        cmp.set("v.pageNumber", pageNumber);
        helper.getContracts(cmp, order, pageNumber, cmp.get("v.searchKeyword"));
        var elmnt = document.getElementById("x");
        elmnt.scrollIntoView(false);
    },
    
    sortByContractNumber: function (cmp, event, helper) {
        cmp.set("v.order", 'Number');
        helper.toggleAD(cmp, 'Number');
        helper.getContracts(cmp, 'Number', cmp.get("v.pageNumber"), cmp.get("v.searchKeyword"));
    },
    
    sortByDueDate: function (cmp, event, helper) {
        cmp.set("v.order", 'Due Date');
        helper.toggleAD(cmp, 'Due Date');
        helper.getContracts(cmp, 'Due Date', cmp.get("v.pageNumber"), cmp.get("v.searchKeyword"));
    },
      
    
    sortByMaturityDate: function (cmp, event, helper) {
        cmp.set("v.order", 'Maturity Date');
        helper.toggleAD(cmp, 'Maturity Date');
        helper.getContracts(cmp, 'Maturity Date', cmp.get("v.pageNumber"), cmp.get("v.searchKeyword"));
    },
    
    /*doExport: function (cmp, event, helper) {
        var order = cmp.get("v.order");
        if(order != null || order != ''){
            helper.getAllRecordsForExport(cmp, order);
        }else{
            helper.getAllRecordsForExport(cmp, 'Number');
        }
    },*/    
})