import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getOppIds from '@salesforce/apex/quoteCalloutController.getOppIds';
import getQuoteId from '@salesforce/apex/quoteCalloutController.getQuoteId';
import getOpportunities from '@salesforce/apex/quoteCalloutController.getOpportunities';
import getQuotes from '@salesforce/apex/quoteCalloutController.getQuotes';
import { CloseActionScreenEvent } from 'lightning/actions';
import UserNameFld from '@salesforce/schema/User.Name';
import LightningConfirm from "lightning/confirm";
import Quote_Id__c_FIELD from "@salesforce/schema/Opportunity.Quote_Id__c";

const fields = [Quote_Id__c_FIELD];
//import QuoteIdCUrrentRecord from '@salesforce/schema/Opportunity.Quote_Id__c';
export default class SearchQuoteCalloutUI2 extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api isLoaded = false;
    userId = Id;
    currentUserName = UserNameFld;
    //currentRecordQUOTEId = QuoteIdCUrrentRecord;
    @wire(getRecord, { recordId: Id, fields: [UserNameFld] })
    userDetails({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
        }
    }

    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    opportunity;
    tableHeadings = ["Name", "Quote Id", "Amount", "Brand", "Dealer Name", "Dealer Delivery Date", "Closed Date"];
    data = [];
    fullData = [];
    nonClosedateArray = [];
    nonClosedateArraySelected = [];
    firstCall = false;
    secondcall = false;

    renderedCallback() {
        if (this.recordId != null && this.secondcall == false) {
            getQuotes({
                    oppId: this.recordId
                })
                .then(result => {
                    let data = result;
                    let closedateArrayQuote = [];
                    data.map(ele => {
                            if (getFieldValue(this.opportunity.data, Quote_Id__c_FIELD) != null) {
                                closedateArrayQuote = [...closedateArrayQuote, { Quote_Id__c: ele.Name, Id: ele.Name, checkbox: false, radio: false, Quote_Status__c: ele.Quote_Status__c, Vin_Number__c: ele.Vin_Number__c, Financed_Amount__c: ele.Financed_Amount__c, Delivery_Date__c: ele.Delivery_Date__c, Model__c: ele.Model__c }]
                            } else {
                                closedateArrayQuote = [...closedateArrayQuote, {
                                    Quote_Id__c: ele.Name,
                                    Id: ele.Name,
                                    checkbox: false,
                                    radio: true,
                                    Quote_Status__c: ele.Quote_Status__c,
                                    Vin_Number__c: ele.Vin_Number__c,
                                    Financed_Amount__c: ele.Financed_Amount__c,
                                    Delivery_Date__c: ele.Delivery_Date__c,
                                    Model__c: ele.Model__c
                                }]
                            }
                        })
                        //this.secondcall = true;
                    console.log('resultcurrent' + result);
                    console.log(getFieldValue(this.opportunity.data, Quote_Id__c_FIELD));
                    console.log('closedateArrayQuote' + closedateArrayQuote);
                    this.data = closedateArrayQuote;
                    console.log('this.secondcall = true', this.secondcall);
                    this.secondcall = true;
                })
                .catch(result => {
                    this.secondcall = true;
                    console.log('Error Caused:renderedCallback secondcall', JSON.stringify(result));
                })
        }
    }

    async linkOpportunity(event) {
        const quoteIdToPass = event.target.name;
        const result = await LightningConfirm.open({
            message: `Are you sure you want to link ` + event.target.name + ` to the current Opportunity`,
            variant: "default", // headerless
            label: "Confirm to link"
        });
        console.log(event.target.value);
        console.log(quoteIdToPass);
        if (result) {
            //alert('Success');
            getQuoteId({ quoteId: quoteIdToPass, oppId: this.recordId })
                .then(data => {
                    if (data.includes("Warning")) {
                        alert('Warning');
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Warning',
                                message: `${data}`,
                                variant: 'warning'
                            })
                        );
                    } else if (data.includes("Info")) {
                        alert('Info');
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Information',
                                message: `${data}`,
                                variant: 'warning'
                            })
                        );
                    } else {
                        //alert('Success');
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: `${data}`,
                                variant: 'success'
                            })
                        );
                        this.dispatchEvent(new CustomEvent('refreshevent', {
                            detail: {
                                message: 'Success'
                            }
                        }));
                        setTimeout(() => { document.location.reload(); }, 2000);
                        this.dispatchEvent(new CloseActionScreenEvent());
                    }
                })
                //setTimeout(() => { document.location.reload(); }, 1000);
                //this.dispatchEvent(new CloseActionScreenEvent());
        } else {
            //and false if cancel was clicked
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Cancelled',
                    message: `Quote Link was cancelled`,
                    variant: 'warning'
                })
            );
        }
    }
}