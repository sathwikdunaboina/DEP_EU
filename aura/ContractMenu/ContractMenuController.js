({
    doInit: function (cmp, event, helper) {
        var contractId = cmp.get("v.contractId");
        var urlString=window.location.path;
        var keyvalue=window.location.pathname.split("/");
        var urlString=window.location.path;
        var keyvalue=window.location.pathname.split("/");
        if(keyvalue[3]=="contract")
        {cmp.set("v.selTabId","details"); }
        if(keyvalue[3]=="payment-plan")
        {cmp.set("v.selTabId","payment");}
    },
    
    onOptionChange:function (cmp, event, helper) {
        var nav_name=cmp.get("v.selTabId");
        var seletedTab=cmp.find('select').get('v.value');
        cmp.set("v.selTabId",seletedTab);
        var name = cmp.get("v.simpleContractRecord.Name");
        name=name.replace(/-/g, "");
        
        if (nav_name === 'details') {
            helper.navigateToContractDetail(cmp, cmp.get("v.contractId"), name);
        } else if (nav_name === 'payment') {
            cmp.set("v.selTab1",false);
            cmp.set("v.selTab2",true);
            helper.navigateToPaymentPlan (cmp, cmp.get("v.contractId"));
        }
    },
    
    onOptionChangeVolvo:function (cmp, event, helper) {
        var nav_name=cmp.get("v.selTabId");
        var seletedTab=cmp.find('selectTransport').get('v.value');
        cmp.set("v.selTabId",seletedTab);
        var name = cmp.get("v.simpleContractRecord.Name");
        name=name.replace(/-/g, "");
        
        if (nav_name === 'details') {
            helper.navigateToContractDetail(cmp, cmp.get("v.contractId"), name);
        } else if (nav_name === 'payment') {
            cmp.set("v.selTab1",false);
            cmp.set("v.selTab2",true);
            helper.navigateToPaymentPlan(cmp, cmp.get("v.contractId"));
        } 
    },
})