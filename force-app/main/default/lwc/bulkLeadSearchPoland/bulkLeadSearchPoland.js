import { LightningElement, wire } from 'lwc';
import fetchMyLeads from '@salesforce/apex/BulkLeadSearchController.fetchMyLeads';
import fetchAllLeads from '@salesforce/apex/BulkLeadSearchController.fetchAllLeads';
import fetchAccountsOfLeads from '@salesforce/apex/BulkLeadSearchController.fetchAccountsOfLeads';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Company', fieldName: 'Company' },
    { label: 'Name', fieldName: 'Name' },
    { label: 'Sales Person Name', fieldName: 'Sales_Person_Name__c' },
    { label: 'Product Name', fieldName: 'Product_Name__c' },
    { label: 'Axile Arrangement', fieldName: 'Axle_Arrangement__c' },
    { label: 'Chassis Type', fieldName: 'Chassis_Type__c' },
    { label: 'Dealer Name', fieldName: 'Dealer_Name__c' },
    { label: 'Lead Status', fieldName: 'Status' },
    { label: 'Vehicle Status', fieldName: 'Vehicle_Status__c' },
    { label: 'Dealer Delivery Date', fieldName: 'Dealer_Delivery_Date__c', type: 'date' },
    { label: 'Owner', fieldName: 'OwnerName' },
    { label: 'Lead Source', fieldName: 'LeadSource' }
];
///////////////////////////////////////////////////////////////////////////////
export default class bulkLeadSearchPoland extends LightningElement {
    scope = 'MyLeads';
    dealerName = ''; data;
    selectedAccount = '';
    isFetchingAccounts; isFetchingData; rowSize = '50';
    columns = columns; showModal = false;
    selectedIds;
    accountsOfDealerData = [];

    // init
    connectedCallback() {
        try {
            this.search();
            this.fetchAccounts();
        }
        catch{
            console.error(error);
        }
    }
    get leadOwnerOptions() {
        return [
            { label: 'My Leads', value: 'MyLeads' },
            { label: 'All Leads', value: 'AllLeads' },
        ];
    }
    get rowSizeOptions() {
        return [
            { label: '10', value: '10' },
            { label: '20', value: '20' },
            { label: '50', value: '50' },
            { label: '100', value: '100' },
            { label: '150', value: '150' },
            { label: '200', value: '200' }
        ];
    }
    get accountsOfDealer() {
        return this.accountsOfDealerData;
    }
    get disableConvertButton(){
        return !(this.selectedAccount);
    }
    get isProcessing(){
        return (this.isFetchingAccounts || this.isFetchingData);
    }
    convertSelected(){
        this.selectedIds = this.template.querySelector(".leadDataTable").selectedRows;
        console.log('trying to convert '+ this.selectedIds);
        if (this.selectedIds != undefined && this.selectedIds.length>0){
            this.showModal = true;
        } else {
            this.showNotification('Select leads to convert','Please Select leads using the left checkbox','error')
        }
    }
    handleScopeSelection(event) {
        this.scope = event.target.value;
        this.clearFilterCriteria();
        this.search();
        this.fetchAccounts();
    }
    handleSearchLeads(event) {    
        this.dealerName = event.target.value;
        this.selectedAccount = '';
        this.search();
        this.fetchAccounts();
    }
    handleAccountSelection(event) {    
        this.selectedAccount = event.target.value;
        this.search();
    }
    handleRowSizeSelection(event) {   
        this.rowSize = event.target.value;
        this.search();
    }
    handleClearFilterCriteria() {
        if (this.selectedAccount || this.dealerName)
        {
            this.clearFilterCriteria();
            this.search();
            this.fetchAccounts();
        }
    }
    search(){
        this.isFetchingData = true;
        this.data = null;
        if (this.scope == 'MyLeads'){
            fetchMyLeads({
                dealerName : this.dealerName,
                accountName: this.selectedAccount,
                rowSize : this.rowSize
            }).then(result =>{
                this.setData(result);
                this.isFetchingData = false;
            }).catch(error =>{
                this.showNotification('Error',error,'error');
                console.error(error);
                this.isFetchingData = false;
            });
        } else {
            fetchAllLeads({
                dealerName : this.dealerName,
                accountName: this.selectedAccount,
                rowSize : this.rowSize
            }).then(result =>{
                this.setData(result);
                this.isFetchingData = false;
            }).catch(error =>{
                this.showNotification('Error',error,'error');
                console.error(error);
                this.isFetchingData = false;
            });
        }
    }
    fetchAccounts(){
        this.isFetchingAccounts = true;
        if (this.scope == 'MyLeads'){
            fetchAccountsOfLeads({
                dealerName : this.dealerName,
                myLeads: true
            }).then(result =>{
                this.fillAccountsComboBox(result);
                this.isFetchingAccounts = false;
            }).catch(error =>{
                this.showNotification('Error',error,'error');
                console.error(error);
                this.isFetchingAccounts = false;
            });
        } else {
            fetchAccountsOfLeads({
                dealerName : this.dealerName,
                myLeads: false
            }).then(result =>{
                this.fillAccountsComboBox(result);
                this.isFetchingAccounts = false;
            }).catch(error =>{
                this.showNotification('Error',error,'error');
                console.error(error);
                this.isFetchingAccounts = false;
            });
        }
    }
    clearSelected(){
        this.template.querySelector(".leadDataTable").selectedRows = [];
    }
    clearFilterCriteria() {
        this.dealerName = '';
        this.selectedAccount = '';
    }
    close(){
        this.showModal = false;
        this.search();
    }
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    setData(result){
        try {
               this.data = [];
               result.forEach(res =>{
               this.data = [...this.data,{  Id: res?.Id,
                                            Company: res?.Company, 
                                            Name: res?.Name,
                                            Sales_Person_Name__c: res?.Sales_Person_Name__c,
                                            Product_Name__c: res?.Product_Name__c, 
                                            Axle_Arrangement__c: res?.Axle_Arrangement__c,
                                            Chassis_Type__c: res?.Chassis_Type__c,
                                            Dealer_Name__c: res?.Dealer_Name__c,
                                            Status: res?.Status,
                                            Vehicle_Status__c: res?.Vehicle_Status__c,
                                            Dealer_Delivery_Date__c: res?.Dealer_Delivery_Date__c,
                                            OwnerName: res?.Owner?.Name,
                                            LeadSource: res?.LeadSource}]
            });         
        }
        catch (error) {
            console.error(error);
        }
    }
    fillAccountsComboBox(result){
        try {
            this.accountsOfDealerData = [];
            result.forEach(res =>{
               this.accountsOfDealerData = [...this.accountsOfDealerData,{ label: res, value: res }]
            });
        } 
        catch (error) {
            console.error(error);
        }
    }
}