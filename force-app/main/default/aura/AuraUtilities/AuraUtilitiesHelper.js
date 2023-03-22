/**
 * Created on 9/24/18.
 */
({
    
    showToast: function (cmp, message,  title, toastType, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title ? title : 'Info',
            message: message,
            type: toastType ? toastType : 'info',
            mode: mode ? mode : 'dismissible'
        });
        toastEvent.fire();
    },

    showSpinner: function (cmp) {
        console.log(cmp.get('v.showSpinner'));
        cmp.set('v.showSpinner', true);

        console.log(cmp.get('v.showSpinner'));
    },

    hideSpinner: function (cmp) {

        cmp.set('v.showSpinner', false);


    },


    //Portal nav
    navigateToDocuments: function (cmp, contractId) {
       // alert(contractId);
       //  "url": "/contentdocument/related/" + contractId + "/AttachedContentDocuments"

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/contract-documents?contractId=" + contractId
        });
        urlEvent.fire();
    },

    navigateToSchedulePayment : function (cmp, contractId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/schedule-payment?contractId=" + contractId
        });
        urlEvent.fire();

    },

    navigateToInvoices : function (cmp, contractId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/contract-invoices-list?contractId=" + contractId
        });
        urlEvent.fire();
    },

    navigateToPaymentHistory : function (cmp, contractId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/contract-payment-history-list?contractId=" + contractId
        });
        urlEvent.fire();
    },
    
    navigateToPaymentPlan : function (cmp, contractId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/payment-plan?contractId=" + contractId
        });
        urlEvent.fire();
    },

    navigateToAssets : function (cmp, recordId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/contract-assets-list?contractId=" + recordId
        });
        urlEvent.fire();
    },
    
     navigateToContractDetail : function (cmp, recordId, name) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/contract/" + recordId + "/" + name
        });
        urlEvent.fire();
    },
})