import { LightningElement,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
import getOppIds from '@salesforce/apex/quoteCalloutController.getOppIds';
import getOpportunities from '@salesforce/apex/quoteCalloutController.getOpportunities';
import {CloseActionScreenEvent} from 'lightning/actions';
import UserNameFld from '@salesforce/schema/User.Name';
export default class SingleQuoteToMultipleOpportunites extends LightningElement {
  @api recordId;
  @api objectApiName;
  @api isLoaded = false;
  userId = Id;
  currentUserName = UserNameFld;
  @wire(getRecord, { recordId: Id, fields: [UserNameFld]}) 
  userDetails({error, data}) {
      if (data) {
          this.currentUserName = data.fields.Name.value;
      }
  }
  tableHeadings = ["Name","Quote Id", "Amount","Brand", "Dealer Name", "Dealer Delivery Date", "Closed Date"];
  data = [];
  nonQuotedOpp = [];
  nonQuotedOppSelected = [];
  firstCall = false;
  renderedCallback() {
      if (this.firstCall == false && this.recordId != null) {
          getOpportunities({ oppId: this.recordId })
              .then(result => {
                  let data = result;
                  console.log(result);
                  let QuotedOpp = [];
                  this.nonQuotedOpp = [];
                  this.nonQuotedOppSelected = [];
                  data.map(ele => {
                      if (ele.Quote_Id__c != null) {
                          QuotedOpp = [...QuotedOpp, {Id:ele.Id, Name: ele.Name,Quote_Id__c:ele.Quote_Id__c, Amount: ele.Amount, CloseDate: ele.CloseDate,Brand__c: ele.Brand__c,
                            Dealer_Name__c: ele.Dealer_Name__c,Dealer_Delivery_Date__c: ele.Dealer_Delivery_Date__c,CurrencyIsoCode : ele.CurrencyIsoCode, checkbox: false }]
                      } else if(ele.Quote_Id__c == null) {
                        if(this.recordId == ele.Id){
                            this.nonQuotedOppSelected = [{Id:ele.Id, Name: ele.Name,Quote_Id__c:ele.Quote_Id__c, Amount: ele.Amount, CloseDate: ele.CloseDate,DealerId__c: ele.DealerId__c,
                                Brand__c: ele.Brand__c,Dealer_Name__c: ele.Dealer_Name__c,Dealer_Delivery_Date__c: ele.Dealer_Delivery_Date__c,CurrencyIsoCode : ele.CurrencyIsoCode, checkbox: true }]
                        }
                        else{
                            this.nonQuotedOpp = [...this.nonQuotedOpp, {Id:ele.Id, Name: ele.Name,Quote_Id__c:ele.Quote_Id__c, Amount: ele.Amount, CloseDate: ele.CloseDate,DealerId__c: ele.DealerId__c,
                              Brand__c: ele.Brand__c,Dealer_Name__c: ele.Dealer_Name__c,Dealer_Delivery_Date__c: ele.Dealer_Delivery_Date__c,CurrencyIsoCode : ele.CurrencyIsoCode, checkbox: true }]
                        }
                      }
                  })
                  this.firstCall = true;
                  this.data = QuotedOpp.concat(this.nonQuotedOppSelected.concat(this.nonQuotedOpp));
              })
              .catch(result => {
                alert('Error Caused:renderedCallback'+JSON.stringify(result)); 
              })
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
                  resultCopy = this.nonQuotedOpp.filter(ele=>{
                      return (ele.Id == selectedOpps[i].value)
                  })
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
          getOppIds({ Ids: result })
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
                else if(data.includes("Please select atleast 1 record")|| data.includes("Could") || data.includes("Cannot pass")){
                    this.isLoaded = !this.isLoaded;
                    if(data.includes("Cannot pass")){
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
                    alert('Success');
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