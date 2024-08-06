({
    doInit: function (cmp, event, helper) {
        cmp.set('v.sortByNumber', false);
        helper.toggleAD(cmp, 'Number');
        helper.getPaymentsForContract(cmp, 'Number',cmp.get("v.pageNumber"), cmp.get('v.sortByNumber'));
        
        console.log('payment list init');
        console.log('contractID' , cmp.get('v.contractId'));
    },
    navigatecontract: function (cmp, event, helper) {
         var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/contracts"
        });
        urlEvent.fire(); 
    },
    pageChange: function(cmp, event, helper) {
        var pageNumber = event.getParam("pageNumber");
        var order=cmp.get("v.order");
        cmp.set("v.pageNumber", pageNumber);
        helper.getPaymentsForContract(cmp, order, pageNumber, cmp.get('v.sortByNumber'));
        var elmnt = document.getElementById("x");
        elmnt.scrollIntoView(false);
    },
    
    sortByContractNumber: function (cmp, event, helper) {
        cmp.set('v.sortByNumber', true);
        console.log('sortByContractNumber');
        helper.toggleAD(cmp, 'Number');
        helper.getPaymentsForContract(cmp, 'Number',cmp.get("v.pageNumber"), cmp.get('v.sortByNumber'));
    },
    
    search: function (cmp, event, helper) {
        console.log('search');
        cmp.set('v.offset', 0);
        helper.getPaymentsForContract(cmp, 'Number',cmp.get("v.pageNumber"), cmp.get('v.sortByNumber'));
    },
    
    /*doExport: function (cmp, event, helper) {
        helper.getAllRecordsForExport(cmp, 'Number');
    },*/
})