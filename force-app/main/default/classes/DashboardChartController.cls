public class DashboardChartController {
    /*public boolean displayPopup {get; set;}     
public void closePopup() {        
displayPopup = false;    
}     
public void showPopup() {        
displayPopup = true;    
}*/
    
    public String retrunString {get; set;}
    public Integer totalContract{get; set;}
    public List<Contract__c> records2 {get; set;}
    public List<User> accList {get;set;}
    //public String AccountBrand {get; set;}
    public String accountBrand {get; set;}
    public String colors {get; set;}
    public String colorlabel {get; set;}
    public String totalcountColor {get; set;}
    public String urlforvf {get; set;}
    public String headerdata{get;set;}
    public String urlvalue{get;set;}
    public String url{get;set;}
    
    public DashboardChartController(){
        accountBrand='x';
        retrunString='[ "Contract_Type", "Count"]';
        totalContract = 0;
        headerdata= ApexPages.currentPage().getHeaders().get('Host');
        
        urlvalue=Apexpages.currentPage().getUrl();
        
        url='https://' + headerdata+ urlvalue;
        // urlforvf='https://infosys-custpoc.cs96.force.com';
        urlforvf=url;
        List<String> xlist =new List<String>();		// Modified by Sumit. Replaced String type with Decimal
        Map<String,Integer> mapLeadSource = new Map<String,Integer>();   // Modified by Sumit. Replaced String type with Decimal
        system.debug('url'+System.URL.getSalesforceBaseUrl());
        
        accList=[SELECT Account.Branding__c From User WHERE Id=:UserInfo.getUserID()];
        //AccountBrand = accList[0].Branding__c;
        for(Integer i=0;i<accList.size();i++)
        {
            if(i==0)
            {
                accountBrand  =accList[i].Account.Branding__c;
            }
        }
        
        if(accountBrand=='Renault')		// Modified by Sumit.
        {colors='["#D3D3D3","#8b8d8d","#e31b23"]';
         totalcountColor='#e31b23';
        }
        else		
        { colors='["#D3D3D3","#808080", "#06536a"]';
         totalcountColor='#182871';
        }
        
        /*if(accountBrand=='Volvo')		// Modified by Sumit.
{colors='["#D3D3D3","#8b8d8d","#2e6da0"]';
totalcountColor='#2E6DA0';
}
else if(accountBrand=='Renault')		// Modified by Sumit.
{ colors='["#8b8d8d", "#87754e", "#000000"]';
totalcountColor='#000000';
} 
else
{colors='["#D3D3D3","#808080", "#06536a"]';
totalcountColor='#06536a';
}*/
        Id accountId = PortalUtility.getAccountId();
        records2 =[select id,End_of_Term__c from Contract__c where End_of_Term__c!='' AND Account__c =: accountId]; // Modified by Sumit. Replaced '' with null; Added accountId filter 21st sept 2019
        
        for(Contract__c l : records2)
        {
            if(l.End_of_Term__c != null){
                if(mapLeadSource.containsKey(l.End_of_Term__c))
                {
                    if(l.End_of_Term__c == '3' || l.End_of_Term__c == '6'){
                        mapLeadSource.put(l.End_of_Term__c, mapLeadSource.get(l.End_of_Term__c)+1) ;
                        totalContract++;
                    }
                }else{
                    if(l.End_of_Term__c == '3' || l.End_of_Term__c == '6'){
                        mapLeadSource.put(l.End_of_Term__c, 1) ;
                        xlist.add(l.End_of_Term__c);
                        totalContract++;
                    }
                }
            }
        }
        for(String key : mapLeadSource.keySet())		// Modified by Sumit. Replaced String type with Decimal
        {
            system.debug('f1>>'+key+' '+mapLeadSource.get(key));
            retrunString=retrunString+',["'+key+'",'+mapLeadSource.get(key)+']';
        }
    }
    
}