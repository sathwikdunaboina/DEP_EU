/*
* Created: Prabha
* Data container. Contains methods to parse response into SF Standard objects.
* 
*                          Update
* Date       Developer name Tag Description 
* 14/7/2022  Lovely         T01 Commented legalStatus field as field is no longer in use
* */
public class CMSAPI_ContractDetail {
    
    public Contract__c parseFullDetails (String customerId){
        //Adding basic information
        Contract__c contract = parseBasicDetails(customerId);
        //Adding the detail information
        contract.TerminationDate__c = parse(this.terminationDate);
        contract.DealerId__c = this.dealerId;
        //Not Mapped: contract.Country__c = cmsContract.country;
        if (this.contractFinancials != null && !String.isBlank(this.contractFinancials.equipmentCost)){
            contract.Equipment_Cost__c = Decimal.valueOf(this.contractFinancials.equipmentCost);
        }
        if (this.contractFinancials != null && !String.isBlank(this.contractFinancials.residual)){
            contract.Residual__c = Decimal.valueOf(this.contractFinancials.residual);
        }
        return contract;
    }
    
    public List<Payment_Plan__c> parsePlans(Id contractId){
        List<Payment_Plan__c> plans = new List<Payment_Plan__c>();
        if (this.paymentPlan != null){
            for (PaymentPlan pplan : this.paymentPlan){
                system.debug('Incoming payment Plan...'+pplan.payment.dueDate+' & '+ pplan.payment.balance);
                Payment_Plan__c plan = new Payment_Plan__c();
                plan.Due_Date__c = parse(pplan.payment.dueDate);
                plan.Balance__c = String.isBlank(pplan.payment.balance) ? null : Decimal.valueOf(pplan.payment.balance);
                plan.Contract__c = contractId;
                plans.add(plan);
            }
        }
        return plans;
    }
    
    public Contract__c parseBasicDetails (String customerId){
        Contract__c contract = new Contract__c();
        Account accountReference = new Account( CustomerID__c = customerId);
        contract.Account__r = accountReference;
        contract.Contract_Number__c = this.id;
        contract.Contract_Id__c = customerId + '-' + this.id; //This is the external id, identifier of contract
        contract.Type__c = this.type;
        if(!String.isBlank(this.currencyCode)){
            contract.CurrencyIsoCode = this.currencyCode; // Added by Sumit. For currency mapping.
        }
        contract.VIN_Number__c = this.VINNumber;
        //contract.Legal_Status__c = this.legalStatus; // T01
        contract.Start_Date__c = parse(this.startDate);
        contract.End_Date__c = parse(this.endDate);
        contract.Name = this.id; // Added by Rupal to populate the contract number to name field.
        contract.Term__c = Decimal.ValueOf(this.term); //Do we need term from API??? 
        contract.Net_Investment__c = this.contractFinancials != null 
            && !String.isBlank(this.contractFinancials.netInvestment) ? 
            Decimal.ValueOf(this.contractFinancials.netInvestment)
            : null;
        contract.Remaining_Balance__c = this.contractFinancials != null 
            && !String.isBlank(this.contractFinancials.remainingBalance) ? 
            Decimal.ValueOf(this.contractFinancials.remainingBalance)
            : null;
        return contract;
    }
    
    public String id; //Contract number
    public String type;//Type of Contract
    public String VINNumber;//VIN Number
   // public String legalStatus;//Status of contract //T01
    public String startDate;//Start date of contract
    public String endDate;//End date of contract
    public String term;//Duration of contract
    public String currencyCode;// Added by Sumit. For currency mapping.
    public String contractName;
    public String terminationDate;
    public String dealerId;
    public String country;
    public String customerId;
    public ContractFinancials contractFinancials;
    public List<PaymentPlan> paymentPlan;
    //yyyy-MM-dd format
    public final static String GENERIC_DATE_FORMAT = '\\d{4}-(((0)[0-9])|((1)[0-2]))-([0-2][0-9]|(3)[0-1])';
    
    public class PaymentPlan{
        public Payment payment;
    }
    public class Payment{
        public String dueDate;
        public String balance;
    }
    
    public class ContractFinancials{
        public String netInvestment;//Capital
        public String remainingBalance;//Balance
        public String equipmentCost;
        public String residual;
    }
    public static Date parse(String sDate){
        //Date parsing is done without the context of User.
        //assumed to be in YYYY-MM-dd format
        if (String.isBlank(sDate)){
            return null;
        }
        Pattern genericFormat = Pattern.compile(GENERIC_DATE_FORMAT);
        if (genericFormat.matcher(sDate).matches()){
            return Date.valueOf(sDate); //parse date as per the generic YYYY-MM-dd format
        }
        return Date.parse(sDate); //if its not in generic format, then parse as per the user locale.
    }
}