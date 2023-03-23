public class SynapseGetReport2BResponseJSON2Apex
{
    public class CreditDecision
    {
        public Integer Approved;
        public String Description;
    }
       public Integer ErrorOccured;
       public GetReport2BResponse GetReport2BResponse;
       public CreditDecision CreditDecision;
       public Report Report;
       public ReportInfo ReportInfo;
       public Customer Customer;
       public CreditInfo CreditInfo;
       public MinorFields MinorFields;
       public Header Header;
       public Result Result;
     //   public DetailResponse DetailResponse;
    
    public class Header
    {
        public String MessageDateTime;
        public double MessageVersion;
        public String CallingSystem;
        public String CallingReferenceId;
        public String CountryCode;
        public String BusinessArea;
        public String MarketCode;
        public String CompanyId;
        public String UserId;
    }
    
    public class MinorField
    {
        public String Name;
        public String Value;
    }
   
    	public class Message 
        {
		public String Code;
		public String Description;
		public String Type;
	    }
    
    public class Report
    {
        public String Customer;
        public String ReportInfo;
    }
    
    public class Customer
    {
        //public List<Name> Name;
        public String ExternalCustomerId;  //Integer
        public Long ChambreOfCommerce;
        public String CustomerType;
        public String NatureOfBusiness;
        public String RegisterCourtDate;
    }
    
    public class ReportInfo
    {
        public Integer ProductId;
        public String ReportId;
        public String ReportDate;
    }
    
    public class MinorFields
    {
        public List<MinorField> MinorField;
    }
   
    
    public class CreditInfo
    {
        public CreditDecision CreditDecision;
        public String MaxFinancedAmount;  //Integer
        public String IsBlackListed;  	//Integer
        public String MaxTerms;			//Integer
        public String CreditRating;
    }
    
    public class Result
    {
        public Integer ErrorOccured;  //Integer
        public Report Report;
        public ReportInfo ReportInfo;
        public Customer Customer;
        public CreditInfo CreditInfo;
        public MinorFields MinorFields;
    }
    
    public class GetReport2BResponse
    {
        public Header Header;
        public Result Result;
     //   public DetailResponse DetailResponse;
    }
  /*  public class DetailResponse {
		public String ErrorOccured;
		public Messages Messages;
	}*/
   /* public class Messages {
		public Message Message;
	}*/
    
    public static SynapseGetReport2BResponseJSON2Apex parse(String json)
    {
        return (SynapseGetReport2BResponseJSON2Apex) System.JSON.deserialize(json, SynapseGetReport2BResponseJSON2Apex.class);
    }
}