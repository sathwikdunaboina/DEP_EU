({
    doInit: function (cmp, event, helper) {
        var contractId = cmp.get('v.contractId');
        if (contractId) {
            cmp.set('v.recordId', contractId);
        }
        
        var urlString=window.location;
        var keyvalue=window.location.pathname.split("/");
        if(keyvalue[3]==""){cmp.set("v.selectedItem","Home");}
        else if(keyvalue[3]=="contracts")
        {cmp.set("v.selectedItem","contracts");}
            else if(keyvalue[3]=="support")
            {cmp.set("v.selectedItem","support");} 
                else if(keyvalue[3]=="payment-plan")
                {cmp.set("v.selectedItem","contracts");}
                    else if(keyvalue[3]=="contract")
                    {cmp.set("v.selectedItem","contracts");} 
        /*else if(keyvalue[3]=="assets")
        {cmp.set("v.selectedItem","equipment_list");}
        else if(keyvalue[3]=="payment-history")
        {cmp.set("v.selectedItem","payment_history");}
        else if(urlString=="https://batinternet.speedpay.com/volvo/#/login/guest")
        {cmp.set("v.selectedItem","make_a_payment");}*/
        /*else if(keyvalue[3]=="contract-assets-list")
                {cmp.set("v.selectedItem","contracts");}
        else if(keyvalue[3]=="contract-cs")
        {cmp.set("v.selectedItem","contracts");}*/
        /*else if(keyvalue[3]=="contract-invoices-list")
            {cmp.set("v.selectedItem","contracts");}
                else if(keyvalue[3]=="contract-payment-history-list")
                {cmp.set("v.selectedItem","contracts");}
                    else if(keyvalue[3]=="contentdocument")
                    {cmp.set("v.selectedItem","contracts");}*/
    },
    
    doNavigate: function (cmp, event, helper) {
        var nav_name = event.getParam('name');
        console.log(nav_name);
        var navMenu = cmp.find('navMenu');
        navMenu.set('v.selectedItem', nav_name);
        var recordId=cmp.get("v.contractId");
        
        if (nav_name === 'contracts') {
            helper.navigatecontract(cmp, recordId);
        }/* else if (nav_name === 'equipment_list') {
            helper.navigateasset(cmp, event,helper);
        }*/ else if (nav_name === 'Home') {
            helper.navigatedashboard (cmp, cmp.get("v.contractId"));
        }/* else if (nav_name === 'payment_history') {
            helper.navigatePaymentHistory (cmp, cmp.get("v.contractId"));
        }*/ else if (nav_name === 'support') {
            helper.navigatesupport(cmp, cmp.get("v.contractId"));
        }/* else if (nav_name === 'make_a_payment') {
            helper.navigatemakeapayment (cmp, cmp.get("v.contractId"));
        }*/
    },
    
    doNavigat: function (cmp, event, helper) {
        var nav_name = event.getParam('name');
        console.log(nav_name);
        var navMenu = cmp.find('navMen');
        navMenu.set('v.selectedItem', nav_name);
        var recordId=cmp.get("v.contractId");
        
        if (nav_name === 'contracts') {
            helper.navigatecontract(cmp, recordId);
        }/* else if (nav_name === 'equipment_list') {
            helper.navigateasset(cmp, event,helper);
        }*/ else if (nav_name === 'Home') {
            helper.navigatedashboard (cmp, cmp.get("v.contractId"));
        }/* else if (nav_name === 'payment_history') {
            helper.navigatePaymentHistory (cmp, cmp.get("v.contractId"));
        }*/ else if (nav_name === 'support') {
            helper.navigatesupport(cmp, cmp.get("v.contractId"));
        } /*else if (nav_name === 'make_a_payment') {
            helper.navigatemakeapayment (cmp, cmp.get("v.contractId"));
        }*/
    },
    
    handleApplicationEvent : function (cmp, event, helper) {
        var data = event.getParam("data");
        cmp.set('v.contractId', data.contractId);
    }
})