public class testClass {
    @InvocableMethod(label='Update Opportunity Record' description='Bulk Update')
    public static List<String> updateOpportunities (List<fieldValues>fieldValues){
        List<String> lstOfString = new List <String>();
        system.debug(fieldValues);
        List<String> Ids = new List<String>();
        Ids = fieldValues[0].oppId;
        List<Opportunity> updateOpp = new List<Opportunity>();
        for(Opportunity opp :[Select Id,OwnerId,StageName From Opportunity Where Id IN: Ids]){
            //update fields
            system.debug(opp);
            system.debug(fieldValues[0].Owner);
            opp.OwnerId = fieldValues[0].Owner;
            updateOpp.add(opp);
        }
        lstOfString.add('Successfully Updated');
        update updateOpp;
        return lstOfString;
    }
    public class fieldValues {
        @InvocableVariable(required=true)public List<String> oppId;
        @InvocableVariable(required=true)public String Owner;
        @InvocableVariable(required=true)public String CustomerAccountId;
        @InvocableVariable(required=true)public String OppType;
        @InvocableVariable(required=true)public String Probablity;
        @InvocableVariable(required=true)public String netSalesPrice;
        @InvocableVariable(required=true)public String StageName;
        @InvocableVariable(required=true)public String LostReason;
        @InvocableVariable(required=true)public String Reason;
        @InvocableVariable(required=true)public String subStage;
    }
}