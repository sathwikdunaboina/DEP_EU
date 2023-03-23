import { LightningElement, api, track, wire } from 'lwc';

import updateQuoteOnOpportunity from '@salesforce/apex/SearchQuoteController.updateQuoteOnOpportunity';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';

export default class SearchQuote extends LightningElement {
  @api recordId;
  @track objectApiName = "Opportunity"; 
  @track isdisplaySearchQuote = true;
  @track isdisplaycreatequote = false;
   //@track columns = {label1:"Quote Id",label2:"Account Name",label3:"Business Area",label4:"Asset Information",label5:"Factory Order Opportunity",label6:"Dealer Name",label7:"Amount",label8:"Status",label9:"Creation Date",label10:"Action Button"};
    @track columns = {label1:"Quote Id",label2:"Account Name",label3:"Business Area",label4:"Asset Information"};
    @track records = [
        {Quote_Id: "1", Account_Name: "Abc", Business_Area: "Interest", Asset_Information: "Interest"},
        {Quote_Id: "2", Account_Name: "DEF", Business_Area: "Use", Asset_Information: "Interest"},
        {Quote_Id: "3", Account_Name: "GHI", Business_Area: "Awareness", Asset_Information: "Interest" },
        {Quote_Id: "4", Account_Name: "JKL", Business_Area: "Interest", Asset_Information: "Interest" },
        {Quote_Id: "5", Account_Name: "MNO", Business_Area: "Interest", Asset_Information: "Interest" },
        {Quote_Id: "6", Account_Name: "DEF", Business_Area: "Use", Asset_Information: "Interest"},
        {Quote_Id: "7", Account_Name: "GHI", Business_Area: "Awareness", Asset_Information: "Interest" },
        {Quote_Id: "8", Account_Name: "JKL", Business_Area: "Interest", Asset_Information: "Interest" },
        {Quote_Id: "9", Account_Name: "MNO", Business_Area: "Interest", Asset_Information: "Interest" }

      ];
     @track error;
     @track isQuoteAvailable = true;
    /*connectedCallback(){
      if(this.isQuoteAvailable!=true)
      {
        this.dispatchEvent(new CloseActionScreenEvent());
      const evt = new ShowToastEvent({
        title: 'Toast Error',
        message: 'Some unexpected error1',
        variant: 'error',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
    debugger;
    console.log("Test");
      }
    
     }*/
    updateQuote(event){
           const QuoteId = event.currentTarget.dataset.id;
           alert(QuoteId);
           alert(this.recordId);
           updateQuoteOnOpportunity({
            //oppId: '0065r000005NETBAA4',
            oppId: this.recordId,
            quoteId: QuoteId})
          .then(data => {
           const evt = new ShowToastEvent({
                  title: 'Success',
                  message: 'Records saved succesfully!',
                  variant: 'Success',
                  mode: 'dismissable'
              });
              this.dispatchEvent(evt);
              //this.isHide = false;
              this.dispatchEvent(new CloseActionScreenEvent());
            //refreshApex(this.wiredRecords);
          })
          .catch(error => {
              this.error = error;
          });
       }
       onClickCreateQuote(){
        this.isdisplaySearchQuote = false;
        this.isdisplaycreatequote = true;

       }

}