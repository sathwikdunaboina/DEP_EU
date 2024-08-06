({
    toggleAD: function (cmp, order) {
        var ad = cmp.get('v.ad');
        if(order != cmp.get('v.order')){
           ad = 'ASC';
        }else{
            if(ad == 'ASC'){
                ad = 'DESC';
            }else{
                ad = 'ASC';
            }
        }
        cmp.set('v.ad', ad);
        cmp.set('v.offset', 0);
    },
    
    getPaymentsForContract: function (cmp, order,pNum, sortByNumber) {
        this.showSpinner(cmp);
        cmp.set('v.order', order);
        var ad = cmp.get('v.ad');
        if(cmp.find('search')){
            var search = cmp.find('search').get('v.value');
            var from = cmp.find('from').get('v.value');
            var to = cmp.find('to').get('v.value');
        }
        if(sortByNumber){
            order = 'Number';
        }else{
            order = 'Date_Received';
        }
        
        var action = cmp.get('c.getPaymentsByCheckNumber');
        action.setParams({'contractId' : cmp.get('v.contractId'), 'order' : order, 'ad': ad, 'pageNumber' : pNum,'search': search, 'frm': from, 'to': to});
        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var records = result.getReturnValue();
                cmp.set('v.paymentList', records);
                cmp.set('v.count', records.length);
            } else {
                console.log(result.getError());
                this.showToast(cmp, result.getError()[0].message, 'Error', 'error', 'sticky');
            }
            this.hideSpinner(cmp);
        });
        $A.enqueueAction(action);
    },
    
    /*getAllRecordsForExport: function (cmp, order) {
        console.log('getAllRecordsForExport', cmp.get('v.contractId'));
        this.showSpinner(cmp);
        //order and offset
        cmp.set('v.order', order);
        var order = cmp.get('v.order');
        var offset = 0;
        var max = 1000;//cmp.get('v.max');
        var ad = cmp.get('v.ad');

        //search fields
        if(cmp.find('search')){
            var search = cmp.find('search').get('v.value');
            var from = cmp.find('from').get('v.value');
            var to = cmp.find('to').get('v.value');
        }

        var action = cmp.get('c.getPaymentsByContractId');

        action.setParams({'contractId' : cmp.get('v.contractId'), 'order' : order, 'ad': ad, 'offset': offset, 'max': max, 'search': search, 'frm': from, 'to': to});

        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var records = result.getReturnValue();


                var exp = cmp.find("export");
                var data = records;//cmp.get('v.paymentList');
                var headers = JSON.parse('{ "Contract_Number__c": "Contract Number", "Date_Due__c": "Date Due", "Date_Received__c": "Date Received", "Description__c": "Description", "Amount_Paid__c": "Amount Paid", "Payment__c": "Payment", "Taxes__c": "Taxes", "Misc__c": "Misc", "Late_Charge__c": "Late Charges" }');
                exp.exportCSV('Payment History Export', headers, data) ;
            } else {
                console.log(result.getError());
                this.showToast(cmp, result.getError()[0].message, 'Error', 'error', 'sticky');
            }

            this.hideSpinner(cmp);
        });

        $A.enqueueAction(action);

    },*/
})