({
    doInit: function (cmp, event, helper) {
        var contractId = cmp.get('v.recordId');
        if (contractId) {
            cmp.set('v.contractId', contractId);
        }
        else{
            var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
            var sURLVariables = sPageURL.split('?'); //Split by & so that you get the key value pairs separately in a list
            var sParameterName;
            var i;
            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('='); //to split the key from the value.
                if (sParameterName[0] === 'firstName') { 
                    sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
                }
            }
            cmp.set("v.contractId",sParameterName[1]);
        }
        
        var urlString=window.location.path;
        var keyvalue=window.location.pathname.split("/");
        /*if(keyvalue[3]=="contract-assets-list")
        {cmp.set("v.selTabId","equipment_list");}*/
        if(keyvalue[3]=="contract")
        {cmp.set("v.selTabId","contract_details");}
        if(keyvalue[3]=="payment-plan")
        {cmp.set("v.selTabId","payment_plan");}
        /*if(keyvalue[3]=="contract-payment-history-list")
        {cmp.set("v.selTabId","payment_history");}
        // if(keyvalue[3]=="contentdocument")
        if(keyvalue[3]=="contract-documents")
        {cmp.set("v.selTabId","documents");}*/
    },
    
    selectTab : function(component, event, helper) { 
        /* General utility */
        var selected = component.get("v.key");
        component.find("tabs").set("v.selectedTabId",selected);
    },
    
    handleApplicationEvent : function (cmp, event, helper) {
        var data = event.getParam("data");
        console.log('handleApplicationEvent', data);
        cmp.set('v.contractId', data.contractId);
    },
    
    tabSelected:function (cmp, event, helper) {
        var nav_name=cmp.get("v.selTabId");
        var seletedTab=cmp.find("tabs").get("v.selectedTabId")
        cmp.find("tabs").set("v.selectedTabId",seletedTab);
        cmp.set("v.selTabId",seletedTab);
        
        if (nav_name === 'contract_details') {
            helper.navigateToContractDetail(cmp, cmp.get("v.contractId"), name);
        } 
        else if (nav_name === 'payment_plan') {
            helper.navigateToPaymentPlan(cmp, cmp.get("v.contractId"));
        }
            /*else if (nav_name === 'invoice_list') {
                cmp.set("v.selTab3",true);
                helper.navigateToInvoices (cmp, cmp.get("v.contractId"));
            } else if (nav_name === 'payment_history') {
                cmp.set("v.selTab1",false);
                cmp.set("v.selTab4",true);
                helper.getPaymentHistory(cmp,cmp.get("v.contractId"));
                helper.navigateToPaymentHistory (cmp, cmp.get("v.contractId"));
            } else if (nav_name === 'documents') {
                cmp.set("v.selTab5",true);
                helper.navigateToDocuments(cmp, cmp.get("v.contractId"));
            }*/ 
    },
    
    tabSelectedVolvo:function (cmp, event, helper) {
        var nav_name=cmp.get("v.selTabId");
        var seletedTab=cmp.find("tabsVolvo").get("v.selectedTabId")
        cmp.find("tabsVolvo").set("v.selectedTabId",seletedTab);
        cmp.set("v.selTabId",seletedTab);
        
        if (nav_name === 'contract_details') {
            helper.navigateToContractDetail(cmp, cmp.get("v.contractId"), name);
        } 
        else if (nav_name === 'payment_plan') {
            helper.navigateToPaymentPlan(cmp, cmp.get("v.contractId"));
        }
            
            /*else if (nav_name === 'invoice_list') {
                cmp.set("v.selTab3",true);
                helper.navigateToInvoices (cmp, cmp.get("v.contractId"));
            } else if (nav_name === 'payment_history') {
                cmp.set("v.selTab1",false);
                cmp.set("v.selTab4",true);
                helper.getPaymentHistory(cmp,cmp.get("v.contractId"));
                helper.navigateToPaymentHistory (cmp, cmp.get("v.contractId"));
            } else if (nav_name === 'documents') {
                cmp.set("v.selTab5",true);
                helper.navigateToDocuments(cmp, cmp.get("v.contractId"));
            } */
    },
})