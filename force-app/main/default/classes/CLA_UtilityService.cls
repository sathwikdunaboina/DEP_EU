/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_UtilityService
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-20-2024 
* @Used By            CLA_CreditLineConsumptionService ,CLA_CreditLineControlsService ,CLA_CreditLineSearchService ,CLA_CreditLineService
* @Test Coverded By   CLA_UtilityService_Test
* @SystemLayer        
* ------------------------------------------------------------------------------------------
* @description       This class is used to transform Sobject List to APIC format. 
* ------------------------------------------------------------------------------------------
*/

public with sharing class CLA_UtilityService {

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

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     transformSObjectToApicFormat
* @description     transform SObject list to Apic Format by adding default values in blank field
* ------------------------------------------------------------------------------------------------------
* @param          param             wrapper class which contain sObjectName ,sRelatedObjectName,sRelatedRelationShipName , 
                                    listSObject,setFields,setRelatedFields
* @return         List<SObject>     Returns transformed Sobject list
* ------------------------------------------------------------------------------------------------------ 
*/ 
   
    public static List<SObject> transformSObjectToApicFormat (InputParameters param){
   
        Map<String,Object> mapDefaultValueByFieldApiName = getFieldDefaultValueByFieldNameMap(param.sObjectName,param.setFields);
        if (!param.listSObjects.isEmpty()) {
                for (SObject oRecord : param.listSObjects) {
                       oRecord = handleDefaultValues(param.setFields,oRecord,mapDefaultValueByFieldApiName);
                       if (param.sRelatedObjectName != null) {
                            List<SObject> listRelatedRecords = oRecord.getSObjects(param.sRelatedRelationshipName);
                            listRelatedRecords = getRelatedRecords(listRelatedRecords,param.sRelatedObjectName,param.setRelatedFields);
                        }
                }
                return param.listSObjects;
        }
        else{
            return null;
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getRelatedRecords
* @description     handles transformation for related child records list
* ------------------------------------------------------------------------------------------------------
* @param          listRelatedRecords    List of related records ,List<SObject>             
* @param          sRelatedObjectName    Related object name     ,String
* @param          setRelatedFields      Related obejct field names ,Set<String>
* @return         List<SObject>         Returns transformed Sobject list
* ------------------------------------------------------------------------------------------------------ 
*/

    private static List<SObject> getRelatedRecords( List<SObject> listRelatedRecords,String sRelatedObjectName, Set<String>setRelatedFields){

        Map<String, Object> mapDefaultValueByFieldApiName = getFieldDefaultValueByFieldNameMap(sRelatedObjectName,setRelatedFields);
        if(listRelatedRecords == null || listRelatedRecords.isEmpty()){
            return listRelatedRecords;
        }

        if (listRelatedRecords != null && !listRelatedRecords.isEmpty()) {
            for (SObject oRelatedRecord : listRelatedRecords) {
                 oRelatedRecord = handleDefaultValues(setRelatedFields,oRelatedRecord,mapDefaultValueByFieldApiName);
            }
        }
        return listRelatedRecords;
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     handleDefaultValues
* @description     put default values for each sObject record
* ------------------------------------------------------------------------------------------------------
* @param          setfields                         Set of related records ,List<String>             
* @param          oRecord                           sObject record for transformation ,SObject 
* @param          mapDefaultValueByFieldApiName     Map of default values by field api name,Map<String,Object>
* @return         SObject                           Returns transformed Sobject
* ------------------------------------------------------------------------------------------------------ 
*/

    private static SObject handleDefaultValues(Set<String> setfields, SObject oRecord,  Map<String,Object> mapDefaultValueByFieldApiName) {
    
        for (String field : setfields) {
            if (oRecord.get(field) == null) {
                oRecord.put(field,  mapDefaultValueByFieldApiName.get(field));
            }
        }
        return oRecord;
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getFieldDefaultValueByFieldNameMap
* @description     Prepare map of default values by field api name with the help of Schema classes
* ------------------------------------------------------------------------------------------------------
* @param          sObjectName           Sobject field name,SObject             
* @param          setfields             Set of sObject fields for transformation,List<String>
* @return         Map<String,Object>    Returns map of default values by field api name
* ------------------------------------------------------------------------------------------------------ 
*/

    private static   Map<String,Object> getFieldDefaultValueByFieldNameMap(String sObjectName,Set<String> setfields){

        Type sobjType = Type.forName(sObjectName);
        SObject oSobj = (SObject)sobjType.newInstance();
        Map<String, Schema.SObjectField> mapSchemaObjectFieldByFieldName = oSobj.getSObjectType().getDescribe().fields.getMap();
        Map<String,Object> mapDefaultValueByFieldApiName = new Map<String,Object>();

        
        for (String sField : setfields) {
            mapDefaultValueByFieldApiName.put(sField , MAP_DEFAULT_VALUES_BY_SCHEMA_TYPE.get(mapSchemaObjectFieldByFieldName.get(sField).getDescribe().getType())); 
        }

        return mapDefaultValueByFieldApiName; 
    }

    public class InputParameters{ 
        public String sObjectName {get;set;}
        public String sRelatedObjectName {get;set;}
        public String sRelatedRelationShipName {get;set;}
        public List<SObject> listSObjects {get;set;}
        public Set<String> setFields {get;set;}
        public Set<String> setRelatedFields {get;set;}

     
        public InputParameters(){
           this.sObjectName  =  null ;
           this.sRelatedObjectName = null ;
           this.sRelatedRelationshipName = null;
           this.listSObjects = null ;
           this.setFields = null;
           this.setRelatedFields = null;
        }
      }
}