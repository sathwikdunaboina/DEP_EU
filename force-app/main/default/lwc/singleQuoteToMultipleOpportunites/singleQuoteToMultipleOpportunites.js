import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Id from "@salesforce/user/Id";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getOppIds from "@salesforce/apex/quoteCalloutController.getOppIds";
import getOpportunities from "@salesforce/apex/quoteCalloutController.getOpportunities";
import getAmountFromApex from "@salesforce/apex/quoteCalloutController.getOppForAmountAndCustomer";
import { CloseActionScreenEvent } from "lightning/actions";
import UserNameFld from "@salesforce/schema/User.Name";
import ACCOUNT_NAME from "@salesforce/schema/Opportunity.Account.Name";
import CUSTOMER_ACCOUNT_NAME from "@salesforce/schema/Opportunity.Customer_Account__r.Name";
import AMOUNT from "@salesforce/schema/Opportunity.Amount";
import { CurrentPageReference } from 'lightning/navigation';
export default class SingleQuoteToMultipleOpportunites extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api isLoaded = false;
    ErrorMessageShow = false;
    userId = Id;
    currentUserName = UserNameFld;
    customerNameUI;
    dealerNameUI;
    getAmountData;
    getCustomerData;
    data = [];
    nonClosedateArray = [];
    nonClosedateArraySelected = [];
    firstCall = false;
    //disableBtn = true;
    listOfArray = [];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            console.log('wirecheck' + this.recordId);
        }
    }

    @wire(getRecord, { recordId: Id, fields: [UserNameFld] })
    userDetails({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
        }
    }
    fields = [ACCOUNT_NAME, CUSTOMER_ACCOUNT_NAME];

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [ACCOUNT_NAME, CUSTOMER_ACCOUNT_NAME, AMOUNT]
    })
    record({ error, data }) {
        if (data) {
            this.customerNameUI = getFieldValue(data, CUSTOMER_ACCOUNT_NAME);
            this.dealerNameUI = getFieldValue(data, ACCOUNT_NAME);
        }
    }

    handleChange(event) {
        if (event.target.checked) {
            let selectedOpps = this.template.querySelectorAll("lightning-input");
            if (selectedOpps) {
                for (let i = 0; i < selectedOpps.length; i++) {
                    if (selectedOpps[i].checked && selectedOpps[i].type === "checkbox") {
                        this.template.querySelector(`[data-id="${event.target.value}"]`).classList.add('highlight');
                        //console.log("selectedOpps[i]" + selectedOpps[i]);
                    }
                }
            }
            this.listOfArray.push(event.target.value);
        } else {
            this.listOfArray.pop(event.target.value);
            let selectedOpps = this.template.querySelectorAll("lightning-input");
            if (selectedOpps) {
                for (let i = 0; i < selectedOpps.length; i++) {
                    if (selectedOpps[i].checked && selectedOpps[i].type === "checkbox") {
                        this.template.querySelector(`[data-id="${event.target.value}"]`).classList.remove('highlight');
                        //console.log("selectedOpps[i]" + selectedOpps[i]);
                    }
                }
            }
        }
    }

    renderedCallback() {
        if (this.firstCall == false && this.recordId != null) {
            getAmountFromApex({ oppId: this.recordId })
                .then(result => {
                    console.log('result1' + result.Amount);
                    this.getAmountData = result.Amount;
                    this.getCustomerData = result.Customer_Account__c;
                    if (this.getAmountData == null || this.getCustomerData == null) {
                        this.ErrorMessageShow = true;
                        this.firstCall = true;
                    } else {
                        this.ErrorMessageShow = false;
                        getOpportunities({ oppId: this.recordId })
                            .then(result => {
                                let data = result;
                                //console.log(result);
                                let closedateArray = [];
                                this.nonClosedateArray = [];
                                this.nonClosedateArraySelected = [];
                                data.map(ele => {
                                    if (ele.Quote_Id__c != null || ele.Amount == null) {
                                        if (ele.Amount == null) {
                                            this.dispatchEvent(
                                                new ShowToastEvent({
                                                    title: "Warning",
                                                    message: "Some Record(s) not having Amount!",
                                                    variant: "warning"
                                                })
                                            );
                                        }
                                        closedateArray = [
                                            ...closedateArray,
                                            {
                                                Id: ele.Id,
                                                Name: ele.Name,
                                                Quote_Id__c: ele.Quote_Id__c,
                                                Amount: ele.Amount,
                                                CloseDate: ele.CloseDate,
                                                Brand__c: ele.Brand__c,
                                                Dealer_Name__c: ele.Account.Name,
                                                Dealer_Delivery_Date__c: ele.Dealer_Delivery_Date__c,
                                                CurrencyIsoCode: ele.CurrencyIsoCode,
                                                checkbox: false, // Task-7323 code changes
                                                vinNumber: ele.Factory_Order__r.VIN_Number__c, // Task-7323 code changes
                                                marketType: ele.Factory_Order__r.Market_Type_1_5__c, // Task-7323 code changes
                                                firstRecordCheckByDefault: false
                                            }
                                        ];
                                    } else if (ele.Quote_Id__c == null || ele.Amount != null) {
                                        if (this.recordId == ele.Id) {
                                            //this.disableBtn = false;
                                            this.nonClosedateArraySelected = [{
                                                Id: ele.Id,
                                                Name: ele.Name,
                                                Quote_Id__c: ele.Quote_Id__c,
                                                Amount: ele.Amount,
                                                CloseDate: ele.CloseDate,
                                                DealerId__c: ele.DealerId__c,
                                                Brand__c: ele.Brand__c,
                                                Dealer_Name__c: ele.Account.Name,
                                                Dealer_Delivery_Date__c: ele.Dealer_Delivery_Date__c,
                                                CurrencyIsoCode: ele.CurrencyIsoCode,
                                                checkbox: true, // Task-7323 code changes
                                                vinNumber: ele.Factory_Order__r.VIN_Number__c, // Task-7323 code changes
                                                marketType: ele.Factory_Order__r.Market_Type_1_5__c, // Task-7323 code changes
                                                firstRecordCheckByDefault: true
                                            }];
                                        } else {
                                            this.nonClosedateArray = [
                                                ...this.nonClosedateArray,
                                                {
                                                    Id: ele.Id,
                                                    Name: ele.Name,
                                                    Quote_Id__c: ele.Quote_Id__c,
                                                    Amount: ele.Amount,
                                                    CloseDate: ele.CloseDate,
                                                    DealerId__c: ele.DealerId__c,
                                                    Brand__c: ele.Brand__c,
                                                    Dealer_Name__c: ele.Account.Name,
                                                    Dealer_Delivery_Date__c: ele.Dealer_Delivery_Date__c,
                                                    CurrencyIsoCode: ele.CurrencyIsoCode,
                                                    checkbox: true, // Task-7323 code changes
                                                    vinNumber: ele.Factory_Order__r.VIN_Number__c, // Task-7323 code changes
                                                    marketType: ele.Factory_Order__r.Market_Type_1_5__c, // Task-7323 code changes
                                                    firstRecordCheckByDefault: false
                                                }
                                            ];
                                        }
                                    }
                                });
                                this.firstCall = true;
                                this.data = this.nonClosedateArraySelected.concat(
                                    this.nonClosedateArray,
                                    closedateArray
                                );
                            })
                            .catch(result => {
                                alert("Error Caused:renderedCallback" + JSON.stringify(result));
                            });
                    }
                })
        }
        let selectedOpps = this.template.querySelectorAll("lightning-input");
        console.log('selectedOpps' + selectedOpps);
        if (selectedOpps) {
            for (let i = 0; i < selectedOpps.length; i++) {
                console.log('selectedOpps' + selectedOpps[i].value);
                if (selectedOpps[i].checked && selectedOpps[i].type === "checkbox") {
                    this.template.querySelector(`[data-id="${selectedOpps[i].value}"]`).classList.add('highlight');
                    //console.log("selectedOpps[i]" + selectedOpps[i]);
                }
            }
        }
    }

    refreshMethod(event) {
        //console.log('event.detail.message' + event.detail.message);
        //console.log('event.detail' + event.detail);
        if (event.detail.message) {
            setTimeout(() => {
                document.location.reload();
            }, 1000);
            this.dispatchEvent(new CloseActionScreenEvent());
        };
    }
    selectAll(event) {
            let i;
           let checkboxes = this.template.querySelectorAll('[data-id="checkbox1"]');
           for(i=1; i<checkboxes.length; i++) {
                checkboxes[i].checked = event.target.checked;              
            }
        }

    selectedOpportunities(event) {
        this.isLoaded = !this.isLoaded;
        let selectedOpps = this.template.querySelectorAll("lightning-input");
        //console.log('>>> selectedOpps = ', JSON.stringify(selectedOpps)); // Task-7232 code changes
        let result = [];
        let resultCopy = [];
        let amountArray = [];
        let emptyAmountRecordNames = "";
        let NoDealerId = "";
        for (let i = 1; i < selectedOpps.length; i++) {
            if (selectedOpps[i].checked && selectedOpps[i].type === "checkbox") {
                result.push(selectedOpps[i].value);             
                resultCopy = this.nonClosedateArray
                    .concat(this.nonClosedateArraySelected)
                    .filter(ele => {
                        return ele.Id == selectedOpps[i].value;
                    });           
                if (!resultCopy[0].Amount) {
                    emptyAmountRecordNames += resultCopy[0].Name + ",";
                    amountArray.push(resultCopy);
                }
                if (!resultCopy[0].DealerId__c) {
                    NoDealerId += resultCopy[0].Name + ",";
                }
            }
        }
        //console.log("result2" + resultCopy);
        //this.dispatchEvent(new CloseActionScreenEvent());
        if (emptyAmountRecordNames == "") {
            //alert(result);
            if (NoDealerId != "") {
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: `${NoDealerId} Record(s) not having Dealer Id!`,
                        variant: "warning"
                    })
                );
            } else {
                getOppIds({ ids: result })
                    .then(data => {
                        //alert(data);
                        if (data.includes("Error")) {
                            this.dispatchEvent(new CloseActionScreenEvent());
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Error",
                                    message: `${data}`,
                                    variant: "warning"
                                })
                            );
                        } else if (
                            data.includes("Please select atleast 1 record") ||
                            data.includes("Could") ||
                            data.includes("Cannot pass") ||
                            data.includes("exception") ||
                            data.includes("errorMessage")
                        ) {
                            this.isLoaded = !this.isLoaded;
                            if (
                                data.includes("Cannot pass") ||
                                data.includes("exception") ||
                                data.includes("errorMessage")
                            ) {
                                this.dispatchEvent(new CloseActionScreenEvent());
                            }
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Warning",
                                    message: `${data}`,
                                    variant: "warning"
                                })
                            );
                        } else {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Success",
                                    message: `${data}`,
                                    variant: "success"
                                })
                            );
                            setTimeout(() => {
                                document.location.reload();
                            }, 1000);
                            this.dispatchEvent(new CloseActionScreenEvent());
                        }
                    })
                    .catch(error => {
                        this.dispatchEvent(new CloseActionScreenEvent());
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Warning Message",
                                message: `${JSON.stringify(error.body.message)}`,
                                variant: "warning"
                            })
                        );
                    });
            }
        } else {
            this.isLoaded = !this.isLoaded;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: `${emptyAmountRecordNames} Record(s) not having Amount!`,
                    variant: "error"
                })
            );
        }
    }
}