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
    
    getContracts : function (cmp, order,pNum,search) {
        this.showSpinner(cmp);
        var searchall;
        cmp.set('v.order', order);
        if(search!=''){
            searchall = search;
        }
        var ad = cmp.get('v.ad');
        var action = cmp.get('c.getContractRecords');
        
        action.setParams({'order' : order, 'ad' : ad, 'pageNumber' : pNum,'search': searchall});
        
        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var records = result.getReturnValue();
                cmp.set('v.contracts', records);
                if(search !=undefined && search !=''){
                    cmp.set('v.total', records.length);
                }
                else{
                    var action = cmp.get('c.getContractRecordsTotal');
                    action.setCallback(this, function (result) {
                        if (result.getState() === 'SUCCESS') {
                            var total = result.getReturnValue();
                            cmp.set('v.total', total);
                        } else {
                            console.log(result.getError());
                            this.showToast(cmp, result.getError()[0].message, 'Error', 'error', '');
                        }
                    });
                    $A.enqueueAction(action);
                }
            } else {
                console.log(result.getError());
                this.showToast(cmp, 'Error', result.getError()[0].message, 'error', '');
            }
            this.hideSpinner(cmp);
        });
        $A.enqueueAction(action);
    },
    
    getTotalRecords: function (cmp) {
        this.showSpinner(cmp);
        var action = cmp.get('c.getContractRecordsTotal');
        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var total = result.getReturnValue();
                console.log('Success - ', total);
                cmp.set('v.total', total);
            } else {
                console.log(result.getError());
                this.showToast(cmp, result.getError()[0].message, 'Error', 'error', '');
            }
            this.hideSpinner(cmp);
        });
        $A.enqueueAction(action);
    },
    
    /*getAllRecordsForExport: function (cmp, order) {
        this.showSpinner(cmp);
        cmp.set('v.order', order);
        var order = cmp.get('v.order');
        var offset = 0;
        var max = 1000;
        var ad = cmp.get('v.ad');
        
        if(cmp.find('search')){
            var search = cmp.find('search').get('v.value');
        }
        
        var action = cmp.get('c.getContractSummariesByContractId');
        action.setParams({'order' : order, 'ad': ad, 'offset': offset, 'max': max, 'search': search});
        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var records = result.getReturnValue();
                var exp = cmp.find("export");
                var data = records;
                var headers = JSON.parse('{ "Name": "Contract Number", "Contract_Balance_Remaining__c": "Balance", "Commencement_Date__c": "Commencement Date", "Maturity_Date__c": "Maturity Date", "Payment_Due_Date__c": "Due Date", "Current_Amount_Due__c": "Amount Due"}');
                exp.exportCSV('Contract Summaries Export', headers, data) ;
            } else {
                console.log(result.getError());
                this.showToast(cmp, result.getError()[0].message, 'Error', 'error', 'sticky');
            }
            this.hideSpinner(cmp);
        });
        $A.enqueueAction(action);
    },*/
    
})