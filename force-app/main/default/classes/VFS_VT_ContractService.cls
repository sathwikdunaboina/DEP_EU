public class VFS_VT_ContractService {
    
    private static final Map<Schema.DisplayType, Object> MAP_DEFAULT_VALUES_BY_SCHEMA_TYPE = new Map<Schema.DisplayType, Object>{
        Schema.DisplayType.String => '',
            Schema.DisplayType.Currency => 0,
            Schema.DisplayType.Double => 0,
            Schema.DisplayType.Integer => 0,
            Schema.DisplayType.Percent => 0,
            Schema.DisplayType.Long => 0,
            Schema.DisplayType.Date => null,
            Schema.DisplayType.DateTime => null,
            Schema.DisplayType.Reference => '',
            Schema.DisplayType.Picklist => '',
            Schema.DisplayType.TextArea => '',
            Schema.DisplayType.EncryptedString => '',
            Schema.DisplayType.Phone => '',
            Schema.DisplayType.Email => '',
            Schema.DisplayType.URL => '',
            Schema.DisplayType.Boolean => false,
            Schema.DisplayType.Combobox => null,
            Schema.DisplayType.MultiPicklist => '',
            Schema.DisplayType.Address => '',
            Schema.DisplayType.Time => ''
            };
                
                public static List<SObject> transformSObjectToApicFormat (InputParameters param){
                    Map<String,Object> mapDefaultValueByFieldApiName = getFieldDefaultValueByFieldNameMap(param.sObjectName,param.setFields);
                    if (!param.listSObjects.isEmpty()) {
                        for (SObject oRecord : param.listSObjects) {
                            oRecord = handleDefaultValues(param.setFields,oRecord,mapDefaultValueByFieldApiName);
                        }
                        return param.listSObjects;
                    }
                    else{
                        return null;
                    }
                }
    
    private static SObject handleDefaultValues(Set<String> setfields, SObject oRecord,  Map<String,Object> mapDefaultValueByFieldApiName) {
        
        for (String field : setfields) {
            if (oRecord.get(field) == null) {
                oRecord.put(field,  mapDefaultValueByFieldApiName.get(field));
            }
        }
        return oRecord;
    }
    
    private static Map<String,Object> getFieldDefaultValueByFieldNameMap(String sObjectName,Set<String> setfields){
        Type sobjType = Type.forName(sObjectName);
        SObject oSobj = (SObject)sobjType.newInstance();
        Map<String, Schema.SObjectField> mapSchemaObjectFieldByFieldName = oSobj.getSObjectType().getDescribe().fields.getMap();
        Map<String,Object> mapDefaultValueByFieldApiName = new Map<String,Object>();
        
        for (String sField : setfields) {
            Schema.DescribeFieldResult describe = mapSchemaObjectFieldByFieldName.get(sField).getDescribe();
            if(describe.getType() == Schema.DisplayType.REFERENCE){
            }
            mapDefaultValueByFieldApiName.put(sField , MAP_DEFAULT_VALUES_BY_SCHEMA_TYPE.get(mapSchemaObjectFieldByFieldName.get(sField).getDescribe().getType())); 
        }
        return mapDefaultValueByFieldApiName; 
    }
    
    public static List<SObject> getTransformedContractRecords(List<Contract__c> listOfContractRecords) {
        Set<String> setFields = new Set<String>{'Id', 'Contract_Number__c', 'Type__c', 'Start_Date__c', 'End_Date__c','Contract_Status__c', 'Asset_Usage_Allowance__c', 'Asset_Contract_Start_Usage_Amount__c','Asset_Usage_Allowance_Type__c', 'VIN_Number__c', 'Territory_Manager_Name__c'};
                         
        VFS_VT_ContractService.InputParameters inputParametersInstance = new VFS_VT_ContractService.InputParameters();
        inputParametersInstance.sObjectName = 'Contract__c';
        inputParametersInstance.listSObjects = listOfContractRecords;
        inputParametersInstance.setFields = setFields;
        return transformSObjectToApicFormat(inputParametersInstance);
    }
    
    public class InputParameters{
        public String sObjectName {get;set;}
        public List<SObject> listSObjects {get;set;}
        public Set<String> setFields {get;set;}
        
        
        public InputParameters(){
            this.sObjectName  =  null ;
            this.listSObjects = null ;
            this.setFields = null;
        }
    }
}