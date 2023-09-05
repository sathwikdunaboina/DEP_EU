import { LightningElement,api,wire } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
import getOppIds from '@salesforce/apex/quoteCalloutController.getOppIds';
import getQuoteId from '@salesforce/apex/quoteCalloutController.getQuoteId';
import getOpportunities from '@salesforce/apex/quoteCalloutController.getOpportunities';
import getQuotes from '@salesforce/apex/quoteCalloutController.getQuotes';
import {CloseActionScreenEvent} from 'lightning/actions';
import UserNameFld from '@salesforce/schema/User.Name';
import LightningConfirm from "lightning/confirm";
import Quote_Id__c_FIELD from "@salesforce/schema/Opportunity.Quote_Id__c";

const fields = [Quote_Id__c_FIELD];
//import QuoteIdCUrrentRecord from '@salesforce/schema/Opportunity.Quote_Id__c';
export default class SearchQuoteCalloutUI extends LightningElement {
  @api recordId;
  @api objectApiName;
  @api isLoaded = false;
  userId = Id;
  currentUserName = UserNameFld;
  //currentRecordQUOTEId = QuoteIdCUrrentRecord;
    @wire(getRecord, { recordId: Id, fields: [UserNameFld]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
        }
    }

    @wire(getRecord, {
        recordId: "$recordId",
        fields
      })
      opportunity;
  tableHeadings = ["Name","Quote Id", "Amount","Brand", "Dealer Name", "Dealer Delivery Date", "Closed Date"];
  data = [];
  fullData = [];
  nonClosedateArray = [];
  nonClosedateArraySelected = [];
  firstCall = false;
  secondcall = false;

    renderedCallback() {
        if (this.firstCall == false && this.recordId != null && this.secondcall == false) {
            getOpportunities({
                    oppId: this.recordId
                })
                .then(result => {
                    let data = result;
                    console.log(result);
                    let closedateArray = [];
                    this.nonClosedateArray = [];
                    this.nonClosedateArraySelected = [];
                    let quoteNullArray = [];
                    let amountNullArray = [];
                    data.map(ele => {
                        if (ele.Amount == null && ele.Quote_Id__c == null) {
                            if (ele.Amount == null) {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Warning',
                                        message: 'Some Record(s) not having Amount!',
                                        variant: 'warning'
                                    })
                                );
                            }
                            amountNullArray = [...amountNullArray, {
                                Id: ele.Id,
                                Name: ele.Name,
                                Quote_Id__c: ele.Quote_Id__c,
                                Amount: ele.Amount,
                                CloseDate: ele.CloseDate,
                                Brand__c: ele.Brand__c,
                                Dealer_Name__c: ele.Dealer_Name__c,
                                Dealer_Delivery_Date__c: ele.Dealer_Delivery_Date__c,
                                CurrencyIsoCode: ele.CurrencyIsoCode,
                                checkbox: false,
                                radio: false
                            }]
                        } else {
                            if (ele.Quote_Id__c != null) {
                                if (getFieldValue(this.opportunity.data, Quote_Id__c_FIELD) != null) {
                                    closedateArray = [...closedateArray, {
                                        Id: ele.Id,
                                        Name: ele.Name,
                                        Quote_Id__c: ele.Quote_Id__c,
                                        Amount: ele.Amount,
                                        CloseDate: ele.CloseDate,
                                        Brand__c: ele.Brand__c,
                                        Dealer_Name__c: ele.Dealer_Name__c,
                                        Dealer_Delivery_Date__c: ele.Dealer_Delivery_Date__c,
                                        CurrencyIsoCode: ele.CurrencyIsoCode,
                                        checkbox: false,
                                        radio: false
                                    }]
                                } else {
                                    quoteNullArray = [...quoteNullArray, {
                                        Id: ele.Id,
                                        Name: ele.Name,
                                        Quote_Id__c: ele.Quote_Id__c,
                                        Amount: ele.Amount,
                                        CloseDate: ele.CloseDate,
                                        Brand__c: ele.Brand__c,
                                        Dealer_Name__c: ele.Dealer_Name__c,
                                        Dealer_Delivery_Date__c: ele.Dealer_Delivery_Date__c,
                                        CurrencyIsoCode: ele.CurrencyIsoCode,
                                        checkbox: false,
                                        radio: true
                                    }]
                                }
                            } else if (ele.Quote_Id__c == null || ele.Amount != null) {
                                if (this.recordId == ele.Id) {
                                    this.nonClosedateArraySelected = [{
                                        Id: ele.Id,
                                        Name: ele.Name,
                                        Quote_Id__c: ele.Quote_Id__c,
                                        Amount: ele.Amount,
                                        CloseDate: ele.CloseDate,
                                        DealerId__c: ele.DealerId__c,
                                        Brand__c: ele.Brand__c,
                                        Dealer_Name__c: ele.Dealer_Name__c,
                                        Dealer_Delivery_Date__c: ele.Dealer_Delivery_Date__c,
                                        CurrencyIsoCode: ele.CurrencyIsoCode,
                                        checkbox: true,
                                        radio: false
                                    }]
                                } else {
                                    this.nonClosedateArray = [...this.nonClosedateArray, {
                                        Id: ele.Id,
                                        Name: ele.Name,
                                        Quote_Id__c: ele.Quote_Id__c,
                                        Amount: ele.Amount,
                                        CloseDate: ele.CloseDate,
                                        DealerId__c: ele.DealerId__c,
                                        Brand__c: ele.Brand__c,
                                        Dealer_Name__c: ele.Dealer_Name__c,
                                        Dealer_Delivery_Date__c: ele.Dealer_Delivery_Date__c,
                                        CurrencyIsoCode: ele.CurrencyIsoCode,
                                        checkbox: true,
                                        radio: false
                                    }]
                                }
                            }
                        }
                    })
                    getQuotes({
                        oppId: this.recordId
                    })
                    .then(result => {
                        let data = result;
                        let closedateArrayQuote = [];
                        data.map(ele => {
                            if(getFieldValue(this.opportunity.data, Quote_Id__c_FIELD) != null){
                                closedateArrayQuote = [...closedateArrayQuote,{Quote_Id__c:ele.Name,Id:ele.Name, checkbox: false, radio: false }]
                            }
                            else{
                                closedateArrayQuote = [...closedateArrayQuote, {
                                    Quote_Id__c: ele.Name,
                                    Id: ele.Name,
                                    checkbox: false,
                                    radio: true
                                }]
                            }
                        })
                        this.secondcall = true;
                        console.log(result);
                        console.log(getFieldValue(this.opportunity.data, Quote_Id__c_FIELD));
                        console.log(closedateArrayQuote);
                        this.fullData = closedateArrayQuote;
                        console.log('this.secondcall = true',this.secondcall);
                    })
                    .catch(result => {
                        this.secondcall = true;
                        console.log('Error Caused:renderedCallback secondcall' , JSON.stringify(result));
                    })
                    this.firstcall = true;
                    this.data = closedateArray.concat(quoteNullArray,this.nonClosedateArraySelected, this.nonClosedateArray,amountNullArray);
                    this.data = this.fullData.concat(this.data);
                    console.log('this.firstcall = true',this.firstcall = true)
                })
                .catch(result => {
                    this.firstcall = true;
                    console.log('Error Caused:renderedCallback firstcall' , JSON.stringify(result));
                })
        }
    }

  async linkOpportunity(event){
    const quoteIdToPass = event.target.name;
    const result = await LightningConfirm.open({
        message: `Are you sure you want to link `+event.target.name +` to the current Opportunity`,
        variant: "default", // headerless
        label: "Confirm to link"
    });
    console.log(event.target.value);
    console.log(quoteIdToPass);
    if (result) {
        //alert('Success');
        getQuoteId({ quoteId: quoteIdToPass,oppId: this.recordId })
              .then(data => {
                if(data.includes("Warning")){
                    alert('Warning');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Warning',
                            message: `${data}`,
                            variant: 'warning'
                        })
                    );
                }
                else if(data.includes("Info")){
                    alert('Info');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Information',
                            message: `${data}`,
                            variant: 'warning'
                        })
                    );
                }
                else{
                    //alert('Success');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: `${data}`,
                            variant: 'success'
                        })
                    );
                    this.dispatchEvent(new CloseActionScreenEvent());
                    setTimeout(() => { document.location.reload(); }, 2000);
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

  selectedOpportunities(event) {
      this.isLoaded = !this.isLoaded;
      let selectedOpps = this.template.querySelectorAll('lightning-input');
      let result = [];
      let resultCopy = [];
      let amountArray = [];
      let emptyAmountRecordNames = '';
      let NoDealerId = '';
      for (let i = 0; i < selectedOpps.length; i++) {
              if (selectedOpps[i].checked && selectedOpps[i].type === 'checkbox') {
                  result.push(selectedOpps[i].value);
                  console.log('result1'+result);
                  resultCopy = this.nonClosedateArray.concat(this.nonClosedateArraySelected).filter(ele=>{
                      return (ele.Id == selectedOpps[i].value)
                  }) 
                  //alert(resultCopy);
                  if(!resultCopy[0].Amount){
                      emptyAmountRecordNames += resultCopy[0].Name+',';
                      amountArray.push(resultCopy);
                  }
                  if(!resultCopy[0].DealerId__c){
                    NoDealerId += resultCopy[0].Name+',';
                  }
              }
      }
      console.log('result2'+resultCopy);
      //this.dispatchEvent(new CloseActionScreenEvent());
      if(emptyAmountRecordNames == ''){
        //alert(result);
        if(NoDealerId != ''){
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: `${NoDealerId} Record(s) not having Dealer Id!`,
                    variant: 'warning'
                })
            );
        }
        else{
            //alert(result);
          getOppIds({ ids: result })
              .then(data => {
                //alert(data);
                if(data.includes("Error")){
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: `${data}`,
                            variant: 'warning'
                        })
                    );
                }
                else if(data.includes("Please select atleast 1 record")|| data.includes("Could") || data.includes("Cannot pass")||data.includes("exception")){
                    this.isLoaded = !this.isLoaded;
                    if(data.includes("Cannot pass")||data.includes("exception")){
                        this.dispatchEvent(new CloseActionScreenEvent());
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Warning',
                            message: `${data}`,
                            variant: 'warning'
                        })
                    );
                }
                else {
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: `${data}`,
                            variant: 'success'
                        })
                    );
                    //alert('Success');
                    //setTimeout(() => {
                    //    eval("$A.get('e.force:refreshView').fire()");
                    //}, 1000);
                    setTimeout(() => { document.location.reload(); }, 1000);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }

              })
              .catch(error=>{
                //alert('Error Caused:selectedOpportunities'+JSON.stringify(error));
                console.log(error);
                console.log(JSON.stringify(error));
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Warning Message',
                        message: `${JSON.stringify(error.body.message)}`,
                        variant: 'warning'
                    })
                );
              })
            }
      }else {
        this.isLoaded = !this.isLoaded;
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: `${emptyAmountRecordNames} Record(s) not having Amount!`,
                  variant: 'error'
              })
          );
      }
  }
  selectedOpportunityAction() {
      let selectedRecords = [];

      let selectedRows = this.template.querySelectorAll('lightning-input');

      for (let i = 0; i < selectedRows.length; i++) {
          if (selectedRows[i].checked && selectedRows[i].type === 'checkbox') {
              selectedRecords.push({
                  Id: selectedRows[i].dataset.record.Id,
                  Name: selectedRows[i].dataset.record.Name,
                  Amount: selectedRows[i].dataset.record.Amount,
                  CloseDate: selectedRows[i].dataset.record.CloseDate
              })
          }
      }
  }
  handleSuccess() {
      // Close the modal window and display a success toast
      this.dispatchEvent(new CloseActionScreenEvent());
      refreshView();
      this.dispatchEvent(
          new ShowToastEvent({
              title: 'Success',
              message: 'Record updated!',
              variant: 'success'
          })
      );
  }

}