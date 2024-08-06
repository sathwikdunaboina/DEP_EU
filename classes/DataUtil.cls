public with sharing class DataUtil {
    public static List <SObject> queryObjectFields (String objectType, String whereClause, String limitClause) {        
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objectType);
        
        Map <String, Schema.SObjectField> fldObjMap = sObjType.getDescribe().fields.getMap();
        List <Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        
        String queryString = 'SELECT ';
        
        for (Schema.SObjectField s : fldObjMapValues) {
            String fieldName = s.getDescribe().getName();
            if(fieldName == 'Contract__c'){		// Added by Sumit
                queryString += 'Contract__r.Name' + ',';
            }
            // Continue building your dynamic query string
            queryString += fieldName + ',';
        }
        
        //     Trim last comma
        queryString = queryString.removeEnd(',');
        
        // Finalize query string
        queryString += ' FROM ' + objectType;
        
        queryString += whereClause != null ? ' WHERE ' + whereClause : '';
        queryString += limitClause != null ? ' ' + limitClause + ' ' : '';
        
        return Database.query(queryString);
    }
}