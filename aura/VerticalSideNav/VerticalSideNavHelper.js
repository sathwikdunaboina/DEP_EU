({
    navigatecontract : function (cmp, recordId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/contracts"
        });
        urlEvent.fire(); 
    },
    /*navigateasset : function (cmp, recordId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/assets"
        });
        urlEvent.fire();
    },*/
    navigatedashboard : function (cmp, recordId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"
        });
        urlEvent.fire();
    },
    /*navigatePaymentHistory: function (cmp, recordId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/payment-history/Payment_History__c/Recent"
        });
        urlEvent.fire();
    },*/
    navigatesupport: function (cmp, recordId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/support"
        });
        urlEvent.fire();
    },
    /*navigatemakeapayment: function (cmp, recordId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "https://batinternet.speedpay.com/volvo/#/login/guest"
        });
        urlEvent.fire();
    },*/
})